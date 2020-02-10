using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Threading.Tasks;

namespace Enza.UTM.DataAccess.Interfaces
{
    public interface IDatabase : IDisposable
    {
        /// <summary>
        /// Timeout in seconds
        /// </summary>
        int CommandTimeout { get; set; }

        DbParameter CreateParameter(string name, object value);
        DbParameter CreateOutputParameter(string name, DbType dbType);
        DbParameter CreateOutputParameter(string name, DbType dbType, int size);
        DbParameter CreateInOutParameter(string name, object value, DbType dbType, int size);
        DbParameter CreateTVPParameter(string name, DataTable value);

        Task BeginTransactionAsync();
        Task CommitTransactionAsync();
        Task RollbackTransactionAsync();

        Task<int> ExecuteNonQueryAsync(string query, CommandType commandType, IDictionary<string, object> args);
        Task<int> ExecuteNonQueryAsync(string query, IDictionary<string, object> args);
        Task<int> ExecuteNonQueryAsync(string query, CommandType commandType, Action<IDictionary<string, object>> args);
        Task<int> ExecuteNonQueryAsync(string query, Action<IDictionary<string, object>> args);
        Task<int> ExecuteNonQueryAsync(string query, CommandType commandType);
        Task<int> ExecuteNonQueryAsync(string query);

        Task<object> ExecuteScalarAsync(string query, CommandType commandType, IDictionary<string, object> args);
        Task<object> ExecuteScalarAsync(string query, IDictionary<string, object> args);
        Task<object> ExecuteScalarAsync(string query, CommandType commandType, Action<IDictionary<string, object>> args);
        Task<object> ExecuteScalarAsync(string query, Action<IDictionary<string, object>> args);
        Task<object> ExecuteScalarAsync(string query, CommandType commandType);
        Task<object> ExecuteScalarAsync(string query);


        Task<DbDataReader> ExecuteReaderAsync(string query, CommandType commandType, IDictionary<string, object> args,
            CommandBehavior behavior = CommandBehavior.Default);

        Task<DbDataReader> ExecuteReaderAsync(string query, CommandType commandType,
            Action<IDictionary<string, object>> args, CommandBehavior behavior = CommandBehavior.Default);

        Task<IEnumerable<T>> ExecuteReaderAsync<T>(string query, CommandType commandType,
            IDictionary<string, object> args,
            Func<DbDataReader, T> mapping, CommandBehavior behavior = CommandBehavior.Default);

        Task<IEnumerable<T>> ExecuteReaderAsync<T>(string query, IDictionary<string, object> args,
            Func<DbDataReader, T> mapping);

        Task<IEnumerable<T>> ExecuteReaderAsync<T>(string query, CommandType commandType,
            Action<IDictionary<string, object>> args, Func<DbDataReader, T> mapping);

        Task<IEnumerable<T>> ExecuteReaderAsync<T>(string query, Action<IDictionary<string, object>> args,
            Func<DbDataReader, T> mapping);
        Task<IEnumerable<T>> ExecuteReaderAsync<T>(string query, CommandType commandType, Func<DbDataReader, T> mapping);
        Task<IEnumerable<T>> ExecuteReaderAsync<T>(string query, Func<DbDataReader, T> mapping);

        Task<DataSet> ExecuteDataSetAsync(string query, CommandType commandType,
            IDictionary<string, object> args);

        Task<DataSet> ExecuteDataSetAsync(string query, IDictionary<string, object> args);

        Task<DataSet> ExecuteDataSetAsync(string query, CommandType commandType,
            Action<IDictionary<string, object>> args);

        Task<DataSet> ExecuteDataSetAsync(string query, Action<IDictionary<string, object>> args);
        Task<DataSet> ExecuteDataSetAsync(string query, CommandType commandType);
        Task<DataSet> ExecuteDataSetAsync(string query);

    }
}
