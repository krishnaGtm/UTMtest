using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Security.Principal;

namespace Enza.UTM.Common.Extensions
{
    public static class ClaimExtensions
    {
        public static IEnumerable<string> GetCrops(this IPrincipal user)
        {
            var prefix = "AG_ROLE_Crop";
            var principal = user as ClaimsPrincipal;
            //check if token is from user service. if yes, get crops with different logic

            var issuer = principal.FindFirst(x => x.Type == "iss");
            if (issuer != null && issuer.Value.ToLower() == "http://enzauth")
            {
                var cropsClaims = principal.FindAll(x => x.Type == "enzauth.crops");
                if (cropsClaims.Any())
                {
                    var cropCodes = cropsClaims.Select(x => x.Value);
                    return cropCodes;
                }
            }
            var roles = principal.FindAll(c => c.Type == ClaimTypes.Role);
            var crops = roles.Where(x => x.Value.StartsWith(prefix, System.StringComparison.OrdinalIgnoreCase))
                .Select(x => x.Value.Substring(prefix.Length));
            return crops;
        }
    }
}
