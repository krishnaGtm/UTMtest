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
        Task<EmailConfig> GetEmailConfigAsync(string groupName, string cropCode, string brStationCode = null);
    }

    public class EmailConfigGroups
    {
        public const string SEND_RESULT_MAPPING_MISSING = "SEND_RESULT_MAPPING_MISSING";
        public const string CREATE_DH0_DH1_DATA_ERROR = "Create_Dh0_Dh1_Data_Error";
        public const string EXE_ERROR = "EXE_ERROR";
        public const string DEFAULT_EMAIL_GROUP = "DEFAULT_EMAIL_GROUP";
        public const string MOLECULAR_LAB_GROUP = "MOLECULAR_LAB_GROUP";
        public const string TEST_COMPLETE_NOTIFICATION = "TEST_COMPLETE_NOTIFICATION";
    }
}
