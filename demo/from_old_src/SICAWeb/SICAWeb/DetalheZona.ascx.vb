
Partial Class DetalheZona
    Inherits System.Web.UI.UserControl

    Public Sub RefreshInfo(ByVal IDZona As Integer)
        lblIDZona.Text = IDZona
        dsDetalheZona.DataBind()
        gvDetalheZona.DataBind()
    End Sub
End Class
