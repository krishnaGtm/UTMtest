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
    public interface IRDTRepository : IRepository<object>
    {
        Task<PhenoneImportDataResult> ImportDataFromPhenomeAsync(HttpRequestMessage request, PhenomeImportRequestArgs args);
        Task<MaterialsWithMarkerResult> GetMaterialWithtTestsAsync(MaterialsWithMarkerRequestArgs args);
        Task<Test> AssignTestAsync(AssignDeterminationForRDTRequestArgs args);
        Task<string> RequestSampleTestAsync(TestRequestArgs args);
    }
}
