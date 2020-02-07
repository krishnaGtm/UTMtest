using System.Threading.Tasks;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface IExcelDataService
    {
        Task<ExcelDataResult> ExportExcelDataToDBAsync(ImportDataRequestArgs args);
        Task<ExcelDataResult> GetDataAsync(ExcelDataRequestArgs args);
    }
}
