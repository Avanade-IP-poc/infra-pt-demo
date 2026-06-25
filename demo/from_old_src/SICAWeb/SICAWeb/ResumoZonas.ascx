<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ResumoZonas.ascx.vb" Inherits="ResumoZonas" %>
<%@ Register Src="MasterPage.master" TagName="MasterPage" TagPrefix="mp1" %>

<link href="Styles/refer.css" rel="stylesheet" type="text/css" />

<asp:Panel ID="Panel" runat="server" Width="99%" BorderColor="#C4DD9C" 
    BorderStyle="Solid" BorderWidth="1px">
    <table>
        <tr>
            <td>
                <asp:Label ID="lblTituloResumo" runat="server" CssClass="titulo" Text="Resumo das zonas" Width="99%"></asp:Label>
            </td>
            <td>&nbsp;</td>
            <td valign="middle">
                <asp:Label ID="lblTituloDetalhe" runat="server" CssClass="titulo" Width="80%"></asp:Label>
                <asp:ImageButton ID="ibFechaDetalhe" runat="server" Height="14px" ImageUrl="~/Images/Close2.bmp"
                    Visible="False" Width="35px" /></td>
        </tr>
        <tr>
            <td valign="top">
                <asp:GridView ID="gvZonas" runat="server" AutoGenerateColumns="False" CssClass="corpotexto" Width="100%">
                    <RowStyle CssClass="linhaimpar" />
                    <HeaderStyle CssClass="titulo" />
                    <AlternatingRowStyle CssClass="linhapar" />
                    <Columns>
			            <asp:TemplateField HeaderText="ID" SortExpression="ID" Visible="false">
		                    <ItemTemplate>
		                        <asp:Label ID="lblID" runat="server" Text='<%# Eval("idGeoZone") %>' ToolTip=''></asp:Label>
		                    </ItemTemplate>
		                </asp:TemplateField>
			            <asp:TemplateField HeaderText="Zona" SortExpression="Zona">
		                    <ItemTemplate>
		                        <asp:Label ID="lblZona" runat="server" Text='<%# Eval("Label") %>' ToolTip=''></asp:Label>
		                    </ItemTemplate>
		                </asp:TemplateField>
			            <asp:TemplateField HeaderText="N&#186; de pessoas" SortExpression="N&#186; de pessoas">
		                    <ItemTemplate>
		                        <asp:Label ID="lblNumPessoas" runat="server" Text='<%# Eval("UserCount") %>' ToolTip=''></asp:Label>
		                    </ItemTemplate>
		                </asp:TemplateField>
                        <asp:CommandField InsertVisible="False" SelectText="Detalhe" ShowCancelButton="False" ShowSelectButton="True" />
                    </Columns>
                </asp:GridView>

            </td>
            <td>&nbsp;</td>
            <td valign="top">
                <asp:Label ID="lblIDZona" runat="server" CssClass="corpotexto" Visible="False"></asp:Label>
                <asp:GridView ID="gvDetalheZona" runat="server" AutoGenerateColumns="False" CssClass="corpotexto" Width="100%">
                    <RowStyle CssClass="linhaimpar" />
                    <HeaderStyle CssClass="titulo" />
                    <AlternatingRowStyle CssClass="linhapar" />
                    <Columns>
			            <asp:TemplateField HeaderText="Data / Hora" SortExpression="Data / Hora">
		                    <ItemTemplate>
		                        <asp:Label ID="lblDataUltimaPassagem" runat="server" Text='<%# Eval("LastPassingDate") %>' ToolTip=''></asp:Label>
		                    </ItemTemplate>
		                </asp:TemplateField>
			            <asp:TemplateField HeaderText="Cartão" SortExpression="Cartão">
		                    <ItemTemplate>
		                        <asp:Label ID="lblCartao" runat="server" Text='<%# Eval("LogicalCode") %>' ToolTip=''></asp:Label>
		                    </ItemTemplate>
		                </asp:TemplateField>
			            <asp:TemplateField HeaderText="Nome" SortExpression="Nome">
		                    <ItemTemplate>
		                        <asp:Label ID="lblNome" runat="server" Text='<%# Eval("Name") %>' ToolTip=''></asp:Label>
		                    </ItemTemplate>
		                </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </td>
        </tr>
    </table>
                
    <asp:Timer ID="Timer" runat="server">
    </asp:Timer>
    <asp:Label ID="lblDateTime" runat="server" CssClass="corpotexto" Visible="False"></asp:Label>
</asp:Panel>
