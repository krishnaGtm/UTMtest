using Autofac;
using Enza.UTM.BusinessAccess.Interfaces;
using Enza.UTM.Common;
using Enza.UTM.Common.Extensions;
using log4net;
using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace Enza.UTM.SendResult
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
                        var service = scope.Resolve<ITestService>();
                        var emalConfigService = scope.Resolve<IEmailConfigService>();
                        var emailService = scope.Resolve<IEmailService>();
                        //exception has already been handled inside this method.
                        var ok = await service.ValidateAndSendTraitDeterminationResultAsync("Phenome")
                        .ExecuteSafe(err =>
                        {
                            ErrorLog(err);
                        });
                        if (!ok)
                        {
                            //send email to specified recipients
                            var root = Path.Combine(Environment.CurrentDirectory, "Logs");
                            var logFile = _logger.GetLogCurrentFile(root);
                            await SendErrorEmailAsync(emalConfigService, emailService, logFile);
                        }
                        return ok;
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
                        "Enza.UTM.SendResult.exe execution error".AddEnv(),
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
    }
}
