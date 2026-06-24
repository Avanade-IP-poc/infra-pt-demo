Imports System.Data
Imports System.Configuration.ConfigurationManager

Partial Class Visitantes
    Inherits System.Web.UI.UserControl

#Region " Activação Multipla"

#End Region

#Region " Cartões atribuídos"

    Protected Sub gvCartoesFora_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles gvCartoesFora.SelectedIndexChanged
        DetalheVisitante.AbreCartao(CType(gvCartoesFora.SelectedRow.FindControl("lblNCartao"), Label).Text)
        upAtribuirCartao.Update()
    End Sub

    Private Sub LeCartoesDoTerminal(ByVal Host As String, ByVal Tipo As TipoHost)
        Dim SQLManager As New SQLMethods
        Dim conn As SqlClient.SqlConnection
        Dim dtCartoes As DataTable

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)
        Select Case Tipo
            Case TipoHost.IP
                dtCartoes = SQLManager.SelectQuery("select NumCartao from vwCartoes where IPTerminal='" & Host & "' order by NumCartao", conn)
            Case TipoHost.Nome
                dtCartoes = SQLManager.SelectQuery("select NumCartao from vwCartoes where upper(NomeTerminal)='" & Host & "' order by NumCartao", conn)
        End Select
        SQLManager.DisposeConn(conn)

        Session("CartoesTerminal") = dtCartoes
        dtCartoes.Dispose()
    End Sub

    Private Enum TipoHost
        IP = 0
        Nome = 1
    End Enum

    Private Sub PesquisaCartoesAtribuidos()
        Try
            Dim SQLManager As New SQLMethods
            Dim connSICA As SqlClient.SqlConnection
            Dim dtCartoesAtribuídos As New DataTable
            Dim dtCartoesDoTerminal As DataTable = Session("CartoesTerminal")
            Dim Cartao As New InfoCartao
            Dim params As New Hashtable

            If dtCartoesDoTerminal.Rows.Count > 0 Then
                connSICA = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)

                params.Add("@NomeTerminal", Session("NomeTerminal"))
                dtCartoesAtribuídos = SQLManager.GetStoreProcedure(connSICA, _
                                                "sp_tblVisitantes_SelectAtribuidosByNomeTerminal", _
                                                params)
                SQLManager.DisposeConn(connSICA)

                gvCartoesFora.DataSource = dtCartoesAtribuídos
                gvCartoesFora.DataBind()
                If dtCartoesAtribuídos.Rows.Count = 0 Then lblSemCartoesAtribuidos.Visible = True
            Else
                lblSemCartoesAtribuidos.Visible = True
            End If
        Catch ex As Exception
            EscreveLog("CartoesFora.ascx - PesquisaCartoesFora - " & Err.Description)
        End Try
    End Sub

    Private Structure InfoCartao
        Dim NumCartao As String
        Dim Visitante As String
        Dim HoraEntrada As String
        Dim HoraSaida As String
        Dim ValidadeCartao As Date
    End Structure

    Protected Sub TimerCartoesFora_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        PesquisaCartoesAtribuidos()
        lblDateTime.Text = Now.ToString
    End Sub
#End Region

#Region " Comum"

    Private Sub EscreveLog(ByVal texto As String, Optional ByVal cartao As String = "")
        Dim SQLManager As New SQLMethods
        Dim conn As SqlClient.SqlConnection
        Dim params As New Hashtable

        params.Add("@Texto", texto)
        params.Add("@Cartao", cartao)
        params.Add("@Terminal", Session("NomeTerminal"))
        params.Add("@Utilizador", Session("Utilizador"))
        conn = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)
        SQLManager.ExecuteStoreProcedure("sp_tblLog_Insert", conn, params)
        params.Clear()
        SQLManager.DisposeConn(conn)
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If IsNothing(Session("FamiliasTerminal")) Then LeFamiliasTerminal(Session("NomeTerminal"))
        If IsNothing(Session("CartoesTerminal")) Then LeCartoesDoTerminal(Session("NomeTerminal"), TipoHost.Nome)

        If AppSettings("ShowRefreshTime") = "1" Then
            lblDateTime.Visible = True
        Else
            lblDateTime.Visible = False
        End If
        lblDateTime.Text = Now.ToString

        If Not IsPostBack Then
            TimerCartoesFora.Interval = AppSettings("CartoesForaRefreshInterval") * 1000
            PesquisaCartoesAtribuidos()
        End If
    End Sub

    Private Sub LeFamiliasTerminal(ByVal NomeTerminal As String)
        Dim SQLManager As New SQLMethods
        Dim conn As SqlClient.SqlConnection
        Dim dtFamilias As DataTable

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)
        dtFamilias = SQLManager.SelectQuery("select IDFamilia from vwFamilias where NomeTerminal='" & NomeTerminal & "'", conn)
        SQLManager.DisposeConn(conn)

        Session("FamiliasTerminal") = dtFamilias
        dtFamilias.Dispose()
    End Sub

#End Region

End Class
