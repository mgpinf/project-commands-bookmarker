# Project commands bookmarker

## Script for achieving the following:

- Bookmarking the directories as projects
- Removing bookmarks from bookmarked projects
- Interface to select command from bookmarked projects
- Interface to add command to bookmarked projects
- Interface to remove command from bookmarked projects

## Working

- Actions on directories:

  - **add**
    - bookmark a directory as project if not already marked
  - **remove**
    - remove bookmark from project directory if not already removed

- Actions on commands:
  - **select**
    - bookmarked commands looked for in the bookmark file
    - if bookmark file exists, use it for selecting commands, else, search for the lowest ancestor directory for bookmark file and use that, since the current directory could be a project subdirctory
  - **add**
    - if bookmark file exists, use it for adding selected command, else, search for the lowest ancestor directory for bookmark file and use that, since the current directory could be a project subdirctory
  - **delete**
    - if bookmark file exists, use it for deleting selected bookmarked command, else, search for the lowest ancestor directory for bookmark file and use that, since the current directory could be a project subdirctory

## Commands

```
git clone https://github.com/Manish0925/pcb.git
echo "source $PWD/pcb/pcb.zsh" >> ~/.zshrc
```
