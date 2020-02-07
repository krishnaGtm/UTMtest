using System.Data;
using System.Net.Http;
using System.Threading.Tasks;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface IPhenomeServices
    {
        Task<ExcelDataResult> GetPhenomeDataAsync(HttpRequestMessage request, PhenomeImportRequestArgs args);
        Task<PhenoneImportDataResult> GetDataFromPhenomeAsync(HttpRequestMessage request, PhenomeImportRequestArgs args);
        Task<PhenoneImportDataResult> GetListDataFromPhenomeAsync(HttpRequestMessage request, PhenomeImportRequestArgs args);
    }
}
