#!/usr/bin/env bash

RTSP_URI="rtsp://admin:L25E8A8B@192.168.1.35:554/cam/realmonitor?channel=1&subtype=0"
OUT="stream.m3u8"

# Start web server.
python -m http.server &

# Clean up existing clips.
rm -f "$OUT"
rm -f ./*".ts"

# Transcode.
ffmpeg -i "$RTSP_URI" \
    -y \
    -acodec aac \
    -ac 2 \
    -tune zerolatency \
    -preset veryfast \
    -vcodec libx264 \
    -crf 21 \
    -hls_init_time 1 \
    -hls_time 1 \
    -hls_list_size 60 \
    -fflags nobuffer \
    -hls_flags delete_segments \
    -force_key_frames "expr:gte(t,n_forced*1)" \
    "$OUT"