using Enza.UTM.Common.Extensions;
using System;

namespace Enza.UTM.Services.EmailTemplates
{
    public class EmailTemplate
    {
        public static string GetMissingConversionMail()
        {
            return typeof(EmailTemplate).Assembly.GetString("Enza.UTM.Services.EmailTemplates.MissingConversionMail.st");
        }

        public static string GetTestCompleteNotificationEmailTemplate(string testType)
        {
            if (testType.EqualsIgnoreCase("rdt"))
                return typeof(EmailTemplate).Assembly.GetString("Enza.UTM.Services.EmailTemplates.RDTTestCompleteNotification.st");
            return typeof(EmailTemplate).Assembly.GetString("Enza.UTM.Services.EmailTemplates.TestCompleteNotification.st");
        }

        public static string GetColumnSetErrorEmailTemplate(string testType)
        {
            if (testType.EqualsIgnoreCase("rdt"))
                return typeof(EmailTemplate).Assembly.GetString("Enza.UTM.Services.EmailTemplates.RDTSetColumnError.st");
            return typeof(EmailTemplate).Assembly.GetString("Enza.UTM.Services.EmailTemplates.SetColumnError.st");
        }

        public static string GetPartiallyResultSentEmailTemplate()
        {
            return typeof(EmailTemplate).Assembly.GetString("Enza.UTM.Services.EmailTemplates.RDTPartiallySentResult.st");
        }
    }
}
