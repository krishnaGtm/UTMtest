using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security.Claims;
using System.Security.Principal;
using System.Threading.Tasks;
using Microsoft.Win32.SafeHandles;

namespace Enza.UTM.Common.Extensions
{
    public static class IdentityExtensions
    {
        [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        public static extern bool LogonUser(String lpszUsername, String lpszDomain, String lpszPassword,
            int dwLogonType, int dwLogonProvider, out SafeAccessTokenHandle phToken);

        public static async Task ImpersonateAsync(this IIdentity identity, Func<Task> action)
        {
            if (!(identity is WindowsIdentity user))
                throw new NotSupportedException("Identity must be WindowsIdentity.");

            await WindowsIdentity.RunImpersonated(user.AccessToken, async () => await action());
        }

        public static SafeAccessTokenHandle GetWindowsAccessToken(string userName, string password, string domainName)
        {
            const int LOGON32_LOGON_INTERACTIVE = 2;
            //const int LOGON32_LOGON_NETWORK = 3;
            //const int LOGON32_LOGON_BATCH = 4;
            //const int LOGON32_LOGON_SERVICE = 5;
            //const int LOGON32_LOGON_UNLOCK = 7;
            //const int LOGON32_LOGON_NETWORK_CLEARTEXT = 8;
            //const int LOGON32_LOGON_NEW_CREDENTIALS = 9;
            const int LOGON32_PROVIDER_DEFAULT = 0;

            // Call LogonUser to obtain a handle to an access token. 
            var returnValue = LogonUser(userName, domainName, password,
                LOGON32_LOGON_INTERACTIVE, LOGON32_PROVIDER_DEFAULT,
                out var safeAccessTokenHandle);
            if (false == returnValue)
            {
                var ret = Marshal.GetLastWin32Error();
                throw new System.ComponentModel.Win32Exception(ret);
            }
            return safeAccessTokenHandle;
        }

        public static List<string> GetClaims(this IPrincipal user, string claimName)
        {
            var identity = user as ClaimsPrincipal;
            return identity.Claims.Where(x => x.Type.EqualsIgnoreCase(claimName)).Select(x => x.Value).ToList();

        }
    }

    public enum LogonType
    {
        LOGON32_LOGON_INTERACTIVE = 2,
        LOGON32_LOGON_NETWORK = 3,
        LOGON32_LOGON_BATCH = 4,
        LOGON32_LOGON_SERVICE = 5,
        LOGON32_LOGON_UNLOCK = 7,
        LOGON32_LOGON_NETWORK_CLEARTEXT = 8, // Win2K or higher
        LOGON32_LOGON_NEW_CREDENTIALS = 9 // Win2K or higher
    };

    public enum LogonProvider
    {
        LOGON32_PROVIDER_DEFAULT = 0,
        LOGON32_PROVIDER_WINNT35 = 1,
        LOGON32_PROVIDER_WINNT40 = 2,
        LOGON32_PROVIDER_WINNT50 = 3
    };

    public enum ImpersonationLevel
    {
        SecurityAnonymous = 0,
        SecurityIdentification = 1,
        SecurityImpersonation = 2,
        SecurityDelegation = 3
    }

    public class Win32NativeMethods
    {
        [DllImport("advapi32.dll", SetLastError = true)]
        public static extern int LogonUser(string lpszUserName,
            string lpszDomain,
            string lpszPassword,
            int dwLogonType,
            int dwLogonProvider,
            ref IntPtr phToken);

        [DllImport("advapi32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern int DuplicateToken(IntPtr hToken,
            int impersonationLevel,
            ref IntPtr hNewToken);

        [DllImport("advapi32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern bool RevertToSelf();

        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
        public static extern bool CloseHandle(IntPtr handle);
    }

    /// <summary>
    /// Allows code to be executed under the security context of a specified user account.
    /// </summary>
    /// <remarks> 
    ///
    /// Implements IDispose, so can be used via a using-directive or method calls;
    ///  ...
    ///
    ///  var imp = new Impersonator( "myUsername", "myDomainname", "myPassword" );
    ///  imp.UndoImpersonation();
    ///
    ///  ...
    ///
    ///   var imp = new Impersonator();
    ///  imp.Impersonate("myUsername", "myDomainname", "myPassword");
    ///  imp.UndoImpersonation();
    ///
    ///  ...
    ///
    ///  using ( new Impersonator( "myUsername", "myDomainname", "myPassword" ) )
    ///  {
    ///   ...
    ///   
    ///   ...
    ///  }
    ///
    ///  ...
    /// </remarks>
    public class Impersonator : IDisposable
    {
        private WindowsImpersonationContext _wic;

        public Impersonator(string userName, string domainName, string password, LogonType logonType,
            LogonProvider logonProvider)
        {
            Impersonate(userName, domainName, password, logonType, logonProvider);
        }

        public Impersonator(string userName, string domainName, string password)
        {
            Impersonate(userName, domainName, password, LogonType.LOGON32_LOGON_INTERACTIVE,
                LogonProvider.LOGON32_PROVIDER_DEFAULT);
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="Impersonator"/> class.
        /// </summary>
        public Impersonator()
        {
        }

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            UndoImpersonation();
        }

        public void Impersonate(string userName, string domainName, string password)
        {
            Impersonate(userName, domainName, password, LogonType.LOGON32_LOGON_INTERACTIVE,
                LogonProvider.LOGON32_PROVIDER_DEFAULT);
        }

        public void Impersonate(string userName, string domainName, string password, LogonType logonType,
            LogonProvider logonProvider)
        {
            UndoImpersonation();

            IntPtr logonToken = IntPtr.Zero;
            IntPtr logonTokenDuplicate = IntPtr.Zero;
            try
            {
                // revert to the application pool identity, saving the identity of the current requestor
                _wic = WindowsIdentity.Impersonate(IntPtr.Zero);

                // do logon & impersonate
                if (Win32NativeMethods.LogonUser(userName,
                        domainName,
                        password,
                        (int)logonType,
                        (int)logonProvider,
                        ref logonToken) != 0)
                {
                    if (Win32NativeMethods.DuplicateToken(logonToken, (int)ImpersonationLevel.SecurityImpersonation,
                            ref logonTokenDuplicate) != 0)
                    {
                        var wi = new WindowsIdentity(logonTokenDuplicate);
                        wi.Impersonate(); // discard the returned identity context (which is the context of the application pool)
                    }
                    else
                        throw new Win32Exception(Marshal.GetLastWin32Error());
                }
                else
                    throw new Win32Exception(Marshal.GetLastWin32Error());
            }
            finally
            {
                if (logonToken != IntPtr.Zero)
                    Win32NativeMethods.CloseHandle(logonToken);

                if (logonTokenDuplicate != IntPtr.Zero)
                    Win32NativeMethods.CloseHandle(logonTokenDuplicate);
            }
        }


        public void RunAsIntegratedSecurity(string userName, string password, string domain)
        {
            Impersonate(userName, domain, password, LogonType.LOGON32_LOGON_NEW_CREDENTIALS,
                LogonProvider.LOGON32_PROVIDER_WINNT50);
        }

        /// <summary>
        /// Stops impersonation.
        /// </summary>
        private void UndoImpersonation()
        {
            // restore saved requestor identity
            if (_wic != null)
                _wic.Undo();
            _wic = null;
        }
    }
}
