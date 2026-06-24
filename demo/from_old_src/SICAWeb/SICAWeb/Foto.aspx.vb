Imports System.Data
Imports System.Data.SqlClient
Imports System.IO
Imports System.Configuration.ConfigurationManager

Partial Class Foto
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim numEmp As String = Request.QueryString("NumEmpregado")
        If Not IsNothing(numEmp) Then
            Dim url As String = GetFotoFromURL(numEmp)
            If Not IsNothing(url) Then imgFoto.ImageUrl = url
        End If
    End Sub

    Private Function GetFotoFromURL(NumEmpregado As String) As String
        Dim SQLManager As New SQLMethods
        Dim conn As SqlClient.SqlConnection
        Dim dtFoto As DataTable
        Dim url As String = Nothing

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("ActiveDirectoryConnectionString").ConnectionString)
        dtFoto = SQLManager.SelectQuery("SELECT wWWHomePage FROM tblAD_AD_SQL WHERE employeeID='" & NumEmpregado & "'", conn)
        SQLManager.DisposeConn(conn)

        If dtFoto.Rows.Count = 1 Then
            If Not IsNothing(dtFoto(0)(0)) Then
                url = dtFoto(0)(0)
            End If
        End If
        dtFoto.Dispose()
        If url.Length = 0 Then url = "Images/blank.jpg"
        Return url
    End Function

    'Private Sub GetFotoFromBD(NumEmpregado As String)
    '    Dim con As New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("AlizesConnectionString").ConnectionString)
    '    Dim da As New SqlDataAdapter("select foto from vwREFERUtilizadores where NumEmpregado='" & NumEmpregado & "'", con)
    '    Dim MyCB As SqlCommandBuilder = New SqlCommandBuilder(da)
    '    Dim ds As New DataSet()

    '    con.Open()
    '    da.Fill(ds, "Foto")
    '    Dim myRow As DataRow
    '    myRow = ds.Tables("Foto").Rows(0)

    '    If Not IsDBNull(myRow("Foto")) Then
    '        Dim MyData() As Byte
    '        MyData = myRow("Foto")
    '        Response.Buffer = True
    '        Response.ContentType = "Image/JPEG"
    '        Response.BinaryWrite(MyData)
    '    End If

    '    MyCB = Nothing
    '    ds = Nothing
    '    da = Nothing

    '    con.Close()
    '    con = Nothing
    '    Session("Foto") = Nothing
    'End Sub
End Class
