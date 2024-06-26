# avorion

* AVORION DEDICATED SERVER
* https://linuxgsm.com/servers/avserver/
* LGSM configuration for avorion : https://github.com/GameServerManagers/LinuxGSM/blob/master/lgsm/config-default/config-lgsm/avserver/_default.cfg

* Avorion linux server installation : https://avorion.fandom.com/wiki/Setting_up_a_server
* Avorion internal server.ini file : https://avorion.fandom.com/wiki/Server#Server_Configuration_Options
    * `AVORION_DATA_PATH/linuxgsm/serverfiles/galaxy/avserver/server.ini`

* Avorion Dedicated Server 
    * steam AppID : 565060
    * steamdb info : https://steamdb.info/app/565060/

# howto

* To activate use : `TANGO_SERVICES_MODULES+=avorion` or `--module=avorion`
* Join IP `avorion.$TANGO_DOMAIN:$AVORION_QUERY_PORT`
* Declare admin users using SteamID64 (in decimal) in `AVORION_LGSM_ADMIN` (see https://steamidfinder.com)


# commands

* admin command ingame : https://wiki.nitrado.net/en/Admin_Commands_Avorion

* available avorion launcher command : https://avorion.fandom.com/wiki/Server
    ```
    /home/linuxgsm/linuxgsm/serverfiles/bin/AvorionServer --version
    2.0.11.34546
    /home/linuxgsm/linuxgsm/serverfiles/bin/AvorionServer --help
    Allowed options:
    --help                         show help message
    --version                      print out version and exit
    --port arg                     listening port of the server
    --query-port arg               internal game query port of the server, 
                                    default: 27003
    --steam-query-port arg         steam query port of the server, default: 27020
    --steam-master-port arg        steam master server port of the server, 
                                    default: 27021
    --ip arg                       binds the server to a specific IP (steam 
                                    networking only)
    --max-players arg              maximum number of online players
    --save-interval arg            timestep between savings
    --server-name arg              server name, will be displayed when queried
    --pausable arg                 whether or not the server can be paused by 
                                    admins when there's only a single player 
                                    online
    --galaxy-name arg              galaxy name, appended to datapath, final path 
                                    will be [datapath]/[galaxyname]
    --datapath arg                 folder the galaxies will be stored in, will be
                                    prepended to galaxy name
    --admin arg                    steam id(s) of the administrator(s) to add to 
                                    the server
    --seed arg                     seed of the server
    --difficulty arg               difficulty of the server, allowed values are: 
                                    -3, -2, -1, 0, 1, 2, 3
    --scenario arg                 scenario to be played, can be: normal, 
                                    creative
    --play-tutorial arg            enable tutorial on first login
    --collision-damage arg         amount of damage done to an object on 
                                    collision, from 0 to 1. 0: no damage, 1: full 
                                    damage. default: 1
    --same-start-sector arg        indicate if all players should start in the 
                                    same sector
    --alive-sectors-per-player arg the amount of sectors with player property 
                                    that are simulated in addition to that 
                                    player's current sector
    --safe-player-input arg        enable to guarantee more cheat-safety, but 
                                    players may experience more lag
    --threads arg                  specifies the number of threads used to update
                                    the sectors
    --generator-threads arg        specifies the number of threads used to 
                                    generate sectors
    --script-threads arg           specifies the number of script background 
                                    threads
    -t [ --trace ] arg             tracing options. Can be more than one. Allowed
                                    values are: network scripting threading io 
                                    database input error warning exception user 
                                    game system debug sound gl all
    --exit-on-last-admin-logout    shut down when last administrator logs out
    --stderr-to-log                redirect std error output from console to log 
                                    file
    --stdout-to-log                redirect std console output from console to 
                                    log file
    --public arg                   deprecated, use --multiplayer instead
    --multiplayer arg              indicate if the server should allow other 
                                    players to join
    --listed arg                   indicate if the server should show up on 
                                    public server lists
    --vac-secure arg               enables VAC checks of players
    --use-steam-networking arg     use steam networking and VAC (if enabled) for 
                                    users
    --force-steam-networking arg   force usage of steam networking and disable 
                                    fallback to TCP
    --immediate-writeout arg       immediately write player data to disk when it 
                                    changes. decreases performance during sector 
                                    changes, but makes server data more consistent
                                    on crash.
    --max-logs arg                 maximum number of logs to keep around, 0 for 
                                    infinite, default: 15
    --rcon-ip arg                  binds the rcon server to a specific IP
    --rcon-port arg                rcon port, default: 27015
    --rcon-password arg            sets the password for the rcon interface. 
                                    without password, rcon is disabled.
    --send-crash-reports arg       when enabled, the server will send anonymous 
                                    system specs and a crash report when it 
                                    crashes.
    --backup-file arg              when set, restores a backup file into the 
                                    server path.
    --init-folders-only            only create galaxy folders, then exit again.
    ```

# ports

* Minimal default game network configuration
    * Game Ports 27000 TCP and UDP
    * Query Port 27003 UDP

* Other ports - need these ?
    * Steam Master Port 27021 UDP
    * Steam Query Port 27020 UDP

