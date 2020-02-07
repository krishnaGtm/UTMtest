using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Services
{
    public class WellService : IWellService
    {
        readonly IWellRepository wellRepository;

        public WellService(IWellRepository wellRepository)
        {
            this.wellRepository = wellRepository;
        }

        public async Task<bool> AssignFixedPositionAsync(AssignFixedPositionRequestArgs request)
        {
            return await wellRepository.AssignFixedPosition(request);
        }
        
        public async Task<IEnumerable<WellPosition>> GetLookupAsync(WellLookupRequestArgs request)
        {
            return await wellRepository.GetLookupAsync(request);
        }

        public async Task<IEnumerable<WellTypeResult>> GetWellTypeAsync()
        {
            return await wellRepository.GetWellTypeAsync();
        }

        public async Task<bool> ReOrderMaterialPositionAsync(ReOrderMaterialPositionRequestArgs request)
        {
            return await wellRepository.ReOrderMaterialPositionAsync(request);
        }

        public async Task<bool> UndoFixedPositionAsync(AssignFixedPositionRequestArgs args)
        {
            return await wellRepository.UndoFixedPositionAsync(args);
        }
    }
}
