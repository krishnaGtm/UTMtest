using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities;

namespace Enza.UTM.BusinessAccess.Services
{
    public class TestTypeService : ITestTypeService
    {
        readonly ITestTypeRepository repository;
        public TestTypeService(ITestTypeRepository repository)
        {
            this.repository = repository;
        }
        public async Task<IEnumerable<TestType>> GetLookupAsync()
        {
            return await repository.GetLookupAsync();
        }
    }
}
