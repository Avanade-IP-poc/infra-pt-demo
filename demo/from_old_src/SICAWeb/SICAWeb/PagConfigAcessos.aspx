<%@ Page Title="" Language="VB" MasterPageFile="~/MasterPage.master" AutoEventWireup="false" CodeFile="PagConfigAcessos.aspx.vb" Inherits="PagConfigAcessos" %>

<%@ Register src="Menu.ascx" tagname="Menu" tagprefix="uc1" %>
<%@ Register src="Acessos.ascx" tagname="Acessos" tagprefix="uc2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<table width="100%">
    <tr><td align="center">       
        
        <uc1:Menu ID="Menu1" runat="server" />
        
    </td></tr>
    <tr><td height="5px"></td></tr>
    <tr><td align="center">
        <asp:UpdatePanel ID="upConfiguracaoAcessos" runat="server" UpdateMode="Conditional" Visible="true">
            <ContentTemplate>
                
                <uc2:Acessos ID="Acessos1" runat="server" />
                
            </ContentTemplate>
        </asp:UpdatePanel>
    </td></tr>
</table>
</asp:Content>

