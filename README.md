# Salsa

*WIP - do not use YET*

A central tool to launch game servers on lin,ux

## install

```
cd $HOME
git clone https://github.com/StudioEtrange/salsa
cd salsa
./salsa install
```

## configuration

* create a `salsa.env` file into `$HOME/salsa.env`
    * override any value from `salsa/salsa.env`
* pick a domain and set `TANGO_DOMAIN`
* choose games to activate and set `TANGO_SERVICES_MODULES`
    * TANGO_SERVICES_MODULES=csgo vh
* configure a game server
    * override game settings section from `pool/modules/game.env` into `$HOME/salsa.env`



## commands

```
./salsa info
./salsa up [<game id>]
./salsa down [<game id>]
./salsa status [<game id>]
```

* Update/build linuxgsm-docker image. Usefull to update to its latest dockerfile version.

```
./salsa build-lgsm 
```

## supported servers

* see available games from pool/modules or with `./salsa modules list`

|Game|Salsa Game ID|
|-|-|
|7 days to die|sdtd|
|Counter-Strike:Global Offensive|csgo|
|Valheim|vh|

## monitoring API

* Each game which use linuxgsm expose 3 http url for monitoring
    * /live /ready /gamedig
    * access an http monitor bridge https://github.com/joshhsoj1902/linuxgsm-docker/blob/master/src/cmd/monitor/monitor.go
    
