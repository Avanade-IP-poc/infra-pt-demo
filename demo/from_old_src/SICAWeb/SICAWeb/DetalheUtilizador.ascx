<%@ Control Language="VB" AutoEventWireup="false" CodeFile="DetalheUtilizador.ascx.vb" Inherits="DetalheUtilizador" %>
<link href="Styles/refer.css" rel="stylesheet" type="text/css" />
<table>
    <tr>
        <td colspan="2">
            <asp:Label ID="lblNumEmpregadoLabel" CssClass="corpotexto" runat="server" Text="Cartão:"></asp:Label>            
            <asp:Label ID="lblNumEmpregado" CssClass="corpotexto" runat="server" Text=''></asp:Label>            
        </td>
        <td rowspan="3" valign="top">
            <asp:Image ID="imgFoto" Height="100px" Width="90px" runat="server" ImageUrl='' /> 
        </td>
    </tr>
    <tr>
        <td colspan="2">
            <asp:Label ID="lblNomeLabel" CssClass="corpotexto" runat="server" Text="Nome:"></asp:Label>            
            <asp:Label ID="lblNome" CssClass="corpotexto" runat="server" Text=''></asp:Label>
        </td>
    </tr>
    <tr>
        <td colspan="2">
            <asp:Label ID="lblEmpresaLabel" CssClass="corpotexto" runat="server" Text="Empresa:"></asp:Label>            
            <asp:Label ID="lblEmpresa" CssClass="corpotexto" runat="server" Text=''></asp:Label>
        </td>
    </tr>
    <tr>
        <td colspan="2">
            <asp:Label ID="lblUltimaPassagemLabel" CssClass="corpotexto" runat="server" Text="Última Passagem:"></asp:Label>
            <table border="1">
                <tr>
                    <td>
                        <asp:Label ID="lblDataUltimaPassagemLabel" CssClass="corpotexto" runat="server" Text="Data e Hora:"></asp:Label>
                    </td>
                    <td>
                        <asp:Label ID="lblZonaUltimaPassagemLabel" CssClass="corpotexto" runat="server" Text="Local:"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblDataUltimaPassagem" CssClass="corpotexto" runat="server" Text=''></asp:Label>
                    </td>
                    <td>
                        <asp:Label ID="lblZonaUltimaPassagem" CssClass="corpotexto" runat="server" Text=''></asp:Label>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table> 
