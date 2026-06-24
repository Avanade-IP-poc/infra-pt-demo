<%@ Control Language="VB" AutoEventWireup="false" CodeFile="ActivarCartoes.ascx.vb" Inherits="ActivarCartoes" %>
<%@ Register Src="MasterPage.master" TagName="MasterPage" TagPrefix="mp1" %>
<%@ Register assembly="RJS.Web.WebControl.PopCalendar.Net.2008" namespace="RJS.Web.WebControl" tagprefix="rjs" %>

<link href="Styles/refer.css" rel="stylesheet" type="text/css" />
<table width="100%">
    <tr>
        <td>
            <asp:Label ID="lblCartoesDisponiveis" runat="server" CssClass="titulo" Text="Cartões Disponíveis" Width="100%"></asp:Label></td>
        <td>
            
        </td>
    </tr>
    <tr>
        <td valign="top">
            <asp:ListBox ID="lbCartoesDisponiveis" runat="server" CssClass="formulario" DataTextField="Descricao" Width="300px" DataValueField="NumCartao" Height="350px" SelectionMode="Multiple"></asp:ListBox></td>
        <td valign="top">
            <table border="1">
                <tr>
                    <td valign="top" align="left">
                        <asp:Label ID="lblVisitanteLabel" runat="server" Text="Visitante" CssClass="corpotexto"></asp:Label></td>
                    <td valign="top" align="left">
                        <table width="100%">
                            <tr>
                                <td>
                                    <asp:Label ID="lblVisitanteNome" runat="server" Text="Nome:" CssClass="corpotexto"></asp:Label>
                                </td>
                                <td align="right">
                                    <asp:TextBox ID="txtVisitanteNome" runat="server" Text="" CssClass="formulario" Width="200px"></asp:TextBox></td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="lblVisitanteEmpresa" runat="server" Text="Empresa:" CssClass="corpotexto"></asp:Label>
                                </td>
                                <td align="right">
                                    <asp:TextBox ID="txtVisitanteEmpresa" runat="server" Text="" CssClass="formulario" Width="200px"></asp:TextBox>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td valign="top" align="left">
                        <asp:Label ID="lblEntidadeVisitadaLabel" runat="server" Text="Entidade Visitada" CssClass="corpotexto"></asp:Label></td>
                    <td valign="top" align="left">
                        <table width="100%">
                            <tr>
                                <td>
                                    <asp:Label ID="lblEntidadeVisitadaNome" runat="server" Text="Nome:" CssClass="corpotexto"></asp:Label>
                                </td>
                                <td align="right">
                                    <asp:TextBox ID="txtEntidadeVisitadaNome" runat="server" Text="" CssClass="formulario" Width="200px"></asp:TextBox>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td valign="top" align="left">
                        <asp:Label ID="lblVisitanteAcessoLabel" runat="server" Text="Acesso" CssClass="corpotexto"></asp:Label></td>
                    <td valign="top" align="left">
                        <table width="100%" align="left">
                            <tr>
                                <td >
                                    <asp:Label ID="lblVisitanteAcessoHoraEntrada" runat="server" Text="Hora de entrada:" CssClass="corpotexto"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtVisitanteAcessoHoraEntrada" runat="server" Text="" CssClass="formulario" Width="200px"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="lblVisitanteAcessoHoraSaida" runat="server" Text="Hora de saída:" CssClass="corpotexto"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtVisitanteAcessoHoraSaida" runat="server" Text="" CssClass="formulario" Width="200px"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    <asp:Label ID="lblVisitanteAcessoFamilia" runat="server" Text="Acesso:" CssClass="corpotexto"></asp:Label></td>
                                <td>
                                    <asp:ListBox ID="lbVisitanteAcessoFamilia" runat="server" CssClass="formulario" Width="200px"></asp:ListBox>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    <asp:Label ID="lblVisitanteAcessoValidade" runat="server" Text="Validade:" CssClass="corpotexto"></asp:Label></td>
                                <td>
                                    <asp:TextBox ID="txtVisitanteAcessoValidade" runat="server" CssClass="formulario"
                                        Width="75px"></asp:TextBox>
                                    <rjs:PopCalendar ID="PopCalendarInicio" runat="server" Control="txtVisitanteAcessoValidade" Format="yyyy mm dd" />
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    <asp:Label ID="lblVisitanteEstadoCartao" runat="server" Text="Cartão:" CssClass="corpotexto"></asp:Label></td>
                                <td>
                                    <asp:DropDownList ID="ddlVisitanteEstadoCartao" runat="server" CssClass="formulario"
                                        Width="200px">
                                        <asp:ListItem Value="2">V&#225;lido</asp:ListItem>
                                        <asp:ListItem Value="4">Proibido</asp:ListItem>
                                        <asp:ListItem Value="16">Roubado</asp:ListItem>
                                        <asp:ListItem Value="32">Destru&#237;do</asp:ListItem>
                                        <asp:ListItem Value="8">Perdido</asp:ListItem>
                                    </asp:DropDownList></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <asp:Label ID="lblStatus" runat="server" CssClass="corpotexto" Font-Italic="True" ForeColor="red"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2" align="right">
                        <asp:Button ID="cmdLimpar" runat="server" Text="Limpar" CssClass="formulario" Width="70px" />
                        <asp:Button ID="cmdGravar" runat="server" Text="Gravar" CssClass="formulario" Width="70px" />
                        <asp:Button ID="cmdCancelar" runat="server" Text="Cancelar" CssClass="formulario" Width="70px" OnClientClick="changeTab(0);" />
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>