using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Drawing;

using Indico.BusinessObjects;
using System.Drawing.Drawing2D;

namespace Indico.Common
{
    public class ImageProcess
    {
        public void ResizeImage(string originalFilePath, string newFilePath, float newWidth, float newHeight)
        {
            System.Drawing.Image FullsizeImage = System.Drawing.Image.FromFile(originalFilePath);

            // Prevent using images internal thumbnail
            FullsizeImage.RotateFlip(System.Drawing.RotateFlipType.Rotate180FlipNone);
            FullsizeImage.RotateFlip(System.Drawing.RotateFlipType.Rotate180FlipNone);

            if (FullsizeImage.Width <= newWidth && FullsizeImage.Height <= newHeight)
            {
                File.Copy(originalFilePath, newFilePath);
            }
            else
            {
                List<float> resizedDimension = this.GetResizedImageDimension(FullsizeImage.Width, FullsizeImage.Height, newWidth, newHeight);

                System.Drawing.Image NewImage = FullsizeImage.GetThumbnailImage(FloatToInt(resizedDimension[1]), FloatToInt(resizedDimension[0]), null, IntPtr.Zero);
                FullsizeImage.Dispose();// Clear handle to original file so that we can overwrite it if necessary
                NewImage.Save(newFilePath);// Save resized picture
            }
        }

        /// <summary>
        /// returns resized height and width
        /// </summary>
        /// <param name="originalWidth"></param>
        /// <param name="originalHeight"></param>
        /// <param name="newWidth"></param>
        /// <param name="newHeight"></param>
        /// <returns></returns>        
        public List<float> GetResizedImageDimension(int originalWidth, int originalHeight, float newWidth, float newHeight)
        {
            float displayHeight = 0;
            float displayWidth = 0;
            List<float> lstDimensions = new List<float>();

            if (originalHeight > originalWidth)
            {
                if (originalHeight > newHeight)
                {
                    displayHeight = newHeight;
                    displayWidth = (float)Math.Round(((newHeight / originalHeight) * originalWidth), 0);

                    if (displayWidth > newWidth)
                    {
                        displayWidth = newWidth;
                        displayHeight = (float)Math.Round(((newWidth / originalWidth) * originalHeight), 0);
                    }
                }
                else
                {
                    displayHeight = originalHeight;
                    displayWidth = originalWidth;
                }
            }
            else
            {
                if (originalWidth > newWidth)
                {
                    displayWidth = newWidth;
                    displayHeight = (float)Math.Round(((newWidth / originalWidth) * originalHeight), 0);

                    if (displayHeight > newHeight)
                    {
                        displayHeight = newHeight;
                        displayWidth = (float)Math.Round(((newHeight / originalHeight) * originalWidth), 0);
                    }
                }
                else
                {
                    displayHeight = originalHeight;
                    displayWidth = originalWidth;
                }
            }

            lstDimensions.Add(displayHeight);
            lstDimensions.Add(displayWidth);

            return lstDimensions;
        }

        public List<float> GetResizedImageDimensionForHeight(int originalWidth, int originalHeight, float newHeight)
        {
            float tempHeight = 0;
            float tempWidth = 0;
            List<float> lstDimensions = new List<float>();

            if (originalHeight > newHeight)
            {
                tempHeight = newHeight;
                tempWidth = (float)Math.Round(((newHeight / originalHeight) * originalWidth), 0);
            }
            else
            {
                tempHeight = originalHeight;
                tempWidth = originalWidth;
            }

            lstDimensions.Add(tempHeight);
            lstDimensions.Add(tempWidth);

            return lstDimensions;
        }

        public List<float> GetResizedImageDimensionForWidth(int originalWidth, int originalHeight, float newWidth)
        {
            float tempHeight = 0;
            float tempWidth = 0;
            List<float> lstDimensions = new List<float>();

            if (originalWidth > newWidth)
            {
                tempWidth = newWidth;
                tempHeight = (float)Math.Round(((newWidth / originalWidth) * originalHeight), 0);
            }
            else
            {
                tempHeight = originalHeight;
                tempWidth = originalWidth;
            }

            lstDimensions.Add(tempHeight);
            lstDimensions.Add(tempWidth);

            return lstDimensions;
        }

        public List<float> GetResizedImageDimensions(string imagePath)
        {
            string filePath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + imagePath;
            if (File.Exists(filePath))
            {
                System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(filePath);
                SizeF origImageSize = VLOrigImage.PhysicalDimension;
                VLOrigImage.Dispose();

                List<float> lstImgDimensions = this.GetResizedImageDimension(Convert.ToInt32(Math.Abs(origImageSize.Width)), Convert.ToInt32(Math.Abs(origImageSize.Height)), 250, 140);

                return lstImgDimensions;
            }
            else
            {
                return new List<float>();
            }
        }

        public List<float> GetOriginalImageDimensions(string imagePath)
        {
            string filePath = IndicoConfiguration.AppConfiguration.PathToProjectFolder + "\\" + imagePath;
            if (File.Exists(filePath))
            {
                System.Drawing.Image VLOrigImage = System.Drawing.Image.FromFile(filePath);
                SizeF origImageSize = VLOrigImage.PhysicalDimension;
                VLOrigImage.Dispose();

                List<float> lstImgDimensions = new List<float>();
                lstImgDimensions.Add(origImageSize.Height);
                lstImgDimensions.Add(origImageSize.Width);

                return lstImgDimensions;
            }
            else
            {
                return new List<float>();
            }
        }

        public void ResizeWebServiceImages(int newWidth, int newHeight, string srcImage, string newSource)
        {
            Image SrcImg = Image.FromFile(srcImage);

            Bitmap newImage = new Bitmap(newWidth, newHeight);
            using (Graphics gr = Graphics.FromImage(newImage))
            {
                gr.SmoothingMode = SmoothingMode.HighQuality;
                gr.InterpolationMode = InterpolationMode.HighQualityBicubic;
                gr.PixelOffsetMode = PixelOffsetMode.HighQuality;
                gr.DrawImage(SrcImg, new Rectangle(0, 0, newWidth, newHeight));

                newImage.Save(newSource);
            }
        }

        private static int FloatToInt(float f)
        {
            return (int)Math.Floor(f + 0.5);
        }
    }
}