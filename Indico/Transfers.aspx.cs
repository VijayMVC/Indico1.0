using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web.UI.WebControls;
using Indico.Common;
using System.Data.SqlClient;
using System.Linq;
using System.Windows.Forms;
using Dapper;
using Indico.BusinessObjects;
using Telerik.Web.UI;

namespace Indico
{
    public partial class Transfers : IndicoPage
    {
        #region Properties

        private SqlConnection Connection { get { return new SqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString); } }
        
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
                return;
            HearText.Text = "Transfer Job Names And Products";
            PopulateControls();
        }

        #region Event handlers



        protected void OnFromDistributorDistributorDropDownChanged(object sender, EventArgs e)
        {
            var selectedDistributorId = int.Parse(FromDistributorDistributorDropDown.SelectedValue);
            if (selectedDistributorId < 1)
                return;

            var distributors = GetAllDistributors().Where(d=>d.Key!=selectedDistributorId).ToList();

            if (distributors.Count < 1)
                return;

            ToDistributorDistributorDropDown.Items.Add(new ListItem("Select distributor", "0"));
            foreach (var dis in distributors)
                ToDistributorDistributorDropDown.Items.Add(new ListItem(dis.Value, dis.Key.ToString()));

            ToDistributorDistributorDropDown.Enabled = true;
                     
        }

        protected void OnToDistributorDistributorDropDownChanged(object sender, EventArgs e)
        {

            var selectedDistributorId = int.Parse(ToDistributorDistributorDropDown.SelectedValue);
            if (selectedDistributorId < 1)
                return;

            TransferDistributoButton.Enabled = true;
            
        }


        protected void OnTransferDistributoButtonClick(object sender,EventArgs e)
        {
            var fromDistributor = int.Parse(FromDistributorDistributorDropDown.SelectedValue);
            var toDistributor = int.Parse(ToDistributorDistributorDropDown.SelectedValue);

            if (fromDistributor < 1 || toDistributor < 1)
                return;

            TransferDistributor(fromDistributor, toDistributor);
            ToDistributorDistributorDropDown.Items.Clear();
            ToDistributorDistributorDropDown.Enabled = false;
            FromDistributorDistributorDropDown.SelectedIndex = 0;
        }


        protected void OnFromDistributorDropDownSelectionChanged(object sender, EventArgs e)
        {
            var selectedDistributorId = int.Parse(FromDistributorDropDown.SelectedValue);
            if (selectedDistributorId < 1)
                return;
            var jobNames = GetJobNamesForDistributor(selectedDistributorId);

            if (jobNames.Count <= 0)
                return;
            JobNameDropDown.Items.Clear();
            JobNameDropDown.Items.Add(new ListItem("Select Job name", 0.ToString()));
            foreach (var jobName in jobNames)
            {
                JobNameDropDown.Items.Add(new ListItem(jobName.Value, jobName.Key.ToString()));
            }
            JobNameDropDown.Enabled = true;
        }



        protected void OnJobNameDropDownSelectionChanged(object sender, EventArgs e)
        {
            var selectedJobName = int.Parse(JobNameDropDown.SelectedValue);
            if (selectedJobName < 1)
                return;
            var selectedFromDistributor = int.Parse(FromDistributorDropDown.SelectedValue);
            if (selectedFromDistributor < 1)
                return;
            var distributors = GetAllDistributors().Where(d => d.Key != selectedFromDistributor).ToList();
            if (distributors.Count < 1)
                return;
            ToDistributorDropDown.Items.Add(new ListItem("Select distributor", "0"));
            foreach (var distributor in distributors)
                ToDistributorDropDown.Items.Add(new ListItem(distributor.Value, distributor.Key.ToString()));
            ToDistributorDropDown.Enabled = true;
        }

        protected void OnToDistributorDropDownSelectionChanged(object sender, EventArgs e)
        {
            var selectedDistributor = int.Parse(ToDistributorDropDown.SelectedValue);
            if (selectedDistributor < 1)
                return;
            TransferJobNameButton.Enabled = true;
        }

        protected void OnTransferJobNameButtonClick(object sender, EventArgs e)
        {
            var jobName = int.Parse(JobNameDropDown.SelectedValue);
            var toDistributor = int.Parse(ToDistributorDropDown.SelectedValue);
            try
            {
                TransferJobName(jobName, toDistributor);
            }
            catch (Exception)
            {
                IndicoLogging.log.ErrorFormat("Unable to transferJob Name to a distributor Job Name : {0}, Distributor : {1}", jobName, toDistributor);
            }

            PopulateControls();
        }

        protected void OnFromJobNameDropDownSelectionChanged(object sender, EventArgs e)
        {
            var selectedJobName = int.Parse(FromJobNameDropDown.SelectedValue);
            if (selectedJobName < 1)
                return;

            var products = GetProductsForJobName(selectedJobName);
            if (products.Count < 1)
                return;
            ProductsListBox.Items.Clear();
            foreach (var product in products)
            {
                ProductsListBox.Items.Add(new RadListBoxItem("  "+product.Value, product.Key.ToString()));
            }

            var distributors = GetAllDistributors();
            if (distributors.Count < 1)
                return;
            ToDistributorVlDropDown.Items.Clear();
            ToDistributorVlDropDown.Items.Add(new ListItem("Select distributor", "0"));
            foreach (var distributor in distributors)
            {
                ToDistributorVlDropDown.Items.Add(new ListItem(distributor.Value, distributor.Key.ToString()));
                ToDistributorVlDropDown.Enabled = true;
            }
        }

        protected void OnToJobNameDropDownSelectionChanged(object sender, EventArgs e)
        {
            var selectedJobName = int.Parse(ToJobNameDropDown.SelectedValue);
            if (selectedJobName < 1)
                return;
            TransferProductsButton.Enabled = true;
        }

        protected void OnTransferProductsButtonClick(object sender, EventArgs e)
        {
            var selected = ProductsListBox.CheckedItems;
            var selectedJobName = int.Parse(ToJobNameDropDown.SelectedValue);
            if (selected.Count < 1)
                return;
            foreach (var product in selected)
            {
                try
                {
                    TransferProduct(int.Parse(product.Value), selectedJobName);
                }
                catch (Exception)
                {
                    IndicoLogging.log.ErrorFormat("Unable to transfer Visual Layout to a Job Name.  visual layout : {0}, Distributor : {1}", product.Value, selectedJobName);
                }

            }

            FromJobNameDropDown.Items.Clear();
            FromJobNameDropDown.Enabled = false;

            ProductsListBox.Items.Clear();
            ToDistributorVlDropDown.Items.Clear();
            ToDistributorVlDropDown.Enabled = false;
            ToJobNameDropDown.Items.Clear();
            ToJobNameDropDown.Enabled = false;
            TransferProductsButton.Enabled = false;
            FromDistributorVlDropDown.SelectedIndex = 0;

        }

        protected void OnToDistributorVlDropDownSelectionChanged(object sender, EventArgs e)
        {

            var selectedDistributorId = int.Parse(ToDistributorVlDropDown.SelectedValue);
            if (selectedDistributorId < 1)
                return;
            var selectedJobName = int.Parse(FromJobNameDropDown.SelectedValue);
            var jobNames = GetJobNamesForDistributor(selectedDistributorId).Where(p => p.Key != selectedJobName).ToList();

            if (jobNames.Count <= 0)
                return;
            ToJobNameDropDown.Items.Clear();
            ToJobNameDropDown.Items.Add(new ListItem("Select Job name", 0.ToString()));
            foreach (var jobName in jobNames)
            {
                ToJobNameDropDown.Items.Add(new ListItem(jobName.Value, jobName.Key.ToString()));
            }
            ToJobNameDropDown.Enabled = true;
        }

        protected void OnFromDistributorVlDropDownSelectionChanged(object sender, EventArgs e)
        {
            var selectedDistributorId = int.Parse(FromDistributorVlDropDown.SelectedValue);
            if (selectedDistributorId < 1)
                return;
            var jobNames = GetJobNamesForDistributorForProduct(selectedDistributorId);

            if (jobNames.Count <= 0)
                return;
            FromJobNameDropDown.Items.Clear();
            FromJobNameDropDown.Items.Add(new ListItem("Select Job name", 0.ToString()));
            foreach (var jobName in jobNames)
            {
                FromJobNameDropDown.Items.Add(new ListItem(jobName.Value, jobName.Key.ToString()));
            }
            FromJobNameDropDown.Enabled = true;
        }

        #endregion

        #region Methods

        private void PopulateControls()
        {
            FromDistributorDropDown.Items.Clear();
            FromDistributorVlDropDown.Items.Clear();
            FromDistributorDropDown.Items.Add(new ListItem("Select Distributor", 0.ToString()));
            FromDistributorVlDropDown.Items.Add(new ListItem("Select Distributor", 0.ToString()));
            FromDistributorDistributorDropDown.Items.Add(new ListItem("Select Distributor", 0.ToString()));

            var distributors = GetAllDistributors();
            foreach (var distributor in distributors)
            {
                FromDistributorDropDown.Items.Add(new ListItem(distributor.Value, distributor.Key.ToString()));
                FromDistributorDistributorDropDown.Items.Add(new ListItem(distributor.Value, distributor.Key.ToString()));
            }


            distributors = GetAllDistributorsForProduct();
            foreach (var distributor in distributors)
            {
                FromDistributorVlDropDown.Items.Add(new ListItem(distributor.Value, distributor.Key.ToString()));
            }

            JobNameDropDown.Enabled = false;
            JobNameDropDown.Items.Clear();
            ToDistributorDropDown.Enabled = false;
            ToDistributorDropDown.Items.Clear();
            TransferJobNameButton.Enabled = false;
            FromJobNameDropDown.Enabled = false;
            TransferProductsButton.Enabled = false;
            ToDistributorVlDropDown.Enabled = false;
            ToJobNameDropDown.Enabled = false;
            TransferDistributoButton.Enabled = false;
        }

        /// <summary>
        /// Returns all distributors that have 1 or more job names and clients ordered by name as dictionary
        /// </summary>
        /// <returns></returns>
        private Dictionary<int, string> GetAllDistributors(int excludeJobName = 0)
        {
            using (var connection = Connection)
            {
                var query = string.Format(@"SELECT 
                                        co.Name AS Value
                                        ,co.ID AS [Key] 
                                        FROM [dbo].[Company] co
                                            INNER JOIN [dbo].[Client] cl
                                                ON cl.Distributor = co.ID
                                            INNER JOIN [dbo].[JobName] jn
                                                ON jn.Client = cl.ID
                                        {0}
                                    GROUP BY co.Name,co.ID
                                    ORDER BY co.Name", excludeJobName > 0 ? "WHERE jn.ID != " + excludeJobName : "");
                var queryResult = connection.Query(query);
                return queryResult != null && queryResult.Any() ?
                    connection.Query(query).ToDictionary(r => (int)r.Key, r => (string)r.Value)
                    : new Dictionary<int, string>();
            }
        }

        /// <summary>
        /// Returns all distributors that have 1 or more job names and clients ordered by name as dictionary
        /// </summary>
        /// <returns></returns>
        private Dictionary<int, string> GetAllDistributorsForProduct()
        {
            using (var connection = Connection)
            {
                var query = string.Format(@"SELECT 
                                co.Name AS Value
                                ,co.ID AS [Key] 
                                FROM [dbo].[Company] co
                                    INNER JOIN [dbo].[Client] cl
                                        ON cl.Distributor = co.ID
                                    INNER JOIN [dbo].[JobName] jn
                                        ON jn.Client = cl.ID
                                    INNER JOIN [dbo].[VisualLayout] vl
                                        ON vl.Client = jn.ID
                            GROUP BY co.Name,co.ID
                            ORDER BY co.Name");
                var queryResult = connection.Query(query);
                return queryResult != null && queryResult.Any() ?
                    connection.Query(query).ToDictionary(r => (int)r.Key, r => (string)r.Value)
                    : new Dictionary<int, string>();
            }
        }

        /// <summary>
        /// Returns all job names for a distributor as a dictionary of id and name
        /// </summary>
        /// <param name="distributorId"></param>
        /// <returns></returns>
        private Dictionary<int, string> GetJobNamesForDistributor(int distributorId)
        {
            var result = new Dictionary<int, string>();
            if (distributorId < 1)
                return result;
            using (var connection = Connection)
            {
                var query = @"SELECT 
                                        jn.Name AS Value
                                        ,jn.ID AS [Key]  
                                        FROM [dbo].[Company] co
                                            INNER JOIN [dbo].[Client] cl
                                                ON cl.Distributor = co.ID
                                            INNER JOIN [dbo].[JobName] jn
                                                ON jn.Client = cl.ID
                                    WHERE co.ID = " + distributorId;
                var queryResult = connection.Query(query).ToList();
                return queryResult.Count > 0 ? queryResult.ToDictionary(r => (int)r.Key, r => (string)r.Value) : result;
            }
        }

        /// <summary>
        /// Returns all job names for a distributor as a dictionary of id and name
        /// </summary>
        /// <param name="distributorId"></param>
        /// <returns></returns>
        private Dictionary<int, string> GetJobNamesForDistributorForProduct(int distributorId)
        {
            var result = new Dictionary<int, string>();
            if (distributorId < 1)
                return result;
            using (var connection = Connection)
            {
                var query = string.Format(@"SELECT 
                            jn.Name AS Value
                            ,jn.ID AS [Key]  
                            FROM [dbo].[Company] co
                                INNER JOIN [dbo].[Client] cl
                                    ON cl.Distributor = co.ID
                                INNER JOIN [dbo].[JobName] jn
                                    ON jn.Client = cl.ID
                                INNER JOIN [dbo].[VisualLayout] vl	
                                    ON vl.Client = jn.ID
                        WHERE co.ID = {0}
                        GROUP BY jn.ID,jn.Name", distributorId);
                var queryResult = connection.Query(query).ToList();
                return queryResult.Count > 0 ? queryResult.ToDictionary(r => (int)r.Key, r => (string)r.Value) : result;
            }
        }


        /// <summary>
        /// return all job names as a dictionary
        /// </summary>
        /// <returns></returns>
        private Dictionary<int, string> GetAllJobNames()
        {
            using (var connection = Connection)
            {
                const string query = @"SELECT jn.Name AS Value , jn.ID AS [Key] FROM [dbo].[JobName] jn
                                    INNER JOIN [dbo].[VisualLayout] vl
                                        ON vl.Client = jn.ID
                                GROUP BY jn.ID,jn.Name";
                var queryResult = connection.Query(query).ToList();
                return queryResult.Count > 0 ? queryResult.ToDictionary(r => (int)r.Key, r => (string)r.Value) : new Dictionary<int, string>();
            }

        }

        /// <summary>
        /// Get all products associated with given job name
        /// </summary>
        /// <param name="jobName"></param>
        /// <returns></returns>
        private Dictionary<int, string> GetProductsForJobName(int jobName)
        {
            var result = new Dictionary<int, string>();
            if (jobName < 1)
                return result;
            using (var connection = Connection)
            {
                var query = @"SELECT vl.NamePrefix + '  - ' +p.NickName AS Value, vl.ID AS [Key] FROM [dbo].[VisualLayout] vl	
                                    INNER JOIN [dbo].[JobName] jn
                                        ON vl.Client = jn.ID
                                    INNER JOIN [dbo].[Pattern] p
                                        ON vl.Pattern = p.ID
                            WHERE jn.ID =" + jobName;
                var queryResult = connection.Query(query).ToList();
                return queryResult.Count > 0 ? queryResult.ToDictionary(r => (int)r.Key, r => (string)r.Value) : result;
            }

        }

        /// <summary>
        /// Execute procedure and transfer job name to given distributor
        /// </summary>
        /// <param name="jobName"></param>
        /// <param name="distributor"></param>
        private void TransferJobName(int jobName, int distributor)
        {
            using (var connection = Connection)
            {
                connection.Open();
                connection.Execute(string.Format("EXEC [dbo].[SPC_TransferJobName] {0}, {1}", jobName, distributor));
            }
        }

        /// <summary>
        /// Execute procedure and transfer Product name to given job Name
        /// </summary>
        /// <param name="product"></param>
        /// <param name="jobName"></param>
        private void TransferProduct(int product, int jobName)
        {
            using (var connection = Connection)
            {
                connection.Open();
                connection.Execute(string.Format("EXEC [dbo].[SPC_TransferVisualLayout] {0}, {1}", product, jobName));
            }
        }

        /// <summary>
        /// Execute procedure and transfer Distributor to given Distributor
        /// </summary>
        /// <param name="from"></param>
        /// <param name="to"></param>
        private void TransferDistributor(int from,int to)
        {
            if (from < 1 || to < 1)
                return;

            using(var connection = Connection)
            {
                connection.Execute(string.Format("EXEC [dbo].[SPC_TransferDistributor] {0}, {1}", from, to));
            }
        }

        #endregion


    }
}