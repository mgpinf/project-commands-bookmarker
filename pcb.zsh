# if $HOME/.pcb directory doesn't already exist, create it
[[ -d $HOME/.pcb ]] || mkdir $HOME/.pcb


# function to bookmark a directory as project (create .pcbfile in the copy of the directory relative to $HOME and then relative to $HOME/.pcb)
function pcbm() {
  local prefix="$HOME/.pcb"
  local projectDirectory=$PWD
  local favoritesDirectory="${prefix}/${projectDirectory#"$HOME/"}"
  local pcbCommandsFile='.pcbCommandsFile'
  local pcbDirsFile='.pcbDirsFile'
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

  local pcbCommandsFile='.pcbCommandsFile'
  local pcbDirsFile='.pcbDirsFile'

  while [[ -n ${temp2} ]]
  do
    output=$(find ${prefix} -wholename "${prefix}${temp2}/${pcbCommandsFile}")
    [[ -n ${output} ]] && break
    temp2=${temp2%/*}
  done

  echo $command >> "${prefix}${temp2}/${pcbCommandsFile}"
  echo $PWD >> "${prefix}${temp2}/${pcbDirsFile}"
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
  local pcbCommandsFile='.pcbCommandsFile'
  local pcbDirsFile='.pcbDirsFile'

  # while testDir isn't empty w.r.t $HOME directory and .pcbfile does not exist in the testDir w.r.t to the prefix directory, move testDir string one directory up
  while [[ -n $testDir ]] && [[ ! -f $prefixDir'/'${testDir:1}'/'$pcbCommandsFile ]]
  do
    # remove bottommost directory in the testDir string (make the current test directory it's parent (or) move testDir one directory up)
    testDir=${testDir%/*}
  done

  local resCommandsFilePath
  local resDirsFilePath

  if [[ -n $testDir ]]
  then
    # remove '/' at beginning of testDir string if not empty since we don't need it anymore, we had just used it to simplify the process of moving to the parent directory
    testDir=${testDir:1}
    resCommandsFilePath="$prefixDir/$testDir/$pcbCommandsFile"
    resDirsFilePath="$prefixDir/$testDir/$pcbDirsFile"
  else
    resCommandsFilePath="$prefixDir/$pcbCommandsFile"
    resDirsFilePath="$prefixDir/$pcbDirsFile"
  fi

  # if the .pcbfile in the resultant directory is empty, return
  [[ -s $resCommandsFilePath ]] || return

  # select command among the list of bookmarked commands with help of fzf
  local command=$(cat -n $resCommandsFilePath | sort -uk2 | sort -nk1 | cut -f2- | fzf --layout=reverse)

  # if no command selected, return
  [[ -z $command ]] && return

  # fetch line nos. from the having the command
  local lineNosString=$(grep -n $command $resCommandsFilePath | cut --fields=1 --delimiter=':')

  local lineNosArr=(${(@f)lineNosString})
  local lineNo
  local directoriesArr=()

  for lineNo in $lineNosArr[@]
  do
    directoriesArr+=$(sed -n "${lineNo}p" $resDirsFilePath)
  done
  directoriesArr+=$PWD

  local selectedDir=$(printf '%s\n' "${directoriesArr[@]}" | fzf --layout=reverse)
  
  [[ -z $selectedDir ]] && return

  local curDir=$PWD

  # change to selected directory
  cd $selectedDir

  # execute obtained command
  eval $command

  # return to original directory
  cd $curDir
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
  local pcbCommandsFile='.pcbCommandsFile'
  local pcbDirsFile='.pcbDirsFile'

  # while testDir isn't empty w.r.t $HOME directory and .pcbfile does not exist in the testDir w.r.t to the prefix directory, move testDir string one directory up
  while [[ -n $testDir ]] && [[ ! -f $prefixDir'/'${testDir:1}'/'$pcbCommandsFile ]]
  do
    # remove bottommost directory in the testDir string (make the current test directory it's parent (or) move testDir one directory up)
    testDir=${testDir%/*}
  done

  local resCommandsFilePath
  local resDirsFilePath

  if [[ -n $testDir ]]
  then
    # remove '/' at beginning of testDir string if not empty since we don't need it anymore, we had just used it to simplify the process of moving to the parent directory
    testDir=${testDir:1}
    resCommandsFilePath="$prefixDir/$testDir/$pcbCommandsFile"
    resDirsFilePath="$prefixDir/$testDir/$pcbDirsFile"
  else
    resCommandsFilePath="$prefixDir/$pcbCommandsFile"
    resDirsFilePath="$prefixDir/$pcbDirsFile"
  fi

  # if the .pcbfile in the resultant directory is empty, return
  [[ -s $resCommandsFilePath ]] || return

  # select command among the list of bookmarked commands with help of fzf
  local command=$(cat -n $resCommandsFilePath | sort -uk2 | sort -nk1 | cut -f2- | fzf --layout=reverse)

  # if no command selected, return
  [[ -z $command ]] && return

  # fetch line nos. from the having the command
  local lineNosString=$(grep -n $command $resCommandsFilePath | cut --fields=1 --delimiter=':' | tac)

  local lineNosArr=(${(@f)lineNosString})

  local lineNo

  for lineNo in $lineNosArr[@]
  do
    # delete specific line no. from the .pcbCommandsFile and .pcbDirsFile
    sed -i "${lineNo}d" $resCommandsFilePath
    sed -i "${lineNo}d" $resDirsFilePath
  done
}
