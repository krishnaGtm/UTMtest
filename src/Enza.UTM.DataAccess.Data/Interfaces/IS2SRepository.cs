using System.Collections.Generic;
using System.Data;
using System.Net.Http;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface IS2SRepository : IRepository<object>
    {
        Task<PhenoneImportDataResult> ImportDataFromPhenomeAsync(HttpRequestMessage request, S2SRequestArgs args);
        Task<IEnumerable<S2SCapacitySlotResult>> GetS2SCapacityAsync(S2SCapacitySlotArgs args);
        Task<DataSet> GetDataAsync(S2SGetDataRequestArgs requestArgs);
        Task<MaterialsWithMarkerResult> MarkerWithMaterialS2SAsync(MaterialsWithMarkerRequestArgs args);
        Task<Test> AssignDeterminationsAsync(AssignDeterminationForS2SRequestArgs args);
        Task<S2SFillRateDetail> GetFillRateDetailsAsync(int testID);
        Task UploadS2SDonorAsync(int testID);
        Task CreateDH0Async();
        Task<IEnumerable<CreateDHInfo>> GetDataToCreate(DHSyncConfig _config);
        //Task<DataSet> GetDH0Data(DHSyncConfig _config);
        Task<IEnumerable<DHSyncConfig>> GetSyncConfigAsync(int statusCode = 100);
        Task<IEnumerable<string>> GetDH0ToSyncGID(string cropCode);
        Task SaveCreatedDHGID(string list);
        Task<IEnumerable<MissingConversionResult>> GetConversionMissingData(DHSyncConfig config);
        Task<IEnumerable<S2SGetProgramCodesByCropResult>> GetProjectsAsync(string crop);

        Task ManageMarkersAsync(S2SManageMarkersRequestArgs requestArgs);
        Task<IEnumerable<S2SDH1Info>> GetDH1DetailsAsync(int testID);
        Task UpdateRelationDonorStatusAsync(string proposedName, int statusCode);
    }
}
