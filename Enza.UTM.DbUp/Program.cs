using System;
using System.Configuration;
using System.IO;
using DbUp;

namespace Enza.UTM.DbUp
{
    class Program
    {
        static int Main(string[] args)
        {
            //var environment = ConfigurationManager.AppSettings["App:Environment"];
            //if (string.IsNullOrWhiteSpace(environment))
            //{
            //    Console.WriteLine("App:Environment is not specified in app.config file.");
            //    return -1;
            //}
            //environment = string.Concat(environment, @"\");
            var root = GetExeDirectory();
            //var scriptDirectory = Path.Combine(root, @"Scripts\", environment);
            var scriptDirectory = Path.Combine(root, "Scripts");
            Console.WriteLine(scriptDirectory);
            var connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            var upgrader = DeployChanges.To
                    .SqlDatabase(connectionString)
                    .WithScriptsFromFileSystem(scriptDirectory)
                    .LogToConsole()
                    .Build();            
            var result = upgrader.PerformUpgrade();
            if (!result.Successful)
            {
                return -1;
            }            
            return 0;
        }

        static string GetExeDirectory()
        {
            return new Uri(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().CodeBase)).LocalPath;
        }
    }
}
