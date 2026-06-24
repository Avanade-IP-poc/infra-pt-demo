Imports System.Data
Imports System.Configuration.ConfigurationManager

Partial Class Acessos
    Inherits System.Web.UI.UserControl

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack Then
            If AppSettings("AcessoDeConfiguracao").IndexOf(Session("Utilizador")) < 0 Then
                updatePanelGeral.Visible = False
            Else
                CarregaInfo()
            End If
        End If
    End Sub

    Private Sub CarregaInfo()
        Dim conn As SqlClient.SqlConnection
        Dim SQLManager As New SQLMethods
        Dim SMI As New SMIMethodsWebService.SMIMethodsSoapClient

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)

        LeTerminais(conn, SQLManager, SMI)
        LeCartoes(conn, SQLManager, SMI)
        LeFamilias(conn, SQLManager, SMI)
        LeCircuitos(conn, SQLManager, SMI)

        SMI = Nothing
        SQLManager.DisposeConn(conn)
    End Sub

    Private Sub LeTerminais(ByVal conn As SqlClient.SqlConnection, ByVal SQLManager As SQLMethods, SMI As SMIMethodsWebService.SMIMethodsSoapClient)
        Dim dt As DataTable

        dt = SQLManager.SelectQuery("select ID,Nome,Descricao from vwTerminais", conn)
        ddlFiltroTerminais.Items.Add(New ListItem("Seleccione um terminal", ""))

        For Each dr As DataRow In dt.Rows
            ddlFiltroTerminais.Items.Add(New ListItem(dr("Descricao") & " (" & dr("Nome") & ")", dr("ID")))
        Next
    End Sub

    Private Sub LeCartoes(ByVal conn As SqlClient.SqlConnection, ByVal SQLManager As SQLMethods, SMI As SMIMethodsWebService.SMIMethodsSoapClient)
        Dim SMICartoes() As SMIMethodsWebService.SmartCardProperties
        Dim SICACartoes As DataTable

        'lê cartões na BD SICA
        SICACartoes = SQLManager.SelectQuery("select ID from tblCartoes", conn)

        'lê cartoes do SMI
        SMICartoes = SMI.GetExternalSmartCards()

        'verifica os cartões SMI já estão registados na BD SICA
        For i = 0 To SMICartoes.Length - 1
            Dim drCartao() As DataRow = SICACartoes.Select("id='" & SMICartoes(i).idSmartCard & "'")
            If drCartao.Length = 0 Then SQLManager.SelectQuery("INSERT INTO tblCartoes (ID,NumCartao,Decricao) VALUES (" & SMICartoes(i).idSmartCard & ",'" & SMICartoes(i).LogicalCode & "','" & Left(SMICartoes(i).Label, 50) & "')", conn)
            cblCartoes.Items.Add(New ListItem(SMICartoes(i).LogicalCode & " - " & SMICartoes(i).Label, SMICartoes(i).idSmartCard))
        Next
    End Sub

    Private Sub LeFamilias(ByVal conn As SqlClient.SqlConnection, ByVal SQLManager As SQLMethods, SMI As SMIMethodsWebService.SMIMethodsSoapClient)
        Dim SMIFamilias() As SMIMethodsWebService.Family
        Dim SICAFamilias As DataTable

        'lê familias na BD SICA
        SICAFamilias = SQLManager.SelectQuery("select ID from tblFamilias", conn)

        'lê familias do SMI
        SMIFamilias = SMI.GetFamilies

        'verifica as familias SMI já estão registados na BD SICA
        For i = 0 To SMIFamilias.Length - 1
            Dim drFamilia() As DataRow = SICAFamilias.Select("id='" & SMIFamilias(i).idFamily & "'")
            If drFamilia.Length = 0 Then SQLManager.SelectQuery("INSERT INTO tblFamilias (ID,Nome) VALUES (" & SMIFamilias(i).idFamily & ",'" & Left(SMIFamilias(i).Label, 50) & "')", conn)
            cblFamilias.Items.Add(New ListItem(SMIFamilias(i).Label, SMIFamilias(i).idFamily))
        Next
    End Sub

    Private Sub LeCircuitos(ByVal conn As SqlClient.SqlConnection, ByVal SQLManager As SQLMethods, SMI As SMIMethodsWebService.SMIMethodsSoapClient)
        Dim SMICircuitos() As SMIMethodsWebService.CircuitProperties
        Dim SICACircuitos As DataTable
        Dim BDSICAAtualizada As Boolean = False
        'lê circuitos na BD SICA
        SICACircuitos = SQLManager.SelectQuery("select ID,Nome from tblCircuitos order by Nome", conn)

        'lê circuitos do SMI
        SMICircuitos = SMI.GetCircuits

        'verifica os circuitos SMI já estão registados na BD SICA
        For i = 0 To SMICircuitos.Length - 1
            Dim drFamilia() As DataRow = SICACircuitos.Select("id='" & SMICircuitos(i).idCircuit & "'")
            If drFamilia.Length = 0 Then
                BDSICAAtualizada = True
                SQLManager.SelectQuery("INSERT INTO tblCircuitos (ID,Nome,IDCircuitoGrupo) VALUES (" & SMICircuitos(i).idCircuit & ",'" & Left(SMICircuitos(i).Label, 50) & "'," & SMICircuitos(i).idCircuit & ")", conn)
            End If
        Next

        If BDSICAAtualizada Then SICACircuitos = SQLManager.SelectQuery("select ID,Nome from tblCircuitos", conn)
        For Each dr As DataRow In SICACircuitos.Rows
            cblCircuitos.Items.Add(New ListItem(dr("Nome"), dr("ID")))
        Next
    End Sub

    Protected Sub ddlFiltroTerminais_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlFiltroTerminais.SelectedIndexChanged
        CarregaAcessos()
    End Sub

    Private Sub CarregaAcessos()
        Dim conn As SqlClient.SqlConnection
        Dim SQLManager As New SQLMethods
        Dim dtCartoes, dtFamilias, dtCircuitos As DataTable
        
        cblCartoes.Enabled = True
        cblFamilias.Enabled = True
        cblCircuitos.Enabled = True

        cblCartoes.ClearSelection()
        cblFamilias.ClearSelection()
        cblCircuitos.ClearSelection()

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)

        dtCartoes = SQLManager.SelectQuery("Select tblCartoes.ID FROM tblCartoesTerminal INNER JOIN tblCartoes ON tblCartoesTerminal.IDCartao = tblCartoes.ID WHERE tblCartoesTerminal.IDTerminal=" & ddlFiltroTerminais.SelectedValue, conn)
        dtFamilias = SQLManager.SelectQuery("Select tblFamilias.ID FROM tblFamiliasTerminal INNER JOIN tblFamilias ON tblFamiliasTerminal.IDFamilia = tblFamilias.ID WHERE tblFamiliasTerminal.IDTerminal=" & ddlFiltroTerminais.SelectedValue, conn)
        dtCircuitos = SQLManager.SelectQuery("Select tblCircuitos.ID FROM tblCircuitosTerminal INNER JOIN tblCircuitos ON tblCircuitosTerminal.IDCircuito = tblCircuitos.ID WHERE tblCircuitosTerminal.IDTerminal=" & ddlFiltroTerminais.SelectedValue, conn)

        For Each dr As DataRow In dtCartoes.Rows
            seleccionaCartao(dr("ID"))
        Next
        For Each dr As DataRow In dtFamilias.Rows
            seleccionaFamilia(dr("ID"))
        Next
        For Each dr As DataRow In dtCircuitos.Rows
            seleccionaCircuito(dr("ID"))
        Next

        SQLManager.DisposeConn(conn)

        cmdAplicar.Enabled = True
        cmdCancelar.Enabled = True
    End Sub

    Private Sub seleccionaCartao(ByVal ID As String)
        For Each item As ListItem In cblCartoes.Items
            If item.Value = ID Then item.Selected = True
        Next
    End Sub

    Private Sub seleccionaFamilia(ByVal ID As String)
        For Each item As ListItem In cblFamilias.Items
            If item.Value = ID Then item.Selected = True
        Next
    End Sub

    Private Sub seleccionaCircuito(ByVal ID As String)
        For Each item As ListItem In cblCircuitos.Items
            If item.Value = ID Then item.Selected = True
        Next
    End Sub

    Protected Sub cmdAplicar_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdAplicar.Click
        Dim conn As SqlClient.SqlConnection
        Dim SQLManager As New SQLMethods

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)

        If ddlFiltroTerminais.SelectedValue <> 0 Then
            SQLManager.SelectQuery("delete from tblCartoesTerminal where idterminal=" & ddlFiltroTerminais.SelectedValue, conn)
            For Each itemCartao As ListItem In cblCartoes.Items
                If itemCartao.Selected Then
                    SQLManager.SelectQuery("insert into tblCartoesTerminal (idcartao,idterminal) values (" & itemCartao.Value & "," & ddlFiltroTerminais.SelectedValue & ")", conn)
                End If
            Next
            SQLManager.SelectQuery("delete from tblFamiliasTerminal where idterminal=" & ddlFiltroTerminais.SelectedValue, conn)
            For Each itemFamilia As ListItem In cblFamilias.Items
                If itemFamilia.Selected Then
                    SQLManager.SelectQuery("insert into tblFamiliasTerminal (idfamilia,idterminal) values (" & itemFamilia.Value & "," & ddlFiltroTerminais.SelectedValue & ")", conn)
                End If
            Next
            SQLManager.SelectQuery("delete from tblCircuitosTerminal where idterminal=" & ddlFiltroTerminais.SelectedValue, conn)
            For Each itemCircuito As ListItem In cblCircuitos.Items
                If itemCircuito.Selected Then
                    SQLManager.SelectQuery("insert into tblCircuitosTerminal (idcircuito,idterminal) values (" & itemCircuito.Value & "," & ddlFiltroTerminais.SelectedValue & ")", conn)
                End If
            Next
            lblEstado.Text = "Perfil gravado para o terminal " & ddlFiltroTerminais.SelectedItem.Text
        End If

        SQLManager.DisposeConn(conn)
    End Sub

    Protected Sub cmdCancelar_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdCancelar.Click
        CarregaAcessos()
        lblEstado.Text = ""
    End Sub
End Class
