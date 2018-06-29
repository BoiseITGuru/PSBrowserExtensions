
Function New-ChromeExtension {
    <#
    
    .SYNOPSIS
    Add Chrome Extensions to PC via Powershell
    
    .PARAMETER ExtensionID
    String value of an extension ID taken from the Chrome Web Store URL for the extension
    
    .EXAMPLE
    This will install uBlock Origin
    New-ChromeExtension -ExtensionID 'cjpalhdlnbpafiamejdnhcphjbkeiagm'
    
    .EXAMPLE
    This will install uBlock Origin, and Zoom Meetings
    New-ChromeExtension -ExtensionID @('kgjfgplpablkjnlkjmjdecgdpfankdle', 'cjpalhdlnbpafiamejdnhcphjbkeiagm') -Verbose
    
    #>
    
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String[]]$ExtensionID,
        [Parameter(Mandatory)]
        [ValidateSet('Machine', 'User')]
        [String]$Mode

    )

    #Loop through each Extension in ExtensionID since it is an array.
    #Create a Key for every member of the ExtensionID Array
    Foreach ($Extension in $ExtensionID) {
      
        $regLocation = 'Software\Policies\Google\Chrome\ExtensionInstallForcelist'
        
        #Target HKLM or HKCU depending on whether you want to affect EVERY user, or just a single user.
        #If using HKCU, you'll need to run this script in that user context.
        Switch ($Mode) {
            'Machine' {
                If (!(Test-Path "HKLM:\$regLocation")) {
                    Write-Verbose -Message "No Registry Path, setting count to: 0"
                    [int]$Count = 0
                    Write-Verbose -Message "Count is now $Count" 
                    New-Item -Path "HKLM:\$regLocation" -Force
        
                }
        
                Else {
                    Write-Verbose -Message "Keys found, counting them..."
                    [int]$Count = (Get-Item "HKLM:\$regLocation").Count
                    Write-Verbose -Message "Count is now $Count"
                }
            }
            
            'User' {
                If (!(Test-Path "HKCU:\$regLocation")) {
                    
                    Write-Verbose -Message "No Registry Path, setting count to: 0"
                    [int]$Count = 0
                    Write-Verbose -Message "Count is now $Count" 
                    New-Item -Path "HKCU:\$regLocation" -Force
        
                }
        
                Else {
                    
                    Write-Verbose -Message "Keys found, counting them..."
                    [int]$Count = (Get-Item "HKCU:\$regLocation").Count
                    Write-Verbose -Message "Count is now $Count"
                
                }
            }
        }

        $regKey = $Count + 1
        Write-Verbose -Message "Creating reg key with value $regKey"
        
        $regData = "$Extension;https://clients2.google.com/service/update2/crx"

        Switch ($Mode) {
            
            'Machine' { New-ItemProperty -Path "HKLM:\$regLocation" -Name $regKey -Value $regData -PropertyType STRING -Force }
            'User' { New-ItemProperty -Path "HKCU:\$regLocation" -Name $regKey -Value $regData -PropertyType STRING -Force }
        
        }
    
    }

}

Function New-FirefoxExtension {
    <#
    .SYNOPSIS
    Add extensions to Firefox. Does not enable them
    
    .PARAMETER ExtensionUri
    The extension download uri found by right-clicking download in the app store --> copy link address

    .PARAMETER ExtensionPath
    The path you wish to store extensions on the system

    .PARAMETER Hive
    Controls whether you write changes to HKEY_LOCAL_MACHINE, or HKEY_CURRENT_USER.
    HKLM affects every user of a machine, HKCU will affect only the primary user.
    Shared machines should use HKLM, whereas single-user machines are fine with HKCU.

    .EXAMPLE
    #Installs the uBlock Origin Add-On
    New-FirefoxExtension -ExtensionUri 'https://addons.mozilla.org/firefox/downloads/file/985780/ublock_origin-1.16.10-an+fx.xpi?src=dp-btn-primary' -ExtensionPath 'C:\FirefoxExtensions' -Hive HKLM

    .EXAMPLE
    #Use splatting to shorten the scroll of the parameters
    $params = @{
        'ExtensionUri' = 'https://addons.mozilla.org/firefox/downloads/file/985780/ublock_origin-1.16.10-an+fx.xpi?src=dp-btn-primary'
        'ExtensionPath' = 'C:\FirefoxExtensions'
        'Hive' = 'HKLM'
    }

    New-FirefoxExtension @params

    .EXAMPLE
    #Load Uri's from a file
    $Params = @{
        'ExtensionUri' = @(Get-Content C:\addons.txt)
        'ExtensionPath = 'C:\FirefoxExtensions'
        'Hive' = 'HKLM'
    }

    .EXAMPLE
    #Load function into scope
    Import-Module C:\Scripts\New-FirefoxExtension.ps1
    $params = @{
        'ExtensionUri' = 'https://addons.mozilla.org/firefox/downloads/file/985780/ublock_origin-1.16.10-an+fx.xpi?src=dp-btn-primary'
        'ExtensionPath' = 'C:\FirefoxExtensions'
        'Hive' = 'HKLM'
    }

    New-FirefoxExtension @params

    #>
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string[]]$ExtensionUri,
        [Parameter(Mandatory)]
        [String]$ExtensionPath,
        [Parameter(Mandatory = $false)]
        [ValidateSet('HKCU', 'HKLM')]
        [string]$Hive
    )

    If (!(Test-Path $ExtensionPath)) {
        
        New-Item -ItemType Directory $ExtensionPath | Out-Null
    
    }

    Foreach ($Uri in $ExtensionUri) {

        #Store just the extension filename for later use
        #Thanks reddit user /u/ta11ow for the regex help!
        $Uri -match '(?<=/)(?<ExtensionName>[^/]+)(?=\?)'
        $Extension = $matches['ExtensionName']

        #Download the Extension and save it to the FireFoxExtensions folder
        Invoke-WebRequest -Uri $Uri -OutFile "C:\FirefoxExtensions\$Extension"

        #Now we have to manipulate the extension into the form that Mozilla dictates
        
        #Create a zip file from the xpi
        Get-ChildItem -Path $ExtensionPath | Foreach-Object { $NewName = $_.FullName -replace ".xpi", ".zip"
            Copy-Item -Path $_.FullName -Destination $NewName }

        #Depending on PS Version, expand the zip file
        If ($PSVersionTable.PSVersion.Major -ge 4) {
            
            Expand-Archive -Path (Get-ChildItem $ExtensionPath |
                    Where-Object { $_.Extension -eq '.zip'} |
                    Select-Object -ExpandProperty FullName) -DestinationPath $ExtensionPath
        }

        Else {

            [System.IO.Compression.ZipFile]::ExtractToDirectory((Get-ChildItem $ExtensionPath |
                        Where-Object { $_.Extension -eq '.zip'} |
                        Select-Object -ExpandProperty FullName), $ExtensionPath)

        }

        #convert the manifest file into a psobject
        $file = Get-Content "$ExtensionPath\manifest.json" | ConvertFrom-Json

        
        #store the author id
        $authorValue = $file.applications.gecko.id

        

        Rename-Item -Path $ExtensionPath\$($matches['ExtensionName']) -NewName "$authorValue.xpi"
        #Cleanup all the junk, leaving only the extension pack file behind
        Remove-Item -Path $ExtensionPath -Exclude *.xpi -Recurse -Force

        #Modify registry based on which Hive you selected
        Switch ($Hive) {
            
            'HKCU' {
                Switch ([environment]::Is64BitOperatingSystem) {
                    $true {
            
                        If (!(Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe")) {
                            
                            $regKey = "HKCU:\Software\Wow6432Node\Mozilla\Firefox\Extensions"
                            New-ItemProperty -Path $regKey -Name $authorValue -Value "$ExtensionPath\$authorValue.xpi" -PropertyType String
                        }
                        
                        Else {
                            
                            $regKey = "HKCU:\Software\Mozilla\Firefox\Extensions"
                            New-ItemProperty -Path $regKey -Name $authorValue -Value "$ExtensionPath\$authorValue.xpi" -PropertyType String
                        }
                        
                    }
                    
                    $false {
                        
                        $regKey = "HKCU:\Software\Mozilla\Firefox\Extensions"
                        New-ItemProperty -Path $regKey -Name $authorValue -Value "$ExtensionPath\$authorValue.xpi" -PropertyType String
                    
                    }
                
                }#hkcu switch

            }#hkcu

            'HKLM' {
                Switch ([environment]::Is64BitOperatingSystem) {
                    $true {
            
                        If (Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe") {
                            
                            $regKey = "HKLM:\Software\Mozilla\Firefox\Extensions"
                            New-ItemProperty -Path $regKey -Name $authorValue -Value "$ExtensionPath\$authorValue.xpi" -PropertyType String
                        }
                        
                        Else {
                            
                            $regKey = "HKLM:\Software\Wow6432Node\Mozilla\Firefox\Extensions"
                            
                            New-ItemProperty -Path $regKey -Name $authorValue -Value "$ExtensionPath\$authorValue.xpi" -PropertyType String
                        }
                        
                    }
                    
                    $false {
                        
                        $regKey = "HKLM:\Software\Mozilla\Firefox\Extensions"
                        New-ItemProperty -Path $regKey -Name $matches['ExtensionName'] -Value "$ExtensionPath\$($matches['ExtensionName'])" -PropertyType String
                    
                    }
                
                }#hklm switch
        
            }#hklm 
        }#end outer switch

    }#foreach

}#function

Export-ModuleMember -Function New-ChromeExtension,New-FirefoxExtension