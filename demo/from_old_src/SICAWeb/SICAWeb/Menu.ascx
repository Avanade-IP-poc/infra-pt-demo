<%@ Control Language="VB" AutoEventWireup="false" CodeFile="Menu.ascx.vb" Inherits="Menu" %>

<asp:LinkButton ID="lbTituloLogPorta" runat="server" CssClass="linknivel01on" 
    PostBackUrl="~/PagPrincipal.aspx">Actividade das portas</asp:LinkButton>
&nbsp;&nbsp;
<asp:LinkButton ID="lbTituloVisitantes" runat="server" CssClass="linknivel01" 
    PostBackUrl="~/PagVisitantes.aspx">Gestão de Visitantes</asp:LinkButton>
&nbsp;&nbsp;
<asp:LinkButton ID="lbTituloZonas" runat="server" CssClass="linknivel01" 
    PostBackUrl="~/PagZonas.aspx">Zonas</asp:LinkButton>
&nbsp;&nbsp;
<asp:LinkButton ID="lbTituloHistorico" runat="server" CssClass="linknivel01" 
    PostBackUrl="~/PagHistorico.aspx">Histórico</asp:LinkButton>
&nbsp;&nbsp;
<asp:LinkButton ID="lbTituloConfiguracaoAcessos" runat="server" 
    CssClass="linknivel01" PostBackUrl="~/PagConfigAcessos.aspx">Configuração de Acessos</asp:LinkButton>