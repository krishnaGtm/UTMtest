using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;
using System.Configuration;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Services.Proxies;
using System.Net;
using System.Net.Http;
using Enza.UTM.Services.Abstract;
using Enza.UTM.Common.Exceptions;
using System.Linq;
using Enza.UTM.Common;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class RDTRepository : Repository<object>, IRDTRepository
    {
        private readonly IUserContext userContext;
        //private readonly string BASE_SVC_URL = ConfigurationManager.AppSettings["BasePhenomeServiceUrl"];
        public RDTRepository(IDatabase dbContext, IUserContext userContext) : base(dbContext)
        {
            this.userContext = userContext;
        }

        public async Task<MaterialsWithMarkerResult> GetMaterialWithtTestsAsync(MaterialsWithMarkerRequestArgs args)
        {
            var result = new MaterialsWithMarkerResult();
            DbContext.CommandTimeout = 2 * 60; //time out is set to 2 minutes
            var data = await DbContext.ExecuteDataSetAsync(DataConstants.PR_RDT_GET_MATERIAL_WITH_TESTS, CommandType.StoredProcedure, args1 =>
            {
                args1.Add("@TestID", args.TestID);
                args1.Add("@Page", args.PageNumber);
                args1.Add("@PageSize", args.PageSize);
                args1.Add("@Filter", args.ToFilterString());
            });
            if (data.Tables.Count == 2)
            {
                var table0 = data.Tables[0];
                if (table0.Columns.Contains("TotalRows"))
                {
                    if (table0.Rows.Count > 0)
                    {
                        result.Total = table0.Rows[0]["TotalRows"].ToInt32();
                    }
                    table0.Columns.Remove("TotalRows");
                }
                result.Data = new
                {
                    Columns = data.Tables[1],
                    Data = table0
                };
            }
            return result;
        }

        public async Task<Test> AssignTestAsync(AssignDeterminationForRDTRequestArgs request)
        {
            var data = await DbContext.ExecuteReaderAsync(DataConstants.PR_SAVE_TEST_MATERIAL_DETERMINATION_ForRDT, CommandType.StoredProcedure, args =>
            {
                args.Add("@TestTypeID", request.TestTypeID);
                args.Add("@TestID", request.TestID);
                args.Add("@Columns", request.ToColumnsString());
                args.Add("@Filter", request.ToFilterString());
                args.Add("@TVPTestWithExpDate", request.ToTVPTestMaterialDetermation());
                args.Add("@Determinations", request.ToTVPDeterminations());
            },
            reader => new Test
            {
                TestID = reader.Get<int>(0),
                StatusCode = reader.Get<int>(1)

            });
            return data.FirstOrDefault();
        }

        public async Task<string> RequestSampleTestAsync(TestRequestArgs args)
        {
            return await ImplementRequestSampleTest();
        }

        private async Task<string> ImplementRequestSampleTest()
        {
            await Task.Delay(1);

            var client = new LimsServiceRestClient();
            return client.RequestSampleTestAsync();
        }
    }
    
}
