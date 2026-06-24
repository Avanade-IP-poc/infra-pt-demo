<%@ Control Language="VB" AutoEventWireup="false" CodeFile="Alarmes.ascx.vb" Inherits="Alarmes" %>
<link href="Styles/refer.css" rel="stylesheet" type="text/css" />

<asp:SqlDataSource ID="dsAlarmes" runat="server" ConnectionString="<%$ ConnectionStrings:AlizesConnectionString %>"
    SelectCommand="spREFER_vwREFERAlarmes" SelectCommandType="StoredProcedure">
    <SelectParameters>
        <asp:ControlParameter ControlID="lblNumDias" Name="NumDias" PropertyName="Text" Type="Int32" />
    </SelectParameters>
</asp:SqlDataSource>
<asp:Label ID="lblNumDias" runat="server" CssClass="corpotexto" Visible="False"></asp:Label>

<table width="100%">
    <tr><td align="center" valign="top">
        <asp:Label ID="lblTituloAlarmes" runat="server" CssClass="linknivel01" Text="Alarmes"></asp:Label>
    </td></tr>
    <tr><td align="center" valign="top">
        <asp:Panel ID="Panel" runat="server" Width="99%">
            <asp:GridView ID="gvAlarmes" runat="server" AutoGenerateColumns="False" DataSourceID="dsAlarmes" Width="100%">
                <Columns>
                    <asp:BoundField DataField="Data" HeaderText="Data" SortExpression="Data" />
                    <asp:BoundField DataField="IDCircuito" HeaderText="IDCircuito" SortExpression="IDCircuito"
                        Visible="False" />
                    <asp:BoundField DataField="Nome" HeaderText="Nome" ReadOnly="True" SortExpression="Nome" />
                    <asp:BoundField DataField="Evento" HeaderText="Evento" SortExpression="Evento" />
                </Columns>
                <RowStyle CssClass="linhaimpar" />
                <HeaderStyle CssClass="titulo" />
                <AlternatingRowStyle CssClass="linhapar" />
            </asp:GridView>
            <asp:Label ID="lblDateTime" runat="server" CssClass="corpotexto" Visible="false"></asp:Label>
        </asp:Panel>
    </td></tr>
</table>

<asp:Timer ID="TimerAlarmes" runat="server"></asp:Timer>