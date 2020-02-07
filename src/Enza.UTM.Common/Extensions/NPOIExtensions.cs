using System.Linq;
using System.Reflection;
using NPOI.OpenXmlFormats.Spreadsheet;
using NPOI.SS.UserModel;
using NPOI.XSSF.UserModel;

namespace Enza.UTM.Common.Extensions
{
    public static class NPOIExtensions
    {
        public static string GetCellStyleName(this NPOI.XSSF.Model.StylesTable stylesTable, ICell cell)
        {
            var style = cell.CellStyle as XSSFCellStyle;            
            var flags = BindingFlags.Public | BindingFlags.Instance | BindingFlags.NonPublic;
            var method = stylesTable.GetType().GetMethod("GetCTStylesheet", flags);
            if (method == null)
                return string.Empty;

            var styleSheet = (CT_Stylesheet)method.Invoke(stylesTable, null);
            var idx = style.GetCoreXf().xfId;
            var name = styleSheet.cellStyles.cellStyle.FirstOrDefault(o => o.xfId == idx)?.name;
            return name ?? string.Empty;
        }
    }
}
