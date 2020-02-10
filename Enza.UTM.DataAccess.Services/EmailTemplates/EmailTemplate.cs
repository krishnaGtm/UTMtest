using Enza.UTM.Common.Extensions;

namespace Enza.UTM.Services.EmailTemplates
{
    public class EmailTemplate
    {
        public static string GetMissingConversionMail()
        {
            return typeof(EmailTemplate).Assembly.GetString("Enza.UTM.Services.EmailTemplates.MissingConversionMail.st");
        }
    }
}
