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

        //public async Task<IEnumerable<MigrationDataResult>> ValidateTraitDeterminationResultAndSendEmailAsync(int? testID, bool sendResult, string source)
        //{
        //    var tests = new List<int>();
        //    var data = (await repo.ValidateTraitDeterminationResultAsync(testID, sendResult, source)).ToList();
        //    var data1 = data.Where(x => !x.IsValid && x.StatusCode != 625);
        //    //mail is only sent when any test conversion is failed and 
        //    if (data1.Any())
        //    {
        //        tests.AddRange(data1.GroupBy(x => x.TestID).Select(g => g.Key));
        //        //send mail per test because individual who created test should also need to be notified
        //        var test = data1.FirstOrDefault();
        //        var testname = test.TestName;
        //        var distinctDeterminations = data1.GroupBy(g => new
        //        {
        //            g.DeterminationName,
        //            g.ColumnLabel,
        //            g.DeterminationValue
        //        }).Select(x => string.Concat($"Trait: { x.Key.ColumnLabel}, ", x.Key.DeterminationName, " : ", x.Key.DeterminationValue));

        //        var distinctDeterminations1 = data1.GroupBy(g => new
        //        {
        //            g.DeterminationName,
        //            g.ColumnLabel,
        //            g.DeterminationValue
        //        }).Select(x=>new
        //        {
        //            x.Key.DeterminationName,
        //            x.Key.ColumnLabel,
        //            x.Key.DeterminationValue,
        //        }).ToList();                
        //        var tpl = EmailTemplate.GetMissingConversionMail();
        //        var model = new
        //        {
        //            test.CropCode,
        //            TestName = testname,
        //            Determinations = distinctDeterminations1,
        //        };
        //        var body = Template.Render(tpl, model);
        //        //send email to mapped recipients fo this crop
        //        await SendEmailAsync(test.CropCode, body);
        //    }
        //    //only update test whose status is 600 only
        //    foreach(var _test in tests)
        //    {
        //        var result = await _testRepository.UpdateTestStatusAsync(new UpdateTestStatusRequestArgs
        //        {
        //            TestId = _test,
        //            StatusCode = 625
        //        });
        //    }
        //    return data;
        //}

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
