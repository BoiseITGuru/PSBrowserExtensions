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

New-FirefoxExtension -ExtensionPath 'C:\FirefoxExtensions' -ExtensionUri 'https://addons.mozilla.org/firefox/downloads/file/984183/keepacom_amazon_preisuberwachung-3.29-an+fx.xpi?src=collection' -Hive HKLM