using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using System.Collections.Generic;
using System.Data;
using Enza.UTM.Entities.Results;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities;
using System.Linq;
using System;

namespace Enza.UTM.BusinessAccess.Services
{
    public class TraitDeterminationService : ITraitDeterminationService
    {
        readonly ITraitDeterminationRepository repository;
        public TraitDeterminationService(ITraitDeterminationRepository repository)
        {
            this.repository = repository;
        }

        public async Task<IEnumerable<DeterminationResult>> GetDeterminationsAsync(string determinationName, string cropCode)
        {
            return await repository.GetDeterminationsAsync(determinationName, cropCode);
        }

        public async Task<IEnumerable<TraitResult>> GetTraitsAndDeterminationAsync(string traitName, string cropCode, string source)
        {
            return await repository.GetTraitsAndDeterminationAsync(traitName, cropCode, source);
        }
        public async Task<IEnumerable<RelationTraitDetermination>> GetRelationTraitDeterminationAsync(RelationTraitDeterminationRequestArgs args)
        {
            return await repository.GetRelationTraitDeterminationAsync(args);
        }

        public Task<DataTable> GetTraitDeterminationResultAsync(TraitDeterminationResultRequestArgs requestArgs)
        {
            return repository.GetTraitDeterminationResultAsync(requestArgs);
        }

        public Task<IEnumerable<RelationTraitDetermination>> SaveRelationTraitMaterialDetermination(SaveTraitDeterminationRelationRequestArgs args)
        {
            return repository.SaveRelationTraitMaterialDetermination(args);
        }

        public async Task<DataTable> SaveTraitDeterminationResultAsync(
            SaveTraitDeterminationResultRequestArgs requestArgs)
        {
            await repository.SaveTraitDeterminationResultAsync(requestArgs);
            var args = new TraitDeterminationResultRequestArgs
            {
                Crops = requestArgs.Crops,
                Filter = requestArgs.Filter,
                PageNumber = requestArgs.PageNumber,
                PageSize = requestArgs.PageSize
            };
            var dt = await GetTraitDeterminationResultAsync(args);
            //return totalrows back to controller
            requestArgs.TotalRows = args.TotalRows;
            return dt;
        }

        public async Task<IEnumerable<TraitValueLookup>> GetTraitListOfValuesAsync(int cropTraitID)
        {
            return await repository.GetTraitListOfValuesAsync(cropTraitID);
        }

        public async Task<IEnumerable<Crop>> GetCropAsync(List<string> crops)
        {
            var data = await repository.GetCropAsync();     
            return data.Where(x => crops.Contains(x.CropCode,StringComparer.OrdinalIgnoreCase));

        }
    }
}
