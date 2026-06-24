<%@ Page Title="" Language="VB" MasterPageFile="~/MasterPage.master" AutoEventWireup="false" CodeFile="PagZonas.aspx.vb" Inherits="PagZonas" %>

<%@ Register src="Menu.ascx" tagname="Menu" tagprefix="uc1" %>
<%@ Register src="ResumoZonas.ascx" tagname="ResumoZonas" tagprefix="uc2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<table width="100%">
    <tr><td align="center">       
        
        <uc1:Menu ID="Menu1" runat="server" />
        
    </td></tr>
    <tr><td height="5px"></td></tr>
    <tr><td align="center">
        <asp:UpdatePanel ID="upResumoZonas" runat="server" UpdateMode="Conditional" Visible="true">
            <ContentTemplate>
                <uc2:ResumoZonas ID="ResumoZonas1" runat="server" />
            </ContentTemplate>
        </asp:UpdatePanel>
    </td></tr>
</table>
</asp:Content>

