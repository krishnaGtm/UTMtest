using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities;

namespace Enza.UTM.BusinessAccess.Services
{
    public class FileService : IFileService
    {
        readonly IFileRepository repository;
        public FileService(IFileRepository repository)
        {
            this.repository = repository;
        }
        
        public async Task<IEnumerable<ExcelFile>> GetFilesAsync(string cropCode, string breedingStationCode)
        {
            return await repository.GetFilesAsync(cropCode, breedingStationCode);
        }

        public async Task<ExcelFile> GetFileAsync(int testID)
        {
            return await repository.GetFileAsync(testID);
        }
        //public async Task<bool> FileExistsAsync(string fileName)
        //{
        //    return await repository.FileExistsAsync(fileName);
        //}

    }
}
