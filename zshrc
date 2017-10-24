export ZSH=~/.zsh
ENABLE_CORRECTION=true
COMPLETION_WAITING_DOTS=true

if [[ -z "$ZSH_CACHE_DIR" ]]; then
  ZSH_CACHE_DIR="$ZSH/cache"
fi

# Load all stock functions (from $fpath files) called below.
autoload -U compaudit compinit
: ${ZSH_DISABLE_COMPFIX:=true}

# Load all of the config files in $ZSH that end in .zsh
for config_file ($ZSH/lib/*.zsh); do
  source $config_file
done

plugins=(colored-man-pages zsh-syntax-highlighting)

is_plugin() {
  local base_dir=$1
  local name=$2
  test -f $base_dir/plugins/$name/$name.plugin.zsh \
    || test -f $base_dir/plugins/$name/_$name
}

# Add all defined plugins to fpath. This must be done
# before running compinit.
for plugin ($plugins); do
  if is_plugin $ZSH $plugin; then
    fpath=($ZSH/plugins/$plugin $fpath)
  fi
done

if [ -z "$ZSH_COMPDUMP" ]; then
  ZSH_COMPDUMP="${ZDOTDIR:-${HOME}}/.zcompdump-${SHORT_HOST}-${ZSH_VERSION}"
fi

if [[ $ZSH_DISABLE_COMPFIX != true ]]; then
  # If completion insecurities exist, warn the user without enabling completions.
  if ! compaudit &>/dev/null; then
    # This function resides in the "lib/compfix.zsh" script sourced above.
    handle_completion_insecurities
  # Else, enable and cache completions to the desired file.
  else
    compinit -d "${ZSH_COMPDUMP}"
  fi
else
  compinit -i -d "${ZSH_COMPDUMP}"
fi
#
# Load all of the plugins that were defined in ~/.zshrc
for plugin ($plugins); do
  if [ -f $ZSH/plugins/$plugin/$plugin.plugin.zsh ]; then
    source $ZSH/plugins/$plugin/$plugin.plugin.zsh
  fi
done

local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
function prompt_char {
  if [ $UID -eq 0 ]; then echo "#"; else echo $; fi
}
PROMPT='${ret_status}% %{$fg_bold[red]%}%{$fg_bold[green]%}%m %{$fg[yellow]%}%~ $(git_prompt_info)%{$fg[yellow]%}$(prompt_char) %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

if [ -f ~/.aliases ]; then
  source ~/.aliases
fi

if [ -f ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
