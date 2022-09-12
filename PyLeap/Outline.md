# Outline

## Overview

 Facade 
 The Wifi View's interaction with the View Model should be simple.
 Functions that should be accessible:
 ViewModel should have these functions:
 
 Should be able to choose the device its connects to.
 - Should I use IP? Host name?
 
 Are we connected to Wi-Fi?
 - If not, show Wi-fi prompt
 - If yes, continue.
 
 Check if this project exists.
 - If it doesn't exist, download named project from JSON URL
 - If download fails or not able to download the project, show message "Try Again Later"
 
 Transfer this project.
 Can we connect to another remote client(Adafruit device)?
 
 *Notes*
 The User should be able to switch to Bluetooth Mode while in Wi-Fi mode.
 
 Entities:
 [RootResult] -> ProjectDemos
 These are references that need to be validated to make sure they exist in File Manager, then transferred.
 
 For File Manager URL validation functions:
 
 ###1. File Manager URL validation
  Project Validation - Within this function parameter, add in the string of the project's name and check if the project folder with that name exists.
 If it doesn't exist, show error saying it doesn't or download file then resume file transfer process.
 
 
 ###2. Filter Files
 File Filter - To determine if unwanted files are being sorted out, we create a sort or remove files and directories that has a path like this: 
    "adafruit-circuitpython-bundle-7.x-mpy"
 
  ###3. Find out the number of files and directories in selected project.
 Project Enumeration - We need to figure out how many files and directories are in the project folder.
 
 ###4. Sort Files/Directories
 Project Sort - Sort files and directories into designated arrays. Might do this individually.
 
 ###5. Directory Validation
  Check if each directory aleardy exists on client(disc).

 ###6. Directory Creation
 Using the "PUT" REST command create each directory in the array of directories until count equals zero. 
   - If yes, remove queued directory from array and recurse.
   - If no, create new directory on disc.
 
 
 *Look into creating a queue for this*
 
 Prepare to start file transfer.
 
 File Transfer notes will continue...
 
 New topic, States for Wifi View

When the user uses wifi view, these are the things that should happen:
Check connection status.

Check stored IP address.

 - If IP Address was not stored, show alert prompt that allows 
 - If IP stored, 
 

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
