using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using Enza.UTM.Services.Proxies;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface IThreeGBRepository : IRepository<object>
    {
        Task ImportDataAsync(ThreeGBImportRequestArgs requestArgs, DataTable dtColumnsTVP, DataTable dtRowTVP, DataTable dtCellTVP);
        Task<IEnumerable<ThreeGBMaterialResult>> Get3GBMaterialsAsync(int testID);
        Task Update3GBMaterialsAsync(int testID, IEnumerable<ThreeGBPlantData> materials);
    }
}
