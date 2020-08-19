###########################################
#
# NXLog Configuration Script
#
# To execute this script:
# 1) Create a line delimited file with target computer names for installation
# 2) Fill in the Function Variables with the appropriate values
# 3) Open powershell window as an administrator
# 4) Allow script execution by running command "Set-ExecutionPolicy Unrestricted"
# 5) Execute the script by running ".\nxlog.ps1"
# Remote PowerShell must be supported by the target environment
# in order to it to function properly.
# Target hosts must have access to the internet in order to download configurations.
#
# Version: 0.1.3
# Last modification: 2020-08-19
###########################################

#Global Variables
$COMPUTERS = Get-Content "C:\PATH\TO\LOG\FILE"

# Check to make sure script is running as admin
Write-Verbose "[+] Checking if script is running as administrator.."
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )
if (-Not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Verbose "`t[ERR] Please run this script as administrator`n" #-ForegroundColor Red
    Read-Host  "Press any key to continue"
    exit
}

Function downloadagent {
    #Function Variables that need to be set
    $SENSORIP = '0.0.0.0' #Set Sensor IP
    $PORT = 'udp' #input udp or tcp, configurations default to port 514/UDP
    $PATH = "$env:USERPROFILE\nxlog.conf"
    $DEST = "$env:ProgramFiles (x86)\nxlog\conf\nxlog.conf"
    $WINLOGS = '' #Input y or n
    $IISLOGS = '' #Input y or n
    $IISELOGS = '' #Input y or n
    $WFWLOGS = '' #Input y or n
    $DHCPLOGS = '' #Input y or n
    $DNSLOGS = '' #Input y or n
    $EXCHANGE = '' #Input y or n
    $SYSMON = '' #Input y or n
    $SQL = '' #Input y or n
    $NPS = '' #Input y or n
    $SHARE = '' #Input y or n
    $NET = '' #Input y or n
    $FTP = '' #Input y or n
    $IIE2 = '' #Input y or n

    #Download and install NXLog CE
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://nxlog.co/system/files/products/files/348/nxlog-ce-2.10.2150.msi", "$env:USERPROFILE\nxlog.msi")
    msiexec /i "$env:USERPROFILE\nxlog.msi" /quiet /passive
    sleep -s 10
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://raw.githubusercontent.com/Hacks4Snacks/windows-nxlog/master/nxlog_nxlog.conf", "$env:USERPROFILE\nxlog.conf")
    if ($SENSORIP) {
        #Edit and replace the conf file
        (Get-Content $PATH) | ForEach-Object { $_ -replace "$SENSORIP", $SENSORIP } | Set-Content $PATH
        #Set the logging port
        if ($PORT -eq 'tcp') {
            (Get-Content $PATH) | ForEach-Object { $_ -replace "514", "601" } | Set-Content $PATH
            (Get-Content $PATH) | ForEach-Object { $_ -replace "om_udp", "om_tcp" } | Set-Content $PATH
        }
        #Log Windows Events
        if ($WINLOGS -eq 'y') {
            (Get-Content $PATH) | ForEach-Object { $_ -replace "#WIN", "" } | Set-Content $PATH
        }
        #Log IIS
        if ($IISLOGS -eq 'y') {
            (Get-Content $PATH) | ForEach-Object { $_ -replace "#IIS", "" } | Set-Content $PATH
        }
        #Log IIS Extended
        if ($IISELOGS -eq 'y') {
            (Get-Content $PATH) | ForEach-Object { $_ -replace "#IISE", "" } | Set-Content $PATH
        }
        #Windows FW
        if ( $WFWLOGS -eq 'y') {
            (Get-Content $PATH) | ForEach-Object { $_ -replace "#WFW", "" } | Set-Content $PATH
        }
        #DHCP
        if ($DHCPLOGS -eq 'y') {
            (Get-Content $PATH) | ForEach-Object { $_ -replace "#DHCP", "" } | Set-Content $PATH
        }
        #DNS
        if ($DNSLOGS -eq 'y') {
            (Get-Content $PATH) | ForEach-Object { $_ -replace "#DNS", "" } | Set-Content $PATH
        }
        #Exchange
        if ($EXCHANGE -eq 'y') {
            (Get-Content $PATH) | ForEach-Object { $_ -replace "#EXCH", "" } | Set-Content $PATH
        }
        #SQL
        if ($SQL -eq 'y') {
            (Get-Content $PATH) | ForEach-Object { $_ -replace "#SQL", "" } | Set-Content $PATH
        }
        #NPS
        if ($NPS -eq 'y') {
            (Get-Content $PATH) | ForEach-Object { $_ -replace "#NPS", "" } | Set-Content $PATH
        }
        #SHARE
        if ($SHARE -eq 'y') {
            (Get-Content $PATH) | ForEach-Object { $_ -replace "#SHARE", "" } | Set-Content $PATH
        }
        #NET
        if ($NET -eq 'y') {
            (Get-Content $PATH) | ForEach-Object { $_ -replace "#NET", "" } | Set-Content $PATH
        }
        #FTP
        if ($FTP -eq 'y') {
            (Get-Content $PATH) | ForEach-Object { $_ -replace "#FTP", "" } | Set-Content $PATH
        }
        #IIE2
        if ($IIE2 -eq 'y') {
            (Get-Content $PATH) | ForEach-Object { $_ -replace "#IIE2", "" } | Set-Content $PATH
        }	
        #Sysmon
        if ($SYSMON -eq 'y') {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $WebClient = New-Object System.Net.WebClient
            # TODO transition from EXE download to Microsoft latest version zip
            $WebClient.DownloadFile("https://raw.githubusercontent.com/Hacks4Snacks/windows-nxlog/master/sysmon_config_schema4_0.xml", "$env:USERPROFILE\sysmon_config_schema4_0.xml")
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile("https://github.com/Hacks4Snacks/windows-nxlog/raw/master/Sysmon.exe", "$env:USERPROFILE\Sysmon.exe")
            sleep -s 10
            $sysconf = "$env:USERPROFILE\sysmon_config_schema4_0.xml"
            $sysmon = "$env:USERPROFILE\Sysmon.exe"
            Start-Process -FilePath $sysmon "-accepteula -h md5 -n -l -i $sysconf"
            sleep -s 10
            (Get-Content $PATH) | ForEach-Object { $_ -replace "#SYSM", "" } | Set-Content $PATH
        }
		
        #Copy the conf file to the NXLog system folder
        Copy-Item -Path $PATH -Destination $DEST -force
    }
    'Starting service...'
    #Check if NxLog is installed
    $Service = Get-Service -display nxlog -ErrorAction SilentlyContinue 
    If (-Not $Service) {
        "NxLog is not installed on this server."
    }
    else {
        #Start nxlog service
        Start-Service nxlog
        'Done!'
    }
    sleep -s 3
}

ForEach ($computer in $COMPUTERS) {
    Invoke-Command -ComputerName $computer -ScriptBlock ${Function:downloadagent}
}
