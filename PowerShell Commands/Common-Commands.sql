-- 1) Open SQL Server Management Studio and Connect to Server from PowerShell
ssms.exe <scriptfile> -S $serverName -E

-- 2) Add datetime in FileName
Write-Host "fileName_$(Get-Date -Format ddMMMyyyyTHHmm).sql";

-- 3) Unattended script execution
	https://dba.stackexchange.com/questions/197360/how-to-execute-sql-server-query-in-ssms-using-powershell
sqlcmd -Q 'E:\PowerShell_PROD\Screenshot\ServerDetails.sql' -E -S localhost

-- 4) Get file name
"F:\Mssqldata\Data\UserTracking_data.mdf" -match "^(?'PathPhysicalName'.*[\\\/])(?'BasePhysicalName'.+)"
$Matches['BasePhysicalName'] => UserTracking_data.mdf
$Matches['PathPhysicalName'] => F:\Mssqldata\Data\

-- 5) Is Null or Empty
[string]::IsNullOrEmpty($StopAt_Time) -eq $false

-- 6) Create a PS Drive for Demo Purposes
New-PSDrive -Persist -Name "P" -PSProvider "FileSystem" -Root "\\Tul1cipedb3\g$"

-- 7) Add color to Foreground and Background text
write-host "[OK]" -ForegroundColor Cyan

-- 7) File exists or not
[System.IO.File]::Exists($n)

-- 8) Get all files on drive by Size
Get-ChildItem -Path 'F:\' -Recurse -Force -ErrorAction SilentlyContinue | 
    Select-Object Name, @{l='ParentPath';e={$_.DirectoryName}}, @{l='SizeBytes';e={$_.Length}}, @{l='Owner';e={((Get-ACL $_.FullName).Owner)}}, CreationTime, LastAccessTime, LastWriteTime, @{l='IsFolder';e={if($_.PSIsContainer) {1} else {0}}}, @{l='SizeMB';e={$_.Length/1mb}}, @{l='SizeGB';e={$_.Length/1gb}} |
    Sort-Object -Property SizeBytes -Descending | Out-GridView

-- 9) Check if -Verbose switch is used
$PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent

-- 10) Check if Module is installed
if (Get-Module -ListAvailable -Name SqlServer) {
    Write-Host "Module exists"
} else {
    Write-Host "Module does not exist"
}

-- 11) Find path of SQLDBATools Module
(Get-Module -ListAvailable SQLDBATools).Path

-- 12) Log entry into ErrorLogs table
$MessageText = "Get-WmiObject : Access is denied. Failed in execution of Get-ServerInfo";
Write-Host $MessageText -ForegroundColor Red;
Add-CollectionError -ComputerName $ComputerName -Cmdlet 'Add-ServerInfo' -CommandText "Add-ServerInfo -ComputerName '$ComputerName'" -ErrorText $MessageText -Remark $null;
return;

-- 13) Querying using SQLProvider
$computerName = 'TUL1CIPEDB2'

Get-ChildItem SQLSERVER:\SQL\$computerName\DEFAULT
$sqlInstance = Get-Item SQLSERVER:\SQL\$computerName\DEFAULT
$sqlInstance | gm -MemberType Property

$sqlInstance | select ComputerNamePhysicalNetBIOS, Name, Edition, ErrorLogPath, IsCaseSensitive, IsClustered,
                            IsHadrEnabled, IsFullTextInstalled, LoginMode, NetName, PhysicalMemory,
                            Processors, ServiceInstanceId, ServiceName, ServiceStartMode, 
                            VersionString, Version, DatabaseEngineEdition

$sqlInstance.Information | Select-Object * | fl
$sqlInstance.Properties | Select-Object Name, Value | ft -AutoSize
$sqlInstance.Configuration

-- 14) Querying SqlServer using PowerShell
$computerName = 'TUL1CIPEDB2'

<# SMO #> 
$server = New-Object Microsoft.SqlServer.Management.Smo.Server("$computerName")
$server | Select-Object ComputerNamePhysicalNetBIOS, Name, Edition, ErrorLogPath, IsCaseSensitive, IsClustered,
                            IsHadrEnabled, IsFullTextInstalled, LoginMode, NetName, PhysicalMemory,
                            Processors, ServiceInstanceId, ServiceName, ServiceStartMode, 
                            VersionString, Version, DatabaseEngineEdition

$server.Configuration.MaxServerMemory
$server.Configuration.CostThresholdForParallelism
$server.Configuration.MinServerMemory
$server.Configuration.MaxDegreeOfParallelism
$server.Configuration.Properties | ft -AutoSize -Wrap
                            
<# SQL Provider #> 
Get-ChildItem SQLSERVER:\SQL\$computerName\DEFAULT
$sqlInstance = Get-Item SQLSERVER:\SQL\$computerName\DEFAULT
$sqlInstance.Databases['DBA'].Schemas
$sqlInstance.Databases['DBA'].Tables | Select-Object Schema, Name, RowCount
Get-ChildItem SQLSERVER:\SQL\$computerName\DEFAULT\Databases\DBA\Tables | Select-Object Schema, Name, RowCount;
(Get-Item SQLSERVER:\SQL\$computerName\DEFAULT\Databases\DBA\Tables).Collection | Select-Object Schema, Name, RowCount;

$sqlInstance | gm -MemberType Property

$sqlInstance | select ComputerNamePhysicalNetBIOS, Name, Edition, ErrorLogPath, IsCaseSensitive, IsClustered,
                            IsHadrEnabled, IsFullTextInstalled, LoginMode, NetName, PhysicalMemory,
                            Processors, ServiceInstanceId, ServiceName, ServiceStartMode, 
                            VersionString, Version, DatabaseEngineEdition

$sqlInstance.Information | Select-Object * | fl
$sqlInstance.Properties | Select-Object Name, Value | ft -AutoSize
$sqlInstance.Configuration 

-- 15) Set Mail profile
# Set computerName
$computerName = 'TUL1CIPINXDB4'

$srv = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Server("$computerName");
$sm = $srv.Mail.Profiles | Where-Object {$_.Name -eq $computerName};
$srv.JobServer.AgentMailType = 'DatabaseMail';
$srv.JobServer.DatabaseMailProfile = $sm.Name;
$srv.JobServer.Alter();

--	16) CollectionTime
@{l='CollectionTime';e={(Get-Date).ToString("yyyy-MM-dd HH:mm:ss")}}

-- 17) Out-GridView
Get-Process|Where {$_.cpu -ne $null}|ForEach {New-Object -TypeName psObject -Property @{name=$_.Name;cpu=[double]$_.cpu}}|Out-GridView

-- 18) Move *.sql Files & Folder from Source to Destination
$sServer = 'SrvSource';
$tServer = 'SrvDestination';

$basePath = 'f$\mssqldata'

# Find source folders
$folders = Get-ChildItem "\\$sServer\$basePath" -Recurse | Where-Object {$_.PsIsContainer};

# Create same folders on destination
foreach($fldr in $folders)
{
    $newPath = $fldr.FullName -replace "\\\\$sServer\\", "\\\\$tServer\\";
    $exists = ([System.IO.Directory]::Exists($newPath));

    if($exists) {
        Write-Host "Exists=> $newPath" -ForegroundColor Green;
    } else {
        Write-Host "NotExists=> $newPath" -ForegroundColor Yellow;
        #[System.IO.Directory]::CreateDirectory($newPath);
    }
    #$fldr.FullName -replace "\\\\$sServer\\", "\\\\$tServer\\"
}

# Find source folders
$sqlfiles = Get-ChildItem "\\$sServer\$basePath" -Recurse | Where-Object {$_.PsIsContainer -eq $false} | 
                Where-Object {$_.Extension -eq '.sql' -or $_.Extension -eq '.bat'};

# Create same folders on destination
foreach($file in $sqlfiles)
{
    $newPath = $file.FullName -replace "\\\\$sServer\\", "\\\\$tServer\\";
    $exists = ([System.IO.File]::Exists($newPath));

    if($exists) {
        Write-Host "Exists=> $newPath" -ForegroundColor Green;
    } else {
        Write-Host "NotExists=> $newPath" -ForegroundColor Yellow;
        #Copy-Item "$($file.FullName)" -Destination "$newPath"
    }
}

-- 16) Get Inventory Servers on Excel
Import-Module SQLDBATools -DisableNameChecking;

# Fetch ServerInstances from Inventory
$tsqlInventory = @"
select * from Info.Server
"@;

$Servers = (Invoke-Sqlcmd -ServerInstance $InventoryInstance -Database $InventoryDatabase -Query $tsqlInventory | Select-Object -ExpandProperty ServerName);
$SqlInstance = @();


foreach($server in $Servers)
{
    $r = Fetch-ServerInfo -ComputerName $server;
    $SqlInstance += $r;
}

$SqlInstance | Export-Excel 'C:\temp\TivoSQLServerInventory.xlsx'


-- 17) Group-Object & Measure-Object
$PathOrFolder = 'E:\'
$files = Get-ChildItem -Path $PathOrFolder -Recurse -File | ForEach-Object {
                $Parent = (Split-Path -path $_.FullName);
                New-Object psobject -Property @{
                   Name = $_.Name;
                   FullName = $_.FullName;
                   Parent = $Parent;
                   SizeBytes = $_.Length;
                }
            }

$FolderWithSize = $files | Group-Object Parent | %{
            New-Object psobject -Property @{
                                            Parent = $_.Name
                                            Sum = ($_.Group | Measure-Object SizeBytes -Sum).Sum
                                           }
        }

--	18) 
<# Script to Find databases which are not backed up in Last 7 Days
#>

$Server2Analyze = 'tul1cipxdb12';
$DateSince = (Get-Date).AddDays(-7) # Last 7 days

# Find Latest Bacukps
$Backups = Get-DbaBackupHistory -SqlInstance $Server2Analyze -Type Full -Since $DateSince #'5/5/2018 00:00:00'

$BackedDbs = $Backups | Select-Object -ExpandProperty Database -Unique

# List of available dbs
$dbs = Invoke-Sqlcmd -ServerInstance $Server2Analyze -Database master -Query "select name from sys.databases" | select -ExpandProperty name;

$NotBackedDbs = @();
foreach($db in $dbs)
{
    if($BackedDbs -contains $db){
        Write-Host "$db is +nt";
    }
    else {
        $NotBackedDbs += $db;
    }
}

Write-Host "Returing Dbs for which backup is not there.." -ForegroundColor Green;
$NotBackedDbs | Add-Member -NotePropertyName ServerName -NotePropertyValue $Server2Analyze -PassThru -Force | 
    Out-GridView -Title "Not Backed Dbs"

#Remove-Variable -Name NotBackedDbs

--	19) Import Remove Server Module
$session = New-PSSession -computerName TUL1DBAPMTDB1;
Invoke-Command -scriptblock { Import-Module dbatools } -session $session;
Import-PSSession -module dbatools -session $session;

