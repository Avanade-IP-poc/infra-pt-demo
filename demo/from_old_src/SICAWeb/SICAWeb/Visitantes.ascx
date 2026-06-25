<%@ Control Language="VB" AutoEventWireup="false" CodeFile="Visitantes.ascx.vb" Inherits="Visitantes" %>
<%@ Register Src="ActivarCartoes.ascx" TagName="ActivarCartoes" TagPrefix="uc2" %>
<%@ Register Src="DetalheVisitante.ascx" TagName="DetalheVisitante" TagPrefix="uc1" %>
<%@ Register Src="MasterPage.master" TagName="MasterPage" TagPrefix="mp1" %>

<link href="Styles/refer.css" rel="stylesheet" type="text/css" />

<table width="100%">
    <tr><td align="center" valign="top">
        <asp:LinkButton ID="lbTituloCartoesFora" runat="server" Visible="false" CssClass="linknivel01on">Cartões atribuídos</asp:LinkButton>
        <asp:LinkButton ID="lbTituloAtribuirCartao" runat="server" Visible="false" CssClass="linknivel01">Atribuir Cartão</asp:LinkButton>
    </td></tr>
    <tr><td align="center" valign="top">
            <asp:Panel ID="Panel" runat="server" Width="99%" BorderColor="#C4DD9C" 
    BorderStyle="Solid" BorderWidth="1px">
                <table width="100%">
                    <tr>
                        <td valign="top" align="center">
                           <asp:Panel ID="panelCartoesFora" runat="server" Visible="true">
                                <asp:UpdatePanel ID="upCartoesFora" runat="server" RenderMode="Inline">
                                <ContentTemplate>
                                    <asp:GridView ID="gvCartoesFora" runat="server" AutoGenerateColumns="False" Width="100%" >
                                        <RowStyle CssClass="linhaimpar" />
                                        <HeaderStyle CssClass="titulo" />
                                        <AlternatingRowStyle CssClass="linhapar" />
                                        <Columns>
                                            <asp:TemplateField ShowHeader="False">
                                                <ItemTemplate>
                                                    <asp:ImageButton ID="ImageButton1" runat="server" CausesValidation="False" CommandName="Select"
                                                        ImageUrl="~/Images/seta-direita.jpg" />
                                                </ItemTemplate>
                                                <ControlStyle Height="10px" Width="10px" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Cart&#227;o">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblNCartao" runat="server" Text='<%# Eval("NumCartao") %>'></asp:Label>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField DataField="NomeVisitante" HeaderText="Visitante" />
                                            <asp:BoundField DataField="DescricaoTipoVisitante" HeaderText="Tipo" />
                                            <asp:BoundField DataField="HoraEntrada" HeaderText="Data de atribuição" />
                                        </Columns>
                                    </asp:GridView>
                                    <asp:Label ID="lblSemCartoesAtribuidos" runat="server" CssClass="corpotexto" Visible="False" Text="Não existem cartões atribuídos."></asp:Label>
                                    <asp:Label ID="lblDateTime" runat="server" CssClass="corpotexto" Visible="False"></asp:Label>
                                    <asp:Timer ID="TimerCartoesFora" runat="server" OnTick="TimerCartoesFora_Tick"></asp:Timer>
                                </ContentTemplate>
                                </asp:UpdatePanel>
                            </asp:Panel>             
                        </td>
                        <td valign="top" align="center" width="300px">
                            <asp:Panel ID="panelAtribuirCartao" runat="server" Visible="true">
                                <asp:UpdatePanel ID="upAtribuirCartao" runat="server" RenderMode="Inline" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <uc1:DetalheVisitante ID="DetalheVisitante" runat="server" />    
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </asp:Panel>                
                        </td>
                    </tr>
                </table>
            </asp:Panel>
    </td></tr>
</table>
