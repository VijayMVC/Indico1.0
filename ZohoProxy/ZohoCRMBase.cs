using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using ZohoLibrary;

namespace ZohoProxy
{
    public abstract class ZohoCRMBase: IDisposable
    {
        #region Private variable

        private WebApiHelper httpClient = null;
        private string baseUri = "https://crm.zoho.com/";
        private string token;
        private bool disposed = false;

        #endregion

        #region Protected variable
        protected string ModuleName;

        #endregion
        
        public ZohoCRMBase(string authToken)
        {
            this.token = authToken;
            this.httpClient = new WebApiHelper(this.baseUri);
        }


        protected async Task<ZohoResult> PostAsync(string uri, HttpContent postData)
        {
            if (this.httpClient != null)
            {

                var result = await httpClient.PostAsync(uri, postData).ConfigureAwait(false);
                var response = JsonConvert.DeserializeObject<ZohoResponse>(result);
                return response.Response;
            }

            return null;
        }

        /// <summary>
        /// Gets the specified URI async
        /// </summary>
        /// <param name="uri">The URI.</param>
        /// <returns></returns>
        protected async Task<ZohoResult> GetAsync(string uri)
        {
            if (this.httpClient != null)
            {

                var result = await httpClient.GetAsync(uri).ConfigureAwait(false);
                var response = JsonConvert.DeserializeObject<ZohoResponse>(result);
                return response.Response;
            }

            return null;
        }

        /// <summary>
        /// Gets the Zoho Request URL.
        /// </summary>
        /// 
        /// <param name="method">The method.</param>
        /// <param name="paras">The url paras.</param>
        /// <returns></returns>
        protected string GetUrl(string method, Dictionary<string, string> paras)
        {
            StringBuilder result = new StringBuilder();
            result.AppendFormat("/crm/private/json/{0}/{1}?authtoken={2}&scope=crmapi", this.ModuleName, method, this.token);

            foreach (var para in paras)
            {
                result.AppendFormat("&{0}={1}", para.Key, para.Value);
            }

            return result.ToString();
        }

        #region Dispose
        ~ZohoCRMBase()
        {
            Dispose(false);
        }
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposed)
                return;

            if (disposing)
            {
                if (this.httpClient != null)
                {
                    this.httpClient.Dispose();
                    this.httpClient = null;
                }
            }

            disposed = true;
        }

        #endregion

    }
}
