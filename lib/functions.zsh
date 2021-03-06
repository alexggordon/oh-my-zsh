function zsh_stats() {
  fc -l 1 | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n20
}

function hopa() {
  cleansed=`echo $1 | tr  "-"  "."`
  ssh -A -t $(whoami)@admin01.iad.sessionm.com ssh -A $(whoami)@$cleansed
}

function hopie() {
  cleansed=`echo $1 | tr  "-"  "."`
  ssh -A -t $(whoami)@jump.ent-ie.local ssh -A $(whoami)@$cleansed
}

function hopsg() {
  cleansed=`echo $1 | tr  "-"  "."`
  ssh -A -t $(whoami)@jump.ent-sg.local ssh -A $(whoami)@$cleansed
}

function hop() {
  cleansed=`echo $1 | tr  "-"  "."`
  ssh -A -t $(whoami)@jump.sessionm.local ssh -A $(whoami)@$cleansed
}

function gsubl() {
  subl $(git diff --name-only HEAD | tr '\n' ' ')
}

function transfer() {
    # check arguments
    if [ $# -eq 0 ];
    then
        echo "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"
        return 1
    fi

    # get temporarily filename, output is written to this file show progress can be showed
    tmpfile=$( mktemp -t transferXXX )

    # upload stdin or file
    file=$1

    if tty -s;
    then
        basefile=$(basename "$file" | sed -e 's/[^a-zA-Z0-9._-]/-/g')

        if [ ! -e $file ];
        then
            echo "File $file doesn't exists."
            return 1
        fi

        if [ -d $file ];
        then
            # zip directory and transfer
            zipfile=$( mktemp -t transferXXX.zip )
            cd $(dirname $file) && zip -r -q - $(basename $file) >> $zipfile
            curl --progress-bar --upload-file "$zipfile" "https://transfer.sh/$basefile.zip" >> $tmpfile
            rm -f $zipfile
        else
            # transfer file
            curl --progress-bar --upload-file "$file" "https://transfer.sh/$basefile" >> $tmpfile
        fi
    else
        # transfer pipe
        curl --progress-bar --upload-file "-" "https://transfer.sh/$file" >> $tmpfile
    fi

    # cat output link
    cat $tmpfile

    # cleanup
    rm -f $tmpfile
}


function uninstall_oh_my_zsh() {
  /usr/bin/env ZSH=$ZSH /bin/sh $ZSH/tools/uninstall.sh
}

function upgrade_oh_my_zsh() {
  /usr/bin/env ZSH=$ZSH /bin/sh $ZSH/tools/upgrade.sh
}

function take() {
  mkdir -p $1
  cd $1
}

function fast-rspec() {
  RUBY_GC_MALLOC_LIMIT=700000000 RUBY_GC_HEAP_FREE_SLOTS=500000 RUBY_GC_HEAP_INIT_SLOTS=40000 rspec --format Fuubar --color $*

}

function app() {
  cd ~/Documents/SessionM/Work/$1;
  git status;
}
compctl -W ~/Documents/SessionM/work -/ app

function dev() {
  cd ~/Documents/SessionM/work/$1;
  git status;
  sublime ~/Documents/SessionM/work/$1;
}
compctl -W ~/Documents/SessionM/work -/ dev

function stash() {
  if [[ $1 = "-p" ]]; then
    if [[ $2 -eq 0 ]]; then
      open -a /Applications/Google\ Chrome.app $(echo "https://stash.o.sessionm.com/projects/PLAT/repos/greyhound/pull-requests?create&targetBranch=refs%2Fheads%2Fmaster&sourceBranch=refs%2Fheads%2F")$(git rev-parse --abbrev-ref HEAD) &> /dev/null;
    else
      open -a /Applications/Google\ Chrome.app $(echo "https://stash.o.sessionm.com/projects/PLAT/repos/greyhound/pull-requests?create&targetBranch=refs%2Fheads%2Fmaster&sourceBranch=refs%2Fheads%2F$2") &> /dev/null;
    fi
  else
    open -a /Applications/Google\ Chrome.app $(echo "https://stash.o.sessionm.com/projects/PLAT/repos/greyhound/compare/commits?sourceBranch=refs%2Fheads%2F")$(git rev-parse --abbrev-ref HEAD) &> /dev/null;
  fi
}

function github-create() {
  repo_name=$1

  dir_name=`basename $(pwd)`
  invalid_credentials=0

  if [ "$repo_name" = "" ]; then
    echo "  Repo name (hit enter to use '$dir_name')?"
    read repo_name
  fi

  if [ "$repo_name" = "" ]; then
    repo_name=$dir_name
  fi

  username=`git config github.user`
  if [ "$username" = "" ]; then
    echo "  Could not find username, run 'git config --global github.user <username>'"
    invalid_credentials=1
  fi

  token=`git config github.token`
  if [ "$token" = "" ]; then
    echo "  Could not find token, run 'git config --global github.token <token>'"
    invalid_credentials=1
  fi

  if [ "$invalid_credentials" -eq "1" ]; then
    return 1
  fi

  echo -n "  Creating Github repository '$repo_name' ..."
  curl -u "$username:$token" https://api.github.com/user/repos -d '{"name":"'$repo_name'"}' > /dev/null 2>&1
  echo " done."

  echo -n "  Pushing local code to remote ..."
  git remote add origin git@github.com:$username/$repo_name.git > /dev/null 2>&1
  git push -u origin master > /dev/null 2>&1
  echo " done."
}


#
# Get the value of an alias.
#
# Arguments:
#    1. alias - The alias to get its value from
# STDOUT:
#    The value of alias $1 (if it has one).
# Return value:
#    0 if the alias was found,
#    1 if it does not exist
#
function alias_value() {
    alias "$1" | sed "s/^$1='\(.*\)'$/\1/"
    test $(alias "$1")
}

function extract {
  echo Extracting $1 ...
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xjf $1  ;;
          *.tar.gz)    tar xzf $1  ;;
          *.bz2)       bunzip2 $1  ;;
          *.rar)       unrar x $1    ;;
          *.gz)        gunzip $1   ;;
          *.tar)       tar xf $1   ;;
          *.tbz2)      tar xjf $1  ;;
          *.tgz)       tar xzf $1  ;;
          *.zip)       unzip $1   ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1  ;;
          *)        echo "'$1' cannot be extracted via extract()" ;;
      esac
  else
      echo "'$1' is not a valid file"
  fi
}

#
# Try to get the value of an alias,
# otherwise return the input.
#
# Arguments:
#    1. alias - The alias to get its value from
# STDOUT:
#    The value of alias $1, or $1 if there is no alias $1.
# Return value:
#    Always 0
#
function try_alias_value() {
    alias_value "$1" || echo "$1"
}

#
# Set variable "$1" to default value "$2" if "$1" is not yet defined.
#
# Arguments:
#    1. name - The variable to set
#    2. val  - The default value
# Return value:
#    0 if the variable exists, 3 if it was set
#
function default() {
    test `typeset +m "$1"` && return 0
    typeset -g "$1"="$2"   && return 3
}

#
# Set enviroment variable "$1" to default value "$2" if "$1" is not yet defined.
#
# Arguments:
#    1. name - The env variable to set
#    2. val  - The default value
# Return value:
#    0 if the env variable exists, 3 if it was set
#
function env_default() {
    env | grep -q "^$1=" && return 0
    export "$1=$2"       && return 3
}
