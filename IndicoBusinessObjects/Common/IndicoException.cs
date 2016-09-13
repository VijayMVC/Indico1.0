using System;
using System.Configuration;
using System.Runtime.Serialization;

using Microsoft.ApplicationBlocks.ExceptionManagement;

namespace Indico.BusinessObjects
{
	/// <summary>
	/// Summary description for IndicoException.
	/// </summary>
	[Serializable()]
	public class IndicoException : BaseApplicationException 
	{
		private int m_intSeverity = 2;
		private int m_intErrorNumber = 0;
		private int m_intID = 0;
		private string m_strOuterMessage;

		/// <summary>
		/// True if the application is in Development mode. If the value of the AppSetting "strEnvironment" is "dev", then this returns true
		/// </summary>
		protected bool IsDevelopmentMode 
		{
			get 
			{
                return true;
              //**  return (INewsConfiguration.AppConfiguration.Environment.ToUpper() == "DEV");
			}
		}

		/// <summary>
		/// True if the application is in debug mode. This reflects the value of the AppSetting "blnIsDebugMode"
		/// </summary>
		protected bool IsDebugMode 
		{
			get 
			{
                return true;
              //**  return INewsConfiguration.AppConfiguration.IsIsDebugMode;   
			}
		}

		/// <summary>
		/// True if the application is in Maintenance mode. This reflects the value of the AppSetting "blnIsMaintenanceMode"
		/// </summary>
		protected bool IsMaintenanceMode 
		{
			get 
			{
                return true;
                //** return INewsConfiguration.AppConfiguration.IsIsMaintenanceMode;
			}
		}

		/// <summary>
		/// The location of the Maintenance URL. This reflects the value of the AppSetting "strMaintenanceURL"
		/// </summary>
		protected string MaintenanceURL 
		{
			get 
			{
                return null;
               //** return INewsConfiguration.AppConfiguration.MaintenanceURL; 
			}
		}
		
		/// <summary>
		/// The error message to display to the user when something unexpected happens.
		/// </summary>
		protected string UnexpectedErrorMessage 
		{
			get 
			{
                return null;
                //** return INewsConfiguration.AppConfiguration.UnexpectedErrorMessage; 
			}
		}

		/// <summary>
		/// The Severity of the IndicoException
		/// </summary>
		public int Severity 
		{
			get 
			{
				return m_intSeverity;
			}
			set 
			{
				m_intSeverity = value;
			}
		}

		/// <summary>
		/// The Error Number of the exception
		/// </summary>
		public int ErrorNumber 
		{
			get 
			{
				return m_intErrorNumber;
			}
			set 
			{
				m_intErrorNumber = value;
			}
		}

		/// <summary>
		/// The id of this error instance
		/// </summary>
		public int ID 
		{
			get 
			{
				return m_intID;
			}
			set 
			{
				m_intID = value;
			}
		}

		/// <summary>
		/// The Outer Message of the exception. This is the message displayed to users.
		/// </summary>
		public string OuterMessage 
		{
			get 
			{
				string msg;
				if (this.IsDebugMode || this.IsDevelopmentMode) 
				{
					msg = this.GetSystemErrorMessage(this.ErrorNumber);
					if (msg != String.Empty) 
					{
						msg += " : ";
					}
					msg += this.Message;
				} 
				else 
				{
					msg = this.GetUserErrorMessage(this.ErrorNumber);
					if (msg == String.Empty) 
					{
						if (this.Message == null || this.Message == String.Empty)
						{
							msg = this.UnexpectedErrorMessage;
						} 
						else 
						{
							msg = this.Message;
						}
					}
				}
				m_strOuterMessage = msg;

				return msg;
			}
		}

		#region Constants
		/// <summary>
		/// Error Number Constants
		/// </summary>
		public struct ERRNO{
				///<summary>readonly value for INT_ERR_SESSION_ALLOC_FAIL</summary>
				public const int INT_ERR_SESSION_ALLOC_FAIL = 10000;
				///<summary>readonly value for INT_ERR_SESSION_CACHE_UPDATE_FAIL</summary>
				public const int INT_ERR_SESSION_CACHE_UPDATE_FAIL = 10001;
				///<summary>readonly value for INT_ERR_SESSION_CACHE_PURGE_FAIL</summary>
				public const int INT_ERR_SESSION_CACHE_PURGE_FAIL = 10002;
				///<summary>readonly value for INT_ERR_SESSION_CACHE_PURGE_SUSPECT_FAIL</summary>
				public const int INT_ERR_SESSION_CACHE_PURGE_SUSPECT_FAIL = 10003;
				///<summary>readonly value for INT_ERR_BO_INSERT_FAIL</summary>
				public const int INT_ERR_BO_INSERT_FAIL = 10004;
				///<summary>readonly value for INT_ERR_BO_UPDATE_FAIL</summary>
				public const int INT_ERR_BO_UPDATE_FAIL = 10005;
				///<summary>readonly value for INT_ERR_BO_DELETE_FAIL</summary>
				public const int INT_ERR_BO_DELETE_FAIL = 10006;
				///<summary>readonly value for INT_ERR_BO_SELECT_FAIL</summary>
				public const int INT_ERR_BO_SELECT_FAIL = 10007;
				///<summary>readonly value for INT_ERR_USER_CACHE_PURGE_FAIL</summary>
				public const int INT_ERR_USER_CACHE_PURGE_FAIL = 10008;
				///<summary>readonly value for INT_ERR_USER_CACHE_UPDATE_FAIL</summary>
				public const int INT_ERR_USER_CACHE_UPDATE_FAIL = 10009;
				///<summary>readonly value for INT_ERR_USER_CACHE_PURGE_SUSPECT_FAIL</summary>
				public const int INT_ERR_USER_CACHE_PURGE_SUSPECT_FAIL = 10010;
				///<summary>readonly value for INT_ERR_VALID_SESSION_REQUIRED</summary>
				public const int INT_ERR_VALID_SESSION_REQUIRED = 10011;

			
				///<summary>readonly value for  STR_MSG_ERR_SESSION_ALLOC_FAIL</summary>
				public const string STR_MSG_ERR_SESSION_ALLOC_FAIL = "Could not allocate new YoGo Alley 2 Session";
				///<summary>readonly value for  STR_MSG_ERR_SESSION_CACHE_UPDATE_FAIL</summary>
				public const string STR_MSG_ERR_SESSION_CACHE_UPDATE_FAIL = "Could not update Session in cache.";
				///<summary>readonly value for  STR_MSG_ERR_SESSION_CACHE_PURGE_FAIL</summary>
				public const string STR_MSG_ERR_SESSION_CACHE_PURGE_FAIL = "Could not purge Session from cache";
				///<summary>readonly value for  STR_MSG_ERR_SESSION_CACHE_PURGE_SUSPECT_FAIL</summary>
				public const string STR_MSG_ERR_SESSION_CACHE_PURGE_SUSPECT_FAIL = "Could not purge a suspect Session from the cache";
				///<summary>readonly value for  STR_MSG_ERR_BO_INSERT_FAIL</summary>
				public const string STR_MSG_ERR_BO_INSERT_FAIL = "Could not add object to data store";
				///<summary>readonly value for  STR_MSG_ERR_BO_UPDATE_FAIL</summary>
				public const string STR_MSG_ERR_BO_UPDATE_FAIL = "Could not update object in data store";
				///<summary>readonly value for  STR_MSG_ERR_BO_DELETE_FAIL</summary>
				public const string STR_MSG_ERR_BO_DELETE_FAIL = "Could not delete object in data store";
				///<summary>readonly value for  STR_MSG_ERR_BO_SELECT_FAIL</summary>
				public const string STR_MSG_ERR_BO_SELECT_FAIL = "Could not retrieve object from data store";
				///<summary>readonly value for  STR_MSG_ERR_USER_CACHE_PURGE_FAIL</summary>
				public const string STR_MSG_ERR_USER_CACHE_PURGE_FAIL = "Could not purge User from cache";
				///<summary>readonly value for  STR_MSG_ERR_USER_CACHE_UPDATE_FAIL</summary>
				public const string STR_MSG_ERR_USER_CACHE_UPDATE_FAIL = "Could not update User in cache.";
				///<summary>readonly value for  STR_MSG_ERR_USER_CACHE_PURGE_SUSPECT_FAIL</summary>
				public const string STR_MSG_ERR_USER_CACHE_PURGE_SUSPECT_FAIL = "Could not purge a suspect User from the cache";
				///<summary>readonly value for  STR_MSG_ERR_VALID_SESSION_REQUIRED</summary>
				public const string STR_MSG_ERR_VALID_SESSION_REQUIRED = "A Valid Session is required to perform this action.";

				///<summary>readonly value for  STR_NMSG_ERR_SESSION_ALLOC_FAIL</summary>
				public const string STR_NMSG_ERR_SESSION_ALLOC_FAIL = "INews could not service your request at this time. Please try again later";
				///<summary>readonly value for  STR_NMSG_ERR_SESSION_CACHE_UPDATE_FAIL</summary>
				public const string STR_NMSG_ERR_SESSION_CACHE_UPDATE_FAIL = "INews could not service your request at this time. Please try again later";
				///<summary>readonly value for  STR_NMSG_ERR_SESSION_CACHE_PURGE_FAIL</summary>
				public const string STR_NMSG_ERR_SESSION_CACHE_PURGE_FAIL = "INews could not service your request at this time. Please try again later";
				///<summary>readonly value for  STR_NMSG_ERR_SESSION_CACHE_PURGE_SUSPECT_FAIL</summary>
				public const string STR_NMSG_ERR_SESSION_CACHE_PURGE_SUSPECT_FAIL = "INews could not service your request at this time. Please try again later";
				///<summary>readonly value for  STR_NMSG_ERR_BO_INSERT_FAIL</summary>
				public const string STR_NMSG_ERR_BO_INSERT_FAIL = "INews could not service your request at this time. Please try again later";
				///<summary>readonly value for  STR_NMSG_ERR_BO_UPDATE_FAIL</summary>
				public const string STR_NMSG_ERR_BO_UPDATE_FAIL = "INews could not service your request at this time. Please try again later";
				///<summary>readonly value for  STR_NMSG_ERR_BO_DELETE_FAIL</summary>
				public const string STR_NMSG_ERR_BO_DELETE_FAIL = "INews could not service your request at this time. Please try again later";
				///<summary>readonly value for  STR_NMSG_ERR_BO_SELECT_FAIL</summary>
				public const string STR_NMSG_ERR_BO_SELECT_FAIL = "INews could not service your request at this time. Please try again later";
				///<summary>readonly value for  STR_NMSG_ERR_USER_CACHE_PURGE_FAIL</summary>
				public const string STR_NMSG_ERR_USER_CACHE_PURGE_FAIL = "INews could not service your request at this time. Please try again later";
				///<summary>readonly value for  STR_NMSG_ERR_USER_CACHE_UPDATE_FAIL</summary>
				public const string STR_NMSG_ERR_USER_CACHE_UPDATE_FAIL = "INews could not service your request at this time. Please try again later";
				///<summary>readonly value for  STR_NMSG_ERR_USER_CACHE_PURGE_SUSPECT_FAIL</summary>
				public const string STR_NMSG_ERR_USER_CACHE_PURGE_SUSPECT_FAIL = "INews could not service your request at this time. Please try again later";
				///<summary>readonly value for  STR_NMSG_ERR_VALID_SESSION_REQUIRED</summary>
				public const string STR_NMSG_ERR_VALID_SESSION_REQUIRED = "You have to log in to do that. Please log in and try again.";
		}
		
		/// <summary>
		/// Retrieve the nice user error message for a particular error number
		/// </summary>
		/// <param name="errorNumber">The error number</param>
		/// <returns>a String containing the error message</returns>
		public string GetUserErrorMessage (int errorNumber) 
		{
			string msg;
			switch (errorNumber) {
				case ERRNO.INT_ERR_SESSION_ALLOC_FAIL:
					msg = ERRNO.STR_NMSG_ERR_SESSION_ALLOC_FAIL;
					break;
				case ERRNO.INT_ERR_SESSION_CACHE_UPDATE_FAIL:
					msg = ERRNO.STR_NMSG_ERR_SESSION_CACHE_UPDATE_FAIL;
					break;
				case ERRNO.INT_ERR_SESSION_CACHE_PURGE_FAIL:
					msg = ERRNO.STR_NMSG_ERR_SESSION_CACHE_PURGE_FAIL;
					break;
				case ERRNO.INT_ERR_SESSION_CACHE_PURGE_SUSPECT_FAIL:
					msg = ERRNO.STR_NMSG_ERR_SESSION_CACHE_PURGE_SUSPECT_FAIL;
					break;
				case ERRNO.INT_ERR_BO_INSERT_FAIL:
					msg = ERRNO.STR_NMSG_ERR_BO_INSERT_FAIL;
					break;
				case ERRNO.INT_ERR_BO_UPDATE_FAIL:
					msg = ERRNO.STR_NMSG_ERR_BO_UPDATE_FAIL;
					break;
				case ERRNO.INT_ERR_BO_DELETE_FAIL:
					msg = ERRNO.STR_NMSG_ERR_BO_DELETE_FAIL;
					break;
				case ERRNO.INT_ERR_BO_SELECT_FAIL:
					msg = ERRNO.STR_NMSG_ERR_BO_SELECT_FAIL;
					break;
				case ERRNO.INT_ERR_USER_CACHE_PURGE_FAIL:
					msg = ERRNO.STR_NMSG_ERR_USER_CACHE_PURGE_FAIL;
					break;
				case ERRNO.INT_ERR_USER_CACHE_UPDATE_FAIL:
					msg = ERRNO.STR_NMSG_ERR_USER_CACHE_UPDATE_FAIL;
					break;
				case ERRNO.INT_ERR_USER_CACHE_PURGE_SUSPECT_FAIL:
					msg = ERRNO.STR_NMSG_ERR_USER_CACHE_PURGE_SUSPECT_FAIL;
					break;
				case ERRNO.INT_ERR_VALID_SESSION_REQUIRED:
					msg = ERRNO.STR_NMSG_ERR_VALID_SESSION_REQUIRED;
					break;
				default:
					msg = String.Empty;
					break;
			}

			return msg;
		}
		
		/// <summary>
		/// Retrieve the system error message for a particular error number
		/// </summary>
		/// <param name="errorNumber">The error number</param>
		/// <returns>a String containing the error message</returns>
		public string GetSystemErrorMessage (int errorNumber) 
		{
			string msg;
			switch (errorNumber) {
				case ERRNO.INT_ERR_SESSION_ALLOC_FAIL:
					msg = ERRNO.STR_MSG_ERR_SESSION_ALLOC_FAIL;
					break;
				case ERRNO.INT_ERR_SESSION_CACHE_UPDATE_FAIL:
					msg = ERRNO.STR_MSG_ERR_SESSION_CACHE_UPDATE_FAIL;
					break;
				case ERRNO.INT_ERR_SESSION_CACHE_PURGE_FAIL:
					msg = ERRNO.STR_MSG_ERR_SESSION_CACHE_PURGE_FAIL;
					break;
				case ERRNO.INT_ERR_SESSION_CACHE_PURGE_SUSPECT_FAIL:
					msg = ERRNO.STR_MSG_ERR_SESSION_CACHE_PURGE_SUSPECT_FAIL;
					break;
				case ERRNO.INT_ERR_BO_INSERT_FAIL:
					msg = ERRNO.STR_MSG_ERR_BO_INSERT_FAIL;
					break;
				case ERRNO.INT_ERR_BO_UPDATE_FAIL:
					msg = ERRNO.STR_MSG_ERR_BO_UPDATE_FAIL;
					break;
				case ERRNO.INT_ERR_BO_DELETE_FAIL:
					msg = ERRNO.STR_MSG_ERR_BO_DELETE_FAIL;
					break;
				case ERRNO.INT_ERR_BO_SELECT_FAIL:
					msg = ERRNO.STR_MSG_ERR_BO_SELECT_FAIL;
					break;
				case ERRNO.INT_ERR_USER_CACHE_PURGE_FAIL:
					msg = ERRNO.STR_MSG_ERR_USER_CACHE_PURGE_FAIL;
					break;
				case ERRNO.INT_ERR_USER_CACHE_UPDATE_FAIL:
					msg = ERRNO.STR_MSG_ERR_USER_CACHE_UPDATE_FAIL;
					break;
				case ERRNO.INT_ERR_USER_CACHE_PURGE_SUSPECT_FAIL:
					msg = ERRNO.STR_MSG_ERR_USER_CACHE_PURGE_SUSPECT_FAIL;
					break;
				case ERRNO.INT_ERR_VALID_SESSION_REQUIRED:
					msg = ERRNO.STR_MSG_ERR_VALID_SESSION_REQUIRED;
					break;
				default:
					msg = String.Empty;
					break;
			}

			return msg;
		}
		#endregion

		#region severities struct
		/// <summary>
		/// A struct containing the various severities exceptions can fall under. the default is USER.
		/// </summary>
		public struct Severities
		{
			/// <summary>
			/// this is a validation exception. It is raised on validation failure in order to construct an
			/// error notification for a flash client
			/// </summary>
			public static readonly int VALIDATION = 0;
			/// <summary>
			/// this is a user error - usually recoverable, and caused by unexpected user behaviour or unexpected program behaviour.
			/// In any case, this type of exception should be logged and reviewed, as it would usually point to failings in the 
			/// logic of the application
			/// </summary>
			public static readonly int USER = 1;
			/// <summary>
			/// This severity is reserved for exceptions that show the application data is in danger of being corrupted, or that
			/// a core part of the application is no longer available. Triggering of this exception should put clients into maintenance
			/// mode. It should also be investigated thoroughly.
			/// </summary>
			public static readonly int APPLICATIONFATAL = 2;
		}

		#endregion

		#region constructors

		/// <summary>
		/// Create a new instance of IndicoException
		/// </summary>
		public IndicoException() : base()
		{

		}

		/// <summary>
		/// Create a new instance of IndicoException with the specified error message
		/// </summary>
		/// <param name="message">The exception message</param>
		public IndicoException(string message) : base(message)
		{

		}

		/// <summary>
		/// Create a new instance of IndicoException with the specified error message and inner exception
		/// </summary>
		/// <param name="message">The exception message</param>
		/// <param name="inner">The inner exception</param>
		public IndicoException(string message, Exception inner) : base(message, inner)

		{

		}

		/// <summary>
		/// Create a new instance of IndicoException with the specified error message, inner exception and severity
		/// </summary>
		/// <param name="message">The exception message</param>
		/// <param name="inner">The inner exception</param>
		/// <param name="severity">The severity. <see cref="IndicoException.Severities"/></param>
		public IndicoException(string message, Exception inner, int severity) : base(message, inner)
		{
			this.Severity = severity;
		}

		/// <summary>
		/// Create a new instance of IndicoException with the specified error message, inner exception, severity and error number
		/// </summary>
		/// <param name="message">The exception message</param>
		/// <param name="inner">The inner exception</param>
		/// <param name="severity">The severity. <see cref="IndicoException.Severities"/></param>
		/// <param name="errorNo">The Error Number, <see cref="IndicoException.ERRNO"/></param>
		public IndicoException(string message, Exception inner, int severity, int errorNo) : base(message, inner)
		{
			this.Severity = severity;
			this.ErrorNumber = errorNo;
		}

		/// <summary>
		/// Create a new instance of IndicoException with the specified error message and severity
		/// </summary>
		/// <param name="message">The exception message</param>
		/// <param name="severity">The severity. <see cref="IndicoException.Severities"/></param>
		public IndicoException(string message, int severity) : base(message)
		{
			this.Severity = severity;
		}

		/// <summary>
		/// Create a new instance of IndicoException with the specified error message, severity and error number
		/// </summary>
		/// <param name="message">The exception message</param>
		/// <param name="severity">The severity. <see cref="IndicoException.Severities"/></param>
		/// <param name="errorNo">The Error Number, <see cref="IndicoException.ERRNO"/></param>
		public IndicoException(string message, int severity, int errorNo) : base(message)
		{
			this.Severity = severity;
			this.ErrorNumber = errorNo;
		}

		/// <summary>
		/// Create a new instance of IndicoException with the specified SerializationInfo and StreamingContext.
		/// In the protected constructor, the code uses the SerializationInfo object to initialize the class state.
		/// </summary>
		/// <param name="info"></param>
		/// <param name="context"></param>
		protected IndicoException(SerializationInfo info, StreamingContext context) : base(info, context)
		{

		}

		#endregion

		#region overrides

		/// <summary>
		/// Overridden. GetObjectData is overridden to allow us to serialise the extra properties of IndicoException. 
		/// The code serializes the class state by using custom name-value pairs.
		/// </summary>
		/// <param name="info">SerializationInfo to use</param>
		/// <param name="context">StreamingContext to use</param>
		public override void GetObjectData(SerializationInfo info, StreamingContext context)
		{
			// Serialize this class' state and then call the base class GetObjectData
			info.AddValue("Severity", m_intSeverity, typeof(int));
			info.AddValue("ErrorNumber", m_intErrorNumber, typeof(int));
			info.AddValue("OuterMessage", m_strOuterMessage, typeof(string)); 
			base.GetObjectData(info, context);
		}

		#endregion
	}
}
