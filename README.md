# Salsa

* WIP - do not use YET*

A central tool to launch game servers

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
    * see available games from pool/modules
* configure a game server
    * override game settings section from `pool/modules/game.env` into `$HOME/salsa.env`



## commands

```
./salsa info
./salsa up
./salsa down
./salsa status
```


## monitoring API

* Each game which use linuxgsm expose 3 http url for monitoring
    * /live /ready /gamedig
    * access an http monitor bridge https://github.com/joshhsoj1902/linuxgsm-docker/blob/master/src/cmd/monitor/monitor.go
    
