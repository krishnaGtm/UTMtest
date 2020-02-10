using System.Data;
using System.Net.Http;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface ICNTRepository : IRepository<object>
    {
        Task<ExcelDataResult> GetDataAsync(ExcelDataRequestArgs requestArgs);
        Task<PhenoneImportDataResult> ImportDataFromPhenomeAsync(HttpRequestMessage request, CNTRequestArgs args);
        Task AssignMarkersAsync(CNTAssignMarkersRequestArgs requestArgs);
        Task ManageMarkersAsync(CNTManageMarkersRequestArgs requestArgs);
        Task ManageInfoAsync(CNTManageInfoRequestArgs requestArgs);
        Task<MaterialsWithMarkerResult> GetDataWithMarkersAsync(MaterialsWithMarkerRequestArgs args);
        Task<byte[]> GetDataForExcelAsync(int testID);
    }
}
