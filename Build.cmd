@echo off
pushd %~dp0
set msbuild="C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe"
set log-dir=Build\BuildOutput\log
set nuget-bin=Build\BuildOutput\temp\nuget-bin
set nuget=%nuget-bin%\nuget.exe
set nuget-download=powershell.exe -NoProfile -Command "& {(New-Object System.Net.WebClient).DownloadFile('https://www.nuget.org/nuget.exe','%nuget%')}"

if not exist remotion.snk goto nosnk

if not [%1]==[] goto %1
	
@REM if %ERRORLEVEL%==2 
@REM goto run_full_build

:msbuild

@set msbuild="%ProgramFiles(x86)%\msbuild\14.0\Bin\MSBuild.exe"
@if not exist %msbuild% @set msbuild="%ProgramFiles%\MSBuild\14.0\Bin\MSBuild.exe"
@if not exist %msbuild% @set msbuild="%ProgramFiles(x86)%\MSBuild\12.0\Bin\MSBuild.exe"
@if not exist %msbuild% @set msbuild="%ProgramFiles%\MSBuild\12.0\Bin\MSBuild.exe"

%msbuild% /m /nr:false /p:Platform="Any CPU" /v:M /p:COnfiguration=Debug Relinq.sln

:run_test_build
mkdir %log-dir%
mkdir %nuget-bin%
%nuget-download%
%nuget% restore . -NonInteractive
%msbuild% build\Remotion.Local.build /t:TestBuild /maxcpucount /verbosity:normal /flp:verbosity=normal;logfile=build\BuildOutput\log\build.log
if not %ERRORLEVEL%==0 goto build_failed
goto build_succeeded

:run_full_build
mkdir %log-dir%
mkdir %nuget-bin%
%nuget-download%
%nuget% restore . -NonInteractive
%msbuild% build\Remotion.Local.build /t:FullBuildWithoutDocumentation /maxcpucount /verbosity:normal /flp:verbosity=normal;logfile=build\BuildOutput\log\build.log
if not %ERRORLEVEL%==0 goto build_failed
goto build_succeeded

:run_docs_build
mkdir %log-dir%
mkdir %nuget-bin%
%nuget-download%
%nuget% restore . -NonInteractive
%msbuild% build\Remotion.Local.build /t:DocumentationBuild /maxcpucount /verbosity:minimal /flp:verbosity=normal;logfile=build\BuildOutput\log\build.log
if not %ERRORLEVEL%==0 goto build_failed
goto build_succeeded

:run_pkg_build
mkdir %log-dir%
mkdir %nuget-bin%
%nuget-download%
%nuget% restore . -NonInteractive
%msbuild% build\Remotion.Local.build /t:PackageBuild /maxcpucount /verbosity:minimal /flp:verbosity=normal;logfile=build\BuildOutput\log\build.log
if not %ERRORLEVEL%==0 goto build_failed
goto build_succeeded

:run_dependdb
mkdir %log-dir%
mkdir %nuget-bin%
%nuget-download%
%nuget% restore . -NonInteractive
%msbuild% build\Remotion.Local.build /t:DependDBBuild /maxcpucount /verbosity:normal /flp:verbosity=detailed;logfile=build\BuildOutput\log\build.log
if not %ERRORLEVEL%==0 goto build_failed
goto build_succeeded

:run_exit
exit /b 0


:build_failed
echo.
echo Building re-motion has failed.
start build\BuildOutput\log\build.log
pause
popd
exit /b 1

:build_succeeded
echo.
pause
popd
exit /b 0

:nosnk
echo remotion.snk does not exist. Please run Generate-Snk.cmd from a Visual Studio Command Prompt.
pause
popd
exit /b 2
