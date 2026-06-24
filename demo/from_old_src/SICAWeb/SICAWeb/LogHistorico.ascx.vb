Imports System.Data
Imports System.Configuration.ConfigurationManager

Partial Class LogHistorico
    Inherits System.Web.UI.UserControl
    Dim SQLManager As New SQLMethods

    Private Sub PossoasNaZonaNoPeriodo(ByVal idCircuitos As String, ByVal inicioPeriodo As DateTime, ByVal FimPeriodo As DateTime)
        Dim conn As SqlClient.SqlConnection
        Dim dtTodosOsMovimentos As DataTable
        Dim dtResult As New DataTable
        Dim cartaoActual As String = ""
        Dim dentroDoPeriodo As Boolean = False
        Dim dataPosicao As DateTime
        Dim posicao As DentroFora

        dtResult.Columns.Add("Cartao")
        dtResult.Columns.Add("Nome")
        dtResult.Columns.Add("Circuito")
        dtResult.Columns.Add("Entrada")
        dtResult.Columns.Add("Saida")

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
        dtTodosOsMovimentos = SQLManager.SelectQuery("select * from vwREFERLog where " & _
                                                                                "idevenement in (130,133) and " & _
                                                                                "idcircuit in (" & idCircuitos & ") and " & _
                                                                                "dat > '" & inicioPeriodo.AddDays(-7).Year & "-" & inicioPeriodo.AddDays(-7).Month & "-" & inicioPeriodo.AddDays(-7).Day & " " & inicioPeriodo.AddDays(-7).Hour & ":" & inicioPeriodo.AddDays(-7).Minute & ":" & inicioPeriodo.AddDays(-7).Second & "' and " & _
                                                                                "dat < '" & FimPeriodo.AddDays(7).Year & "-" & FimPeriodo.AddDays(7).Month & "-" & FimPeriodo.AddDays(7).Day & " " & FimPeriodo.AddDays(7).Hour & ":" & FimPeriodo.AddDays(7).Minute & ":" & FimPeriodo.AddDays(7).Second & "' " & _
                                                                              "order by codelogique,dat asc", conn)

        'percorre todos os movimentos no periodo a alalisar
        For Each drTodosOsMovimentos As DataRow In dtTodosOsMovimentos.Rows
            If cartaoActual = "" Then cartaoActual = IIf(IsDBNull(drTodosOsMovimentos("codelogique")), "", drTodosOsMovimentos("codelogique"))

            dataPosicao = drTodosOsMovimentos("dat")

            'verifica se o movimeto é entrada ou saída
            If drTodosOsMovimentos("descriptioncircuit").ToString.ToUpper.IndexOf("ENTRADA") > 0 Then
                posicao = DentroFora.Dentro
            ElseIf drTodosOsMovimentos("descriptioncircuit").ToString.ToUpper.IndexOf("SAIDA") > 0 Then
                posicao = DentroFora.Fora
            ElseIf drTodosOsMovimentos("parametre") = 1 Then
                posicao = DentroFora.Dentro
            ElseIf drTodosOsMovimentos("parametre") = 2 Then
                posicao = DentroFora.Fora
            Else
                posicao = DentroFora.Desconhecido
                dataPosicao = Nothing
            End If

            'para cada movimento verifica se estamos dentro do periodo pretendido
            If drTodosOsMovimentos("dat") >= inicioPeriodo And drTodosOsMovimentos("dat") <= FimPeriodo Then
                dentroDoPeriodo = True

                Dim dr As DataRow
                dr = dtResult.NewRow
                dr("Cartao") = drTodosOsMovimentos("codelogique")
                dr("Nome") = drTodosOsMovimentos("Prenom") & " " & drTodosOsMovimentos("nom")
                dr("Circuito") = drTodosOsMovimentos("libellecircuit") & " - " & drTodosOsMovimentos("descriptioncircuit")
                Select Case posicao
                    Case DentroFora.Dentro
                        dr("Entrada") = dataPosicao
                    Case DentroFora.Fora
                        dr("Saida") = dataPosicao
                    Case DentroFora.Desconhecido

                End Select
                dtResult.Rows.Add(dr)
                dr = Nothing
            End If
            'verifica se mudou de cartao
            If cartaoActual <> IIf(IsDBNull(drTodosOsMovimentos("codelogique")), "", drTodosOsMovimentos("codelogique")) Then
                'inicia a verificação do proximo cartão
                cartaoActual = drTodosOsMovimentos("codelogique")
                dentroDoPeriodo = False
            End If
        Next

        MostraResultado(dtResult)
        SQLManager.DisposeConn(conn)
    End Sub

    Private Sub MostraResultado(ByVal dt As DataTable)
        gvResultado.DataSource = dt
        gvResultado.DataBind()
    End Sub

    Private Enum DentroFora
        Dentro
        Fora
        Desconhecido
    End Enum

    Protected Sub cmdConsulta_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdConsulta.Click
        Dim idcircuitos As String = ""

        For Each item As ListItem In lbCircuitosParaAnalise.Items
            If item.Selected Then
                If idcircuitos.Length > 0 Then idcircuitos += ","
                idcircuitos += item.Value
            End If
        Next
        'PossoasNaZonaNoPeriodo("338,342,347,344,343,346,340,345,341", "2008-04-18 18:20:00", "2008-04-18 19:11:00")
        PossoasNaZonaNoPeriodo(idcircuitos, txtPeriodoParaAnaliseInicio.Text, txtPeriodoParaAnaliseFim.Text)
    End Sub

    Protected Sub rblTipoConsulta_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles rblTipoConsulta.SelectedIndexChanged
        Select Case rblTipoConsulta.SelectedValue
            Case 0
                panel0.Visible = True
                panel1.Visible = False
            Case 1
                panel0.Visible = False
                panel1.Visible = True
        End Select
    End Sub

    Private Sub CarregaCircuitos()
        Dim conn As SqlClient.SqlConnection
        Dim dt As DataTable
        Dim item As ListItem

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
        dt = SQLManager.SelectQuery("select * from vwREFERCircuitos order by Descricao", conn)
        lbCircuitosParaAnalise.Items.Clear()
        For Each dr As DataRow In dt.Rows
            item = New ListItem
            item.Value = dr("idcircuit")
            item.Text = dr("Descricao")
            lbCircuitosParaAnalise.Items.Add(item)
            item = Nothing
        Next
        SQLManager.DisposeConn(conn)
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If AppSettings("AcessoAHistorico").IndexOf(Session("Utilizador")) >= 0 And Session("Utilizador").ToString.Length > 0 Then
            'acesso OK
            If Not IsPostBack Then
                CarregaCircuitos()
                txtPeriodoParaAnaliseInicio.Text = FormataDataHora(Now.AddDays(-1))
                txtPeriodoParaAnaliseFim.Text = FormataDataHora(Now)
            End If
        Else
            'sem acesso
            panelConsulta.Visible = False
            panelResultado.Visible = False
        End If
    End Sub

    Private Function FormataDataHora(ByVal datahora As Date) As String
        Dim result As String

        result = datahora.Year.ToString
        result += "-"
        If datahora.Month < 10 Then result += "0"
        result += datahora.Month.ToString
        result += "-"
        If datahora.Day < 10 Then result += "0"
        result += datahora.Day.ToString

        result += " "

        If datahora.Hour < 10 Then result += "0"
        result += datahora.Hour.ToString
        result += ":"
        If datahora.Minute < 10 Then result += "0"
        result += datahora.Minute.ToString
        result += ":"
        If datahora.Second < 10 Then result += "0"
        result += datahora.Second.ToString

        Return result
    End Function
End Class
