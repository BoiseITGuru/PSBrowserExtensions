# PSChromeExtensions

Add extensions to chrome via Web  Strore ID via powershell

Getting the extension
------

Clone the repository with git using `git clone https://svalding@bitbucket.org/svalding/pschromeextensions.git`

Visit https://bitbucket.org/svalding/pschromeextensions/downloads/ and click the Download repository link


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
New-ChromeExtension -ExtensionID 'bmnlcjabgnpnenekpadlanbbkooimhnj' -Mode Machine
```