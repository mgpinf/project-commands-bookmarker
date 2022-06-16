# flags:
# @harsha
# marking
# adding

# @manish
# selecting
function pcbs() {
  local prefix="$HOME/.pcb"
  local pcbFile='.pcbfile'
  local curDir=$PWD
  local resFilePath

  # if current working directory beyond $HOME, return
  [[ $curDir == $HOME* ]] || return

  # remove $HOME prefix
  curDir=${curDir#"$HOME"}

  [[ $curDir[1] == '/' ]] || curDir='/'$curDir

  while [[ -n $curDir ]] && [[ ! -f $prefix$curDir'/'$pcbFile ]]
  do
    # remove last part of current directory
    curDir=${curDir%/*}
    [[ -z $curDir ]] && break
  done

  if [[ -n $curDir ]]
  then
    curDir="${curDir:1}"
    resFilePath="$prefix/$curDir/$pcbFile"
  else
    resFilePath="$prefix/$pcbFile"
  fi

  if [[ ! -s $resFilePath ]]
  then
    echo 'Nothing to show'
    return
  fi

  local command=$(cat --number $resFilePath | awk '{$1=$1;print}' | fzf --layout=reverse)
  [[ -z $command ]] && return

  local regex='s/^\w*\ *//'
  command=$(echo $command | sed -e $regex)
  eval $command
}

# deleting
function pcbd() {
  local prefix="$HOME/.pcb"
  local pcbFile='.pcbfile'
  local curDir=$PWD
  local resFilePath

  # if current working directory beyond $HOME, return
  [[ $curDir == $HOME* ]] || return

  # remove $HOME prefix
  curDir=${curDir#"$HOME"}

  [[ $curDir[1] == '/' ]] || curDir='/'$curDir

  while [[ -n $curDir ]] && [[ ! -f $prefix$curDir'/'$pcbFile ]]
  do
    # remove last part of current directory
    curDir=${curDir%/*}
    [[ -z $curDir ]] && break
  done

  if [[ -n $curDir ]]
  then
    curDir="${curDir:1}"
    resFilePath="$prefix/$curDir/$pcbFile"
  else
    resFilePath="$prefix/$pcbFile"
  fi

  if [[ ! -s $resFilePath ]]
  then
    echo 'Nothing to show'
    return
  fi

  local command=$(cat --number $resFilePath | awk '{$1=$1;print}' | fzf --layout=reverse)
  [[ -z $command ]] && return
  local regex='s/^([^.]+).*$/\1/; s/^[^0-9]*([0-9]+).*$/\1/'
  command=$(echo $command | sed -r $regex)
  sed -i "${command}d" $resFilePath
}
