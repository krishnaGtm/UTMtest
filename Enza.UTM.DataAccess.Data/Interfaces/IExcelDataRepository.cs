using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using System.Data;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface IExcelDataRepository: IRepository<object>
    {
        Task ImportDataAsync(string crop, string breedingStation,string syncCode, string countryCode, ImportDataRequestArgs requestArgs,
            DataTable dtColumnsTVP, DataTable dtRowTVP, DataTable dtCellTVP, DataTable dtListTVP);
        Task<ExcelDataResult> ExportExcelDataToDBAsync(ImportDataRequestArgs requestArgs);
        Task<ExcelDataResult> GetDataAsync(ExcelDataRequestArgs requestArgs);
        //Task<DataSet> ValidateColumnsForUniqueDeterminations(DataTable dtColumnsTVP, string crop, string source);
    }
}
