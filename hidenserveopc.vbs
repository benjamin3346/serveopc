Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & "serveopc.bat" & chr(34), 0
Set WshShell = Nothing
