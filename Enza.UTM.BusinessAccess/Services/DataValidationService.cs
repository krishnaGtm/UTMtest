using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.DataAccess.Data.Interfaces;
using Enza.UTM.Entities.Results;
using System.Data;
using System.Linq;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Entities.Args;
using Enza.UTM.Common;
using Enza.UTM.Services.Proxies;
using Enza.UTM.Services.EmailTemplates;

namespace Enza.UTM.BusinessAccess.Services
{
    public class DataValidationService : IDataValidationService
    {
        private readonly IDataValidationRepository repo;
        private readonly IEmailConfigService _emailConfigService;
        private readonly IEmailService _emailService;
        private readonly ITestRepository _testRepository;

        public DataValidationService(IDataValidationRepository repo, IEmailConfigService emailConfigService, IEmailService emailService,ITestRepository testRepository)
        {
            this.repo = repo;
            _emailConfigService = emailConfigService;
            _emailService = emailService;
            _testRepository = testRepository;

        }

        public async Task<IEnumerable<MigrationDataResult>> ValidateTraitDeterminationResultAsync(int? testID, bool sendResult, string source)
        {
            return await repo.ValidateTraitDeterminationResultAsync(testID, sendResult, source);
        }

        public async Task SendEmailAsync(string cropCode, string body)
        {
            var config = await _emailConfigService.GetEmailConfigAsync(EmailConfigGroups.SEND_RESULT_MAPPING_MISSING, cropCode);
            var recipients = config?.Recipients;
            if (string.IsNullOrWhiteSpace(recipients))
            {
                //get * email of the same group
                config = await _emailConfigService.GetEmailConfigAsync(EmailConfigGroups.SEND_RESULT_MAPPING_MISSING, "*");
                recipients = config?.Recipients;
                if (string.IsNullOrWhiteSpace(recipients))
                {
                    //get default email
                    config = await _emailConfigService.GetEmailConfigAsync(EmailConfigGroups.DEFAULT_EMAIL_GROUP, "*");
                    recipients = config?.Recipients;
                }
            }

            if (string.IsNullOrWhiteSpace(recipients))
                return;

            var tos = recipients.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries)
                .Where(o => !string.IsNullOrWhiteSpace(o))
                .Select(o => o.Trim());
            if (tos.Any())
            {
                await _emailService.SendEmailAsync(tos, "Missing Mapping".AddEnv(), body);
            }
        }
    }
}
