using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface IDataValidationRepository : IRepository<object>
    {
        Task<IEnumerable<MigrationDataResult>> ValidateTraitDeterminationResultAsync(int? testID, bool sendResult, string source);

    }
}
