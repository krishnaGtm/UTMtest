using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class TestTypeRepository : Repository<TestType>, ITestTypeRepository
    {
        public TestTypeRepository(IDatabase dbContext) : base(dbContext)
        {
        }
        public async Task<IEnumerable<TestType>> GetLookupAsync()
        {
            var query = "SELECT TestTypeID, TestTypeCode, TestTypeName, DeterminationRequired FROM TestType";
            return await DbContext.ExecuteReaderAsync(query, reader => new TestType
            {
                TestTypeID = reader.Get<int>(0),
                TestTypeCode = reader.Get<string>(1),
                TestTypeName = reader.Get<string>(2),
                DeterminationRequired = reader.Get<bool>(3)
            });
        }
    }
}
