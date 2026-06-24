Imports System.Text
'Imports System.Web.Mail
Imports System.Net.Mail
Imports System.Configuration.ConfigurationManager

Public Class Email

    Protected Friend Function SendReportEmail(ByVal fromEmail As String, ByVal toEmail As String, ByVal subject As String, ByVal body As ArrayList) As Boolean
        Dim mail As New MailMessage()
        Dim Ex As New Exception
        Dim smtpclient As New SmtpClient

        Try
            mail.From = New MailAddress(fromEmail)
            With mail
                .To.Add(New MailAddress(toEmail))
                .Subject = subject
                .IsBodyHtml = True
                .Body = BuildMessage(body, subject)
            End With
            smtpclient.Host = AppSettings("mailserver")
            smtpclient.Send(mail)
            Return True

        Catch ex
            Return False
        End Try
    End Function

    Private Function BuildMessage(ByVal message As ArrayList, ByVal subject As String) As String
        Dim strBuilder As New StringBuilder

        'head
        strBuilder.Append("<head>")
        strBuilder.Append("<style type=""text/css"">")
        strBuilder.Append(".tabelaazul {border : 1px solid #00458A;}")
        strBuilder.Append(".corpotexto{color : #000000;font-family : Verdana, Arial, Helvetica, sans-serif;font-size : 10px;padding : 3px;}")
        strBuilder.Append(".linhapar{	background-color : #E0F0FF;	color : #00458A;font-family : Verdana, Arial, Helvetica, sans-serif;font-size : 10px;padding : 3px;}")
        strBuilder.Append(".linhaimpar{background-color : #FFFFFF;color : #00458A;font-family : Verdana, Arial, Helvetica, sans-serif;font-size : 10px;padding : 3px;}")
        strBuilder.Append(".linknivel01vertical{background-color : #639CCE;color : #FFFFFF;font-family : Verdana, Arial, Helvetica, sans-serif;font-size : 10px;font-weight : bold;padding : 3px 3px 3px;}")
        strBuilder.Append("</style>")
        strBuilder.Append("</head>")
        'form
        strBuilder.Append("<form>")
        strBuilder.Append("<table border=""0"" width=""100%"" class=""tabelaazul"">")
        strBuilder.Append("	<tr>")
        strBuilder.Append("		<td width=""100%"" align=""center"" class=""linknivel01vertical"">")
        strBuilder.Append("			" & subject)
        strBuilder.Append("		</td>")
        strBuilder.Append("	</tr>")
        strBuilder.Append("	<tr>")
        strBuilder.Append("		<td width=""100%"">&nbsp;</td>")
        strBuilder.Append("	</tr>")

        'texto a repetir
        For linhas As Integer = 0 To message.Count - 1
            strBuilder.Append("		<tr>")
            strBuilder.Append("		    <td width=""100%"" class=""corpotexto"">")
            strBuilder.Append("			        " & message(linhas) & "<br>")
            strBuilder.Append("		    </td>")
            strBuilder.Append("		</tr>")
        Next

        strBuilder.Append("</table>")
        strBuilder.Append("</form>")

        Return strBuilder.ToString
    End Function

End Class
