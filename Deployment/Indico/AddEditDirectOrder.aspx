<%@ Page Title="" Language="C#" MasterPageFile="~/Indico.Master" AutoEventWireup="true" CodeBehind="AddEditDirectOrder.aspx.cs" Inherits="Indico.AddEditDirectOrder" %>

<asp:Content ID="Content1" ContentPlaceHolderID="iContentPlaceHolder" runat="server">
    <style>
        .control-group {
            margin-bottom: 2px !important;
        }

        legend .control-group {
            margin-left: 2.5641%;
        }

        legend .control-label {
            margin-top: 12px !important;
        }

        .table .header {
            font-weight: bold;
        }

        .table th, .table td {
            line-height: 12px !important;
        }
    </style>
    <!-- Page -->
    <div class="page">
        <!-- Page Header -->
        <div class="page-header">
            <h3>Order Overview Form</h3>
        </div>
        <!-- / -->
        <!-- Page Content -->
        <div class="page-content">
            <div class="row-fluid">
                <!-- Page Data -->
                <div class="span12">
                    <div class="span6">
                        <asp:Repeater ID="rptItem" runat="server" OnItemDataBound="rptItem_ItemDataBound" OnItemCommand="rptItem_ItemCommand">
                            <ItemTemplate>
                                <legend>
                                    <asp:Literal ID="litItemNumber" runat="server"></asp:Literal>
                                    <asp:LinkButton ID="lnkRemove" runat="server" CommandName="Remove" Text=" X "></asp:LinkButton>
                                    <legend>
                                        <div class="span12">
                                            <div class="span6">
                                                <div class="control-group">
                                                    <label class="control-label">Part Number</label>
                                                    <div class="controls">
                                                        <asp:TextBox ID="TextBox1" runat="server"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="span6">
                                                <div class="control-group">
                                                    <label class="control-label">Pattern Number</label>
                                                    <div class="controls">
                                                        <asp:TextBox ID="TextBox2" runat="server"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="span12">
                                            <div class="control-group">
                                                <label class="control-label">Garment Style</label>
                                                <div class="controls">
                                                    <asp:TextBox ID="TextBox3" runat="server"></asp:TextBox>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="span12">
                                            <div class="span6">
                                                <div class="control-group">
                                                    <label class="control-label">Fabric</label>
                                                    <div class="controls">
                                                        <asp:TextBox ID="TextBox4" runat="server"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="span6">
                                                <div class="control-group">
                                                    <label class="control-label">Pocketr</label>
                                                    <div class="controls">
                                                        <label class="radio inline">
                                                            Yes<asp:RadioButton ID="RadioButton1" runat="server" GroupName="grpYesNo" />
                                                        </label>
                                                        <label class="radio inline">
                                                            No<asp:RadioButton ID="RadioButton2" runat="server" GroupName="grpYesNo" />
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="span12">
                                            <asp:DataGrid ID="dgItem" runat="server" CssClass="table" AllowPaging="false" AutoGenerateColumns="false" GridLines="None" ShowFooter="true" OnItemDataBound="dgItem_ItemDataBound">
                                                <HeaderStyle CssClass="header" />
                                                <FooterStyle CssClass="footer" />
                                                <Columns>
                                                    <asp:TemplateColumn HeaderText="Adult/Youth">
                                                        <ItemTemplate>
                                                            <asp:Literal ID="litAgeGroup" runat="server"></asp:Literal>
                                                        </ItemTemplate>
                                                        <FooterTemplate>
                                                            <asp:Literal ID="litSubTotal" runat="server">Sub Total</asp:Literal>
                                                        </FooterTemplate>
                                                    </asp:TemplateColumn>
                                                    <asp:TemplateColumn HeaderText="Size">
                                                        <ItemTemplate>
                                                            <asp:Literal ID="litSize" runat="server"></asp:Literal>
                                                        </ItemTemplate>
                                                    </asp:TemplateColumn>
                                                    <asp:TemplateColumn HeaderText="Quantity">
                                                        <ItemTemplate>
                                                            <asp:Literal ID="litQuantity" runat="server"></asp:Literal>
                                                        </ItemTemplate>
                                                        <FooterTemplate>
                                                            <asp:Literal ID="litFooterQuantity" runat="server"></asp:Literal>
                                                        </FooterTemplate>
                                                    </asp:TemplateColumn>
                                                    <asp:TemplateColumn HeaderText="Price">
                                                        <ItemTemplate>
                                                            <asp:Literal ID="litPrice" runat="server"></asp:Literal>
                                                        </ItemTemplate>
                                                    </asp:TemplateColumn>
                                                    <asp:TemplateColumn HeaderText="Value">
                                                        <ItemTemplate>
                                                            <asp:Literal ID="litValue" runat="server"></asp:Literal>
                                                        </ItemTemplate>
                                                        <FooterTemplate>
                                                            <asp:Literal ID="litFooterValue" runat="server" Text="testasdad"></asp:Literal>
                                                        </FooterTemplate>
                                                    </asp:TemplateColumn>
                                                </Columns>
                                            </asp:DataGrid>
                                        </div>
                                        <asp:HiddenField ID="hdnItemNumber" runat="server" Value="0" />
                            </ItemTemplate>
                        </asp:Repeater>
                        <div class="span11">
                            <div class="form-actions">
                                <button id="btnAddItem" runat="server" class="btn btn-success" onserverclick="btnAddItem_Click">
                                    <i class="icon-plus"></i>Insert New Item
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="span6">
                        <legend>
                            <div class="control-group">
                                <label class="control-label">MYOB Card File</label>
                                <div class="controls">
                                    <asp:DropDownList ID="DropDownList1" runat="server"></asp:DropDownList>
                                </div>
                            </div>
                        </legend>
                        <div class="span12">
                            <div class="span6">
                                <div class="control-group">
                                    <label class="control-label">Date</label>
                                    <div class="controls">
                                        <asp:TextBox ID="TextBox5" runat="server"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="span6">
                                <div class="control-group">
                                    <label class="control-label">Your Po.Ref Number</label>
                                    <div class="controls">
                                        <asp:TextBox ID="TextBox6" runat="server"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="span12">
                            <div class="control-group">
                                <label class="control-label">Please Tick Indicate</label>
                                <div class="controls">
                                    <label class="radio inline">
                                        Sample(s)<asp:RadioButton ID="RadioButton3" runat="server" GroupName="grpSOR" />
                                    </label>
                                    <label class="radio inline">
                                        Order<asp:RadioButton ID="RadioButton4" runat="server" GroupName="grpSOR" />
                                    </label>
                                    <label class="radio inline">
                                        Repeat Order<asp:RadioButton ID="RadioButton5" runat="server" GroupName="grpSOR" />
                                    </label>
                                </div>
                            </div>
                        </div>
                        <legend>Billing and Delivery Information</legend>
                        <div class="span12">
                            <div class="control-group">
                                <label class="control-label">Delivery Address Type</label>
                                <div class="controls">
                                    <label class="radio inline">
                                        Residential<asp:RadioButton ID="RadioButton6" runat="server" GroupName="grpRB" />
                                    </label>
                                    <label class="radio inline">
                                        Business<asp:RadioButton ID="RadioButton7" runat="server" GroupName="grpRB" />
                                    </label>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Company Name</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox7" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Address</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox8" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Suburb</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox9" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">State</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox10" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Contact</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox11" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Contact Phone</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox12" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Contact Email</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox13" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Job Name</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox14" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Date Required:</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox15" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Is this delivery date NON NEGOTIABLE?</label>
                                <div class="controls">
                                    <label class="radio inline">
                                        Yes<asp:RadioButton ID="RadioButton8" runat="server" GroupName="grpYN" />
                                    </label>
                                    <label class="radio inline">
                                        No<asp:RadioButton ID="RadioButton9" runat="server" GroupName="grpYN" />
                                    </label>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Delivery Option</label>
                                <div class="controls">
                                    <label class="radio inline">
                                        Road Freight<asp:RadioButton ID="RadioButton10" runat="server" GroupName="grpRA" />
                                    </label>
                                    <label class="radio inline">
                                        Airbag<asp:RadioButton ID="RadioButton11" runat="server" GroupName="grpRA" />
                                    </label>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Shipment Date</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox16" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Total</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox17" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Delivery charge:</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox18" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Artwork charge:</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox19" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Additional charges:</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox20" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">GST:</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox21" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Total price:</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox22" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label">Special Instructions:</label>
                                <div class="controls">
                                    <asp:TextBox ID="TextBox23" runat="server" TextMode="MultiLine" Rows="4"></asp:TextBox>
                                </div>
                            </div>
                            <div class="span11">
                                <div class="alert alert-error">
                                    <strong>PLEASE NOTE</strong>
                                    <p>
                                        THE MANUFACTURING LEAD TIME QUOTED IS DEPENDENT ON PROMPT APPROVAL OF THIS FORM. IF ART APPROVAL IS DELAYED A NEW DELIVERY DATE WILL BE ADVISED. CHANGES CANNOT BE MADE AFTER APPROVAL OF THIS FORM AND CANCELLATION FEES WILL APPLY FROM THIS POINT FORWARD.
                                    </p>
                                </div>
                                <div class="alert alert-error">
                                    <strong>PLEASE FORWARD A 50% DEPOSIT IMMEDIATELY</strong>
                                    <p>
                                        PRODUCTION OF ORDER WILL COMMENCE ONCE PAYMENT HAS BEEN RECEIVED. GOODS WILL BE DESPATCHED ONCE BALANCE OF PAYMENT HAS BEEN RECEIVED.
                                    </p>
                                </div>
                                <div class="alert alert-error">
                                    <strong>PLEASE NOTE</strong>
                                    <p>
                                        THIS ORDER IS NOW A LEGALLY BINDING CONTRACT AND INDICO PTY LTD HOLDS A BILL OF SALE OVER ANY UNPAID GOODS. THE CLIENT ACCEPTS AND ACKNOWLEDGES ALL TERMS AND CONDITIONS OF SALE.
                                    </p>
                                </div>
                                <div class="form-actions">
                                    <button id="btnSaveChanges" runat="server" class="btn btn-primary" type="submit" data-loading-text="Saving...">Save Changes</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- / -->
            </div>
        </div>
        <!-- / -->
    </div>
    <!-- / -->
</asp:Content>
