<%@ Control Language="VB" AutoEventWireup="false" CodeFile="Acessos.ascx.vb" Inherits="Acessos" %>
<%@ Register Src="MasterPage.master" TagName="MasterPage" TagPrefix="mp1" %>

<link href="Styles/refer.css" rel="stylesheet" type="text/css" />

<asp:UpdatePanel ID="updatePanelGeral" runat="server">
    <ContentTemplate>
        <table width="100%">
            <tr align="center">
                <td style="width: 25%; height: 21px;">
                    <asp:DropDownList ID="ddlFiltroTerminais" runat="server"
                        DataTextField="NomeTerminal" DataValueField="IDTerminal" CssClass="formulario" Width="100%" AutoPostBack="True">
                    </asp:DropDownList>
                </td>
            </tr>
            <tr><td>
                <table width="100%">
                    <tr align="center">
                        <td style="height: 22px">
                            <asp:Label ID="lblTituloCartoes" runat="server" CssClass="titulo" Text="Cartões"></asp:Label></td>
                        <td style="height: 22px">
                            <asp:Label ID="lblTituloFamilias" runat="server" CssClass="titulo" Text="Familias"></asp:Label></td>
                        <td style="height: 22px">
                            <asp:Label ID="lblTituloCircuitos" runat="server" CssClass="titulo" Text="Circuitos"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td valign="top" style="width: 33%" align="left">
                            <asp:CheckBoxList ID="cblCartoes" runat="server" Enabled="False" Height="300px" ></asp:CheckBoxList>
                        </td>
                        <td valign="top" style="width: 33%" align="left">
                            <asp:CheckBoxList ID="cblFamilias" runat="server" Enabled="False" Height="300px" ></asp:CheckBoxList>
                        </td>
                        <td valign="top" style="width: 33%" align="left">
                            <asp:CheckBoxList ID="cblCircuitos" runat="server" Enabled="False" Height="300px" ></asp:CheckBoxList>
                        </td>
                    </tr>
                    <tr align="center">
                        <td valign="top" colspan="3">
                            &nbsp;
                            <asp:Button ID="cmdAplicar" runat="server" CssClass="formulario" Enabled="False" Text="Aplicar" />
                            &nbsp;
                            <asp:Button ID="cmdCancelar" runat="server" Text="Cancelar" CssClass="formulario" Enabled="False" OnClick="cmdCancelar_Click" />
                        </td>
                    </tr>
                    <tr align="center">
                        <td valign="top" colspan="3">
                            <asp:Label ID="lblEstado" runat="server" CssClass="legenda"></asp:Label>
                        </td>
                    </tr>
                </table>
            </td></tr>
        </table>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:UpdateProgress ID="UpdateProgress" runat="server" AssociatedUpdatePanelID="updatePanelGeral">
    <ProgressTemplate>
        <table width="100%"><tr><td align="center">
            <asp:Image ID="ImageWait" runat="server" ImageUrl="~/Images/wait_animated.gif" Height="30px" Width="30px" />
        </td></tr></table>
    </ProgressTemplate>
</asp:UpdateProgress>