using Enza.UTM.DataAccess.Interfaces;
using Enza.UTM.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Enza.UTM.DataAccess.Data.Interfaces
{
    public interface IEmailConfigRepository : IRepository<EmailConfig>
    {
        Task<EmailConfig> GetEmailConfigByGroupAsync(string groupName);
        Task<EmailConfig> GetEmailConfigAsync(string groupName, string cropCode);
    }
}
