@echo off
REM Block all executables found rooted at given path in Windows Firewall.
REM Unless "ALL" is given as the 2nd argument, ask for each executable.
REM Always add rules to also block local network access too if desired.
SETLOCAL EnableDelayedExpansion
set __COMPAT_LAYER=RunAsAdmin
IF EXIST "%~f1" ( 
	IF EXIST "%~f1\*" (
		FOR /R "%~f1" %%G IN (*.EXE) DO (
			IF /I [%~2]==[ALL] (
				set _choice=
			) ELSE (
				set /P _choice="Block %%~nxG (%~n1)? " || N
			)
			IF /I NOT [!_choice!]==[N] (
				call :addrule "%%~nxG (%~n1)" "%%~fG"
			)
		)
	) ELSE (
		call :addrule "%~nx1 (%~n1)" "%~f1"
	)
	echo [%~nx0] Done.
) ELSE (
    echo [%~nx0] ERROR: "%~f1" not found or does not exist.
)
GOTO :done

:addrule
echo [%~nx0] Adding rules in Windows Firewall for "%~nx1"...
netsh advfirewall firewall add rule name="Block %~1" dir=out action=block program="%~2" enable=yes
netsh advfirewall firewall add rule name="Block %~1" dir=in action=block program="%~2" enable=yes
netsh advfirewall firewall add rule name="Allow LocalSubnet for %~1" dir=out action=allow program="%~2" profile="private,domain" remoteip="LocalSubnet" enable=no
netsh advfirewall firewall add rule name="Allow LocalSubnet for %~1" dir=in action=allow program="%~2"  profile="private,domain" remoteip="LocalSubnet" enable=no
netsh advfirewall firewall add rule name="Allow all local subnets for %~1" dir=out action=allow program="%~2" profile="private,domain" remoteip="192.168.0.0/16,172.16.0.0/12,10.0.0.0/8" enable=no
netsh advfirewall firewall add rule name="Allow all local subnets for %~1" dir=in action=allow program="%~2"  profile="private,domain" remoteip="192.168.0.0/16,172.16.0.0/12,10.0.0.0/8" enable=no
netsh advfirewall firewall add rule name="Allow public LocalSubnet for %~1" dir=out action=allow program="%~2" profile="public" remoteip="LocalSubnet" enable=no
netsh advfirewall firewall add rule name="Allow public LocalSubnet for %~1" dir=in action=allow program="%~2"  profile="public" remoteip="LocalSubnet" enable=no
netsh advfirewall firewall add rule name="Allow public all local subnets for %~1" dir=out action=allow program="%~2" profile="public" remoteip="192.168.0.0/16,172.16.0.0/12,10.0.0.0/8" enable=no
netsh advfirewall firewall add rule name="Allow public all local subnets for %~1" dir=in action=allow program="%~2"  profile="public" remoteip="192.168.0.0/16,172.16.0.0/12,10.0.0.0/8" enable=no
echo [%~nx0] Added rules in Windows Firewall to block outbound/inbound for "%~nx1".
GOTO :eof

:done
