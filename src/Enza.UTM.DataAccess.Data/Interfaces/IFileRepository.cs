using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface IFileRepository : IRepository<ExcelFile>
    {
        Task<IEnumerable<ExcelFile>> GetFilesAsync(string cropCode, string breedingStationCode);
        Task<ExcelFile> GetFileAsync(int testID);
        //Task<bool> FileExistsAsync(string fileName);
    }
}
