using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;

namespace Enza.UTM.BusinessAccess.Interfaces
{
    public interface IEmailConfigService
    {
        Task<IEnumerable<EmailConfig>> GetAllAsync(EmailConfigRequestArgs args);
        Task AddAsync(EmailConfig entity);
        Task DeleteAsync(int configID);

        Task<EmailConfig> GetEmailConfigByGroupAsync(string groupName);
        Task<EmailConfig> GetEmailConfigAsync(string groupName, string cropCode);
    }

    public class EmailConfigGroups
    {
        public const string SEND_RESULT_MAPPING_MISSING = "SEND_RESULT_MAPPING_MISSING";
        public const string EXE_ERROR = "EXE_ERROR";
        public const string DEFAULT_EMAIL_GROUP = "DEFAULT_EMAIL_GROUP";
        public const string MOLECULAR_LAB_GROUP = "MOLECULAR_LAB_GROUP";
    }
}
