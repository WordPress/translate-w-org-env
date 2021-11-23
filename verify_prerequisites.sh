#!/bin/bash
COMMANDS_TO_CHECK=( docker wp git npm curl )
for command in "${COMMANDS_TO_CHECK[@]}"
do :
  if ! command -v ${command} &> /dev/null
  then
    echo "The ${command} could not be found. Stopping the installation."
    echo "Please, install ${command} before continuing."
    exit
  else
    echo "${command} is installed."
  fi
done

echo "You have all prerequisites."
exit
