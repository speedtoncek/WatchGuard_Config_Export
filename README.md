# WatchGuard_Config_Export
Exports xml configuration from a list of WatchGuard devices

This script exists to make automatic backups of WG devices.
Since WatchGuard does not provide this option on its own.

You will need a Powershell and Plink for this to work.

The Script was tested on Windows and Linux enviroment.

[!NOTE]
>On Linux enviroment you need to edit path to plink and other files

Steps to make this work
1) Create a list of devices 
<br />  List of devices that you want to backup is in variable called $WatchGuardList
2) Log in to the each device atleast once via putty to accept the ssh key, otherwise the script will fail
3) Create a user that will perform the backup, you can use the default status, or create other readonly account
4) Fill in password - The password is stored in the script in the form of cleantext, you can modify it for either a prompt or vault if you want
5) Fill in output destination for the .xml file



>[!NOTE]
>You can modify the script to run other commands / do other actions. <br/>
>You can also further automate the backups by putting this script in scheduler. <br/>
>Or you can modify it to put ftp/tfp instead of an export command, but you will need to have that ftp/tftp server reachable by the fireboxes. <br/>
>The script will name the .xml file by its IP, you can then use the sort script to put it into a matching folder

>[!TIP]
>I will also include another script -> Sort_Backup for sorting the downloaded .xml files into folders and then move them to a different location for keeping a different versions of backups <br/>
>The sorting script assumes that the folder exists and its format is: PublicIP_DeviceName 


>[!WARNING]
Always test the script before running it in production network
