Function New-FirefoxExtension {
    [cmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$ExtensionUri,
        [Parameter(Mandatory)]
        [String]$ExtensionPath,
        [Parameter(Mandatory = $false)]
        [ValidateSet('HKCU', 'HKLM')]
        [string]$Hive
    )

    If (!(Test-Path $ExtensionPath)) {
        
        New-Item -ItemType Directory $ExtensionPath | Out-Null
    
    }

    #Store just the extension filename for later use
    #Thanks reddit user /u/ta11ow for the regex help!
    $ExtensionUri -match '(?<=/)(?<ExtensionName>[^/]+)(?=\?)'
    $Extension = $matches['ExtensionName']

    #Download the Extension and save it to the FireFoxExtensions folder
    Invoke-WebRequest -Uri $ExtensionUri -OutFile "C:\FirefoxExtensions\$Extension"

    Get-ChildItem -Path $ExtensionPath | Rename-Item -NewName {$_.Name -replace ".xpi",".zip"}

    If ($PSVersionTable.PSVersion.Major -ge 4) {
        
        Expand-Archive -Path (Get-ChildItem $ExtensionPath).FullName -DestinationPath $ExtensionPath
    }

    Else {

        [System.IO.Compression.ZipFile]::ExtractToDirectory((Get-ChildItem $ExtensionPath).FullName,$ExtensionPath)

    }

    Switch ($Hive) {
        
        'HKCU' {
            Switch ([environment]::Is64BitOperatingSystem) {
                $true {
          
                    If (!(Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe")) {

                        $regKey = "HKCU:\Software\Wow6432Node\Mozilla\Firefox\Extensions"
                        New-ItemProperty -Path $regKey -Name $matches['ExtensionName'] -Value "$ExtensionPath\$($matches['ExtensionName'])" -PropertyType String
                    }
                    
                    Else {
                        $regKey = "HKCU:\Software\Mozilla\Firefox\Extensions"
                        New-ItemProperty -Path $regKey -Name $matches['ExtensionName'] -Value "$ExtensionPath\$($matches['ExtensionName'])" -PropertyType String
                    }
                    
                }
                
                $false {
                        
                    $regKey = "HKCU:\Software\Mozilla\Firefox\Extensions"
                    New-ItemProperty -Path $regKey -Name $matches['ExtensionName'] -Value "$ExtensionPath\$($matches['ExtensionName'])" -PropertyType String
                
                }
            
            }#hkcu switch

        }#hkcu

        'HKLM' {
            Switch ([environment]::Is64BitOperatingSystem) {
                $true {
          
                    If (!(Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe")) {

                        $regKey = "HKLM:\Software\Wow6432Node\Mozilla\Firefox\Extensions"
                        New-ItemProperty -Path $regKey -Name $matches['ExtensionName'] -Value "$ExtensionPath\$($matches['ExtensionName'])" -PropertyType String
                    }
                    
                    Else {
                        $regKey = "HKLM:\Software\Mozilla\Firefox\Extensions"
                        New-ItemProperty -Path $regKey -Name $matches['ExtensionName'] -Value "$ExtensionPath\$($matches['ExtensionName'])" -PropertyType String
                    }
                    
                }
                
                $false {
                        
                    $regKey = "HKLM:\Software\Mozilla\Firefox\Extensions"
                    New-ItemProperty -Path $regKey -Name $matches['ExtensionName'] -Value "$ExtensionPath\$($matches['ExtensionName'])" -PropertyType String
                
                }
            
            }#hklm switch
    
        }#hklm 
    }#end outer switch
}

$cmdletParams = @{
    'ExtensionUri' = 'https://addons.mozilla.org/firefox/downloads/file/984183/keepacom_amazon_preisuberwachung-3.29-an+fx.xpi?src=collection'
    'ExtensionPath' = 'C:\FirefoxExtensions'
    'Hive' = 'HKLM'
}

New-FirefoxExtension @cmdletParams