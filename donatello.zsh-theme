# Donatello theme by Brad Buchanan (http://bradleycbuchanan.com)
#   based on Fino-time theme by Aexander Berezovsky (http://berezovsky.me)
#   based on Fino by Max Masnick (http://max.masnick.me)
#   Also borrowing heavily from 
#     bira
#     bureau
#     robbyrussell
#     http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
#
# Use with a dark background and 256-color terminal!
#
# You can set your computer name in the ~/.box-name file if you want.

function box_name {
    [ -f ~/.box-name ] && cat ~/.box-name || hostname -s
}

# This is a magical method that generates the padding
# Based on a similar method from bureau
# The two arguments are the left- and right- aligned portions of the prompt
get_space() {
    local STR=$1$2
    local zero='%([BSUbfksu]|([FB]|){*})'
    local LENGTH=${#${(S%%)STR//$~zero/}}
    local SPACES=""
    (( LENGTH = ${COLUMNS} - $LENGTH - 2))

    for i in {0..$LENGTH}
      do
        SPACES="$SPACES─"
      done

    echo $SPACES
}

local green="%{$FG[040]%}"
local blue="%{$FG[033]%}"
local yellow="%{$terminfo[bold]$FG[226]%}"
local purple="%{$FG[091]%}"
local orange="%{$FG[202]%}"
local darkgray="%{$FG[239]%}"
local resetcolor="%{$reset_color%}"

local username="${green}%n${resetcolor}"
local machine=" ${darkgray}@${resetcolor} ${blue}$(box_name)${resetcolor}"
local directory=" ${darkgray}:${resetcolor} ${yellow}%~${resetcolor}"
local timestamp="${purple}%D{%A %Y-%m-%d %T}${resetcolor}"

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$FG[239]%}⌘ %{$reset_color%} %{$fg[255]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$FG[239]%}[%{$FG[202]%}✘%{$FG[239]%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$FG[239]%}[%{$FG[040]%}✔%{$FG[239]%}]"

PROMPT_LEFT_SIDE="${darkgray}╭─${resetcolor} ${username}${machine}${directory}$(git_prompt_info) ${darkgray}"
PROMPT_RIGHT_SIDE="${resetcolor} $timestamp ${darkgray}─○${resetcolor}"

donatello_precmd () {
    PROMPT_PADDING=`get_space $PROMPT_LEFT_SIDE $PROMPT_RIGHT_SIDE`
    echo
}

setopt prompt_subst
PROMPT='$PROMPT_LEFT_SIDE$PROMPT_PADDING$PROMPT_RIGHT_SIDE
${darkgray}╰○${resetcolor} '

autoload -U add-zsh-hook
add-zsh-hook precmd donatello_precmd
