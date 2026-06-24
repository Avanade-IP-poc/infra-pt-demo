Imports System.Configuration.ConfigurationManager
Imports System.Data

Partial Class MonSeg
    Inherits System.Web.UI.Page

    Protected Sub lbTituloLogPorta_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbTituloLogPorta.Click
        SelectTab(0)
    End Sub

    Protected Sub lbTituloZonas_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbTituloZonas.Click
        SelectTab(1)
    End Sub

    Protected Sub lbTituloHistorico_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbTituloHistorico.Click
        SelectTab(2)
    End Sub

    Protected Sub lbTituloConfiguracaoAcessos_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbTituloConfiguracaoAcessos.Click
        SelectTab(3)
    End Sub

    Protected Sub lbTituloAlarmes_Click(sender As Object, e As System.EventArgs) Handles lbTituloAlarmes.Click
        SelectTab(4)
    End Sub

    Private Sub SelectTab(ByVal index As Integer)
        upLogPorta.Visible = False
        upResumoZonas.Visible = False
        upHistorico.Visible = False
        upConfiguracaoAcessos.Visible = False
        upAlarmes.Visible = False

        lbTituloLogPorta.CssClass = "linknivel01"
        lbTituloZonas.CssClass = "linknivel01"
        lbTituloHistorico.CssClass = "linknivel01"
        lbTituloConfiguracaoAcessos.CssClass = "linknivel01"
        lbTituloAlarmes.CssClass = "linknivel01"

        Select Case index
            Case 0
                upLogPorta.Visible = True
                lbTituloLogPorta.CssClass = "linknivel01on"
            Case 1
                upResumoZonas.Visible = True
                lbTituloZonas.CssClass = "linknivel01on"
            Case 2
                upHistorico.Visible = True
                lbTituloHistorico.CssClass = "linknivel01on"
            Case 3
                upConfiguracaoAcessos.Visible = True
                lbTituloConfiguracaoAcessos.CssClass = "linknivel01on"
            Case 4
                upAlarmes.Visible = True
                lbTituloAlarmes.CssClass = "linknivel01on"
        End Select
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If VerificaNomeTerminal(Session("NomeTerminal")) Then
                If AppSettings("AcessoAHistorico").IndexOf(Session("Utilizador")) >= 0 And Session("Utilizador").ToString.Length > 0 Then
                    lbTituloHistorico.Visible = True
                Else
                    lbTituloHistorico.Visible = False
                    upHistorico.Visible = False
                End If
            Else
                lbTituloLogPorta.Visible = False
                lbTituloZonas.Visible = False
                lbTituloHistorico.Visible = False
                lbTituloConfiguracaoAcessos.Visible = False
                upLogPorta.Visible = False
                upResumoZonas.Visible = False
                upHistorico.Visible = False
                upConfiguracaoAcessos.Visible = False
                upVisitantes.Visible = False
                upAlarmes.Visible = False
            End If
            If AppSettings("AcessoDeConfiguracao").IndexOf(Session("Utilizador")) >= 0 And Session("Utilizador").ToString.Length > 0 Then
                lbTituloConfiguracaoAcessos.Visible = True
            Else
                lbTituloConfiguracaoAcessos.Visible = False
                upConfiguracaoAcessos.Visible = False
            End If
        End If
    End Sub

    'Private Function VerificaIPTerminal(ByVal IP As String) As Boolean
    '    Dim SQLManager As New SQLMethods
    '    Dim conn As SqlClient.SqlConnection
    '    Dim dt As DataTable

    '    conn = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)
    '    dt = SQLManager.SelectQuery("select count(*) as c from tblTerminais where ip='" & IP & "'", conn)
    '    SQLManager.DisposeConn(conn)

    '    If dt.Rows(0)(0) > 0 Then
    '        Return True
    '    Else
    '        Return False
    '    End If
    'End Function

    Private Function VerificaNomeTerminal(ByVal Nome As String) As Boolean
        Dim SQLManager As New SQLMethods
        Dim conn As SqlClient.SqlConnection
        Dim dt As DataTable

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)
        dt = SQLManager.SelectQuery("select count(*) as c from tblTerminais where nome='" & Nome & "'", conn)
        SQLManager.DisposeConn(conn)

        If dt.Rows(0)(0) > 0 Then
            Return True
        Else
            Return False
        End If
    End Function
End Class
