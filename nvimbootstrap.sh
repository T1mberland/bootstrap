#!/bin/sh

set -e

today=$(date -I | tr '-' '_')

if command -v git >/dev/null 2>&1; then
  #printf "Git installed.\n\n"
  echo
else
  printf "You don't have git. Install git and run me again. Bye!\n"
  exit 1
fi

# Dry run only for now.
printf "This script will run the following commands:\n"
printf "\tmv ~/.config/nvim ~/.config/nvim.BACKUP.${today}\n"
printf "\tcd ~/.config\n"
printf '\tgit clone "https://github.com/T1mberland/init.lua.git" --depth 1\n'
printf '\tmv init.lua nvim\n'
printf "Proceed? [y/N]: "
read ans
case "$ans" in
[yY]*) echo "Running..." ;;
*)
  echo "Aborted."
  exit 0
  ;;
esac

mv ~/.config/nvim ~/.config/nvim.BACKUP.${today}
echo "Ran : mv ~/.config/nvim ~/.config/nvim.BACKUP.${today}"

cd ~/.config
echo "Ran : cd ~/.config"

git clone "https://github.com/T1mberland/init.lua.git" --depth 1
echo 'Ran : git clone "https://github.com/T1mberland/init.lua.git" --depth 1'

mv init.lua nvim
echo 'Ran : mv init.lua nvim'
