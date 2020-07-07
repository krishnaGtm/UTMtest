using System.Data;
using System.Threading.Tasks;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface IExternalTestService
    {
        Task<ImportDataResult> ImportDataAsync(ExternalTestImportRequestArgs requestArgs);
        Task<byte[]> GetExcelFileForExternalTestAsync(int testID, bool markAsExported = false, bool traitScore = false);
        Task<DataTable> GetExternalTestsLookupAsync(string cropCode, string brStationCode, bool showAll);
    }
}
