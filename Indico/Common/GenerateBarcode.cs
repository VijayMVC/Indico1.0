using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Drawing;
using System.IO;

using Indico.BusinessObjects;

namespace Indico.Common
{
    public static class GenerateBarcode
    {
        #region fields

        private static int maxODCount = 9;

        #endregion

        #region methods

        public static void GeneratePackingLabel(Bitmap bmLabel, string orderNumber, string VLNumber, string size, string qty, string description, string distributor, string clientName, string labelText, string savingPath)
        {
            BarcodeLib.Barcode b = new BarcodeLib.Barcode();
            b.Alignment = BarcodeLib.AlignmentPositions.CENTER;
            BarcodeLib.TYPE type = BarcodeLib.TYPE.CODE93;

            try
            {
                if (type != BarcodeLib.TYPE.UNSPECIFIED)
                {
                    b.IncludeLabel = false; // true;

                    //b.RotateFlipType = (RotateFlipType)Enum.Parse(typeof(RotateFlipType), this.cbRotateFlip.SelectedItem.ToString(), true);

                    ////label alignment and position
                    //switch (this.cbLabelLocation.SelectedItem.ToString().Trim().ToUpper())
                    //{
                    //    case "BOTTOMLEFT": b.LabelPosition = BarcodeLib.LabelPositions.BOTTOMLEFT; break;
                    //    case "BOTTOMRIGHT": b.LabelPosition = BarcodeLib.LabelPositions.BOTTOMRIGHT; break;
                    //    case "TOPCENTER": b.LabelPosition = BarcodeLib.LabelPositions.TOPCENTER; break;
                    //    case "TOPLEFT": b.LabelPosition = BarcodeLib.LabelPositions.TOPLEFT; break;
                    //    case "TOPRIGHT": b.LabelPosition = BarcodeLib.LabelPositions.TOPRIGHT; break;
                    //    default: b.LabelPosition = BarcodeLib.LabelPositions.BOTTOMCENTER; break;
                    //}//switch

                    //string tempPath = "C:\\Barcode\\temp.jpg";
                    //Bitmap lblBM = new Bitmap(378, 113);

                    //using (Graphics gfx = Graphics.FromImage(lblBM))
                    //using (SolidBrush brush = new SolidBrush(Color.White))
                    //{
                    //    gfx.FillRectangle(brush, 0, 0, 378, 113);
                    //}

                    //lblBM.Save(tempPath);

                    // Image lblImg = Image.

                    //===== Encoding performed here =====
                    //Image barCodeIMG = b.Encode(type, labelText, 378, 75); //, Color.Black, Color.White, W, H);
                    labelText = "P" + labelText;
                    Image barCodeIMG = b.Encode(type, labelText, 270, 50);

                    // Bitmap bm = new Bitmap(barCodeIMG);
                    //Graphics graphics = Graphics.FromImage(bm);
                    //graphics.DrawString("Hello", new Font("Times New Roman", 10), Brushes.Black, 0, 0);

                    //bm.Save(savingPath, barCodeIMG.RawFormat);

                    //Bitmap bmpp = MergeTwoImages(Image.FromFile(tempPath), barCodeIMG);

                    //qty = "9999/9999";

                    Graphics graphics = Graphics.FromImage(bmLabel);
                    graphics.DrawString(distributor + " - " + clientName, new Font("Calibri", 8, FontStyle.Regular), Brushes.Black, 10, 10);
                    //graphics.DrawString(clientName, new Font("Calibri", 8, FontStyle.Bold), Brushes.Black, 135, 10);
                    graphics.DrawString("Order: " + orderNumber, new Font("Calibri", 9, FontStyle.Bold), Brushes.Black, 10, 22);
                    graphics.DrawString(VLNumber, new Font("Calibri", 9, FontStyle.Bold), Brushes.Black, 100, 22);
                    graphics.DrawString("Size: " + size, new Font("Calibri", 9, FontStyle.Bold), Brushes.Black, 180, 22);
                    graphics.DrawString("Qty: " + qty, new Font("Calibri", 9, FontStyle.Bold), Brushes.Black, 250, 22);
                    graphics.DrawString(description, new Font("Calibri", 8), Brushes.Black, 10, 34);
                    graphics.DrawImage(barCodeIMG, 0, 50, 300, 50); //  ("Order: " + orderNumber, new Font("Calibri", 8, FontStyle.Bold), Brushes.Black, 50, 10);
                    graphics.DrawString(labelText, new Font("Calibri", 8, FontStyle.Bold), Brushes.Black, 250, 100);

                    //var logo = new Bitmap(IndicoConfiguration.AppConfiguration.PathToDataFolder + "\\Logo\\blackchrome_logo.jpg");
                    //graphics.DrawImage(logo, 310, 50);

                    bmLabel.Save(savingPath, bmLabel.RawFormat);

                    //lblBM.Dispose();
                    //lblBM.Dispose();
                    //File.Delete(tempPath);

                    //===================================

                    //show the encoding time
                    //this.lblEncodingTime.Text = "(" + Math.Round(b.EncodingTime, 0, MidpointRounding.AwayFromZero).ToString() + "ms)";

                    string encodedvalue = b.EncodedValue;

                }//if

                //reposition the barcode image to the middle
                // barcode.Location = new Point((this.groupBox2.Location.X + this.groupBox2.Width / 2) - barcode.Width / 2, (this.groupBox2.Location.Y + this.groupBox2.Height / 2) - barcode.Height / 2);
            }//try
            catch (Exception ex)
            {
                // MessageBox.Show(ex.Message);
            }//catch
        }

        public static void GenerateCartonLabel(Bitmap bmLabel, string cartonNo, List<KeyValuePair<int, string>> listOrderDetails, string labelText, string savingLocation, string invoiceno /*DistributorClientAddressBO objDistributorClientAddress, string ShipmentMode*/)
        {
            BarcodeLib.Barcode b = new BarcodeLib.Barcode();
            b.Alignment = BarcodeLib.AlignmentPositions.CENTER;
            BarcodeLib.TYPE type = BarcodeLib.TYPE.CODE128;

            List<IGrouping<int, KeyValuePair<int, string>>> lstGroupedODs = listOrderDetails.GroupBy(m => m.Key).ToList();
            int orderDetailCount = lstGroupedODs.Count();
            int cartonLabelCount = (orderDetailCount % maxODCount == 0) ? orderDetailCount / maxODCount : (orderDetailCount / maxODCount) + 1;
            labelText = "C-" + labelText;

            try
            {
                if (type != BarcodeLib.TYPE.UNSPECIFIED)
                {
                    for (int k = 0; k < cartonLabelCount; k++)
                    {
                        b.IncludeLabel = false;
                        Image barCodeIMG = b.Encode(type, labelText, 250, 50);
                        Bitmap originalBM = new Bitmap(bmLabel);
                        Graphics graphics = Graphics.FromImage(originalBM);

                        graphics.DrawString("Carton #: " + cartonNo + ((cartonLabelCount > 1) ? " - " + (k + 1).ToString() : ""), new Font("Calibri", 22, FontStyle.Bold), Brushes.Black, 20, 10);
                        graphics.DrawString(invoiceno, new Font("Calibri", 12, FontStyle.Bold), Brushes.Black, 180, 15);
                        graphics.DrawString("Po No", new Font("Calibri", 8, FontStyle.Bold), Brushes.Black, 10, 40);
                        graphics.DrawString("Client", new Font("Calibri", 8, FontStyle.Bold), Brushes.Black, 50, 40);
                        graphics.DrawString("VL No", new Font("Calibri", 8, FontStyle.Bold), Brushes.Black, 150, 40);
                        graphics.DrawString("Sizes", new Font("Calibri", 8, FontStyle.Bold), Brushes.Black, 250, 40);

                        float yValue = 40;

                        foreach (IGrouping<int, KeyValuePair<int, string>> objOrderDetail in lstGroupedODs.GetRange(0, (lstGroupedODs.Count > maxODCount) ? maxODCount : lstGroupedODs.Count))
                        {
                            yValue += 15;
                            int i = 0;

                            foreach (KeyValuePair<int, string> item in objOrderDetail.OrderBy(m => m.Key))
                            {
                                switch (++i)
                                {
                                    case 1:
                                        graphics.DrawString(item.Value, new Font("Calibri", 8), Brushes.Black, 10, yValue);
                                        break;
                                    case 2:
                                        graphics.DrawString(item.Value.Substring(0, Math.Min(15, item.Value.Length)), new Font("Calibri", 8), Brushes.Black, 50, yValue);
                                        break;
                                    case 3:
                                        graphics.DrawString(item.Value, new Font("Calibri", 8), Brushes.Black, 150, yValue);
                                        break;
                                    case 4: // size
                                        graphics.DrawString(item.Value, new Font("Calibri", 8), Brushes.Black, 250, yValue);
                                        break;
                                }
                            }
                        }

                        lstGroupedODs.RemoveRange(0, (lstGroupedODs.Count > maxODCount) ? maxODCount : lstGroupedODs.Count);
                        graphics.DrawImage(barCodeIMG, 10, 200, 250, 50);
                        originalBM.Save(savingLocation + labelText.Replace('/', '_') + "-" + k + ".jpg", originalBM.RawFormat);
                        //originalBM.Dispose();
                        graphics.Dispose();
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public static string GenerateResetLabel(Bitmap bmLabel, string labelText, string saveLocation)
        {
            string savePath = saveLocation + labelText.Replace('/', '_') + "- Reset" + ".jpg";
            try
            {
                BarcodeLib.Barcode b = new BarcodeLib.Barcode();
                b.Alignment = BarcodeLib.AlignmentPositions.CENTER;
                BarcodeLib.TYPE type = BarcodeLib.TYPE.CODE128;

                if (type != BarcodeLib.TYPE.UNSPECIFIED)
                {
                    b.IncludeLabel = false;
                    Image barCodeIMG = b.Encode(type, labelText, 250, 50);
                    Bitmap originalBM = new Bitmap(bmLabel);
                    Graphics graphics = Graphics.FromImage(originalBM);

                    graphics.DrawString("Reset", new Font("Calibri", 24, FontStyle.Bold), Brushes.Black, 20, 10);

                    graphics.DrawImage(barCodeIMG, 10, 200, 250, 50);
                    originalBM.Save(savePath, originalBM.RawFormat);
                    //originalBM.Dispose();
                    graphics.Dispose();
                }
            }
            catch (Exception ex)
            {
                IndicoLogging.log.Error("Error occured while generating Reset Barcode Label from GenerateBarcode.cs", ex);
            }

            return savePath;
        }

        public static Bitmap MergeTwoImages(Image firstImage, Image secondImage)
        {
            if (firstImage == null)
            {
                throw new ArgumentNullException("firstImage");
            }

            if (secondImage == null)
            {
                throw new ArgumentNullException("secondImage");
            }

            int outputImageWidth = firstImage.Width > secondImage.Width ? firstImage.Width : secondImage.Width;

            int outputImageHeight = firstImage.Height + secondImage.Height + 1;

            Bitmap outputImage = new Bitmap(outputImageWidth, outputImageHeight, System.Drawing.Imaging.PixelFormat.Format32bppArgb);

            using (Graphics graphics = Graphics.FromImage(outputImage))
            {
                graphics.DrawImage(firstImage, new Rectangle(new Point(), firstImage.Size),
                    new Rectangle(new Point(), firstImage.Size), GraphicsUnit.Pixel);
                graphics.DrawImage(secondImage, new Rectangle(new Point(0, firstImage.Height + 1), secondImage.Size),
                    new Rectangle(new Point(), secondImage.Size), GraphicsUnit.Pixel);
            }

            firstImage.Dispose();
            secondImage.Dispose();

            return outputImage;
        }

        #endregion
    }
}