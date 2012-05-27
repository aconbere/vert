# This file must be used with "source bin/activate" *from bash*
# you cannot run it directly

deactivate () {
    # reset old environment variables
    if [ -n "$_OLD_VERT_PATH" ] ; then
        PATH="$_OLD_VERT_PATH"
        export PATH
        unset _OLD_VERT_PATH
    fi

    if [ -n "$_OLD_VERT_LUA_PATH" ] ; then
        LUA_PATH="$_OLD_VERT_LUA_PATH"
        export LUA_PATH
        unset _OLD_VERT_LUA_PATH
    fi

    if [ -n "$_OLD_VERT_LUA_CPATH" ] ; then
        LUA_CPATH="$_OLD_VERT_LUA_CPATH"
        export LUA_CPATH
        unset _OLD_VERT_LUA_CPATH
    fi

    # This should detect bash and zsh, which have a hash command that must
    # be called to get it to forget past commands.  Without forgetting
    # past commands the $PATH changes we made may not be respected
    if [ -n "$BASH" -o -n "$ZSH_VERSION" ] ; then
        hash -r
    fi

    if [ -n "$_OLD_VERT_PS1" ] ; then
        PS1="$_OLD_VERT_PS1"
        export PS1
        unset _OLD_VERT_PS1
    fi

    unset VERT_ENV
    if [ ! "$1" = "nondestructive" ] ; then
    # Self destruct!
        unset -f deactivate
    fi
}

# unset irrelavent variables
deactivate nondestructive

VERT_ENV="/home/aconbere/Projects/lua/vert"
export VERT_ENV

_OLD_VERT_PATH="$PATH"
PATH="$VERT_ENV/bin:$PATH"
export PATH

# unset LUA_PATH if set
# this will fail if LUA_PATH is set to the empty string (which is bad anyway)
# could use `if (set -u; : $LUA_PATH) ;` in bash
if [ -n "$LUA_PATH" ] ; then
    _OLD_VERT_LUA_PATH="$LUA_PATH"
    unset LUA_PATH
fi

if [ -n "$LUA_CPATH" ] ; then
    _OLD_VERT_LUA_CPATH="$LUA_CPATH"
    unset LUA_CPATH
fi

LUA_PATH="/home/aconbere/Projects/lua/vert/share/lua/5.1//?.lua;/home/aconbere/Projects/lua/vert/lib/luarocks/?.lua"
export LUA_PATH

LUA_CPATH="/home/aconbere/Projects/lua/vert/share/lua/5.1//?.lua;/home/aconbere/Projects/lua/vert/lib/luarocks/?.lua"
export LUA_CPATH

if [ -z "$VERT_ENV_DISABLE_PROMPT" ] ; then
    _OLD_VERT_PS1="$PS1"
    if [ "x" != x ] ; then
	PS1="$PS1"
    else
    if [ "`basename \"$VERT_ENV\"`" = "__" ] ; then
        # special case for Aspen magic directories
        # see http://www.zetadev.com/software/aspen/
        PS1="[`basename \`dirname \"$VERT_ENV\"\``] $PS1"
    else
        PS1="(`basename \"$VERT_ENV\"`)$PS1"
    fi
    fi
    export PS1
fi

# This should detect bash and zsh, which have a hash command that must
# be called to get it to forget past commands.  Without forgetting
# past commands the $PATH changes we made may not be respected
if [ -n "$BASH" -o -n "$ZSH_VERSION" ] ; then
    hash -r
fi
