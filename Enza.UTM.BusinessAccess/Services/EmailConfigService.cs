using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities;
using Enza.UTM.Entities.Args;

namespace Enza.UTM.BusinessAccess.Services
{
    public class EmailConfigService : IEmailConfigService
    {
        private readonly IEmailConfigRepository _emailConfigRepository;
        private readonly IEmailService _emailService;
        public EmailConfigService(IEmailConfigRepository emailConfigRepository, IEmailService emailService)
        {
            _emailConfigRepository = emailConfigRepository;
            _emailService = emailService;
        }

        public Task AddAsync(EmailConfig entity)
        {
            return _emailConfigRepository.AddAsync(entity);
        }

        public Task DeleteAsync(int configID)
        {
            return _emailConfigRepository.DeleteAsync(new EmailConfig
            {
                ConfigID = configID
            });
        }

        public Task<IEnumerable<EmailConfig>> GetAllAsync(EmailConfigRequestArgs args)
        {
            return _emailConfigRepository.GetAllAsync(args);
        }

        public Task<EmailConfig> GetEmailConfigAsync(string groupName, string cropCode, string brStationCode = null)
        {
            return _emailConfigRepository.GetEmailConfigAsync(groupName, cropCode, brStationCode);
        }

        public Task<EmailConfig> GetEmailConfigByGroupAsync(string groupName)
        {
            return _emailConfigRepository.GetEmailConfigByGroupAsync(groupName);
        }

    }
}
