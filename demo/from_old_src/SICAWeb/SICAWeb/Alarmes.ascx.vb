Imports System.Configuration.ConfigurationManager

Partial Class Alarmes
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        lblNumDias.Text = AppSettings("AlarmDaysToShow")
        lblDateTime.Text = Now.ToString
        TimerAlarmes.Interval = AppSettings("AlarmsRefreshInterval") * 1000
        If AppSettings("ShowRefreshTime") = "1" Then
            lblDateTime.Visible = True
        Else
            lblDateTime.Visible = False
        End If
    End Sub
End Class
