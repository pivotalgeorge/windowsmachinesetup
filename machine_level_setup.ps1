param([Boolean]$silent=$false)

$start_dir = $pwd
$CHOCOLATEY_THUMBPRINT = "4BF7DCBC06F6D0BDFA8A0A78DE0EFB62563C4D87"
$EXITCODE_NOTADMIN = 1
$EXITCODE_EXCEPTION = 2

function KeypressToExit($code = 0) {
    If ($silent) {
        break;
    }
    Write-Host -NoNewLine 'Press any key to exit...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    exit $code
}

#######################
# wait for user input #
#######################

if (-not ([security.principal.windowsprincipal] [security.principal.windowsidentity]::getcurrent()).isinrole(
    [security.principal.windowsbuiltinrole] "administrator"))
{
    write-warning "This script should be run as an administrator."
    KeypressToExit $EXITCODE_NOTADMIN
}

try
    {
    Set-ExecutionPolicy Unrestricted                 # Set policy for machine scope
    Set-ExecutionPolicy Unrestricted -Scope Process  # Ensures policy setting for this script

    ##############################
    # create install temp folder #
    ##############################

    $setup_files_dir_name = "windows-machine-setup-files"

    cd $env:UserProfile/Downloads/
    (Remove-Item -Recurse -Force $setup_files_dir_name) 2> $null
    mkdir $setup_files_dir_name
    pushd $setup_files_dir_name



    ##########################################
    # install the chocolatey package manager #
    ##########################################

    # use system proxy and download chocolatey isntall script
    [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
    $script = (New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')

    # validate contents of chocolatey install script
    $encoding = [system.Text.Encoding]::UTF8
    $script_data = $encoding.GetBytes($script)
    $script_thumbprint = (Get-AuthenticodeSignature -SourcePathOrExtension .ps1 -Content $script_data).SignerCertificate.Thumbprint


    if ($script_thumbprint -ne $CHOCOLATEY_THUMBPRINT) {
        Write-Warning 'FAILURE. Thumbprint of script does not match Chocolatey thumbprint.
    Please check at https://chocolatey.org/security#chocolatey-binaries-and-the-chocolatey-package'
        exit $EXITCODE_EXCEPTION
    }

    iex $script

    #######################
    # chocolatey packages #
    #######################

    choco install -y git
    choco install -y notepadplusplus
    choco install -y 7zip
    choco install -y gow
    choco install -y visualstudiocode
    choco install -y vscode-csharp vscode-gitlens
    choco install -y dotnetcore-sdk
    choco install -y openssh
    choco install -y conemu

    ##################
    # other packages #
    ##################

    Install-PackageProvider -Name NuGet -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted  # Needed to avoid prompts.
    PowerShellGet\Install-Module posh-git -Scope AllUsers

    ###############
    # other setup #
    ###############

    cd ~/downloads
    (new-object system.net.webclient).downloadfile('https://github.com/git-duet/git-duet/releases/download/0.6.0/windows_amd64.tar.gz', "$env:homepath\\downloads\\git-duet-amd64.tar.gz")
    set-alias 7z "$env:programfiles\7-zip\7z.exe"
    # extract and say yes to prompts
    7z x -y git-duet-amd64.tar.gz git-duet-amd64.tar
    7z x -y git-duet-amd64.tar -o"$env:programfiles\git\cmd"

    ###################
    # git duet config #
    ###################

    [Environment]::SetEnvironmentVariable("GIT_DUET_CO_AUTHORED_BY", 1, "Machine")
    [Environment]::SetEnvironmentVariable("GIT_DUET_GLOBAL", $true, "Machine")


}
catch {
    Write-Warning ""
    Write-Warning "Something broke :("
    Write-Warning ""
    Write-Error $_.Exception
    KeypressToExit $EXITCODE_EXCEPTION
}
