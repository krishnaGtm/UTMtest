using System.Collections.Generic;
using System.Data;
using System.Net.Http;
using System.Threading.Tasks;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using Enza.UTM.Services.Proxies;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface IS2SService
    {
        Task<ExcelDataResult> ImportDataAsync(HttpRequestMessage request, S2SRequestArgs args);
        Task<IEnumerable<S2SCapacitySlotResult>> GetS2SCapacityAsync(S2SCapacitySlotArgs args);
        Task<ExcelDataResult> GetDataAsync(ExcelDataRequestArgs requestArgs);
        Task<MaterialsWithMarkerResult> MarkerWithMaterialS2SAsync(MaterialsWithMarkerRequestArgs args);
        Task<Test> AssignDeterminationsAsync(AssignDeterminationForS2SRequestArgs args);
        Task<S2SFillRateDetail> GetFillRateDetailsAsync(int testID);
        Task UploadS2SDonorAsync(int testID);
        Task<List<ExecutableError>> CreateDHAsync();
        Task<IEnumerable<S2SGetProgramCodesByCropResult>> GetProjectsAsync(string crop);
        Task ManageMarkersAsync(S2SManageMarkersRequestArgs requestArgs);
        Task<List<ExecutableError>> StoreGIDinCordysAsync();
    }
}
