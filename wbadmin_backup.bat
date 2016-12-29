@echo off
REM Incremental backups with a full backup once it runs out of free space.
REM Assumes backups fail due to lack of space, then deleting old ones.
REM Originally made for Windows 8 as it didn't include
REM the imaging options from Windows 7. May still be needed
REM in Windows 10.

REM Supports backing up to a target drive letter or directory,
REM a VHD/VHDX which is mounted on demand, and/or copying the
REM backups to a fileserver.

REM User-configurable variables you must set:
REM wbINCLUDE - Drives to include, given to wbadmin
REM wbTARGET - Target drive letter or path.
REM wbVHD - [Optional] VHD/VHDX to mount first. Will be un-mounted upon completion.
REM wbVHDLETTER - [Optional] Drive letter for mounted VHD/VHDX.
REM MYSERVER - [Optional] Server path to copy backed-up files to AFTER backup.
REM MYSERVER_IP - [Optional] IP or hostname to check if server is up.

SETLOCAL EnableDelayedExpansion
set ROBOCOPY=%WINDIR%\System32\Robocopy.exe
set IGNOREDIRS="Temp" "Temp*" "Cache" "*Cache*" "System Volume Information" "$RECYCLE.BIN" "Prefetch" "Prefetch*"
set LOGNAME=wbadmin_backup.log
set LOG=C:\Scripts\%LOGNAME%

REM Which drive to include and where to put it
set wbINCLUDE=C:
set wbTARGET=I:

REM Optionally mount and then backup to a VHD/VHDX
REM To set this option, you must have already created a valid VHD/VHDX
REM set wbVHD.
set wbVHD=
set wbVHDLETTER=I

REM Optionally copy to a fileserver (drive mapping not necessary)
set MYSERVER=
set MYSERVER_IP=
IF NOT EXIST "\\%MYSERVER%" (
   set MYSERVER=%MYSERVER_IP%
)

REM Initialize log file. Set it with permissions
REM for Administrators only.
echo [%0] started on %DATE% > "%LOG%"
icacls "%LOG%" /inheritance:r 
icacls "%LOG%" /grant Administrators:(F)
icacls "%LOG%" /grant System:(F)

REM Mount the Backups VHDX, if it exists
IF EXIST "%wbVHD%" (
	echo [%0] Mounting [%wbVHD%]... >> "%LOG%"
	echo select vdisk file="%wbVHD%" > "%TEMP%\%~n0.txt"
	echo attach vdisk >> "%TEMP%\%~n0.txt"
	"%WINDIR%\System32\diskpart.exe" /s "%TEMP%\%~n0.txt" >> "%LOG%"
	ping 127.0.0.1 -n 5 >Nul 2>&1
	IF NOT EXIST "%wbTARGET%\" (
		REM Try to recover from error
		echo [%0] [%wbTARGET%] does not exist, re-mounting [%wbVHD%]... >> "%LOG%"
		echo select vdisk file="%wbVHD%" > "%TEMP%\%~n0.txt"
		echo attach vdisk >> "%TEMP%\%~n0.txt"
		echo remove letter=%wbVHDLETTER%
		echo assign letter=%wbVHDLETTER% >> "%TEMP%\%~n0.txt"
		"%WINDIR%\System32\diskpart.exe" /s "%TEMP%\%~n0.txt" >> "%LOG%"
	)
	ping 127.0.0.1 -n 5 >Nul 2>&1
	IF NOT EXIST "%wbTARGET%\" GOTO :fatalerror
)

SET /a "loopCount=0"
:dobackup
SET /a "loopCount=loopCount+1"
echo wbadmin start backup -vssFull -include:"%wbINCLUDE%" -backupTarget:"%wbTARGET%" >> "%LOG%"
wbadmin start backup -vssFull -include:"%wbINCLUDE%" -backupTarget:"%wbTARGET%" >> "%LOG%" && GOTO :backupOK
echo [%0] ERROR - Backup not completed
findstr "There is not enough free space" "%LOG%" >Nul && GOTO :nofreespace
echo [%0] UNKNOWN ERROR >> "%LOG%"
GOTO :fatalerror

:nofreespace
echo [%0] NOT ENOUGH FREE SPACE >> "%LOG%"
REM We don't want to do this twice...
IF %loopCount% GTR 1 GOTO :fatalerror
echo [%0] Deleting old backups... >> "%LOG%"
rmdir /s /q "%wbTARGET%\WindowsImageBackup" || echo [%0] ERROR with deleting old backups
GOTO :dobackup

:backupOK
IF NOT "!MYSERVER!"=="" (
	echo %ROBOCOPY% "%wbTARGET%\WindowsImageBackup" "\\!MYSERVER!\Backups\WindowsImageBackup" /E /XO /FFT /TBD /R:5 /W:60 /J /IPG:30 /NP /XJD >> "%LOG%"
	%ROBOCOPY% "%wbTARGET%\WindowsImageBackup" "\\!MYSERVER!\Backups\WindowsImageBackup" /E /XO /FFT /TBD /R:5 /W:60 /J /IPG:30 /NP /XJD >> "%LOG%"
)
GOTO :done

:fatalerror
echo [%0] FATAL ERROR, aborting

:done
REM Copy the log file
copy /A /V /Y "%LOG%" "%wbTARGET%\%LOGNAME%"

REM Unmount the Backups VHDX, if it exists
IF EXIST "%wbVHD%" (
	echo [%0] Unmounting [%wbVHD%]... >> "%LOG%"
	echo select vdisk file="%wbVHD%" > "%TEMP%\%~n0.txt"
	echo detach vdisk >> "%TEMP%\%~n0.txt"
	"%WINDIR%\System32\diskpart.exe" /s "%TEMP%\%~n0.txt" >> "%LOG%"
)
echo [%0] Done. >> "%LOG%"
