using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using iTextSharp.text.pdf;
using iTextSharp.text;

namespace Indico.Common
{


    public class PDFFooter : PdfPageEventHelper
    {
        #region Fields

        private static PdfContentByte contentByte;
        private static BaseFont customFont_PDF;
        private static BaseFont customFontBold_PDF;
        private string Content { get; set; }
        private bool IsVisible { get; set; }

        #endregion

        #region Properties

        private static BaseFont PDFFont
        {
            get
            {
                if (customFont_PDF == null)
                {
                    customFont_PDF = BaseFont.CreateFont((@"C:\Projects\Indico\IndicoData\fonts\DaxOT-WideRegular.otf"), BaseFont.CP1252, BaseFont.EMBEDDED);
                }
                return customFont_PDF;
            }
        }
        
        public static BaseFont PDFFontBold
        {
            get
            {
                if (customFontBold_PDF == null)
                {
                    customFontBold_PDF = BaseFont.CreateFont((@"C:\Projects\Indico\IndicoData\fonts\DaxOT-WideBold.otf"), BaseFont.CP1252, BaseFont.EMBEDDED);
                }
                return customFontBold_PDF;
            }
        }

        #endregion

        #region Constructors

        public PDFFooter(string content, bool isVisible)
        {
            Content = content;
            IsVisible = isVisible;
        }

        #endregion

        #region Methods

        // write on top of document
        public override void OnOpenDocument(PdfWriter writer, Document document)
        {
            base.OnOpenDocument(writer, document);
            /* PdfPTable tabFot = new PdfPTable(new float[] { 1F });
             tabFot.SpacingAfter = 10F;
             PdfPCell cell;
             tabFot.TotalWidth = 300F;
             cell = new PdfPCell(new Phrase("Header"));
             tabFot.AddCell(cell);
             tabFot.WriteSelectedRows(0, -1, 150, document.Top, writer.DirectContent); */
        }

        // write on start of each page
        public override void OnStartPage(PdfWriter writer, Document document)
        {
            /* base.OnStartPage(writer, document);
             PdfPTable tabFot = new PdfPTable(new float[] { 1F });
             PdfPCell cell;
             tabFot.TotalWidth = 300F;
             cell = new PdfPCell(new Phrase("Footer"));
             tabFot.AddCell(cell);
             tabFot.WriteSelectedRows(0, -1, 150, document.Top, writer.DirectContent);
             cell.Border = 0;*/

            float marginBottom = 12;
            float lineHeight = 14;
            float pageMargin = 20;
            float pageHeight = iTextSharp.text.PageSize.A4.Height;
            float pageWidth = iTextSharp.text.PageSize.A4.Width;

            contentByte = writer.DirectContent;

            contentByte.BeginText();
            string content = string.Empty;
            string content_1 = string.Empty;
            string pageNo = string.Empty;
            //string page = "Page " + writer.GetPageReference();


            //Header
            contentByte.SetFontAndSize(PDFFontBold, 12);
            content = Content;
            contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content, pageMargin, (pageHeight - pageMargin - lineHeight), 0);

            if (IsVisible == true)
            {
                contentByte.SetFontAndSize(PDFFont, 6);
                content_1 = "Suit 43,125 Highbury Road, Burwood, VIC 3125";
                contentByte.ShowTextAligned(PdfContentByte.ALIGN_LEFT, content_1, pageMargin, (pageHeight - pageMargin - 22), 0);
            }
            // set Page Number
            contentByte.SetFontAndSize(PDFFont, 8);
            pageNo = "Page " + writer.PageNumber.ToString();
            contentByte.ShowTextAligned(PdfContentByte.ALIGN_RIGHT, pageNo, (pageWidth - 30), (pageHeight - pageMargin - lineHeight), 0);

            contentByte.EndText();
            // Top Line
            contentByte.SetLineWidth(0.5f);
            contentByte.SetColorStroke(BaseColor.BLACK);
            contentByte.MoveTo(pageMargin, (pageHeight - pageMargin - lineHeight - marginBottom - 4));
            contentByte.LineTo((pageWidth - pageMargin), (pageHeight - pageMargin - lineHeight - marginBottom - 4));
            contentByte.Stroke();
        }

        // write on end of each page
        public override void OnEndPage(PdfWriter writer, Document document)
        {
            base.OnEndPage(writer, document);
            /*  PdfPTable tabFot = new PdfPTable(new float[] { 1F });
              PdfPCell cell;
              tabFot.TotalWidth = 300F;
              cell = new PdfPCell(new Phrase("Footer"));
              tabFot.AddCell(cell);
              tabFot.WriteSelectedRows(0, -1, 150, document.Bottom, writer.DirectContent);*/
        }

        //write on close of document
        public override void OnCloseDocument(PdfWriter writer, Document document)
        {
            base.OnCloseDocument(writer, document);
        }

        #endregion

    }
}