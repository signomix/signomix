#!/bin/bash
TOKEN=$(curl -k --user tester1:signomix -H "Accept: text/plain" -X POST "https://localhost/api/auth")

QUERY=$(urlencode "from 2022-04-01T09:00:00+02 to 2022-04-01T11:00:00+02 timeseries")
#QUERY=$(urlencode "last 10 timeseries")
echo "$QUERY"

curl -ik -H "Accept: text/csv" -H "Authentication: $TOKEN" "https:/localhost/api/iot/device/iot-emulator/*?query=$QUERY"  \
-o data_iot-emulator.csv

#curl -ik -H "Accept: text/csv" -H "Authentication: $TOKEN" "https:/localhost/api/iot/device/iot-emulator/*?query=last%20100%20timeseries" \
#-o data_iot-emulator.csv
