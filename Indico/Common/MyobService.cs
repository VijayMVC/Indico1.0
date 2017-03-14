
//using System;
//using System.Collections.Generic;
//using System.Diagnostics;
//using System.IO;
//using System.Linq;
//using System.Net;
//using System.Text;
//using System.Windows.Forms;
//using Indico.BusinessObjects;
//using MYOB.AccountRight.SDK;
//using MYOB.AccountRight.SDK.Contracts;
//using MYOB.AccountRight.SDK.Contracts.Version2;
//using MYOB.AccountRight.SDK.Contracts.Version2.Contact;
//using MYOB.AccountRight.SDK.Contracts.Version2.GeneralLedger;
//using MYOB.AccountRight.SDK.Contracts.Version2.Inventory;
//using MYOB.AccountRight.SDK.Contracts.Version2.Sale;
//using MYOB.AccountRight.SDK.Services;
//using MYOB.AccountRight.SDK.Services.Contact;
//using MYOB.AccountRight.SDK.Services.GeneralLedger;
//using MYOB.AccountRight.SDK.Services.Inventory;
//using MYOB.AccountRight.SDK.Services.Sale;
//using Newtonsoft.Json;
//using Item = MYOB.AccountRight.SDK.Contracts.Version2.Inventory.Item;
//using System.Threading.Tasks;

//namespace Indico.Common
//{
//    /// <summary>
//    /// this class helps to save entities in the my ob service
//    /// </summary>
//    public class MyobService
//    {
//        #region Fields

//        private static Account _incomeAccount;
//        private static Account _assetAccount;
//        private static Account _costOfSaleAccount;
//        private static IApiConfiguration _configuration;
//        private static CompanyFile _companyFile;
//        private static SimpleOAuthKeyService _keyStore;

//        #endregion

//        #region Public Methods

//        /// <summary>
//        /// save visual layout as an Inventory Item
//        /// </summary>
//        /// <param name="visualLayoutId">id of the visual layout to be saved</param>
//        public void SaveVisualLayout(int visualLayoutId)
//        {
//            Task.Factory.StartNew(() =>
//            {
//                try
//                {
//                    var objVl = new VisualLayoutBO {ID = visualLayoutId};
//                    objVl.GetObject();
//                    if (!SetupAuth())
//                        throw new Exception("Cannot Setup Authentication for myob");
//                    var itemService = new ItemService(_configuration, null, _keyStore);
//                    var number = (objVl.NamePrefix).Trim();
//                    var myobVl = itemService.GetRange(_companyFile, "$filter=Number eq '" + number + "'", null).Items.FirstOrDefault();
//                    if (!SetUpAccounts())
//                        throw new Exception("Cannot Setup Accounts");
//                    var gstTaxCode = GetTaxCode(_configuration, _companyFile, _keyStore);

//                    if (gstTaxCode == null)
//                        return;
//                    var itemSubCat = objVl.objPattern.objSubItem.Name;
//                    var distributor = objVl.objClient.objClient.objDistributor.Name;
//                    var client = objVl.objClient.objClient.Name;
//                    var jobName = objVl.objClient.Name;
//                    var patternCode = objVl.objPattern.Number;
//                    var ageGroup = objVl.objPattern.objAgeGroup.Name;
//                    var imagepath = IndicoPage.GetVLImagePath(objVl.ID);
//                    var item = new Item
//                    {
//                        Number = objVl.NamePrefix,
//                        Name = itemSubCat,
//                        CostOfSalesAccount = new AccountLink {UID = _costOfSaleAccount.UID},
//                        IncomeAccount = new AccountLink {UID = _incomeAccount.UID},
//                        AssetAccount = new AccountLink {UID = _assetAccount.UID},
//                        IsBought = true,
//                        IsInventoried = true,
//                        IsSold = true,
//                        UseDescription = true,
//                        Description = string.Format("{0}, {1} , # {2} {3}", itemSubCat, jobName ?? client, patternCode, ageGroup),
//                        CustomField1 = new Identifier {Label = "Distributor", Value = distributor != null ? distributor.Substring(0, Math.Min(distributor.Length, 30)) : ""},
//                        CustomField2 = new Identifier {Label = "Client", Value = client != null ? client.Substring(0, Math.Min(client.Length, 30)) : ""},
//                        CustomField3 = new Identifier {Label = "Job Name", Value = jobName != null ? jobName.Substring(0, Math.Min(jobName.Length, 30)) : ""},
//                        BuyingDetails = new ItemBuyingDetails
//                        {
//                            BuyingUnitOfMeasure = "Each",
//                            ItemsPerBuyingUnit = 1,
//                            LastPurchasePrice = 0,
//                            TaxCode = GetTaxCodeLink(gstTaxCode)
//                        },
//                        SellingDetails = new ItemSellingDetails
//                        {
//                            BaseSellingPrice = 0,
//                            CalculateSalesTaxOn = CalculateSalesTaxOn.LevelA,
//                            IsTaxInclusive = true,
//                            ItemsPerSellingUnit = 1,
//                            PriceMatrixURI = null,
//                            SellingUnitOfMeasure = "Each",
//                            TaxCode = GetTaxCodeLink(gstTaxCode)
//                        },
//                        UID = (myobVl != null) ? myobVl.UID : Guid.NewGuid(),
//                        RowVersion = (myobVl != null) ? myobVl.RowVersion : "1",
//                        PhotoURI = !string.IsNullOrWhiteSpace(imagepath) ? new Uri("http://gw.indiman.net/" + imagepath) : null
//                    };
//                    if (myobVl == null)
//                        itemService.InsertEx(_companyFile, item, null, (sc, str, i) => { }, OnItemInsertError);
//                    else if (!myobVl.Equals(item))
//                    {
//                        itemService.UpdateEx(_companyFile, item, null, (sc, str, i) => { }, OnItemInsertError);
//                    }
//                }
//                catch (Exception exception)
//                {
//                    IndicoLogging.log.ErrorFormat("an error occurred when trying to save the visual layout ({0}) in Myob.\n\nException : -{1}", visualLayoutId, exception.Message);
//                }
//            });

//        }

//        /// <summary>
//        /// save address as Customer
//        /// </summary>
//        /// <param name="addressIds"></param>
//        public void SaveAddress(int addressIds)
//        {

//            try
//            {
//                if (addressIds < 1)
//                    return;
//                var address = new DistributorClientAddressBO {ID = addressIds};
//                address.GetObject();
//                if (!SetupAuth())
//                    throw new Exception("Cannot Setup Authentication for myob");
//                var addresses = new List<Address>
//                {
//                    new Address
//                    {
//                        Location = 0,
//                        Country = address.objCountry.ShortName,
//                        PostCode = address.PostCode,
//                        ContactName = address.ContactName,
//                        State = address.State,
//                        Street = address.Address,
//                        City = address.Suburb
//                    }
//                };
//                var gstTaxCode = GetTaxCode(_configuration, _companyFile, _keyStore);
//                if (gstTaxCode == null)
//                    return;
//                var gst = GetTaxCodeLink(gstTaxCode);
//                var customerService = new CustomerService(_configuration, null, _keyStore);
//                var myobCustomer = customerService.GetRange(_companyFile,
//                    string.Format("$filter = DisplayID eq '{0}'", address.ID), null).Items.FirstOrDefault();
//                var customer = new Customer
//                {
//                    CompanyName = address.CompanyName,
//                    Addresses = addresses,
//                    DisplayID = address.ID.ToString(),
//                    IsActive = true,
//                    SellingDetails = new CustomerSellingDetails {TaxCode = gst, FreightTaxCode = gst},
//                    RowVersion = myobCustomer == null ? "1" : myobCustomer.RowVersion,
//                    UID = myobCustomer == null ? Guid.NewGuid() : myobCustomer.UID
//                };
//                if (myobCustomer == null)
//                {
//                    customerService.InsertEx(_companyFile, customer, null, (sc, str, a) =>
//                    {
                            
//                    }, OnItemInsertError);
//                }
                        
//                else if (!myobCustomer.Equals(customer))
//                    customerService.UpdateEx(_companyFile, customer, null, (sc, str, cus) => { }, OnItemInsertError);
//            }
//            catch (Exception exception)
//            {
//                IndicoLogging.log.ErrorFormat("an error occurred when trying to save the Address ({0}) in Myob.\n\nException : -{1}", addressIds, exception.Message);
//            }
//        }

//        /// <summary>
//        /// save order as item order (sales)
//        /// </summary>
//        /// <param name="orderId"></param>
//        public void SaveOrder(int orderId)
//        {
//            Task.Factory.StartNew(() =>
//            {
//                try
//                {
//                    if (orderId < 1)
//                        return;
//                    if (!SetupAuth())
//                        throw new Exception("Cannot Setup Authentication for myob");
//                    var indicoOrder = new OrderBO {ID = orderId};
//                    if (!indicoOrder.GetObject())
//                        throw new Exception(string.Format("No Order Associated with the order ID {0}.", orderId));
//                    var itemOrder = new ItemOrder();
//                    var customerService = new CustomerService(_configuration, null, _keyStore);
//                    var customerBo = indicoOrder.objBillingAddress;
//                    var customer = GetCustomer(customerBo.ID.ToString(), customerService) ?? SaveCustomer(customerBo, customerService); // get customer . if not available then save the customer
//                    if (customer == null)
//                        throw new Exception(string.Format("Cannot Save Customer ({0}) in my ob ", customerBo.ID));
//                    itemOrder.Customer = new CustomerLink {DisplayID = customer.DisplayID, Name = customer.CompanyName, UID = customer.UID}; //set customer
//                    var orderDetails = (from od in indicoOrder.OrderDetailsWhereThisIsOrder
//                        where od.objOrder.ID == orderId
//                        select new
//                        {
//                            VLName = od.objVisualLayout.NamePrefix.Trim(),
//                            VLID = od.objVisualLayout.ID,
//                            Quantity = od.OrderDetailQtysWhereThisIsOrderDetail.Select(m => m.Qty).Sum(),
//                            od.EditedPrice
//                        }).ToList();
//                    var lines = new List<ItemOrderLine>();
//                    var gstTaxCode = GetTaxCode(_configuration, _companyFile, _keyStore);
//                    var gstTaxCodeLink = new TaxCodeLink {Code = gstTaxCode.Code, UID = gstTaxCode.UID};
//                    var itemService = new ItemService(_configuration, null, _keyStore);
//                    foreach (var od in orderDetails)
//                    {
//                        var vl = GetItem(od.VLName) ?? SaveItem(od.VLID, gstTaxCode, itemService, od.Quantity);
//                        if (vl == null)
//                            throw new Exception("Cannot Update / Insert Item (Visual Layout to Myob)  VLID : " + od.VLID);
//                        lines.Add(new ItemOrderLine
//                        {
//                            Item = new ItemLink
//                            {
//                                Name = vl.Name,
//                                Number = vl.Number,
//                                UID = vl.UID
//                            },
//                            TaxCode = gstTaxCodeLink,
//                            ShipQuantity = od.Quantity,
//                            Type = OrderLineType.Transaction,
//                            UnitPrice = od.EditedPrice.GetValueOrDefault(),
//                            Total = od.EditedPrice.GetValueOrDefault()*od.Quantity,

//                        });
//                    }
//                    itemOrder.Lines = lines.ToArray();
//                    itemOrder.IsTaxInclusive = true;
//                    itemOrder.FreightTaxCode = GetTaxCodeLink(gstTaxCode);
//                    itemOrder.Date = indicoOrder.Date;
//                    var itemOrderService = new ItemOrderService(_configuration, null, _keyStore);
//                    itemOrderService.Insert(_companyFile, itemOrder, null);
//                }
//                catch (Exception exception)
//                {
//                    IndicoLogging.log.ErrorFormat("an error occurred when trying to save the Order ({0}) in Myob.\n\nException : -{1}", orderId, exception.Message);
//                }
//            });
//        }

//        #endregion

//        #region Private Methods

//        private bool SetupAuth()
//        {
//            try
//            {
//                if(_configuration==null)
//                    _configuration = GetConfiguration();
//                if(_keyStore==null)
//                    _keyStore = GetKeyStore(GetTokens());
//                if(_companyFile==null)
//                    _companyFile = _companyFile ?? GetCompanyFile(_configuration, _keyStore);
//                return _configuration != null && _keyStore != null && _companyFile != null;
//            }
//            catch (Exception)
//            {
//                return false;
//            }
//        }

//        private bool SetUpAccounts(AccountService accountService = null)
//        {
//            accountService = accountService ?? new AccountService(_configuration, null, _keyStore);
//            try
//            {
//                if(_incomeAccount==null)
//                    _incomeAccount =  accountService.GetRange(_companyFile, string.Format("$filter=Number eq {0} and Type eq 'Income'", IndicoConfiguration.AppConfiguration.MyobItemIncomeAccountNumber), null).Items.FirstOrDefault();
//                if(_assetAccount==null)
//                    _assetAccount =  accountService.GetRange(_companyFile, string.Format("$filter=Number eq {0} and Type eq 'OtherAsset'", IndicoConfiguration.AppConfiguration.MyobItemAssetAccountNumber), null).Items.FirstOrDefault();
//                if(_costOfSaleAccount==null)
//                    _costOfSaleAccount = _costOfSaleAccount ?? accountService.GetRange(_companyFile, string.Format("$filter=Number eq {0} and Type eq 'CostOfSales'", IndicoConfiguration.AppConfiguration.MyobItemCostOfSaleAccounNumber), null).Items.FirstOrDefault();
//                return _incomeAccount != null && _assetAccount != null && _costOfSaleAccount != null;
//            }
//            catch (Exception)
//            {
//                return false;
//            }
//        }

//        private void OnItemInsertError(Uri uri, Exception exception)
//        {
//            switch (exception.GetType().Name)
//            {
//                case "WebException":
//                    Debug.Write(string.Format("Cannot save/update Myob. Error :\n{0}", FormatMessage((WebException)exception)));
//                    break;
//                case "ApiCommunicationException":
//                    MessageBox.Show(FormatMessage((WebException)exception.InnerException));
//                    break;
//                case "ApiOperationException":
//                    MessageBox.Show(exception.Message);
//                    break;
//                default:
//                    MessageBox.Show(exception.Message);
//                    break;
//            }
//        }

//        private string FormatMessage(WebException webEx)
//        {
//            var responseText = new StringBuilder();
//            responseText.AppendLine(webEx.Message);
//            responseText.AppendLine();
//            var response = webEx.Response;
//            var receiveStream = response.GetResponseStream();
//            var encode = Encoding.GetEncoding("utf-8");
//            if (receiveStream == null)
//                return "";
//            var readStream = new StreamReader(receiveStream, encode);
//            var read = new Char[257];
//            var count = readStream.Read(read, 0, 256);
//            responseText.AppendLine("HTML...");

//            while (count > 0)
//            {
//                var str = new String(read, 0, count);
//                responseText.Append(str);
//                count = readStream.Read(read, 0, 256);
//            }
//            responseText.Append("");
//            readStream.Close();
//            response.Close();
//            return responseText.ToString();
//        }

//        private OAuthTokens GetTokens()
//        {
//            var httpWReq =
//                (HttpWebRequest)WebRequest.Create(IndicoConfiguration.AppConfiguration.MyobOAuthUrl);

//            var postdata = new StringBuilder()
//                .Append(string.Format("client_id={0}", IndicoConfiguration.AppConfiguration.MyobClientId))
//                .Append(string.Format("&client_secret={0}", IndicoConfiguration.AppConfiguration.MyobClientSecret))
//                .Append(string.Format("&scope={0}", IndicoConfiguration.AppConfiguration.MyobScope))
//                .Append(string.Format("&username={0}", IndicoConfiguration.AppConfiguration.MyobUsername))
//                .Append(string.Format("&password={0}", IndicoConfiguration.AppConfiguration.MyobPassword))
//                .Append("&grant_type=password").ToString();
//            var encoding = new UTF8Encoding();
//            var data = encoding.GetBytes(postdata);

//            httpWReq.Method = "POST";
//            httpWReq.ContentType = "application/x-www-form-urlencoded";
//            httpWReq.ContentLength = data.Length;

//            using (var stream = httpWReq.GetRequestStream())
//            {
//                stream.Write(data, 0, data.Length);
//            }

//            var response = (HttpWebResponse)httpWReq.GetResponse();
//            var responseStream = response.GetResponseStream();
//            if (responseStream == null)
//                return null;
//            var reader = new StreamReader(responseStream);
//            var jsonresponse = "";
//            string temp;
//            while ((temp = reader.ReadLine()) != null)
//            {
//                jsonresponse += temp;
//            }
//            var jsondata = JsonConvert.DeserializeObject<Dictionary<string, object>>(jsonresponse);
//            var accessToken = jsondata["access_token"];
//            var expiresIn = jsondata["expires_in"];
//            var refreshToken = jsondata["refresh_token"];

//            var tokens = new OAuthTokens
//            {
//                AccessToken = (string)accessToken,
//                ExpiresIn = Int32.Parse((string)expiresIn),
//                RefreshToken = (string)refreshToken
//            };
//            return tokens;
//        }


//        private TaxCode GetTaxCode(IApiConfiguration config, CompanyFile companyFile, IOAuthKeyService keyStore, string code = "GST")
//        {
//            var taxCodeService = new TaxCodeService(config, null, keyStore);
//            var taxCode =
//               taxCodeService.GetRange(companyFile, string.Format("$filter=Code eq '{0}'", code), null).Items.FirstOrDefault();
//            return taxCode;
//        }

//        private TaxCodeLink GetTaxCodeLink(TaxCode taxCode)
//        {
//            if (taxCode != null)
//            {
//                return new TaxCodeLink
//                {
//                    Code = taxCode.Code,
//                    UID = taxCode.UID
//                };
//            }
//            return null;
//        }

//        private ApiConfiguration GetConfiguration()
//        {
//            return new ApiConfiguration(IndicoConfiguration.AppConfiguration.MyoBDeveloperKey,
//                     IndicoConfiguration.AppConfiguration.MyoBDeveloperSecretKey, "http://gw.indiman.net/");
//        }

//        private SimpleOAuthKeyService GetKeyStore(OAuthTokens tokens)
//        {
//            return new SimpleOAuthKeyService { OAuthResponse = tokens };
//        }

//        private CompanyFile GetCompanyFile(IApiConfiguration config, SimpleOAuthKeyService keyservice)
//        {
//            var companyFileService = new CompanyFileService(config, null, keyservice);
//            return companyFileService.GetRange(string.Format("$filter = Name eq '{0}'",
//                    IndicoConfiguration.AppConfiguration.MyObCompanyFile)).Last();
//        }

//        private Customer GetCustomer(string displayId, CustomerService customerservice = null)
//        {
//            var customerService = customerservice ?? new CustomerService(_configuration, null, _keyStore);
//            var customer = customerService.GetRange(_companyFile, string.Format("$filter = DisplayID eq '{0}'", displayId), null).Items.FirstOrDefault();
//            return customer;
//        }

//        private Customer SaveCustomer(DistributorClientAddressBO address, CustomerService customerservice = null, TaxCode gsttaxCode = null)
//        {
//            try
//            {
//                var addresses = new List<Address>
//                {
//                    new Address
//                    {
//                        Location = 0,
//                        Country = address.objCountry.ShortName,
//                        PostCode = address.PostCode,
//                        ContactName = address.ContactName,
//                        State = address.State,
//                        Street = address.Address,
//                        City = address.Suburb
//                    }
//                };
//                var gstTaxCode = gsttaxCode ?? GetTaxCode(_configuration, _companyFile, _keyStore);
//                if (gstTaxCode == null)
//                    return null;
//                var gst = GetTaxCodeLink(gstTaxCode);
//                var customerService = customerservice ?? new CustomerService(_configuration, null, _keyStore);
//                var customer = new Customer
//                {
//                    CompanyName = address.CompanyName,
//                    Addresses = addresses,
//                    DisplayID = address.ID.ToString(),
//                    IsActive = true,
//                    SellingDetails = new CustomerSellingDetails {TaxCode = gst, FreightTaxCode = gst},
//                    RowVersion = "1",
//                    UID = Guid.NewGuid()
//                };
//               customerService.Insert(_companyFile, customer, null);
//                return customer;
//            }
//            catch (Exception)
//            {
//                return null;
//            }
//        }

//        private Item GetItem(string id, ItemService itemservice = null)
//        {
//            try
//            {
//                var itemService = itemservice ?? new ItemService(_configuration, null, _keyStore);
//                return itemService.GetRange(_companyFile, "$filter=Number eq '" + id + "'", null).Items.FirstOrDefault();
//            }
//            catch (Exception)
//            {
//                return null;
//            }
//        }

//        private Item SaveItem(int vlId, TaxCode gsttaxCode = null, ItemService itemservice = null, double quantity = -1)
//        {
//            try
//            {
//                var vl = new VisualLayoutBO { ID = vlId };
//                if (!vl.GetObject())
//                    return null;
//                var itemService = itemservice ?? new ItemService(_configuration, null, _keyStore);
//                if (!SetUpAccounts())
//                    throw new Exception("Cannot Setup Accounts");
//                var gstTaxCode = gsttaxCode ?? GetTaxCode(_configuration, _companyFile, _keyStore);
//                if (gstTaxCode == null)
//                    return null;
//                var itemSubCat = vl.objPattern.objSubItem.Name;
//                var distributor = vl.objClient.objClient.objDistributor.Name;
//                var client = vl.objClient.objClient.Name;
//                var jobName = vl.objClient.Name;
//                var patternCode = vl.objPattern.Number;
//                var ageGroup = vl.objPattern.objAgeGroup.Name;
//                var imagepath = IndicoPage.GetVLImagePath(vl.ID);
//                var item = new Item
//                {
//                    Number = vl.NamePrefix,
//                    Name = itemSubCat,
//                    CostOfSalesAccount = new AccountLink { UID = _costOfSaleAccount.UID },
//                    IncomeAccount = new AccountLink { UID = _incomeAccount.UID },
//                    AssetAccount = new AccountLink { UID = _assetAccount.UID },
//                    IsBought = true,
//                    IsInventoried = true,
//                    IsSold = true,
//                    Created = DateTime.Now,
//                    UseDescription = true,
//                    Description = string.Format("{0}, {1} , # {2} {3}", itemSubCat, jobName ?? client, patternCode, ageGroup),
//                    CustomField1 = new Identifier { Label = "Distributor", Value = distributor != null ? distributor.Substring(0, Math.Min(distributor.Length, 30)) : "" },
//                    CustomField2 = new Identifier { Label = "Client", Value = client != null ? client.Substring(0, Math.Min(client.Length, 30)) : "" },
//                    CustomField3 = new Identifier { Label = "Job Name", Value = jobName != null ? jobName.Substring(0, Math.Min(jobName.Length, 30)) : "" },
//                    BuyingDetails = new ItemBuyingDetails
//                    {
//                        BuyingUnitOfMeasure = "Each",
//                        ItemsPerBuyingUnit = 1,
//                        LastPurchasePrice = 0,
//                        TaxCode = GetTaxCodeLink(gsttaxCode)
//                    },
//                    SellingDetails = new ItemSellingDetails
//                    {
//                        BaseSellingPrice = 0,
//                        CalculateSalesTaxOn = CalculateSalesTaxOn.LevelA,
//                        IsTaxInclusive = true,
//                        ItemsPerSellingUnit = 1,
//                        PriceMatrixURI = null,
//                        SellingUnitOfMeasure = "Each",
//                        TaxCode = GetTaxCodeLink(gstTaxCode)
//                    },

//                    UID =Guid.NewGuid(),
//                    RowVersion = "1",
//                    PhotoURI = !string.IsNullOrWhiteSpace(imagepath) ? new Uri("http://gw.indiman.net/" + imagepath) : null,
//                    QuantityOnHand = quantity
//                };
//                itemService.Insert(_companyFile, item, null);
//                return item;
//            }
//            catch (Exception)
//            {
//                return null;
//            }
//        }
//        #endregion
//    }
//}