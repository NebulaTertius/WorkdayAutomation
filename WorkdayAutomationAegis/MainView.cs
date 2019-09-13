using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Windows.Forms;
using AI.Automation;
using System.IO;
using System.Data.SqlClient;

using DevExpress.XtraBars;
using DevExpress.Xpo;
using DevExpress.Xpo.Metadata;
using DevExpress.Data.Linq.Helpers;
using DevExpress.XtraGrid.Views.Grid;
using DevExpress.UserSkins;
using DevExpress.Skins;
using DevExpress.Mvvm.DataAnnotations;

namespace WorkdayAutomationAegis
{
    public partial class MainView : DevExpress.XtraBars.Ribbon.RibbonForm
    {
        public static string fileName = Directory.GetCurrentDirectory() + "\\SQLConfig.sage";
        public static string connFile = Directory.GetCurrentDirectory() + "\\SQLConnString.sage";
        public static string csvConfigFile = Directory.GetCurrentDirectory() + "\\FileConfig.sage";
        public static string csvFolderLoc;
        public static string csvCompletedLoc;
        public static string csvStringIdentifier;
        public static char[] csvColSeparator;
        public static string ConnectionString;

        public MainView()
        {
            InitializeComponent();

            if (File.Exists(Directory.GetCurrentDirectory() + "\\SQLConnString.sage") == true)
            {
                ConnectionString = Crypto.Decrypt(File.ReadAllLines(Directory.GetCurrentDirectory() + "\\SQLConnString.sage").First(), "SAGE");
                refreshValidations();
            }
            else { ConnectionString = @"XpoProvider=MSSqlServer;data source=NotDefined;integrated security=SSPI;initial catalog=NotDefined"; }

            if (File.Exists(Directory.GetCurrentDirectory() + "\\FileConfig.sage") == true)
            {
                csvFolderLoc = Crypto.Decrypt(File.ReadAllLines(Directory.GetCurrentDirectory() + "\\FileConfig.sage").Skip(1).Take(1).First(), "SAGE");
                csvCompletedLoc = Crypto.Decrypt(File.ReadAllLines(Directory.GetCurrentDirectory() + "\\FileConfig.sage").Skip(3).Take(1).First(), "SAGE");
                csvStringIdentifier = Crypto.Decrypt(File.ReadAllLines(Directory.GetCurrentDirectory() + "\\FileConfig.sage").Skip(4).Take(1).First(), "SAGE");
                csvColSeparator = Crypto.Decrypt(File.ReadAllLines(Directory.GetCurrentDirectory() + "\\FileConfig.sage").Skip(5).Take(1).First(), "SAGE").ToCharArray();
            }
            else
            {
                csvFolderLoc = Directory.GetCurrentDirectory() + "\\NotCreated";
                csvCompletedLoc = Directory.GetCurrentDirectory() + "\\NotCreated";
                csvStringIdentifier = Directory.GetCurrentDirectory() + "\\NotCreated";
                csvColSeparator = ";".ToCharArray();
            }
        }


        private void bbiCloseApp_ItemClick(object sender, ItemClickEventArgs e)
        {
            Application.Exit();
        }


        private void bbiRefresh_ItemClick(object sender, ItemClickEventArgs e)
        {
            gridControl.Refresh();
        }
        void bbiPrintPreview_ItemClick(object sender, ItemClickEventArgs e)
        {
            gridControl.ShowRibbonPrintPreview();
        }
        private void bbiExportToExcel_ItemClick(object sender, ItemClickEventArgs e)
        {
            gridControl.ExportToXlsx("AutomationGridExport.xlsx");
        }
        private void gridControl_ProcessGridKey(object sender, KeyEventArgs e)
        {
            var grid = gridControl;
            var view = grid.FocusedView as GridView;
            if (e.KeyData == Keys.Delete)
            {
                //view.DeleteSelectedRows();
                //e.Handled = true;
            }
        }

        private void focusGridToEditableView(DevExpress.Xpo.XPCollection xpCollection)
        {
            gvwEditable.ClearGrouping();
            gvwEditable.ClearSorting();
            gvwEditable.ClearColumnsFilter();
            navFrame.SelectedPageIndex = 1;
            gridControl.DataSource = null;
            gridControl.DataSource = xpCollection;
            gridControl.MainView.PopulateColumns();
            gvwEditable.Columns[0].Visible = false;
            //for (int c = 0; c <= gvwEditable.VisibleColumns.Count; c++)
            //{
            //    gvwEditable.Columns[c].MaxWidth = 175;
            //}
            gvwEditable.BestFitColumns();
            gvwEditable.OptionsView.NewItemRowPosition = NewItemRowPosition.Bottom;
            gvwEditable.OptionsBehavior.Editable = true;
            gvwEditable.OptionsBehavior.ReadOnly = false;
            bsiRecordsCount.Caption = "RECORDS : " + gridControl.DefaultView.DataRowCount;
            gvwEditable.Focus();
        }

        private void focusGridToReadView(DevExpress.Xpo.XPCollection xpCollection)
        {

            gvwEditable.ClearGrouping();
            gvwEditable.ClearSorting();
            gvwEditable.ClearColumnsFilter();
            navFrame.SelectedPageIndex = 1;
            gridControl.DataSource = null;
            gridControl.DataSource = xpCollection;
            gridControl.MainView.PopulateColumns();
            gvwEditable.Columns[0].Visible = false;
            //for (int c = 0; c <= gvwEditable.VisibleColumns.Count; c++)
            //{
            //    gvwEditable.Columns[c].MaxWidth = 175;
            //}
            gvwEditable.BestFitColumns();
            gvwEditable.OptionsView.NewItemRowPosition = NewItemRowPosition.None;
            gvwEditable.OptionsBehavior.Editable = false;
            gvwEditable.OptionsBehavior.ReadOnly = true;
            bsiRecordsCount.Caption = "RECORDS : " + gridControl.DefaultView.DataRowCount;
            gvwEditable.Focus();
        }

        private void focusGridByColumnNames(DevExpress.Xpo.XPCollection xpCollection)
        {
            navFrame.SelectedPageIndex = 1;
            gridControl.DataSource = null;
            gridControl.DataSource = xpCollection;

            gridControl.MainView.PopulateColumns();

            //var inclCols = new List<DevExpress.XtraGrid.Columns.GridColumn>();
            ////= new List<DevExpress.XtraGrid.Columns.GridColumn >();

            //inclCols.Add(gvwEditable.Columns.ColumnByFieldName("EmployeeCode"));
            //inclCols.Add(gvwEditable.Columns.ColumnByFieldName("ErrorCode"));
            //inclCols.Add(gvwEditable.Columns.ColumnByFieldName("ErrorMessage"));



            //foreach (var i in inclCols)
            //{
            //    gvwEditable.Columns.SkipWhile(i,true);
            //    //gvwEditable.Columns.ColumnByFieldName("EmployeeCode").Visible = true;
            //    //gvwEditable.PopulateColumns(i);
            //    //gvwEditable.Columns.AddRange(inclCols);
            //    //gvwEditable.VisibleColumns.ToList<DevExpress.XtraGrid.Columns.GridColumn>();
            //}

            //gvwEditable.Columns.SkipWhile(gvwEditable.Columns.ColumnByFieldName("EmployeeCode"), gvwEditable.Columns.ColumnByFieldName("EmployeeCode").VisibleIndex.Equals(0));

            for (int c = 0; c <= gvwEditable.VisibleColumns.Count; c++)
            {
                gvwEditable.Columns[c].MaxWidth = 175;
            }
            gvwEditable.BestFitColumns();
            gvwEditable.OptionsView.NewItemRowPosition = NewItemRowPosition.None;
            gvwEditable.OptionsBehavior.Editable = false;
            gvwEditable.OptionsBehavior.ReadOnly = true;
            bsiRecordsCount.Caption = "RECORDS : " + gridControl.DefaultView.DataRowCount;
            gvwEditable.Focus();
        }


        private XPCollection dynamicXPCollection(string ConnString, string TableName, Type className)
        {
            ReflectionDictionary newDictionary = new ReflectionDictionary();
            newDictionary.CollectClassInfos(className.Assembly);
            XPClassInfo dynClassInfo = newDictionary.GetClassInfo(className);
            dynClassInfo.AddAttribute(new PersistentAttribute(TableName));
            IDataLayer dataLayer = XpoDefault.GetDataLayer(ConnString, newDictionary, DevExpress.Xpo.DB.AutoCreateOption.DatabaseAndSchema);
            dataLayer.UpdateSchema(false, dynClassInfo);
            Session xpSession = new Session(dataLayer);
            XPCollection xpCol = new XPCollection(xpSession, dynClassInfo);
            return xpCol;
        }

        private void bbiEventTracker_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.EventTracker", typeof(AIEventTracker));
                focusGridToReadView(xpCol);
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void bbiCreateHistoryTables_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                ExecuteSQLQuery("EXEC AI.CreateHistoryTables");
                MessageBox.Show("Process completed", "Done", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void bbiCatalogMapping_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.CatalogMapping", typeof(AICatalogMapping));
                focusGridToEditableView(xpCol);

                gvwEditable.Columns.ColumnByFieldName("CatalogType").Group();
                gvwEditable.Columns.ColumnByFieldName("CatalogName").Group();

                gvwEditable.Columns.ColumnByFieldName("SourceField").SortIndex = 0;
                gvwEditable.Columns.ColumnByFieldName("CatalogLocale").SortIndex = 1;
                gvwEditable.Columns.ColumnByFieldName("TargetValue").SortIndex = 2;
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void bbiQueueMapping_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.QueueMapping", typeof(AIQueueMapping));
                focusGridToEditableView(xpCol);

                gvwEditable.Columns.ColumnByFieldName("QueueType").Group();
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void bbiEmpMaster_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.EmployeeSource", typeof(AIEmployeeSource));
                focusGridToReadView(xpCol);
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void bbiAllAndOTP_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.AllowanceAndOTPSource", typeof(AIAllowanceAndOTPSource));
                focusGridToReadView(xpCol);
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void bbiAbsences_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.AbsenceSource", typeof(AIAbsenceSource));
                focusGridToReadView(xpCol);
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }

        }


        private void bbiEmpQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.EmployeeQueue", typeof(AIEmployeeQueue));
                focusGridToReadView(xpCol);
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }
        private void bbiEmpSubQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.EmployeeSubQueue", typeof(AIEmployeeSubQueue));
                focusGridToReadView(xpCol);
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void bbiFinQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.FinancialQueue", typeof(AIFinancialQueue));
                focusGridToReadView(xpCol);
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void bbiLveBalQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.LeaveBalanceQueue", typeof(AILeaveBalanceQueue));
                focusGridToReadView(xpCol);
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }


        private void bbiLveTranQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.LeaveTransactionQueue", typeof(AILeaveTransactionQueue));
                focusGridToReadView(xpCol);
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }





        private void bbiEmployeeQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.EmployeeQueue", typeof(AIEmployeeQueue));
            focusGridToReadView(xpCol);
        }



        private void bbiSageDBSetup_ItemClick(object sender, ItemClickEventArgs e)
        {
            navFrame.SelectedPageIndex = 0;
            try
            {
                if (File.Exists(fileName) == true)
                {
                    string[] strFileName = File.ReadAllLines(fileName);
                    int u = 0;

                    foreach (string myLine in strFileName)
                    {
                        if (u == 1) { ConnectionString = Crypto.Decrypt(myLine, "SAGE"); }
                        if (u == 2) { beConnServerName.Text = Crypto.Decrypt(myLine, "SAGE"); }
                        if (u == 3) { if (Crypto.Decrypt(myLine, "SAGE").Equals("True")) { cheADAuth.Checked = true; } else { cheADAuth.Checked = false; } }
                        if (u == 4) { teConnUsername.Text = Crypto.Decrypt(myLine, "SAGE"); }
                        if (u == 5) { teConnPassword.Text = Crypto.Decrypt(myLine, "SAGE"); }
                        if (u == 6) { teDatabase.Text = Crypto.Decrypt(myLine, "SAGE"); }
                        u = u + 1;
                    }
                }
                else
                {
                    MessageBox.Show("Application configuration file is missing, a new one will be created when you complete the details.", "Form Loading Failed", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
            catch (Exception myException)
            {
                MessageBox.Show("Error loading application configuration form:" + myException.Message, "Form Loading Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }

        }



        private void cheADAuth_CheckedChanged(object sender, EventArgs e)
        {
            if (cheADAuth.Checked == true)
            { teConnUsername.Enabled = false; teConnPassword.Enabled = false; }
            else { teConnUsername.Enabled = true; teConnPassword.Enabled = true; }
        }

        private void sbConnSave_Click(object sender, EventArgs e)
        {
            try
            {
                if (File.Exists(fileName) == true)
                { File.Delete(fileName); }

                if (cheADAuth.Checked == true)
                { ConnectionString = @"XpoProvider=MSSqlServer;data source=" + beConnServerName.Text + ";integrated security=SSPI;initial catalog=" + teDatabase.Text; }
                else { ConnectionString = @"XpoProvider=MSSqlServer;data source=" + beConnServerName.Text + ";user id=" + teConnUsername.Text + ";password=" + teConnPassword.Text + ";initial catalog=" + teDatabase.Text; }

                StreamWriter objWriter = new StreamWriter(fileName, false);
                objWriter.WriteLine("[Application SQL Details]");
                objWriter.WriteLine(Crypto.Encrypt(ConnectionString, "SAGE"));
                objWriter.WriteLine(Crypto.Encrypt(beConnServerName.Text, "SAGE"));
                if (cheADAuth.Checked == true) { objWriter.WriteLine(Crypto.Encrypt("True", "SAGE")); } else { objWriter.WriteLine(Crypto.Encrypt("False", "SAGE")); }
                objWriter.WriteLine(Crypto.Encrypt(teConnUsername.Text, "SAGE"));
                objWriter.WriteLine(Crypto.Encrypt(teConnPassword.Text, "SAGE"));
                objWriter.WriteLine(Crypto.Encrypt(teDatabase.Text, "SAGE"));
                objWriter.Close();

                StreamWriter connWriter = new StreamWriter(connFile, false);
                connWriter.WriteLine(Crypto.Encrypt(ConnectionString, "SAGE"));
                connWriter.Close();

                MessageBox.Show("Application configuration settings saved succesfully.", "Application Configuration", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception myException)
            {
                MessageBox.Show("Error loading application configuration form:" + myException.Message, "Form Loading Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void sbConnTest_Click(object sender, EventArgs e)
        {
            bool missField = false;
            try
            {
                if (cheADAuth.Checked == true)
                { if (!string.IsNullOrEmpty(beConnServerName.Text) & !string.IsNullOrEmpty(teDatabase.Text)) { } else { missField = true; }; }
                else { if (!string.IsNullOrEmpty(beConnServerName.Text) & !string.IsNullOrEmpty(teDatabase.Text) & !string.IsNullOrEmpty(teConnUsername.Text) & !string.IsNullOrEmpty(teConnPassword.Text)) { } else { missField = true; }; }

                if (missField == false)
                {
                    if (cheADAuth.Checked == true)
                    { ConnectionString = @"Persist Security Info=False;server=" + beConnServerName.Text + ";integrated security=SSPI;database=" + teDatabase.Text; }
                    else { ConnectionString = @"Persist Security Info=False;server=" + beConnServerName.Text + ";user id=" + teConnUsername.Text + ";password=" + teConnPassword.Text + ";database=" + teDatabase.Text; }

                    //string connectionString = string.Format("Persist Security Info=False;database={0};server={1};Connect Timeout=30;User Id={2};Password={3}", txtData.Text, txtSQLServer.Text, txtUsername.Text, txtPassword.Text);
                    SqlConnection myCon = new SqlConnection(ConnectionString);
                    try
                    {
                        myCon.Open();
                        myCon.Close();
                        MessageBox.Show("Application connection established succesfully.", "Application Configuration", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                    catch (Exception myException)
                    {
                        MessageBox.Show("Unable to connect to the Application database: " + myException.Message, "Testing Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                    }
                }
                else
                {
                    MessageBox.Show("Please ensure all fields are filled in.", "Application Configuration", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }

            }
            catch (Exception myException)
            {
                MessageBox.Show("Testing database connection failed: " + myException.Message, "Testing Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void sbConnCancel_Click(object sender, EventArgs e)
        {
            beConnServerName.Text = "";
            cheADAuth.Checked = false;
            teConnUsername.Text = "";
            teConnPassword.Text = "";
            teDatabase.Text = "";
        }

        private void bbiWDFileSetup_ItemClick(object sender, ItemClickEventArgs e)
        {
            navFrame.SelectedPageIndex = 2;
            try
            {
                if (File.Exists(csvConfigFile) == true)
                {
                    string[] csvConfig = File.ReadAllLines(csvConfigFile);
                    int u = 0;

                    foreach (string myLine in csvConfig)
                    {
                        if (u == 1) { csvFolderLoc = Crypto.Decrypt(myLine, "SAGE"); beFileLocation.Text = csvFolderLoc; }
                        if (u == 2) { if (Crypto.Decrypt(myLine, "SAGE").Equals("True")) { ceFileDeletionOption.Checked = true; } else { ceFileDeletionOption.Checked = false; } }
                        if (u == 3) { csvCompletedLoc = Crypto.Decrypt(myLine, "SAGE"); teCompletedFolder.Text = csvCompletedLoc; }
                        if (u == 4) { csvStringIdentifier = Crypto.Decrypt(myLine, "SAGE"); teCSVStringQuoteIdentifier.Text = csvStringIdentifier; }
                        if (u == 5) { csvColSeparator = Crypto.Decrypt(myLine, "SAGE").ToCharArray(); teCSVSeparator.Text = csvColSeparator[0].ToString(); }
                        u = u + 1;
                    }
                }
                else
                {
                    MessageBox.Show("CSV configuration file is missing, a new one will be created when you complete the details.", "CSV Config Loading Failed", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
            catch (Exception myException)
            {
                MessageBox.Show("Error loading CSV configuration form:" + myException.Message, "CSV Config Loading Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void sbSaveFileLocation_Click(object sender, EventArgs e)
        {
            try
            {
                if (File.Exists(csvConfigFile) == true)
                { File.Delete(csvConfigFile); }
                StreamWriter objWriter = new StreamWriter(csvConfigFile, false);
                objWriter.WriteLine("[CSV File Location Details]");
                objWriter.WriteLine(Crypto.Encrypt(beFileLocation.Text, "SAGE"));
                if (ceFileDeletionOption.Checked == true) { objWriter.WriteLine(Crypto.Encrypt("True", "SAGE")); } else { objWriter.WriteLine(Crypto.Encrypt("False", "SAGE")); }
                objWriter.WriteLine(Crypto.Encrypt(teCompletedFolder.Text, "SAGE"));
                objWriter.WriteLine(Crypto.Encrypt(teCSVStringQuoteIdentifier.Text, "SAGE"));
                objWriter.WriteLine(Crypto.Encrypt(teCSVSeparator.Text, "SAGE"));
                objWriter.Close();

                csvFolderLoc = beFileLocation.Text;
                csvCompletedLoc = teCompletedFolder.Text;
                csvStringIdentifier = teCSVStringQuoteIdentifier.Text;
                csvColSeparator = teCSVSeparator.Text.ToCharArray();

                MessageBox.Show("Application configuration settings saved succesfully.", "Application Configuration", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                ErrorLogging.WriteToErrorFile(ex, "");
                MessageBox.Show("Error loading application configuration form:" + ex.Message, "Form Loading Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void sbClearSelections_Click(object sender, EventArgs e)
        {
            beFileLocation.Text = "";
            ceFileDeletionOption.Checked = true;
        }

        private void ceFileDeletionOption_CheckedChanged(object sender, EventArgs e)
        {
            if (ceFileDeletionOption.Checked == true)
            { teCompletedFolder.Enabled = false; }
            else { teCompletedFolder.Enabled = true; }
        }

        public string GetSQLConnString()
        {
            string sqlConnString = "";
            string ServerName = Crypto.Decrypt(File.ReadAllLines(fileName).Skip(2).Take(1).First(), "SAGE");
            string UseADAuth = Crypto.Decrypt(File.ReadAllLines(fileName).Skip(3).Take(1).First(), "SAGE");
            string Username = Crypto.Decrypt(File.ReadAllLines(fileName).Skip(4).Take(1).First(), "SAGE");
            string Password = Crypto.Decrypt(File.ReadAllLines(fileName).Skip(5).Take(1).First(), "SAGE");
            string DB = Crypto.Decrypt(File.ReadAllLines(fileName).Skip(6).Take(1).First(), "SAGE");

            if (UseADAuth == "True")
            { sqlConnString = @"Persist Security Info=False;server=" + ServerName + ";integrated security=SSPI;database=" + DB; }
            else { sqlConnString = @"Persist Security Info=False;server=" + ServerName + ";user id=" + Username + ";password=" + Password + ";database=" + DB; }
            return sqlConnString;
        }

        public void DataTableToSQL(string csvFile, string sqlConnection, string sqlTable)
        {
            var lines = System.IO.File.ReadAllLines(csvFile);
            if (lines.Count() == 0) return;
            var columns = lines[0].Split(csvColSeparator[0]);
            var table = new DataTable();

            int colNo = 1;
            foreach (var c in columns)
            { if (colNo == 1) { table.Columns.Add("CountryCodeIndicator"); colNo = colNo + 1; } else { table.Columns.Add(c); colNo = colNo + 1; }; }

            table.Columns.Add("SourceFileName");

            for (int i = 1; i < lines.Count(); i++)
            { table.Rows.Add((lines[i].ToString() + csvColSeparator[0] + Path.GetFileName(csvFile)).Split(csvColSeparator[0])); }

            table.Columns.Add("Oid");
            table.Columns["Oid"].SetOrdinal(0);

            var sqlBulk = new SqlBulkCopy(sqlConnection);
            sqlBulk.DestinationTableName = sqlTable;
            sqlBulk.WriteToServer(table);
        }


        public void CSVToSQL(string csvFile, string sqlConnection, string sqlTable)
        {

            using (DataTable csvDT = new DataTable())
            {
                try
                {
                    string[] seps = { "\";", ";\"" };
                    char[] quotes = { '\"', ' ' };
                    string[] colFields = null;
                    foreach (var line in File.ReadLines(csvFile))
                    {
                        var fields = (line.ToString() + "\";" + Path.GetFileName(csvFile) + ";\"")
                            .Split(seps, StringSplitOptions.None)
                            .Select(s => s.Trim(quotes).Replace("\\\"", "\""))
                            .ToArray();

                        if (colFields == null)
                        {
                            colFields = fields;
                            int colNo = 1;
                            foreach (string column in colFields)
                            {
                                if (colNo == 1)
                                {
                                    csvDT.Columns.Add("CountryCodeIndicator");
                                    colNo = colNo + 1;
                                }
                                else
                                {
                                    DataColumn datacolumn = new DataColumn(column);
                                    datacolumn.AllowDBNull = true;
                                    csvDT.Columns.Add(datacolumn);
                                }
                            }
                            csvDT.Columns.Add("SourceFileName");
                        }
                        else
                        {
                            for (int i = 0; i < fields.Length; i++)
                            {
                                if (fields[i] == "")
                                {
                                    fields[i] = null;
                                }
                            }
                            csvDT.Rows.Add(fields);
                        }
                    }
                    csvDT.Columns.Add("Oid");
                    csvDT.Columns["Oid"].SetOrdinal(0);



                    var sqlBulk = new SqlBulkCopy(sqlConnection);
                    sqlBulk.DestinationTableName = sqlTable;
                    sqlBulk.WriteToServer(csvDT);
                }
                catch (Exception ex)
                {
                    ErrorLogging.WriteToErrorFile(ex, "");
                    MessageBox.Show("Error loading CSV Data:" + ex.Message, "CSV Loading Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
        }


        private void bbiImportCSVEmployee_ItemClick(object sender, ItemClickEventArgs e)
        {
            string[] inputFiles = Directory.GetFiles(csvFolderLoc, "*ETO*.csv");
            if (inputFiles.Length == 0) { MessageBox.Show("No new import files containing key word ETO found in " + csvFolderLoc + ": The process will continue to refresh existing data.", "No New Files Found", MessageBoxButtons.OK, MessageBoxIcon.Information); }
            {
                try
                {
                    string sqlConn = GetSQLConnString();

                    foreach (string inputpath in Directory.GetFiles(csvFolderLoc, "*ETO*.csv"))
                    {
                        CSVToSQL(inputpath, sqlConn, "AI.EmployeeSource");
                        MoveOrDeleteImportFile(inputpath, csvCompletedLoc + "\\" + Path.GetFileName(inputpath));
                        //XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.EmployeeSource", typeof(AIEmployeeSource));
                        //focusGridToReadView(xpCol);
                    }
                }
                catch (Exception ex)
                {
                    ErrorLogging.WriteToErrorFile(ex, "");
                    MessageBox.Show(ex.Source + ": " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
        }

        private void bbiImportCSVAllAndOTP_ItemClick(object sender, ItemClickEventArgs e)
        {
            string[] inputFiles = Directory.GetFiles(csvFolderLoc, "*PAY*.csv");

            if (inputFiles.Length == 0) { MessageBox.Show("No import files containing key word PAY found in " + csvFolderLoc + ": The process will continue to refresh existing data.", "No New Files Found", MessageBoxButtons.OK, MessageBoxIcon.Information); }
            {
                try
                {
                    string sqlConn = GetSQLConnString();

                    foreach (string inputpath in Directory.GetFiles(csvFolderLoc, "*PAY*.csv"))
                    {
                        CSVToSQL(inputpath, sqlConn, "AI.AllowanceAndOTPSource");
                        MoveOrDeleteImportFile(inputpath, csvCompletedLoc + "\\" + Path.GetFileName(inputpath));
                        //XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.AllowanceAndOTPSource", typeof(AIAllowanceAndOTPSource));
                        //focusGridToReadView(xpCol);
                    }
                }
                catch (Exception ex)
                {
                    ErrorLogging.WriteToErrorFile(ex, "");
                    MessageBox.Show(ex.Source + ": " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
        }

        private void bbiImportCSVAbsences_ItemClick(object sender, ItemClickEventArgs e)
        {
            string[] inputFiles = Directory.GetFiles(csvFolderLoc, "*ATO*.csv");
            if (inputFiles.Length == 0) { MessageBox.Show("No import files containing key word ATO found in " + csvFolderLoc + ": The process will continue to refresh existing data.", "No New Files Found", MessageBoxButtons.OK, MessageBoxIcon.Information); }
            {
                try
                {
                    string sqlConn = GetSQLConnString();

                    foreach (string inputpath in Directory.GetFiles(csvFolderLoc, "*ATO*.csv"))
                    {
                        CSVToSQL(inputpath, sqlConn, "AI.AbsenceSource");
                        string testFolders = csvFolderLoc + "\\" + Path.GetFileName(inputpath).PadLeft(19);

                        MoveOrDeleteImportFile(inputpath, csvCompletedLoc + "\\" + Path.GetFileName(inputpath));
                        //XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.AbsenceSource", typeof(AIAbsenceSource));
                        //focusGridToReadView(xpCol);
                    }
                }
                catch (Exception ex)
                {
                    ErrorLogging.WriteToErrorFile(ex, "");
                    MessageBox.Show(ex.Source + ": " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
        }

        private void MoveOrDeleteImportFile(string sourcePath, string completedPath)
        {
            if (Crypto.Decrypt(File.ReadAllLines(csvConfigFile).Skip(2).Take(1).First(), "SAGE") == "True")
            { File.Delete(sourcePath); }
            else { if (File.Exists(completedPath)) { File.Delete(completedPath); File.Move(sourcePath, completedPath); } else { File.Move(sourcePath, completedPath); } }
        }


        private void bbiCreateTestingFolders_ItemClick(object sender, ItemClickEventArgs e)
        {
            string[] inputFiles = Directory.GetFiles(csvFolderLoc);
            if (inputFiles.Length == 0) { MessageBox.Show("No files found " + csvFolderLoc, "No Files Found", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
            {
                try
                {
                    string sqlConn = GetSQLConnString();

                    foreach (string inputpath in Directory.GetFiles(csvFolderLoc))
                    {
                        string testFolders = csvFolderLoc + Path.GetFileName(inputpath).Substring(0, 19);
                        Directory.CreateDirectory(testFolders);
                        Directory.CreateDirectory(testFolders + "\\Completed");
                        MoveOrDeleteImportFile(inputpath, testFolders + "\\" + Path.GetFileName(inputpath));
                    }
                }
                catch (Exception ex)
                {
                    ErrorLogging.WriteToErrorFile(ex, "");
                    MessageBox.Show(ex.Source + ": " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                }
            }
        }

        private void ExecuteSQLQuery(string sqlStatement)
        {
            using (SqlConnection sqlConn = new SqlConnection(GetSQLConnString()))
            {
                sqlConn.Open();
                using (SqlCommand cmd = new SqlCommand(sqlStatement, sqlConn))
                {
                    cmd.ExecuteNonQuery();
                }
                sqlConn.Close();
            }
        }

        public DataTable SQLQueryToDataTable(string sqlStatement)
        {
            DataTable dt = new DataTable();
            using (SqlConnection sqlConn = new SqlConnection(GetSQLConnString()))
            {
                sqlConn.Open();
                SqlDataAdapter da = new SqlDataAdapter(sqlStatement, sqlConn);
                da.Fill(dt);
                sqlConn.Close();
            }
            return dt;
        }


        public DataTable GetEmployeesToMerge(string sqlQuery)
        {
            DataTable dt = SQLQueryToDataTable(sqlQuery);


            return dt;
        }

        private void bbiBuildAIStructures_ItemClick(object sender, ItemClickEventArgs e)
        {
            DialogResult dr = MessageBox.Show("Warning: This will reset all tables and delete any historic data." + Environment.NewLine + "Select Yes if you are sure that you want to continue.",
                      "Complete Reset Warning", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
            switch (dr)
            {
                case DialogResult.Yes:
                    try
                    {
                        DirectoryInfo sqlSetupDirectory = new DirectoryInfo(@".\SQLScripts\Setup\");
                        List<string> resultMsgList = new List<string>();
                        string msgDisplay = "";

                        foreach (var dir in sqlSetupDirectory.EnumerateDirectories())
                        {
                            try
                            {
                                string[] files = Directory.GetFiles(@".\SQLScripts\Setup\" + dir.ToString() + @"\");
                                foreach (string file in files)
                                {
                                    try { ExecuteSQLQuery(File.ReadAllText(file)); resultMsgList.Add(dir.ToString() + @" - Successful: " + Path.GetFileName(file)); }
                                    catch (Exception ex) { resultMsgList.Add(@"Failed: " + Path.GetFileName(file) + ". Source: " + ex.Source + " - " + ex.Message); }
                                }
                            }
                            catch (Exception ex) { resultMsgList.Add(@"Failed: " + ex.Source + " - " + ex.Message); }
                            msgDisplay = string.Join(Environment.NewLine, resultMsgList);
                        }
                        MessageBox.Show(msgDisplay, "Structures");
                    }
                    catch (Exception ex) { MessageBox.Show("Error: " + ex.Source + " - " + ex.Message); }
                    MessageBox.Show("Process Completed", "Information", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    break;
                case DialogResult.No:
                    MessageBox.Show("No changes have been made.", "Structure Reset Cancelled", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    break;
            }

        }


        private void bbiMoveEmployeeToQueue_ItemClick(object sender, ItemClickEventArgs e)
        {

            string insEmpOIDs = "''";

            using (DataTable empInsDT = SQLQueryToDataTable("SELECT * FROM (SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeCode ORDER BY OID) [RwNumb], * FROM AI.EmployeeSource WHERE EmployeeCode NOT IN (SELECT EmployeeCode FROM AI.EmployeeQueue)) s WHERE RwNumb = 1 ORDER BY OID"))
            {
                foreach (DataRow insDR in empInsDT.Rows)
                {
                    insEmpOIDs = insEmpOIDs + "," + insDR["OID"].ToString();
                }
            }


            string empSrcToQueueQuery = "";
            string empInsertString = "INSERT INTO AI.EmployeeQueue(StatusCode,DateCreated,LastChanged";
            string empSelectString = "SELECT 'N' [StatusCode],GETDATE() [DateCreated],GETDATE() [LastChanged]";

            string empContactSelect = "SELECT OID,EmployeeCode";
            string empHierarchySelect = "SELECT OID,EmployeeCode";
            string empGenericSelect = "SELECT OID,EmployeeCode";

            DataTable dt = SQLQueryToDataTable("SELECT * FROM AI.QueueMapping");
            foreach (DataRow dr in dt.Rows)
            {
                string qType = dr["QueueType"].ToString();
                string mapType = dr["MappingType"].ToString();
                string srcField = dr["SourceField"].ToString();
                if (srcField == "" || srcField == null) { srcField = "''"; } else { srcField = "s." + srcField; }
                string tgtField = dr["TargetField"].ToString();
                string tgtDataType = dr["TargetFieldDataType"].ToString();
                string leftConvertText = ""; string rightConvertText = "";
                if (tgtDataType != "") { leftConvertText = "CONVERT(" + tgtDataType + ","; rightConvertText = ")"; } else { }
                string tgtDataFormat = dr["TargetFieldDataFormat"].ToString();
                if (tgtDataFormat != "") { rightConvertText = "," + tgtDataFormat + ")"; } else { }
                string tgtLength = dr["TargetFieldMaxLength"].ToString();
                string leftLenText = ""; string rightLenText = "";
                if (tgtLength != "") { leftLenText = "LEFT("; rightLenText = "," + tgtLength + ")"; } else { }
                string defaultVal = dr["DefaultValue"].ToString();
                string sqlStatement = dr["SQLStatement"].ToString();
                string catStatement = dr["CatalogStatement"].ToString();

                switch (qType)
                {
                    case "Employee":
                        empInsertString = empInsertString + "," + tgtField;
                        switch (mapType)
                        {
                            case "Direct": empSelectString = empSelectString + "," + leftLenText + leftConvertText + srcField + rightConvertText + rightLenText + " [" + tgtField + "]"; break;
                            case "Catalog": empSelectString = empSelectString + "," + leftConvertText + "(SELECT TOP 1 m.TargetValue FROM AI.CatalogMapping m WHERE " + srcField + " = m.SourceValue AND m.SourceField = '" + srcField.Replace("s.", "") + "')" + rightConvertText + " [" + tgtField + "]"; break;
                            case "DefaultValue": empSelectString = empSelectString + "," + defaultVal + " [" + tgtField + "]"; break;
                            case "DefaultValueIfNull": empSelectString = empSelectString + "," + leftConvertText + ",ISNULL(" + srcField + "," + defaultVal + ")" + rightConvertText + " [" + tgtField + "]"; break;
                            case "SQLStatement": empSelectString = empSelectString + "," + sqlStatement + " [" + tgtField + "]"; break;
                            case "CatalogStatement": empSelectString = empSelectString + "," + catStatement + " [" + tgtField + "]"; break;
                            default: empSelectString = empSelectString + "," + leftLenText + leftConvertText + srcField + rightConvertText + rightLenText + " [" + tgtField + "]"; break;
                        }
                        break;

                    case "EmployeeContact":
                        switch (mapType)
                        {
                            case "Direct": empContactSelect = empContactSelect + "," + leftLenText + leftConvertText + srcField + rightConvertText + rightLenText + " [" + tgtField + "]"; break;
                            case "Catalog": empContactSelect = empContactSelect + "," + leftConvertText + "(SELECT TOP 1 m.TargetValue FROM AI.CatalogMapping m WHERE " + srcField + " = m.SourceValue AND m.SourceField = '" + srcField.Replace("s.", "") + "')" + rightConvertText + " [" + tgtField + "]"; break;
                            case "DefaultValue": empContactSelect = empContactSelect + "," + defaultVal + " [" + tgtField + "]"; break;
                            case "DefaultValueIfNull": empContactSelect = empContactSelect + "," + leftConvertText + ",ISNULL(" + srcField + "," + defaultVal + ")" + rightConvertText + " [" + tgtField + "]"; break;
                            case "SQLStatement": empContactSelect = empContactSelect + "," + sqlStatement + " [" + tgtField + "]"; break;
                            case "CatalogStatement": empContactSelect = empContactSelect + "," + catStatement + " [" + tgtField + "]"; break;
                            default: empContactSelect = empContactSelect + "," + leftLenText + leftConvertText + srcField + rightConvertText + rightLenText + " [" + tgtField + "]"; break;
                        }
                        break;

                    case "EmployeeHierarchy":
                        switch (mapType)
                        {
                            case "Direct": empHierarchySelect = empHierarchySelect + "," + leftLenText + leftConvertText + srcField + rightConvertText + rightLenText + " [" + tgtField + "]"; break;
                            case "Catalog": empHierarchySelect = empHierarchySelect + "," + leftConvertText + "(SELECT TOP 1 m.TargetValue FROM AI.CatalogMapping m WHERE " + srcField + " = m.SourceValue AND m.SourceField = '" + srcField.Replace("s.", "") + "')" + rightConvertText + " [" + tgtField + "]"; break;
                            case "DefaultValue": empHierarchySelect = empHierarchySelect + "," + defaultVal + " [" + tgtField + "]"; break;
                            case "DefaultValueIfNull": empHierarchySelect = empHierarchySelect + "," + leftConvertText + ",ISNULL(" + srcField + "," + defaultVal + ")" + rightConvertText + " [" + tgtField + "]"; break;
                            case "SQLStatement": empHierarchySelect = empHierarchySelect + "," + sqlStatement + " [" + tgtField + "]"; break;
                            case "CatalogStatement": empHierarchySelect = empHierarchySelect + "," + catStatement + " [" + tgtField + "]"; break;
                            default: empHierarchySelect = empHierarchySelect + "," + leftLenText + leftConvertText + srcField + rightConvertText + rightLenText + " [" + tgtField + "]"; break;
                        }
                        break;

                    case "EmployeeGeneric":
                        switch (mapType)
                        {
                            case "Direct": empGenericSelect = empGenericSelect + "," + leftLenText + leftConvertText + srcField + rightConvertText + rightLenText + " [" + tgtField + "]"; break;
                            case "Catalog": empGenericSelect = empGenericSelect + "," + leftConvertText + "(SELECT TOP 1 m.TargetValue FROM AI.CatalogMapping m WHERE " + srcField + " = m.SourceValue AND m.SourceField = '" + srcField.Replace("s.", "") + "')" + rightConvertText + " [" + tgtField + "]"; break;
                            case "DefaultValue": empGenericSelect = empGenericSelect + "," + defaultVal + " [" + tgtField + "]"; break;
                            case "DefaultValueIfNull": empGenericSelect = empGenericSelect + "," + leftConvertText + ",ISNULL(" + srcField + "," + defaultVal + ")" + rightConvertText + " [" + tgtField + "]"; break;
                            case "SQLStatement": empGenericSelect = empGenericSelect + "," + sqlStatement + " [" + tgtField + "]"; break;
                            case "CatalogStatement": empGenericSelect = empGenericSelect + "," + catStatement + " [" + tgtField + "]"; break;
                            default: empGenericSelect = empGenericSelect + "," + leftLenText + leftConvertText + srcField + rightConvertText + rightLenText + " [" + tgtField + "]"; break;
                        }
                        break;
                }
            }



            //Employee Queue Process
            empInsertString = empInsertString + ",QueueComment) ";
            empSrcToQueueQuery = empInsertString + empSelectString + ",SourceFileName [QueueComment] FROM AI.EmployeeSource s WHERE s.OID IN (" + insEmpOIDs + ")";
            ExecuteSQLQuery(empSrcToQueueQuery);



            //DataTable srcFileName = SQLQueryToDataTable("SELECT SourceFileName FROM (SELECT DISTINCT SourceFileName FROM AI.EmployeeSource) s ORDER BY s.SourceFileName");
            string empUpdateString = empSelectString + ", SourceFileName FROM AI.EmployeeSource s WHERE s.OID NOT IN (" + insEmpOIDs + ")";
            string updStatement = "";

            DataTable updList = SQLQueryToDataTable(empUpdateString);

            foreach (DataRow ur in updList.Rows)
            {
                updStatement = "UPDATE AI.EmployeeQueue SET QueueComment = QueueComment + '|" + ur["SourceFileName"].ToString() + "'";
                foreach (DataColumn dc in updList.Columns)
                {
                    if (ur[dc.Ordinal].ToString() == null || ur[dc.Ordinal].ToString() == "" || dc.ColumnName == "SourceFileName") { }
                    else { updStatement = updStatement + "," + dc.ColumnName + " = '" + ur[dc.Ordinal].ToString() + "' "; }
                }
                updStatement = updStatement + " WHERE EmployeeCode = '" + ur[updList.Columns["EmployeeCode"].Ordinal].ToString() + "'";
                if (updStatement == "") { } else { ExecuteSQLQuery(updStatement); }
            }



            //Employee Sub Queue Process
            empContactSelect = empContactSelect + " FROM AI.EmployeeSource s";
            empHierarchySelect = empHierarchySelect + " FROM AI.EmployeeSource s";
            empGenericSelect = empGenericSelect + " FROM AI.EmployeeSource s";


            if (empContactSelect != "SELECT OID,EmployeeCode FROM AI.EmployeeSource s")
            {
                using (DataTable cDT = SQLQueryToDataTable(empContactSelect))
                {
                    foreach (DataColumn dc in cDT.Columns)
                    {
                        if (dc.ColumnName == "OID" || dc.ColumnName == "EmployeeCode")
                        { }
                        else
                        {
                            string insSubStatement = "";
                            foreach (DataRow dr in cDT.Rows)
                            {
                                if (dr[dc.Ordinal].ToString() == null || dr[dc.Ordinal].ToString() == "" || dc.ColumnName == "OID" || dc.ColumnName == "EmployeeCode") { }
                                else
                                {
                                    insSubStatement = insSubStatement + "INSERT INTO AI.EmployeeSubQueue (EmployeeQueueOID,EmployeeCode,SubQueueTableType,SubQueueType,SubQueueValue) ";
                                    insSubStatement = insSubStatement + "VALUES ((SELECT TOP 1 q.OID FROM AI.EmployeeQueue q INNER JOIN AI.EmployeeSource s ON s.EmployeeCode = q.EmployeeCode WHERE s.EmployeeCode = '" + dr["EmployeeCode"].ToString() + "' ORDER BY q.OID DESC),'" + dr["EmployeeCode"].ToString() + "','Contact'";
                                    insSubStatement = insSubStatement + ",'" + dc.ColumnName + "','" + dr[dc.Ordinal].ToString().Replace("'", "") + "') ";
                                }
                            }
                            if (insSubStatement == "") { } else { ExecuteSQLQuery(insSubStatement); };
                        }
                    }
                }
            }


            if (empHierarchySelect != "SELECT OID,EmployeeCode FROM AI.EmployeeSource s")
            {
                using (DataTable hDT = SQLQueryToDataTable(empHierarchySelect))
                {
                    foreach (DataColumn dc in hDT.Columns)
                    {
                        if (dc.ColumnName == "OID" || dc.ColumnName == "EmployeeCode")
                        { }
                        else
                        {
                            string insSubStatement = "";
                            foreach (DataRow dr in hDT.Rows)
                            {
                                if (dr[dc.Ordinal].ToString() == null || dr[dc.Ordinal].ToString() == "" || dc.ColumnName == "OID" || dc.ColumnName == "EmployeeCode") { }
                                else
                                {
                                    insSubStatement = insSubStatement + "INSERT INTO AI.EmployeeSubQueue (EmployeeQueueOID,EmployeeCode,SubQueueTableType,SubQueueType,SubQueueValue) ";
                                    insSubStatement = insSubStatement + "VALUES ((SELECT TOP 1 q.OID FROM AI.EmployeeQueue q INNER JOIN AI.EmployeeSource s ON s.EmployeeCode = q.EmployeeCode WHERE s.EmployeeCode = '" + dr["EmployeeCode"].ToString() + "' ORDER BY q.OID DESC),'" + dr["EmployeeCode"].ToString().Replace("'", "") + "','HierarchyHeader'";
                                    insSubStatement = insSubStatement + ",'" + dc.ColumnName + "','" + dr[dc.Ordinal].ToString() + "') ";
                                }
                            }
                            if (insSubStatement == "") { } else { ExecuteSQLQuery(insSubStatement); };
                        }
                    }
                }
            }


            if (empGenericSelect != "SELECT OID,EmployeeCode FROM AI.EmployeeSource s")
            {
                using (DataTable gDT = SQLQueryToDataTable(empGenericSelect))
                {
                    foreach (DataColumn dc in gDT.Columns)
                    {
                        if (dc.ColumnName == "OID" || dc.ColumnName == "EmployeeCode")
                        { }
                        else
                        {
                            string insSubStatement = "";
                            foreach (DataRow dr in gDT.Rows)
                            {
                                if (dr[dc.Ordinal].ToString() == null || dr[dc.Ordinal].ToString() == "" || dc.ColumnName == "OID" || dc.ColumnName == "EmployeeCode") { }
                                else
                                {
                                    insSubStatement = insSubStatement + "INSERT INTO AI.EmployeeSubQueue (EmployeeQueueOID,EmployeeCode,SubQueueTableType,SubQueueType,SubQueueValue) ";
                                    insSubStatement = insSubStatement + "VALUES ((SELECT TOP 1 q.OID FROM AI.EmployeeQueue q INNER JOIN AI.EmployeeSource s ON s.EmployeeCode = q.EmployeeCode WHERE s.EmployeeCode = '" + dr["EmployeeCode"].ToString() + "' ORDER BY q.OID DESC),'" + dr["EmployeeCode"].ToString().Replace("'", "") + "','EmployeeGenericFields'";
                                    insSubStatement = insSubStatement + ",'" + dc.ColumnName + "','" + dr[dc.Ordinal].ToString() + "') ";
                                }
                            }
                            if (insSubStatement == "") { } else { ExecuteSQLQuery(insSubStatement); };
                        }
                    }
                }
            }

            //bbiTrackerPreProcess_ItemClick(sender, e);
            //bbiTrackerQueue_ItemClick(sender, e);

            //XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.EmployeeQueue", typeof(AIEmployeeQueue));
            //focusGridToReadView(xpCol);
        }


        private void bbiMoveAllowToQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            string otpSrcToQueueQuery = "";
            string otpInsertString = "INSERT INTO AI.FinancialQueue(StatusCode,DateCreated,LastChanged";
            string otpSelectString = "SELECT 'New' [StatusCode],GETDATE() [DateCreated],GETDATE() [LastChanged]";

            DataTable dt = SQLQueryToDataTable("SELECT * FROM AI.QueueMapping");
            foreach (DataRow dr in dt.Rows)
            {
                string qType = dr["QueueType"].ToString();
                string mapType = dr["MappingType"].ToString();
                string srcField = dr["SourceField"].ToString();
                if (srcField == "" || srcField == null) { srcField = "''"; } else { srcField = "s." + srcField; }
                string tgtField = dr["TargetField"].ToString();
                string tgtDataType = dr["TargetFieldDataType"].ToString();
                string leftConvertText = ""; string rightConvertText = "";
                if (tgtDataType != "") { leftConvertText = "CONVERT(" + tgtDataType + ","; rightConvertText = ")"; } else { }
                string tgtDataFormat = dr["TargetFieldDataFormat"].ToString();
                if (tgtDataFormat != "") { rightConvertText = "," + tgtDataFormat + ")"; } else { }
                string tgtLength = dr["TargetFieldMaxLength"].ToString();
                string leftLenText = ""; string rightLenText = "";
                if (tgtLength != "") { leftLenText = "LEFT("; rightLenText = "," + tgtLength + ")"; } else { }
                string defaultVal = dr["DefaultValue"].ToString();
                string sqlStatement = dr["SQLStatement"].ToString();
                string catStatement = dr["CatalogStatement"].ToString();

                switch (qType)
                {
                    case "AllowanceAndOTP":
                        otpInsertString = otpInsertString + "," + tgtField;
                        switch (mapType)
                        {
                            case "Direct": otpSelectString = otpSelectString + "," + leftLenText + leftConvertText + srcField + rightConvertText + rightLenText + " [" + tgtField + "]"; break;
                            case "Catalog": otpSelectString = otpSelectString + "," + leftConvertText + "(SELECT TOP 1 m.TargetValue FROM AI.CatalogMapping m WHERE " + srcField + " = m.SourceValue AND m.CatalogType = 'Payslip Batch')" + rightConvertText + " [" + tgtField + "]"; break;
                            case "DefaultValue": otpSelectString = otpSelectString + "," + defaultVal + " [" + tgtField + "]"; break;
                            case "DefaultValueIfNull": otpSelectString = otpSelectString + "," + leftConvertText + ",ISNULL(" + srcField + "," + defaultVal + ")" + rightConvertText + " [" + tgtField + "]"; break;
                            case "SQLStatement": otpSelectString = otpSelectString + "," + sqlStatement + " [" + tgtField + "]"; break;
                            case "CatalogStatement": otpSelectString = otpSelectString + "," + catStatement + " [" + tgtField + "]"; break;
                            default: otpSelectString = otpSelectString + "," + leftLenText + leftConvertText + srcField + rightConvertText + rightLenText + " [" + tgtField + "]"; break;
                        }
                        break;
                }
            }

            //Financial Queue
            otpInsertString = otpInsertString + ",QueueComment) ";
            otpSrcToQueueQuery = otpInsertString + otpSelectString + ",SourceFileName [QueueComment] FROM AI.AllowanceAndOTPSource s";
            ExecuteSQLQuery(otpSrcToQueueQuery);


            //bbiTrackerPreProcess_ItemClick(sender, e);
            //bbiTrackerQueue_ItemClick(sender, e);

            //XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.FinancialQueue", typeof(AIFinancialQueue));
            //focusGridToReadView(xpCol);
        }

        private void bbiMoveAbsencesToQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            string srcToQueueQuery = "";
            string insertString = "INSERT INTO AI.LeaveTransactionQueue(StatusCode,DateCreated,LastChanged";
            string selectString = "SELECT 'New' [StatusCode],GETDATE() [DateCreated],GETDATE() [LastChanged]";

            DataTable dt = SQLQueryToDataTable("SELECT * FROM AI.QueueMapping");
            foreach (DataRow dr in dt.Rows)
            {
                string qType = dr["QueueType"].ToString();
                string mapType = dr["MappingType"].ToString();
                string srcField = dr["SourceField"].ToString();
                if (srcField == "" || srcField == null) { srcField = "''"; } else { srcField = "s." + srcField; }
                string tgtField = dr["TargetField"].ToString();
                string tgtDataType = dr["TargetFieldDataType"].ToString();
                string leftConvertText = ""; string rightConvertText = "";
                if (tgtDataType != "") { leftConvertText = "CONVERT(" + tgtDataType + ","; rightConvertText = ")"; } else { }
                string tgtDataFormat = dr["TargetFieldDataFormat"].ToString();
                if (tgtDataFormat != "") { rightConvertText = "," + tgtDataFormat + ")"; } else { }
                string tgtLength = dr["TargetFieldMaxLength"].ToString();
                string leftLenText = ""; string rightLenText = "";
                if (tgtLength != "") { leftLenText = "LEFT("; rightLenText = "," + tgtLength + ")"; } else { }
                string defaultVal = dr["DefaultValue"].ToString();
                string sqlStatement = dr["SQLStatement"].ToString();
                string catStatement = dr["CatalogStatement"].ToString();

                switch (qType)
                {
                    case "Leave":
                        insertString = insertString + "," + tgtField;
                        switch (mapType)
                        {
                            case "Direct": selectString = selectString + "," + leftLenText + leftConvertText + srcField + rightConvertText + rightLenText + " [" + tgtField + "]"; break;
                            case "Catalog": selectString = selectString + "," + leftConvertText + "(SELECT TOP 1 m.TargetValue FROM AI.CatalogMapping m WHERE " + srcField + " = m.SourceValue AND m.CatalogType = 'Leave Batch')" + rightConvertText + " [" + tgtField + "]"; break;
                            case "DefaultValue": selectString = selectString + "," + defaultVal + " [" + tgtField + "]"; break;
                            case "DefaultValueIfNull": selectString = selectString + "," + leftConvertText + ",ISNULL(" + srcField + "," + defaultVal + ")" + rightConvertText + " [" + tgtField + "]"; break;
                            case "SQLStatement": selectString = selectString + "," + sqlStatement + " [" + tgtField + "]"; break;
                            case "CatalogStatement": selectString = selectString + "," + catStatement + " [" + tgtField + "]"; break;
                            default: selectString = selectString + "," + leftLenText + leftConvertText + srcField + rightConvertText + rightLenText + " [" + tgtField + "]"; break;
                        }
                        break;
                }
            }

            //Financial Queue
            insertString = insertString + ",QueueComment) ";
            srcToQueueQuery = insertString + selectString + ",SourceFileName [QueueComment] FROM AI.AbsenceSource s";
            ExecuteSQLQuery(srcToQueueQuery);


            //bbiTrackerPreProcess_ItemClick(sender, e);
            //bbiTrackerQueue_ItemClick(sender, e);

            //XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.LeaveTransactionQueue", typeof(AILeaveTransactionQueue));
            //focusGridToReadView(xpCol);
        }

        private void bbiValidateEmployeeQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            ExecuteSQLQuery("EXEC [AI].[EmployeeBatchValidations]");

            XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.EmployeeQueue", typeof(AIEmployeeQueue));
            focusGridToEditableView(xpCol);
        }

        private void BbiValidateLveBalQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            ExecuteSQLQuery("EXEC [AI].[LeaveBalanceValidations]");

            XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.LeaveBalanceQueue", typeof(AILeaveBalanceQueue));
            focusGridToEditableView(xpCol);
        }

        private void bbiProcessEmployee_ItemClick(object sender, ItemClickEventArgs e)
        {
            ExecuteSQLQuery("EXEC [AI].[ProcessEmployeeQueue]");

            //XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.EmployeeQueue", typeof(AIEmployeeQueue));
            //focusGridToReadView(xpCol);
        }

        private void bbiProcessFinancials_ItemClick(object sender, ItemClickEventArgs e)
        {
            ExecuteSQLQuery("EXEC [AI].[ProcessFinancialQueue]");

            //XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.FinancialQueue", typeof(AIFinancialQueue));
            //focusGridToReadView(xpCol);
        }

        private void BbiMoveLveTransToBalQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            ExecuteSQLQuery("EXEC [AI].[LeaveTransactionToBalanceQueue]");
        }

        private void bbiProcessLeave_ItemClick(object sender, ItemClickEventArgs e)
        {
            ExecuteSQLQuery("EXEC [AI].[ProcessLeaveQueue]");

            //XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.LeaveBalanceQueue", typeof(AILeaveBalanceQueue));
            //focusGridToReadView(xpCol);
        }


        /// <summary>
        /// Steps for tracking:
        /// If a record does not exist for the source queue OID with the specific field name, create a new record
        /// Update the tracker with pre process values, queue values and thereafter post process values
        /// </summary>
        public void UpdateTrackerByColName(DataTable src, string trackType, string qType)
        {
            try
            {
                if (src.Rows.Count > 0)
                {
                    DataTable trk = SQLQueryToDataTable("SELECT DISTINCT SourceOID, FieldName FROM AI.EventTracker");
                    foreach (DataRow dr in src.Rows)
                    {
                        foreach (DataColumn col in src.Columns)
                        {
                            if (dr[col.Ordinal].ToString() == "" || col.ColumnName == "OID" || col.ColumnName == "EventCode" || col.ColumnName == "EventDescription" || col.ColumnName == "EventSequenceID" || col.ColumnName == "EffectiveStartDate" || col.ColumnName == "EffectiveEndDate" || col.ColumnName == "OptimisticLockField" || col.ColumnName == "GCRecord" || col.ColumnName == "LastChanged" || col.ColumnName == "QueueComment" || col.ColumnName == "QueueFilter" || col.ColumnName == "StatusCode" || col.ColumnName == "StatusMessage" || col.ColumnName == "WarningCode" || col.ColumnName == "WarningMessage" || col.ColumnName == "ErrorCode" || col.ColumnName == "ErrorMessage")
                            { }
                            else
                            {
                                var k = (from r in trk.Rows.OfType<DataRow>() where r["SourceOID"].ToString() == dr["OID"].ToString() && r["FieldName"].ToString() == col.ColumnName select r).FirstOrDefault();
                                if (k == null)
                                {
                                    string trIns = "INSERT INTO AI.EventTracker (QueueType,TrackerComment,TrackerCreatedDate,SourceOID,SourceComment,FieldName," + trackType + ") VALUES ('" + qType + "'";
                                    trIns = trIns + ",NULL,GETDATE()," + dr["OID"].ToString() + ",'" + dr["QueueComment"].ToString() + "','" + col.ColumnName + "','" + dr[col.Ordinal].ToString() + "') ";
                                    ExecuteSQLQuery(trIns);
                                }
                                else
                                {
                                    string upd = "UPDATE AI.EventTracker SET " + trackType + " = '" + dr[col.Ordinal].ToString() + "' WHERE SourceOID = " + dr["OID"].ToString() + " AND FieldName = '" + col.ColumnName + "'";
                                    ExecuteSQLQuery("UPDATE AI.EventTracker SET " + trackType + " = '" + dr[col.Ordinal].ToString() + "' WHERE SourceOID = " + dr["OID"].ToString() + " AND FieldName = '" + col.ColumnName + "'");
                                }
                            }
                        }
                    }
                }
                else
                { }
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }


        public void UpdateTrackerByFieldName(DataTable src, string trackType, string qType)
        {
            try
            {
                if (src.Rows.Count > 0)
                {
                    DataTable trk = SQLQueryToDataTable("SELECT DISTINCT SourceOID, FieldName FROM AI.EventTracker");
                    foreach (DataRow dr in src.Rows)
                    {
                        string fldName = dr[2].ToString();
                        string fldVal = dr[3].ToString();

                        var k = (from r in trk.Rows.OfType<DataRow>() where r["SourceOID"].ToString() == dr["OID"].ToString() && r["FieldName"].ToString() == fldName select r).FirstOrDefault();
                        if (k == null)
                        {
                            string trIns = "INSERT INTO AI.EventTracker (QueueType,TrackerComment,TrackerCreatedDate,SourceOID,SourceComment,FieldName," + trackType + ") VALUES ('" + qType + "'";
                            trIns = trIns + ",NULL,GETDATE()," + dr["OID"].ToString() + ",'" + dr["QueueComment"].ToString() + "','" + fldName + "','" + fldVal + "') ";
                            ExecuteSQLQuery(trIns);
                        }
                        else
                        {
                            string upd = "UPDATE AI.EventTracker SET " + trackType + " = '" + fldVal + "' WHERE SourceOID = " + dr["OID"].ToString() + " AND FieldName = '" + fldName + "'";
                            ExecuteSQLQuery("UPDATE AI.EventTracker SET " + trackType + " = '" + fldVal + "' WHERE SourceOID = " + dr["OID"].ToString() + " AND FieldName = '" + fldName + "'");
                        }
                    }
                }
                else
                { }
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void trackerPreProcess(string[] eventType)
        {
            //Need to find a way to run the tracker with an indicator for which Queue it should process.

            foreach (string type in eventType)
            {
                string oidInQueue = "0";
                using (DataTable q = SQLQueryToDataTable("SELECT OID FROM AI.EmployeeQueue WHERE StatusCode = 'N'"))
                {
                    foreach (DataRow qr in q.Rows)
                    {
                        oidInQueue = oidInQueue + "," + qr["OID"].ToString();
                    }
                }

                using (DataTable dt = SQLQueryToDataTable("SELECT q.OID, q.QueueComment, sn.* FROM AI.EmployeeDetailSnapshot sn LEFT JOIN AI.EmployeeQueue q ON q.EmployeeCode = sn.EmployeeCode WHERE q.OID IN (" + oidInQueue + ")"))
                {
                    UpdateTrackerByColName(dt, "PreProcessValue", "Employee");
                }

                string subQry = "SELECT DISTINCT eq.OID,eq.QueueComment,CASE sn.SubQueueTableType WHEN 'HierarchyHeader' THEN '(H)' WHEN 'Contact' THEN '(C)' WHEN 'EmployeeGenericFields' THEN '(G)' END + sn.SubQueueType,sn.SubQueueValue ";
                subQry = subQry + "FROM AI.EmployeeSubDetailSnapshot sn INNER JOIN AI.EmployeeSubQueue q ON q.EmployeeCode = sn.EmployeeCode INNER JOIN AI.EmployeeQueue eq ON eq.EmployeeCode = q.EmployeeCode WHERE eq.StatusCode = 'N' ";
                using (DataTable sdt = SQLQueryToDataTable(subQry))
                {
                    UpdateTrackerByFieldName(sdt, "PreProcessValue", "EmployeeSub");
                }

            }

            //MessageBox.Show("PreProcess Tracking Complete", "Tracker", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void bbiTrackerPreProcess_ItemClick(object sender, ItemClickEventArgs e)
        {
            //Need to find a way to run the tracker with an indicator for which Queue it should process.

            string oidInQueue = "0";
            using (DataTable q = SQLQueryToDataTable("SELECT OID FROM AI.EmployeeQueue WHERE StatusCode = 'N'"))
            {
                foreach (DataRow qr in q.Rows)
                {
                    oidInQueue = oidInQueue + "," + qr["OID"].ToString();
                }
            }

            using (DataTable dt = SQLQueryToDataTable("SELECT q.OID, q.QueueComment, sn.* FROM AI.EmployeeDetailSnapshot sn LEFT JOIN AI.EmployeeQueue q ON q.EmployeeCode = sn.EmployeeCode WHERE q.OID IN (" + oidInQueue + ")"))
            {
                UpdateTrackerByColName(dt, "PreProcessValue", "Employee");
            }

            string subQry = "SELECT DISTINCT eq.OID,eq.QueueComment,CASE sn.SubQueueTableType WHEN 'HierarchyHeader' THEN '(H)' WHEN 'Contact' THEN '(C)' WHEN 'EmployeeGenericFields' THEN '(G)' END + sn.SubQueueType,sn.SubQueueValue ";
            subQry = subQry + "FROM AI.EmployeeSubDetailSnapshot sn INNER JOIN AI.EmployeeSubQueue q ON q.EmployeeCode = sn.EmployeeCode INNER JOIN AI.EmployeeQueue eq ON eq.EmployeeCode = q.EmployeeCode WHERE eq.StatusCode = 'N' ";
            using (DataTable sdt = SQLQueryToDataTable(subQry))
            {
                UpdateTrackerByFieldName(sdt, "PreProcessValue", "EmployeeSub");
            }

            //MessageBox.Show("PreProcess Tracking Complete", "Tracker", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void bbiTrackerQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            using (DataTable dt = SQLQueryToDataTable("SELECT * FROM AI.EmployeeQueue WHERE StatusCode = 'N'"))
            {
                UpdateTrackerByColName(dt, "QueueValue", "Employee");
            }

            string subQry = "SELECT eq.OID,eq.QueueComment,CASE q.SubQueueTableType WHEN 'HierarchyHeader' THEN '(H)' WHEN 'Contact' THEN '(C)' WHEN 'EmployeeGenericFields' THEN '(G)' END + q.SubQueueType,q.SubQueueValue ";
            subQry = subQry + "FROM AI.EmployeeSubQueue q INNER JOIN AI.EmployeeQueue eq ON eq.EmployeeCode = q.EmployeeCode WHERE eq.StatusCode = 'N' ";
            using (DataTable sdt = SQLQueryToDataTable(subQry))
            {
                UpdateTrackerByFieldName(sdt, "QueueValue", "EmployeeSub");
            }

            //MessageBox.Show("Queue Tracking Complete", "Tracker", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void bbiTrackerPostProcess_ItemClick(object sender, ItemClickEventArgs e)
        {
            string postSQLQuery = "SELECT h.OID,h.QueueComment,sn.* ";
            postSQLQuery = postSQLQuery + "FROM AI.EmployeeQueueHistory h INNER JOIN AI.EmployeeDetailSnapshot sn ON sn.EmployeeCode = h.EmployeeCode ";
            postSQLQuery = postSQLQuery + "WHERE REPLACE(SUBSTRING(h.QueueComment,9,11),'-','_') IN (SELECT RIGHT(Code,11) FROM TakeOn.EmployeeTakeOnInstance WHERE TakeOnStatus NOT IN (2,14)) AND h.EmployeeCode IN (SELECT DISTINCT QueueValue FROM AI.EventTracker WHERE FieldName = 'EmployeeCode') ";
            using (DataTable dt = SQLQueryToDataTable(postSQLQuery))
            {
                UpdateTrackerByColName(dt, "PostProcessValue", "Employee");
            }

            string subQry = "SELECT DISTINCT h.OID,h.QueueComment,CASE sn.SubQueueTableType WHEN 'HierarchyHeader' THEN '(H)' WHEN 'Contact' THEN '(C)' WHEN 'EmployeeGenericFields' THEN '(G)' END + sn.SubQueueType,sn.SubQueueValue ";
            subQry = subQry + "FROM AI.EmployeeSubDetailSnapshot sn INNER JOIN AI.EmployeeSubQueueHistory q ON q.EmployeeCode = sn.EmployeeCode INNER JOIN AI.EmployeeQueueHistory h ON h.EmployeeCode = q.EmployeeCode ";
            subQry = subQry + "WHERE REPLACE(SUBSTRING(h.QueueComment,9,11),'-','_') IN (SELECT RIGHT(Code,11) FROM TakeOn.EmployeeTakeOnInstance WHERE TakeOnStatus NOT IN (2,14)) AND h.EmployeeCode IN (SELECT DISTINCT QueueValue FROM AI.EventTracker WHERE FieldName = 'EmployeeCode') ";
            using (DataTable sdt = SQLQueryToDataTable(subQry))
            {
                UpdateTrackerByFieldName(sdt, "QueueValue", "EmployeeSub");
            }

            MessageBox.Show("PostProcess Tracking Complete", "Tracker", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void bbiEmployeeRunAll_ItemClick(object sender, ItemClickEventArgs e)
        {
            try { bbiImportCSVEmployee_ItemClick(sender, e); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure during new file import", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            try { bbiMoveEmployeeToQueue_ItemClick(sender, e); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure moving source data to queue", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            try { bbiValidateEmployeeQueue_ItemClick(sender, e); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure during queue validation", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            try { bbiProcessEmployee_ItemClick(sender, e); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure moving batch to Sage", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            try { BbiEmpIssues_ItemClick(sender, e); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure displaying Error Records", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            MessageBox.Show("Process Finished" + Environment.NewLine + "Successful records will be available for processing in Sage", "", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void BbiAllAndOTPRunAll_ItemClick_1(object sender, ItemClickEventArgs e)
        {
            try { bbiImportCSVAllAndOTP_ItemClick(sender, e); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure during new file import", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            try { bbiMoveAllowToQueue_ItemClick(sender, e); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure moving source data to queue", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            try { ExecuteSQLQuery("EXEC AI.ValidateBatchTemplates"); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure to refresh batch templates", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            try { bbiProcessFinancials_ItemClick(sender, e); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure moving batch to Sage", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            try { BbiPayslipIssues_ItemClick(sender, e); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure displaying Error Records", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            MessageBox.Show("Process Finished" + Environment.NewLine + "Successful records will be available for processing in Sage", "", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void BbiAbsenceRunAll_ItemClick_1(object sender, ItemClickEventArgs e)
        {
            try { bbiImportCSVAbsences_ItemClick(sender, e); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure during new file import", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            try { bbiMoveAbsencesToQueue_ItemClick(sender, e); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure moving source data to queue", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            try { BbiMoveLveTransToBalQueue_ItemClick(sender, e); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure moving source data to queue", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            try { BbiValidateLveBalQueue_ItemClick(sender, e); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure during queue validation", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            try { ExecuteSQLQuery("EXEC AI.ValidateBatchTemplates"); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure to refresh batch templates", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            try { bbiProcessLeave_ItemClick(sender, e); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure moving batch to Sage", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            try { BbiLeaveIssues_ItemClick(sender, e); } catch (Exception ex) { MessageBox.Show(ex.Source + " - " + ex.Message, "Failure displaying Error Records", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning); }
            MessageBox.Show("Process Finished" + Environment.NewLine + "Successful records will be available for processing in Sage", "", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void BbiOpenUserGuide_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                System.Diagnostics.Process.Start(@".\UserGuide\User Guide.pdf", "/A \"page=2\"");

                //System.Diagnostics.Process myProcess = new System.Diagnostics.Process();
                //myProcess.StartInfo.FileName = ".\\UserGuide\\User Guide.pdf";
                //myProcess.StartInfo.Arguments = "/A \"page=2\" \".\\UserGuide\\User Guide.pdf\"";
                //myProcess.Start();

                //System.Diagnostics.ProcessStartInfo stpdf = new System.Diagnostics.ProcessStartInfo(@".\UserGuide\User Guide.pdf", "/A \"page=3\" \".\\UserGuide\\User Guide.pdf");
                //System.Diagnostics.Process.Start(stpdf);
            }
            catch (Exception ex) { MessageBox.Show("Error: " + ex.Source + " - " + ex.Message); }
        }

        private void BbiRefreshValidations_ItemClick(object sender, ItemClickEventArgs e)
        {
            try { refreshValidations(); }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void refreshValidations()
        {
            try
            {
                ExecuteSQLQuery("EXEC AI.RefreshValidationWarnings");
                XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.ValidationWarnings", typeof(AIValidationWarnings));
                focusGridToEditableView(xpCol);

                gvwEditable.Columns.ColumnByFieldName("ValidationMessage").Group();
                gvwEditable.Columns.ColumnByFieldName("CountryCode").SortIndex = 0;
            }
            catch
            {
                MessageBox.Show("Refresh Error: No database connection or data could not be refreshed on start-up.", "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void BbiEmpIssues_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.EmployeeQueue", typeof(AIEmployeeQueue));
                focusGridToReadView(xpCol);

                int i = 0;
                while (gvwEditable.VisibleColumns.Count() > 0)
                {
                    gvwEditable.Columns[i].Visible = false;
                    i = i + 1;
                }

                gvwEditable.Columns.ColumnByFieldName("DateCreated").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("QueueComment").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("EmployeeCode").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("EventDescription").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("ErrorCode").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("ErrorMessage").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("StatusMessage").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("StatusCode").Visible = true;

                gvwEditable.Columns.ColumnByFieldName("StatusCode").Group();
                gvwEditable.Columns.ColumnByFieldName("StatusMessage").Group();
                gvwEditable.Columns.ColumnByFieldName("StatusCode").SortOrder = DevExpress.Data.ColumnSortOrder.Ascending;
                gvwEditable.Columns.ColumnByFieldName("StatusMessage").SortOrder = DevExpress.Data.ColumnSortOrder.Ascending;
                gvwEditable.Columns.ColumnByFieldName("ErrorMessage").SortOrder = DevExpress.Data.ColumnSortOrder.Ascending;
                gvwEditable.Columns.ColumnByFieldName("EmployeeCode").SortOrder = DevExpress.Data.ColumnSortOrder.Ascending;
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void BbiPayslipIssues_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.FinancialQueue", typeof(AIFinancialQueue));
                focusGridToReadView(xpCol);

                int i = 0;
                while (gvwEditable.VisibleColumns.Count() > 0)
                {
                    gvwEditable.Columns[i].Visible = false;
                    i = i + 1;
                }

                gvwEditable.Columns.ColumnByFieldName("DateCreated").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("QueueComment").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("EmployeeCode").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("EventDescription").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("ErrorCode").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("ErrorMessage").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("StatusMessage").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("StatusCode").Visible = true;

                gvwEditable.Columns.ColumnByFieldName("StatusCode").Group();
                gvwEditable.Columns.ColumnByFieldName("StatusMessage").Group();
                gvwEditable.Columns.ColumnByFieldName("StatusCode").SortOrder = DevExpress.Data.ColumnSortOrder.Ascending;
                gvwEditable.Columns.ColumnByFieldName("StatusMessage").SortOrder = DevExpress.Data.ColumnSortOrder.Ascending;
                gvwEditable.Columns.ColumnByFieldName("ErrorMessage").SortOrder = DevExpress.Data.ColumnSortOrder.Ascending;
                gvwEditable.Columns.ColumnByFieldName("EmployeeCode").SortOrder = DevExpress.Data.ColumnSortOrder.Ascending;
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void BbiLeaveIssues_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                XPCollection xpCol = dynamicXPCollection(ConnectionString, "AI.LeaveBalanceQueue", typeof(AILeaveBalanceQueue));
                focusGridToReadView(xpCol);

                int i = 0;
                while (gvwEditable.VisibleColumns.Count() > 0)
                {
                    gvwEditable.Columns[i].Visible = false;
                    i = i + 1;
                }

                gvwEditable.Columns.ColumnByFieldName("DateCreated").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("QueueComment").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("EmployeeCode").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("EventDescription").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("ErrorCode").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("ErrorMessage").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("StatusMessage").Visible = true;
                gvwEditable.Columns.ColumnByFieldName("StatusCode").Visible = true;

                gvwEditable.Columns.ColumnByFieldName("StatusCode").Group();
                gvwEditable.Columns.ColumnByFieldName("StatusMessage").Group();
                gvwEditable.Columns.ColumnByFieldName("StatusCode").SortOrder = DevExpress.Data.ColumnSortOrder.Ascending;
                gvwEditable.Columns.ColumnByFieldName("StatusMessage").SortOrder = DevExpress.Data.ColumnSortOrder.Ascending;
                gvwEditable.Columns.ColumnByFieldName("ErrorMessage").SortOrder = DevExpress.Data.ColumnSortOrder.Ascending;
                gvwEditable.Columns.ColumnByFieldName("EmployeeCode").SortOrder = DevExpress.Data.ColumnSortOrder.Ascending;
            }
            catch (Exception myException)
            {
                MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
        }

        private void BbiMappingIssues_ItemClick(object sender, ItemClickEventArgs e)
        {
            refreshValidations();
        }



        private void focusGridToDTReadView(DataTable dt)
        {
            
            gvwEditable.ClearGrouping();
            gvwEditable.ClearSorting();
            gvwEditable.ClearColumnsFilter();
            navFrame.SelectedPageIndex = 1;
            gridControl.DataSource = null;
            gridControl.DataSource = dt;
            gridControl.MainView.PopulateColumns();
            gvwEditable.Columns[0].Visible = false;
            //for (int c = 0; c <= gvwEditable.VisibleColumns.Count; c++)
            //{
            //    gvwEditable.Columns[c].MaxWidth = 175;
            //}
            gvwEditable.BestFitColumns();
            gvwEditable.OptionsView.NewItemRowPosition = NewItemRowPosition.None;
            gvwEditable.OptionsBehavior.Editable = false;
            gvwEditable.OptionsBehavior.ReadOnly = true;
            bsiRecordsCount.Caption = "RECORDS : " + gridControl.DefaultView.DataRowCount;
            gvwEditable.Focus();
        }

        private void BbiEmpSourceHistory_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                DataTable dt = SQLQueryToDataTable("SELECT * FROM AI.EmployeeSourceHistory");
                focusGridToDTReadView(dt);

                gvwEditable.Columns.ColumnByFieldName("SourceFileName").Group();
                gvwEditable.Columns.ColumnByFieldName("SourceFileName").SortIndex = 0;
                gvwEditable.Columns.ColumnByFieldName("SourceFileName").SortOrder = DevExpress.Data.ColumnSortOrder.Descending;
            }
            catch (Exception myException)
            { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiAllAndOTPSourceHistory_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                DataTable dt = SQLQueryToDataTable("SELECT * FROM AI.AllowanceAndOTPSourceHistory");
                focusGridToDTReadView(dt);

                gvwEditable.Columns.ColumnByFieldName("SourceFileName").Group();
                gvwEditable.Columns.ColumnByFieldName("SourceFileName").SortIndex = 0;
                gvwEditable.Columns.ColumnByFieldName("SourceFileName").SortOrder = DevExpress.Data.ColumnSortOrder.Descending;
            }
            catch (Exception myException)
            { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiAbsenceSourceHistory_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                DataTable dt = SQLQueryToDataTable("SELECT * FROM AI.AbsenceSourceHistory");
                focusGridToDTReadView(dt);

                gvwEditable.Columns.ColumnByFieldName("SourceFileName").Group();
                gvwEditable.Columns.ColumnByFieldName("SourceFileName").SortIndex = 0;
                gvwEditable.Columns.ColumnByFieldName("SourceFileName").SortOrder = DevExpress.Data.ColumnSortOrder.Descending;
            }
            catch (Exception myException)
            { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiEmpQueueHistory_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                DataTable dt = SQLQueryToDataTable("SELECT * FROM AI.EmployeeQueueHistory");
                focusGridToDTReadView(dt);

                gvwEditable.Columns.ColumnByFieldName("DateCreated").Group();
                gvwEditable.Columns.ColumnByFieldName("DateCreated").SortIndex = 0;
                gvwEditable.Columns.ColumnByFieldName("DateCreated").SortOrder = DevExpress.Data.ColumnSortOrder.Descending;
            }
            catch (Exception myException)
            { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiEmpSubQueueHistory_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                DataTable dt = SQLQueryToDataTable("SELECT * FROM AI.EmployeeSubQueueHistory");
                focusGridToDTReadView(dt);

                gvwEditable.Columns.ColumnByFieldName("DateCreated").Group();
                gvwEditable.Columns.ColumnByFieldName("DateCreated").SortIndex = 0;
                gvwEditable.Columns.ColumnByFieldName("DateCreated").SortOrder = DevExpress.Data.ColumnSortOrder.Descending;
            }
            catch (Exception myException)
            { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiPayslipQueueHistory_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                DataTable dt = SQLQueryToDataTable("SELECT * FROM AI.FinancialQueueHistory");
                focusGridToDTReadView(dt);

                gvwEditable.Columns.ColumnByFieldName("DateCreated").Group();
                gvwEditable.Columns.ColumnByFieldName("DateCreated").SortIndex = 0;
                gvwEditable.Columns.ColumnByFieldName("DateCreated").SortOrder = DevExpress.Data.ColumnSortOrder.Descending;
            }
            catch (Exception myException)
            { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiLveTransQueueHistory_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                DataTable dt = SQLQueryToDataTable("SELECT * FROM AI.LeaveTransactionQueueHistory");
                focusGridToDTReadView(dt);

                gvwEditable.Columns.ColumnByFieldName("DateCreated").Group();
                gvwEditable.Columns.ColumnByFieldName("DateCreated").SortIndex = 0;
                gvwEditable.Columns.ColumnByFieldName("DateCreated").SortOrder = DevExpress.Data.ColumnSortOrder.Descending;
            }
            catch (Exception myException)
            { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiLveBalQueueHistory_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                viewData("SELECT * FROM AI.LeaveBalanceQueueHistory", "DateCreated", "DateCreated", DevExpress.Data.ColumnSortOrder.Ascending);
            }
            catch (Exception myException)
            { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void viewData(string sqlSelect,string groupCol, string sortCol, DevExpress.Data.ColumnSortOrder sortOrder)
        {
            try
            {
                DataTable dt = SQLQueryToDataTable(sqlSelect);
                focusGridToDTReadView(dt);
                gvwEditable.Columns.ColumnByFieldName(groupCol).Group();
                gvwEditable.Columns.ColumnByFieldName(sortCol).SortOrder = sortOrder;
            }
            catch (Exception myException)
            { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiViewEmpSource_ItemClick(object sender, ItemClickEventArgs e)
        {
            try { viewData("SELECT * FROM AI.EmployeeSource", "SourceFileName", "SourceFileName",DevExpress.Data.ColumnSortOrder.Descending);}
            catch (Exception myException) { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiViewAllAndOTPSource_ItemClick(object sender, ItemClickEventArgs e)
        {
            try { viewData("SELECT * FROM AI.AllowanceAndOTPSource", "SourceFileName", "SourceFileName", DevExpress.Data.ColumnSortOrder.Descending); }
            catch (Exception myException) { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiViewAbsenceSource_ItemClick(object sender, ItemClickEventArgs e)
        {
            try { viewData("SELECT * FROM AI.AbsenceSource", "SourceFileName", "SourceFileName", DevExpress.Data.ColumnSortOrder.Descending); }
            catch (Exception myException) { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiViewEmpMasterQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            try { viewData("SELECT * FROM AI.EmployeeQueue", "DateCreated", "EmployeeCode", DevExpress.Data.ColumnSortOrder.Ascending); }
            catch (Exception myException) { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiViewEmpSubQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            try { viewData("SELECT * FROM AI.EmployeeSubQueue", "DateCreated", "EmployeeCode", DevExpress.Data.ColumnSortOrder.Ascending); }
            catch (Exception myException) { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiViewPayslipQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            try { viewData("SELECT * FROM AI.FinancialQueue", "DateCreated", "EmployeeCode", DevExpress.Data.ColumnSortOrder.Ascending); }
            catch (Exception myException) { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiViewLeaveTransQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            try { viewData("SELECT * FROM AI.LeaveTransactionQueue", "DateCreated", "EmployeeCode", DevExpress.Data.ColumnSortOrder.Ascending); }
            catch (Exception myException) { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiViewLeaveBalQueue_ItemClick(object sender, ItemClickEventArgs e)
        {
            try { viewData("SELECT * FROM AI.LeaveBalanceQueue", "DateCreated", "EmployeeCode", DevExpress.Data.ColumnSortOrder.Ascending); }
            catch (Exception myException) { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiResetSelectedRows_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                //string sourceTableName;

                //if (gvwEditable.DataSource.GetType().Name == "XPCollection")
                //{ sourceTableName = ((XPCollection)gvwEditable.DataSource).GetObjectClassInfo().TableName; }
                //else { sourceTableName = ((DataView)gvwEditable.DataSource).Table.TableName;
                //    sourceTableName = 
                //}

                //foreach (int selectedRow in gvwEditable.GetSelectedRows())
                //{
                //    var pkID = gvwEditable.GetRowCellValue(selectedRow, gvwEditable.Columns[0]);
                //    ExecuteSQLQuery("UPDATE " + sourceTableName + " SET StatusCode = 'New' WHERE OID = ISNULL(" + pkID.ToString() + ",0)");
                //}
                gvwEditable.RefreshData();
            }
            catch (Exception myException) { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
        }

        private void BbiRemoveSelectedRows_ItemClick(object sender, ItemClickEventArgs e)
        {
            try
            {
                string sourceTableName;

                if (gvwEditable.DataSource.GetType().IsClass == true)
                { sourceTableName = ((XPCollection)gvwEditable.DataSource).GetObjectClassInfo().TableName; }
                else { sourceTableName = ((DataTable)gvwEditable.DataSource).TableName; }

                foreach (int selectedRow in gvwEditable.GetSelectedRows())
                {
                    var pkID = gvwEditable.GetRowCellValue(selectedRow, gvwEditable.Columns[0]);
                    ExecuteSQLQuery(
                            "INSERT INTO " + sourceTableName + "History SELECT * FROM " + sourceTableName + " WHERE OID = ISNULL(" + pkID.ToString() + ",0)"
                            + "DELETE FROM " + sourceTableName + " WHERE OID = ISNULL(" + pkID.ToString() + ",0)"
                            );
                }
                gvwEditable.RefreshData();
            }
            catch (Exception myException) { MessageBox.Show("Application Error:" + myException.Message, "Failed", MessageBoxButtons.OK, MessageBoxIcon.Stop); }
}

        
    }
}



