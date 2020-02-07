using System.Data;
using System.Threading.Tasks;
using Enza.UTM.Common.Extensions;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class MaterialTypeTestProtocolRepository : Repository<TestProtocol>, IMaterialTypeTestProtocolRepository
    {
        public MaterialTypeTestProtocolRepository(IDatabase dbContext) : base(dbContext)
        {
        }
        public async Task<DataTable> GetDataAsync(GetMaterialTypeTestProtocolsRequestArgs requestArgs)
        {
            var data = await DbContext.ExecuteDataSetAsync(DataConstants.PR_GET_MATERIAL_TYPE_TEST_PROTOCOLS, 
                CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@Page", requestArgs.PageNumber);
                    args.Add("@PageSize", requestArgs.PageSize);
                    args.Add("@Filters", requestArgs.ToFilterString());
                });
            var table0 = data.Tables[0];
            if (table0.Columns.Contains("TotalRows"))
            {
                if (table0.Rows.Count > 0)
                {
                    requestArgs.TotalRows = table0.Rows[0]["TotalRows"].ToInt32();
                }
                table0.Columns.Remove("TotalRows");
            }
            return table0;
        }

        public async Task SaveDataAsync(SaveMaterialTypeTestProtocolsRequestArgs requestArgs)
        {
            await DbContext.ExecuteNonQueryAsync(DataConstants.PR_SAVE_MATERIAL_TYPE_TESTP_ROTOCOLS, CommandType.StoredProcedure, args =>
            {
                args.Add("@OldMaterialTypeID", requestArgs.OldMaterialTypeID);
                args.Add("@OldTestProtocolID", requestArgs.OldTestProtocolID);
                args.Add("@OldCropCode", requestArgs.OldCropCode);
                args.Add("@MaterialTypeID", requestArgs.MaterialTypeID);
                args.Add("@TestProtocolID", requestArgs.TestProtocolID);
                args.Add("@CropCode", requestArgs.CropCode);
            });
        }
    }
}
