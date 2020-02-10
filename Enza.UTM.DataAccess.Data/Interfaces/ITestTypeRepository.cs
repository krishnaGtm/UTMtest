using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface ITestTypeRepository : IRepository<TestType>
    {
        Task<IEnumerable<TestType>> GetLookupAsync();
    }
}
