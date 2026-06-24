<%@ Control Language="VB" AutoEventWireup="false" CodeFile="Circuitos.ascx.vb" Inherits="Circuitos" %>
<%@ Register Src="DetalheUtilizador.ascx" TagName="DetalheUtilizador" TagPrefix="uc2" %>
<%@ Register Src="LogPorta.ascx" TagName="LogPorta" TagPrefix="uc1" %>

<link href="Styles/refer.css" rel="stylesheet" type="text/css" />

<asp:Panel ID="Panel" runat="server" Width="99%" BorderColor="#C4DD9C" 
    BorderStyle="Solid" BorderWidth="1px" >
    <table width="100%">
        <tr>
            <td align="left">
                <asp:DropDownList ID="ddlCircuit" runat="server" AutoPostBack="True" CssClass="formulario" DataTextField="NomeCircuito" DataValueField="IDCircuito" OnSelectedIndexChanged="ddlCircuit_SelectedIndexChanged"></asp:DropDownList>
                &nbsp;
                <asp:ImageButton ID="ibRefresh" runat="server" Height="18px" 
                    ImageUrl="~/Images/refresh.jpg" Width="18px" />
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel ID="upActividadePorta" runat="server" UpdateMode="Conditional" RenderMode="Inline">
                    <ContentTemplate>
                        <table width="100%">
                            <tr>
                                <td valign="top">
                                    <uc1:LogPorta ID="LogPorta" runat="server"/>
                                </td>
                                <td align="center" valign="top">
                                    <uc2:DetalheUtilizador ID="DetalheUtilizador" runat="server" />
                                </td>
                            </tr>
                        </table>
                        <asp:Timer ID="timerLogPorta" runat="server" Interval="5000" 
                            OnTick="timerLogPorta_Tick">
                        </asp:Timer>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="timerLogPorta" EventName="Tick" />
                    </Triggers>
                </asp:UpdatePanel>            
            </td>
        </tr>
    </table>
</asp:Panel>    
