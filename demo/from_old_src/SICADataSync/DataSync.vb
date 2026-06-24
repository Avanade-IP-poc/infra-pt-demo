Imports System.Data.SqlClient
Imports System.Configuration.ConfigurationManager
Imports System.DirectoryServices
Imports System.Windows.Forms.Application

Public Class DataSync

    Private SQLManager As New SQLMethods
    Private log As Logs

    Private Sub cmdRun_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdRun.Click
        ProcessaActualizacoes()
        'CriaUtilizadoresNaBDAlizes()
    End Sub

    Private Sub CriaUtilizadoresNaBDAlizes()
        'Dim connSICA As New SqlConnection
        'Dim strSQL As String
        'log = New Logs

        'Dim strNomenclaturaCartao As String = "S"
        'Dim strNomeCartao As String = "Vigilante REFER"
        'Dim numCartaoInicio As Integer = 101
        'Dim numCartaoFim As Integer = 150

        'connSICA = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
        'WriteLog("A criar utilizadores.")
        'For i As Integer = numCartaoInicio To numCartaoFim
        '    Dim aux As String = ""

        '    If i < 10 Then aux = aux & "0"
        '    If i < 100 Then aux = aux & "0"
        '    aux = aux & i
        '    WriteLog("A criar " & strNomenclaturaCartao & aux & " - " & strNomeCartao)
        '    strSQL = "INSERT INTO [Usager] ([idfamille],[codelogique],[nom],[prenom],[type],[etatcrise],[datevalidite],[codecip],[confirmtype],[confirmautorise],[matricule],[listerouge],[idzonevehicule],[idzonegeographique],[iddomaine],[datecreation],[datemodif],[datepassage],[idtetedelecture],[timestamp],[supprime]) " & _
        '        "VALUES (9,'" & strNomenclaturaCartao & aux & "','" & strNomeCartao & "','" & strNomeCartao & "',2,0,'2009-04-14',100,1,0,'',0,null,4,null,getdate(),getdate(),null,5,getdate(),0)"
        '    SQLManager.UpdateQuery(strSQL, connSICA)
        'Next
        'WriteLog("Fim de criação de utilizadores.")
        'connSICA.Close()
        'connSICA.Dispose()
        'log.Close()
    End Sub

    Private Sub ProcessaActualizacoesOLD()
        '    Dim connSICA As New SqlConnection
        '    Dim dtAD, dtADREFERPatrimonio, dtSICA, dtCartoesActivos As DataTable

        '    log = New Logs
        '    pgProgress.Minimum = 0
        '    pgProgress.Value = 0

        '    lbLog.Items.Clear()
        '    WriteLog("A ler utilizadores REFER.")
        '    'lê info na AD da REFER
        '    dtAD = LeUtilizadoresREFER()

        '    'lê info na AD da REFERPatrimonio
        '    dtADREFERPatrimonio = LeUtilizadoresREFERPatrimonio()

        '    WriteLog("A ler informação no SICA.")
        '    connSICA = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)

        '    'lê utilizadores no SICA
        '    dtSICA = SQLManager.SelectQuery("select idusager,nom,prenom,codelogique,idfamille,idsociete from VueUsagers where supprime=0", connSICA)
        '    'lê cartões activos
        '    dtCartoesActivos = SQLManager.SelectQuery("select idbadge,libelle,codelogique from badge where statutbadge=2 and supprime=0", connSICA)

        '    pgProgress.Maximum = dtAD.Rows.Count

        '    'carrega utilizadores REFER
        '    WriteLog("A actualizar utilizadores REFER...")
        '    For Each drAD As DataRow In dtAD.Rows
        '        pgProgress.Increment(1)
        '        DoEvents()

        '        If Not IsDBNull(drAD("employeeID")) Then
        '            If drAD("employeeID").ToString.Length = 7 And drAD("employeeID").ToString.Substring(0, 6) <> "999999" And drAD("employeeID").ToString.Substring(0, 6) <> "888888" And drAD("employeeID").ToString.Substring(0, 6) <> "777777" Then

        '                'verifica se é cessado
        '                If drAD("distinguishedName").ToString.IndexOf(AppSettings("OUCessadosREFER")) >= 0 Then
        '                    DesactivaCartoesUtilizador(drAD("employeeID").ToString, dtCartoesActivos.Select("codelogique='" & drAD("employeeID") & "'"), connSICA)
        '                Else
        '                    Dim drSICA() As DataRow = dtSICA.Select("codelogique='" & drAD("employeeID") & "'")

        '                    If drSICA.Length = 0 Then
        '                        'criar novo utilizador SICA
        '                        WriteLog(vbTab & "Novo utilizador REFER: " & drAD("employeeID") & " - " & drAD("givenName") & " " & drAD("sn"))
        '                        NovoUtilizadorSICA(drAD, connSICA, Empresa.REFER)
        '                    Else
        '                        'actualizar informação do utilizador SICA
        '                        ActualizaUtilizadorSICA(drAD, drSICA(0), connSICA, Empresa.REFER)
        '                    End If
        '                End If
        '            End If
        '        End If
        '    Next
        '    dtAD.Clear()

        '    'lê info na AD da REFERTelecom
        '    WriteLog("A ler utilizadores REFER Telecom.")
        '    dtAD = LeUtilizadoresREFERTelecom()

        '    pgProgress.Value = 0
        '    pgProgress.Maximum = dtAD.Rows.Count

        '    'carrega utilizadores REFERTelecom
        '    WriteLog("A actualizar utilizadores REFER Telecom...")
        '    For Each drAD As DataRow In dtAD.Rows
        '        pgProgress.Increment(1)
        '        DoEvents()

        '        If Not IsDBNull(drAD("employeeID")) Then
        '            If drAD("employeeID").ToString.Length = 6 Then

        '                'verifica se é cessado
        '                If drAD("distinguishedName").ToString.IndexOf(AppSettings("OUCessadosREFERTelecom")) >= 0 Then
        '                    DesactivaCartoesUtilizador(drAD("employeeID").ToString, dtCartoesActivos.Select("codelogique='" & drAD("employeeID") & "'"), connSICA)
        '                Else
        '                    Dim drSICA() As DataRow = dtSICA.Select("codelogique='" & drAD("employeeID") & "'")

        '                    If drSICA.Length = 0 Then
        '                        'criar novo utilizador SICA
        '                        WriteLog(vbTab & "Novo utilizador REFERTelecom: " & drAD("employeeID") & " - " & drAD("givenName") & " " & drAD("sn"))
        '                        NovoUtilizadorSICA(drAD, connSICA, Empresa.REFERTelecom)
        '                    Else
        '                        'actualizar informação do utilizador SICA
        '                        ActualizaUtilizadorSICA(drAD, drSICA(0), connSICA, Empresa.REFERTelecom)
        '                    End If
        '                End If
        '            End If
        '        End If
        '    Next

        '    WriteLog("A sincronizar cartões para SICAWeb...")
        '    WriteLog(SincronizaCartoesParaSICAWeb(connSICA).ToString & " cartões carregados.")

        '    WriteLog("Actualização concluída.")
        '    SQLManager.DisposeConn(connSICA)
        '    log.Close()
        '    log = Nothing
    End Sub

    Private Sub ProcessaActualizacoes()
        Dim connSICA As New SqlConnection
        log = New Logs

        WriteLog("A ler informação no SICA.")
        connSICA = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)

        If cbREFER.Checked Then ProcessaActualizacoesPorEmpresa(Empresa.REFER, connSICA)
        If cbREFERTelecom.Checked Then ProcessaActualizacoesPorEmpresa(Empresa.REFERTelecom, connSICA)
        If cbREFERPatrimonio.Checked Then ProcessaActualizacoesPorEmpresa(Empresa.REFERPatrimonio, connSICA)
        If cbREFEREngineering.Checked Then ProcessaActualizacoesPorEmpresa(Empresa.REFEREngineering, connSICA)

        WriteLog("A sincronizar cartões de visitantes...")
        WriteLog(SincronizaCartoesParaSICAWeb(connSICA).ToString & " cartões carregados.")

        WriteLog("Actualização concluída.")
        SQLManager.DisposeConn(connSICA)
        log.Close()
        log = Nothing
    End Sub

    Private Sub ProcessaActualizacoesPorEmpresa(ByVal emp As Empresa, ByVal connSICA As SqlConnection)
        Dim dtAD, dtSICA, dtCartoesActivos As DataTable
        Dim empresaAProcessar As String = ""

        Select Case emp
            Case Empresa.REFER, Empresa.REFERCessado
                empresaAProcessar = "REFER"
            Case Empresa.REFERTelecomCessado, Empresa.REFERTelecom
                empresaAProcessar = "REFER Telecom"
            Case Empresa.REFERPatrimonioCessado, Empresa.REFERPatrimonio
                empresaAProcessar = "REFER Patrimonio"
            Case Empresa.REFEREngineeringCessado, Empresa.REFEREngineering
                empresaAProcessar = "REFER Engineering"
        End Select

        pgProgress.Minimum = 0
        pgProgress.Value = 0

        lbLog.Items.Clear()
        WriteLog("A ler utilizadores.")

        'lê info na AD
        dtAD = LeUtilizadoresREFER()

        WriteLog("A ler informação no SICA.")
        connSICA = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)

        'lê utilizadores no SICA
        dtSICA = SQLManager.SelectQuery("select idusager,nom,prenom,codelogique,idfamille,idsociete from VueUsagers where supprime=0", connSICA)
        'lê cartões activos
        dtCartoesActivos = SQLManager.SelectQuery("select idbadge,libelle,codelogique from badge where statutbadge=2 and supprime=0", connSICA)

        pgProgress.Maximum = dtAD.Rows.Count
        WriteLog("A actualizar utilizadores " & empresaAProcessar & "...")
        For Each drAD As DataRow In dtAD.Rows
            pgProgress.Increment(1)
            DoEvents()

            If Not IsDBNull(drAD("employeeID")) And Not IsDBNull(drAD("company")) Then
                If drAD("employeeID").ToString.Length = 7 And drAD("employeeID").ToString.Substring(0, 6) <> "999999" And drAD("employeeID").ToString.Substring(0, 6) <> "888888" And drAD("employeeID").ToString.Substring(0, 6) <> "777777" Then

                    If drAD("company") = empresaAProcessar Then
                        ''verifica se é cessado
                        'If drAD("distinguishedName").ToString.IndexOf(AppSettings("OUCessadosREFER")) >= 0 Then
                        'DesactivaCartoesUtilizador(drAD("employeeID").ToString, dtCartoesActivos.Select("codelogique='" & drAD("employeeID") & "'"), connSICA)
                        'Else
                        Dim drSICA() As DataRow = dtSICA.Select("codelogique='" & drAD("employeeID") & "'")

                        If drSICA.Length = 0 Then
                            'criar novo utilizador SICA
                            WriteLog(vbTab & "Novo utilizador " & empresaAProcessar & ": " & drAD("employeeID") & " - " & drAD("givenName") & " " & drAD("sn"))
                            NovoUtilizadorSICA(drAD, connSICA, emp)
                        Else
                            'actualizar informação do utilizador SICA
                            ActualizaUtilizadorSICA(drAD, drSICA(0), connSICA, emp)
                        End If
                        'End If
                    End If

                End If
            End If
        Next
        dtAD.Clear()

        WriteLog("A sincronizar cartões para SICAWeb...")
        WriteLog(SincronizaCartoesParaSICAWeb(connSICA).ToString & " cartões carregados.")

        WriteLog("Actualização concluída.")
        SQLManager.DisposeConn(connSICA)
    End Sub

    Private Function SincronizaCartoesParaSICAWeb(ByVal connSICA As SqlConnection) As Integer
        Dim connSICAWeb As New SqlConnection
        Dim dtCartoesSICA As DataTable
        Dim dtCartoesSICAWeb As DataTable
        Dim idTipoCartao As String
        Dim result As Integer = 0

        connSICAWeb = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)

        dtCartoesSICA = SQLManager.SelectQuery("SELECT DISTINCT Badge.codelogique, Usager.prenom FROM Badge INNER JOIN Usager ON Badge.idusager = Usager.idusager WHERE (Badge.supprime = 0) AND (LEFT(Badge.codelogique, 1) IN ('C', 'V', 'M', 'A', 'R'))", connSICA)
        dtCartoesSICAWeb = SQLManager.SelectQuery("select NumCartao from tblcartoes", connSICAWeb)

        For Each drCartoesSICA As DataRow In dtCartoesSICA.Rows
            Select Case drCartoesSICA("codelogique").ToString.Substring(0, 1)
                Case "V"
                    idTipoCartao = 1
                Case "M"
                    idTipoCartao = 2
                Case "C"
                    idTipoCartao = 3
                Case "R"
                    idTipoCartao = 4
                Case "A"
                    idTipoCartao = 5
                Case Else
                    idTipoCartao = 1
            End Select
            If dtCartoesSICAWeb.Select("NumCartao='" & drCartoesSICA("codelogique") & "'").Length = 0 Then
                SQLManager.UpdateQuery("insert into tblCartoes (NumCartao,Decricao,Tipo) " & _
                                       "values ('" & drCartoesSICA("codelogique") & "','" & drCartoesSICA("prenom") & "'," & idTipoCartao.ToString & ")", connSICAWeb)
                result += 1
            End If
        Next

        connSICAWeb.Close()
        connSICAWeb.Dispose()
        connSICA.Close()
        connSICA.Dispose()

        Return result
    End Function

    Private Sub WriteLog(ByVal text As String)
        lbLog.Items.Add(Now.ToString & " - " & text)
        log.SetSummaryReporteMailMessage(text)
        DoEvents()
    End Sub

    Private Function LeUtilizadoresREFER() As DataTable
        Dim ADConn As DirectoryEntry
        Dim dt As DataTable

        ADConn = ADConnection(AppSettings("LDAPRefer"), AppSettings("RootDSERefer"))
        dt = ADMakeTableWithADResult( _
                                        ADSearch( _
                                                  ADConn, "(&(objectClass=user))", _
                                                  New String() {"sAMAccountName", "employeeID", "givenName", "sn", "distinguishedName", "url", "company"}), _
                                        New String() {"sAMAccountName", "employeeID", "givenName", "sn", "distinguishedName", "url", "company"})
        ADConn.Close()
        ADConn.Dispose()

        Return dt
    End Function

    'Private Function LeUtilizadoresREFERTelecom() As DataTable
    '    Dim ADConn As DirectoryEntry
    '    Dim dt As DataTable

    '    ADConn = ADConnection(AppSettings("LDAPReferTelecom"), AppSettings("RootDSEReferTelecom"))
    '    dt = ADMakeTableWithADResult( _
    '                                    ADSearch( _
    '                                              ADConn, "(&(objectClass=user))", _
    '                                              New String() {"sAMAccountName", "employeeID", "givenName", "sn", "distinguishedName", "url"}), _
    '                                    New String() {"sAMAccountName", "employeeID", "givenName", "sn", "distinguishedName", "url"})
    '    ADConn.Close()
    '    ADConn.Dispose()

    '    Return dt
    'End Function

    'Private Function LeUtilizadoresREFERPatrimonio() As DataTable
    '    Dim ADConn As DirectoryEntry
    '    Dim dt As DataTable

    '    ADConn = ADConnection(AppSettings("LDAPReferPatrimonio"), AppSettings("RootDSEReferPatrimonio"))
    '    dt = ADMakeTableWithADResult( _
    '                                    ADSearch( _
    '                                              ADConn, "(&(objectClass=user))", _
    '                                              New String() {"sAMAccountName", "employeeID", "givenName", "sn", "distinguishedName", "url"}), _
    '                                    New String() {"sAMAccountName", "employeeID", "givenName", "sn", "distinguishedName", "url"})
    '    ADConn.Close()
    '    ADConn.Dispose()

    '    Return dt
    'End Function

    Private Sub NovoUtilizadorSICA(ByVal drUtilizadorAD As DataRow, ByVal conn As SqlConnection, ByVal Emp As Empresa)
        'escolhe afamília a atribuir
        Dim familia As String
        Select Case Emp
            Case Empresa.REFER
                familia = AppSettings("idFamiliaInicialREFER")
            Case Empresa.REFERTelecom
                familia = AppSettings("idFamiliaInicialREFERTelecom")
            Case Empresa.REFERPatrimonio
                familia = AppSettings("idFamiliaInicialREFERPatrimonio")
            Case Empresa.REFEREngineering
                familia = AppSettings("idFamiliaInicialREFEREngineering")
            Case Else
                familia = "null"
        End Select

        'SQLManager.SelectQuery("insert into usager (idfamille," & _
        '                                                    "codelogique," & _
        '                                                    "nom," & _
        '                                                    "prenom," & _
        '                                                    "type," & _
        '                                                    "etatcrise," & _
        '                                                    "datevalidite," & _
        '                                                    "codecip," & _
        '                                                    "confirmtype," & _
        '                                                    "confirmautorise," & _
        '                                                    "matricule," & _
        '                                                    "listerouge," & _
        '                                                    "idzonevehicule," & _
        '                                                    "idzonegeographique," & _
        '                                                    "iddomaine," & _
        '                                                    "datecreation," & _
        '                                                    "datemodif," & _
        '                                                    "datepassage," & _
        '                                                    "idtetedelecture," & _
        '                                                    "timestamp," & _
        '                                                    "supprime)" & _
        '                                            "values (" & familia & "," & _
        '                                                    "'" & drUtilizadorAD("employeeID") & "'," & _
        '                                                    "'" & drUtilizadorAD("sn") & "'," & _
        '                                                    "'" & drUtilizadorAD("givenName") & "'," & _
        '                                                    "0," & _
        '                                                    "0," & _
        '                                                    "'" & Now.Year & "-" & IIf(Now.Month < 10, "0", "") & Now.Month & "-" & IIf(Now.Day < 10, "0", "") & Now.Day & "'," & _
        '                                                    "100," & _
        '                                                    "1," & _
        '                                                    "0," & _
        '                                                    "''," & _
        '                                                    "0," & _
        '                                                    "null," & _
        '                                                    "null," & _
        '                                                    "null," & _
        '                                                    "'" & Now.Year & "-" & IIf(Now.Month < 10, "0", "") & Now.Month & "-" & IIf(Now.Day < 10, "0", "") & Now.Day & "'," & _
        '                                                    "'" & Now.Year & "-" & IIf(Now.Month < 10, "0", "") & Now.Month & "-" & IIf(Now.Day < 10, "0", "") & Now.Day & "'," & _
        '                                                    "null," & _
        '                                                    "null," & _
        '                                                    "'" & Now.Year & "-" & IIf(Now.Month < 10, "0", "") & Now.Month & "-" & IIf(Now.Day < 10, "0", "") & Now.Day & "'," & _
        '                                                    "0)", conn)

        'Dim dtNovoUtilizador As DataTable
        'dtNovoUtilizador = SQLManager.SelectQuery("select idusager,nom,prenom,codelogique,idfamille,idsociete from VueUsagers where supprime=0 and codelogique='" & drUtilizadorAD("employeeID") & "'", conn)

        'If dtNovoUtilizador.Rows.Count = 1 Then ActualizaEmpresa(dtNovoUtilizador.Rows(0), Emp, conn)

        Select Case Emp
            Case Empresa.REFER
                log.SetCounter(Logs.typeOfCounter.NovosREFER)
            Case Empresa.REFERTelecom
                log.SetCounter(Logs.typeOfCounter.NovosREFERTelecom)
            Case Empresa.REFERPatrimonio
                log.SetCounter(Logs.typeOfCounter.NovosREFERPatrimonio)
            Case Empresa.REFEREngineering
                log.SetCounter(Logs.typeOfCounter.NovosREFEREngineering)
        End Select
    End Sub

    Private Sub ActualizaUtilizadorSICA(ByVal drUtilizadorAD As DataRow, ByVal drUtilizadorSICA As DataRow, ByVal conn As SqlConnection, ByVal Emp As Empresa)
        If drUtilizadorAD("givenName").ToString <> drUtilizadorSICA("prenom").ToString Or drUtilizadorAD("sn").ToString <> drUtilizadorSICA("nom").ToString Then
            'SQLManager.SelectQuery("update usager set prenom='" & drUtilizadorAD("givenName").ToString & "'," & _
            '                                         "nom='" & drUtilizadorAD("sn").ToString & "', " & _
            '                                         "datemodif='" & Now.Year & "-" & IIf(Now.Month < 10, "0", "") & Now.Month & "-" & IIf(Now.Day < 10, "0", "") & Now.Day & "' " & _
            '                       "where codelogique='" & drUtilizadorAD("employeeID").ToString & "' and supprime=0", conn)

            Select Case Emp
                Case Empresa.REFER
                    log.SetCounter(Logs.typeOfCounter.ActualizadosREFER)
                Case Empresa.REFERTelecom
                    log.SetCounter(Logs.typeOfCounter.ActualizadosREFERTelecom)
                Case Empresa.REFERPatrimonio
                    log.SetCounter(Logs.typeOfCounter.ActualizadosREFERPatrimonio)
                Case Empresa.REFEREngineering
                    log.SetCounter(Logs.typeOfCounter.ActualizadosREFEREngineering)
            End Select
        End If

        'ActualizaEmpresa(drUtilizadorSICA, Emp, conn)

        'actualiza foto
        'If Not IsDBNull(drUtilizadorAD("url")) Then
        '    ActualizaFoto(drUtilizadorAD("employeeID").ToString, drUtilizadorAD("url").ToString, conn)
        'End If
    End Sub

    Private Sub ActualizaEmpresa(ByVal drUtilizadorSICA As DataRow, ByVal idEmpresa As Integer, ByVal conn As SqlConnection)
        'actualiza empresa
        If IsDBNull(drUtilizadorSICA("idsociete")) Then
            SQLManager.SelectQuery("insert into ChampExplElem (idusager,idchampexpl,idchampexplliste) " & _
                                                      "values (" & drUtilizadorSICA("idusager".ToString) & ",1," & idEmpresa & ")", conn)
        Else
            If drUtilizadorSICA("idsociete") <> idEmpresa Then
                SQLManager.SelectQuery("update ChampExplElem set idchampexplliste=" & idEmpresa & " where idusager=" & drUtilizadorSICA("idusager").ToString & " and idchampexpl=1", conn)
            End If
        End If
    End Sub

    'Private Sub DesactivaCartoesUtilizador(ByVal NumEmpregado As String, ByVal drCartoes() As DataRow, ByVal conn As SqlConnection)
    '    'desactiva cartões activos que não estejam eliminados
    '    If drCartoes.Length > 0 Then
    '        WriteLog(vbTab & "Utilizador cessado: " & NumEmpregado)
    '        For Each dr As DataRow In drCartoes
    '            SQLManager.SelectQuery("update badge set statutbadge=4 where idbadge=" & dr("idbadge"), conn)
    '            WriteLog(vbTab & "Cartão """ & dr("libelle") & """ desabilitado.")
    '            log.SetCounter(Logs.typeOfCounter.CartoesDesabilidaosREFER)
    '        Next
    '    End If
    'End Sub

    Private Enum Empresa
        REFER = 4
        REFERTelecom = 1480
        REFERCessado = 1653
        REFERTelecomCessado = 1654
        REFERPatrimonio = 1656
        REFERPatrimonioCessado = 1657
        REFEREngineering = 1658
        REFEREngineeringCessado = 1659
    End Enum

    Private Sub ActualizaFoto(ByVal NumEmpregado As String, ByVal FotoURL As String, ByVal conn As SqlConnection)
        'Dim Foto As String = FotoURL
        'Foto = Foto.Replace(AppSettings("fotoURLREFER"), AppSettings("fotoPATHREFER"))
        'Foto = Foto.Replace("/", "\")

        'If Dir(Foto).Length > 0 Then
        '    Dim ficheiro As New System.IO.FileInfo(Foto)
        '    Dim fStream As System.IO.Stream
        '    Dim param As New Hashtable

        '    fStream = ficheiro.OpenRead()
        '    Dim b(fStream.Length - 1) As Byte
        '    fStream.Read(b, 0, b.Length)
        '    fStream.Close()

        '    'Dim teste As New System.IO.FileStream("c:\teste.jpg", IO.FileMode.Create)
        '    'teste.Write(b, 0, b.Length)
        '    'teste.Close()
        '    'Exit Sub

        '    param.Add("@NumEmpregado", NumEmpregado)
        '    param.Add("@Imagem", b)
        '    SQLManager.ExecuteStoreProcedure("spREFER_ImportaFoto", conn, param)
        'End If
    End Sub

    Private Sub DataSync_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Dim strParams() As String
        Dim run As Boolean = False
        Dim close As Boolean = False

        strParams = System.Environment.GetCommandLineArgs

        If strParams.Length > 1 Then
            For i As Integer = 1 To strParams.Length - 1
                Select Case strParams(i).ToUpper
                    Case "/START"
                        run = True
                    Case "/STOP"
                        close = True
                End Select
            Next

            If run Then ProcessaActualizacoes()
            If close Then Application.Exit()
        End If
    End Sub

    Private Sub DataSync_Resize(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Resize
        lbLog.Width = Me.Width - 34
        lbLog.Height = Me.Height - 75

        pgProgress.Width = Me.Width - 114
        pgProgress.Top = Me.Height - 57

        cmdRun.Top = Me.Height - 57
        cmdAjuda.Top = Me.Height - 57
    End Sub

    Private Sub cmdAjuda_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdAjuda.Click
        lbLog.Items.Clear()
        lbLog.Items.Add("Parâmetros aceites:")
        lbLog.Items.Add(vbTab & "/start - inicia automaticamente o processo de actualização")
        lbLog.Items.Add(vbTab & "/stop - fecha a aplicação quando terminar a actualização")
    End Sub

    Private Function VerificaSeUtilizadorCessado(ByVal NumEmpregado As String, ByVal emp As Empresa)
        'employeeID
    End Function
End Class