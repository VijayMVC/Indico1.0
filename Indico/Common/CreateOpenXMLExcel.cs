using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ClosedXML.Excel;

namespace Indico.Common
{
    public class CreateOpenXMLExcel
    {
        #region Fields

        XLWorkbook workbook = null;

        #endregion

        #region Properties

        private IXLWorksheet ws { get; set; }

        #endregion

        #region Constructors

        public CreateOpenXMLExcel(string SheetName)
        {
            workbook = new XLWorkbook();
            ws = workbook.Worksheets.Add(SheetName);
        }

        #endregion

        #region Methods

        public void SetPageSetup(XLPageOrientation orientation, XLPaperSize paperSize)
        {
            ws.PageSetup.PageOrientation = orientation;
            ws.PageSetup.PaperSize = paperSize;
        }

        public void SetMargings(double _top, double _bottom, double _left, double _right, double _footer, double _header, bool _isCenterHorizontally, bool _isCenterVertically)
        {
            ws.PageSetup.Margins.Top = _top;
            ws.PageSetup.Margins.Bottom = _bottom;
            ws.PageSetup.Margins.Left = _left;
            ws.PageSetup.Margins.Right = _right;
            ws.PageSetup.Margins.Footer = _footer;
            ws.PageSetup.Margins.Header = _header;

            ws.PageSetup.CenterHorizontally = _isCenterHorizontally;
            ws.PageSetup.CenterVertically = _isCenterVertically;
        }

        public void ChangeColumnWidth(int column, int width)
        {
            ws.Column(column).Width = width;
        }

        public void AddHeaderData(string cell, string cellvalue, string font, bool isBold, XLAlignmentHorizontalValues Alignment, double fontsize, XLCellValues DataType)
        {

            ws.Cell(cell).Value = cellvalue;
            ws.Cell(cell).Style.Font.FontName = font;
            ws.Cell(cell).Style.Font.Bold = isBold;
            ws.Cell(cell).Style.Font.FontSize = fontsize;
            ws.Cell(cell).Style.Alignment.Horizontal = Alignment;
            ws.Cell(cell).DataType = DataType;
        }

        public void AddHeaderData(string cell, string cellvalue, string font, bool isBold, XLAlignmentHorizontalValues Alignment, double fontsize, string mergeCellReference, XLCellValues DataType)
        {

            ws.Cell(cell).Value = cellvalue;
            ws.Cell(cell).Style.Font.FontName = font;
            ws.Cell(cell).Style.Font.Bold = isBold;
            ws.Cell(cell).Style.Font.FontSize = fontsize;
            ws.Cell(cell).Style.Alignment.Horizontal = Alignment;
            ws.Range(mergeCellReference).Merge();
            ws.Cell(cell).DataType = DataType;
        }

        public void AddHeaderData(string cell, string cellvalue, string font, bool isBold, XLAlignmentHorizontalValues Alignment, double fontsize, string mergeCellReference, XLCellValues DataType, XLColor bgColor)
        {

            ws.Cell(cell).Value = cellvalue;
            ws.Cell(cell).Style.Font.FontName = font;
            ws.Cell(cell).Style.Font.Bold = isBold;
            ws.Cell(cell).Style.Font.FontSize = fontsize;
            ws.Cell(cell).Style.Alignment.Horizontal = Alignment;
            ws.Range(mergeCellReference).Merge();
            ws.Cell(cell).DataType = DataType;
            ws.Cell(cell).Style.Fill.BackgroundColor = bgColor;
        }

        public void AddHeaderData(string cell, string cellvalue, string font, bool isBold, XLAlignmentHorizontalValues Alignment, double fontsize, XLCellValues DataType, XLColor bgColor)
        {

            ws.Cell(cell).Value = cellvalue;
            ws.Cell(cell).Style.Font.FontName = font;
            ws.Cell(cell).Style.Font.Bold = isBold;
            ws.Cell(cell).Style.Font.FontSize = fontsize;
            ws.Cell(cell).Style.Alignment.Horizontal = Alignment;
            ws.Cell(cell).DataType = DataType;
            ws.Cell(cell).Style.Fill.BackgroundColor = bgColor;
        }

        public void AddCellValue(string cell, string cellvalue, string font, bool isBold, XLAlignmentHorizontalValues Alignment, double fontsize, XLCellValues DataType, XLColor bgColor)
        {
            ws.Cell(cell).Value = cellvalue;
            ws.Cell(cell).Style.Font.FontName = font;
            ws.Cell(cell).Style.Font.Bold = isBold;
            ws.Cell(cell).Style.Font.FontSize = fontsize;
            ws.Cell(cell).Style.Alignment.Horizontal = Alignment;
            ws.Cell(cell).DataType = DataType;
            ws.Cell(cell).Style.Fill.BackgroundColor = bgColor;
        }

        public void AddCellValue(string cell, string cellvalue, string font, bool isBold, XLAlignmentHorizontalValues Alignment, double fontsize, XLCellValues DataType)
        {
            ws.Cell(cell).Value = cellvalue;
            ws.Cell(cell).Style.Font.FontName = font;
            ws.Cell(cell).Style.Font.Bold = isBold;
            ws.Cell(cell).Style.Font.FontSize = fontsize;
            ws.Cell(cell).Style.Alignment.Horizontal = Alignment;
            ws.Cell(cell).DataType = DataType;
        }

        public void AddCellValueNumberFormat(string cell, string cellvalue, string font, bool isBold, XLAlignmentHorizontalValues Alignment, double fontsize, string numFormat)
        {
            ws.Cell(cell).Value = cellvalue;
            ws.Cell(cell).Style.NumberFormat.Format = numFormat;
            ws.Cell(cell).Style.Font.FontName = font;
            ws.Cell(cell).Style.Font.Bold = isBold;
            ws.Cell(cell).Style.Font.FontSize = fontsize;
            ws.Cell(cell).Style.Alignment.Horizontal = Alignment;
        }

        public void AddCellValueNumberFormat(string cell, string cellvalue, string font, bool isBold, XLAlignmentHorizontalValues Alignment, double fontsize, string numFormat, XLColor bgColor)
        {
            ws.Cell(cell).Value = cellvalue;
            ws.Cell(cell).Style.NumberFormat.Format = numFormat;
            ws.Cell(cell).Style.Font.FontName = font;
            ws.Cell(cell).Style.Font.Bold = isBold;
            ws.Cell(cell).Style.Font.FontSize = fontsize;
            ws.Cell(cell).Style.Alignment.Horizontal = Alignment;
            ws.Cell(cell).Style.Fill.BackgroundColor = bgColor;
        }

        public void AddHeaderDataWrapText(string cell, string cellvalue, string font, bool isBold, XLAlignmentHorizontalValues Alignment, double fontsize, string mergeCellReference, XLCellValues DataType, XLColor bgColor, XLAlignmentVerticalValues VerticalAlignment)
        {

            ws.Cell(cell).Value = cellvalue;
            ws.Cell(cell).Style.Font.FontName = font;
            ws.Cell(cell).Style.Font.Bold = isBold;
            ws.Cell(cell).Style.Font.FontSize = fontsize;
            ws.Cell(cell).Style.Alignment.Horizontal = Alignment;
            ws.Cell(cell).Style.Alignment.Vertical = VerticalAlignment;
            ws.Range(mergeCellReference).Merge();
            ws.Cell(cell).DataType = DataType;
            ws.Cell(cell).Style.Fill.BackgroundColor = bgColor;
            ws.Cell(cell).Style.Alignment.SetWrapText();
        }

        public void AddHeaderDataWrapText(string cell, string cellvalue, string font, bool isBold, XLAlignmentHorizontalValues Alignment, double fontsize, XLCellValues DataType, XLAlignmentVerticalValues VerticalAlignment)
        {

            ws.Cell(cell).Value = cellvalue;
            ws.Cell(cell).Style.Font.FontName = font;
            ws.Cell(cell).Style.Font.Bold = isBold;
            ws.Cell(cell).Style.Font.FontSize = fontsize;
            ws.Cell(cell).Style.Alignment.Horizontal = Alignment;
            ws.Cell(cell).DataType = DataType;
            ws.Cell(cell).Style.Alignment.Vertical = VerticalAlignment;
            ws.Cell(cell).Style.Alignment.SetWrapText();
        }

        public void AutotFilter(string cellRefernce)
        {
            ws.Range(cellRefernce).SetAutoFilter();
        }

        public void FreezePane(int row, int column)
        {
            ws.SheetView.Freeze(row, column);
        }

        public void DrawBottomBorder(int row, int col, XLBorderStyleValues Style, XLColor Color)
        {
            ws.Cell(row, col).Style.Border.BottomBorder = Style;
            ws.Cell(row, col).Style.Border.BottomBorderColor = Color;

        }

        public void DrawLeftBorder(int row, int col, XLBorderStyleValues Style, XLColor Color)
        {
            ws.Cell(row, col).Style.Border.LeftBorder = Style;
            ws.Cell(row, col).Style.Border.LeftBorderColor = Color;

        }

        public void DrawToptBorder(int row, int col, XLBorderStyleValues Style, XLColor Color)
        {
            ws.Cell(row, col).Style.Border.TopBorder = Style;
            ws.Cell(row, col).Style.Border.TopBorderColor = Color;

        }

        public void DrawRightBorder(int row, int col, XLBorderStyleValues Style, XLColor Color)
        {
            ws.Cell(row, col).Style.Border.RightBorder = Style;
            ws.Cell(row, col).Style.Border.RightBorderColor = Color;

        }

        public void DrawOutSideBorder(string cellRange)
        {
            var rngTable = ws.Range(cellRange);
            rngTable.Style.Border.OutsideBorder = XLBorderStyleValues.Thin;
        }

        public void DrawInsideBorder(string cellRange)
        {
            var rngTable = ws.Range(cellRange);
            rngTable.Style.Border.InsideBorder = XLBorderStyleValues.Thin;
        }

        public void FooterRight(string _text, XLHFOccurrence _xlhfOccurence)
        {
            ws.PageSetup.Footer.Right.AddText(_text, _xlhfOccurence);
        }

        public void FooterCenter(string _text, XLHFOccurrence _xlhfOccurence)
        {
            ws.PageSetup.Footer.Center.AddText(_text, _xlhfOccurence);
        }

        public void FooterLeft(string _text, XLHFOccurrence _xlhfOccurence)
        {
            ws.PageSetup.Footer.Left.AddText(_text, _xlhfOccurence);
        }

        public void FooterRight(XLHFPredefinedText _text, XLHFOccurrence _xlhfOccurence)
        {
            ws.PageSetup.Footer.Right.AddText(_text, _xlhfOccurence);
        }

        public void FooterCenter(XLHFPredefinedText _text, XLHFOccurrence _xlhfOccurence)
        {
            ws.PageSetup.Footer.Center.AddText(_text, _xlhfOccurence);
        }

        public void FooterLeft(XLHFPredefinedText _text, XLHFOccurrence _xlhfOccurence)
        {
            ws.PageSetup.Footer.Left.AddText(_text, _xlhfOccurence);
        }

        public void CloseDocument(string filePath)
        {
            workbook.SaveAs(filePath);         
        }

        #endregion

    }
}