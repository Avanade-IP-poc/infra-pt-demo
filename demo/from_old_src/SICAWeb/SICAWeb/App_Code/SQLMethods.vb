Imports System.Data
Imports System.Data.OleDb
Imports System.Data.SqlClient
Imports System.Collections

Public Class SQLMethods

    Public Function InicializeConnSQL(ByVal strConn As String) As SqlConnection
        Dim sqlconn As New SqlConnection(strConn)
        sqlconn.Open()

        Return sqlconn
    End Function

    Public Sub DisposeConn(ByRef conn As SqlConnection)
        Try
            If conn IsNot Nothing Then
                conn.Close()
                conn.Dispose()
                conn = Nothing
            End If
        Catch
        End Try
    End Sub

    Protected Friend Function InicializeConnOleDb(ByVal strConn) As OleDbConnection
        Dim conn As New OleDbConnection(strConn)
        conn.Open()

        Return conn
    End Function

    Protected Friend Sub DisposeConn(ByRef conn As OleDbConnection)
        Try
            If conn IsNot Nothing Then
                conn.Close()
                conn.Dispose()
                conn = Nothing
            End If
        Catch
        End Try
    End Sub

    Public Function GetStoreProcedure(ByVal SQLConn As SqlConnection, ByVal SpName As String, ByVal Params As Hashtable) As DataTable
        Dim dt As DataTable

        dt = SelectStoreProcedure(SpName, SQLConn, Params)

        Return dt

    End Function

    Public Function GetStoreProcedure(ByVal SQLConn As SqlConnection, ByVal SpName As String) As DataTable
        Dim dt As DataTable

        dt = SelectStoreProcedure(SpName, SQLConn)

        Return dt

    End Function

    Private Function SelectStoreProcedure(ByVal SpName As String, ByVal SQLConn As SqlConnection, ByVal Params As Hashtable) As DataTable
        Dim comm As New SqlCommand
        Dim dr As SqlDataReader
        Dim dt As DataTable

        comm = buildProcedureCommand(SQLConn, SpName, Params)
        dr = comm.ExecuteReader()
        dt = makeTable(dr)
        dr.Close()
        Return dt

    End Function

    Private Function SelectStoreProcedure(ByVal SpName As String, ByVal SQLConn As SqlConnection) As DataTable
        Dim comm As New SqlCommand
        Dim dr As SqlDataReader
        Dim dt As DataTable

        comm.CommandType = CommandType.StoredProcedure
        comm.CommandText = SpName
        comm.Connection = SQLConn
        dr = comm.ExecuteReader()
        dt = makeTable(dr)
        dr.Close()
        Return dt

    End Function

    Private Function SelectStoreProcedure(ByVal SpName As String, ByVal Conn As OleDbConnection, ByVal Params As Hashtable) As DataTable
        Dim comm As New OleDbCommand
        Dim dr As OleDbDataReader
        Dim dt As DataTable

        comm = buildProcedureCommand(Conn, SpName, Params)
        dr = comm.ExecuteReader()
        dt = makeTable(dr)
        dr.Close()
        Return dt

    End Function

    Public Sub ExecuteStoreProcedure(ByVal SpName As String, ByVal SQLConn As SqlConnection, ByVal Params As Hashtable)
        Dim comm As New SqlCommand

        comm = buildProcedureCommand(SQLConn, SpName, Params)
        comm.ExecuteNonQuery()
    End Sub

    Private Function buildProcedureCommand(ByVal SQLConn As SqlConnection, ByVal SpName As String, ByVal parameters As Hashtable) As SqlCommand
        Dim cmd As New SqlCommand(SpName, SQLConn)
        Dim enumerator As IDictionaryEnumerator

        cmd.CommandType = CommandType.StoredProcedure

        enumerator = parameters.GetEnumerator()

        Do While enumerator.MoveNext
            cmd.Parameters.AddWithValue(DirectCast(enumerator.Key, String), enumerator.Value)
        Loop

        Return cmd
    End Function

    Private Function buildProcedureCommand(ByVal Conn As OleDbConnection, ByVal SpName As String, ByVal parameters As Hashtable) As OleDbCommand
        Dim cmd As New OleDbCommand(SpName, Conn)
        Dim enumerator As IDictionaryEnumerator

        cmd.CommandType = CommandType.StoredProcedure

        enumerator = parameters.GetEnumerator()

        Do While enumerator.MoveNext
            cmd.Parameters.AddWithValue(DirectCast(enumerator.Key, String), enumerator.Value)
        Loop

        Return cmd
    End Function

    Public Function SelectQuery(ByVal SqlStrQuery As String, ByVal SqlConn As SqlConnection) As DataTable
        Dim Cmd As New SqlCommand
        Dim Table As New DataTable
        Dim Dr As SqlDataReader

        'Try
        Cmd = SqlConn.CreateCommand()
        Cmd.CommandText = SqlStrQuery
        Cmd.CommandType = CommandType.Text
        Dr = Cmd.ExecuteReader()

        Table = makeTable(Dr)
        Dr.Close()
        'Catch
        'End Try

        Return Table
    End Function

    Protected Friend Function SelectQuery(ByVal SqlStrQuery As String, ByVal Conn As OleDbConnection) As DataTable
        Dim Cmd As New OleDbCommand
        Dim Table As New DataTable
        Dim Dr As OleDbDataReader

        'Try
        Cmd = Conn.CreateCommand()
        Cmd.CommandText = SqlStrQuery
        Cmd.CommandType = CommandType.Text
        Dr = Cmd.ExecuteReader()

        Table = makeTable(Dr)
        Dr.Close()

        Return Table
    End Function

    Public Function SelectQuery(ByVal selectCommand As String, ByVal connectionString As String) As DataTable
        Dim result As DataTable
        Dim conn As SqlConnection

        conn = InicializeConnSQL(connectionString)

        result = SelectQuery(selectCommand, conn)

        conn.Close()
        conn.Dispose()

        Return result
    End Function

    Protected Friend Function UpdateQuery(ByVal SqlStrQuery As String, ByVal SqlConn As SqlConnection) As Integer
        Dim Rowsaffected As Integer = 0
        Dim Cmd As New SqlCommand

        Try
            Cmd = SqlConn.CreateCommand()
            Cmd.CommandText = SqlStrQuery
            Cmd.CommandType = CommandType.Text

            Rowsaffected = Cmd.ExecuteNonQuery()
        Catch
        End Try

        Return Rowsaffected
    End Function

    Protected Friend Function UpdateQuery(ByVal SqlStrQuery As String, ByVal Conn As OleDbConnection) As Integer
        Dim Rowsaffected As Integer = 0
        Dim Cmd As New OleDbCommand

        Try
            Cmd = Conn.CreateCommand()
            Cmd.CommandText = SqlStrQuery
            Cmd.CommandType = CommandType.Text

            Rowsaffected = Cmd.ExecuteNonQuery()
        Catch
        End Try

        Return Rowsaffected
    End Function

    Private Function makeTable(ByVal reader As SqlDataReader) As DataTable
        Dim n As Integer = reader.FieldCount
        Dim Table As New DataTable
        Dim Col As DataColumn
        Dim Row As DataRow

        Dim i As Integer

        For i = 0 To n - 1
            Col = New DataColumn(reader.GetName(i), reader.GetFieldType(i))
            Table.Columns.Add(Col)
        Next

        While reader.Read()
            Row = Table.NewRow()
            For i = 0 To n - 1
                Row(i) = reader.GetValue(i)
            Next
            Table.Rows.Add(Row)
        End While

        Return Table

    End Function

    Private Function makeTable(ByVal reader As OleDbDataReader) As DataTable
        Dim n As Integer = reader.FieldCount
        Dim Table As New DataTable
        Dim Col As DataColumn
        Dim Row As DataRow

        Dim i As Integer

        For i = 0 To n - 1
            Col = New DataColumn(reader.GetName(i), reader.GetFieldType(i))
            Table.Columns.Add(Col)
        Next

        While reader.Read()
            Row = Table.NewRow()
            For i = 0 To n - 1
                Row(i) = reader.GetValue(i)
            Next
            Table.Rows.Add(Row)
        End While

        Return Table

    End Function

    Protected Friend Function ConstructQueryStr(ByVal param() As String) As String
        Dim i As Integer
        Dim sb As New System.Text.StringBuilder

        For i = 1 To param.Length - 1
            sb.Append(" c_03_98_01='" & param(i) & "' ")
            If i <> param.Length - 1 Then
                sb.Append(" or")
            End If
        Next

        Return sb.ToString
    End Function

    Protected Friend Function BuildInsertSQL(ByVal TableName As String, ByVal dtColumns As DataTable, ByVal drData As DataRow) As String
        Dim strSQL As String = ""
        Dim strFields As String = ""
        Dim strValues As String = ""

        For Each drColumns As DataRow In dtColumns.Rows
            If drColumns("UpdateSQLField") Then
                If strFields.Length > 0 Then strFields += ","
                strFields += "[" & drColumns("SQLFieldName") & "]"

                If strValues.Length > 0 Then strValues += ","
                strValues += drColumns("SQLFieldDataSeparator")
                If drData(drColumns("ADAttributeName").ToString).ToString.Length > drColumns("SQLFieldLength") Then
                    strValues += drData(drColumns("ADAttributeName").ToString).ToString.Substring(0, drColumns("SQLFieldLength"))
                Else
                    strValues += drData(drColumns("ADAttributeName").ToString).ToString
                End If
                strValues += drColumns("SQLFieldDataSeparator")
            End If
        Next

        If strFields.Length > 1 Then strSQL = "INSERT INTO " & TableName & " (" & strFields & ") VALUES (" & strValues & ")"

        Return strSQL
    End Function

    Protected Friend Function BuildUpdateSQL(ByVal TableName As String, ByVal dtColumns As DataTable, ByVal drData As DataRow) As String
        Dim strSQL As String = ""
        Dim strFields As String = ""
        Dim strWhere As String = ""

        For Each drColumns As DataRow In dtColumns.Rows
            If drColumns("UpdateSQLField") Then
                If strFields.Length > 0 Then strFields += ","
                strFields += "[" & drColumns("SQLFieldName") & "]=" & drColumns("SQLFieldDataSeparator")
                If drData(drColumns("ADAttributeName").ToString).ToString.Length > drColumns("SQLFieldLength") Then
                    strFields += drData(drColumns("ADAttributeName").ToString).ToString.Substring(0, drColumns("SQLFieldLength"))
                Else
                    strFields += drData(drColumns("ADAttributeName").ToString).ToString
                End If
                strFields += drColumns("SQLFieldDataSeparator")
            End If
            If drColumns("IsKey") Then
                If strWhere.Length > 0 Then strWhere += " AND "
                strWhere += drColumns("SQLFieldName") & "=" & drColumns("SQLFieldDataSeparator") & drData(drColumns("ADAttributeName").ToString).ToString & drColumns("SQLFieldDataSeparator")
            End If
        Next

        If strFields.Length > 0 Then strSQL = "UPDATE " & TableName & " SET " & strFields & " WHERE " & strWhere

        Return strSQL
    End Function


End Class
