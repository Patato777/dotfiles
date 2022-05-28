#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


echo Copying the theme in the right folder
cp -r ./themes /boot/grub
echo If there are no error the themes was copied succefully :D

echo Copying the grub file
cp ./default/grub /etc/default
echo If there are no error grub file copied succefully

echo Executing grub update and it should work
