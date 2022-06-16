# if $HOME/.pcb directory doesn't already exist, create it
[[ -d $HOME/.pcb ]] || mkdir $HOME/.pcb


# function to bookmark a directory as project (create .pcbfile in the copy of the directory relative to $HOME and then relative to $HOME/.pcb)
function pcbm() {
  local prefix="$HOME/.pcb"
  local projectDirectory=$PWD
  local favoritesDirectory="${prefix}/${projectDirectory#"$HOME/"}"
  local pcbCommandsFile='.pcbCommandsfile'
  local pcbDirsFile='.pcbDirsfile'
  mkdir -p "$favoritesDirectory"
  touch "$favoritesDirectory/$pcbCommandsFile"
  touch "$favoritesDirectory/$pcbDirsFile" && echo "Bookmarked directory as a Project"
}


# function to add a command to bookmarked commands
function pcba() {
  local prefix="$HOME/.pcb"
  local projectDirectory=$PWD
  local favoritesDirectory="${prefix}/${projectDirectory#"$HOME/"}"

  read command

  local temp1="${projectDirectory#"$HOME/"}"
  local temp2="/${temp1}"

  local pcbCommandsFile='.pcbCommandsfile'
  local pcbDirsFile='.pcbDirsfile'

  while [[ -n ${temp2} ]]
  do
    output=$(find ${prefix} -wholename "${prefix}${temp2}/${pcbCommandsFile}")
    [[ -n ${output} ]] && break
    temp2=${temp2%/*}
  done

  echo $command >> "${prefix}${temp2}/${pcbCommandsFile}"
  echo $(pwd) >> "${prefix}${temp2}/${pcbDirsFile}"
  echo "Successfully added command \"${command}\" to project ${HOME}${temp2}"
}

# fucntion to select a bookmarked command
function pcbs() {
  local testDir=$PWD

  # if current working directory is $HOME (or) is a subdirectory of $HOME, continue, else return
  [[ $testDir == $HOME* ]] || return

  # remove $HOME prefix (since we are creating a copy of the directory relative to the home directory to the $HOME/.pcb directory)
  testDir=${testDir#"$HOME"}

  # if path relative to $HOME is non-empty (not $HOME directory), add '/' to the testDir string for simplifying the further operations
  [[ $testDir[1] == '/' ]] || testDir='/'$testDir

  local prefixDir="$HOME/.pcb"
  local pcbFile='.pcbfile'

  # while testDir isn't empty w.r.t $HOME directory and .pcbfile does not exist in the testDir w.r.t to the prefix directory, move testDir string one directory up
  while [[ -n $testDir ]] && [[ ! -f $prefixDir'/'${testDir:1}'/'$pcbFile ]]
  do
    # remove bottommost directory in the testDir string (make the current test directory it's parent (or) move testDir one directory up)
    testDir=${testDir%/*}
  done

  local resFilePath

  if [[ -n $testDir ]]
  then
    # remove '/' at beginning of testDir string if not empty since we don't need it anymore, we had just used it to simplify the process of moving to the parent directory
    testDir=${testDir:1}
    resFilePath="$prefixDir/$testDir/$pcbFile"
  else
    resFilePath="$prefixDir/$pcbFile"
  fi

  # if the .pcbfile in the resultant directory is empty, return
  [[ -s $resFilePath ]] || return

  # select command among the list of bookmarked commands with help of fzf
  # command number added before commands to simplify the selection process by just selecting the command no.
  # by default cat --number returns trailing whitespaces, so remove them using awk
  local commandWithLineNo=$(cat --number $resFilePath | awk '{$1=$1;print}' | fzf --layout=reverse)

  # if no command selected, return
  [[ -z $commandWithLineNo ]] && return

  # regex to obtain first word in string
  local regex='s/^\w*\ *//'

  # apply regex on the command with line no. to obtain the command (delete line no. from command, i.e. the first word from the command)
  local command=$(echo $commandWithLineNo | sed --expression $regex)

  # execute obtained command
  eval $command
}


# fucntion to delete a bookmarked command
function pcbd() {
  local testDir=$PWD

  # if current working directory is an ancestor of $HOME, return
  [[ $testDir == $HOME* ]] || return

  # remove $HOME prefix (since we are creating a copy of the directory relative to the home directory to the $HOME/.pcb directory)
  testDir=${testDir#"$HOME"}

  # if path relative to $HOME is non-empty (not $HOME directory), add '/' to the testDir string for simplifying the further operations
  [[ $testDir[1] == '/' ]] || testDir='/'$testDir

  local prefixDir=$HOME/.pcb
  local pcbFile='.pcbfile'

  # while testDir isn't empty w.r.t $HOME directory and .pcbfile does not exist in the testDir w.r.t to the prefix directory, move testDir string one directory up
  while [[ -n $testDir ]] && [[ ! -f $prefixDir'/'${testDir:1}'/'$pcbFile ]]
  do
    # remove bottommost directory in the testDir string (make the current test directory it's parent (or) move testDir one directory up)
    testDir=${testDir%/*}
  done

  local resFilePath

  if [[ -n $testDir ]]
  then
    # remove '/' at beginning of testDir string if not empty since we don't need it anymore, we had just used it to simplify the process of moving to the parent directory
    testDir=${testDir:1}
    resFilePath="$prefixDir/$testDir/$pcbFile"
  else
    resFilePath="$prefixDir/$pcbFile"
  fi

  # if the .pcbfile in the resultant directory is empty, return
  [[ -s $resFilePath ]] || return

  # select command among the list of bookmarked commands with help of fzf
  # command number added before commands to simplify the selection process by just selecting the command no.
  # by default cat --number returns trailing whitespaces, so remove them using awk
  local commandWithLineNo=$(cat --number $resFilePath | awk '{$1=$1;print}' | fzf --layout=reverse)

  # if no command selected, return
  [[ -z $commandWithLineNo ]] && return

  # regex to obtain first occurrence of a number in the selected string (used to delete specific line no. in the .pcbfile)
  local regex='s/^([^.]+).*$/\1/; s/^[^0-9]*([0-9]+).*$/\1/'

  # apply regex on the command with line no. to obtain the line no. to be deleted
  local lineNo=$(echo $commandWithLineNo | sed --regexp-extended $regex)

  # delete specific line no. from the .pcbfile
  sed -i "${lineNo}d" $resFilePath
}
