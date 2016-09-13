using System;
using log4net.Config;
using log4net.Appender;

// Configure log4net using the .config file
[assembly: log4net.Config.XmlConfigurator(Watch = true)]

namespace Indico.BusinessObjects
{
    /// <summary>
    /// This class is responsible for logging information, warnings, errors etc.
    /// </summary>
    public static class IndicoLogging
    {
        // Create a logger for use in this class
        public static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
    }
}
