using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Threading.Tasks;
using Enza.UTM.DataAccess.Interfaces;

namespace Enza.UTM.DataAccess.Abstract
{
    /// <summary>
    /// This class is responsible to expose core database functionality i.e. interaction with database store. 
    /// This is the base class of any database type and provides extensibility functionality for derived classes.
    /// </summary>
    public abstract class Database : IDatabase
    {
        #region Local/Member Variables

        private bool _disposed;
        private DbProviderFactory _factory;
        private DbConnection _connection;
        private DbCommand _command;
        private DbTransaction _trans;

        #endregion

        #region .Ctor

        /// <summary>
        /// Initializes a new instance of the <see cref="Database"/> class.
        /// </summary>
        /// <param name="nameOrConnectionString">The name or connection string.</param>
        /// <param name="userContext"></param>
        /// <exception cref="System.Exception">
        /// Failed to initialize DbProviderFactory based on provided provider name.
        /// or
        /// Failed to initialize connection based on provided provider name.
        /// </exception>
        protected Database(string nameOrConnectionString, IUserContext userContext)
        {
           Context = userContext?.GetContext();
            var conString = nameOrConnectionString;
            var providerName = ProviderName;
            var settings = ConfigurationManager.ConnectionStrings[nameOrConnectionString];
            if (settings != null)
            {
                conString = settings.ConnectionString;
                providerName = settings.ProviderName;
            }
            _factory = DbProviderFactories.GetFactory(providerName);
            if (_factory == null)
                throw new Exception("Failed to initialize DbProviderFactory based on provided provider name.");

            _connection = _factory.CreateConnection();
            if (_connection == null)
                throw new Exception("Failed to initialize connection based on provided provider name.");

            _connection.ConnectionString = conString;
        }

        #endregion

        #region Protected Methods

        /// <summary>
        /// Gets the name of the provider.
        /// </summary>
        /// <value>
        /// The name of the provider.
        /// </value>
        protected abstract string ProviderName { get; }

        /// <summary>
        /// Gets the factory.
        /// </summary>
        /// <value>
        /// The factory.
        /// </value>
        protected DbProviderFactory Factory => _factory;

        /// <summary>
        /// Creates the name of the parameter.
        /// </summary>
        /// <param name="name">The name.</param>
        /// <returns></returns>
        /// <exception cref="System.ArgumentException">name</exception>
        protected virtual string CreateParameterName(string name)
        {
            if (string.IsNullOrEmpty(name))
                throw new ArgumentException("name");

            if (name.StartsWith("@"))
            {
                return name;
            }
            return string.Concat("@", name);
        }

        #endregion

        #region Private Methods

        /// <summary>
        /// Creates the parameter.
        /// </summary>
        /// <param name="name">The name.</param>
        /// <param name="value">The value.</param>
        /// <returns></returns>
        /// <exception cref="System.Exception">Failed to create parameter object by the Provider Factory.</exception>
        public virtual DbParameter CreateParameter(string name, object value)
        {
            if (!(value is DbParameter param))
            {
                var parameter = _factory.CreateParameter();
                if (parameter == null)
                    throw new Exception("Failed to create parameter object by the Provider Factory.");

                parameter.ParameterName = CreateParameterName(name);
                parameter.Value = value ?? DBNull.Value;
                return parameter;
            }
            return param;
        }

        public virtual DbParameter CreateOutputParameter(string name, DbType dbType)
        {
            var parameter = _factory.CreateParameter();
            if (parameter == null)
                throw new Exception("Failed to create parameter object by the Provider Factory.");

            parameter.ParameterName = CreateParameterName(name);
            parameter.DbType = dbType;
            parameter.Direction = ParameterDirection.Output;
            return parameter;
        }
        public DbParameter CreateOutputParameter(string name, DbType dbType, int size)
        {
            var parameter = _factory.CreateParameter();
            if (parameter == null)
                throw new Exception("Failed to create parameter object by the Provider Factory.");

            parameter.ParameterName = CreateParameterName(name);
            parameter.DbType = dbType;
            parameter.Direction = ParameterDirection.Output;
            parameter.Size = size;
            return parameter;
        }

        public DbParameter CreateInOutParameter(string name, object value, DbType dbType, int size)
        {
            var parameter = _factory.CreateParameter();
            if (parameter == null)
                throw new Exception("Failed to create parameter object by the Provider Factory.");

            parameter.ParameterName = CreateParameterName(name);
            parameter.DbType = dbType;
            parameter.Direction = ParameterDirection.InputOutput;
            parameter.Size = size;
            parameter.Value = value ?? DBNull.Value;
            return parameter;
        }

        public virtual DbParameter CreateTVPParameter(string name, DataTable value)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Opens the connection.
        /// </summary>
        private async Task OpenAsync()
        {
            if (!(_connection.State == ConnectionState.Open || _connection.State == ConnectionState.Connecting))
                await _connection.OpenAsync();
            //CommandTimeOut can't be applied on constructor. So, it was called here.
            CreateCommand();
        }
        
        /// <summary>
        /// Closes the connection.
        /// </summary>
        private void Close()
        {
            if (_connection.State != ConnectionState.Closed)
            {
                if (_trans == null)
                    _connection.Close();
            }
        }

        /// <summary>
        /// Setups the parameters.
        /// </summary>
        /// <param name="args">The arguments.</param>
        void SetupParameters(IDictionary<string, object> args)
        {
            _command.Parameters.Clear();

            if (args != null && args.Count > 0)
            {
                foreach (var key in args.Keys)
                {
                    var value = args[key];
                    if (value is DbParameter)
                    {
                        _command.Parameters.Add(value as DbParameter);
                    }
                    else
                    {
                        var parameter = CreateParameter(key, args[key]);
                        _command.Parameters.Add(parameter);
                    }
                }
            }
        }

        #endregion

        #region Public Methods

        /// <summary>
        /// Gets or sets the command timeout. Default value is 30 seconds
        /// </summary>
        /// <value>
        /// The command timeout.
        /// </value>
        public int CommandTimeout { get; set; } = 30;
        protected IUserContext Context { get; }

        /// <summary>
        /// Creates the command.
        /// </summary>
        void CreateCommand()
        {
            if (_command == null)
                _command = _connection.CreateCommand();
            if (CommandTimeout != _command.CommandTimeout)
                _command.CommandTimeout = CommandTimeout;
        }

        /// <summary>
        /// Creates the data adapter. Must be overriden by the derived class
        /// </summary>
        /// <param name="cmd">The command.</param>
        /// <returns></returns>
        protected abstract DbDataAdapter CreateDataAdapter(DbCommand cmd);

        /// <summary>
        /// Gets the parameter value.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="parameterName">Name of the parameter.</param>
        /// <returns></returns>
        public T GetParameterValue<T>(string parameterName)
        {
            return (T) _command.Parameters[parameterName].Value;
        }

        protected async Task SetContextAsync()
        {
            if (Context != null)
            {
                PrepareContextCommand();
                await _command.ExecuteNonQueryAsync();
                _command.Parameters.Clear();
            }
        }

        void PrepareContextCommand()
        {
            //create userName from context object
            var userName = Context.FullName;
            const string query =
                @"DECLARE @Ctx VARBINARY(128) = CAST(@username AS VARBINARY(128));SET CONTEXT_INFO @Ctx;";
            _command.CommandText = query;
            _command.CommandType = CommandType.Text;

            _command.Parameters.Clear();
            var parameter = CreateParameter("@username", userName);
            parameter.DbType = DbType.String;
            parameter.Size = 128;
            _command.Parameters.Add(parameter);
        }

        #region Transactions

        /// <summary>
        /// Begins the trans.
        /// </summary>
        public async Task BeginTransactionAsync()
        {
            if (_trans == null)
            {
                //connection should be opened prior to begin transaction.
                await OpenAsync();
                _trans = _connection.BeginTransaction(); //Task.Run(() => _connection.BeginTransaction());
            }
        }

        /// <summary>
        /// Commits the trans.
        /// </summary>
        public async Task CommitTransactionAsync()
        {
            if (_trans != null)
            {
                await Task.Run(() =>
                {
                    _trans.Commit();
                    _trans.Dispose();
                    _trans = null;
                });
            }
            Close();
        }

        /// <summary>
        /// Rollbacks the trans.
        /// </summary>
        public async Task RollbackTransactionAsync()
        {
            if (_trans != null)
            {
                await Task.Run(() =>
                {
                    _trans.Rollback();
                    _trans.Dispose();
                    _trans = null;
                });
            }
            Close();
        }

        /// <summary>
        /// Begins the transactio internal.
        /// </summary>

        #endregion


        /// <summary>
        /// Executes the non query.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <param name="commandType">Type of the command.</param>
        /// <param name="args">The arguments.</param>
        /// <returns></returns>
        public async Task<int> ExecuteNonQueryAsync(string query, CommandType commandType,
            IDictionary<string, object> args)
        {
            int rs;
            try
            {
                await OpenAsync();
                //if transaction is enabled, assign it to command
                if (_trans != null)
                {
                    _command.Transaction = _trans;
                }
                //set connection context
                await SetContextAsync();

                _command.CommandText = query;
                _command.CommandType = commandType;
                SetupParameters(args);

                rs = await _command.ExecuteNonQueryAsync();
            }
            finally
            {
                Close();
            }
            return rs;
        }

        /// <summary>
        /// Executes the non query.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <param name="args">The arguments.</param>
        /// <returns></returns>
        public async Task<int> ExecuteNonQueryAsync(string query, IDictionary<string, object> args)
        {
            return await ExecuteNonQueryAsync(query, CommandType.Text, args);
        }

        /// <summary>
        /// Executes the non query.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <param name="commandType">Type of the command.</param>
        /// <param name="args">The arguments.</param>
        /// <returns></returns>
        public async Task<int> ExecuteNonQueryAsync(string query, CommandType commandType,
            Action<IDictionary<string, object>> args)
        {
            var parameters = new Dictionary<string, object>();
            args?.Invoke(parameters);
            return await ExecuteNonQueryAsync(query, commandType, parameters);
        }

        /// <summary>
        /// Executes the non query.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <param name="args">The arguments.</param>
        /// <returns></returns>
        public async Task<int> ExecuteNonQueryAsync(string query, Action<IDictionary<string, object>> args)
        {
            return await ExecuteNonQueryAsync(query, CommandType.Text, args);
        }

        /// <summary>
        /// Executes the non query.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <param name="commandType">Type of the command.</param>
        /// <returns></returns>
        public async Task<int> ExecuteNonQueryAsync(string query, CommandType commandType)
        {
            return await ExecuteNonQueryAsync(query, commandType, args => { });
        }

        /// <summary>
        /// Executes the non query.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <returns></returns>
        public async Task<int> ExecuteNonQueryAsync(string query)
        {
            return await ExecuteNonQueryAsync(query, CommandType.Text);
        }



        /// <summary>
        /// Executes the scalar.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <param name="commandType">Type of the command.</param>
        /// <param name="args">The arguments.</param>
        /// <returns></returns>
        public async Task<object> ExecuteScalarAsync(string query, CommandType commandType,
            IDictionary<string, object> args)
        {
            object rs;
            try
            {
                await OpenAsync();
                //if transaction is enabled, assign it to command
                if (_trans != null)
                {
                    _command.Transaction = _trans;
                }
                //set connection context
                await SetContextAsync();

                _command.CommandText = query;
                _command.CommandType = commandType;
                SetupParameters(args);

                rs = await _command.ExecuteScalarAsync();
            }
            finally
            {
                Close();
            }
            return rs;
        }

        /// <summary>
        /// Executes the scalar.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <param name="args">The arguments.</param>
        /// <returns></returns>
        public async Task<object> ExecuteScalarAsync(string query, IDictionary<string, object> args)
        {
            return await ExecuteScalarAsync(query, CommandType.Text, args);
        }

        /// <summary>
        /// Executes the scalar.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <param name="commandType">Type of the command.</param>
        /// <param name="args">The arguments.</param>
        /// <returns></returns>
        public async Task<object> ExecuteScalarAsync(string query, CommandType commandType,
            Action<IDictionary<string, object>> args)
        {
            var parameters = new Dictionary<string, object>();
            args?.Invoke(parameters);
            return await ExecuteScalarAsync(query, commandType, parameters);
        }

        /// <summary>
        /// Executes the scalar.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <param name="args">The arguments.</param>
        /// <returns></returns>
        public async Task<object> ExecuteScalarAsync(string query, Action<IDictionary<string, object>> args)
        {
            return await ExecuteScalarAsync(query, CommandType.Text, args);
        }

        /// <summary>
        /// Executes the scalar.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <param name="commandType">Type of the command.</param>
        /// <returns></returns>
        public async Task<object> ExecuteScalarAsync(string query, CommandType commandType)
        {
            return await ExecuteScalarAsync(query, commandType, args => { });
        }

        /// <summary>
        /// Executes the scalar.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <returns></returns>
        public async Task<object> ExecuteScalarAsync(string query)
        {
            return await ExecuteScalarAsync(query, CommandType.Text);
        }

        public async Task<DbDataReader> ExecuteReaderAsync(string query, CommandType commandType,
            IDictionary<string, object> args, CommandBehavior behavior = CommandBehavior.Default)
        {
            await OpenAsync();
            //if transaction is enabled, assign it to command
            if (_trans != null)
            {
                _command.Transaction = _trans;
            }
            //set connection context
            await SetContextAsync();

            _command.CommandText = query;
            _command.CommandType = commandType;
            SetupParameters(args);

            return await _command.ExecuteReaderAsync(behavior);
        }

        public async Task<DbDataReader> ExecuteReaderAsync(string query, CommandType commandType,
            Action<IDictionary<string, object>> args, CommandBehavior behavior = CommandBehavior.Default)
        {
            var parameters = new Dictionary<string, object>();
            args?.Invoke(parameters);
            return await ExecuteReaderAsync(query, commandType, parameters, behavior);
        }



        /// <summary>
        /// Executes the reader.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="query">The query.</param>
        /// <param name="commandType">Type of the command.</param>
        /// <param name="args">The arguments.</param>
        /// <param name="mapping">The mapping.</param>
        /// <param name="behavior">The behavior.</param>
        /// <returns></returns>
        public async Task<IEnumerable<T>> ExecuteReaderAsync<T>(string query, CommandType commandType,
            IDictionary<string, object> args,
            Func<DbDataReader, T> mapping, CommandBehavior behavior = CommandBehavior.Default)
        {
            var rs = new List<T>();
            try
            {
                await OpenAsync();
                //if transaction is enabled, assign it to command
                if (_trans != null)
                {
                    _command.Transaction = _trans;
                }
                //set connection context
                await SetContextAsync();

                _command.CommandText = query;
                _command.CommandType = commandType;
                SetupParameters(args);

                using (var reader = await _command.ExecuteReaderAsync(behavior))
                {
                    while (await reader.ReadAsync())
                    {
                        rs.Add(mapping(reader));
                    }
                }
            }
            finally
            {
                Close();
            }
            return rs;
        }

        /// <summary>
        /// Executes the reader.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="query">The query.</param>
        /// <param name="args">The arguments.</param>
        /// <param name="mapping">The mapping.</param>
        /// <returns></returns>
        public async Task<IEnumerable<T>> ExecuteReaderAsync<T>(string query, IDictionary<string, object> args,
            Func<DbDataReader, T> mapping)
        {
            return await ExecuteReaderAsync(query, CommandType.Text, args, mapping);
        }

        /// <summary>
        /// Executes the reader.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="query">The query.</param>
        /// <param name="commandType">Type of the command.</param>
        /// <param name="args">The arguments.</param>
        /// <param name="mapping">The mapping.</param>
        /// <returns></returns>
        public async Task<IEnumerable<T>> ExecuteReaderAsync<T>(string query, CommandType commandType,
            Action<IDictionary<string, object>> args, Func<DbDataReader, T> mapping)
        {
            var parameters = new Dictionary<string, object>();
            args?.Invoke(parameters);
            return await ExecuteReaderAsync(query, commandType, parameters, mapping);
        }

        /// <summary>
        /// Executes the reader.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="query">The query.</param>
        /// <param name="args">The arguments.</param>
        /// <param name="mapping">The mapping.</param>
        /// <returns></returns>
        public async Task<IEnumerable<T>> ExecuteReaderAsync<T>(string query, Action<IDictionary<string, object>> args,
            Func<DbDataReader, T> mapping)
        {
            return await ExecuteReaderAsync(query, CommandType.Text, args, mapping);
        }

        /// <summary>
        /// Executes the reader.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="query">The query.</param>
        /// <param name="commandType">Type of the command.</param>
        /// <param name="mapping">The mapping.</param>
        /// <returns></returns>
        public async Task<IEnumerable<T>> ExecuteReaderAsync<T>(string query, CommandType commandType,
            Func<DbDataReader, T> mapping)
        {
            return await ExecuteReaderAsync(query, commandType, args => { }, mapping);
        }

        /// <summary>
        /// Executes the reader.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="query">The query.</param>
        /// <param name="mapping">The mapping.</param>
        /// <returns></returns>
        public async Task<IEnumerable<T>> ExecuteReaderAsync<T>(string query, Func<DbDataReader, T> mapping)
        {
            return await ExecuteReaderAsync(query, CommandType.Text, mapping);
        }



        /// <summary>
        /// Executes the data set.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <param name="commandType">Type of the command.</param>
        /// <param name="args">The arguments.</param>
        /// <returns></returns>
        public async Task<DataSet> ExecuteDataSetAsync(string query, CommandType commandType,
            IDictionary<string, object> args)
        {
            try
            {
                await OpenAsync();

                CreateCommand();
                //if transaction is enabled, assign it to command
                if (_trans != null)
                {
                    _command.Transaction = _trans;
                }
                //set connection context
                await SetContextAsync();

                _command.CommandText = query;
                _command.CommandType = commandType;
                SetupParameters(args);

                var rs = new DataSet {EnforceConstraints = false, RemotingFormat = SerializationFormat.Binary};
                using (var da = CreateDataAdapter(_command))
                {
                    da.Fill(rs);
                }
                return rs;
            }
            finally
            {
                Close();
            }
        }

        /// <summary>
        /// Executes the data set.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <param name="args">The arguments.</param>
        /// <returns></returns>
        public async Task<DataSet> ExecuteDataSetAsync(string query, IDictionary<string, object> args)
        {
            return await ExecuteDataSetAsync(query, CommandType.Text, args);
        }

        /// <summary>
        /// Executes the data set.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <param name="commandType">Type of the command.</param>
        /// <param name="args">The arguments.</param>
        /// <returns></returns>
        public async Task<DataSet> ExecuteDataSetAsync(string query, CommandType commandType,
            Action<IDictionary<string, object>> args)
        {
            var parameters = new Dictionary<string, object>();
            args?.Invoke(parameters);
            return await ExecuteDataSetAsync(query, commandType, parameters);
        }

        /// <summary>
        /// Executes the data set.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <param name="args">The arguments.</param>
        /// <returns></returns>
        public async Task<DataSet> ExecuteDataSetAsync(string query, Action<IDictionary<string, object>> args)
        {
            return await ExecuteDataSetAsync(query, CommandType.Text, args);
        }

        /// <summary>
        /// Executes the data set.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <param name="commandType">Type of the command.</param>
        /// <returns></returns>
        public async Task<DataSet> ExecuteDataSetAsync(string query, CommandType commandType)
        {
            return await ExecuteDataSetAsync(query, commandType, args => { });
        }

        /// <summary>
        /// Executes the data set.
        /// </summary>
        /// <param name="query">The query.</param>
        /// <returns></returns>
        public async Task<DataSet> ExecuteDataSetAsync(string query)
        {
            return await ExecuteDataSetAsync(query, CommandType.Text);
        }

        #endregion

        public virtual Task<string> ExecuteAsync(string queryAsJson)
        {
            throw new NotImplementedException();
        }

        #region IDisposable Members

        /// <summary>
        /// Finalizes an instance of the <see cref="Database"/> class.
        /// </summary>
        ~Database()
        {
            Dispose(false);
        }

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// Releases unmanaged and - optionally - managed resources.
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposed) return;

            if (disposing)
            {
                if (_command != null)
                {
                    _command.Dispose();
                    _command = null;
                }
                if (_trans != null)
                {
                    _trans.Dispose();
                    _trans = null;
                }
                if (_connection != null)
                {
                    _connection.Dispose();
                    _connection = null;
                }
                _factory = null;
            }
            _disposed = true;
        }

        

        #endregion
    }
}
