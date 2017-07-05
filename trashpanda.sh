#!/bin/bash

trash_target=/home/$USER/.local/share/Trash

while [[ true ]]; do
  if find "$trash_target" -mindepth 1 -print -quit | grep -q .; then
      echo The directory $trash_target is not empty
      ls $trash_target/files/* >> logfile
      rm -rf $trash_target/*
      echo The directory $trash_target has been emptied
  else
      echo The directory $trash_target is empty
  fi

  #sleep for 5 seconds
  sleep 5s
done
