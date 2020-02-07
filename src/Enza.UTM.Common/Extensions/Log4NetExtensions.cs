using System;
using System.IO;
using System.Linq;
using log4net;
using log4net.Appender;

namespace Enza.UTM.Common.Extensions
{
    public static class Log4NetExtensions
    {
        private static ILog _logger;

        public static void LogDebug(this object o, Exception ex)
        {
            Initialize(o);
            if (_logger.IsDebugEnabled)
            {
                _logger.Debug(ex.GetException());
            }
        }

        public static void LogError(this object o, Exception ex)
        {
            Initialize(o);
            if (_logger.IsErrorEnabled)
            {
                _logger.Error(ex.GetException());
            }
        }

        public static void LogError(this Type type, Exception ex)
        {
            Initialize(type);
            if (_logger.IsErrorEnabled)
            {
                _logger.Error(ex.GetException());
            }
        }

        public static void Fatal(this object o, Exception ex)
        {
            Initialize(o);
            if (_logger.IsFatalEnabled)
            {
                _logger.Fatal(ex.GetException());
            }
        }

        public static void LogInfo(this object o, Exception ex)
        {
            Initialize(o);
            if (_logger.IsInfoEnabled)
            {
                _logger.Info(ex.GetException());
            }
        }

        private static void Initialize(object o)
        {
            Initialize(o.GetType());
        }

        private static void Initialize(Type type)
        {
            if (_logger == null)
            {
                _logger = LogManager.GetLogger(type);
            }
            else
            {
                if (_logger.Logger.Name != type.FullName)
                {
                    _logger = LogManager.GetLogger(type);
                }
            }
        }
        public static Exception GetException(this Exception ex)
        {
            var innerEx = ex;
            while (innerEx.InnerException != null)
            {
                innerEx = innerEx.InnerException;
            }
            return innerEx;
        }

        public static Stream GetLogCurrentFile(this ILog logger, string dir)
        {
            var logFile = logger.Logger.Repository.GetAppenders()
                        .OfType<FileAppender>()
                        .FirstOrDefault()?.File;
            var logFileName = Path.Combine(dir, logFile);
            if (File.Exists(logFileName))
            {
                return new FileStream(logFileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
            }
            return null;
        }
    }
}