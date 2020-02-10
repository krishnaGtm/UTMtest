using System.Data;
using System.Net.Http;
using System.Threading.Tasks;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface ICNTService
    {
        Task<PhenoneImportDataResult> ImportDataAsync(HttpRequestMessage request, CNTRequestArgs args);
        Task<ExcelDataResult> GetDataAsync(ExcelDataRequestArgs requestArgs);
        Task AssignMarkersAsync(CNTAssignMarkersRequestArgs requestArgs);
        Task ManageMarkersAsync(CNTManageMarkersRequestArgs requestArgs);
        Task ManageInfoAsync(CNTManageInfoRequestArgs requestArgs);
        Task<MaterialsWithMarkerResult> GetDataWithMarkersAsync(MaterialsWithMarkerRequestArgs args);
        Task<byte[]> GetDataForExcelAsync(int testID);
    }
}
