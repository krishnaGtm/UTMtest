using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Abstract;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;

namespace Enza.UTM.DataAccess.Data.Repositories
{
    public class EmailConfigRepository : Repository<EmailConfig>, IEmailConfigRepository
    {
        public EmailConfigRepository(IDatabase dbContext) : base(dbContext)
        {
        }

        public override Task AddAsync(EmailConfig entity)
        {
            return DbContext.ExecuteNonQueryAsync(DataConstants.PR_SAVE_EMAIL_CONFIG, CommandType.StoredProcedure, args =>
            {
                args.Add("@ConfigID", entity.ConfigID);
                args.Add("@ConfigGroup", entity.ConfigGroup);
                args.Add("@CropCode", entity.CropCode);
                args.Add("@BrStationCode", entity.BrStationCode);
                args.Add("@Recipients", entity.Recipients);
            });
        }

        public override async Task<IEnumerable<EmailConfig>> GetAllAsync<TArgs>(TArgs args)
        {
            var entity = args as EmailConfigRequestArgs;
            var items = await DbContext.ExecuteReaderAsync(DataConstants.PR_GET_EMAIL_CONFIGS, CommandType.StoredProcedure, p =>
            {
                p.Add("@ConfigGroup", entity.ConfigGroup);
                p.Add("@CropCode", entity.CropCode);
                p.Add("@BrStationCode", entity.BrStationCode);
                p.Add("@Page", entity.PageNumber);
                p.Add("@PageSize", entity.PageSize);
            }, reader =>
            {
                var item = new EmailConfig
                {
                    ConfigID = reader.Get<int>(0),
                    ConfigGroup = reader.Get<string>(1),
                    CropCode = reader.Get<string>(2),                    
                    Recipients = reader.Get<string>(3),
                    BrStationCode = reader.Get<string>(4)
                };
                return new
                {
                    Item = item,
                    TotalRows = reader.Get<int>(5)
                };
            });
            if (items.Any())
            {
                entity.TotalRows = items.FirstOrDefault().TotalRows;
            }
            return items.Select(o => o.Item);
        }

        public override Task DeleteAsync(EmailConfig entity)
        {
            return DbContext.ExecuteNonQueryAsync(DataConstants.PR_DELETE_EMAIL_CONFIG, CommandType.StoredProcedure, args =>
            {
                args.Add("@ConfigID", entity.ConfigID);
            });
        }

        public Task<EmailConfig> GetEmailConfigByGroupAsync(string groupName)
        {
            return GetEmailConfigAsync(groupName, null);
        }

        public async Task<EmailConfig> GetEmailConfigAsync(string groupName, string cropCode, string brStationCode = null)
        {
            var configs = await GetAllAsync(new EmailConfigRequestArgs
            {
                ConfigGroup = groupName,
                CropCode = cropCode,
                BrStationCode = brStationCode,
                PageNumber = 1,
                PageSize = int.MaxValue
            });
            return configs.FirstOrDefault();
        }
    }
}
