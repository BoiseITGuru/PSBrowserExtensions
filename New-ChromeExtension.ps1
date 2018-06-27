
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
        [String[]]$ExtensionID
    )

    Foreach ($Extension in $ExtensionID) {
      
        $regLocation = 'Software\Policies\Google\Chrome\ExtensionInstallForcelist'
        # Each extension if you want to force install more than 1 extension needs its own key #

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

        
        $regKey = $Count + 1
        Write-Verbose -Message "Creating reg key with value $regKey"
        
        $regData = "$Extension;https://clients2.google.com/service/update2/crx"
        New-ItemProperty -Path "HKLM:\$regLocation" -Name $regKey -Value $regData -PropertyType STRING -Force
    
    }

}
