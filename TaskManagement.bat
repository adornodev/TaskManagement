@echo off

cls
setlocal EnableDelayedExpansion

set blacklist="Nome da tarefa"

rem The second argument is the outputpath  where the application will be use to export or import tasks
set outputpath=%2
	
rem The first argument is the choice by calling the function "import" or "export"
if %1. == export. call :export
if %1. == import. call :import

exit /b 0


:export

	rem Get current date
	for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (
		 set day=%%k
		 set month=%%j
		 set year=%%l
	)
	set currentDate=%year%_%month%_%day%

	rem Create new directory
	md %outputpath%taskscheduler_bkp_%currentDate% 2>nul

	rem Export tasks name to specific txt file
	schtasks /query /fo csv | findstr /V /c:"TaskName" > %outputpath%exported_task_list_%currentDate%.txt

	rem Iterate over lines at txt file
	for /F "delims=," %%T in (%outputpath%exported_task_list_%currentDate%.txt) do (
		set tn=%%T
		set fn=!tn:\=!
		if /I !tn! NEQ !blacklist! ( 
			echo !tn!
			schtasks /query /xml /TN !tn! > %outputpath%taskscheduler_bkp_%currentDate%\!fn!.xml
		)
	)
	
	rem Remove Microsoft tasks which should not be imported.
	del %outputpath%taskscheduler_bkp_%currentDate%\Microsoft*.xml

	exit /b 0

	
:import
	rem Date example
	set currentDate=2018_04_28
	
	rem Import all tasks from specific input file
	for %%f in (%outputpath%taskscheduler_bkp_%currentDate%\*.xml) do (
		call :importfile "%%f"
	)
exit /b 0
