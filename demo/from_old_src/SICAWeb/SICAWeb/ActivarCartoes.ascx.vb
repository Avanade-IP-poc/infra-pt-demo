Imports System.Data
Imports System.Configuration.ConfigurationManager

Partial Class ActivarCartoes
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If IsNothing(Session("FamiliasTerminal")) Then LeFamiliasTerminal(Session("NomeTerminal"))

        If Not IsPostBack Then
            CarregaCartoesDisponiveis()
            LeFamilias()
            txtVisitanteAcessoValidade.Text = FormataData(Now)
        End If
    End Sub

    Private Sub LeFamiliasTerminal(ByVal Nome As String)
        Dim SQLManager As New SQLMethods
        Dim conn As SqlClient.SqlConnection
        Dim dtFamilias As DataTable

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)
        dtFamilias = SQLManager.SelectQuery("select IDFamilia from vwFamilias where NomeTerminal='" & Nome & "'", conn)
        SQLManager.DisposeConn(conn)

        Session("FamiliasTerminal") = dtFamilias
        dtFamilias.Dispose()
    End Sub

    Private Sub LeFamilias()
        Dim SQLManager As New SQLMethods
        Dim conn As SqlClient.SqlConnection
        Dim dt As DataTable
        Dim dtFamiliasDoTerminal As DataTable = Session("FamiliasTerminal")
        Dim strSQLWhere As String = ""

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
        For Each dr As DataRow In dtFamiliasDoTerminal.Rows
            If strSQLWhere.Length > 0 Then strSQLWhere += " or ID="
            strSQLWhere += dr("IDFamilia").ToString
        Next
        If strSQLWhere.Length > 0 Then
            strSQLWhere = " where ID=" & strSQLWhere
        End If
        'lê informação adicional para o cartão indicado
        dt = SQLManager.SelectQuery("select * from vwREFERFamilias" & strSQLWhere, conn)
        SQLManager.DisposeConn(conn)

        lbVisitanteAcessoFamilia.Items.Clear()
        For Each dr As DataRow In dt.Rows
            Dim i As New ListItem(dr("Nome"), dr("ID"))
            lbVisitanteAcessoFamilia.Items.Add(i)
        Next
    End Sub

    Public Sub CarregaCartoesDisponiveis()
        Try
            Dim SQLManager As New SQLMethods
            Dim conn As SqlClient.SqlConnection
            Dim dtCartoes As DataTable
            Dim dtCartoesDisponiveis As New DataTable
            Dim dtCartoesDoTerminal As DataTable = Session("CartoesTerminal")
            Dim Cartao As New InfoCartao
            Dim strSQLWhere As String = ""

            If dtCartoesDoTerminal.Rows.Count > 0 Then
                conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
                For Each dr As DataRow In dtCartoesDoTerminal.Rows
                    If strSQLWhere.Length > 0 Then strSQLWhere += " or NumCartao="
                    strSQLWhere += "'" & dr("NumCartao") & "'"
                Next
                If strSQLWhere.Length > 0 Then
                    strSQLWhere = " where NumCartao=" & strSQLWhere
                End If
                dtCartoes = SQLManager.SelectQuery("select *, NumCartao + ' - ' + Nome as Descricao from vwREFERVisitantes" & strSQLWhere & " order by NumCartao,IDCampo", conn)
                SQLManager.DisposeConn(conn)

                'controi tabela final
                dtCartoesDisponiveis.Columns.Add("NumCartao")
                dtCartoesDisponiveis.Columns.Add("Descricao")
                dtCartoesDisponiveis.Columns.Add("HoraEntrada")
                dtCartoesDisponiveis.Columns.Add("ValidadeCartao")

                Cartao.Descricao = ""
                Cartao.HoraEntrada = ""
                Cartao.HoraSaida = ""
                For Each drCartao As DataRow In dtCartoes.Rows
                    If Cartao.NumCartao = drCartao("NumCartao") Then
                        LeCampoCartao(drCartao, Cartao)
                    Else
                        'verifica se o cartão tem hora de saída
                        If Cartao.HoraSaida.Length > 0 Or (Cartao.HoraEntrada.Length = 0 And Cartao.HoraSaida.Length = 0) Then
                            'escreve registo na tabela final
                            Dim drCartoesDisponiveis As DataRow

                            drCartoesDisponiveis = dtCartoesDisponiveis.NewRow
                            drCartoesDisponiveis("NumCartao") = Cartao.NumCartao
                            drCartoesDisponiveis("Descricao") = Cartao.Descricao
                            drCartoesDisponiveis("HoraEntrada") = Cartao.HoraEntrada
                            drCartoesDisponiveis("ValidadeCartao") = Cartao.ValidadeCartao
                            dtCartoesDisponiveis.Rows.Add(drCartoesDisponiveis)

                            drCartoesDisponiveis = Nothing
                        End If
                        Cartao.NumCartao = drCartao("NumCartao")
                        Cartao.Descricao = drCartao("Descricao")
                        Cartao.HoraEntrada = ""
                        Cartao.HoraSaida = ""
                        Cartao.ValidadeCartao = drCartao("ValidadeCartao")
                        LeCampoCartao(drCartao, Cartao)
                    End If
                Next
                'para o ultimo cartao 
                'verifica se o cartão tem hora de saída
                If Cartao.HoraSaida.Length > 0 Then
                    'escreve registo na tabela final
                    Dim drCartoesDisponiveis As DataRow

                    drCartoesDisponiveis = dtCartoesDisponiveis.NewRow
                    drCartoesDisponiveis("NumCartao") = Cartao.NumCartao
                    drCartoesDisponiveis("Descricao") = Cartao.Descricao
                    drCartoesDisponiveis("HoraEntrada") = Cartao.HoraEntrada
                    drCartoesDisponiveis("ValidadeCartao") = Cartao.ValidadeCartao
                    dtCartoesDisponiveis.Rows.Add(drCartoesDisponiveis)

                    drCartoesDisponiveis = Nothing
                End If

                lbCartoesDisponiveis.DataSource = dtCartoesDisponiveis
                lbCartoesDisponiveis.DataBind()
            End If
        Catch ex As Exception
            EscreveLog("CartoesFora.ascx - PesquisaCartoesFora - " & Err.Description)
        End Try
    End Sub

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

    Private Structure InfoCartao
        Dim NumCartao As String
        Dim Descricao As String
        Dim HoraEntrada As String
        Dim HoraSaida As String
        Dim ValidadeCartao As Date
    End Structure

    Private Sub LeCampoCartao(ByVal dr As DataRow, ByRef cartao As InfoCartao)
        Select Case dr("IDCampo")
            'Case 3
            'nome do visitante
            'cartao.Descricao = LeValorCampoAdicional(dr)
            Case 5
                'empresa do visitante
                cartao.Descricao += " (" & LeValorCampoAdicional(dr) & ")"
            Case 6
                'hora de entrada
                cartao.HoraEntrada = LeValorCampoAdicional(dr)
            Case 7
                'hora de saída
                cartao.HoraSaida = LeValorCampoAdicional(dr)
        End Select
    End Sub

    Private Function LeValorCampoAdicional(ByVal dr As DataRow) As Object
        Dim result As Object

        Select Case dr("TipoValor")
            Case 1
                result = dr("ValorTipo1")
            Case 2
                result = dr("ValorTipo2")
            Case 3
                result = dr("ValorTipo3")
        End Select

        If IsDBNull(result) Then result = Nothing
        Return result
    End Function

    Protected Sub cmdLimpar_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdLimpar.Click
        'Dim mPage As MasterPage = Page.Master
        'mPage.MarcaMovimentoSessao()

        txtVisitanteNome.Text = ""
        txtVisitanteEmpresa.Text = ""
        txtEntidadeVisitadaNome.Text = ""
        txtVisitanteAcessoHoraEntrada.Text = ""
        txtVisitanteAcessoHoraSaida.Text = ""
        lbVisitanteAcessoFamilia.ClearSelection()
        txtVisitanteAcessoValidade.Text = ""
        lblStatus.Text = ""
        ddlVisitanteEstadoCartao.ClearSelection()
    End Sub

    'Protected Sub cmdCancelar_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdCancelar.Click
    '    Dim mPage As MasterPage = Page.Master
    '    mPage.MarcaMovimentoSessao()
    'End Sub

    Protected Sub cmdGravar_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdGravar.Click
        'Dim mPage As MasterPage = Page.Master
        'mPage.MarcaMovimentoSessao()
        Dim ok As Boolean = False

        'verifica se existe algum campo preenchido
        If txtVisitanteNome.Text.Length > 0 Or txtVisitanteEmpresa.Text.Length > 0 Or txtEntidadeVisitadaNome.Text.Length > 0 Or txtVisitanteAcessoHoraEntrada.Text.Length > 0 Or txtVisitanteAcessoHoraSaida.Text.Length > 0 Then
            'verifica se existe uma familia seleccionada
            For Each li As ListItem In lbVisitanteAcessoFamilia.Items
                If li.Selected Then
                    ok = True
                    Exit For
                End If
            Next
            If ok Then
                Dim nCartoesActualizador As Integer = 0

                For Each item As ListItem In lbCartoesDisponiveis.Items
                    If item.Selected Then
                        GravaInfoAdicional(item.Value)
                        nCartoesActualizador += 1
                    End If
                Next
                If nCartoesActualizador > 0 Then
                    LimpaForm()
                    lblStatus.Text = "Informação gravada com sucesso."
                Else
                    lblStatus.Text = "Seleccione um ou mais cartões disponíveis."
                End If
            Else
                lblStatus.Text = "Seleccione o acesso pretendido."
            End If
        Else
            lblStatus.Text = "Identifique o destinatário do cartão."
        End If
    End Sub

    Private Sub GravaInfoAdicional(ByVal numCartao As String)
        Dim SQLManager As New SQLMethods
        Dim conn As SqlClient.SqlConnection
        Dim params As New Hashtable
        Dim dtInfoAdicional As DataTable
        Dim idUtilizador As Integer
        Dim idCartao As Integer

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)

        'lê informação adicional para o cartão indicado
        params.Add("@NumCartao", numCartao)
        dtInfoAdicional = SQLManager.GetStoreProcedure(conn, _
                                        "spREFER_vwREFERVisitantesSelectByNumCartao", _
                                        params)
        params.Clear()

        idUtilizador = dtInfoAdicional.Rows(0)("IDUtilizador")
        idCartao = dtInfoAdicional.Rows(0)("IDCartao")

        'grava nome do visitante
        GravaCampoAdicional(idUtilizador, 3, txtVisitanteNome.Text, conn, SQLManager)
        'grava empresa do visitante
        GravaCampoAdicional(idUtilizador, 5, txtVisitanteEmpresa.Text, conn, SQLManager)
        'grava entidade visitada
        GravaCampoAdicional(idUtilizador, 4, txtEntidadeVisitadaNome.Text, conn, SQLManager)
        'grava hora de entrada
        GravaCampoAdicional(idUtilizador, 6, txtVisitanteAcessoHoraEntrada.Text, conn, SQLManager)
        'grava hora de saida
        GravaCampoAdicional(idUtilizador, 7, txtVisitanteAcessoHoraSaida.Text, conn, SQLManager)

        'grava data de validade do cartao
        GravaCartao(idCartao, _
                    txtVisitanteAcessoValidade.Text, _
                    idUtilizador, _
                    lbVisitanteAcessoFamilia.SelectedValue, _
                    ddlVisitanteEstadoCartao.SelectedValue, _
                    conn, _
                    SQLManager)

        SQLManager.DisposeConn(conn)

        If txtVisitanteAcessoHoraEntrada.Text.Length > 0 And txtVisitanteAcessoHoraSaida.Text.Length = 0 Then
            'entrada
            EscreveLog("Cartão atribuído a " & txtVisitanteNome.Text & " (" & txtVisitanteEmpresa.Text & "): ENTRADA.", numCartao)
        Else
            If txtVisitanteAcessoHoraEntrada.Text.Length > 0 And txtVisitanteAcessoHoraSaida.Text.Length > 0 Then
                'saída
                EscreveLog("Cartão atribuído a " & txtVisitanteNome.Text & " (" & txtVisitanteEmpresa.Text & "): SAÍDA.", numCartao)
            Else
                EscreveLog("Informação alterada no cartão.", numCartao)
            End If
        End If

        dtInfoAdicional.Clear()
        dtInfoAdicional.Dispose()
    End Sub

    Private Sub GravaCampoAdicional(ByVal IDUtilizador As Integer, ByVal IDCampo As Integer, ByVal Valor As String, ByVal conn As SqlClient.SqlConnection, ByVal SQLManager As SQLMethods)
        Dim params As New Hashtable

        params.Add("@IDUtilizador", IDUtilizador)
        params.Add("@IDCampo", IDCampo)
        params.Add("@ValorTipo2", Valor)
        SQLManager.ExecuteStoreProcedure("spREFER_ActualizaVisitante", conn, params)
    End Sub

    Private Sub GravaCartao(ByVal IDCartao As Integer, ByVal DataValidade As DateTime, ByVal IDUtilizador As Integer, ByVal IDFamilia As Integer, ByVal Estado As Integer, ByVal conn As SqlClient.SqlConnection, ByVal SQLManager As SQLMethods)
        Dim params As New Hashtable

        'cartão
        params.Add("@IDCartao", IDCartao)
        params.Add("@DataValidade", DataValidade)
        params.Add("@Estado", Estado)
        SQLManager.ExecuteStoreProcedure("spREFER_ActualizaCartao", conn, params)
        params.Clear()

        'utilizador
        params.Add("@IDUtilizador", IDUtilizador)
        params.Add("@IDFamilia", IDFamilia)
        SQLManager.ExecuteStoreProcedure("spREFER_ActualizaUtilizador", conn, params)
    End Sub

    Private Sub LimpaForm()
        txtVisitanteNome.Text = ""
        txtVisitanteEmpresa.Text = ""
        txtEntidadeVisitadaNome.Text = ""
        txtVisitanteAcessoHoraEntrada.Text = ""
        txtVisitanteAcessoHoraSaida.Text = ""
        lbVisitanteAcessoFamilia.ClearSelection()
        txtVisitanteAcessoValidade.Text = ""
        lblStatus.Text = ""
    End Sub

    Private Function FormataData(ByVal data As DateTime) As String
        Dim result As String

        result = data.Year & "-"
        If data.Month < 10 Then result += "0"
        result += data.Month & "-"
        If data.Day < 10 Then result += "0"
        result += data.Day.ToString

        Return result
    End Function
End Class
