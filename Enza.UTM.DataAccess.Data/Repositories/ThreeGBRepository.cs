using Enza.UTM.Common.Extensions;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using Enza.UTM.Services.Proxies;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class ThreeGBRepository : Repository<object>, IThreeGBRepository
    {
        private readonly IUserContext _userContext;

        public ThreeGBRepository(IDatabase dbContext, IUserContext userContext) : base(dbContext)
        {
            _userContext = userContext;
        }

        public async Task ImportDataAsync(ThreeGBImportRequestArgs requestArgs, DataTable dtColumnsTVP, DataTable dtRowTVP, DataTable dtCellTVP)
        {
            var p1 = DbContext.CreateOutputParameter("@TestID", DbType.Int32);
            DbContext.CommandTimeout = 5 * 60; //5 minutes
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_IMPORT_FROM_PHENOME_FOR_3GB,
                CommandType.StoredProcedure, args1 =>
                {
                    args1.Add("@CropCode", requestArgs.CropCode);
                    args1.Add("@BrStationCode", requestArgs.BrStationCode);
                    args1.Add("@SyncCode", requestArgs.SyncCode);
                    args1.Add("@CountryCode", requestArgs.CountryCode);
                    args1.Add("@TestTypeID", requestArgs.TestTypeID);
                    args1.Add("@TestName", requestArgs.TestName);                    
                    args1.Add("@Source", requestArgs.Source);
                    args1.Add("@ObjectID", requestArgs.ObjectID);
                    args1.Add("@ThreeGBTaskID", requestArgs.ThreeGBTaskID);
                    args1.Add("@UserID", _userContext.GetContext().FullName);
                    args1.Add("@TVPColumns", dtColumnsTVP);
                    args1.Add("@TVPRow", dtRowTVP);
                    args1.Add("@TVPCell", dtCellTVP);
                    args1.Add("@TestID", p1);
                    args1.Add("@FileID", requestArgs.FileID);
                });
            requestArgs.TestID = p1.Value.ToInt32();
        }

        public Task<IEnumerable<ThreeGBMaterialResult>> Get3GBMaterialsAsync(int testID)
        {
            return DbContext.ExecuteReaderAsync(DataConstants.PR_GET_3GB_MATERIALS_FOR_UPLOAD,
                CommandType.StoredProcedure, 
                args => args.Add("@TestID", testID), 
                reader => new ThreeGBMaterialResult
                {
                    BreEZysAdministrationCode = reader.Get<string>(0),
                    ThreeGBTaskID = reader.Get<int>(1),
                    PlantNumber = reader.Get<string>(2),
                    BreedingProject = reader.Get<string>(3),
                    PlantID = reader.Get<string>(4),
                    Generation = reader.Get<string>(5),
                    TwoGBPlatePlanID = reader.Get<string>(6),
                    TwoGBPlateNumber = reader.Get<string>(7),
                    TwoGBRow = reader.Get<string>(8),
                    TwoGBColumn = reader.Get<string>(9),
                    TwoGBWeek = reader.Get<int?>(10),
                    MarkerName = reader.Get<string>(11),
                    Result = reader.Get<string>(12)
                });
        }

        public Task Update3GBMaterialsAsync(int testID, IEnumerable<ThreeGBPlantData> materials)
        {
            var p1 = new DataTable("TVP_3GBMaterials");
            p1.Columns.Add("MaterialKey", typeof(string));
            p1.Columns.Add("ThreeGBPlantID", typeof(int));
            foreach (var material in materials)
            {
                var dr = p1.NewRow();
                dr["MaterialKey"] = material.PlantID;
                dr["ThreeGBPlantID"] = material.ThreeGBPlantID;
                p1.Rows.Add(dr);
            }
            return DbContext.ExecuteNonQueryAsync(DataConstants.PR_UPDATE_3GB_MATERIALS,
                CommandType.StoredProcedure, args =>
                {
                    args.Add("@TestID", testID);
                    args.Add("@TVP", p1);
                });
        }
    }
}
