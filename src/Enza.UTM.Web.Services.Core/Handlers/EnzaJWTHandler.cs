using Enza.UTM.Common.Extensions;
using Enza.UTM.Common.Security;
using System;
using System.Linq;
using System.Net.Http;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using System.Web;

namespace Enza.UTM.Web.Services.Core.Handlers
{
    public class EnzaJWTHandler : DelegatingHandler
    {
        private const string AUTH_HEADER_NAME = "enzauth";
        protected async override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            try
            {
                if (request.Headers.Contains(AUTH_HEADER_NAME))
                {
                    var token = request.Headers.GetValues(AUTH_HEADER_NAME).First();
                    var claimsPrincipal = Verify(token);
                    //convert all roles to lowercase to support case insensitive authorization check in attributes
                    var claimsIdentity = (ClaimsIdentity)claimsPrincipal.Identity;
                    var roleClaims = claimsPrincipal.Claims.Where(o => o.Type == ClaimTypes.Role).ToList();
                    foreach (var roleClaim in roleClaims)
                    {
                        claimsIdentity.RemoveClaim(roleClaim);
                        claimsIdentity.AddClaim(new Claim(roleClaim.Type, roleClaim.Value.ToLower()));
                    }
                    Thread.CurrentPrincipal = claimsPrincipal;
                    if (HttpContext.Current != null)
                    {
                        HttpContext.Current.User = claimsPrincipal;
                    }
                }
            }
            catch (Exception ex)
            {
                this.LogError(ex);
            }
            return await base.SendAsync(request, cancellationToken);
        }

        private ClaimsPrincipal Verify(string token)
        {
            var validator = new JwtTokenValidator();
            return validator.Verify(token);
        }
    }
}