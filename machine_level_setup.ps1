param([Boolean]$silent=$false)

function KeypressToContinue() {
    If ($silent) {
        break;
    }
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

#######################
# wait for user input #
#######################

if (-not ([security.principal.windowsprincipal] [security.principal.windowsidentity]::getcurrent()).isinrole(
    [security.principal.windowsbuiltinrole] "administrator"))
{
    write-warning "Re-run this script as an administrator."
    KeypressToContinue
    break
}

set-executionpolicy unrestricted

#######################################
# chain install some package managers #
#######################################

install-module -name nuget
install-package chocolatey

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

##################
# other packages #
##################
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted  # Needed to avoid prompts.
PowerShellGet\Install-Module posh-git -Scope AllUsers

###############
# other setup #
###############

cd ~/downloads
(new-object system.net.webclient).downloadfile('https://github.com/git-duet/git-duet/releases/download/0.5.2/windows_amd64.tar.gz', "$env:homepath\\downloads\\git-duet-amd64.tar.gz")
set-alias 7z "$env:programfiles\7-zip\7z.exe"
# extract and say yes to prompts
7z x -y git-duet-amd64.tar.gz git-duet-amd64.tar
7z x -y git-duet-amd64.tar -o"$env:programfiles\git\cmd"

###############
# git aliases #
###############

set-alias git "$env:ProgramFiles\Git\cmd\git.exe"

git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.st status
git config --global alias.ci duet-commit
git config --global alias.lola "log --graph --decorate --pretty=oneline --abbrev-commit --all"
git config --global alias.lol "log --graph --decorate --pretty=oneline --abbrev-commit"

#######################
# wait for user input #
#######################
KeypressToContinue