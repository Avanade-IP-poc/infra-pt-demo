Imports System.Data.SqlClient
Imports System.Data
Imports System.Configuration.ConfigurationManager

Partial Class Circuitos
    Inherits System.Web.UI.UserControl

    Protected Sub ddlCircuit_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlCircuit.SelectedIndexChanged
        Session("CircuitoSeleccionado") = ddlCircuit.SelectedItem.Value
        Refresh()
    End Sub

    Protected Sub timerLogPorta_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Refresh()
    End Sub

    Private Sub LeCircuitos()
        If Session("Circuitos") Is Nothing Then
            Dim SQLManager As New SQLMethods
            Dim conn As SqlClient.SqlConnection
            Dim params As New Hashtable
            Dim dtCircuitos As DataTable
            Dim dtCircuitosFisicos As DataTable
            Dim strWhere As String = ""

            conn = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)

            params.Add("@Nome", Session("NomeTerminal"))
            dtCircuitos = SQLManager.GetStoreProcedure(conn, "SelectVwCircuitosByNomeTerminal", params)
            Session("Circuitos") = dtCircuitos
            params.Clear()

            For Each drCircuitosFisicos As DataRow In dtCircuitos.Rows
                If strWhere.Length > 0 Then strWhere += ","
                strWhere += drCircuitosFisicos("IDCircuito").ToString
            Next
            dtCircuitosFisicos = SQLManager.SelectQuery("select distinct IDCircuitoGrupo,ID as IDCircuito from tblCircuitos where IDCircuitoGrupo in (" & strWhere & ")", conn)
            Session("CircuitosFisicos") = dtCircuitosFisicos

            dtCircuitos = Nothing
            dtCircuitosFisicos = Nothing
            SQLManager.DisposeConn(conn)
        End If

        ddlCircuit.DataSource = Session("Circuitos")
        ddlCircuit.DataBind()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            timerLogPorta.Interval = AppSettings("DisplayLogRefreshInterval") * 1000
            LeCircuitos()
            Refresh()
        End If
    End Sub

    Protected Sub ibRefresh_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs) Handles ibRefresh.Click
        Refresh()
    End Sub

    Private Sub Refresh()
        If ddlCircuit.Items.Count > 0 Then
            Dim UltimaPassagem As SMIMethodsWebService.EventProperties

            UltimaPassagem = LogPorta.ActualizaInfo(ddlCircuit.SelectedItem.Value)
            DetalheUtilizador.RefreshInfo(UltimaPassagem)
            UltimaPassagem = Nothing
        End If
    End Sub
End Class
