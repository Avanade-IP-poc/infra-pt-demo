<%@ Page Title="" Language="VB" MasterPageFile="~/MasterPage.master" AutoEventWireup="false" CodeFile="PagAlarmes.aspx.vb" Inherits="PagAlarmes" %>

<%@ Register src="Alarmes.ascx" tagname="Alarmes" tagprefix="uc1" %>
<%@ Register src="Menu.ascx" tagname="Menu" tagprefix="uc2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<table width="100%">
    <tr><td align="center">       
        
        <uc2:Menu ID="Menu1" runat="server" />
        
    </td></tr>
    <tr><td height="5px"></td></tr>
    <tr><td align="center">
        <asp:UpdatePanel ID="upAlarmes" runat="server" UpdateMode="Conditional" Visible="true">
            <ContentTemplate>
                
                <uc1:Alarmes ID="Alarmes1" runat="server" />
                
            </ContentTemplate>
        </asp:UpdatePanel>
    </td></tr>
</table>
</asp:Content>

