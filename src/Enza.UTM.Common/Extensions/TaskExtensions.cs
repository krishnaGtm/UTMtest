using System;
using System.Threading.Tasks;

namespace Enza.UTM.Common.Extensions
{
    public static class TaskExtensions
    {
        public static async Task<T> ExecuteSafe<T>(this Task<T> task, Action<Exception> error)
        {
            try
            {
                return await task;
            }
            catch (Exception ex)
            {
                error(ex);
            }
            return default(T);
        }
    }
}
