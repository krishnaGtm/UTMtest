using System.Configuration;
using DbUp;

namespace Enza.UTM.DbUp
{
    class Program
    {
        static int Main(string[] args)
        {
            var connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            var upgrader = DeployChanges.To
                    .SqlDatabase(connectionString)
                    .WithScriptsEmbeddedInAssembly(System.Reflection.Assembly.GetExecutingAssembly())
                    .LogToConsole()
                    .Build();
            var result = upgrader.PerformUpgrade();
            if (!result.Successful)
            {
                return -1;
            }
            return 0;
        }
    }
}
