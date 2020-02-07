using System.DirectoryServices;

namespace Enza.UTM.Common
{
    public class LDAP
    {
        public static string GetEmail(string domainUserName)
        {
            using (var connection = new DirectoryEntry())
            {
                var userName = GetUserName(domainUserName);
                var filter = $@"(&(samAccountName={userName})(objectCategory=person)(objectClass=user))";
                //var filter = $@"(samaccountname={userName})";
                var propertiesToLoad = new[] {"mail"};
                using (var searcher = new DirectorySearcher(connection, filter, propertiesToLoad))
                {
                    var searchResult = searcher.FindOne();
                    return GetProperty(searchResult, "mail");
                }
            }
        }

        private static string GetProperty(SearchResult searchResult, string PropertyName)
        {
            if (searchResult == null)
                return string.Empty;

            if (searchResult.Properties.Contains(PropertyName))
            {
                return System.Convert.ToString(searchResult.Properties[PropertyName][0]);
            }
            return string.Empty;
        }

        public static string GetUserName(string domainUserName)
        {
            if (string.IsNullOrWhiteSpace(domainUserName))
                return string.Empty;

            var tokens = domainUserName.Split(new[] {'/', '\\'});
            if (tokens.Length == 1)
                return tokens[0];
            if (tokens.Length == 2)
                return tokens[1];
            return string.Empty;
        }
    }
}
