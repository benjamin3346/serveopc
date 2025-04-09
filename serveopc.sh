#!/usr/bin/env bash

BOT_TOKEN="7450852198:AAEJrO8y3gqaWFECOW87VtOpOtx13_WwrXg"
CHAT_ID="8107240151"

# Tentukan lokasi file log (sama folder dengan script ini)
DIR="$(cd "$(dirname "$0")" && pwd)"
LOGFILE="$DIR/serveo_log.txt"

while true; do
    if ping -n 1 8.8.8.8 > /dev/null 2>&1; then
        echo "[+] Koneksi tersedia, jalankan Serveo"

        # Jalankan SSH dan simpan output ke logfile
        ssh -o StrictHostKeyChecking=no -R 80:localhost:8080 serveo.net > "$LOGFILE" 2>&1 &
        SSH_PID=$!

        sleep 5

        # Ambil URL dari output Serveo
        URL=$(grep -m 1 -o "https://[a-zA-Z0-9]*\.serveo.net" "$LOGFILE")

        if [ -n "$URL" ]; then
            echo "[+] Serveo URL ditemukan: $URL"
            curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
                -d chat_id=$CHAT_ID \
                -d text="Serveo aktif: $URL"
        else
            echo "[!] Serveo URL tidak ditemukan."
        fi

        echo "[!] Menunggu Serveo mati..."
        wait $SSH_PID

        echo "[!] Serveo disconnected, ulangi..."
    else
        echo "[!] Tidak ada koneksi internet. Coba lagi 10 detik..."
        sleep 10
    fi
done

