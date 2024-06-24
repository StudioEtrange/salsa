# TODO DO NOT WORK
# Sons Of The Forest



## doc

* https://github.com/jammsen/docker-sons-of-the-forest-dedicated-server


* docker run --rm -i -t -p 8766:8766/udp -p 27016:27016/udp -p 9700:9700/udp -v $(pwd)/steamcmd:/steamcmd -v $(pwd)/game:/sonsoftheforest -v $(pwd)/winedata:/winedata --name sons-of-the-forest-dedicated-server jammsen/sons-of-the-forest-dedicated-server:latest


## ports
   - 8766:8766/udp #GamePort
      - 27016:27016/udp #QueryPort
      - 9700:9700/udp #BlobSyncPort

* open these port into your firewall

## commands
./salsa info [<game id>]
./salsa up --module sotf sotf
./salsa down --module sotf sotf
./salsa status --module sotf sotf
./salsa logs --module sotf sotf
./salsa shell <game id>


## configuration

There is two files documented here https://steamcommunity.com/sharedfiles/filedetails/?id=2992700419&snr=1_2108_9__2107
located in SOTF_DATA_GAME_PATH/userdata


* dedicatedserver.cfg

set 
  "ServerName": "salsa-etrange",
  "MaxPlayers": 8,
  "Password": "studioetrange",


* ownerswhitelist.txt
#put your steamid (see https://www.steamidfinder.com/)