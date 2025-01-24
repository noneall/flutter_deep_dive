#!/bin/bash

# Get devices
# Get devices
devices=$(emulator -list-avds)

echo "Available devices:"
i=0

while read -r name; do
    ((i++))
    printf "%2d. %s\n" $i "$name"
done <<<"$devices"

read -p "Select device (1-$i): " selection

if [[ $selection =~ ^[0-9]+$ ]] && [ "$selection" -gt 0 ] && [ "$selection" -le "$i" ]; then
    name=$(echo "$devices" | sed -n "${selection}p")
    echo "Starting $name..."
    emulator @"$name" -no-boot-anim -gpu host
else
    echo "Invalid selection"
fi
