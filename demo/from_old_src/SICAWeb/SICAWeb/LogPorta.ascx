<%@ Control Language="VB" AutoEventWireup="false" CodeFile="LogPorta.ascx.vb" Inherits="LogPorta" %>
<link href="Styles/refer.css" rel="stylesheet" type="text/css" />
<asp:Label ID="lblCircuitID" runat="server" CssClass="corpotexto" Visible="false"></asp:Label>
<asp:GridView ID="gvLog" runat="server" Width="100%" AutoGenerateColumns="False" CssClass="corpotexto">
    <RowStyle CssClass="linhaimpar" />
    <HeaderStyle CssClass="titulo" />
    <AlternatingRowStyle CssClass="linhapar" />
    <Columns>
        <asp:TemplateField HeaderText="Data e Hora" SortExpression="DataHora">
            <ItemTemplate>
                <asp:Label ID="lblDataHora" runat="server" Text='<%# Eval("DateTime") %>' ToolTip=''></asp:Label>
            </ItemTemplate>
        </asp:TemplateField>
        <asp:TemplateField HeaderText="Nome" SortExpression="Nome">
            <ItemTemplate>
                <asp:Label ID="lblNome" runat="server" Text='<%# Eval("Name") %>' ToolTip=''></asp:Label>
            </ItemTemplate>
        </asp:TemplateField>
        <asp:TemplateField HeaderText="Cart&#227;o" SortExpression="NumEmpregado">
            <ItemTemplate>
                <asp:Label ID="lblNumEmpregado" runat="server" Text='<%# Eval("LogicalCode") %>' ToolTip=''></asp:Label>
            </ItemTemplate>
        </asp:TemplateField>
        <asp:TemplateField HeaderText="Mensagem" SortExpression="Mensagem">
            <ItemTemplate>
                <asp:Label ID="lblMensagem" runat="server" Text='<%# Eval("Event") %>' ToolTip=''></asp:Label>
            </ItemTemplate>
        </asp:TemplateField>
        <asp:TemplateField HeaderText="Local" SortExpression="Zona">
            <ItemTemplate>
                <asp:Label ID="lblZona" runat="server" Text='<%# Eval("GeoZone") %>' ToolTip=''></asp:Label>
            </ItemTemplate>
        </asp:TemplateField>
    </Columns>
</asp:GridView>
<asp:Label ID="lblDateTime" runat="server" CssClass="corpotexto" 
    Visible="false"></asp:Label>