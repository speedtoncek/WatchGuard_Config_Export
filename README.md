# WatchGuard_Config_Export
Exports xml configuration from a list of WatchGuard devices

This script exists to make automatic backups of WG devices.
Since WatchGuard does not provide this option on its own.

You will need a Powershell and Plink for this to work.

Steps to make this work
1) Create a list of devices 
List of devices that you want to backup is in variable called $WatchGuardList
2) Log in to the each device atleast once via putty to accept the ssh key, otherwise the script will fail
3) Create a user that will perform the backup, you can create a default status, or create other readonly account
4) Fill in password - The password is stored in the script in the form of cleantext, you can modify it for either a prompt or vault if you want
5) Fill in output of the .xml backup

You can modify the script to run other commands / do other actions.
You can also further automate the backups by putting this script in scheduler.
Or you can modify it to put ftp/tfp instead of an export command, but you will need to have that ftp/tftp server reachable by the fireboxes.

>[!WARNING]
Always test the script before running it in production network
