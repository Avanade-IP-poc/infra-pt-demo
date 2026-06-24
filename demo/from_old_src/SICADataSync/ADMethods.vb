Imports System.DirectoryServices
Imports System.DirectoryServices.ActiveDirectory
Imports System.Configuration.ConfigurationManager

Module ADMethods
    Public Function ADConnection(ByVal DomainControler As String, _
                                    ByVal RootDSE As String, _
                                    ByVal distinguishedUsername As String, _
                                    ByVal Password As String) As DirectoryEntry

        Dim ConnActiveDirectory As New DirectoryServices.DirectoryEntry("LDAP://" & DomainControler & ":389/" & RootDSE)

        ConnActiveDirectory.Username = distinguishedUsername
        ConnActiveDirectory.Password = Password
        ConnActiveDirectory.AuthenticationType = AuthenticationTypes.Secure

        Return ConnActiveDirectory
    End Function

    Public Function ADConnection(ByVal DomainControler As String, _
                                    ByVal RootDSE As String) As DirectoryEntry

        Dim ConnActiveDirectory As New DirectoryServices.DirectoryEntry("LDAP://" & DomainControler & ":389/" & RootDSE)

        ConnActiveDirectory.AuthenticationType = AuthenticationTypes.Secure

        Return ConnActiveDirectory
    End Function

    Public Function ADConnectionObj(ByVal adsPath As String, _
                                        ByVal distinguishedUsername As String, _
                                        ByVal Password As String) As DirectoryEntry

        Dim ConnActiveDirectory As New DirectoryServices.DirectoryEntry(adsPath)

        ConnActiveDirectory.Username = distinguishedUsername
        ConnActiveDirectory.Password = Password
        ConnActiveDirectory.AuthenticationType = AuthenticationTypes.Secure

        Return ConnActiveDirectory
    End Function

    Public Function ADConnectionObj(ByVal adsPath As String) As DirectoryEntry

        Dim ConnActiveDirectory As New DirectoryServices.DirectoryEntry(adsPath)

        ConnActiveDirectory.AuthenticationType = AuthenticationTypes.Secure

        Return ConnActiveDirectory
    End Function


    Public Function ADCheck_By_AtributeName(ByVal attributeValue As String, ByVal attributeNameToSearch As String, ByVal ADConnRefer As DirectoryEntry, ByVal withObjAdsPath As Boolean) As AD_By_AtributeName
        Dim struct As AD_By_AtributeName

        struct = ADSearch(ADConnRefer, "(&(objectClass=user)(" & attributeNameToSearch & "=" & attributeValue & "))", withObjAdsPath)

        Return struct
    End Function

    Public Function ADGetNonArrayParameterValue(ByVal ADConn As DirectoryEntry, ByVal parameterName As String) As Object
        If ADConn.Properties.Contains(parameterName) Then
            Return ADConn.Properties(parameterName).Value
        Else
            Return Nothing
        End If

    End Function

    Public Function ADGetUserMembers(ByVal userADSPath As String) As String()
        Dim objUser As DirectoryEntry

        objUser = ADConnectionObj(userADSPath)

        If objUser.Properties.Contains("memberOf") Then
            Dim listGroups(objUser.Properties("memberOf").Count - 1) As String
            objUser.Properties("memberOf").CopyTo(listGroups, 0)
            Return listGroups
        End If

        objUser.Close()
        objUser.Dispose()
        Return Nothing
    End Function

    Public Function ADGetUserMembers(ByVal objUser As DirectoryEntry) As String()
        If objUser.Properties.Contains("memberOf") Then
            Dim listGroups(objUser.Properties("memberOf").Count - 1) As String
            objUser.Properties("memberOf").CopyTo(listGroups, 0)
            Return listGroups
        End If

        Return Nothing
    End Function

    Public Function ADGetUsers(ByVal DomainControler As String, _
                                ByVal RootDSE As String, _
                                ByVal propertiesToLoad() As String, _
                                Optional ByVal sAMAccountName As String = Nothing) As DataTable
        Dim result As DataTable
        Dim ADConn As DirectoryEntry

        ADConn = ADConnection(DomainControler, RootDSE)

        'lê todos os utilizadores na AD
        If IsNothing(sAMAccountName) Then
            result = ADMakeTableWithADResult( _
                                            ADSearch( _
                                                    ADConn, "(&(objectClass=user))", propertiesToLoad), _
                                            propertiesToLoad)
        Else
            result = ADMakeTableWithADResult( _
                                ADSearch( _
                                        ADConn, "(&(objectCategory=user)(objectClass=user)(sAMAccountName=" & sAMAccountName & "))", propertiesToLoad), _
                                propertiesToLoad)
        End If

        ADConn.Close()
        ADConn.Dispose()

        Return result
    End Function

    Public Function ADGetUsers(ByVal DomainControler As String, _
                                ByVal RootDSE As String, _
                                ByVal propertiesToLoad() As DataRow, _
                                Optional ByVal sAMAccountName As String = Nothing, _
                                Optional ByVal employeeID As String = Nothing) As DataTable
        Dim result As DataTable
        Dim ADConn As DirectoryEntry

        ADConn = ADConnection(DomainControler, RootDSE)

        'lê todos os utilizadores na AD
        If IsNothing(sAMAccountName) Then
            If IsNothing(employeeID) Then
                result = ADMakeTableWithADResult( _
                                                ADSearch( _
                                                        ADConn, "(&(objectCategory=user)(objectClass=user))", propertiesToLoad), _
                                                propertiesToLoad)
            Else
                result = ADMakeTableWithADResult( _
                                                ADSearch( _
                                                        ADConn, "(&(objectCategory=user)(objectClass=user)(employeeID=" & employeeID & "))", propertiesToLoad), _
                                                propertiesToLoad)
            End If
        Else
            result = ADMakeTableWithADResult( _
                                            ADSearch( _
                                                    ADConn, "(&(objectCategory=user)(objectClass=user)(sAMAccountName=" & sAMAccountName & "))", propertiesToLoad), _
                                            propertiesToLoad)
        End If

        ADConn.Close()
        ADConn.Dispose()

        Return result
    End Function

    Public Function ADaddRemoveGroupFromUser(ByRef objuser As DirectoryEntry, ByVal GroupDistinguishedName As String, ByVal addRemove As String) As Boolean
        Dim group As DirectoryEntry
        Dim result As Boolean


        group = ADConnectionObj("LDAP://" & AppSettings("LDAPRefer") & ":389/" & GroupDistinguishedName)
        result = ADGroupAddRemove(group, objuser, addRemove)

        group.Close()
        group.Dispose()
        group = Nothing

        Return result
    End Function

    Public Sub ADUpdateInsertNonArrayAttributeWithCommit(ByRef obj As DirectoryEntry, ByVal valueToUpdate As Object, ByVal attributeName As String)
        If Not IsNothing(valueToUpdate) Then
            If obj.Properties.Contains(attributeName) Then
                If obj.Properties(attributeName).Value <> valueToUpdate Then
                    obj.Properties(attributeName).Value = valueToUpdate
                End If
            Else
                obj.Properties(attributeName).Add(valueToUpdate)
            End If
        Else
            If obj.Properties.Contains(attributeName) Then
                obj.Properties(attributeName).Clear()
            End If
        End If
        obj.CommitChanges()
    End Sub

    Public Sub ADUpdateInsertNonArrayAttribute(ByRef obj As DirectoryEntry, ByVal valueToUpdate As Object, ByVal attributeName As String)
        If Not IsNothing(valueToUpdate) Then
            If obj.Properties.Contains(attributeName) Then
                If obj.Properties(attributeName).Value <> valueToUpdate Then
                    obj.Properties(attributeName).Value = valueToUpdate
                End If
            Else
                obj.Properties(attributeName).Add(valueToUpdate)
            End If
        Else
            If obj.Properties.Contains(attributeName) Then
                obj.Properties(attributeName).Clear()
            End If
        End If
    End Sub

    Public Function ADGroupAddRemove(ByRef objGroup As DirectoryEntry, ByRef objUser As DirectoryEntry, ByVal AddRmv As String) As Boolean
        Try
            objGroup.Invoke(AddRmv, objUser.Path)
            objGroup.CommitChanges()
            Return True
        Catch
            Return False
        End Try
    End Function

    Public Function ADGroupAddRemove(ByRef objGroup As DirectoryEntry, ByRef objAdsPath As String, ByVal AddRmv As String) As Boolean
        Try
            objGroup.Invoke(AddRmv, objAdsPath)
            objGroup.CommitChanges()
            Return True
        Catch
            Return False
        End Try
    End Function

    Public Sub ADRemoveProxyAddressFromUser(ByVal obj As DirectoryEntry)
        If obj.Properties.Contains("proxyAddresses") Then
            obj.Properties("proxyAddresses").Clear()
            obj.CommitChanges()
        End If
    End Sub

    Public Function ADSearch(ByRef ADConn As DirectoryEntry, ByVal Filter As String, ByVal PropertiesToLoad As String()) As SearchResultCollection
        Dim ADResult As SearchResultCollection
        Dim ADSearcher As DirectorySearcher

        ADSearcher = New DirectorySearcher(ADConn)

        ADSearcher.Filter = Filter

        ADSearcher.PropertiesToLoad.AddRange(PropertiesToLoad)

        ADResult = ADSearcher.FindAll()

        Return ADResult
    End Function

    Public Function ADSearch(ByRef ADConn As DirectoryEntry, ByVal Filter As String, ByVal PropertiesToLoad() As DataRow) As SearchResultCollection
        Dim ADResult As SearchResultCollection
        Dim ADSearcher As DirectorySearcher

        ADSearcher = New DirectorySearcher(ADConn)

        For Each drPropertiesToLoad As DataRow In PropertiesToLoad
            ADSearcher.PropertiesToLoad.Add(drPropertiesToLoad(0).ToString)
        Next

        ADSearcher.Filter = Filter

        ADResult = ADSearcher.FindAll()

        Return ADResult
    End Function

    Private Function ADSearch(ByVal ADConnRefer As DirectoryEntry, ByVal Filter As String, ByVal withObjAdsPath As Boolean) As AD_By_AtributeName
        Dim struct As AD_By_AtributeName
        Dim ADSearcher As DirectorySearcher
        Dim ADResult As SearchResultCollection
        Dim searchResult As SearchResult

        ADSearcher = New DirectorySearcher(ADConnRefer)
        ADSearcher.PropertiesToLoad.Add("sAMAccountName")
        ADSearcher.Filter = Filter
        ADResult = ADSearcher.FindAll()
        struct._numberOfOccurrencesRefer = ADResult.Count
        If withObjAdsPath Then
            struct.adsPaths = New ArrayList
            For Each searchResult In ADResult
                struct.adsPaths.Add(searchResult.Path)
            Next
        End If

        ADSearcher.Dispose()
        ADSearcher = Nothing

        Return struct
    End Function

    Public Function ADSearchSubnetsInCurrentForest() As Data.DataTable
        Dim myForest As Forest
        Dim mySites As ReadOnlySiteCollection
        Dim mySubnets As ActiveDirectorySubnetCollection
        Dim iEnumSites, iEnumSubnets As Integer

        Dim result As New DataTable
        Dim row As DataRow

        result.Columns.Add("Name", System.Type.GetType("System.String"))
        result.Columns.Add("Location", System.Type.GetType("System.String"))

        myForest = Forest.GetCurrentForest
        mySites = myForest.Sites

        For iEnumSites = 0 To mySites.Count - 2
            mySubnets = mySites(iEnumSites).Subnets
            For iEnumSubnets = 0 To (mySubnets.Count - 1)
                row = result.NewRow()
                row("Name") = mySubnets(iEnumSubnets).Name
                row("Location") = mySubnets(iEnumSubnets).Location
                result.Rows.Add(row)
                row = Nothing
            Next
        Next

        Return result
    End Function

    Public Function ADMakeTableWithADResult(ByRef ADResult As SearchResultCollection, _
                                            ByVal PropertiesLoaded() As String) As Data.DataTable
        Dim Table As New DataTable
        Dim col As DataColumn
        Dim row As DataRow

        For i As Integer = 0 To PropertiesLoaded.Length - 1
            col = New DataColumn(PropertiesLoaded(i), System.Type.GetType("System.String"))
            Table.Columns.Add(col)
        Next

        For i As Integer = 0 To ADResult.Count - 1
            row = Table.NewRow()
            For j As Integer = 0 To PropertiesLoaded.Length - 1
                If ADResult(i).Properties.Contains(PropertiesLoaded(j)) Then
                    row(PropertiesLoaded(j)) = ADResult(i).Properties(PropertiesLoaded(j))(0)
                End If
            Next
            Table.Rows.Add(row)
        Next
        Return Table
    End Function

    Public Function ADMakeTableWithADResult(ByRef ADResult As SearchResultCollection, _
                                                ByVal PropertiesLoaded() As DataRow) As Data.DataTable
        Dim Table As New DataTable
        Dim col As DataColumn
        Dim row As DataRow

        For Each drPropertiesToLoad As DataRow In PropertiesLoaded
            col = New DataColumn(drPropertiesToLoad(0), System.Type.GetType("System.String"))
            Table.Columns.Add(col)
            col.Dispose()
        Next

        For i As Integer = 0 To ADResult.Count - 1
            row = Table.NewRow()
            For j As Integer = 0 To Table.Columns.Count - 1
                If ADResult(i).Properties.Contains(Table.Columns(j).ColumnName) Then
                    row(Table.Columns(j).ColumnName) = ADResult(i).Properties(Table.Columns(j).ColumnName)(0)
                End If
            Next

            Table.Rows.Add(row)
        Next
        Return Table
    End Function

    Public Sub ADMoveObject(ByVal ObjectToMove As DirectoryEntry, ByVal DestinationObject As DirectoryEntry)
        ObjectToMove.MoveTo(DestinationObject)
    End Sub

    Public Sub ADMoveObject(ByVal ADConn As DirectoryEntry, ByVal ObjectToMoveADSPath As String, ByVal DestinationADSPath As String, ByVal ADAdminUserPassword As String)
        Dim ObjectToMove As DirectoryEntry
        Dim DestinationObject As DirectoryEntry

        ObjectToMove = ADConnectionObj(ObjectToMoveADSPath, ADConn.Username, ADAdminUserPassword)
        DestinationObject = ADConnectionObj(DestinationADSPath, ADConn.Username, ADAdminUserPassword)

        ObjectToMove.MoveTo(DestinationObject)

        ObjectToMove.Close()
        ObjectToMove.Dispose()
        ObjectToMove = Nothing
        DestinationObject.Close()
        DestinationObject.Dispose()
        DestinationObject = Nothing
    End Sub

    Public Sub ADMoveObject(ByVal ObjectToMoveADSPath As String, ByVal DestinationADSPath As String)
        Dim ObjectToMove As DirectoryEntry
        Dim DestinationObject As DirectoryEntry

        ObjectToMove = ADConnectionObj(ObjectToMoveADSPath)
        DestinationObject = ADConnectionObj(DestinationADSPath)

        ObjectToMove.MoveTo(DestinationObject)

        ObjectToMove.Close()
        ObjectToMove.Dispose()
        ObjectToMove = Nothing
        DestinationObject.Close()
        DestinationObject.Dispose()
        DestinationObject = Nothing
    End Sub

    Public Sub ADSetWorkstationUserAccountControl(ByVal ADConn As DirectoryEntry, ByVal ADObjectPath As String, ByVal Enable As Boolean, ByVal ADAdminUserPassword As String)
        Dim obj As DirectoryEntry

        obj = ADConnectionObj(ADConn.Path, ADConn.Username, ADAdminUserPassword)

        'userAccountControl = 4096 - account enabled
        'userAccountControl = 4098 - account disabled
        'http://support.microsoft.com/kb/305144

        obj.Path = ADObjectPath
        obj.Properties("userAccountControl").Value = IIf(Enable, 4096, 4098)
        obj.CommitChanges()

        obj.Close()
        obj.Dispose()
        obj = Nothing
    End Sub

    Public Sub ADSetWorkstationUserAccountControl(ByVal ADConn As DirectoryEntry, ByVal ADObjectPath As String, ByVal Enable As Boolean)
        Dim obj As DirectoryEntry

        obj = ADConnectionObj(ADConn.Path)

        'userAccountControl = 4096 - account enabled
        'userAccountControl = 4098 - account disabled
        'http://support.microsoft.com/kb/305144

        obj.Path = ADObjectPath
        obj.Properties("userAccountControl").Value = IIf(Enable, 4096, 4098)
        obj.CommitChanges()

        obj.Close()
        obj.Dispose()
        obj = Nothing
    End Sub

    Public Sub ADSetUserAccountControl(ByVal ADConn As DirectoryEntry, ByVal ADObjectPath As String, ByVal Enable As Boolean)
        Dim obj As DirectoryEntry

        obj = ADConnectionObj(ADConn.Path)

        'userAccountControl = 544 - account enabled
        'userAccountControl = 546 - account disabled
        'http://support.microsoft.com/kb/305144

        obj.Path = ADObjectPath
        obj.Properties("userAccountControl").Value = IIf(Enable, 544, 546)
        obj.CommitChanges()

        obj.Close()
        obj.Dispose()
        obj = Nothing
    End Sub

    Public Sub ADSetUserAccountControl(ByVal ADObject As DirectoryEntry, ByVal Enable As Boolean)

        'userAccountControl = 544 - account enabled
        'userAccountControl = 546 - account disabled
        'http://support.microsoft.com/kb/305144

        ADObject.Properties("userAccountControl").Value = IIf(Enable, 544, 546)
        ADObject.CommitChanges()
    End Sub

    Public Function ADIsUserEnabled(ByVal ADObject As DirectoryEntry) As Boolean
        Dim result As Boolean = True

        Select Case ADObject.Properties("userAccountControl").Value
            Case 544
                result = True
            Case Else
                result = False
        End Select

        Return result
    End Function

    Public Function ADIsUserEnabled(ByVal userAccountControl As Integer) As Boolean
        Dim result As Boolean = True

        Select Case userAccountControl
            Case 544
                result = False
        End Select

        Return result
    End Function

    Public Sub ADDeleteWorkstation(ByVal ADConn As DirectoryEntry, ByVal ADObjectPath As String, ByVal ADAdminUserPassword As String)
        Dim obj As DirectoryEntry

        obj = ADConnectionObj(ADConn.Path, ADConn.Username, ADAdminUserPassword)

        obj.Path = ADObjectPath
        obj.DeleteTree()
        obj.CommitChanges()

        obj.Close()
        obj.Dispose()
        obj = Nothing
    End Sub

    Public Function ADConvertLargeIntegerToDate(ByVal ADConn As DirectoryEntry, ByVal PropertieToConvert As String) As Date
        Dim d As Date = Nothing
        Dim l As Long
        Dim o As Object = ADConn.Properties(PropertieToConvert).Value

        If Not IsNothing(o) Then
            l = (o.HighPart * &H100000000) + o.LowPart
            d = DateTime.FromFileTime(l)
        End If

        Return d
    End Function

    Public Structure AD_By_AtributeName
        Public _numberOfOccurrencesRefer As Integer
        Public adsPaths As ArrayList
    End Structure

End Module
