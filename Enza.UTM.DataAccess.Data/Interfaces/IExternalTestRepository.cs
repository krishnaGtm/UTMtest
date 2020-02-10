using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Args;
using System.Data;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface IExternalTestRepository : IRepository<object>
    {
        Task ImportDataAsync(ExternalTestImportRequestArgs requestArgs, DataTable dtColumnsTVP, DataTable dtRowTVP, DataTable dtCellTVP);

        Task<ExternalTestExportDataResult> GetExternalTestDataForExportAsync(int testID, bool markAsExported = false);
        Task<DataTable> GetExternalTestsLookupAsync(string cropCode, string brStationCode, bool showAll);
    }
}
