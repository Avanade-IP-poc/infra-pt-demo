<%@ Page Title="" Language="VB" MasterPageFile="~/MasterPage.master" AutoEventWireup="false" CodeFile="PagHistorico.aspx.vb" Inherits="PagHistorico" %>

<%@ Register src="LogHistorico.ascx" tagname="LogHistorico" tagprefix="uc1" %>
<%@ Register src="Menu.ascx" tagname="Menu" tagprefix="uc2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<table width="100%">
    <tr><td align="center">       
        
        <uc2:Menu ID="Menu1" runat="server" />
        
    </td></tr>
    <tr><td height="5px"></td></tr>
    <tr><td align="center">
        <asp:UpdatePanel ID="upHistorico" runat="server" UpdateMode="Conditional" Visible="true">
            <ContentTemplate>
                
                <uc1:LogHistorico ID="LogHistorico1" runat="server" />
                
            </ContentTemplate>
        </asp:UpdatePanel>
    </td></tr>
</table>
</asp:Content>

