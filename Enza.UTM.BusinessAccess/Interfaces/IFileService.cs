using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.Entities;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface IFileService
    {
        Task<IEnumerable<ExcelFile>> GetFilesAsync(string cropCode, string breedingStationCode);
        Task<ExcelFile> GetFileAsync(int testID);
        //Task<bool> FileExistsAsync(string fileName);
    }
}
