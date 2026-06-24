<%@ Control Language="VB" AutoEventWireup="false" CodeFile="DetalheVisitante.ascx.vb" Inherits="DetalheVisitante" %>
<%@ Register Src="MasterPage.master" TagName="MasterPage" TagPrefix="mp1" %>
<%@ Register assembly="RJS.Web.WebControl.PopCalendar.Net.2008" namespace="RJS.Web.WebControl" tagprefix="rjs" %>

<link href="Styles/refer.css" rel="stylesheet" type="text/css" />
<table>
    <tr>
        <td>
            <asp:Label ID="lblNumCartaoLabel" runat="server" CssClass="corpotexto" Text="Nº do cartão"></asp:Label>
            <asp:TextBox ID="txtNumCartao" runat="server" CssClass="formulario" Width="55px"></asp:TextBox>

            <asp:Label ID="lblNovoRegisto" runat="server" CssClass="corpotexto" Visible="False"></asp:Label>
            <asp:Label ID="lblIDRegistoVisitante" runat="server" CssClass="corpotexto" Visible="False"></asp:Label>
            <asp:Label ID="lblIDUtilizador" runat="server" CssClass="corpotexto" Visible="False"></asp:Label><asp:Label ID="lblNumCartao" runat="server" CssClass="corpotexto" Visible="False"></asp:Label><asp:Label ID="lblIDCartao" runat="server" CssClass="corpotexto" Visible="False"></asp:Label>
            <asp:Button ID="cmdPesquisar" runat="server" CssClass="formulario" Text="Pesquisar" />
        </td>
    </tr>
    <tr>
        <td>
            <table border="1">
                <tr>
                    <td valign="top">
                        <asp:Label ID="lblVisitanteLabel" runat="server" Text="Visitante" CssClass="corpotexto"></asp:Label></td>
                    <td valign="top">
                        <table width="100%">
                            <tr>
                                <td style="width: 120px">
                                    <asp:Label ID="lblVisitanteTipo" runat="server" Text="Tipo:" CssClass="corpotexto"></asp:Label>
                                </td>
                                <td>
                                    <asp:RadioButtonList ID="rblTipoVisitante" runat="server" CssClass="formulario" 
                                        AutoPostBack="True" RepeatDirection="Horizontal">
                                    </asp:RadioButtonList>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 120px">
                                    <asp:Label ID="lblVisitanteNome" runat="server" Text="Nome:" CssClass="corpotexto"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtVisitanteNome" runat="server" Text="" CssClass="formulario" Width="200px"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 120px">
                                    <asp:Label ID="lblVisitanteEmpresa" runat="server" Text="Empresa:" CssClass="corpotexto"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtVisitanteEmpresa" runat="server" Text="" CssClass="formulario" Width="200px"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 120px">
                                    <asp:Label ID="lblEntidadeVisitadaNome" runat="server" Text="Visitado:" CssClass="corpotexto"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtEntidadeVisitadaNome" runat="server" Text="" CssClass="formulario" Width="200px"></asp:TextBox>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td valign="top" style="height: 49px">
                        <asp:Label ID="lblVisitanteColaborador" runat="server" Text="Colaborador" 
                            CssClass="corpotexto" Visible="False"></asp:Label>
                        <asp:Label ID="lblVisitanteViatura" runat="server" Text="Viatura" 
                            CssClass="corpotexto" Visible="False"></asp:Label>
                    </td>
                    <td valign="top" style="height: 49px">
                        <table width="100%">
                            <tr>
                                <td style="width: 120px" valign="top">
                                    <asp:Label ID="lblVisitanteNumEmpregado" runat="server" Text="Num. Empregado:" CssClass="corpotexto"></asp:Label>
                                    <asp:Label ID="lblVisitanteViaturaMatricula" runat="server" Text="Matrícula:" CssClass="corpotexto"></asp:Label>
                                </td>
                                <td valign="top">
                                    <asp:TextBox ID="txtVisitanteNumEmpregado" runat="server" Text="" CssClass="formulario" Width="50px"></asp:TextBox>
                                    <asp:Button ID="cmdValidarEmpregado" runat="server" CssClass="formulario" Text="Validar" />
                                    <asp:TextBox ID="txtVisitanteViaturaMatricula" runat="server" Text="" CssClass="formulario" Width="100px"></asp:TextBox>
                                </td>
                                <td>
                                    <asp:Image ID="imgVisitanteFotoEmpregado" runat="server" Height="50px" 
                                        ImageUrl="~/Images/blank.jpg" Width="50px" />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td valign="top">
                        <asp:Label ID="lblVisitanteAcessoLabel" runat="server" Text="Acesso" CssClass="corpotexto"></asp:Label></td>
                    <td valign="top">
                        <table width="100%">
                            <tr>
                                <td colspan="2">
                                    <table width="100%">
                                        <tr>
                                            <td align="center">
                                                <asp:Label ID="lblVisitanteAcessoHoraEntrada" runat="server" Text="Hora de entrada:" CssClass="corpotexto"></asp:Label>
                                            </td>
                                            <td align="center">
                                                <asp:Label ID="lblVisitanteAcessoHoraSaida" runat="server" Text="Hora de saída:" CssClass="corpotexto"></asp:Label></td>
                                        </tr>
                                        <tr>
                                            <td align="center">
                                                <asp:TextBox ID="txtVisitanteAcessoHoraEntrada" runat="server" Text="" CssClass="formulario" Width="50px"></asp:TextBox>
                                                &nbsp;<asp:Label ID="lblVisitanteAcessoHoraEntradaFormato" runat="server" Text="(hh:mm)" CssClass="corpotexto"></asp:Label>
                                            </td>
                                            <td align="center">
                                                <asp:TextBox ID="txtVisitanteAcessoHoraSaida" runat="server" Text="" CssClass="formulario" Width="50px"></asp:TextBox>
                                                &nbsp;<asp:Label ID="lblVisitanteAcessoSaidaEntradaFormato" runat="server" Text="(hh:mm)" CssClass="corpotexto"></asp:Label>
                                            </td>
                                        </tr>            
                                    </table>            
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 120px" valign="middle" align="left">
                                    <asp:Label ID="lblVisitanteAcessoFamilia" runat="server" Text="Acesso:" CssClass="corpotexto"></asp:Label></td>
                                <td align="left">
                                    <asp:CheckBoxList ID="cblVisitanteAcessoFamilia" runat="server" CssClass="formulario" Width="250px">
                                    </asp:CheckBoxList>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 120px" valign="top" align="left">
                                    <asp:Label ID="lblVisitanteAcessoValidade" runat="server" Text="Validade:" CssClass="corpotexto"></asp:Label></td>
                                <td align="left">
                                    <asp:TextBox ID="txtVisitanteAcessoValidade" runat="server" CssClass="formulario"
                                        Width="75px"></asp:TextBox>
                                    <rjs:PopCalendar ID="PopCalendarInicio" runat="server" Control="txtVisitanteAcessoValidade" Format="yyyy mm dd" />
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 120px" valign="top" align="left">
                                    <asp:Label ID="lblVisitanteEstadoCartao" runat="server" Text="Cartão:" CssClass="corpotexto"></asp:Label></td>
                                <td align="left">
                                    <asp:DropDownList ID="ddlVisitanteEstadoCartao" runat="server" CssClass="formulario"
                                        Width="200px">
                                        <asp:ListItem Value="2">V&#225;lido</asp:ListItem>
                                        <asp:ListItem Value="4">Proibído</asp:ListItem>
                                        <asp:ListItem Value="16">Roubado</asp:ListItem>
                                        <asp:ListItem Value="32">Destru&#237;do</asp:ListItem>
                                        <asp:ListItem Value="8">Perdido</asp:ListItem>
                                        <asp:ListItem Value="0">Desconhecido</asp:ListItem>
                                    </asp:DropDownList></td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>
            <asp:Label ID="lblStatus" runat="server" CssClass="corpotexto" Font-Italic="True" ForeColor="red"></asp:Label>
        </td>
    </tr>
    <tr>
        <td align="right" style="height: 21px">
            <asp:Button ID="cmdLimpar" runat="server" Text="Limpar" CssClass="formulario" Width="70px" />
            <asp:Button ID="cmdGravar" runat="server" Text="Gravar" CssClass="formulario" Width="70px" />
            <asp:Button ID="cmdCancelar" runat="server" Text="Cancelar" CssClass="formulario" Width="70px" />
        </td>
    </tr>
</table>