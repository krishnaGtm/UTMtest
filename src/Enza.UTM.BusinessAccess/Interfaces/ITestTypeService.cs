using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.Entities;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface ITestTypeService 
    {
        Task<IEnumerable<TestType>> GetLookupAsync();
    }
}
