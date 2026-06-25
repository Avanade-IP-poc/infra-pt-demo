Imports System.Data
Imports System.Configuration.ConfigurationManager

Partial Class DetalheUtilizador
    Inherits System.Web.UI.UserControl

    Public Sub RefreshInfo(ByVal UltimaPassagem As SMIMethodsWebService.EventProperties)
        If IsNothing(UltimaPassagem) Then
            ShowHideFields(False)
            lblNumEmpregado.Text = ""
            imgFoto.ImageUrl = "Images/blank.jpg"
            lblNome.Text = ""
            lblEmpresa.Text = ""
            lblDataUltimaPassagem.Text = ""
            lblZonaUltimaPassagem.Text = ""
        Else
            ShowHideFields(True)
            lblNumEmpregado.Text = UltimaPassagem.LogicalCode
            imgFoto.ImageUrl = GetFotoFromURL(UltimaPassagem.LogicalCode)
            lblNome.Text = UltimaPassagem.Name
            lblEmpresa.Text = UltimaPassagem.Company
            lblDataUltimaPassagem.Text = UltimaPassagem.DateTime
            lblZonaUltimaPassagem.Text = UltimaPassagem.GeoZone
        End If
    End Sub

    Private Sub ShowHideFields(opt As Boolean)
        lblNumEmpregado.Visible = opt
        imgFoto.Visible = opt
        lblNome.Visible = opt
        lblEmpresa.Visible = opt
        lblDataUltimaPassagem.Visible = opt
        lblZonaUltimaPassagem.Visible = opt
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
        If url Is Nothing Then
            url = "Images/blank.jpg"
        Else
            If url.Length = 0 Then url = "Images/blank.jpg"
        End If

        Return url
    End Function
End Class
