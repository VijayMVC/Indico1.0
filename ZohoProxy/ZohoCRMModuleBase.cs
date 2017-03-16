using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace ZohoProxy
{
    public class ZohoCRMModuleBase : ZohoCRMBase
    {
        #region Private variable

        //private bool disposed = false;
        #endregion

        public ZohoCRMModuleBase(string authToken) : base(authToken)
        {
            
        }


        /// <summary>
        /// Deletes the record by identifier.
        /// </summary>
        /// <param name="id">The identifier.</param>
        /// <returns></returns>
        public bool DeleteRecordById(string id)
        {
            var result = DeleteRecordByIdBaseAsync(id);
            return result.Result;
        }

        /// <summary>
        /// Inserts the record base.
        /// Currently Zoho API only support xml data in insert
        /// https://forums.zoho.com/topic/does-zoho-api-support-insertrecords-by-json
        /// 
        /// </summary>
        /// <param name="xmlData">The XML data.</param>
        /// <returns></returns>
        protected async Task<ZohoInsertUpdateDetail> InsertRecordBase(string xmlData)
        {
            var insertDetail =  await InsertRecordBase(xmlData, 1).ConfigureAwait(false);
            if(insertDetail.Message.Contains("already exists"))
            {
                throw new Exception("Record(s) already exists");
            }

            var result = GetInsertResult(insertDetail.RecordDetail);
            result.Message = insertDetail.Message;
            return result;
        }

        protected async Task<ZohoInsertUpdateDetail> InsertOrUpdateRecordBase(string xmlData)
        {
            var insertDetail = await InsertRecordBase(xmlData, 2).ConfigureAwait(false);
            var result = GetInsertResult(insertDetail.RecordDetail);
            result.Message = insertDetail.Message;
            return result;
        }

        protected async Task<ZohoInsertUpdateDetail> UpdateRecordBase(string id, string xmlData)
        {
            var paras = new Dictionary<string, string>();

            //Set value as true to trigger the workflow rule while inserting record into CRM  
            paras.Add("wfTrigger", "true");
            
            paras.Add("id", id);

            paras.Add("xmlData", xmlData);

            var uri = GetUrl("updateRecords", paras);

            var result = await PostAsync(uri, null).ConfigureAwait(false);

            var updateResult = BasePostResultNormalize(result);
            
            var returnValue = GetInsertResult(updateResult.RecordDetail);
            returnValue.Message = updateResult.Message;

            return returnValue;
        }

        protected async Task<List<GetRecordResult>> GetRelatedRecords(string parentModule, string parentId, int fromIndex = 1, int toIndex = 20)
        {
            var paras = new Dictionary<string, string>();

            paras.Add("parentModule", parentModule);
            paras.Add("id", parentId);

            if (fromIndex >= 1)
            {
                paras.Add("fromIndex", fromIndex.ToString());
            }

            if (toIndex != 20)
            {
                paras.Add("toIndex", toIndex.ToString());
            }

            var uri = GetUrl("getRelatedRecords", paras);

            var result = GetAsync(uri).Result;

            return BaseGetResultNormalize(result);
        }

        protected async Task<List<GetRecordResult>> GetRecordByIdBase(string id)
        {
            var paras = new Dictionary<string, string>();
            paras.Add("id", id);

            var uri = GetUrl("getRecordById", paras);

            var result = await GetAsync(uri).ConfigureAwait(false);

            return BaseGetResultNormalize(result);

        }

       

        protected async Task<bool> DeleteRecordByIdBaseAsync(string id)
        {
            var paras = new Dictionary<string, string>();
            paras.Add("id", id);

            var uri = GetUrl("deleteRecords", paras);

            var result = await GetAsync(uri).ConfigureAwait(false);

            if (result == null)
            {
                throw new Exception("Null object returned from Zoho server");
            }

            if (result.Error != null)
            {
                throw new Exception(string.Format("{0}:{1}", result.Error.Code, result.Error.Message));
            }

            ZohoReqeustError message = result.Result.ToObject<ZohoReqeustError>();

            if(message.Code == "5000")
            {
                return true;
            }

            throw new Exception(string.Format("{0}:{1}", message.Code, message.Message));
        }
        
        protected async Task<List<GetRecordResult>> SearchRecordsBase(string criteria, int fromIndex = 1, int toIndex = 20)
        {
            var paras = new Dictionary<string, string>();
            paras.Add("criteria", criteria);
            
            if (fromIndex >= 1)
            {
                paras.Add("fromIndex", fromIndex.ToString());
            }

            if (toIndex != 20)
            {
                paras.Add("toIndex", toIndex.ToString());
            }

            var uri = GetUrl("searchRecords", paras);

            var result = await GetAsync(uri).ConfigureAwait(false);

            return BaseGetResultNormalize(result);
            
        }

        //if result only have one record, Zoho return as object instead of 
        
        protected async Task<List<GetRecordResult>> GetRecordsBase(int fromIndex = 1, int toIndex = 20)
        {
            var paras = new Dictionary<string, string>();

            if (fromIndex > 1)
            {
                paras.Add("fromIndex", fromIndex.ToString());
            }

            if (toIndex != 20)
            {
                paras.Add("toIndex", toIndex.ToString());
            }

            var uri = GetUrl("getRecords", paras);

            var result = await GetAsync(uri).ConfigureAwait(false);

            return BaseGetResultNormalize(result);

            //if (result.Error != null)
            //{
            //    throw new Exception(string.Format("{0}:{1}", result.Error.Code, result.Error.Message));
            //}
            
            //return (result.Nodata != null || IsNullOrEmpty(result.Result)) ? new List<GetRecordResult>() : GetList<GetRecordResult>(result.Result.First.First.First.First);
        }


        protected string GetZohoFieldXML<T>(T zohoObject, FieldInfo field, string value = "", string prefix = "", string replacedKey = "")
        {
            DescriptionAttribute description;

            if (string.IsNullOrEmpty(value))
            {
                value = field.GetValue(zohoObject).ToString();
            }
            //Type type = field.GetType();

            //if(type.IsClass)
            //{
            //    throw new Exception("Not support object now");
            //}

            //if(field.IsInitOnly)
            //{
            //    return string.Empty;
            //}

            //do not pass

            //do it later
            //if (type != typeof(bool) || type != typeof(Boolean))
            //{

            //    object defaultValue = Activator.CreateInstance(type);
            //    if (value == defaultValue)
            //    {
            //        return string.Empty;
            //    }
            //}
            string name = string.Empty;
            if (string.IsNullOrEmpty(replacedKey))
            {
                description = (DescriptionAttribute)Attribute.GetCustomAttribute(field, typeof(DescriptionAttribute), false);


                if (description != null)
                {
                    name = description.Description;
                }
                else
                {
                    name = field.Name;
                }
            }
            else
            {
                name = replacedKey;
            }

            name = string.Format("{0}{1}", prefix, name);
            

            return string.Format("<FL val=\"{0}\">{1}</FL>", name, value);
        }

        //for enum type
        /// <summary>
        /// Gets the enum description.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="obj">The object.</param>
        /// <returns></returns>
        protected string GetEnumDescription<T>(T obj) where T : IConvertible
        {
            if (!typeof(T).IsEnum)
            {
                return string.Empty;
            }

            var desc = obj.GetType().GetCustomAttributes(typeof(DescriptionAttribute), false);
            return desc.Length > 0 ? ((DescriptionAttribute)desc[0]).Description : string.Empty;
        }


        protected T GetValueFromDescription<T>(string description)
        {
            var type = typeof(T);

            if (!type.IsEnum) throw new InvalidOperationException();

            foreach (var field in type.GetFields())
            {
                var attribute = Attribute.GetCustomAttribute(field,
                    typeof(DescriptionAttribute)) as DescriptionAttribute;
                if (attribute != null)
                {
                    if (attribute.Description == description)
                        return (T)field.GetValue(null);
                }
                else
                {
                    if (field.Name == description)
                        return (T)field.GetValue(null);
                }
            }

            throw new ArgumentException("Not found.", "description");
            // or return default(T);
        }

        /// <summary>
        /// Sets the object property.
        /// This version does not support neast object
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="resultObject">The result object.</param>
        /// <param name="key">The key.</param>
        /// <param name="value">The value.</param>
        protected void SetObjectProperty<T>(T resultObject, string key, string value)
        {
            var fields = typeof(T).GetFields(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance);
            if (fields.Any(x => x.Name.Equals(key, StringComparison.InvariantCultureIgnoreCase)))
            {
                var field = fields.First(x => x.Name.Equals(key, StringComparison.InvariantCultureIgnoreCase));
                if (field.FieldType != typeof(Object))
                {
                    
                    if(field.FieldType.IsEnum)
                    {
                       
                        field.SetValue(resultObject, GetEnumValue(field.FieldType, value));
                    }
                    else
                    {
                        field.SetValue(resultObject, Convert.ChangeType(value, field.FieldType));
                    }
                    
                }
            }
            else
            {
                DescriptionAttribute description;
                foreach (var f in fields)
                {
                    description = (DescriptionAttribute)Attribute.GetCustomAttribute(f, typeof(DescriptionAttribute), false);
                    if (description != null && description.Description.Equals(key, StringComparison.InvariantCultureIgnoreCase))
                    {
                        if (f.FieldType != typeof(Object))
                        {
                            if (f.FieldType.IsEnum)
                            {
                                f.SetValue(resultObject, GetEnumValue(f.FieldType, value));
                            }
                            else
                            {
                                f.SetValue(resultObject, Convert.ChangeType(value, f.FieldType));
                            }
                            //f.SetValue(resultObject, Convert.ChangeType(value, f.FieldType));
                            break;
                        }
                    }
                }
            }
        }

        private async Task<ZohoInsertResult> InsertRecordBase(string xmlData, int duplicateCheck)
        {
            var paras = new Dictionary<string, string>();

            //Set value as true to trigger the workflow rule while inserting record into CRM  
            paras.Add("wfTrigger", "true");

            //Set value as "1" to check the duplicate records and throw an error response 
            //"2" to check the duplicate records, if exists, update the same.
            paras.Add("duplicateCheck", duplicateCheck.ToString());

            paras.Add("xmlData", xmlData);

            var uri = GetUrl("insertRecords", paras);

            var result = await PostAsync(uri, null).ConfigureAwait(false);

            return BasePostResultNormalize(result);

            //return (result == null || result.Result == null) ? null : result.Result.ToObject<ZohoInsertResult>();

        }

        private object GetEnumValue(Type type, string description)
        {
            
            if (!type.IsEnum) throw new InvalidOperationException();

            foreach (var field in type.GetFields())
            {
                var attribute = Attribute.GetCustomAttribute(field,
                    typeof(DescriptionAttribute)) as DescriptionAttribute;
                if (attribute != null)
                {
                    if (attribute.Description == description)
                        return field.GetValue(null);
                }
                else
                {
                    if (field.Name == description)
                        return field.GetValue(null);
                }
            }

            throw new ArgumentException("Not found.", "description");
        }

        private ZohoInsertUpdateDetail GetInsertResult(GetRecordResult insertResult)
        {
            var result = new ZohoInsertUpdateDetail();

            foreach(var r in insertResult.Fields)
            {
                SetObjectProperty<ZohoInsertUpdateDetail>(result, r.Value, r.Content);
            }

            return result;
        }


        private ZohoInsertResult BasePostResultNormalize(ZohoResult result)
        {
            if (result == null)
            {
                throw new Exception("Null object returned from Zoho server");
            }

            if (result.Error != null)
            {
                throw new Exception(string.Format("{0}:{1}", result.Error.Code, result.Error.Message));
            }

            if(result.Result == null)
            {
                throw new Exception(string.Format("{0}", "Zohho result object is null"));
            }

            return result.Result.ToObject<ZohoInsertResult>();
        }

        private List<GetRecordResult> BaseGetResultNormalize(ZohoResult result)
        {
            if(result == null)
            {
                throw new Exception("Null object returned from Zoho server");
            }

            if (result.Error != null)
            {
                throw new Exception(string.Format("{0}:{1}", result.Error.Code, result.Error.Message));
            }

            return (result.Nodata != null || IsNullOrEmpty(result.Result)) ? new List<GetRecordResult>() : GetList<GetRecordResult>(result.Result.First.First.First.First);
        }


        private List<T> GetList<T>(JToken token)
        {

            return token.Type == JTokenType.Array ? token.ToObject<List<T>>() :
                new List<T>() { token.ToObject<T>() };
        }

        private bool IsNullOrEmpty(JToken token)
        {
            return (token == null) ||
                   (token.Type == JTokenType.Array && !token.HasValues) ||
                   (token.Type == JTokenType.Object && !token.HasValues) ||
                   (token.Type == JTokenType.String && token.ToString() == String.Empty) ||
                   (token.Type == JTokenType.Null);
        }

    }
}
