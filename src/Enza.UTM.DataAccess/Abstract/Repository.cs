using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;

namespace Enza.UTM.DataAccess.Abstract
{
    public abstract class Repository<T> : IRepository<T> where T : class
    {
        private bool disposed;
        protected Repository(IDatabase dbContext)
        {
            DbContext = dbContext;
        }
        protected IDatabase DbContext { get; }

        public virtual Task AddAsync(T entity)
        {
            throw new System.NotImplementedException();
        }

        public virtual Task DeleteAsync(T entity)
        {
            throw new System.NotImplementedException();
        }

        public virtual Task<IEnumerable<T>> GetAllAsync()
        {
            throw new System.NotImplementedException();
        }

        public virtual Task<IEnumerable<T>> GetAllAsync<TArgs>(TArgs args)
        {
            throw new System.NotImplementedException();
        }

        public virtual Task<T> GetAsync<TArgs>(TArgs args)
        {
            throw new System.NotImplementedException();
        }

        public virtual Task UpdateAsync(T entity)
        {
            throw new System.NotImplementedException();
        }


        #region IDisposable Members

        protected virtual void Dispose(bool disposing)
        {
            if (disposed) return;
            if (disposing)
            {

            }
            disposed = true;
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        ~Repository()
        {
            Dispose(false);
        }

        #endregion
    }
}
