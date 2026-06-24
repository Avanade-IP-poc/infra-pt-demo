Imports System.Configuration.ConfigurationManager
Imports System.Data.SqlClient

Partial Class ResumoZonas
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If AppSettings("ShowRefreshTime") = "1" Then
            lblDateTime.Visible = True
        Else
            lblDateTime.Visible = False
        End If

        If Not IsPostBack Then
            Timer.Interval = AppSettings("ZonasRefreshInterval") * 1000
            ActualizaResumo()
        End If
    End Sub

    Protected Sub gvLZonas_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvZonas.SelectedIndexChanged
        lblIDZona.Text = TryCast(gvZonas.SelectedRow.FindControl("lblID"), Label).Text

        ActualizaDetalhe(lblIDZona.Text)
        lblTituloDetalhe.Text = "Pessoas presentes na zona " & gvZonas.SelectedRow.Cells(1).Text()
    End Sub

    Private Sub ActualizaResumo()
        Dim SMI As New SMIMethodsWebService.SMIMethodsSoapClient
        gvZonas.DataSource = SMI.CountUsersByZone()
        gvZonas.DataBind()
        SMI = Nothing

        If lblIDZona.Text.Length > 0 Then ActualizaDetalhe(lblIDZona.Text)

        lblDateTime.Text = Now.ToString
    End Sub

    Private Sub ActualizaDetalhe(ByVal idzona As Integer)
        Dim SMI As New SMIMethodsWebService.SMIMethodsSoapClient
        gvDetalheZona.DataSource = SMI.GetUsersByZone(idzona)
        gvDetalheZona.DataBind()
        SMI = Nothing

        ibFechaDetalhe.Visible = True
    End Sub

    Protected Sub ibFechaDetalhe_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs) Handles ibFechaDetalhe.Click
        gvDetalheZona.DataSource = Nothing
        gvDetalheZona.DataBind()
        lblTituloDetalhe.Text = ""
        lblIDZona.Text = ""
        ibFechaDetalhe.Visible = False
    End Sub

    Protected Sub Timer_Tick(ByVal sender As Object, ByVal e As System.EventArgs) Handles Timer.Tick
        ActualizaResumo()
    End Sub

End Class
