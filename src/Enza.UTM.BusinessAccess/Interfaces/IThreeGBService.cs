using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using Enza.UTM.Services.Proxies;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface IThreeGBService
    {
        Task<IEnumerable<ThreeGBSlotData>> GetAvailableProjectsAsync(AvailableThreeGBProjectsRequestArgs requestArgs);
        Task<ExcelDataResult> ImportDataAsync(HttpRequestMessage request, ThreeGBImportRequestArgs requestArgs);
        Task Upload3GBMaterialsAsync(int testID);
        Task<PhenoneImportDataResult> GetDataFromPhenomeAsync(HttpRequestMessage request, ThreeGBImportRequestArgs args);
    }
}
