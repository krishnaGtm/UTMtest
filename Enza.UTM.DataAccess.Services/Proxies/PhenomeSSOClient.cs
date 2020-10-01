using Enza.UTM.Common;
using Enza.UTM.Common.Extensions;
using Enza.UTM.Entities.Results;
using Enza.UTM.Services.Abstract;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using System.Configuration;
using System.Net.Http;
using System.Threading.Tasks;

namespace Enza.UTM.Services.Proxies
{
    public class PhenomeSSOClient
    {
        private async Task<AuthenticationResult> GetTokenAsync()
        {
            var instance = ConfigurationManager.AppSettings["SSO:Instance"];
            var tenant = ConfigurationManager.AppSettings["SSO:Tenant"];
            var clientId = ConfigurationManager.AppSettings["SSO:ClientID"];
            var (UserName, Password) = Credentials.GetCredentials("SSO:Credentials");
            var resource = ConfigurationManager.AppSettings["SSO:ResourceID"];

            var authority = $"{instance.TrimEnd('/')}/{tenant}";
            var context = new AuthenticationContext(authority, false);
            return await context.AcquireTokenAsync(resource, clientId, new UserPasswordCredential(UserName, Password));
        }

        public async Task<HttpResponseMessage> SignInAsync(RestClient client)
        {
            var token = await GetTokenAsync();
            var response = await client.PostAsync("/single_sign_on", values =>
            {
                values.Add("token", token.AccessToken);
            });
            await response.EnsureSuccessStatusCodeAsync();
            var result = await response.Content.DeserializeAsync<PhenomeSSOResult>();
            if (result.Status == "1")
            {
                //get UUID from response to process futher(setting cookies in phenome)
                if (string.IsNullOrWhiteSpace(result.UUID))
                {
                    throw new System.Exception("UUID for the request is not available.");
                }

                //request for authentication cookies
                //https://onprem.unity.phenome-networks.com/login_do?username=ronensh@phenome-test.co.il&password=FADC3116-E1B0-11E8-BC0B-B8211DFEC1A6
                response = await client.GetAsync($"/login_do?username={result.UserName}&password={result.UUID}");
            }
            return response;
        }
    }
}
