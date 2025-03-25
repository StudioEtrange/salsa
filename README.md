# Salsa

*WIP - do not use YET*

A central tool to launch game servers on linux

## Install

    ```x
    cd $HOME
    git clone https://github.com/StudioEtrange/salsa
    cd salsa
    ./salsa install
    ```

## Configuration

* create a `salsa.env` file into `$HOME/salsa.env`
    * override any value from `salsa/salsa.env`
* pick a domain and set `TANGO_DOMAIN`
* choose games to activate and set `TANGO_SERVICES_MODULES`
    * TANGO_SERVICES_MODULES=csgo vh
* configure a game server
    * override game settings section from `pool/modules/game.env` into `$HOME/salsa.env`



## commands

```
./salsa info [<game id>]
./salsa up --module=<game id> <game id>
./salsa down [<game id>]
./salsa status [<game id>]
./salsa shell <game id>

```

* For game managed by Linux Game Server Manager (LGSM)
```
./salsa lgsm <game id> <command> -- launch a LGSM command (equivalent to ./lgsm-gameserver <command>)
```




## Salsa supported servers

* see available games from pool/modules or with `./salsa modules list`

|Game|Salsa Game ID|Manager|
|-|-|-|
|7 days to die|sdtd|LGSM|
|Counter-Strike:Global Offensive|csgo|LGSM|
|Valheim|vh|LGSM|
|Avorion|avorion|LGSM|

## Monitoring API

* Each game which use linuxgsm expose 3 http url for monitoring
    * /live /ready /gamedig
    * access an http monitor bridge https://github.com/joshhsoj1902/linuxgsm-docker/blob/master/src/cmd/monitor/monitor.go
    

## About Linux Game Server Manager (LGSM)


* supported games : https://linuxgsm.com/servers/
* salsa use Linux Game Server Manager (LGSM) from a docker container : https://github.com/StudioEtrange/linuxgsm-docker
    * Update/build studioetrange/linuxgsm-docker image. Usefull to update to its latest dockerfile version.
        ```
        ./salsa lgsm build
        ```
    * studioetrange/linuxgsm-docker deploy a full LGSM installation into `$CTX_DATA_PATH/<game_id>/linuxgsm`
* set `LGSM_DEFAULT_CFG_DIRNAME` variable with folder in https://github.com/GameServerManagers/Game-Server-Configs


### LGSM Configuration files

* There is two kind of configuration files
    * `LinuxGSM Config Files` are config files mainly LinuxGSM itself and some game config used to launch the game server
        * File extension is `.cfg`
        * files are located in `$CTX_DATA_PATH/<game_id>/linuxgsm/lgsm/config-lgsm/<server_name>`
        * i.e for avorion dedicated server : `$CTX_DATA_PATH/avorion/linuxgsm/lgsm/config-lgsm/avserver`
        * config files are splitted in several files with a resolution priority order `_default.cfg` -> `common.cfg` -> `<server_name>.cfg` (i.e `avserver.cfg`)
        * Setting an `LGSM_<variable>=<value>` variable at launch or in env file will populate the `common.cfg` conf file with `<variable>=<value>`
        * docker image add `LGSM_SOURCETVPORT` and `LGSM_CLIENTPORT` if empty https://github.com/StudioEtrange/linuxgsm-docker/blob/master/docker-runner.sh#L110
    * `Game Server Config Files` are specific configs the for game server
        * Files extension are various
        * Default game server configs are here : https://github.com/GameServerManagers/Game-Server-Configs
        * To obtain files location try to use `details` command :  `./salsa lgsm <game_id> details`
    
* game config used at launch defined into `LinuxGSM Config Files` may be overriden by rule defined in `info_game.sh`. Some game config are extracted from `Game Server Config Files` ones defined in `LinuxGSM Config Files`.
    * Sample 
        * ark game config from `LinuxGSM Config Files` : https://github.com/GameServerManagers/LinuxGSM/blob/8f6c349dbd7abeb0e368e5c298bbe378146f4aa2/lgsm/config-default/config-lgsm/arkserver/_default.cfg#L12
        * ark `info_game.sh` wich extract game config from `Game Server Config Files` :  https://github.com/GameServerManagers/LinuxGSM/blob/8f6c349dbd7abeb0e368e5c298bbe378146f4aa2/lgsm/functions/info_game.sh#L42

## About Source Engine

* Source Engine have Source Dedicated Servers (SRCDS) : https://developer.valvesoftware.com/wiki/Source_Dedicated_Server
* SRCDS ports requires are:
    * 27015 TCP/UDP (game transmission, pings and RCON) - Can be changed using -port on startup
    * 27020 UDP (SourceTV transmission) - Can be changed using +tv_port on startup
    * 27005 UDP (Client Port) - Can be changed using -clientport on startup
    * 26900 UDP (Steam Port, outgoing) - Can be changed using -sport on startup
* SourceTV offers the ability to have an unlimited number of spectators watching online games based on the Source Engine. 

## About Steam

* Steam Ports Dedicated or Listen Servers https://help.steampowered.com/en/faqs/view/2EA8-4D75-DA21-31EB
    * TCP local port 27015 (default): SRCDS Rcon port
    * UDP local port 27015 (default): gameplay traffic


## RCON

* rcon web client : https://github.com/rcon-web-admin/rcon-web-admin