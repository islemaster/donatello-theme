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

# If current directory is within a git repo, show:
#   ± branchname[✔] : Clean
#   ± branchname[✘] : Dirty
ZSH_THEME_GIT_PROMPT_PREFIX=" ${darkgray}±${resetcolor} %{$fg[255]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="${resetcolor}"
ZSH_THEME_GIT_PROMPT_DIRTY="${darkgray}[${orange}✘${darkgray}]"
ZSH_THEME_GIT_PROMPT_CLEAN="${darkgray}[${green}✔${darkgray}]"

# If current directory is within a P4 workspace, show:
#   ⍚ [✔] : Has no opened files at/below current directory
#   ⍚ [✘] : Has opened files at/below current directory
function p4_prompt {
    P4_STATUS=$(p4 opened ./... 2>&1)
    if [ ${P4_STATUS/"unknown - use 'client' command to create it."} = $P4_STATUS ] ; then
        # This means we are in a P4 workspace
        if [ ${P4_STATUS/"file(s) not opened on this client."} = $P4_STATUS ] ; then
            # This means there are changes in this workspace
            P4_STATUS_ICON="${orange}✘"
        else
            # This means there are no changes in this workspace
            P4_STATUS_ICON="${green}✔"
        fi
        echo " ${darkgray}⍚${resetcolor} ${darkgray}[${P4_STATUS_ICON}${darkgray}]${resetcolor}"
    fi
}

donatello_precmd () {
    PROMPT_LEFT_SIDE="${darkgray}╭─${resetcolor} ${username}${machine}${directory}$(p4_prompt)$(git_prompt_info) ${darkgray}"
    PROMPT_RIGHT_SIDE="${resetcolor} $timestamp ${darkgray}─○${resetcolor}"
    PROMPT_PADDING=`get_space $PROMPT_LEFT_SIDE $PROMPT_RIGHT_SIDE`
    echo
}

setopt prompt_subst
PROMPT='$PROMPT_LEFT_SIDE$PROMPT_PADDING$PROMPT_RIGHT_SIDE
${darkgray}╰○${resetcolor} '

autoload -U add-zsh-hook
add-zsh-hook precmd donatello_precmd
