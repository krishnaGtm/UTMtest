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
    public interface IRDTService
    {
        Task<ExcelDataResult> ImportDataFromPhenomeAsync(HttpRequestMessage request, PhenomeImportRequestArgs args);
        Task<ExcelDataResult> GetDataAsync(ExcelDataRequestArgs requestArgs);
        Task<MaterialsWithMarkerResult> GetMaterialWithTestsAsync(MaterialsWithMarkerRequestArgs args);
        Task<Test> AssignTestAsync(AssignDeterminationForRDTRequestArgs args);
        Task<RequestSampleTestResult> RequestSampleTestAsync(TestRequestArgs args);
        Task<List<MaterialState>> GetmaterialStatusAsync();
        Task<PlatePlanResult> GetRDTtestsOverviewAsync(PlatePlanRequestArgs args);
        Task<RequestSampleTestCallbackResult> RequestSampleTestCallbackAsync(RequestSampleTestCallBackRequestArgs args);
        Task<PrintLabelResult> PrintLabelAsync(PrintLabelForRDTRequestArgs reqArgs);
    }
}
