<%@ Page Title="" Language="VB" MasterPageFile="~/MasterPage.master" AutoEventWireup="false" CodeFile="PagVisitantes.aspx.vb" Inherits="PagVisitantes" %>

<%@ Register src="Menu.ascx" tagname="Menu" tagprefix="uc1" %>
<%@ Register src="Visitantes.ascx" tagname="Visitantes" tagprefix="uc2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<table width="100%">
    <tr><td align="center">       
        
        <uc1:Menu ID="Menu1" runat="server" />
        
    </td></tr>
    <tr><td height="5px"></td></tr>
    <tr><td align="center">
        <asp:UpdatePanel ID="upVisitantes" runat="server" UpdateMode="Conditional" Visible="true">
            <ContentTemplate>
                
                <uc2:Visitantes ID="Visitantes1" runat="server" />
                
            </ContentTemplate>
        </asp:UpdatePanel>
    </td></tr>
</table>
</asp:Content>

