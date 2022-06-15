#!/bin/bash
#TOKEN=$(curl -k --user admin:test123 -H "Accept: text/plain" -X POST "https://localhost/api/auth")
AUTHKEY=NzE5NjUxMjUzODkzMzAxODgyNQ
TS=$(urlencode "2022-06-01T08:00:00+02")
echo "$TS"
curl -k -H "Authorization: $AUTHKEY"  \
-d "eui=iot-emulator&latitude=51.736761&longitude=19.435047&timestamp=$TS" \
"http://localhost/api/i4t" 

TS=$(urlencode "2022-06-01T09:00:00+02")
curl -k -H "Authorization: $AUTHKEY"  \
-d "eui=iot-emulator&latitude=51.736495&longitude=19.442150&timestamp=$TS" \
"http://localhost/api/i4t" 

TS=$(urlencode "2022-06-01T10:00:00+02")
curl -k -H "Authorization: $AUTHKEY"  \
-d "eui=iot-emulator&latitude=51.727148&longitude=19.447584&timestamp=$TS" \
"http://localhost/api/i4t" 

TS=$(urlencode "2022-06-01T11:00:00+02")
curl -k -H "Authorization: $AUTHKEY"  \
-d "eui=iot-emulator&latitude=51.719236&longitude=19.437953&timestamp=$TS" \
"http://localhost/api/i4t" 

TS=$(urlencode "2022-06-01T12:00:00+02")
curl -k -H "Authorization: $AUTHKEY"  \
-d "eui=iot-emulator&latitude=51.717510&longitude=19.457085&timestamp=$TS" \
"http://localhost/api/i4t" 
