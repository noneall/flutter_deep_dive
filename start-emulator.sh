#!/bin/bash

# Default AVD name if not set in .env
DEFAULT_AVD="Pixel_7_Pro_API_35"

# Load environment variables if .env exists
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

# Use default if AVD_NAME not set
AVD_NAME=${AVD_NAME:-$DEFAULT_AVD}

# Verify emulator command
if ! command -v emulator &>/dev/null; then
    echo "Error: emulator command not found. Please verify Android SDK installation"
    exit 1
fi

echo "Starting emulator: $AVD_NAME"

# Try to start emulator, if fails, list available AVDs
if ! emulator @"$AVD_NAME" -no-boot-anim -gpu host; then
    echo -e "\nAVD '$AVD_NAME' not found. Available AVDs:"
    emulator -list-avds
    exit 1
fi
