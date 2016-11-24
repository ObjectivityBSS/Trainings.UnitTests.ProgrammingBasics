@echo off

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:-------------------------------------

regsvr32 -s .\Tools\OpenCover\x64\OpenCover.Profiler.dll
.\Tools\OpenCover\opencover.console -output:coverage.xml -target:".\Tools\xunit.runner.console\2.1.0\tools\xunit.console.exe" -targetdir:".\UnitTestsTrainingSamples\OpenCover.Tests\bin\Debug" -targetargs:"..\..\..\..\UnitTestsTrainingSamples\OpenCover.Tests\bin\Debug\OpenCover.Tests.dll" -filter:"+[*]BestPractices.* -[*.Tests]*"
regsvr32 -u -s .\Tools\OpenCover\x64\OpenCover.Profiler.dll
.\Tools\ReportGenerator\reportgenerator.exe coverage.xml .\coverageReport
start .\coverageReport\index.htm
