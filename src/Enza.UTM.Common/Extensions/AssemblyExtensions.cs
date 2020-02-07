using System.IO;
using System.Reflection;

namespace Enza.UTM.Common.Extensions
{
    public static class AssemblyExtensions
    {
        public static string GetString(this Assembly assembly, string resourceName)
        {
            using (var stream = assembly.GetManifestResourceStream(resourceName))
            {
                using (var reader = new StreamReader(stream))
                {
                    return reader.ReadToEnd();
                }
            }
        }
    }
}
