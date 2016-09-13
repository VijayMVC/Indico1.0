using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;

using Indico.DAL;

namespace Indico.BusinessObjects
{
    public partial class UserBO : BusinessObject
    {
        #region Enum

        public enum ImageSize
        {
            Default,
            Medium,
            Large
        }

        #endregion

        #region OnPropertyChange Methods
        // Put implementations of OnBusinessObjectNameBOPropertyNameChanging()
        // and OnBusinessObjectNameBOPropertyNameChanged() here

        #endregion

        #region Extension Methods
        // Put methods to manipulate Business Objects here. Add, Update etc

        public UserBO Login(string username, string password)
        {
            this.Username = username;
            this.Password = password;

            var userAttemptingLogin = new UserBO();
            this.SetBO(userAttemptingLogin);
            var validUsers = new List<UserBO>();

            if (this.Context != null)
            {
                validUsers = userAttemptingLogin.ToList(this.Context.Context.GetUserLogin(username, password).ToList());
            }
            else
            {
                IndicoEntities objContext = new IndicoEntities();
                validUsers = userAttemptingLogin.ToList(objContext.GetUserLogin(username, password).ToList());
            }

            if (validUsers.Count > 0)
            {
                var user = new UserBO(_context);
                user.ID = validUsers[0].ID;
                user.GetObject(true);

                userAttemptingLogin.SetBO(user);
                this.SetBO(userAttemptingLogin);
            }

            return this;
        }

        public static bool VlidateUsername(int UserID, string Username)
        {
            var users = (new UserBO()).SearchObjects().Where(o => o.ID != UserID && o.Username.ToLower() == Username.ToLower()).ToList();
            return (users.Count == 0);
        }

        public static string GetNewEncryptedRandomPassword()
        {
            return GetNewEncryptedPassword(GetNewRandomPassword(6));
        }

        public static string GetNewEncryptedRandomPassword(int passwordLength)
        {
            return GetNewEncryptedPassword(GetNewRandomPassword(passwordLength));
        }

        public static string GetNewRandomPassword()
        {
            return GetNewRandomPassword(6);
        }

        public static string GetNewRandomPassword(int passwordLength)
        {
            string _allowedChars = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ0123456789";
            Random randNum = new Random();
            char[] chars = new char[passwordLength];
            int allowedCharCount = _allowedChars.Length;

            for (int i = 0; i < passwordLength; i++)
            {
                chars[i] = _allowedChars[(int)((_allowedChars.Length) * randNum.NextDouble())];
            }

            return new string(chars);
        }

        public static string GetNewEncryptedPassword(string password)
        {
            using (IndicoEntities objContext = new IndicoEntities())
            {
                var alParams = new ArrayList();
                alParams.Add(password);

                return objContext.GetEncryptedPassword(password).ToList()[0].RetVal;
            }
        }

        public static string GetProfilePicturePath(int UserID)
        {
            return UserBO.GetProfilePicturePath(UserID, ImageSize.Default);
        }

        public static string GetProfilePicturePath(UserBO objUser)
        {
            return UserBO.GetProfilePicturePath(objUser, ImageSize.Default);
        }

        public static string GetProfilePicturePath(int UserID, ImageSize size)
        {
            UserBO objUser = new UserBO();
            objUser.ID = UserID;
            objUser.GetObject();

            return UserBO.GetProfilePicturePath(objUser);
        }

        public static string GetProfilePicturePath(UserBO objUser, ImageSize size)
        {
            string physicalFolderPath = IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Users\\" + objUser.Guid + "\\";
            string profilePicturePath = "/" + IndicoConfiguration.AppConfiguration.DataFolderName + "/Users/";

            string imageSize = string.Empty;
            switch (size)
            {
                default:
                case ImageSize.Default: imageSize = "32px-32px";
                    break;
                case ImageSize.Medium: imageSize = "64px-64px";
                    break;
                case ImageSize.Large: imageSize = "96px-96px";
                    break;
            }

            string extention = Path.GetExtension(objUser.PhotoPath);
            if (!String.IsNullOrEmpty(objUser.PhotoPath) && File.Exists(physicalFolderPath + "user-profile-picture-" + imageSize + extention))
            {
                profilePicturePath += objUser.Guid + "/user-profile-picture-" + imageSize + extention;
            }
            else
            {
                profilePicturePath += "nouser-png-" + imageSize + ".png";
            }

            profilePicturePath += "?" + (new Random()).Next(10, 99).ToString();

            return profilePicturePath;
        }

        #endregion
    }
}