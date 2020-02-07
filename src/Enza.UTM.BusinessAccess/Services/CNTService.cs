using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities.Args;
using System.Net.Http;
using Enza.UTM.Entities.Results;

namespace Enza.UTM.BusinessAccess.Services
{
    public class CNTService : ICNTService
    {
        private readonly ICNTRepository _cNTRepository;
        public CNTService(ICNTRepository cNTRepository)
        {
            _cNTRepository = cNTRepository;
        }

        public Task<ExcelDataResult> GetDataAsync(ExcelDataRequestArgs requestArgs)
        {
            return _cNTRepository.GetDataAsync(requestArgs);
        }

        public Task<PhenoneImportDataResult> ImportDataAsync(HttpRequestMessage request, CNTRequestArgs args)
        {
            return _cNTRepository.ImportDataFromPhenomeAsync(request, args);
        }


        public Task AssignMarkersAsync(CNTAssignMarkersRequestArgs requestArgs)
        {
            return _cNTRepository.AssignMarkersAsync(requestArgs);
        }


        public Task ManageInfoAsync(CNTManageInfoRequestArgs requestArgs)
        {
            return _cNTRepository.ManageInfoAsync(requestArgs);
        }

        public Task ManageMarkersAsync(CNTManageMarkersRequestArgs requestArgs)
        {
            return _cNTRepository.ManageMarkersAsync(requestArgs);
        }

        public Task<MaterialsWithMarkerResult> GetDataWithMarkersAsync(MaterialsWithMarkerRequestArgs args)
        {
            return _cNTRepository.GetDataWithMarkersAsync(args);
        }

        public Task<byte[]> GetDataForExcelAsync(int testID)
        {
            return _cNTRepository.GetDataForExcelAsync(testID);
        }
    }
}
