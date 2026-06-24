<%@ Page Language="VB" MasterPageFile="~/MasterPage.master" AutoEventWireup="false" CodeFile="MonSeg.aspx.vb" Inherits="MonSeg" %>

<%@ Register Src="Acessos.ascx" TagName="Acessos" TagPrefix="uc6" %>

<%@ Register Src="LogHistorico.ascx" TagName="LogHistorico" TagPrefix="uc4" %>

<%@ Register Src="Visitantes.ascx" TagName="Visitantes" TagPrefix="uc3" %>
<%@ Register Src="Alarmes.ascx" TagName="Alarmes" TagPrefix="uc5" %>
<%@ Register Src="ResumoZonas.ascx" TagName="ResumoZonas" TagPrefix="uc2" %>
<%@ Register Src="Circuitos.ascx" TagName="Circuitos" TagPrefix="uc1" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <asp:UpdatePanel ID="upTotal" runat="server" UpdateMode="Conditional" Visible="true">
        <ContentTemplate>
            <table width="100%">
                <tr><td colspan="2" align="center" valign="top">
                    <asp:LinkButton ID="lbTituloLogPorta" runat="server" CssClass="linknivel01on">Actividade da porta</asp:LinkButton>
                    <asp:LinkButton ID="lbTituloZonas" runat="server" CssClass="linknivel01">Zonas</asp:LinkButton>
                    <asp:LinkButton ID="lbTituloHistorico" runat="server" CssClass="linknivel01">Histórico</asp:LinkButton>
                    <asp:LinkButton ID="lbTituloConfiguracaoAcessos" runat="server" CssClass="linknivel01">Configuração de Acessos</asp:LinkButton>
                    <asp:LinkButton ID="lbTituloAlarmes" runat="server" CssClass="linknivel01">Alarmes</asp:LinkButton>
                </td></tr>
                <tr><td colspan="2" align="center" valign="top">
                    <asp:UpdatePanel ID="upLogPorta" runat="server" UpdateMode="Conditional" Visible="true">
                        <ContentTemplate>
                            <uc1:Circuitos ID="Circuitos1" runat="server" width="90%" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    
                    <asp:UpdatePanel ID="upResumoZonas" runat="server" UpdateMode="Conditional" Visible="false">
                        <ContentTemplate>
                            <uc2:ResumoZonas ID="ResumoZonas1" runat="server" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    
                    <asp:UpdatePanel ID="upHistorico" runat="server" UpdateMode="Conditional" Visible="false">
                        <ContentTemplate>
                            <uc4:LogHistorico ID="LogHistorico1" runat="server" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    
                    <asp:UpdatePanel ID="upConfiguracaoAcessos" runat="server" UpdateMode="Conditional" Visible="false">
                        <ContentTemplate>
                            <uc6:Acessos ID="Acessos1" runat="server" />                            
                        </ContentTemplate>
                    </asp:UpdatePanel>

                    <asp:UpdatePanel ID="upAlarmes" runat="server" UpdateMode="Conditional" Visible=false >
                        <ContentTemplate>
                            <uc5:Alarmes ID="Alarmes1" runat="server" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </td></tr>
                <tr>
                    <td align="center" valign="top" colspan="2">
                        <asp:UpdatePanel ID="upVisitantes" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <uc3:Visitantes ID="Visitantes1" runat="server" />
                            </ContentTemplate>
                        </asp:UpdatePanel>                        
                    </td>
                </tr>
            </table>    
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
