# need to re-source PATH since we're in an old terminal context 
# (that hasn't been updated after chocolatey installs)
& "$env:ProgramData\chocolatey\bin\refreshenv.CMD"

set-alias git "$env:ProgramFiles\Git\cmd\git.exe"

Add-PoshGitToProfile

###############
# git aliases #
###############

git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.st status
git config --global alias.ci commit
git config --global alias.lola "log --graph --decorate --pretty=oneline --abbrev-commit --all"
git config --global alias.lol "log --graph --decorate --pretty=oneline --abbrev-commit"
