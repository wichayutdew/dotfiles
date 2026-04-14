# Prerequisites to clone the repo
  ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install --cask 1password
  ```
  - Login to 1Password, then clone this Repo

# Device Setup
  - Starts with `cd .config`
  - run `bash setup.sh`
  - restart terminal to make Fish default sh
  - run `fish init.fish`
  - to add env variable, add `set -gx SECRET_NAME ${SECRET}` to `/Users/wphongphanpa/.config/fish/conf.d/environment.fish`

# Device config
  - cmd+` = change language
  - cmd+space = Raycast
  - Hot corner bottom right = show desktop

# Browser Extension
- Vimium keymap
```
unmap J
unmap K
map J nextTab
map K previousTab
unmap <c-e>
unmap <c-y>
unmap d
unmap u
map <c-d> scrollPageDown
map <c-u> scrollPageUp
unmap x
map d removeTab
unmap gt
unmap gT
unmap b
unmap B
```
