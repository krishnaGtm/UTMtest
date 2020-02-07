using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Enza.UTM.DataAccess.Interfaces
{
    public interface IRepository<T> : IDisposable
    {
        Task<IEnumerable<T>> GetAllAsync();
        Task<IEnumerable<T>> GetAllAsync<TArgs>(TArgs args);
        Task<T> GetAsync<TArgs>(TArgs args);

        Task AddAsync(T entity);
        Task UpdateAsync(T entity);
        Task DeleteAsync(T entity);
    }
}
