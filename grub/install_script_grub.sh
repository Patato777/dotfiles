#!/bin/bash

echo Copying the theme in the right folder
cp -r ./themes /boot/grub
echo The themes was copied succefully :D

echo Copying the grub file
cp ./default/grub /etc/default
echo Grub file copied succefully

echo Executing grub update and it should work
