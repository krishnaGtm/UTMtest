using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.Common.Extensions;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using Enza.UTM.Entities;
using System.Linq;
using System;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class MasterRepository : Repository<object>, IMasterRepository
    {
        private readonly IUserContext userContext;
        public MasterRepository(IDatabase dbContext, IUserContext userContext) : base(dbContext)
        {
            this.userContext = userContext;
        }


        public async Task<IEnumerable<Crop>> GetCropAsync()
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_CROP, CommandType.StoredProcedure, reader => new Crop
            {
                CropCode = reader.Get<string>(0),
                CropName = reader.Get<string>(1)
            });
        }

        public async Task<IEnumerable<TraitValueLookup>> GetTraitValuesAsync(string cropCode, int traitID)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_TRAIT_VALUES, CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@CropCode", cropCode);
                    args.Add("@TraitID", traitID);
                }, reader => new TraitValueLookup
                {
                    TraitValueCode = reader.Get<string>(0),
                    TraitValueName = reader.Get<string>(1)
                });
        }

        public async Task<IEnumerable<BreedingStation>> GetBreedingStationAsync()
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_BREEDINGSTATION, CommandType.StoredProcedure, reader => new BreedingStation
            {
                BreedingStationCode = reader.Get<string>(0),
                BreedingStationName = reader.Get<string>(1)
            });
        }

        public Task<IEnumerable<TestProtocol>> GetTestProtocolsAsync()
        {
            var query = @"SELECT 
	                        TestProtocolID, 
                            TestTypeID,
	                        TestProtocolName
                        FROM TestProtocol 
                        ORDER BY TestTypeID";
            return DbContext.ExecuteReaderAsync(query, args => { }, reader => new TestProtocol
            {
                TestProtocolID = reader.Get<int>(0),
                TestTypeID = reader.Get<int>(1),
                TestProtocolName = reader.Get<string>(2)
            });
        }

        public async Task<DataTable> GetCNTProcessesAsync()
        {
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_CNT_GET_PROCESSES, args => { });
            return ds.Tables[0];
        }

        public Task SaveCNTProcessAsync(IEnumerable<CNTProcessRequestArgs> items)
        {
            return DbContext.ExecuteNonQueryAsync(DataConstants.PR_CNT_SAVE_PROCESS,
                CommandType.StoredProcedure,
                args => args.Add("@DataAsJson", items.ToJson()));
        }

        public async Task<DataTable> GetCNTLabLocationsAsync()
        {
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_CNT_GET_LAB_LOCATIONS, args => { });
            return ds.Tables[0];
        }

        public Task SaveCNTLabLocationsAsync(IEnumerable<CNTLabLocationRequestArgs> items)
        {
            return DbContext.ExecuteNonQueryAsync(DataConstants.PR_CNT_SAVE_LABLOCATIONS,
                CommandType.StoredProcedure,
                args => args.Add("@DataAsJson", items.ToJson()));
        }

        public async Task<DataTable> GetCNTStartMaterialsAsync()
        {
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_CNT_GET_STARTMATERIALS, args => { });
            return ds.Tables[0];
        }

        public Task SaveCNTStartMaterialsAsync(IEnumerable<CNTStartMaterialRequestArgs> items)
        {
            return DbContext.ExecuteNonQueryAsync(DataConstants.PR_CNT_SAVE_STARTMATERIALS,
                CommandType.StoredProcedure,
                args => args.Add("@DataAsJson", items.ToJson()));
        }

        public async Task<DataTable> GetCNTTypesAsync()
        {
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_CNT_GET_TYPES, args => { });
            return ds.Tables[0];
        }

        public Task SaveCNTTypesAsync(IEnumerable<CNTTypeRequestArgs> items)
        {
            return DbContext.ExecuteNonQueryAsync(DataConstants.PR_CNT_SAVE_TYPES,
                CommandType.StoredProcedure,
                args => args.Add("@DataAsJson", items.ToJson()));
        }

        public Task<IEnumerable<SiteLocation>> GetSitesAsync()
        {
            var query = @"SELECT 
	                        SiteID, 
                            SiteName
                        FROM SiteLocation 
                        WHERE StatusCode = 100";
            return DbContext.ExecuteReaderAsync(query, args => { }, reader => new SiteLocation
            {
                SiteID = reader.Get<int>(0),
                SiteName = reader.Get<string>(1)
            });
        }
    }
}
