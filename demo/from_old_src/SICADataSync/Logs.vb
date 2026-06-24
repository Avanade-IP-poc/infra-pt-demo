Imports System.Configuration.ConfigurationManager

Public Class Logs

    Private NovosREFER As Integer = 0
    Private ActualizadosREFER As Integer = 0
    Private CartoesDesabilidaosREFER As Integer = 0

    Private NovosREFERTelecom As Integer = 0
    Private ActualizadosREFERTelecom As Integer = 0
    Private CartoesDesabilidaosREFERTelecom As Integer = 0

    Private NovosREFERPatrimonio As Integer = 0
    Private ActualizadosREFERPatrimonio As Integer = 0
    Private CartoesDesabilidaosREFERPatrimonio As Integer = 0

    Private NovosREFEREngineering As Integer = 0
    Private ActualizadosREFEREngineering As Integer = 0
    Private CartoesDesabilidaosREFEREngineering As Integer = 0


    Private ReportSummaryEmailMessage As New ArrayList

    Protected Friend Sub New()
        WriteEventInLogTXT("*********** Inicio **********")
    End Sub

    Protected Friend Sub SetSummaryReporteMailMessage(ByVal Message As String)
        Message = Message.Replace(vbTab, "&nbsp;&nbsp;&middot;&nbsp;")
        ReportSummaryEmailMessage.Add(Message)
    End Sub

    Protected Friend Sub WriteEventInLogTXT(ByVal text As String)
        WriteLog(text)
    End Sub

    Protected Friend Sub Close()
        ' write counters in TXT
        WriteLog("")
        WriteLog("Resumo REFER:")
        WriteLog("   Novos    - " & NovosREFER.ToString)
        WriteLog("   Actualizados - " & ActualizadosREFER.ToString)
        WriteLog("   Cartões desabilidaos - " & CartoesDesabilidaosREFER.ToString)
        WriteLog("")
        WriteLog("Resumo REFER Telecom:")
        WriteLog("   Novos    - " & NovosREFERTelecom.ToString)
        WriteLog("   Actualizados - " & ActualizadosREFERTelecom.ToString)
        WriteLog("   Cartões desabilidaos - " & CartoesDesabilidaosREFERTelecom.ToString)
        WriteLog("")
        WriteLog("Resumo REFER Patrimonio:")
        WriteLog("   Novos    - " & NovosREFERPatrimonio.ToString)
        WriteLog("   Actualizados - " & ActualizadosREFERPatrimonio.ToString)
        WriteLog("   Cartões desabilidaos - " & CartoesDesabilidaosREFERPatrimonio.ToString)
        WriteLog("")
        WriteLog("Resumo REFER Engineering:")
        WriteLog("   Novos    - " & NovosREFEREngineering.ToString)
        WriteLog("   Actualizados - " & ActualizadosREFEREngineering.ToString)
        WriteLog("   Cartões desabilidaos - " & CartoesDesabilidaosREFEREngineering.ToString)
        WriteLog("")
        WriteLog("************ Fim ************")

        ' write counters in email message
        SetSummaryReporteMailMessage("")
        SetSummaryReporteMailMessage("Resumo REFER:")
        SetSummaryReporteMailMessage("   Novos    - " & NovosREFER.ToString)
        SetSummaryReporteMailMessage("   Actualizados - " & ActualizadosREFER.ToString)
        SetSummaryReporteMailMessage("   Cartões desabilidaos - " & CartoesDesabilidaosREFER.ToString)
        SetSummaryReporteMailMessage("")
        SetSummaryReporteMailMessage("Resumo REFER Telecom:")
        SetSummaryReporteMailMessage("   Novos    - " & NovosREFERTelecom.ToString)
        SetSummaryReporteMailMessage("   Actualizados - " & ActualizadosREFERTelecom.ToString)
        SetSummaryReporteMailMessage("   Cartões desabilidaos - " & CartoesDesabilidaosREFERTelecom.ToString)
        SetSummaryReporteMailMessage("")
        SetSummaryReporteMailMessage("Resumo REFER Patrimonio:")
        SetSummaryReporteMailMessage("   Novos    - " & NovosREFERPatrimonio.ToString)
        SetSummaryReporteMailMessage("   Actualizados - " & ActualizadosREFERPatrimonio.ToString)
        SetSummaryReporteMailMessage("   Cartões desabilidaos - " & CartoesDesabilidaosREFERPatrimonio.ToString)
        SetSummaryReporteMailMessage("")
        SetSummaryReporteMailMessage("Resumo REFER Engineering:")
        SetSummaryReporteMailMessage("   Novos    - " & NovosREFEREngineering.ToString)
        SetSummaryReporteMailMessage("   Actualizados - " & ActualizadosREFEREngineering.ToString)
        SetSummaryReporteMailMessage("   Cartões desabilidaos - " & CartoesDesabilidaosREFEREngineering.ToString)
        SetSummaryReporteMailMessage("")
        SetSummaryReporteMailMessage("************ Fim ************")


        ' send email with ReportLog
        If ReportSummaryEmailMessage.Count > 0 Then
            Dim SendReportEmail As New Email

            SendReportEmail.SendReportEmail(AppSettings("fromemail"), AppSettings("reportemail"), "Relatório de actualizações SICA", ReportSummaryEmailMessage)

            SendReportEmail = Nothing
        End If
    End Sub

    Private Sub WriteLog(ByVal text As String)
        My.Computer.FileSystem.WriteAllText("Log.txt", Now & ": " & text & vbCrLf, True)
    End Sub

    Protected Friend Enum typeOfCounter
        NovosREFER = 0
        ActualizadosREFER = 1
        CartoesDesabilidaosREFER = 2

        NovosREFERTelecom = 3
        ActualizadosREFERTelecom = 4
        CartoesDesabilidaosREFERTelecom = 5

        NovosREFERPatrimonio = 6
        ActualizadosREFERPatrimonio = 7
        CartoesDesabilidaosREFERPatrimonio = 8

        NovosREFEREngineering = 9
        ActualizadosREFEREngineering = 10
        CartoesDesabilidaosREFEREngineering = 11
    End Enum

    Protected Friend Sub SetCounter(ByVal type As typeOfCounter)
        Select Case type
            Case typeOfCounter.NovosREFER
                NovosREFER += 1
            Case typeOfCounter.ActualizadosREFER
                ActualizadosREFER += 1
            Case typeOfCounter.CartoesDesabilidaosREFER
                CartoesDesabilidaosREFER += 1

            Case typeOfCounter.NovosREFERTelecom
                NovosREFERTelecom += 1
            Case typeOfCounter.ActualizadosREFERTelecom
                ActualizadosREFERTelecom += 1
            Case typeOfCounter.CartoesDesabilidaosREFERTelecom
                CartoesDesabilidaosREFERTelecom += 1

            Case typeOfCounter.NovosREFERPatrimonio
                NovosREFERPatrimonio += 1
            Case typeOfCounter.ActualizadosREFERPatrimonio
                ActualizadosREFERPatrimonio += 1
            Case typeOfCounter.CartoesDesabilidaosREFERPatrimonio
                CartoesDesabilidaosREFERPatrimonio += 1

            Case typeOfCounter.NovosREFEREngineering
                NovosREFEREngineering += 1
            Case typeOfCounter.ActualizadosREFEREngineering
                ActualizadosREFEREngineering += 1
            Case typeOfCounter.CartoesDesabilidaosREFEREngineering
                CartoesDesabilidaosREFEREngineering += 1
        End Select
    End Sub

    Private ReadOnly Property GetCounterForNovosREFER() As Integer
        Get
            Return NovosREFER
        End Get
    End Property

    Private ReadOnly Property GetCounterForActualizadosREFER() As Integer
        Get
            Return ActualizadosREFER
        End Get
    End Property

    Private ReadOnly Property GetCounterForCartoesDesabilidaosREFER() As Integer
        Get
            Return CartoesDesabilidaosREFER
        End Get
    End Property

    Private ReadOnly Property GetCounterForNovosREFERTelecom() As Integer
        Get
            Return NovosREFERTelecom
        End Get
    End Property

    Private ReadOnly Property GetCounterForActualizadosREFERTelecom() As Integer
        Get
            Return ActualizadosREFERTelecom
        End Get
    End Property

    Private ReadOnly Property GetCounterForCartoesDesabilidaosREFERTelecom() As Integer
        Get
            Return CartoesDesabilidaosREFERTelecom
        End Get
    End Property

    Private ReadOnly Property GetCounterForNovosREFERPatrimonio() As Integer
        Get
            Return NovosREFERPatrimonio
        End Get
    End Property

    Private ReadOnly Property GetCounterForActualizadosREFERPatrimonio() As Integer
        Get
            Return ActualizadosREFERPatrimonio
        End Get
    End Property

    Private ReadOnly Property GetCounterForCartoesDesabilidaosREFERPatrimonio() As Integer
        Get
            Return CartoesDesabilidaosREFERPatrimonio
        End Get
    End Property

    Private ReadOnly Property GetCounterForNovosREFEREngineering() As Integer
        Get
            Return NovosREFEREngineering
        End Get
    End Property

    Private ReadOnly Property GetCounterForActualizadosREFEREngineering() As Integer
        Get
            Return ActualizadosREFEREngineering
        End Get
    End Property

    Private ReadOnly Property GetCounterForCartoesDesabilidaosREFEREngineering() As Integer
        Get
            Return CartoesDesabilidaosREFEREngineering
        End Get
    End Property
End Class
