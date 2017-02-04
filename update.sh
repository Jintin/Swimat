# install and setup script - only needed once
brew install vitorgalvao/tiny-scripts/cask-repair
cask-repair --help

# fork homebrew-cask to your account - only needed once
cd "$(brew --repository)/Library/Taps/caskroom/homebrew-cask/Casks"
git config --local hub.protocol https
hub fork

# use to update <outdated_cask>
outdated_cask='<the-cask-i-want-to-update>'
github_user='<my-github-username>'
cd "$(brew --repository)/Library/Taps/caskroom/homebrew-cask/Casks"

cask-repair --pull origin --push $github_user $outdated_cask
