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

get_length() {
    local STR=$1
    local zero='%([BSUbfksu]|([FB]|){*})'
    local LENGTH=${#${(S%%)STR//$~zero/}}
    echo $LENGTH
}

# This is a magical method that generates the padding
# Based on a similar method from bureau
# The two arguments are the left- and right- aligned portions of the prompt
get_space() {
    local LENGTH=`get_length $1$2`
    local SPACES=""
    (( LENGTH = ${COLUMNS} - $LENGTH - 2))

    for i in {0..$LENGTH}
      do
        SPACES="$SPACES─"
      done

    echo $SPACES
}

local red="%{$FG[124]%}"
local green="%{$FG[040]%}"
local blue="%{$FG[033]%}"
local yellow="%{$terminfo[bold]$FG[226]%}"
local purple="%{$FG[127]%}"
local purple2="%{$FG[128]%}"
local orange="%{$FG[202]%}"
local darkgray="%{$FG[239]%}"
local resetcolor="%{$reset_color%}"

local username="${green}%n${resetcolor}"
local machine=" ${darkgray}@${resetcolor} ${blue}$(box_name)${resetcolor}"
local directory=" ${darkgray}:${resetcolor} ${orange}%~${resetcolor}"
local shortDirectory=" ${darkgray}:${resetcolor} ${orange}../%1~${resetcolor}"
local weekday="${purple2}%D{%A}${resetcolor}"
local date="${purple2}%D{%Y-%m-%d}${resetcolor}"
local time="${purple}%D{%r}${resetcolor}"

# If current directory is within a git repo, show:
#   ± branchname[✔] : Clean
#   ± branchname[✘] : Dirty
ZSH_THEME_GIT_PROMPT_PREFIX=" ${darkgray}±${resetcolor} ${blue}"
ZSH_THEME_GIT_PROMPT_SUFFIX="${resetcolor}"
ZSH_THEME_GIT_PROMPT_DIRTY="${darkgray}[${yellow}✘${darkgray}]"
ZSH_THEME_GIT_PROMPT_CLEAN="${darkgray}[${green}✔${darkgray}]"

function isInP4Workspace {
    local P4_FOUND
    P4_FOUND=$(which p4 2>&1)
    if [ ${P4_FOUND/"not found"} = $P4_FOUND ] ; then
        local P4_STATUS
        P4_STATUS=$(p4 opened ./... 2>&1)
        if [ ${P4_STATUS/"unknown - use 'client' command to create it."} = $P4_STATUS ] ; then
            if [ ${P4_STATUS/"Perforce client error:"} = $P4_STATUS ] ; then
                if [ ${P4_STATUS/"is not under client's root"} = $P4_STATUS ] ; then
                    return 0
                fi
            fi
        fi
    fi
    return 1
}

# If current directory is within a P4 workspace, show:
#   ⍚ [✔] : Has no opened files at/below current directory
#   ⍚ [✘] : Has opened files at/below current directory
function p4_prompt {
    if isInP4Workspace ; then
        local P4_STATUS
        P4_STATUS=$(p4 opened ./... 2>&1)
        if [ ${P4_STATUS/"file(s) not opened on this client."} = $P4_STATUS ] ; then
            # This means there are changes in this workspace
            P4_STATUS_ICON="${yellow}✘"
        else
            # This means there are no changes in this workspace
            P4_STATUS_ICON="${green}✔"
        fi
        echo " ${darkgray}⍚${resetcolor} ${darkgray}[${P4_STATUS_ICON}${darkgray}]${resetcolor}"
    fi
}

donatello_precmd () {
    # Default longest prompt option
    PROMPT_LEFT_SIDE="${darkgray}╭─${resetcolor} ${username}${machine}${directory}$(p4_prompt)$(git_prompt_info) ${darkgray}"
    PROMPT_RIGHT_SIDE="${resetcolor} $weekday $date $time ${darkgray}─○${resetcolor}"

    local TIMES_PROMPT_ABBREVIATED
    local USABLE_COLUMNS
    ((TIMES_PROMPT_ABBREVIATED = 0))
    ((USABLE_COLUMNS = ${COLUMNS} - 2))
    while [ $TIMES_PROMPT_ABBREVIATED -lt 9 ] && [ `get_length $PROMPT_LEFT_SIDE$PROMPT_RIGHT_SIDE` -gt $USABLE_COLUMNS ]; do
        if [ $TIMES_PROMPT_ABBREVIATED -eq 0 ]; then
            PROMPT_RIGHT_SIDE="${resetcolor} $date $time ${darkgray}─○${resetcolor}"
        elif [ $TIMES_PROMPT_ABBREVIATED -eq 1 ]; then
            PROMPT_RIGHT_SIDE="${resetcolor} $time ${darkgray}─○${resetcolor}"
        elif [ $TIMES_PROMPT_ABBREVIATED -eq 2 ]; then
            PROMPT_LEFT_SIDE="${darkgray}╭─${resetcolor} ${username}${directory}$(p4_prompt)$(git_prompt_info) ${darkgray}"
        elif [ $TIMES_PROMPT_ABBREVIATED -eq 3 ]; then
            PROMPT_RIGHT_SIDE="${resetcolor}${darkgray}─○${resetcolor}"
        elif [ $TIMES_PROMPT_ABBREVIATED -eq 4 ]; then
            # Reset and use short directory
            PROMPT_LEFT_SIDE="${darkgray}╭─${resetcolor} ${username}${machine}${shortDirectory}$(p4_prompt)$(git_prompt_info) ${darkgray}"
            PROMPT_RIGHT_SIDE="${resetcolor} $weekday $date $time ${darkgray}─○${resetcolor}"
        elif [ $TIMES_PROMPT_ABBREVIATED -eq 5 ]; then
            PROMPT_RIGHT_SIDE="${resetcolor} $date $time ${darkgray}─○${resetcolor}"
        elif [ $TIMES_PROMPT_ABBREVIATED -eq 6 ]; then
            PROMPT_RIGHT_SIDE="${resetcolor} $time ${darkgray}─○${resetcolor}"
        elif [ $TIMES_PROMPT_ABBREVIATED -eq 7 ]; then
            PROMPT_LEFT_SIDE="${darkgray}╭─${resetcolor} ${username}${shortDirectory}$(p4_prompt)$(git_prompt_info) ${darkgray}"
        elif [ $TIMES_PROMPT_ABBREVIATED -eq 8 ]; then
            PROMPT_RIGHT_SIDE="${resetcolor}${darkgray}─○${resetcolor}"
        fi
        ((TIMES_PROMPT_ABBREVIATED = $TIMES_PROMPT_ABBREVIATED + 1))
    done
    PROMPT_PADDING=`get_space $PROMPT_LEFT_SIDE $PROMPT_RIGHT_SIDE`
    echo
}

setopt prompt_subst
PROMPT='$PROMPT_LEFT_SIDE$PROMPT_PADDING$PROMPT_RIGHT_SIDE
${darkgray}╰○${resetcolor} '

autoload -U add-zsh-hook
add-zsh-hook precmd donatello_precmd
