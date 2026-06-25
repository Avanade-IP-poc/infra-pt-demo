
Partial Class DetalheLog
    Inherits System.Web.UI.UserControl

    Protected Sub cmdPesquisar_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdPesquisar.Click
        dsLog.DataBind()
        gvLog.DataBind()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub
End Class
