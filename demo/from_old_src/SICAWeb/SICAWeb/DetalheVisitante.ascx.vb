Imports System.Data
Imports System.Configuration.ConfigurationManager


Partial Class DetalheVisitante
    Inherits System.Web.UI.UserControl

    Public Sub AbreCartao(ByVal NumCartao As String)
        LeFamilias()
        LimpaForm()
        txtNumCartao.Text = NumCartao
        txtNumCartao.Enabled = False
        cmdPesquisar.Visible = False
        CarregaInfoVisitanteECartao(NumCartao)
        If lblStatus.Text.Length = 0 Then ActivaCampos(True)
    End Sub

    Protected Sub cmdPesquisar_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdPesquisar.Click
        LimpaForm()
        CarregaInfoVisitanteECartao(txtNumCartao.Text.ToUpper)
    End Sub

    Private Sub LimpaForm(Optional SoInfoVistante As Boolean = False, Optional ConfigAcesso As Boolean = False)
        If Not SoInfoVistante Then
            lblIDRegistoVisitante.Text = ""
            lblIDUtilizador.Text = ""
            lblNumCartao.Text = ""
            lblIDCartao.Text = ""
        End If

        txtVisitanteNome.Text = ""
        txtVisitanteEmpresa.Text = ""
        txtEntidadeVisitadaNome.Text = ""

        txtVisitanteNumEmpregado.Text = ""
        imgVisitanteFotoEmpregado.ImageUrl = "Images/blank.jpg"

        txtVisitanteViaturaMatricula.Text = ""

        If ConfigAcesso Then
            txtVisitanteAcessoHoraEntrada.Text = ""
            txtVisitanteAcessoHoraSaida.Text = ""
            cblVisitanteAcessoFamilia.ClearSelection()
            txtVisitanteAcessoValidade.Text = ""
        End If
        
        lblStatus.Text = ""

        txtVisitanteAcessoHoraEntrada.BackColor = Nothing
        txtVisitanteAcessoHoraSaida.BackColor = Nothing
        txtVisitanteAcessoValidade.BackColor = Nothing
        ddlVisitanteEstadoCartao.BackColor = Nothing
    End Sub

    Private Sub CarregaInfoVisitanteECartao(ByVal NumCartao As String)
        Dim SQLManager As New SQLMethods
        Dim dtInfoAcessoCartao, dtInfoVisitante As DataTable
        Dim connSICA As SqlClient.SqlConnection
        Dim params As New Hashtable
        
        connSICA = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)

        'valida acesso ao cartao
        dtInfoAcessoCartao = SQLManager.SelectQuery("select distinct IDCartao from vwAcessos where NumCartao='" & NumCartao & "' and NomeTerminal like '" & Session("NomeTerminal") & "%'", connSICA)

        If dtInfoAcessoCartao.Rows.Count = 1 Then
            'tem acesso

            'lê informação da última atribuição
            params.Clear()
            params.Add("@NumCartao", NumCartao)
            dtInfoVisitante = SQLManager.GetStoreProcedure(connSICA, _
                                            "sp_tblVisitantes_SelectUltimaAtribuicao", _
                                            params)

            'lê informação do estado do cartão
            Dim SMI As New SMIMethodsWebService.SMIMethodsSoapClient
            Dim InfoCartao As SMIMethodsWebService.SmartCardProperties

            InfoCartao = SMI.GetSmartCardByID(dtInfoAcessoCartao.Rows(0)(0))

            'preenche info do cartão
            If Not InfoCartao Is Nothing Then
                lblIDUtilizador.Text = InfoCartao.idUser
                lblNumCartao.Text = NumCartao
                lblIDCartao.Text = InfoCartao.idSmartCard
                txtVisitanteAcessoValidade.Text = FormataData(InfoCartao.ExpirationDate)
                Select Case InfoCartao.Status
                    Case SMIMethodsWebService.SmartCardStatus.Active
                        ddlVisitanteEstadoCartao.SelectedValue = 2
                    Case SMIMethodsWebService.SmartCardStatus.Forbiden
                        ddlVisitanteEstadoCartao.SelectedValue = 4
                    Case SMIMethodsWebService.SmartCardStatus.Lost
                        ddlVisitanteEstadoCartao.SelectedValue = 8
                    Case SMIMethodsWebService.SmartCardStatus.Stolen
                        ddlVisitanteEstadoCartao.SelectedValue = 16
                    Case SMIMethodsWebService.SmartCardStatus.Destroied
                        ddlVisitanteEstadoCartao.SelectedValue = 32
                    Case Else
                        ddlVisitanteEstadoCartao.SelectedValue = 0
                End Select

                Dim FamiliasCartao() As SMIMethodsWebService.UserFamilies
                FamiliasCartao = SMI.GetUserFamiles(InfoCartao.idUser)

                If Not FamiliasCartao Is Nothing Then
                    For Each li As ListItem In cblVisitanteAcessoFamilia.Items
                        For i As Integer = 0 To FamiliasCartao.Length - 1
                            If li.Value = FamiliasCartao(i).idFamily Then li.Selected = True
                        Next
                    Next
                End If
            End If

            'preenche info da última atribuição
            If dtInfoVisitante.Rows.Count = 1 Then
                lblIDRegistoVisitante.Text = dtInfoVisitante.Rows(0)("ID")
                rblTipoVisitante.SelectedValue = dtInfoVisitante(0)("IDTipoVisitante")
                rblTipoVisitante.SelectedItem.Selected = True
                txtVisitanteNome.Text = IIf(IsDBNull(dtInfoVisitante(0)("NomeVisitante")), "", dtInfoVisitante(0)("NomeVisitante"))
                txtVisitanteEmpresa.Text = IIf(IsDBNull(dtInfoVisitante(0)("EmpresaVisitante")), "", dtInfoVisitante(0)("EmpresaVisitante"))
                txtEntidadeVisitadaNome.Text = IIf(IsDBNull(dtInfoVisitante(0)("EntidadeVisitada")), "", dtInfoVisitante(0)("EntidadeVisitada"))

                txtVisitanteNumEmpregado.Text = IIf(IsDBNull(dtInfoVisitante(0)("NumEmpregado")), "", dtInfoVisitante(0)("NumEmpregado"))

                txtVisitanteViaturaMatricula.Text = IIf(IsDBNull(dtInfoVisitante(0)("MatriculaViatura")), "", dtInfoVisitante(0)("MatriculaViatura"))

                If IsDBNull(dtInfoVisitante(0)("HoraEntrada")) Then
                    txtVisitanteAcessoHoraEntrada.Text = ""
                Else
                    txtVisitanteAcessoHoraEntrada.Text = FormataHora(dtInfoVisitante(0)("HoraEntrada"))
                End If
                If IsDBNull(dtInfoVisitante(0)("HoraSaida")) Then
                    txtVisitanteAcessoHoraSaida.Text = ""
                Else
                    txtVisitanteAcessoHoraSaida.Text = FormataHora(dtInfoVisitante(0)("HoraSaida"))
                End If

                If txtVisitanteAcessoHoraEntrada.Text.Length > 0 And txtVisitanteAcessoHoraSaida.Text.Length > 0 Then
                    lblNovoRegisto.Text = 1
                Else
                    lblNovoRegisto.Text = 0
                End If
            Else
                lblNovoRegisto.Text = 1
                rblTipoVisitante.SelectedIndex = 0
            End If

            'sugestões
            If (txtVisitanteAcessoHoraEntrada.Text.Length = 0 And txtVisitanteAcessoHoraSaida.Text.Length = 0) Or _
                                       (txtVisitanteAcessoHoraEntrada.Text.Length > 0 And txtVisitanteAcessoHoraSaida.Text.Length > 0) Then
                'sugere tipo visitante
                'rblTipoVisitante.SelectedIndex = 0

                'sugere validade
                txtVisitanteAcessoValidade.ToolTip = "Validade actual: " & txtVisitanteAcessoValidade.Text
                txtVisitanteAcessoValidade.Text = FormataData(Now)
                txtVisitanteAcessoValidade.BackColor = Drawing.Color.LightGreen
                'segere tb hora de entrada
                txtVisitanteAcessoHoraEntrada.Text = FormataHora(Now)
                txtVisitanteAcessoHoraEntrada.BackColor = Drawing.Color.LightGreen
                txtVisitanteAcessoHoraSaida.Text = ""
                txtVisitanteAcessoHoraSaida.BackColor = Drawing.Color.LightGreen
                ddlVisitanteEstadoCartao.ToolTip = "Estado actual: " & ddlVisitanteEstadoCartao.Text
                ddlVisitanteEstadoCartao.BackColor = Drawing.Color.LightGreen
                ddlVisitanteEstadoCartao.SelectedValue = "2"
            Else
                If txtVisitanteAcessoHoraEntrada.Text.Length > 0 And txtVisitanteAcessoHoraSaida.Text.Length = 0 Then
                    'sugere hora de saída
                    txtVisitanteAcessoHoraSaida.Text = FormataHora(Now)
                    txtVisitanteAcessoHoraSaida.BackColor = Drawing.Color.LightGreen
                    ddlVisitanteEstadoCartao.ToolTip = "Estado actual: " & ddlVisitanteEstadoCartao.Text
                    ddlVisitanteEstadoCartao.BackColor = Drawing.Color.LightGreen
                    ddlVisitanteEstadoCartao.SelectedValue = "4"
                End If
            End If
            ActivaCampos(True)
            MostraCampos(rblTipoVisitante.SelectedValue)
        Else
            'não tem acesso
            lblStatus.Text = "Sem acesso ao cartão " & NumCartao & "."
            EscreveLog("Terminal sem acesso ao cartão.", NumCartao)
        End If

        SQLManager.DisposeConn(connSICA)
    End Sub

    Private Sub GravaInfoVisitanteECartao()
        Dim SQLManager As New SQLMethods
        Dim connSICA As SqlClient.SqlConnection
        Dim msglog As String = ""
        Dim params As New Hashtable
        Dim SMI As New SMIMethodsWebService.SMIMethodsSoapClient

        connSICA = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)

        'grava info cartão
        Dim NovoEstadoCartao As SMIMethodsWebService.SmartCardStatus
        Select Case ddlVisitanteEstadoCartao.SelectedValue
            Case 2
                NovoEstadoCartao = SMIMethodsWebService.SmartCardStatus.Active
            Case 4
                NovoEstadoCartao = SMIMethodsWebService.SmartCardStatus.Forbiden
            Case 8
                NovoEstadoCartao = SMIMethodsWebService.SmartCardStatus.Lost
            Case 16
                NovoEstadoCartao = SMIMethodsWebService.SmartCardStatus.Stolen
            Case 32
                NovoEstadoCartao = SMIMethodsWebService.SmartCardStatus.Destroied
            Case Else
                NovoEstadoCartao = SMIMethodsWebService.SmartCardStatus.Unknown
        End Select
        SMI.UpdateSmartCard(lblIDCartao.Text, txtVisitanteAcessoValidade.Text, NovoEstadoCartao)

        'utilizador
        For Each li As ListItem In cblVisitanteAcessoFamilia.Items
            If li.Selected Then
                SMI.AddUserFamily(lblIDUtilizador.Text, li.Value)
            Else
                SMI.DeleteUserFamily(lblIDUtilizador.Text, li.Value)
            End If
        Next

        'grava info visitante
        params.Add("@IDCartao", lblIDCartao.Text)
        params.Add("@IDTipoVisitante", rblTipoVisitante.SelectedValue)
        params.Add("@NomeVisitante", txtVisitanteNome.Text)
        params.Add("@EmpresaVisitante", txtVisitanteEmpresa.Text)
        params.Add("@NumEmpregado", txtVisitanteNumEmpregado.Text)
        params.Add("@MatriculaViatura", txtVisitanteViaturaMatricula.Text)
        params.Add("@EntidadeVisitada", txtEntidadeVisitadaNome.Text)
        params.Add("@HoraEntrada", CDate(Now.Date.ToShortDateString & " " & CDate(txtVisitanteAcessoHoraEntrada.Text)))
        If txtVisitanteAcessoHoraSaida.Text.Length = 0 Then
            params.Add("@HoraSaida", DBNull.Value)
        Else
            params.Add("@HoraSaida", CDate(Now.Date.ToShortDateString & " " & CDate(txtVisitanteAcessoHoraSaida.Text)))
        End If
        params.Add("@AtualizadorPorUtilizador", Session("Utilizador"))
        params.Add("@AtualizadorPorTerminal", Session("NomeTerminal"))
        If lblNovoRegisto.Text = 1 Then
            'insert 
            params.Add("@NumCartao", lblNumCartao.Text)
            SQLManager.ExecuteStoreProcedure("sp_tblVisitantes_Insert", connSICA, params)
        Else
            'update
            params.Add("@ID", lblIDRegistoVisitante.Text)
            SQLManager.ExecuteStoreProcedure("sp_tblVisitantes_Update", connSICA, params)
        End If
        params.Clear()

        SQLManager.DisposeConn(connSICA)

        msglog = "Cartão tipo "
        Select Case rblTipoVisitante.SelectedValue
            Case 2
                msglog += " COLABORADOR atribuído a " & _
                    txtVisitanteNome.Text & _
                    "(" & txtVisitanteNumEmpregado.Text & ")" & _
                    ": " & IIf(txtVisitanteAcessoHoraSaida.Text.Length = 0, _
                               "ENTRADA (" & txtVisitanteAcessoHoraEntrada.Text & ")", _
                               "SAÍDA (" & txtVisitanteAcessoHoraSaida.Text & ")")
            Case 3
                msglog += " VIATURA atribuído a " & _
                    txtVisitanteNome.Text & _
                    "(" & txtVisitanteViaturaMatricula.Text & ")" & _
                    ": " & IIf(txtVisitanteAcessoHoraSaida.Text.Length = 0, _
                                "ENTRADA (" & txtVisitanteAcessoHoraEntrada.Text & ")", _
                                "SAÍDA (" & txtVisitanteAcessoHoraSaida.Text & ")")
            Case Else
                msglog += " VISITANTE atribuído a " & _
                    txtVisitanteNome.Text & _
                    ": " & IIf(txtVisitanteAcessoHoraSaida.Text.Length = 0, _
                                "ENTRADA (" & txtVisitanteAcessoHoraEntrada.Text & ")", _
                                "SAÍDA (" & txtVisitanteAcessoHoraSaida.Text & ")")
        End Select

        If msglog.Length > 0 Then EscreveLog(msglog, lblNumCartao.Text, txtVisitanteAcessoValidade.Text, ddlVisitanteEstadoCartao.SelectedItem.Text)
    End Sub

    Private Sub LeFamilias()
        Dim SQLManager As New SQLMethods
        Dim conn As SqlClient.SqlConnection
        Dim dt As DataTable
        Dim dtFamiliasDoTerminal As DataTable = Session("FamiliasTerminal")
        Dim strSQLWhere As String = ""

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)
        For Each dr As DataRow In dtFamiliasDoTerminal.Rows
            If strSQLWhere.Length > 0 Then strSQLWhere += " or ID="
            strSQLWhere += dr("IDFamilia").ToString
        Next
        If strSQLWhere.Length > 0 Then
            strSQLWhere = " where ID=" & strSQLWhere
        End If
        'lê informação adicional para o cartão indicado
        dt = SQLManager.SelectQuery("select * from tblFamilias" & strSQLWhere & " order by Nome", conn)
        SQLManager.DisposeConn(conn)

        cblVisitanteAcessoFamilia.Items.Clear()
        For Each dr As DataRow In dt.Rows
            Dim i As New ListItem(dr("Nome"), dr("ID"))
            cblVisitanteAcessoFamilia.Items.Add(i)
        Next
    End Sub

    Private Sub LeTiposVisitante()
        Dim SQLManager As New SQLMethods
        Dim conn As SqlClient.SqlConnection
        Dim dt As DataTable

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)
        dt = SQLManager.SelectQuery("SELECT ID, Descricao FROM tblTipoVisiante WHERE (Ativo = 1) ORDER BY NumSequencia", conn)
        SQLManager.DisposeConn(conn)

        rblTipoVisitante.Items.Clear()
        For Each dr As DataRow In dt.Rows
            Dim i As New ListItem(dr("Descricao"), dr("ID"))
            rblTipoVisitante.Items.Add(i)
        Next
    End Sub

    Private Function FormataData(ByVal data As DateTime) As String
        Dim result As String

        result = data.Year.ToString & "-"
        If data.Month < 10 Then result += "0"
        result += data.Month.ToString & "-"
        If data.Day < 10 Then result += "0"
        result += data.Day.ToString

        Return result
    End Function

    Private Function FormataHora(ByVal hora As DateTime) As String
        Dim result As String = ""

        If hora.Hour < 10 Then result += "0"
        result += hora.Hour.ToString
        result += ":"
        If hora.Minute < 10 Then result += "0"
        result += hora.Minute.ToString

        Return result
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If IsNothing(Session("FamiliasTerminal")) Then LeFamiliasTerminal(Session("NomeTerminal"))
        If Not IsPostBack Then
            LeFamilias()
            LeTiposVisitante()
            ActivaCampos(False)
            MostraCampos(TipoVisitante.Visitante)
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

    Protected Sub cmdLimpar_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdLimpar.Click
        LimpaForm(True)
    End Sub

    Protected Sub cmdGravar_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdGravar.Click
        Dim ok As Boolean = False
        Dim msg As String

        'verifica se existe algum campo preenchido
        If (txtVisitanteNome.Text.Length > 0 Or txtVisitanteEmpresa.Text.Length > 0 Or txtEntidadeVisitadaNome.Text.Length > 0 Or txtVisitanteNumEmpregado.Text.Length > 0 Or txtVisitanteViaturaMatricula.Text.Length > 0) And _
            (txtVisitanteAcessoHoraEntrada.Text.Length > 0 Or txtVisitanteAcessoHoraSaida.Text.Length > 0) Then
            'verifica se existe uma familia seleccionada
            For Each li As ListItem In cblVisitanteAcessoFamilia.Items
                If li.Selected Then
                    ok = True
                    Exit For
                End If
            Next
            If Not ok Then msg = "Seleccione o acesso pretendido."
            If Not IsDate(txtVisitanteAcessoHoraEntrada.Text) Or (txtVisitanteAcessoHoraSaida.Text.Length > 0 And Not IsDate(txtVisitanteAcessoHoraSaida.Text)) Then
                ok = False
                msg = "Formato de hora incorreto."
            End If

            If ok Then
                GravaInfoVisitanteECartao()
                LimpaForm(False, True)
                lblNumCartaoLabel.Visible = True
                txtNumCartao.Enabled = True
                cmdPesquisar.Visible = True
                txtNumCartao.Text = ""
                msg = "Informação gravada com sucesso."
                ActivaCampos(False)
            End If
        Else
            msg = "Identifique os dados do visitante e a hora de entrada/saída."
        End If

        lblStatus.Text = msg
    End Sub

    Protected Sub cmdCancelar_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdCancelar.Click
        LimpaForm(False, True)
        txtNumCartao.Text = ""
        lblNumCartaoLabel.Visible = True
        txtNumCartao.Enabled = True
        cmdPesquisar.Visible = True
        ActivaCampos(False)
    End Sub

    Private Sub EscreveLog(ByVal texto As String, Optional ByVal cartao As String = "", Optional ByVal validadeCartao As String = "", Optional ByVal estadoCartao As String = "", Optional ByVal familiaCartao As String = "")
        Dim SQLManager As New SQLMethods
        Dim conn As SqlClient.SqlConnection
        Dim params As New Hashtable

        params.Add("@Texto", texto)
        params.Add("@Cartao", cartao)
        If validadeCartao.Length > 0 Then params.Add("@ValidadeCartao", CDate(validadeCartao))
        If estadoCartao.Length > 0 Then params.Add("@EstadoCartao", estadoCartao)
        If familiaCartao.Length > 0 Then params.Add("@FamiliaCartao", familiaCartao)
        params.Add("@Terminal", Session("NomeTerminal"))
        params.Add("@Utilizador", Session("Utilizador"))
        conn = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)
        SQLManager.ExecuteStoreProcedure("sp_tblLog_Insert", conn, params)
        params.Clear()
        SQLManager.DisposeConn(conn)
    End Sub

    Private Sub ActivaCampos(ByVal op As Boolean)
        rblTipoVisitante.Enabled = op
        txtVisitanteNome.Enabled = op
        txtVisitanteEmpresa.Enabled = op
        txtEntidadeVisitadaNome.Enabled = op

        txtVisitanteNumEmpregado.Enabled = op
        cmdValidarEmpregado.Enabled = op

        txtVisitanteViaturaMatricula.Enabled = op

        txtVisitanteAcessoHoraEntrada.Enabled = op
        txtVisitanteAcessoHoraSaida.Enabled = op
        cblVisitanteAcessoFamilia.Enabled = op
        txtVisitanteAcessoValidade.Enabled = op
        ddlVisitanteEstadoCartao.Enabled = op
        txtNumCartao.Visible = Not op
        lblNumCartao.Visible = op
        cmdPesquisar.Enabled = Not op
    End Sub

    Private Sub MostraCampos(TipoVisitante As TipoVisitante)
        lblVisitanteColaborador.Visible = False
        lblVisitanteNumEmpregado.Visible = False
        txtVisitanteNumEmpregado.Visible = False
        cmdValidarEmpregado.Visible = False
        imgVisitanteFotoEmpregado.Visible = False

        lblVisitanteViatura.Visible = False
        lblVisitanteViaturaMatricula.Visible = False
        txtVisitanteViaturaMatricula.Visible = False

        Select Case TipoVisitante
            Case DetalheVisitante.TipoVisitante.Colaborador
                lblVisitanteColaborador.Visible = False
                txtVisitanteNome.Enabled = False
                txtVisitanteEmpresa.Enabled = False
                txtEntidadeVisitadaNome.Enabled = False

                lblVisitanteNumEmpregado.Visible = True
                txtVisitanteNumEmpregado.Visible = True
                cmdValidarEmpregado.Visible = True
                imgVisitanteFotoEmpregado.Visible = True
            Case DetalheVisitante.TipoVisitante.Viatura
                lblVisitanteViatura.Visible = True
                txtVisitanteNome.Enabled = True
                txtVisitanteEmpresa.Enabled = True
                txtEntidadeVisitadaNome.Enabled = True

                lblVisitanteViaturaMatricula.Visible = True
                txtVisitanteViaturaMatricula.Visible = True
            Case Else
                txtVisitanteNome.Enabled = True
                txtVisitanteEmpresa.Enabled = True
                txtEntidadeVisitadaNome.Enabled = True
        End Select
    End Sub

    Private Enum TipoVisitante
        Visitante = 1
        Colaborador = 2
        Viatura = 3
    End Enum

    Protected Sub rblTipoVisitante_SelectedIndexChanged(sender As Object, e As System.EventArgs) Handles rblTipoVisitante.SelectedIndexChanged
        Select Case rblTipoVisitante.SelectedValue
            Case 2
                'colaborador
                MostraCampos(TipoVisitante.Colaborador)
            Case 3
                'viatura
                MostraCampos(TipoVisitante.Viatura)
            Case Else
                MostraCampos(TipoVisitante.Visitante)
        End Select
        LimpaForm(True)
    End Sub

    Protected Sub cmdValidarEmpregado_Click(sender As Object, e As System.EventArgs) Handles cmdValidarEmpregado.Click
        Dim SQLManager As New SQLMethods
        Dim conn As SqlClient.SqlConnection
        Dim dt As DataTable
        
        conn = SQLManager.InicializeConnSQL(ConnectionStrings("ActiveDirectoryConnectionString").ConnectionString)
        dt = SQLManager.SelectQuery("select sAMAccountName,displayName,department,wWWHomePage FROM tblAD_AD_SQL where employeeID='" & txtVisitanteNumEmpregado.Text & "'", conn)
        SQLManager.DisposeConn(conn)

        If dt.Rows.Count > 0 Then
            txtVisitanteNome.Text = dt(0)("displayName").ToString
            txtVisitanteEmpresa.Text = dt(0)("department").ToString
            txtEntidadeVisitadaNome.Text = dt(0)("sAMAccountName").ToString
            imgVisitanteFotoEmpregado.ImageUrl = dt(0)("wWWHomePage").ToString
        Else
            txtVisitanteNome.Text = ""
            txtVisitanteEmpresa.Text = ""
            txtEntidadeVisitadaNome.Text = ""
            imgVisitanteFotoEmpregado.ImageUrl = "Images/blank.jpg"
            lblStatus.Text = "Número de empregado inexistente."
        End If
        dt.Dispose()
    End Sub

End Class
