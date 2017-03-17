$packages = @()

function init
{
    Param(
        [switch] $Force
    )
    #do
    #{

    if(!(Test-Admin)) {
        Write-Host "User is not running with administrative rights. Attempting to elevate..."
        $command = "-ExecutionPolicy bypass -noexit -command . '$(${function:init}.File)';init $($args)"
        Start-Process powershell -verb runas -argumentlist $command
        return
    }
         cls
         Write-Host "`n================ Heyy $env:Username, Welcome to ""I AM A GREAT AUTOMATION TOOL"" Application ================ `n"
         Write-Host "I know that you're suffering everytime when you have to set a new development environment or you have a new/fresh installed computer. `n"
         Write-Host "Don't Worry Honey! I'm here for you and I will make everything you need ready just for you ;) Love you! xoxo `n" 
         Write-Host "After answering a few questions, Please Sit Back and Relax!. `n" 
         Write-Host "INHALE slowly through your nose and EXHALE from your mouth! :D `n"
         
         Show-Menu 1
         $input = Read-Host "Please make a selection"
         switch ($input)
         {
               '1' {
                    #cls
                    $global:packages = "cmder", "jre8", "jdk8", "googlechrome", "7zip.install", "wireshark", "SublimeText3", "winscp.install", "git.install", "git-credential-winstore", "github", "virtualbox", "vagrant"
                    DisplayPackages
               } 
               '2' {
                    #cls
                    $global:packages = "git.install", "git-credential-winstore", "github", "virtualbox", "vagrant"
                    DisplayPackages
               } 
               '3' {
                    #cls
                    AddPackagetoList                    
               } 'q' {
                    return
               }
         }
         
         NeedtoAddPackage
         Write-Host "Package List Confirmed. Let the game begin! :D"
         Get-DevEnv

    #}
    #until($input -eq 'q')
}

function Show-Menu
{
     param (
           [Int32]$stepcounter = 1
     )

    if ($stepcounter -eq 1) {
         Write-Host "`n`n ================ Predefined Package List================ `n"
     
         Write-Host "1: Press '1' to install NewComer/FreshOS Package:
         {jre8/jdk8, GoogleChrome, 7zip, wireshark, SublimeText3, winscp, git, github, virtualbox, vagrant} `n"
         Write-Host "2: Press '2' to install DevBox Packagel:
         {git, github, virtualbox, vagrant} `n"
         Write-Host "3: Press '3' to create your package"
         Write-Host "Q: Press 'Q' to quit. `n"
    }
    elseif ($stepcounter -eq 2) {
         Write-Host "`n`n ================ Vagrant Box Installation================ `n"
     
         Write-Host "Do you want me to create a linux development environment for you? "
         Write-Host "Q: Press 'Q' to quit. `n"
    }
}

function NeedtoAddPackage
{
    $answer = ""
    Write-Host "`nDo you want to add any extra package to list?"
    #$answer = Read-Host "Yes (Y) or NO (N)"
    while("y","yes","n","no" -notcontains $answer)
    {
	    $answer = Read-Host "Yes (Y) or NO (N)"
    }
    if("y", "yes" -contains $answer){
        Write-Warning "Please check package names from the https://chocolatey.org/packages"
        AddPackagetoList
        #return $true
    }
    #else{
    #     return
    #}

    Check-Confirm
   

}

function Check-Confirm
{
    $ans = ""
    DisplayPackages
    Write-Warning "Last Exit before the Bridge : Do you confirm the package list?"
    while("y","yes","n","no" -notcontains $ans)
    {
	    $ans = Read-Host "Yes (Y) or NO (N)"
    }
    if("y", "yes" -contains $ans){
        return
    }
    else{
        NeedtoAddPackage
    }   
}

function AddPackagetoList
{
    $input = ''
    do {
        $input = (Read-Host "Please enter package name")
        if ($input -ne '') {$global:packages += $input}
       }
    until ($input -eq '')
}

function DisplayPackages
{
    Write-Host "`nThese packages below will be installed;"
    foreach($package in $global:packages) {
        Write-Host $package
    }
}


function Get-DevEnv {
    Param(
        [switch] $Force
    )

    #Write-Output "================ Heyy $env:Username, Welcome to the Windows Development Environment installer!================ `n"
    if(Check-Chocolatey -Force:$Force){
        Write-Output "Chocolatey installed, Installing DevOps Tools. `n"
        $version = choco -v
        #Write-Output $version
        #$tools = @("cmder", "git.install", "git-credential-winstore", "virtualbox", "vagrant")
        foreach ($package in $global:packages) {
            #Write-Output $element
	        #$command = "cinst -y $package"
            #Write-Output $command
            try{
                cinst -y $package
                #Invoke-Expression $command
                $SMessage += "$package Installation completed`n"
            }
            catch{
                #Invoke-Expression $command
                $FMessage += "$package Installation failed!`n"
            }
            #Write-Host $Message
        }

        Show-Menu 2
        
    }
    else {
        $Message = "Did not detect Chocolatey and unable to install. Installation  has been aborted."
    }

}

function Check-Chocolatey {
    Param(
        [switch] $Force
    )
    if(-not $env:ChocolateyInstall -or -not (Test-Path "$env:ChocolateyInstall")){
        $message = "Chocolatey is going to be downloaded and installed on your machine. If you do not have the .NET Framework Version 4 or greater, that will also be downloaded and installed."
        Write-Host $message
        if($Force -OR (Confirm-Install)){
            $exitCode = Enable-Net40
            if($exitCode -ne 0) {
                Write-Warning ".net install returned $exitCode. You likely need to reboot your computer before proceeding with the install."
                return $false
            }
            $env:ChocolateyInstall = "$env:programdata\chocolatey"
            New-Item $env:ChocolateyInstall -Force -type directory | Out-Null
            $url="https://chocolatey.org/api/v2/package/chocolatey/"
            $wc=new-object net.webclient
            $wp=[system.net.WebProxy]::GetDefaultProxy()
            $wp.UseDefaultCredentials=$true
            $wc.Proxy=$wp
            iex ($wc.DownloadString("https://chocolatey.org/install.ps1"))
            $env:path="$env:path;$env:ChocolateyInstall\bin"
        }
        else{
            return $false
        }
    }
    return $true
}

function Is64Bit {  [IntPtr]::Size -eq 8  }

function Enable-Net40 {
    if(Is64Bit) {$fx="framework64"} else {$fx="framework"}
    if(!(test-path "$env:windir\Microsoft.Net\$fx\v4.0.30319")) {
        Write-Host "Downloading .net 4.5..."
        Get-HttpToFile "http://download.microsoft.com/download/b/a/4/ba4a7e71-2906-4b2d-a0e1-80cf16844f5f/dotnetfx45_full_x86_x64.exe" "$env:temp\net45.exe"
        Write-Host "Installing .net 4.5..."
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = "$env:temp\net45.exe"
        $pinfo.Verb="runas"
        $pinfo.Arguments = "/quiet /norestart /log $env:temp\net45.log"
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        $p.Start() | Out-Null
        $p.WaitForExit()
        $e = $p.ExitCode
        if($e -ne 0){
            Write-Host "Installer exited with $e"
        }
        return $e
    }
    return 0
}

function Get-HttpToFile ($url, $file){
    Write-Verbose "Downloading $url to $file"
    if(Test-Path $file){Remove-Item $file -Force}
    $downloader=new-object net.webclient
    $wp=[system.net.WebProxy]::GetDefaultProxy()
    $wp.UseDefaultCredentials=$true
    $downloader.Proxy=$wp
    try {
        $downloader.DownloadFile($url, $file)
    }
    catch{
        if($VerbosePreference -eq "Continue"){
            Write-Error $($_.Exception | fl * -Force | Out-String)
        }
        throw $_
    }
}

function Confirm-Install {
    $caption = "Installing Chocolatey"
    $message = "Do you want to proceed?"
    $yes = new-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Yes";
    $no = new-Object System.Management.Automation.Host.ChoiceDescription "&No","No";
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no);
    $answer = $host.ui.PromptForChoice($caption,$message,$choices,0)

    switch ($answer){
        0 {return $true; break}
        1 {return $false; break}
    }
}

function Test-Admin {
    $identity  = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal( $identity )
    return $principal.IsInRole( [System.Security.Principal.WindowsBuiltInRole]::Administrator )
}