#!/bin/bash

fecha=$(date '+%Y %m %d %H %M %S')

#gateway=$(ip route | cut -d ' ' -f 3 | head -n 1) <- si no se quiere poner el gateway manualmente

suma=$(ping -c 10 192.168.47.254 | head -n 11 | tail -n +5 | cut -d " " -f 7 | cut -d "=" -f 2 | tr "\n" "+" | rev | cut -c 2- | rev | bc -l)

media=$(echo "scale=2; $suma / 7" | bc )

echo "$fecha $media"
