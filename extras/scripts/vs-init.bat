@echo off

REM this is a routine that would detect and initialize visual studio environment.
REM It's not going to be tested very well for new versions because I only have VS2017 and VS2019 Community installed

REM if a special variable comes in, it'll use that version XVS_INIT_VER=

IF /I "%~1" EQU "" (
	echo ERROR: Pass in an [arch] to be passed to a vcvarsall.bat
	exit /b 1
)

SET XVS_BASE_COMMON=%ProgramFiles(x86)%\Microsoft Visual Studio
SET XVS_BASE_COMMON64=%ProgramFiles%\Microsoft Visual Studio
SET XVS_VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe

IF /I "%XVS_INIT_VER%" EQU "" GOTO SKIP_VER
	REM need to do it this way so that () chars don't cause a syntax error
	SET XVS_BASE_COMMON=%XVS_BASE_COMMON%\%XVS_INIT_VER%
	SET XVS_BASE_COMMON64=%XVS_BASE_COMMON64%\%XVS_INIT_VER%
:SKIP_VER

SET XVS_VCVARS_BAT=

IF /I NOT "%XVS_INIT_VER%" EQU "" GOTO FIND_VCVARS_BY_DIR

IF EXIST "%XVS_VSWHERE%" (
	FOR /F "usebackq tokens=*" %%I IN (`"%XVS_VSWHERE%" -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -find VC\Auxiliary\Build\vcvarsall.bat`) DO (
		echo + Found VCVARSALL.BAT at: %%I
		SET XVS_VCVARS_BAT=%%I
	)
)

IF /I NOT "%XVS_VCVARS_BAT%" EQU "" GOTO CALL_VCVARS

:FIND_VCVARS_BY_DIR

REM because the directories in theory should come out in order
REM it'll automatically pick up the LAST vcvarsall.bat (in theory)
FOR /F "usebackq tokens=*" %%I IN (`dir /b /on /s "%XVS_BASE_COMMON%\vcvarsall.bat" 2^>nul`) DO (
	echo + Found VCVARSALL.BAT at: %%I
	SET XVS_VCVARS_BAT=%%I
)
FOR /F "usebackq tokens=*" %%I IN (`dir /b /on /s "%XVS_BASE_COMMON64%\vcvarsall.bat" 2^>nul`) DO (
	echo + Found VCVARSALL.BAT at: %%I
	SET XVS_VCVARS_BAT=%%I
)

IF /I "%XVS_VCVARS_BAT%" EQU "" (
	echo Visual Studio C++ build tools not found!
	exit /b 1
)

:CALL_VCVARS
echo == Using: %XVS_VCVARS_BAT% ==
call "%XVS_VCVARS_BAT%" %~1



SET XVS_BASE_COMMON=
SET XVS_BASE_COMMON64=
SET XVS_VCVARS_BAT=
SET XVS_VSWHERE=


exit /b 0
