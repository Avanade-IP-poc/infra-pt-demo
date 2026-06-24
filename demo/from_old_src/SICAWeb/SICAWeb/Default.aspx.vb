Imports System.Data
Imports System.Configuration.ConfigurationManager

Partial Class _Default
    Inherits System.Web.UI.Page

    Private Function VerificaAcesso(NomePC As String, IP As String) As String
        Dim SQLManager As New SQLMethods
        Dim conn As SqlClient.SqlConnection
        Dim dt As DataTable

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("SICAConnectionString").ConnectionString)
        dt = SQLManager.SelectQuery("select nome from tblTerminais where upper(nome)='" & NomePC.ToUpper & "' or ip='" & IP & "'", conn)
        SQLManager.DisposeConn(conn)

        If dt.Rows.Count > 0 Then
            'tem acesso
            Return dt.Rows(0)("nome")
        Else
            'não tem acesso
            Return ""
        End If
    End Function

    Public Shared Function GetIPAddress() As String
        Dim context As System.Web.HttpContext =
            System.Web.HttpContext.Current
        Dim sIPAddress As String =
            context.Request.ServerVariables("HTTP_X_FORWARDED_FOR")
        If String.IsNullOrEmpty(sIPAddress) Then
            Return context.Request.ServerVariables("REMOTE_ADDR")
        Else
            Dim ipArray As String() = sIPAddress.Split(
                New [Char]() {","c})
            Return ipArray(0)
        End If
    End Function

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            Session("Utilizador") = Request.ServerVariables("LOGON_USER")
            If Session("Utilizador").ToString.Length > 1 Then
                Session("Utilizador") = Session("Utilizador").Substring(Session("Utilizador").IndexOf("\") + 1, Session("Utilizador").Length - Session("Utilizador").IndexOf("\") - 1)
            Else
                Session("Utilizador") = ""
            End If
        End If
    End Sub

    Protected Sub Timer1_Tick(sender As Object, e As System.EventArgs) Handles Timer1.Tick
        Dim ip As String = GetIPAddress()
        Dim acesso As Boolean = False


        Timer1.Enabled = False
        lblAcesso.Text = VerificaAcesso(txtComputerName.Text, ip)

        If lblAcesso.Text.Length > 0 Then acesso = True

        lblTerminal.Text = txtComputerName.Text & " / " & ip & " (" & lblAcesso.Text & ")"

        If acesso Then
            txtComputerName.Text = lblAcesso.Text
            lblAcesso.Text = "True"
            Session("NomeTerminal") = txtComputerName.Text
            Response.Redirect("PagPrincipal.aspx")
        Else
            lblAcesso.Text = "False"
        End If
    End Sub
End Class
