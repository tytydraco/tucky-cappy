#!/usr/bin/env bash

# Kill background processes when user exits.
trap "exit" INT TERM
trap "kill 0" EXIT

if [[ -z "$RTSP_URI" ]]; then
    echo "[E] No RTSP_URI environmental variable set."
    exit 1
fi

# How long each clip is in seconds.
SEGMENT_SECONDS="${SEGMENT_SECONDS:-"3600"}"

# How many segments to keep before overwriting old ones.
SEGMENTS="${SEGMENTS:-"24"}"

# Where to store video segments.
SEGMENT_DIR="${SEGMENT_DIR:-"segments/"}"

# How often to update the live screenshot.
LIVE_SCREENSHOT_FREQ="${LIVE_SCREENSHOT_FREQ:-"1"}"

# Live screenshot file path.
LIVE_SCREENSHOT_PATH="${LIVE_SCREENSHOT_PATH:-"live_screenshot.png"}"

# Records periodic segments of video.
periodic_recording() {
    mkdir -p "$SEGMENT_DIR"
    ffmpeg \
        -hide_banner \
        -y \
        -loglevel error \
        -rtsp_transport tcp \
        -use_wallclock_as_timestamps 1 \
        -i "$RTSP_URI" \
        -codec copy \
        -f segment \
        -reset_timestamps 1 \
        -segment_time "$SEGMENT_SECONDS" \
        -segment_format mkv \
        -segment_atclocktime 1 \
        -segment_wrap "$SEGMENTS" \
        -strftime 1 \
        "$SEGMENT_DIR/clip_%03d.mkv"
}

# Updates a single image of a recent camera screenshot.
live_screenshot() {
    while true; do
        ffmpeg \
            -hide_banner \
            -y \
            -loglevel error \
            -rtsp_transport tcp \
            -use_wallclock_as_timestamps 1 \
            -i "$RTSP_URI" \
            -vframes 1 \
            "$LIVE_SCREENSHOT_PATH"
        echo "[I] Updated live preview: $(date)"
        sleep "$LIVE_SCREENSHOT_FREQ"
    done
}

#periodic_recording &
live_screenshot &
python -m http.server

wait
