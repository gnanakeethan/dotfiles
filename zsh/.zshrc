# # If you come from bash you might have to change your $PATH.
# # export PATH=$HOME/bin:/usr/local/bin:$PATH
# # Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
#
# # Set name of the theme to load --- if set to "random", it will
# # load a random theme each time oh-my-zsh is loaded, in which case,
# # to know which specific one was loaded, run: echo $RANDOM_THEME
# # See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="spaceship"
#
# # Set list of themes to pick from when loading at random
# # Setting this variable when ZSH_THEME=random will cause zsh to load
# # a theme from this variable instead of looking in $ZSH/themes/
# # If set to an empty array, this variable will have no effect.
# # ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
#
# # Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"
#
# # Uncomment the following line to use hyphen-insensitive completion.
# # Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"
#
# # Uncomment one of the following lines to change the auto-update behavior
# # zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# # zstyle ':omz:update' mode reminder  # just remind me to update when it's time
#
# # Uncomment the following line to change how often to auto-update (in days).
# # zstyle ':omz:update' frequency 13
#
# # Uncomment the following line if pasting URLs and other text is messed up.
# # DISABLE_MAGIC_FUNCTIONS="true"
#
# # Uncomment the following line to disable colors in ls.
# # DISABLE_LS_COLORS="true"
#
# # Uncomment the following line to disable auto-setting terminal title.
# # DISABLE_AUTO_TITLE="true"
#
# # Uncomment the following line to enable command auto-correction.
# # ENABLE_CORRECTION="true"
#
# # Uncomment the following line to display red dots whilst waiting for completion.
# # You can also set it to another string to have that shown instead of the default red dots.
# # e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# # Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"
#
# # Uncomment the following line if you want to disable marking untracked files
# # under VCS as dirty. This makes repository status check for large repositories
# # much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"
#
# # Uncomment the following line if you want to change the command execution time
# # stamp shown in the history command output.
# # You can set one of the optional three formats:
# # "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# # or set a custom format using the strftime function format specifications,
# # see 'man strftime' for details.
HIST_STAMPS="mm/dd/yyyy"
HISTFILE="$HOME/.zshhistory"
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.
#
#
#
# # Would you like to use another custom folder than $ZSH/custom?
# # ZSH_CUSTOM=/path/to/new-custom-folder
#
# # Which plugins would you like to load?
# # Standard plugins can be found in $ZSH/plugins/
# # Custom plugins may be added to $ZSH_CUSTOM/plugins/
# # Example format: plugins=(rails git textmate ruby lighthouse)
# # Add wisely, as too many plugins slow down shell startup.
# #bindkey '^J' autosuggest-accept
plugins=(autojump aws laravel5 common-aliases git-extras git-flow-avh npm git sudo macos gitfast brew vagrant composer)
#
source $ZSH/oh-my-zsh.sh
#
# # User configuration
#
# # export MANPATH="/usr/local/man:$MANPATH"
#
# # You may need to manually set your language environment
# # export LANG=en_US.UTF-8
#
# # Preferred editor for local and remote sessions
# # if [[ -n $SSH_CONNECTION ]]; then
# #   export EDITOR='vim'
# # else
# #   export EDITOR='mvim'
# # fi
#
# # Compilation flags
# # export ARCHFLAGS="-arch x86_64"
#
# # Set personal aliases, overriding those provided by oh-my-zsh libs,
# # plugins, and themes. Aliases can be placed here, though oh-my-zsh
# # users are encouraged to define aliases within the ZSH_CUSTOM folder.
# # For a full list of active aliases, run `alias`.
# #
# # Example aliases
# # alias zshconfig="mate ~/.zshrc"
# # alias ohmyzsh="mate ~/.oh-my-zsh"
#
# # User configuration
#
export ANDROID_HOME="$HOME/Library/Android/sdk"
export NODE_ENV="development"
export FLUTTER_ROOT=~/Library/Android/flutter
[[ -f ~/.zsh_secrets ]] && source ~/.zsh_secrets  # untracked: tokens live here
#
# # export MANPATH="/usr/local/man:$MANPATH"
#
# # You may need to manually set your language environment
export LANG=en_US.UTF-8
#
# # Preferred editor for local and remote sessions
export EDITOR='vim'
#
# # Compilation flags
# # export ARCHFLAGS="-arch x86_64"
#
# # ssh
# # export SSH_KEY_PATH="~/.ssh/dsa_id"
#
# # Set personal aliases, overriding those provided by oh-my-zsh libs,
# # plugins, and themes. Aliases can be placed here, though oh-my-zsh
# # users are encouraged to define aliases within the ZSH_CUSTOM folder.
# # For a full list of active aliases, run `alias`.
# #
# # Example aliases
# # alias zshconfig="mate ~/.zshrc"
# # alias ohmyzsh="mate ~/.oh-my-zsh"
#
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
#
#
#
# #"SOME VERY IMPORTANT ALIASES INDEED"
alias 'today=calendar -A 0 -f /usr/share/calendar/calendar.mark | sort'
alias 'dus=du -sckx * | sort -nr'
alias 'vima=vim --noplugin -nNu ~/.vimrc.blank'
alias 'mailsize=du -hs ~/Library/mail'
alias 'bk=cd $OLDPWD'
alias 'todo=todo.sh'
alias 'jk=todo.sh lsa'
alias 'adi=todo.sh add'
alias 'ado=todo.sh do'
alias 't=todo'
alias 'tl=todo list'
alias 'ttop=top -ocpu -R -F -s 2 -n30'
alias 'kb=kubectl'
alias lh='ls -a | egrep "^\."'
alias 'ggg=go generate ./...'
alias 'vim=nvim'
alias 'ff=vimf'
#
# test -e ${HOME}/.iterm2_shell_integration.zsh
# source ${HOME}/.iterm2_shell_integration.zsh
# # zsh: Place this in .zshrc after "source /Users/georgen/.iterm2_shell_integration.zsh".
# iterm2_print_user_vars() {
#     iterm2_set_user_var gitBranch $((git branch 2> /dev/null) | grep \* | cut -c3-)
# }
#
# # pnpm
# export PNPM_HOME="/Users/gnanakeethan/Library/pnpm"
# case ":$PATH:" in
#   *":$PNPM_HOME:"*) ;;
#   *) export PATH="$PNPM_HOME:$PATH" ;;
# esac
# # pnpm end
eval "$(direnv hook zsh)"
#
# # bun completions
[ -s "/Users/gnanakeethan/.bun/_bun" ] && source "/Users/gnanakeethan/.bun/_bun"
#
#
#
# # Load Angular CLI autocompletion.
# export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export PATH=$PATH:/opt/homebrew/bin
export PATH=$PATH:/opt/homebrew/opt/libpq/bin
export PATH=$PATH:/opt/homebrew/opt/python@3.13/libexec/bin
export PATH=/opt/homebrew/opt/curl/bin:$PATH
export PATH=$HOME/.local/bin:$PATH

source <(COMPLETE=zsh jj)

eval "$(starship init zsh)"

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
eval "$(ruby ~/.local/try.rb init ~/src/tries)"

# Added by Antigravity
export PATH="/Users/gnanakeethan/.antigravity/antigravity/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Added by Antigravity IDE
export PATH="/Users/gnanakeethan/.antigravity-ide/antigravity-ide/bin:$PATH"


alias claude-account1="CLAUDE_CONFIG_DIR=~/.claude-account1 command claude"
alias claude-account2="CLAUDE_CONFIG_DIR=~/.claude-account2 command claude"

alias nv1="CLAUDE_CONFIG_DIR=~/.claude-account1 nvim"
alias nv2="CLAUDE_CONFIG_DIR=~/.claude-account2 nvim"
