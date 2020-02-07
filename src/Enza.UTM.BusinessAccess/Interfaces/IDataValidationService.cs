using Enza.UTM.Entities.Results;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface IDataValidationService
    {
        Task<IEnumerable<MigrationDataResult>> ValidateTraitDeterminationResultAsync(int? testID, bool sendResult,string source);
        Task<IEnumerable<MigrationDataResult>> ValidateTraitDeterminationResultAndSendEmailAsync(int? testID, bool sendResult, string source);
    }
}
