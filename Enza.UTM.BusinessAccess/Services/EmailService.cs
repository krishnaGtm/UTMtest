using System;
using System.Collections.Generic;
using System.Net.Mail;
using System.Threading.Tasks;
using Enza.UTM.BusinessAccess.Interfaces;

namespace Enza.UTM.BusinessAccess.Services
{
    public class EmailService : IEmailService
    {
        public async Task SendEmailAsync(MailAddress from, IEnumerable<string> recipients, 
            string subject, string body, Action<AttachmentCollection> attachments)
        {
            using(var client = new SmtpClient())
            {
                var msg = new MailMessage
                {
                    Subject = subject,
                    Body = body,
                    IsBodyHtml = true
                };
                if(from != null)
                {
                    msg.From = from;
                }
                msg.To.Add(string.Join(",", recipients));

                attachments?.Invoke(msg.Attachments);
                await client.SendMailAsync(msg);
            }
        }
        public Task SendEmailAsync(IEnumerable<string> recipients, string subject, string body, Action<AttachmentCollection> attachments)
        {
            return SendEmailAsync(null, recipients, subject, body, attachments);
        }

        public Task SendEmailAsync(IEnumerable<string> recipients, string subject, string body)
        {
            return SendEmailAsync(recipients, subject, body, null);
        }

        public Task SendEmailAsync(string from, IEnumerable<string> recipients, string subject, string body)
        {
            return SendEmailAsync(new MailAddress(from), recipients, subject, body, null);
        }
    }
}
