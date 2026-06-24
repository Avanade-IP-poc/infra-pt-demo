Imports System.Configuration.ConfigurationManager

Partial Class Menu
    Inherits System.Web.UI.UserControl


    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        lbTituloLogPorta.CssClass = "linknivel01"
        lbTituloVisitantes.CssClass = "linknivel01"
        lbTituloZonas.CssClass = "linknivel01"
        lbTituloHistorico.CssClass = "linknivel01"
        lbTituloConfiguracaoAcessos.CssClass = "linknivel01"

        Select Case Page.AppRelativeVirtualPath
            Case "~/PagPrincipal.aspx"
                lbTituloLogPorta.CssClass = "linknivel01on"
            Case "~/PagVisitantes.aspx"
                lbTituloVisitantes.CssClass = "linknivel01on"
            Case "~/PagZonas.aspx"
                lbTituloZonas.CssClass = "linknivel01on"
            Case "~/PagHistorico.aspx"
                lbTituloHistorico.CssClass = "linknivel01on"
            Case "~/PagConfigAcessos.aspx"
                lbTituloConfiguracaoAcessos.CssClass = "linknivel01on"
        End Select

        If AppSettings("AcessoAHistorico").IndexOf(Session("Utilizador")) < 0 Then lbTituloHistorico.Visible = False
        If AppSettings("AcessoDeConfiguracao").IndexOf(Session("Utilizador")) < 0 Then lbTituloConfiguracaoAcessos.Visible = False
    End Sub
End Class
