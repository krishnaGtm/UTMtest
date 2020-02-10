using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Services
{
    public class ExcelDataService : IExcelDataService
    {
        readonly IExcelDataRepository repository;
        public ExcelDataService(IExcelDataRepository repository)
        {
            this.repository = repository;
        }

        public async Task<ExcelDataResult> ExportExcelDataToDBAsync(ImportDataRequestArgs args)
        {
            return await repository.ExportExcelDataToDBAsync(args);
        }

        public async Task<ExcelDataResult> GetDataAsync(ExcelDataRequestArgs args)
        {
            return await repository.GetDataAsync(args);
        }
    }
}
