<%@ Control Language="VB" AutoEventWireup="false" CodeFile="LogHistorico.ascx.vb" Inherits="LogHistorico" %>
<link href="Styles/refer.css" rel="stylesheet" type="text/css" />

<asp:Panel ID="panelConsulta" runat="server" Width="100%" Visible="true">
    <table width="100%">
        <tr>
            <td width="20%">
                <asp:Label ID="lblTipoConsulta" runat="server" CssClass="corpotexto" Text="Tipo de consulta"></asp:Label>
            </td>
            <td width="80%">
                <asp:Label ID="lblParametrosConsulta" runat="server" CssClass="corpotexto" Text="Parâmetros da consulta"></asp:Label>
            </td>
        </tr>
        <tr>
            <td valign="top">
                <asp:RadioButtonList ID="rblTipoConsulta" runat="server" CssClass="corpotexto" AutoPostBack="True" RepeatLayout="Flow">
                    <asp:ListItem Selected="True" Text="Presen&#231;as na zona num per&#237;odo" Value="0"></asp:ListItem>
                    <asp:ListItem Text="Detalhe de cart&#245;es externos" Value="1" Enabled="false"></asp:ListItem>
                </asp:RadioButtonList>
            </td>
            <td valign="top">
                <asp:Panel ID="panel0" runat="server" Width="100%" Visible="true">
                    <table>
                        <tr>
                            <td align="left">
                                <asp:Label ID="lblPeriodoParaAnalise" runat="server" CssClass="corpotexto" Text="Periodo para análise"></asp:Label>
                            </td>
                            <td align="left">
                                <asp:Label ID="lblDe" runat="server" CssClass="corpotexto" Text="De"></asp:Label>
                                &nbsp;
                                <asp:TextBox ID="txtPeriodoParaAnaliseInicio" runat="server" CssClass="formulario" ToolTip="Data e Hora no formato: aaaa-mm-dd hh:mm:ss" Width="130px"></asp:TextBox>
                                &nbsp;
                                <asp:Label ID="lblA" runat="server" CssClass="corpotexto" Text="a"></asp:Label>
                                &nbsp;
                                <asp:TextBox ID="txtPeriodoParaAnaliseFim" runat="server" CssClass="formulario" ToolTip="Data e Hora no formato: aaaa-mm-dd hh:mm:ss" Width="130px"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td valign="top">
                                <asp:Label ID="lblCircuitosParaAnalise" runat="server" CssClass="corpotexto" Text="Circuitos"></asp:Label></td>
                            <td>
                                &nbsp;<asp:ListBox ID="lbCircuitosParaAnalise" runat="server" CssClass="formulario"
                                    SelectionMode="Multiple"></asp:ListBox>
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
                <asp:Panel ID="panel1" runat="server" Width="100%" Visible="false">
                    consulta 1
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td colspan="2" align="center">
                <asp:Button ID="cmdConsulta" runat="server" Text="Pesquisar" CssClass="formulario" />
            </td>
        </tr>
    </table>    
</asp:Panel>

<asp:Panel ID="panelResultado" runat="server" Width="100%" Visible="true">
    <table width="100%">
        <tr>
            <td>
                <asp:GridView ID="gvResultado" runat="server" CssClass="corpotexto" Width="100%" HorizontalAlign="Left">
                    <RowStyle CssClass="linhaimpar"/>
                    <HeaderStyle CssClass="titulo" />
                    <AlternatingRowStyle CssClass="linhapar" />
                </asp:GridView>            
            </td>
        </tr>
    </table>    
</asp:Panel>





