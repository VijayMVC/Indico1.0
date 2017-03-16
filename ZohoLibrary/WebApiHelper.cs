using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;

namespace ZohoLibrary
{
    public class WebApiHelper : IDisposable
    {

        private readonly HttpClient _httpClient;

        bool _disposed;
        
        public WebApiHelper(string uri, AuthenticationHeaderValue authentication = null)
        {
            _httpClient = new HttpClient {BaseAddress = new Uri(uri)};

            _httpClient.DefaultRequestHeaders.Accept.Clear();
            if(authentication != null)
            {
                _httpClient.DefaultRequestHeaders.Authorization = authentication;
            }
            _httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
        }

        public string Get(string requestUri)
        {
            var result = GetAsync(requestUri).Result;
            return result;
        }

        public async Task<string> GetAsync(string requestUri)
        {
            if (_httpClient == null) return string.Empty;
            var result = _httpClient.GetAsync(requestUri).Result;
            return result.Content.ReadAsStringAsync().Result;
        }

        public string Post(string requestUri, HttpContent postData)
        {
            var result = PostAsync(requestUri, postData).Result;
            return result;
        }

        public async Task<string> PostAsync(string requestUri, HttpContent postData)
        {
            
            if (_httpClient == null) return string.Empty;

            var result = _httpClient.PostAsync(requestUri, postData).Result;

            return result.Content.ReadAsStringAsync().Result;
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

       
        protected virtual void Dispose(bool disposing)
        {
            if (_disposed)
                return;

            if (disposing)
            {
                if(_httpClient !=null)
                {
                    _httpClient.Dispose();
                }
            }
            
            _disposed = true;

        }

        ~WebApiHelper()
        {
            Dispose(false);
        }
    }
}
