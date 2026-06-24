<%@ Control Language="VB" AutoEventWireup="false" CodeFile="DetalheLog.ascx.vb" Inherits="DetalheLog" %>
<link href="Styles/refer.css" rel="stylesheet" type="text/css" />
<table>
    <tr valign="top">
        <td align="center">
            <asp:Label ID="lblDataHoraInicio" runat="server" CssClass="corpotexto" Text="Data/Hora Início"></asp:Label>
        </td>
        <td align="center">
            <asp:Label ID="lblDataHoraFim" runat="server" CssClass="corpotexto" Text="Data/Hora Fim"></asp:Label>
        </td>
        <td align="center">
            <asp:Label ID="lblCircuito" runat="server" CssClass="corpotexto" Text="Circuito"></asp:Label>
        </td>
        <td align="center">
            <asp:Label ID="lblPesquisa" runat="server" CssClass="corpotexto" Text="Texto"></asp:Label>
        </td>
        <td align="center">
            
        </td>
    </tr>
    <tr valign="top">
        <td align="center">
            <asp:TextBox ID="txtDataHoraInicio" runat="server" CssClass="formulario" Width="75px"></asp:TextBox>
        </td>
        <td align="center">
            <asp:TextBox ID="txtDataHoraFim" runat="server" CssClass="formulario" Width="75px"></asp:TextBox>
        </td>
        <td align="center">
            <asp:SqlDataSource ID="dsCircuits" runat="server" ConnectionString="<%$ ConnectionStrings:SICAConnectionString %>"
                SelectCommand="SelectVwCircuitosByIPTerminal" SelectCommandType="StoredProcedure">
                <SelectParameters>
                    <asp:SessionParameter Name="IP" SessionField="IPTerminal" Type="String" />
                </SelectParameters>
            </asp:SqlDataSource>
            <asp:DropDownList ID="ddlCircuit" runat="server" AutoPostBack="True" CssClass="formulario"
                DataSourceID="dsCircuits" DataTextField="NomeCircuito" DataValueField="IDCircuito" Width="150px">
            </asp:DropDownList>
        </td>
        <td align="center">
            <asp:TextBox ID="txtPesquisa" runat="server" CssClass="formulario" Width="150px"></asp:TextBox>
        </td>
        <td align="center">
            <asp:Button ID="cmdPesquisar" runat="server" CssClass="formulario" Text="Pesquisar" />
        </td>
    </tr>
    <tr valign="top">
        <td colspan="7" align="center">
            <asp:SqlDataSource ID="dsLog" runat="server" ConnectionString="<%$ ConnectionStrings:AlizesConnectionString %>"
                SelectCommand="spREFER_PesquisaLog" SelectCommandType="StoredProcedure">
                <SelectParameters>
                    <asp:ControlParameter ControlID="txtDataHoraInicio" DefaultValue="1900-01-01" Name="DataHoraInicio"
                        PropertyName="Text" Type="DateTime" />
                    <asp:ControlParameter ControlID="txtDataHoraFim" DefaultValue="1900-01-01" Name="DataHoraFim"
                        PropertyName="Text" Type="DateTime" />
                    <asp:ControlParameter ControlID="ddlCircuit" DefaultValue="0" Name="idcircuit" PropertyName="SelectedValue"
                        Type="Int32" />
                    <asp:ControlParameter ControlID="txtPesquisa" DefaultValue="%" Name="Pesquisa" PropertyName="Text"
                        Type="String" />
                </SelectParameters>
            </asp:SqlDataSource>
            <asp:GridView ID="gvLog" runat="server" DataSourceID="dsLog" AutoGenerateColumns="False" CssClass="corpotexto">
                <RowStyle CssClass="linhaimpar" />
                <HeaderStyle CssClass="titulo" />
                <AlternatingRowStyle CssClass="linhapar" />
            </asp:GridView>
        </td>
    </tr>
</table>