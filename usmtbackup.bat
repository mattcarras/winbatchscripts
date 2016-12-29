@echo off
REM Backs up the current username's profile and files using USMT through SCANSTATE.exe.
REM Scanstate is available in the WAIK.
set "SCANSTATE=>>PUT FULL PATH TO SCANSTATE.EXE HERE<<"

set LOG=%USERPROFILE%\scanstate.log
set "BACKUPDEST=>>PUT FULL PATH TO BACKUP DESTINATION HERE<<"
set "KEYFILE=>>PUT FULL PATH TO ENCRYPTION KEYFILE HERE<<"

echo %0 started on %DATE% %TIME% > "%LOG%"

REM USMT
echo [%~nx0] USMT Backup...
IF NOT EXIST "%KEYFILE%" (
	echo [%~nx0] FATAL ERROR: Keyfile [%KEYFILE%] does not seem to exist >> "%LOG%"
	echo [%~nx0] FATAL ERROR: Keyfile [%KEYFILE%] does not seem to exist
	GOTO :done
)
IF NOT EXIST "%BACKUPDEST%" (
	echo [%~nx0] FATAL ERROR: Destination [%BACKUPDEST%] does not seem to exist >> "%LOG%"
	echo [%~nx0] FATAL ERROR: Destination [%BACKUPDEST%] does not seem to exist
	GOTO :done
)

"%SCANSTATE%" "%BACKUPDEST%" /ue:*\* /ui:%USERNAME% /o /vsc /efs:decryptcopy /encrypt /keyfile:"%KEYFILE%" >> "%LOG%"

:done
