Imports System.Net

Public Class DNSClass
    Public Function DnsGetHostByAddress(ByVal IPAddress As String) As String
        Try
            Return Dns.GetHostEntry(IPAddress).HostName
        Catch
            Return ""
        End Try
    End Function

    Public Function DnsGetHostByName(ByVal HostName As String) As String
        Try
            Return Dns.GetHostEntry(HostName).AddressList(0).ToString
        Catch
            Return ""
        End Try
    End Function
End Class
