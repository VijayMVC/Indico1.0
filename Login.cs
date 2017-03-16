using System;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Windows.Forms;

using IndicoPacking.Common;
using IndicoPacking.Model;

namespace IndicoPacking
{
    public partial class Login : Form
    {
        #region Fields

        readonly IndicoPackingEntities _context;

        #endregion

        #region Constructors

        public Login()
        {
            InitializeComponent();
            _context = new IndicoPackingEntities();

            StartPosition = FormStartPosition.CenterScreen;
        }

        private void frmLogin_Load(object sender, EventArgs e)
        {
            var imagePath = (new FileInfo(Application.ExecutablePath).DirectoryName)+ @"\images\logo_login.png";
            var b = new Bitmap(imagePath);
            picLogo.SizeMode = PictureBoxSizeMode.CenterImage;
            picLogo.BackgroundImage = b;
        }

        #endregion      

        #region Events

        private void btnCancel_Click(object sender, EventArgs e)
        {
            DialogResult = DialogResult.Cancel;
            Environment.Exit(0);
        }

        private void btnLogin_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtUsername.Text) && string.IsNullOrWhiteSpace(txtPassword.Text))
            {
                MessageBox.Show("User name and password cannot be empty", "Information", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }
                  
            var user = _context.Users.FirstOrDefault(u => u.Username.ToLower() == txtUsername.Text.ToLower().Trim());
            if (user == null)
            {
                MessageBox.Show("User name or password invalid", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            var password = Security.EncryptPassword(txtPassword.Text.Trim(), user.PasswordSalt);
            if (user.Password == password)
            {
                user.DateLastLogin = DateTime.Now;
                _context.SaveChanges();
                Hide();
                LoginInfo.UserID = user.ID;
                LoginInfo.Role = (UserType)user.Role;
                DialogResult = DialogResult.OK;
                Close();
                return;
            }

            MessageBox.Show("User name or password invalid", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        #endregion
    }
}
