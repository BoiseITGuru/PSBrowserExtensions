# PSBrowserExtensions

Getting the module
------

 1. Clone the repository with git using `git clone https://svalding@bitbucket.org/svalding/psbrowserextensions.git`
 _or_
 2. Visit https://bitbucket.org/svalding/psbrowserextensions/downloads/ and click the Download repository link

 3. Unzip the file

 4. Place the PSBrowserExtensions folder in one of the locations returned by `$PSModulePath` in powershell
 
#Google Chrome
Add extensions to chrome via Web  Store ID via powershell




Finding Chrome Extensions
------
Visit the Chrome webstore here:
https://chrome.google.com/webstore/category/extensions

Search and find the extension you wish to load, and note the ID in the URL

```
Example URL:
https://chrome.google.com/webstore/detail/honey/bmnlcjabgnpnenekpadlanbbkooimhnj
```
In the above Honey example the ID is: bmnlcjabgnpnenekpadlanbbkooimhnj

Using the Script
------


```
Import-Module C:\Scripts\New-ChromeExtension.ps1
New-ChromeExtension -ExtensionID 'bmnlcjabgnpnenekpadlanbbkooimhnj' -Hive Machine
```

#Mozilla Firefox
Add add-ons to Mozilla Firefox via Powershell

Getting the extension
------

Clone the repository with git using `git clone https://svalding@bitbucket.org/svalding/psbrowserextensions.git`

Visit https://bitbucket.org/svalding/psbrowserextensions/downloads/ and click the Download repository link

Finding Firefox Add-ons
------
Visit the Firefox add-on store here:
https://addons.mozilla.org/en-US/firefox/

Search and find the extension you wish to load, and copy the download url
_right click 'Add to Firefox, Copy Link Address_

```
Example URL:
https://addons.mozilla.org/firefox/downloads/file/985780/ublock_origin-1.16.10-an+fx.xpi?src=dp-btn-primary
```
In the above Ublock Origin example the ID is: ublock_origin-1.16.10-an+fx.xpi

Using the Script
------


```
Use splatting to shorten the scroll of the parameters
    $params = @{
        'ExtensionUri' = 'https://addons.mozilla.org/firefox/downloads/file/985780/ublock_origin-1.16.10-an+fx.xpi?src=dp-btn-primary'
        'ExtensionPath' = 'C:\FirefoxExtensions'
        'Hive' = 'HKLM'
    }

    New-FirefoxExtension @params
```

