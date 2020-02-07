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
    public class TraitDeterminationRepository : Repository<object>, ITraitDeterminationRepository
    {
        private readonly IUserContext userContext;
        public TraitDeterminationRepository(IDatabase dbContext, IUserContext userContext) : base(dbContext)
        {
            this.userContext = userContext;
        }

        public async Task<IEnumerable<DeterminationResult>> GetDeterminationsAsync(string determinationName, string cropCode)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_DETERMINATION_ALL, CommandType.StoredProcedure, args =>
            {
                args.Add("@DeterminationName", determinationName);
                args.Add("@CropCode", cropCode);

            }, reader => new DeterminationResult
            {
                DeterminationID = reader.Get<int>(0),
                DeterminationName = reader.Get<string>(1),
                DeterminationAlias = reader.Get<string>(2),
                
            });
        }

        public async Task<IEnumerable<TraitResult>> GetTraitsAndDeterminationAsync(string traitName, string cropCode, string source)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_TRAITS_AND_DETERMINATIONS, CommandType.StoredProcedure, args =>
            {
                args.Add("@TraitName", traitName);
                args.Add("@CropCode", cropCode);

            }, reader => new TraitResult
            {
                CropTraitID = reader.Get<int>(0),
                TraitName = reader.Get<string>(1),
                TraitDescription = reader.Get<string>(2),
                CropCode = reader.Get<string>(3),
                ListOfValues = reader.Get<bool>(4),
                RelationID = reader.Get<int>(5),
                DeterminationID = reader.Get<int>(6),
                DeterminatioName = reader.Get<string>(7),
                DeterminationAlias = reader.Get<string>(8)
            });
        }

        public async Task<IEnumerable<RelationTraitDetermination>> GetRelationTraitDeterminationAsync(RelationTraitDeterminationRequestArgs requestargs)
        {
            var items =  await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_RELATION_TRAIT_DETERMINATION, CommandType.StoredProcedure, args =>
            {
                args.Add("@PageSize", requestargs.PageSize);
                args.Add("@PageNumber", requestargs.PageNumber);
                args.Add("@Crops", requestargs.Crops);
                args.Add("@Filter", requestargs.ToFilterString());

            }, reader => new RelationTraitDetermination
            {          
                CropCode = reader.Get<string>(0),
                TraitID = reader.Get<int>(1),
                TraitLabel = reader.Get<string>(2),
                DeterminationID = reader.Get<int>(3),                
                DeterminationName = reader.Get<string>(4),
                DeterminationAlias = reader.Get<string>(5),
                RelationID = reader.Get<int>(6),
                Status = reader.Get<string>(7),
                TotalRows = reader.Get<int>(8)
            });
            if (items.Any())
            {
                requestargs.TotalRows = items.FirstOrDefault().TotalRows;
            }
            return items;
        }

        public async Task<DataTable> GetTraitDeterminationResultAsync(TraitDeterminationResultRequestArgs requestArgs)
        {
            var ds = await DbContext.ExecuteDataSetAsync(DataConstants.PR_GET_TRAIT_DETERMINATION_RESULT,
                CommandType.StoredProcedure, args =>
                {
                    args.Add("@PageSize", requestArgs.PageSize);
                    args.Add("@PageNumber", requestArgs.PageNumber);
                    args.Add("@Crops", requestArgs.Crops);
                    args.Add("@Filter", requestArgs.ToFilterString());
                });
            var dt = ds.Tables[0];
            if (dt.Rows.Count > 0)
            {
                requestArgs.TotalRows = dt.Rows[0]["TotalRows"].ToInt32();
            }
            dt.Columns.Remove("TotalRows");
            return dt;
        }

        public async Task<IEnumerable<RelationTraitDetermination>> SaveRelationTraitMaterialDetermination(SaveTraitDeterminationRelationRequestArgs requestargs)
        {
            //save data
            await DbContext.ExecuteDataSetAsync(DataConstants.PR_SAVE_RELATION_TRAIT_DETERMINATION,
                CommandType.StoredProcedure, args =>
                {
                    args.Add("@TVP_RelationTraitDetermination", requestargs.ToRelationTraitDeterminationTVP());
                });
            //get data again after successful import
            return await GetRelationTraitDeterminationAsync(new RelationTraitDeterminationRequestArgs
            {
                Filter = requestargs.Filter,
                PageNumber = requestargs.PageNumber,
                PageSize = requestargs.PageSize,
                Crops = requestargs.Crops,
                //Source = requestargs.Source,
                TotalRows = requestargs.TotalRows
            });
        }



        public Task SaveTraitDeterminationResultAsync(SaveTraitDeterminationResultRequestArgs requestArgs)
        {
            return DbContext.ExecuteNonQueryAsync(DataConstants.PR_SAVE_TRAIT_DETERMINATION_RESULT,
                CommandType.StoredProcedure, args =>
                {
                    args.Add("@CropCode", requestArgs.CropCode);
                    args.Add("@TVP", requestArgs.ToTvp());
                });
        }

        public async Task<IEnumerable<TraitValueLookup>> GetTraitListOfValuesAsync(int cropTraitID)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_CROPTRAIT_LOV, CommandType.StoredProcedure, args =>
            {
                args.Add("@CropTraitID", cropTraitID);

            }, reader => new TraitValueLookup
            {
                TraitValueCode = reader.Get<string>(0),
                TraitValueName = reader.Get<string>(1)
            });
            
        }

        public async Task<IEnumerable<Crop>> GetCropAsync()
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_CROP, CommandType.StoredProcedure, reader => new Crop
            {
                CropCode = reader.Get<string>(0),
                CropName = reader.Get<string>(1)
            });

        }
    }
}
