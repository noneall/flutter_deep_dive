#!/bin/bash

# Get devices
devices=$(xcrun simctl list -e -j devices available | jq -r '.devices | to_entries[] | .value[] | select(.state=="Shutdown")')

i=0

echo "Available devices:"

while read -r name; do
    ((i++))
    printf "%2d. %-${max_length}s\n" $i "$name"
done <<<"$(echo $devices | jq -r '"\(.name)"')"

read -p "Select device (1-$i): " selection

uuid=$(echo $devices | jq -r '.udid' | sed -n "${selection}p")

name=$(echo $devices | jq -r '.name' | sed -n "${selection}p")

if [ -n "$uuid" ]; then
    echo "Booting $name..."
    xcrun simctl boot "$uuid"
    open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app
else
    echo "Invalid selection"
fi
