#
#  Getting AAD Token for Database (could be done using WebInvoke as well)
# 
Function Get-AADToken {
    [CmdletBinding()]
    [OutputType([string])]
    PARAM (
        [String]$TenantId,
        [string]$ServicePrincipalId,
        [securestring]$ServicePrincipalPwd
    )
    Try {
        # Set Resource URI to Azure Database
        $resourceAppIdURI = 'https://database.windows.net/'

        # Set Authority to Azure AD Tenant
        $authority = 'https://login.windows.net/' + $TenantId
        $ClientCred = [Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential]::new($ServicePrincipalId, $ServicePrincipalPwd)
        $authContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]::new($authority)
        $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI, $ClientCred)
        #$Token = $authResult.Result.CreateAuthorizationHeader()
        $Token = $authResult.Result.AccessToken
    }
    Catch {
        Throw $_
        $ErrorMessage = 'Failed to aquire Azure AD token.'
        Write-Error -Message 'Failed to aquire Azure AD token'
    }
    $Token
}

# Portable module
Import-Module AzureAD.Standard.Preview

#region Login to Azure Subscription
 # Login-AzureRmAccount
$TenantId = "<INSERT>"
$SubscriptionId = "<INSERT>"
Set-AzureRmContext -SubscriptionId $SubscriptionId
 
# Connect to AD to perform AD commands
Connect-AzureAD -TenantId $TenantId  

# Find previously created SPN by display name
$SpnName = "test sql db"   
$SPN = Get-AzureADServicePrincipal -SearchString $SpnName

# Find AD group to add SPN to
$ADGroupName = "TestSQLAADAdmins"
$AADGroup = Get-AzureADGroup -SearchString $ADGroupName

# Add SPN to AD Group
Add-AzureADGroupMember -ObjectId $($AADGroup.ObjectId) -RefObjectId $($SPN.ObjectId)

# Validate it was added
Get-AzureADGroupMember -ObjectId $($AADGroup.ObjectId)

 #region Connect to db using SPN Account

$ServicePrincipalId =  $SPN.AppId
$SecureStringPassword = ConvertTo-SecureString -String "<INSERT PASSWORD>" -AsPlainText -Force
$SQLServerName = "testpwshsrv"

# Get AAD Token for principal
Get-AADToken -TenantID $TenantId -ServicePrincipalId $ServicePrincipalId -ServicePrincipalPwd $SecureStringPassword -OutVariable SPNToken


# Connect to Database and exacuet commands
Write-Output "Create SQL connectionstring"
$conn = New-Object System.Data.SqlClient.SQLConnection 
$DatabaseName = 'Master'
$conn.ConnectionString = "Data Source=$SQLServerName.database.windows.net;Initial Catalog=$DatabaseName;Connect Timeout=30"
$conn.AccessToken = $($SPNToken)
$conn

Write-Output "Connect to database and execute SQL script"
$conn.Open() 
$query = 'select @@version'
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $conn) 	
$Result = $command.ExecuteScalar()
$Result

$query = 'CREATE USER [$ADGroupName] FROM EXTERNAL PROVIDER;'
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $conn) 	
$Result = $command.ExecuteScalar()
$Result

$query = 'CREATE USER [bob@lenishagmail.onmicrosoft.com] FROM EXTERNAL PROVIDER;'
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $conn) 	
$Result = $command.ExecuteScalar()
$Result


$conn.Close() 

#endregions