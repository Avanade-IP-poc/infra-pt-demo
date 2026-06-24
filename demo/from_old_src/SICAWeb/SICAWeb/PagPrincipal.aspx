<%@ Page Title="" Language="VB" MasterPageFile="~/MasterPage.master" AutoEventWireup="false" CodeFile="PagPrincipal.aspx.vb" Inherits="PagPrincipal" %>

<%@ Register src="Menu.ascx" tagname="Menu" tagprefix="uc1" %>
<%@ Register src="Circuitos.ascx" tagname="Circuitos" tagprefix="uc2" %>
<%@ Register src="Visitantes.ascx" tagname="Visitantes" tagprefix="uc3" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<table width="100%">
    <tr>
        <td align="center">       
            <uc1:Menu ID="Menu1" runat="server" />
        </td>
        <td align="right" >
            <font size="1">
                <%=Session("Utilizador")%>&nbsp;/&nbsp;<%=Session("NomeTerminal")%>
            </font>
        </td>
    </tr>
    <tr>
        <td height="5px" colspan="2"></td>
    </tr>
    <tr>
        <td align="center" colspan="2">
            <asp:UpdatePanel ID="upLogPorta" runat="server" UpdateMode="Conditional" Visible="true">
                <ContentTemplate>
                    <uc2:Circuitos ID="Circuitos1" runat="server" width="90%" />
                </ContentTemplate>
            </asp:UpdatePanel>
        </td>
    </tr>
    <tr>
        <td align="center" colspan="2">
            <asp:UpdatePanel ID="upVisitantes" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                
                </ContentTemplate>
            </asp:UpdatePanel> 
        </td>
    </tr>
</table>
</asp:Content>

