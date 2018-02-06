If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Please re-run this script as an Administrator"
    Break
}

Set-ExecutionPolicy Unrestricted

#######################################
# chain install some package managers #
#######################################

Install-Module -Name NuGet
Install-Package chocolatey

#######################
# chocolatey packages #
#######################

choco install -y git
choco install -y poshgit
choco install -y notepadplusplus
choco install -y 7zip
choco install -y gow
choco install -y visualstudiocode
choco install -y vscode-csharp vscode-gitlens
choco install -y dotnetcore-sdk
choco install -y openssh

###############
# other setup #
###############

cd ~/Downloads
(New-Object System.Net.WebClient).DownloadFile('https://github.com/git-duet/git-duet/releases/download/0.5.2/windows_amd64.tar.gz', "$env:HomePath\\Downloads\\git-duet-amd64.tar.gz")
set-alias 7z "$env:ProgramFiles\7-Zip\7z.exe"
7z x git-duet-amd64.tar.gz git-duet-amd64.tar
7z x git-duet-amd64.tar -o"$env:ProgramFiles\Git\cmd"

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