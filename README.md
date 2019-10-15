# WinBatch Scripts
Various Batch scripts for Windows.  
Authored by: Matthew Carras  :pen:

**RunAsInvoker.bat** - Simple script designed to be put in your "Send To" folder which runs the file as the current user, bypassing UAC checks and running it with whatever privilege level is currently set. Useful if the program always demands Administrator privileges but doesn't actually need them.

**fwblockallprograms.bat** - Adds rules to Windows Firewall to block all executables found rooted at given path from Internet access.

**usmtbackup.bat** - Backs up the current username's profile and files using USMT (User State Migration Tool) through use of the SCANSTATE.exe from WAIK (Windows Automated Installation Kit). Useful to backup, transfer, and migrate a single user's profile. Google "GetWAIKTools" for a simple utility which lets you download the WAIK tools without needing to install the entire kit.

**wbadmin_backup.bat** - Incremental backups with a full backup once it runs out of free space. Assumes backups fail due to lack of space, then deleting old ones. Originally made for Windows 8 as it didn't include the imaging options from Windows 7. May still be needed in Windows 10. Supports backing up to a target drive letter or directory, a VHD/VHDX which is mounted on demand, and/or copying the backups to a fileserver.
