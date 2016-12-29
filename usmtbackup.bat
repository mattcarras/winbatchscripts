@echo off
REM User State Migration Tool Backup Script
REM Backs up the current username's profile and files using USMT through SCANSTATE.exe.
REM Scanstate is available in the WAIK.

REM Give argument NOKEY to avoid encrypting the backup. You can also give a keyfile as
REM an argument as long as it's not specifically named NOKEY.

REM Note: Google GetWAIKTools for a way to easily get SCANSTATE.exe without installing the
REM entire WAIK.

set "SCANSTATE=>>PUT FULL PATH TO SCANSTATE.EXE HERE<<"

set "LOG=%USERPROFILE%\scanstate.log"
set "BACKUPDEST=>>PUT FULL PATH TO BACKUP DESTINATION HERE<<"
set "KEYFILE=>>PUT FULL PATH TO ENCRYPTION KEYFILE HERE<<"

echo %0 started on %DATE% %TIME% > "%LOG%"

echo [%~nx0] User State Migration Tool Backup...
IF NOT /I "%~1"=="NOKEY" (
	set ENCRYPTARGS='
	echo NOKEY argument detected >> "%LOG%"
) ELSE (
	IF NOT "%~1"=="" set "KEYFILE=%~1"
	IF NOT EXIST "%KEYFILE%" (
		echo [%~nx0] FATAL ERROR: Keyfile [%KEYFILE%] does not seem to exist >> "%LOG%"
		echo [%~nx0] FATAL ERROR: Keyfile [%KEYFILE%] does not seem to exist
		GOTO :done
	)
	set ENCRYPTARGS=/encrypt /keyfile:"%KEYFILE%"
)
IF NOT EXIST "%BACKUPDEST%" (
	echo [%~nx0] FATAL ERROR: Destination [%BACKUPDEST%] does not seem to exist >> "%LOG%"
	echo [%~nx0] FATAL ERROR: Destination [%BACKUPDEST%] does not seem to exist
	GOTO :done
)


echo "%SCANSTATE%" "%BACKUPDEST%" /ue:*\* /ui:%USERNAME% /o /vsc /efs:decryptcopy %ENCRYPTARGS% >> "%LOG%"
"%SCANSTATE%" "%BACKUPDEST%" /ue:*\* /ui:%USERNAME% /o /vsc /efs:decryptcopy %ENCRYPTARGS% >> "%LOG%"

:done
