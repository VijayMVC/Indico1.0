using System;
using System.IO;
using Indico.BusinessObjects;

namespace Indico.Common
{
	/// <summary>
	/// Summary description for IndicoHttpRequestFilter.
	/// </summary>
	public class IndicoHttpRequestFilter : System.IO.Stream
	{
        #region Fields

		private Stream sink;
	//**TODO	private HistoryDataViewBO m_objHistory;

        #endregion


      /**TODO  public HistoryDataViewBO History 
		{
			get 
			{
				if (m_objHistory == null) 
				{
					m_objHistory = new HistoryDataViewBO();
					m_objHistory.DateStart = DateTime.Now;
				}

				return m_objHistory;
			}
		} **/

		public IndicoHttpRequestFilter(System.IO.Stream stream) 
		{
			sink = stream;
		}

	/**TODO	public IndicoHttpRequestFilter(System.IO.Stream stream, HistoryDataViewBO history) 
		{
			sink = stream;
			m_objHistory = history;
		} **/

		#region Stream Properties

		public override bool CanRead
		{
			get 
			{
				return true;
			}
		}

		public override bool CanSeek
		{
			get 
			{
				return true;
			}
		}

		public override bool CanWrite
		{
			get 
			{
				return false;
			}
		}

		public override long Length
		{
			get 
			{
				return sink.Length;
			}
		}

		public override long Position
		{
			get 
			{
				return sink.Position;
			}
			set 
			{
				sink.Position = value;
			}
		}

		#endregion

		#region Stream Methods

		public override long Seek(long offset, SeekOrigin origin)
		{
			return sink.Seek(offset, origin);
		}

		public override void SetLength(long value)
		{
			sink.SetLength(value);
		}

		public override void Flush()
		{
			sink.Flush();
		}

		public override void Close()
		{
			sink.Close();
		}

		#endregion

		#region Filter Method and properties

		public override int Read(byte[] buffer, int offset, int count)
		{
		//**TODO	this.History.BytesUp += count;
			return sink.Read(buffer, offset, count);
		}

		public override void Write(byte[] buffer, int offset, int count)
		{
			throw new Exception("This stream cannot be written to");
		}

		#endregion
	}
}
