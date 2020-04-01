using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Enza.UTM.Common.Extensions;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using System.Data;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class FileRepository : Repository<ExcelFile>, IFileRepository
    {
        private readonly IUserContext userContext;
        public FileRepository(IDatabase dbContext, IUserContext userContext) : base(dbContext)
        {
            this.userContext = userContext;
        }

        public async Task<IEnumerable<ExcelFile>> GetFilesAsync(string cropCode, string breedingStationCode)
        {
            return await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_FILES, CommandType.StoredProcedure,
                args =>
                {
                    args.Add("@CropCode", cropCode);
                    args.Add("@BreedingStationCode", breedingStationCode);
                },
                reader => new ExcelFile
                {
                    FileID = reader.Get<int>(0),
                    CropCode = reader.Get<string>(1),
                    FileTitle = reader.Get<string>(2),
                    UserID = reader.Get<string>(3),
                    ImportDateTime = reader.Get<DateTime>(4),
                    TestID = reader.Get<int>(5),
                    TestTypeID = reader.Get<int>(6),
                    Remark  = reader.Get<string>(7),
                    RemarkRequired = reader.Get<bool>(8),
                    StatusCode = reader.Get<int>(9),
                    MaterialstateID = reader.Get<int?>(10),
                    MaterialTypeID = reader.Get<int?>(11),
                    ContainerTypeID = reader.Get<int?>(12),
                    Isolated = reader.Get<bool>(13),
                    PlannedDate = reader.Get<DateTime>(14),
                    SlotID = reader.Get<int?>(15),
                    WellsPerPlate = reader.Get<int>(16),
                    BreedingStationCode = reader.Get<string>(17),
                    ExpectedDate = reader.Get<DateTime>(18),
                    PlatePlanName = reader.Get<string>(19),
                    Source = reader.Get<string>(20),
                    Cumulate = reader.Get<bool>(21),
                    ImportLevel = reader.Get<string>(22),
                    ExcludeControlPosition = reader.Get<bool>(23)
                });
        }

        public async Task<ExcelFile> GetFileAsync(int testID)
        {
            var files = await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_FILES, CommandType.StoredProcedure, args =>
                {
                    //args.Add("@UserID", userContext.GetContext().FullName);
                    args.Add("@CropCode", "");
                    args.Add("@BreedingStationCode", "");
                    args.Add("@TestID", testID);
                },
                reader => new ExcelFile
                {
                    FileID = reader.Get<int>(0),
                    CropCode = reader.Get<string>(1),
                    FileTitle = reader.Get<string>(2),
                    UserID = reader.Get<string>(3),
                    ImportDateTime = reader.Get<DateTime>(4),
                    TestID = reader.Get<int>(5),
                    TestTypeID = reader.Get<int>(6),
                    Remark = reader.Get<string>(7),
                    RemarkRequired = reader.Get<bool>(8),
                    StatusCode = reader.Get<int>(9),
                    MaterialstateID = reader.Get<int?>(10),
                    MaterialTypeID = reader.Get<int?>(11),
                    ContainerTypeID = reader.Get<int?>(12),
                    Isolated = reader.Get<bool>(13),
                    PlannedDate = reader.Get<DateTime>(14),
                    SlotID = reader.Get<int?>(15),
                    WellsPerPlate = reader.Get<int>(16),
                    BreedingStationCode = reader.Get<string>(17),
                    ExpectedDate = reader.Get<DateTime>(18),
                    Cumulate = reader.Get<bool>(21)
                });
            return files.FirstOrDefault();
        }

        //public async Task<bool> FileExistsAsync(string fileName)
        //{
        //    var query = @"SELECT COUNT(FileID) AS Total FROM [File] WHERE FileTitle = @FileTitle AND UserID = @UserID";
        //    var value = await DbContext.ExecuteScalarAsync(query,
        //        args =>
        //        {
        //            args.Add("@FileTitle", fileName);
        //            args.Add("@UserID", userContext.GetContext().FullName);
        //        });

        //    return (value.ToInt32() > 0);
        //}
    }
}
