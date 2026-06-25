Imports System.Data
Imports System.Configuration.ConfigurationManager

Partial Class LogPorta
    Inherits System.Web.UI.UserControl

    Public Function ActualizaInfo(ByVal circuitID As String) As SMIMethodsWebService.EventProperties
        Dim dtCircuitosFisicos As DataTable
        Dim drCircuitosFisicos() As DataRow
        Dim CircuitIDs As String = ""
        Dim SMI As New SMIMethodsWebService.SMIMethodsSoapClient
        Dim UltimasPassagens As SMIMethodsWebService.EventProperties()
        Dim UltimaPassagem As SMIMethodsWebService.EventProperties

        'lê os circuitos físicos
        dtCircuitosFisicos = Session("CircuitosFisicos")
        drCircuitosFisicos = dtCircuitosFisicos.Select("IDCircuitoGrupo = " & circuitID)

        For Each dr As DataRow In drCircuitosFisicos
            If CircuitIDs.Length > 0 Then CircuitIDs += ","
            CircuitIDs += dr("IDCircuito").ToString
        Next

        UltimasPassagens = SMI.GetLastCircuitEvents(CircuitIDs, 72, 20)
        gvLog.DataSource = UltimasPassagens
        If UltimasPassagens Is Nothing Then
            UltimaPassagem = Nothing
        Else
            If UltimasPassagens.Length > 0 Then
                UltimaPassagem = UltimasPassagens(0)
            Else
                UltimaPassagem = Nothing
            End If
        End If
        gvLog.DataBind()

        Return UltimaPassagem
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If AppSettings("ShowRefreshTime") = "1" Then
            lblDateTime.Visible = True
        Else
            lblDateTime.Visible = False
        End If

        lblDateTime.Text = Now.ToString
    End Sub
End Class
