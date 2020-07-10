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
        Task<MaterialsWithMarkerResult> GetMaterialWithtTestsAsync(MaterialsWithMarkerRequestArgs args);
    }
}
