Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.ComponentModel

Imports System.Data
Imports System.Configuration.ConfigurationManager

<System.Web.Services.WebService(Namespace:="http://tempuri.org/")> _
<System.Web.Services.WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<ToolboxItem(False)> _
Public Class SMIMethods
    Inherits System.Web.Services.WebService
    Dim SQLManager As New SQLMethods

#Region " Funções públicas"

    <WebMethod()> _
    Public Function GetUsers() As UserProperties()
        Dim conn As SqlClient.SqlConnection
        Dim dt As DataTable
        Dim nRecords As Integer
        Dim strSQL As String = ""

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
        Select Case getDBVersion(conn)
            Case 11
                strSQL = "select idusager as idUser, prenom + ' ' + nom as Name, codelogique as LogicalCode,idzonegeographique as idGeoZone,idtetedelecture as idReader from Vue_UsagerListe where supprime=0"
            Case 55
                strSQL = "select idUser,FirstName + ' ' + Name as Name,LogicalCode,idGeoZone,idReader from View_UserList where Deleted=0"
        End Select
        If strSQL.Length = 0 Then
            SQLManager.DisposeConn(conn)
            Return Nothing
        Else
            dt = SQLManager.SelectQuery(strSQL, conn)
            SQLManager.DisposeConn(conn)
        End If

        nRecords = dt.Rows.Count
        If nRecords = 0 Then
            SQLManager.DisposeConn(conn)
            Return Nothing
        Else
            Dim result(nRecords - 1) As UserProperties
            Dim i As Integer = 0
            For Each dr As DataRow In dt.Rows
                result(i).idUser = dr("idUser")
                result(i).Name = dr("Name")
                result(i).LogicalCode = dr("LogicalCode")
                result(i).idGeoZone = IIf(IsDBNull(dr("idGeoZone")), 0, dr("idGeoZone"))
                result(i).idReader = IIf(IsDBNull(dr("idReader")), 0, dr("idReader"))
                i += 1
            Next
            Return result
        End If
    End Function

    <WebMethod()> _
    Public Function GetUsersByLogicalCode(LogicalCode As String) As UserProperties
        Dim conn As SqlClient.SqlConnection
        Dim dt As DataTable
        Dim nRecords As Integer
        Dim strsql As String = ""

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
        Select Case getDBVersion(conn)
            Case 11
                strsql = "select idusager as idUser, prenom + ' ' + nom as Name, codelogique as LogicalCode,idzonegeographique as idGeoZone,idtetedelecture as idReader from Vue_UsagerListe where supprime=0 and codelogique='" & LogicalCode & "'"
            Case 55
                strsql = "select idUser,FirstName + ' ' + Name as Name,LogicalCode,idGeoZone,idReader from View_UserList where Deleted=0 and LogicalCode='" & LogicalCode & "'"
        End Select
        If strsql.Length = 0 Then
            SQLManager.DisposeConn(conn)
            Return Nothing
        Else
            dt = SQLManager.SelectQuery(strsql, conn)
            SQLManager.DisposeConn(conn)
        End If

        nRecords = dt.Rows.Count
        If nRecords = 1 Then
            Dim result As UserProperties
            result.idUser = dt.Rows(0)("idUser")
            result.Name = dt.Rows(0)("Name")
            result.LogicalCode = dt.Rows(0)("LogicalCode")
            result.idGeoZone = IIf(IsDBNull(dt.Rows(0)("idGeoZone")), 0, dt.Rows(0)("idGeoZone"))
            result.idReader = IIf(IsDBNull(dt.Rows(0)("idReader")), 0, dt.Rows(0)("idReader"))
            Return result
        Else
            Return Nothing
        End If
    End Function

    <WebMethod()> _
    Public Function GetFamilies() As Family()
        Try
            Dim conn As SqlClient.SqlConnection
            Dim dt As DataTable
            Dim nRecords As Integer
            Dim strSQL As String = ""

            conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
            Select Case getDBVersion(conn)
                Case 11
                    strSQL = "select idfamille as idFamily, libelle as Label from Vue_FamilleListe order by libelle"
                Case 55
                    strSQL = "select idFamily,Label from View_FamilyList order by Label"
            End Select
            If strSQL.Length = 0 Then
                SQLManager.DisposeConn(conn)
                Return Nothing
            Else
                dt = SQLManager.SelectQuery(strSQL, conn)
                SQLManager.DisposeConn(conn)
            End If

            nRecords = dt.Rows.Count
            If nRecords = 0 Then
                SQLManager.DisposeConn(conn)
                Return Nothing
            Else
                Dim result(nRecords - 1) As Family
                Dim i As Integer = 0
                For Each dr As DataRow In dt.Rows
                    result(i).idFamily = dr("idFamily")
                    result(i).Label = dr("Label")
                    i += 1
                Next
                Return result
            End If
        Catch
            Return Nothing
        End Try
    End Function

    <WebMethod()> _
    Public Function GetUserFamiles(idUser As Integer) As UserFamilies()
        Try
            Dim conn As SqlClient.SqlConnection
            Dim dt As DataTable
            Dim nRecords As Integer
            Dim strSQL As String = ""

            conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
            Select Case getDBVersion(conn)
                Case 11
                    strSQL = "select idusager as idUser, idfamille as idFamily, famille as Label,0 as [Index] from VueUsagers where idusager=" & idUser
                Case 55
                    strSQL = "Select idUser,idFamily,Label,[Index] from View_UserFamilyList where idUser=" & idUser
            End Select
            If strSQL.Length = 0 Then
                SQLManager.DisposeConn(conn)
                Return Nothing
            Else
                dt = SQLManager.SelectQuery(strSQL, conn)
                SQLManager.DisposeConn(conn)
            End If

            nRecords = dt.Rows.Count
            If nRecords = 0 Then
                SQLManager.DisposeConn(conn)
                Return Nothing
            Else
                Dim result(nRecords - 1) As UserFamilies
                Dim i As Integer = 0
                For Each dr As DataRow In dt.Rows
                    result(i).idUser = dr("idUser")
                    result(i).idFamily = dr("idFamily")
                    result(i).Label = dr("Label")
                    result(i).index = dr("Index")
                    i += 1
                Next
                Return result
            End If
        Catch
            Return Nothing
        End Try
    End Function

    <WebMethod()> _
    Public Function AddUserFamily(idUser As Integer, idFamily As Integer) As Boolean
        Try
            Dim conn As SqlClient.SqlConnection
            Dim params As New Hashtable
            Dim dt As DataTable
            Dim NextIndex As Integer

            conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
            Select Case getDBVersion(conn)
                Case 11
                    params.Add("@IDUtilizador", idUser)
                    params.Add("@IDFamilia", idFamily)
                    SQLManager.ExecuteStoreProcedure("spREFER_ActualizaUtilizador", conn, params)
                Case 55
                    dt = SQLManager.SelectQuery("Select max([Index]) as [Index] from View_UserFamilyList where idUser=" & idUser, conn)
                    If IsDBNull(dt.Rows(0)("Index")) Then
                        NextIndex = 0
                    Else
                        NextIndex = dt.Rows(0)("Index") + 1
                    End If

                    params.Add("@idUser", idUser)
                    params.Add("@idFamily", idFamily)
                    params.Add("@index", NextIndex)
                    params.Add("@ret", 0)
                    SQLManager.ExecuteStoreProcedure("spe_AddUserFamily", conn, params)
            End Select
            SQLManager.DisposeConn(conn)

            Return True
        Catch
            Return False
        End Try
    End Function

    <WebMethod()> _
    Public Function DeleteUserFamily(idUser As Integer, idFamily As Integer) As Boolean
        Try
            Dim conn As SqlClient.SqlConnection
            Dim params As New Hashtable

            conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
            Select Case getDBVersion(conn)
                Case 11

                Case 55
                    params.Add("@idUser", idUser)
                    params.Add("@idFamily", idFamily)
                    params.Add("@ret", 0)
                    SQLManager.ExecuteStoreProcedure("spe_DeleteUserFamily", conn, params)
            End Select
            SQLManager.DisposeConn(conn)

            Return True
        Catch
            Return False
        End Try
    End Function

    <WebMethod()> _
    Public Function GetSmartCardByID(idSmartCard As Integer) As SmartCardProperties
        Try
            Dim conn As SqlClient.SqlConnection
            Dim dt As DataTable
            Dim nRecords As Integer
            Dim strSQL As String = ""

            conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
            Select Case getDBVersion(conn)
                Case 11
                    strSQL = "select idusager as idUser, idbadge as idSmartCard, dateperemption as ExpirationDate, statutbadge as SmartCardStatus " & _
                             "from Badge " & _
                             "where idbadge=" & idSmartCard
                Case 55
                    strSQL = "SELECT idUser, idSmartCard, ExpirationDate, SmartCardStatus " & _
                             "FROM View_SmartCardList " & _
                             "WHERE Deleted = 0 and idSmartCard=" & idSmartCard
            End Select
            If strSQL.Length = 0 Then
                SQLManager.DisposeConn(conn)
                Return Nothing
            Else
                dt = SQLManager.SelectQuery(strSQL, conn)
                SQLManager.DisposeConn(conn)
            End If

            nRecords = dt.Rows.Count
            If nRecords = 1 Then
                Dim result As SmartCardProperties

                result.idUser = dt.Rows(0)("idUser")
                result.idSmartCard = dt.Rows(0)("idSmartCard")
                result.ExpirationDate = dt.Rows(0)("ExpirationDate")
                result.Status = dt.Rows(0)("SmartCardStatus")
                Return result
            Else
                Return Nothing
            End If
        Catch
            Return Nothing
        End Try
    End Function

    <WebMethod()> _
    Public Function GetExternalSmartCards() As SmartCardProperties()
        Dim conn As SqlClient.SqlConnection
        Dim dt As DataTable
        Dim nRecords As Integer
        Dim strSQL As String = ""

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
        Select Case getDBVersion(conn)
            Case 11
                strSQL = "SELECT Vue_UsagerListe.codelogique as LogicalCode, Vue_UsagerListe.idusager as idUser, Vue_UsagerListe.type, Vue_BadgeListe.idbadge as idSmartCard, " & _
                                "Vue_UsagerListe.prenom + ' ' + Vue_UsagerListe.nom + ' (' + Vue_UsagerListe.codelogique + ') - ' + Vue_BadgeListe.Libelle AS Label, " & _
                                "Vue_BadgeListe.tag, Vue_BadgeListe.statutbadge as SmartCardStatus " & _
                         "FROM Vue_UsagerListe INNER JOIN Vue_BadgeListe ON Vue_UsagerListe.codelogique = Vue_BadgeListe.codelogique " & _
                         "WHERE (Vue_UsagerListe.supprime = 0) AND (Vue_BadgeListe.supprime = 0) AND (Vue_UsagerListe.type > 0) " & _
                         "ORDER BY Vue_UsagerListe.codelogique"
            Case 55
                strSQL = "SELECT View_UserList.LogicalCode, View_UserList.idUser, View_UserList.type, View_SmartCardList.idSmartCard, " & _
                                "View_UserList.FirstName + ' ' + View_UserList.Name + ' (' + View_UserList.LogicalCode + ') - ' + View_SmartCardList.Label AS Label, " & _
                                "View_SmartCardList.tag, View_SmartCardList.SmartCardStatus " & _
                         "FROM View_UserList INNER JOIN View_SmartCardList ON View_UserList.idUser = View_SmartCardList.idUser " & _
                         "WHERE (View_UserList.Deleted = 0) AND (View_SmartCardList.Deleted = 0) AND (View_UserList.type > 0) " & _
                         "ORDER BY View_UserList.LogicalCode"
        End Select
        If strSQL.Length = 0 Then
            SQLManager.DisposeConn(conn)
            Return Nothing
        Else
            dt = SQLManager.SelectQuery(strSQL, conn)
            SQLManager.DisposeConn(conn)
        End If

        nRecords = dt.Rows.Count
        If nRecords = 0 Then
            SQLManager.DisposeConn(conn)
            Return Nothing
        Else
            Dim result(nRecords - 1) As SmartCardProperties
            Dim i As Integer = 0
            For Each dr As DataRow In dt.Rows
                result(i).idSmartCard = dr("idSmartCard")
                result(i).idUser = dr("idUser")
                result(i).Label = IIf(IsDBNull(dr("Label")), 0, dr("Label"))
                result(i).tag = IIf(IsDBNull(dr("tag")), 0, dr("tag"))
                result(i).Status = IIf(IsDBNull(dr("SmartCardStatus")), 0, dr("SmartCardStatus"))
                result(i).LogicalCode = IIf(IsDBNull(dr("LogicalCode")), 0, dr("LogicalCode"))
                i += 1
            Next
            Return result
        End If
    End Function

    <WebMethod()> _
    Public Function UpdateSmartCard(idSmartCard As Integer, ExpirationDate As Datetime, Status As SmartCardStatus) As Boolean
        Try
            Dim conn As SqlClient.SqlConnection
            Dim params As New Hashtable
            Dim strsql As String = ""

            conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
            Select Case getDBVersion(conn)
                Case 11
                    strsql = "spREFER_ActualizaCartao"
                    params.Add("@IDCartao", idSmartCard)
                    params.Add("@DataValidade", ExpirationDate)
                    params.Add("@Estado", Status)
                Case 55
                    strsql = "spe_UpdateSmartCard"
                    params.Add("@idSmartCard", idSmartCard)
                    params.Add("@ExpirationDate", ExpirationDate)
                    params.Add("@SmartCardStatus", Status)
                    params.Add("@Ret", 0)
            End Select
            If strsql.Length = 0 Then
                SQLManager.DisposeConn(conn)
                Return Nothing
            Else
                SQLManager.ExecuteStoreProcedure(strsql, conn, params)
                SQLManager.DisposeConn(conn)
            End If

            Return True
        Catch
            Return False
        End Try
    End Function

    <WebMethod()> _
    Public Function GetLastCircuitEvents(CircuitIDs As String, LastHours As Integer, MaxNumberOfRecords As Integer) As EventProperties()
        Dim conn As SqlClient.SqlConnection
        Dim dt As DataTable
        Dim nRecords As Integer
        Dim strsql As String = ""

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
        If CircuitIDs.Length > 0 And LastHours > 0 And MaxNumberOfRecords > 0 Then
            Select Case getDBVersion(conn)
                Case 11
                    strsql = "SELECT TOP " & MaxNumberOfRecords & " DataHora AS [DateTime],Nome as Name, 0 as idFamily,FamiliaAcesso as Family,0 as idCompany,Empresa as Company,NumEmpregado AS LogicalCode,0 as idEvent,Mensagem as Event, IDZona as idGeoZone, Zona as GeoZone,0 as idCircuit,Circuito as Circuit FROM vwREFERLogPortas WHERE idcircuit IN (" + CircuitIDs + ") order by DataHora DESC"
                Case 55
                    strsql = "SELECT TOP " & MaxNumberOfRecords & " dbo.VueHisto.dat AS [DateTime], dbo.VueHisto.prenom + ' ' + dbo.VueHisto.nom AS Name, " & _
                                 "dbo.VueHisto.idfamille AS idFamily, dbo.VueHisto.famille AS Family, " & _
                                 "dbo.VueHisto.idsociete AS idCompany, dbo.VueHisto.societe AS Company, " & _
                                 "dbo.VueHisto.idevenement AS idEvent, dbo.VueHisto._tr_LibelleEvt AS [Event], " & _
                                 "View_UserList.idGeoZone, dbo.View_GeoZoneList.label AS GeoZone, " & _
                                 "dbo.VueHisto.idCircuit, LibelleCircuit + ' - ' + dbo.Acces.description as Circuit, " & _
                                 "dbo.VueHisto.codelogique AS LogicalCode, DATEDIFF(hour, dbo.VueHisto.dat, GETDATE()) AS Expr1 " & _
                             "FROM View_GeoZoneList INNER JOIN " & _
                                "View_UserList ON View_GeoZoneList.idGeoZone = View_UserList.idGeoZone RIGHT OUTER JOIN " & _
                                "VueHisto LEFT OUTER JOIN " & _
                                "Acces ON VueHisto.idcircuit = Acces.idcircuit ON View_UserList.LogicalCode = VueHisto.codelogique " & _
                             "WHERE (dbo.VueHisto.idevenement NOT IN (249,253,255)) AND (dbo.VueHisto.codelogique IS NOT NULL) AND " & _
                                "(dbo.VueHisto.dat > DATEADD(hh, -" & LastHours & ", GETDATE())) AND " & _
                                "dbo.VueHisto.idCircuit in (" & CircuitIDs & ") " & _
                             "ORDER BY dbo.VueHisto.dat DESC"
            End Select
        End If

        If strsql.Length = 0 Then
            SQLManager.DisposeConn(conn)
            Return Nothing
        Else
            dt = SQLManager.SelectQuery(strsql, conn)
            SQLManager.DisposeConn(conn)
        End If

        nRecords = dt.Rows.Count
        If nRecords = 0 Then
            SQLManager.DisposeConn(conn)
            Return Nothing
        Else
            Dim result(nRecords - 1) As EventProperties
            Dim i As Integer = 0
            For Each dr As DataRow In dt.Rows
                result(i).DateTime = dr("DateTime")
                result(i).Name = IIf(IsDBNull(dr("Name")), "", dr("Name"))
                result(i).idFamily = IIf(IsDBNull(dr("idFamily")), 0, dr("idFamily"))
                result(i).Family = IIf(IsDBNull(dr("Family")), "", dr("Family"))
                result(i).idCompany = IIf(IsDBNull(dr("idCompany")), 0, dr("idCompany"))
                result(i).Company = IIf(IsDBNull(dr("Company")), "", dr("Company"))
                result(i).LogicalCode = IIf(IsDBNull(dr("LogicalCode")), "", dr("LogicalCode"))
                result(i).idEvent = IIf(IsDBNull(dr("idEvent")), 0, dr("idEvent"))
                result(i).Event = IIf(IsDBNull(dr("Event")), "", dr("Event"))
                result(i).idGeoZone = IIf(IsDBNull(dr("idGeoZone")), 0, dr("idGeoZone"))
                result(i).GeoZone = IIf(IsDBNull(dr("GeoZone")), "", dr("GeoZone"))
                result(i).idCircuit = IIf(IsDBNull(dr("idCircuit")), 0, dr("idCircuit"))
                result(i).Circuit = IIf(IsDBNull(dr("Circuit")), "", dr("Circuit"))
                i += 1
            Next
            Return result
        End If
    End Function

    <WebMethod()> _
    Public Function CountUsersByZone() As ZoneProperties()
        Dim conn As SqlClient.SqlConnection
        Dim dt As DataTable
        Dim nRecords As Integer
        Dim strsql As String = ""

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
        Select Case getDBVersion(conn)
            Case 11
                strsql = "SELECT [IDZonaUltimaPassagem] as idGeoZone, [ZonaUltimaPassagem] as Label, [NumPessoas] as C FROM [vwREFERContaPessoasPorZona]"
            Case 55
                strsql = "SELECT View_UserList.idGeoZone, View_GeoZoneList.Label, COUNT(View_UserList.idUser) AS C " & _
                         "FROM View_UserList INNER JOIN " & _
                              "View_GeoZoneList ON View_UserList.idGeoZone = View_GeoZoneList.idGeoZone " & _
                         "WHERE (View_UserList.Deleted = 0) " & _
                         "GROUP BY View_UserList.idGeoZone, View_GeoZoneList.Label " & _
                         "ORDER BY View_GeoZoneList.Label"
        End Select
        If strsql.Length = 0 Then
            SQLManager.DisposeConn(conn)
            Return Nothing
        Else
            dt = SQLManager.SelectQuery(strsql, conn)
            SQLManager.DisposeConn(conn)
        End If

        nRecords = dt.Rows.Count
        If nRecords = 0 Then
            SQLManager.DisposeConn(conn)
            Return Nothing
        Else
            Dim result(nRecords - 1) As ZoneProperties
            Dim i As Integer = 0
            For Each dr As DataRow In dt.Rows
                result(i).idGeoZone = dr("idGeoZone")
                result(i).Label = dr("Label")
                result(i).UserCount = dr("C")
                i += 1
            Next
            Return result
        End If
    End Function

    <WebMethod()> _
    Public Function GetUsersByZone(idGeoZone As Integer) As UserProperties()
        Dim conn As SqlClient.SqlConnection
        Dim dt As DataTable
        Dim nRecords As Integer
        Dim strsql As String = ""

        conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
        Select Case getDBVersion(conn)
            Case 11
                strsql = "SELECT DataUltimaPassagem as PassingDate,NumEmpregado as LogicalCode,Nome as Name " & _
                         "FROM vwREFERUtilizadores " & _
                         "WHERE IDZonaUltimaPassagem = " & idGeoZone
            Case 55
                strsql = "SELECT PassingDate, LogicalCode, FirstName + ' ' + Name AS Name " & _
                         "FROM View_UserList " & _
                         "WHERE idGeoZone = " & idGeoZone & " " & _
                         "ORDER BY Name"
        End Select

        If strsql.Length = 0 Then
            SQLManager.DisposeConn(conn)
            Return Nothing
        Else
            dt = SQLManager.SelectQuery(strsql, conn)
            SQLManager.DisposeConn(conn)
        End If

        nRecords = dt.Rows.Count
        If nRecords = 0 Then
            SQLManager.DisposeConn(conn)
            Return Nothing
        Else
            Dim result(nRecords - 1) As UserProperties
            Dim i As Integer = 0
            For Each dr As DataRow In dt.Rows
                result(i).LastPassingDate = IIf(IsDBNull(dr("PassingDate")), "", dr("PassingDate"))
                result(i).LogicalCode = IIf(IsDBNull(dr("LogicalCode")), "", dr("LogicalCode"))
                result(i).Name = IIf(IsDBNull(dr("Name")), "", dr("Name"))
                i += 1
            Next
            Return result
        End If
    End Function

    <WebMethod()> _
    Public Function GetCircuits() As CircuitProperties()
        Try
            Dim conn As SqlClient.SqlConnection
            Dim dt As DataTable
            Dim nRecords As Integer
            Dim strSQL As String = ""

            conn = SQLManager.InicializeConnSQL(ConnectionStrings("AlizesConnectionString").ConnectionString)
            Select Case getDBVersion(conn)
                Case 11, 55
                    strSQL = "SELECT dbo.Acces.idCircuit, dbo.Acces.libelle + ' - ' + dbo.Acces.description + ' - ' + dbo.Bus.adresse AS Label, dbo.Bus.adresse AS IPBus " & _
                             "FROM dbo.Acces INNER JOIN " & _
                                  "dbo.Coffret ON dbo.Acces.idcoffret = dbo.Coffret.idcoffret INNER JOIN " & _
                                  "dbo.Bus ON dbo.Coffret.idbus = dbo.Bus.idbus " & _
                             "WHERE (dbo.Acces.supprime = 0) " & _
                             "ORDER BY Label"
            End Select
            If strSQL.Length = 0 Then
                SQLManager.DisposeConn(conn)
                Return Nothing
            Else
                dt = SQLManager.SelectQuery(strSQL, conn)
                SQLManager.DisposeConn(conn)
            End If

            nRecords = dt.Rows.Count
            If nRecords = 0 Then
                SQLManager.DisposeConn(conn)
                Return Nothing
            Else
                Dim result(nRecords - 1) As CircuitProperties
                Dim i As Integer = 0
                For Each dr As DataRow In dt.Rows
                    result(i).idCircuit = dr("idCircuit")
                    result(i).Label = IIf(IsDBNull(dr("Label")), "", dr("Label"))
                    result(i).IP = dr("IPBus")
                    i += 1
                Next
                Return result
            End If
        Catch
            Return Nothing
        End Try
    End Function
#End Region

#Region " Funções privadas"
    Private Function getDBVersion(conn As SqlClient.SqlConnection) As Integer
        Dim dt As DataTable
        dt = SQLManager.SelectQuery("SELECT max(version) as Version FROM Version", conn)
        Return dt.Rows(0)("version")
    End Function
#End Region

#Region " Variáveis Publicas"

    Public Enum SmartCardStatus
        Unknown = 0
        Active = 2
        Forbiden = 4
        Lost = 8
        Stolen = 16
        Destroied = 32
    End Enum

    Public Structure UserProperties
        Dim idUser As Integer
        Dim Name As String
        Dim LogicalCode As String
        Dim idGeoZone As Integer
        Dim idReader As Integer
        Dim LastPassingDate As DateTime
    End Structure

    Public Structure UserFamilies
        Dim idUser As Integer
        Dim idFamily As Integer
        Dim Label As String
        Dim index As Integer
    End Structure

    Public Structure SmartCardProperties
        Dim idSmartCard As Integer
        Dim Label As String
        Dim tag As String
        Dim idUser As Integer
        Dim ExpirationDate As Date
        Dim Status As SmartCardStatus
        Dim LogicalCode As String
    End Structure

    Public Structure Family
        Dim idFamily As Integer
        Dim Label As String
    End Structure

    Public Structure EventProperties
        Dim [DateTime] As DateTime
        Dim Name As String
        Dim idFamily As Integer
        Dim Family As String
        Dim idCompany As Integer
        Dim Company As String
        Dim LogicalCode As String
        Dim idEvent As Integer
        Dim [Event] As String
        Dim idGeoZone As Integer
        Dim GeoZone As String
        Dim idCircuit As Integer
        Dim Circuit As String
    End Structure

    Public Structure ZoneProperties
        Dim idGeoZone As Integer
        Dim Label As String
        Dim UserCount As String
    End Structure

    Public Structure CircuitProperties
        Dim idCircuit As Integer
        Dim Label As String
        Dim IP As String
    End Structure
#End Region
End Class