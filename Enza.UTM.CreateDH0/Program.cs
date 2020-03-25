using Autofac;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Common;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Entities.Results;
using log4net;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace Enza.UTM.CreateDH
{
    class Program
    {
        private static readonly ILog _logger =
            LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        private static IContainer Container { get; set; }
        static int Main(string[] args)
        {
            try
            {
                log4net.Config.XmlConfigurator.Configure();

                var builder = new ContainerBuilder();
                AutofacConfig.Register(builder);
                Container = builder.Build();

                using (var scope = Container.BeginLifetimeScope())
                {
                    var success = AsyncHelper.RunSync(async () =>
                    {
                        var service = scope.Resolve<IS2SService>();
                        var emalConfigService = scope.Resolve<IEmailConfigService>();
                        var emailService = scope.Resolve<IEmailService>();
                       
                        var response = new List<ExecutableError>();
                        //call service 
                        response = await service.CreateDHAsync();
                        //Send DH1 information of all crops to Cordys
                        var response1 = await service.StoreGIDinCordysAsync();
                        
                        //concat eror message and exception to send email based on error type we get.

                        response.Concat(response1);

                        var emailTriggerTime = TimeSpan.Parse(ConfigurationManager.AppSettings["ErrorEmailTriggerTime"]);
                        var scheduleInterval = ConfigurationManager.AppSettings["ScheduleInterval"].ToInt32();
                        var today = DateTime.Now;
                        var from = today.Date.Add(emailTriggerTime);
                        var to = from.AddMinutes(scheduleInterval + 1);//add additional 1 minutes so that event should not be missed
                        if (today >= from && today <= to)
                        {
                            var dataErrors = response
                            .Where(x => !x.Success && x.ErrorType.EqualsIgnoreCase("data"))
                            .GroupBy(x => x.CropCode);
                            foreach (var dataError in dataErrors)
                            {
                                var errors = dataError.ToList();
                                await SendDataErrorMailAsync(emalConfigService, emailService, errors);
                            }
                        }

                        var exceptionError = response.Where(x => !x.Success && x.ErrorType.EqualsIgnoreCase("exception"));
                        if (exceptionError.Any())
                        {
                            //send error mail with log file attached.
                            var root = Path.Combine(Environment.CurrentDirectory, "Logs");
                            var logFile = _logger.GetLogCurrentFile(root);
                            await SendErrorEmailAsync(emalConfigService, emailService, logFile);
                        }
                        return !response.Any();
                    });
                    return success ? 0 : 1;
                }
            }
            catch (Exception ex2)
            {
                ErrorLog(ex2);
                return 1;
            }
        }

        private static void ErrorLog(Exception ex)
        {
            _logger.Error(ex);
            Console.WriteLine(ex.Message);
        }
        private static async Task SendErrorEmailAsync(IEmailConfigService emailConfigService, IEmailService emailService, Stream logFile)
        {
            try
            {
                var config = await emailConfigService.GetEmailConfigAsync(EmailConfigGroups.EXE_ERROR, "*");
                var recipients = config?.Recipients;
                if (string.IsNullOrWhiteSpace(recipients))
                {
                    //get default email
                    config = await emailConfigService.GetEmailConfigAsync(EmailConfigGroups.DEFAULT_EMAIL_GROUP, "*");
                    recipients = config?.Recipients;
                }

                if (string.IsNullOrWhiteSpace(recipients))
                    return;

                var tos = recipients.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries)
                    .Where(o => !string.IsNullOrWhiteSpace(o))
                    .Select(o => o.Trim());
                if (tos.Any())
                {
                    await emailService.SendEmailAsync(tos,
                        "S2S_CreateDH0-DH1 execution error".AddEnv(),
                        "Please find the error log file attached herewith.",
                        attachments =>
                        {
                            attachments.Add(new System.Net.Mail.Attachment(logFile, "ErrorsLog.txt"));
                        });
                }
            }
            catch (Exception ex)
            {
                ErrorLog(ex);
            }
        }

        private static async Task SendDataErrorMailAsync(IEmailConfigService emalConfigService, IEmailService emailService, List<ExecutableError> dataError)
        {
            try
            {
                var cropCode = dataError.FirstOrDefault().CropCode;
                var config = await emalConfigService.GetEmailConfigAsync(EmailConfigGroups.CREATE_DH0_DH1_DATA_ERROR, cropCode);
                var recipients = config?.Recipients;
                if (string.IsNullOrWhiteSpace(recipients))
                {
                    config = await emalConfigService.GetEmailConfigAsync(EmailConfigGroups.CREATE_DH0_DH1_DATA_ERROR, "*");
                    recipients = config?.Recipients;
                }
                if (string.IsNullOrWhiteSpace(recipients))
                {
                    config = await emalConfigService.GetEmailConfigAsync(EmailConfigGroups.EXE_ERROR, "*");
                    recipients = config?.Recipients;
                }
                if (string.IsNullOrWhiteSpace(recipients))
                {
                    config = await emalConfigService.GetEmailConfigAsync(EmailConfigGroups.DEFAULT_EMAIL_GROUP, "*");
                    recipients = config?.Recipients;
                }
                if (string.IsNullOrWhiteSpace(recipients))
                    return;

                var tos = recipients.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries)
                    .Where(o => !string.IsNullOrWhiteSpace(o))
                    .Select(o => o.Trim());
                if (tos.Any())
                {
                    var message = string.Join("\n", dataError.Select(x => x.ErrorMessage));
                    await emailService.SendEmailAsync(tos,
                        $"S2S_CreateDH0-DH1 execution error for Crop {cropCode}".AddEnv(),
                        message);
                }
            }
            catch (Exception ex)
            {
                ErrorLog(ex);
            }
        }
    }
}
