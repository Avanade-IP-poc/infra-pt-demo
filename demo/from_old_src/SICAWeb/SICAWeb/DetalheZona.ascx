<%@ Control Language="VB" AutoEventWireup="false" CodeFile="DetalheZona.ascx.vb" Inherits="DetalheZona" %>
<link href="Styles/refer.css" rel="stylesheet" type="text/css" />
<asp:Label ID="lblIDZona" runat="server" CssClass="corpotexto" Visible="False"></asp:Label>
<asp:SqlDataSource ID="dsDetalheZona" runat="server" ConnectionString="<%$ ConnectionStrings:AlizesConnectionString %>"
    SelectCommand="spREFER_vwREFERUtilizadoresSelectByIDZona" SelectCommandType="StoredProcedure">
    <SelectParameters>
        <asp:ControlParameter ControlID="lblIDZona" Name="IDZona" PropertyName="Text" Type="Int32" />
    </SelectParameters>
</asp:SqlDataSource>
<asp:GridView ID="gvDetalheZona" runat="server" DataSourceID="dsDetalheZona" AutoGenerateColumns="False" CssClass="corpotexto">
    <RowStyle CssClass="linhaimpar" />
    <HeaderStyle CssClass="titulo" />
    <AlternatingRowStyle CssClass="linhapar" />
    <Columns>
        <asp:BoundField DataField="DataUltimaPassagem" HeaderText="Data / Hora" />
        <asp:HyperLinkField DataNavigateUrlFields="NumEmpregado" DataNavigateUrlFormatString="~/MonitorizacaoZonas.aspx?NumEmpregado={0}"
            DataTextField="NumEmpregado" HeaderText="Nº de Empregado">
            <ControlStyle CssClass="link " />
        </asp:HyperLinkField>
        <asp:BoundField DataField="Nome" HeaderText="Nome" />
    </Columns>
</asp:GridView>