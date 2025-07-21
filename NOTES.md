

- [Video Games](#video-games)
  - [Game multiplayer servers](#game-multiplayer-servers)
  - [Tools \& links](#tools--links)
  - [Storage](#storage)
  - [Complete retrogaming distribution](#complete-retrogaming-distribution)
  - [Game Streaming](#game-streaming)
  - [Emulators](#emulators)
  - [Web Emulators](#web-emulators)
  - [Web launcher](#web-launcher)
  - [Game Launcher](#game-launcher)
  - [Website running emulators](#website-running-emulators)
  - [Games collection frontend](#games-collection-frontend)
  - [Emulator frontend](#emulator-frontend)
  - [Emulation : Rom manager](#emulation--rom-manager)
  - [Emulation : Rom database](#emulation--rom-database)
  - [Scrapper](#scrapper)
  - [Emulation : Rom NOTES](#emulation--rom-notes)
  - [Emulation : Roms](#emulation--roms)
- [Physical games](#physical-games)
  - [board games](#board-games)
  - [card games](#card-games)

# Video Games


## Game multiplayer servers

* Sample traefik minecraft server : https://community.traefik.io/t/how-to-reverse-proxy-a-minecraft-bedrock-server/6110

* Linux Game Server 
    * docs https://docs.linuxgsm.com/
    * Linux GSM into docker : https://github.com/joshhsoj1902/linuxgsm-docker
        * unit test : https://github.com/joshhsoj1902/linuxgsm-docker/blob/master/.circleci/config.yml
    * gamedig : https://docs.linuxgsm.com/requirements/gamedig -- query game server
        * gamedig api : https://github.com/TheBekker/gamedig-api

* Docker ark server : https://github.com/DrPsychick/docker-linuxgsm-ark

* Docker game servers : https://github.com/OpenSourceLAN/gameservers-docker

* dos games in docker with js-dos : https://earthly.dev/blog/dos-gaming-in-docker/

* docker + dosbox + vnc + websocket : 
    * https://github.com/theonemule/dos-game
    * https://www.wintellect.com/docker-fueled-nostalgia-building-a-retro-gaming-rig-on-kubernetes/


* Game Server manager/UI
    * Easy-wi
        * https://easy-wi.com/
        * https://github.com/easy-wi/developer
        * Gameserver, Voiceserver Webinterface
    * Pterodactyl Panel
        * https://pterodactyl.io/
        * https://github.com/pterodactyl/panel
        * Used internally by some game servers commercial provider
        * pterodactyl games images : https://github.com/orgs/hcgcloud/repositories
        * pterodactyl image for source engine games : https://github.com/CreatorsTF/pterodactyl-srcds-debian-buster
    * LinuxGamePanel
        * https://github.com/Grimston/LinuxGamePanel

## Tools & links

* nodejs library to ping game server https://github.com/gamedig/node-gamedig



## Storage

* WINDOWS rclone usage for roms ; mount + local copy : https://www.reddit.com/r/launchbox/comments/i6wnfi/launchbox_rclonegsuite_for_unlimited_game_storage/
    * Frontend launchbox on windows play machine
    * google drive 
    * rclone to mount folder on windows play machine
    * a windows batch script which first download game on local host and second launch correct emulator with downloaded rom (instead of playing with rom from the cloud)






## Complete retrogaming distribution

* RecalBox
    * distribution emulation with EmulationStation2 + Retroarch
    * install recalbox OS on a machine
    * https://www.recalbox.com/
    * https://gitlab.com/recalbox/recalbox
    * https://gitlab.com/recalbox/recalbox-emulationstation
    * https://gitlab.com/recalbox/recalbox-themes
    * share metadata on network (FR) : https://recalbox.gitbook.io/documentation/v/francais/tutoriels/reseau/partage/charger-ses-roms-depuis-un-partage-reseau-samba-un-nas-par-exemple

* Batocera
    * fork recalbox for linux
    * best for PC than recalbox ?
    * bug on atom cherytrail : https://forum.batocera.org/d/900-batocera-sur-z83-ii-intel-atom-x5-z8350-works-well-but-no-sound/5
    * share metadata on network : https://wiki.batocera.org/store_games_on_a_nas
    * use pacman as package manager and build your own package : https://wiki.batocera.org/pacman_package_manager

* Retropie
    * built primarly for raspberrypi
    * build ontop of raspbian - can be installed as package (instead of a full distro)
    * distribution emulation with (ES) (default frontend) + Retroarch + Others emulators
    * harder and more configurable than recalbox or batocera
    * https://retropie.org.uk/
    * https://github.com/RetroPie
    * https://github.com/RetroPie/EmulationStation
    * https://github.com/retropie/retropie-setup/wiki/themes
    * https://github.com/search?q=org%3ARetroPie+es-theme&unscoped_q=es-theme

* EmulELEC
    * for processor Amlogic (mainly android boxes - work on anbernic device rg351mp)
    * https://github.com/EmuELEC/EmuELEC
    * https://github.com/EmuELEC/EmuELEC/wiki
    * https://emuelec.discourse.group/
    * Retro emulation for Amlogic devices. Based on CoreELEC and Lakka with tidbits from Batocera. Combined them with Batocera-Emulationstation and some standalone emulators (Advancemame, PPSSPP, Reicast, Amiberry and others).

* retrobat
    * https://www.retrobat.ovh/
    * distribution for windows
    * auto install emulation station, retroarch and other emulator

* recalbox vs retropie 
    * https://www.domo-blog.fr/comparatif-solutions-retrogaming-raspberry/
    * recalbox vs retropie vs lakka vs batocera : https://www.electromaker.io/blog/article/retropie-vs-recalbox-vs-lakka-for-retro-gaming-on-the-raspberry-pi

* Retroarch 
    * https://www.retroarch.com/
    * RetroArch is a kind frontend for emulators, game engines and media players.
    * it also includes a variety of emulators as cores

* Lakka.tv
    * http://www.lakka.tv/
    * OS distribution for pc and others based on LibreELEC and retroarch

* Guide for Nvidia shield : retroarch + pegasus frontend + skraper https://rentry.co/auea3


* Complete distributions list for RaspberryPI4 https://www.arcadepunks.com/download-raspberry-pi-4-images/




## Game Streaming

* moonlight [streaming client]
    * https://moonlight-stream.org/
    * https://github.com/moonlight-stream
    * open source implementation nvidia gamestream protocol
    * client android, iOS , win, linux,Mac, web chrome, PS Vita, raspberry Pi
    * non multitenant
    * LG webos client : https://github.com/mariotaku/moonlight-tv

* parsec
    * non free
    * https://parsec.app/
    * https://github.com/parsec-cloud/
    * stream a game from a PC
    * client mac/win/linux/web
    * server Hosting is only available for Windows 8.1+
    * use H265 for encoding video
    * setup with VM on unraid and parsec : https://www.reddit.com/r/unRAID/comments/d2fgv8/my_experience_with_cloud_gaming_and_an_allinone/

* rainway [ABANDONNED]
    * https://github.com/RainwayApp
    * server windows 10
    * client web https://play.rainway.com/
    * multitenant : non
    * stream the game (an non the entire pc)

* retroarcher
    * plex plugin
    * stream game from a windows server to plex client
    * support openstream and sunshine and geforce experience for streaming technologies
    * RetroArcher metadata plugin for Plex : https://github.com/LizardByte/RetroArcher-plex
    * Game streaming server / front-end : https://github.com/LizardByte/RetroArcher

* sunshine [SEEMS A GOOD CHOICE]
    * https://github.com/LizardByte/Sunshine
    * https://app.lizardbyte.dev/Sunshine/?lng=en
    * old : https://github.com/loki-47-6F-64/sunshine
    * sunshine is a host server for moonlight streaming client. Self-hosted game stream host for Moonlight.
    * it replaces NVIDIA GameStream
    * https://www.reddit.com/r/pcgaming/comments/zoytbv/comment/j0qqpmp/
      * a dockerized version with HW support : GOW
        * https://github.com/games-on-whales/gow/tree/master/images/sunshine

* wolf (alpha)
  * Stream virtual desktops and games running in Docker
  * Wolf is a streaming server for Moonlight that allows you to share a single server with multiple remote clients in order to play videogames!
  * It's a specific tool for a specific need, are you looking for a general purpose streaming solution? Try out Sunshine!
  * https://github.com/games-on-whales/wolf


* GOW Games on Whales [SEEMS A GOOD CHOICE]
  * complete system that combine use sunshine or wolf to stream dockerised app using moonlight protocol
  * https://games-on-whales.github.io/gow/_images/gow-diagram.svg  
  * A collection of Docker images ready to be used by Wolf or sunshine in order to run games and apps on a remote host!
  * https://github.com/games-on-whales/gow 
  * https://games-on-whales.github.io/gow/
  * https://www.reddit.com/r/docker/comments/o4tz1c/gaming_on_a_server_running_retroarch_on_docker/



* open-stream [SEEMS A GOOD CHOICE]
    * https://open-stream.net/#
    * use moonlight as client
    * Open Stream is a fork open Sunshine Server. Creating open source solution for Gaming and Desktop Management.
    * open-stream is a host server for moonlight streaming client
    * https://github.com/LS3solutions/openstream-server


## Emulators

* NonMAME
    * Recommendend list of emulators http://nonmame.retrogames.com/
    * NonMAME documents the best open-source emulator for any given system, with priority given to MAME due to its comprehensive scope. This primarily involves arcade, computer, console and handheld systems.

* Ryujinx
    * https://github.com/Ryujinx/Ryujinx [DOWN]
    * switch emulator for win/linux/macos
    * doc : https://github.com/Abd-007/Switch-Emulators-Guide/blob/main/Ryujinx.md
    * forks : 
      * https://github.com/Ryubing/Ryujinx [BEST]
      * https://github.com/ryujinx-mirror/ryujinx

## Web Emulators

* Lists of web emulators 
    * https://github.com/fcambus/jsemu
    * https://github.com/pengan1987/computer-museum-dnbwg

* JSMESS Mame 
    * mame javascript
    * build doc : https://docs.mamedev.org/initialsetup/compilingmame.html#emscripten-javascript-and-html
    * build exemple + use in emularity : https://github.com/simonjohngreen/oldguysarcade

* em-Dosbox
    * https://github.com/dreamlayers/em-dosbox
    * js version of dosbox

* js api over em-Dosbox (have an embedded version of em-Dosbox)
    * https://js-dos.com/
    * https://github.com/caiiiycuk/js-dos
    
* Dosee
    * https://github.com/bengarrett/DOSee
    * web frontend (based on work from emularity) for dos games wich embed em-dosbox

* js-dos
    * web emulator for dos games
    * https://js-dos.com/

* Scummvm for web
    * https://github.com/scummvm/scummvm/tree/master/dists/emscripten
    * demo
      * https://github.com/chkuendig/scummvm-demo
      * https://scummvm.kuendig.io/scummvm.html

* retroarch libretro cores web emscript builders
    * from libretro https://buildbot.libretro.com/stable/1.9.9/emscripten/
    * from libretro build instruction : https://github.com/libretro/RetroArch/blob/master/pkg/emscripten/README.md
    * from linuxserver emulatorjs 
      * https://github.com/thelamer/retrostash
      * ource to build libretro cores for emulatorjs
    * from retro-assembly https://github.com/arianrhodsandlot/retro-assembly-vendors
    * from retro-assembly https://github.com/arianrhodsandlot/retroarch-emscripten-build


* crocods
    * https://crocods.org/web/ https://crazypiri.eu/crocods/
    * amstrad cpc

* cpcbox
    * amstrad cpc
    * https://retroshowcase.gr/cpcbox-master/
    *  embeded version of amstrad cpc web in portal with game :  https://bzhgames.xyz/index.php

* tiny8bits
    *  amstrad cpc, commodre, ...
    *  core emulator : https://github.com/floooh/chips
    *  A toolbox of 8-bit chip-emulators, helper code and complete embeddable system emulators in dependency-free C headers (a subset of C99 that compiles on gcc, clang and cl.exe).
    *  sample code : https://github.com/floooh/chips-test
    *  js wasm version : https://floooh.github.io/tiny8bit/
    *  embeded version of amstrad cpc web in portals
       *  https://bzhgames.xyz/index.php
       *  https://acpc.me/#ACME
      

## Web launcher

* WebtroPie
    * https://github.com/gazpan/WebtroPie
    * https://github.com/StudioEtrange/WebtroPie
    * technical discussion : https://retropie.org.uk/forum/topic/10164/webtropie
    * web rom brower and manager for retropie with emulationstation theme
    * adaptation for batocera : https://github.com/Broceliande/batocera.webtropie
    * some tests : https://gist.github.com/StudioEtrange/235cd22d786c4a0f7fe7ca7e336610ea

* Retropie + webrtc with uv4l
    * https://www.linux-projects.org/uv4l/tutorials/play-retropie-in-browser/

* Emularity
    * https://www.archiveteam.org/index.php?title=Emularity
    * https://github.com/db48x/emularity
    * Easily embed emulators. Emularity is a loader designed to be used with a family of in-browser emulation systems
    * Technical documentation : https://github.com/db48x/emularity/blob/master/TECHNICAL.md
    * 3 supported emulators : MAME (=JSMESS) for 60 systems, EM-DOSBox for DOS, and SAE for Amiga
    * InternetArchive.org
        * Emularity is used in InternetArchive.org
        * documentation of InternetArchive.org Emulation system : https://web.archive.org/web/20201129233231/http://digitize.archiveteam.org/index.php/Internet_Archive_Emulation
        * Software library of dos games (=ROM) loaded with Emularity : https://archive.org/details/softwarelibrary_msdos_games
        * Sofware library for arcade games (=ROM) loaded with Emularity : https://archive.org/details/internetarcade
        * Sofware library for console games (=ROM) loaded with Emularity : https://archive.org/details/consolelivingroom
        * The Emularity Engine Collection : https://archive.org/download/emularity_engine_v1
        * Emularity BIOS Collection : https://archive.org/details/emularity_bios_v1
        * Search for various items about emularity : https://archive.org/search.php?query=Emularity%20Engine
    

* Retrojolt
    * https://github.com/gamejolt/retrojolt 
    * it is a wrapper around emularity AND an emulators builder for emularity
    * example usage of retrojolt from inside gamejolt website : https://github.com/gamejolt/gamejolt/blob/ce912503b7e2cb7c59023c5b6077c1209b537278/src/gameserver/components/embed/rom/rom.ts
    * example retrojolt emulator compile scripts https://github.com/gamejolt/retrojolt/tree/main/scripts
    * test retroljolt
        ```
        git clone https://github.com/gamejolt/retrojolt
        cd retrojolt
        git submodule init
        git submodule update
        
        docker run -it --rm --name retrojolt -p :8080 -v $(pwd):/retrojolt node bash
        cd /retrojolt
        # install typescript
        npm install typescript
        # yarn commands are defined in package.json
        yarn build
        yarn start
        see http://localhost:port/test
       ```

* Gamejolt
    * https://github.com/gamejolt/gamejolt
    * a video game web portal - which use Retrojolt (https://gamejolt.com/)
    * test gamejolt
        ```
        git clone https://github.com/gamejolt/gamejolt
        cd gamejolt
        git submodule init
        git submodule update
        
        docker run -it --rm --name gamejolt -p :8080 -v $(pwd):/gamejolt node bash
        cd /gamejolt
        # yarn commands are defined in package.json
        yarn
        # TODO problem : do not listen on 0.0.0.0 only localhost
        yarn run dev
        see http://localhost:port/test
       ```

* Emupedia
    * https://github.com/Emupedia/emupedia.github.io
    * The purpose of Emupedia is to serve as a nonprofit meta-resource, hub and community
    * EmuOS
        * https://github.com/Emupedia/EmuOS
        * EmuOS is used as a Web Frontend for Emupedia projects.
        * demo : https://emupedia.net/beta/emuos/ Embbed games, with DOSBox, js-dos emularity and other web emulator
    * list of games : https://github.com/orgs/Emupedia/repositories?page=1


* retroarch web [SEEMS A GOOD CHOICE]
    * based on Retroarch and includes severals libretro  compiled with emscript : https://buildbot.libretro.com/stable/1.9.9/emscripten/
    * https://web.libretro.com/
    * retroarch-web
        * https://github.com/Inglebard/dockerfiles/tree/retroarch-web
        * https://github.com/Inglebard/dockerfiles/tree/retroarch-web-nightly
        * https://hub.docker.com/r/inglebard/retroarch-web
    * retroarch web player build instruction : https://github.com/libretro/RetroArch/blob/master/pkg/emscripten/README.md
    * RetroArch web player basic host installation script on docker nginx(ubuntu) https://gist.github.com/jribal/8e73ff1e41aa54a9032f965d82706bf3


* webretro [OLD]
    * RetroArch in your browser
    * RetroArch ported to WebAssembly with emscripten
    * https://github.com/BinBashBanana/webretro
    * demo : https://binbashbanana.github.io/webretro/

* linuxserver emulatorjs (not related to EmulatorJS) [SEEMS A GOOD CHOICE]
    * web frontend with libretro js emulator (retroarch)
    * https://github.com/linuxserver/emulatorjs/
    * https://github.com/linuxserver/docker-emulatorjs
    * https://github.com/linuxserver/libretrojs (prepared js library for web site)
    * source to build libretro cores for linuxserver emulatorjs : https://github.com/thelamer/retrostash


* EmulatorJS (not related to linuxserver/emulatorjs) [SEEMS A GOOD CHOICE]
    * Self-hosted Javascript emulation for various system
    * Embed an emulator with javascript code into an HTML page
    * support only a few old system
    * As an example : Vimmm vault use Emulatorjs https://vimm.net/
    * https://emulatorjs.org/
    * https://github.com/EmulatorJS/EmulatorJS
    * demo : https://demo.emulatorjs.org/

* A web-based collaborative RetroArch frontend
    * https://github.com/ctrlaltf2/lets-play



* Retroassembly [SEEMS A GOOD CHOICE]
    * webfrontend to upload rom and play in browser
    * https://retroassembly.com/ 
      * old version not maintened : "classic" : https://classic.retroassembly.com/
      * new version : "next" : https://next.retroassembly.com/
    * https://github.com/arianrhodsandlot/retro-assembly
    * issue : not ready yet for self hosting : 
      * https://github.com/arianrhodsandlot/retro-assembly/discussions/10
      * https://hub.docker.com/r/arianrhodsandlot/retro-assembly/tags
      * can not set a default rom local folder at launch, we have always to use import folder from browser at runtime
    * based on Nostalgist.js which is built on top of RetroArch Emscripten builds.
      * https://nostalgist.js.org/
      * https://github.com/arianrhodsandlot/nostalgist

* webrcade [SEEMS A GOOD CHOICE - BUT NOT FOR MOBILE - OTHER PB : have specific configured libretro modified cores so difficult to add one]
    * https://github.com/webrcade/webrcade
    * WebЯcade consists of an intuitive web-based front end that enables playing popular gaming content entirely within the context of the browser
    * use modified libretro cores (ex : https://github.com/webrcade/webrcade-app-retro-a5200/tree/main)
    * https://www.webrcade.com/
    * https://docs.webrcade.com/
    * https://play.webrcade.com/
    * webrcade use "feed". A "feed" is a bundle with emulators configuration and games configuration linked to URL ressources
    * do not support Touch-based (virtual) gamepad controls ! Mobile gaming impossible !

## Game Launcher

* Heroic
  * A games launcher for GOG, Amazon and Epic Games for Linux, Windows and macOS.
  * https://heroicgameslauncher.com/
  * https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher

* Whisky [ABANDONNED]
  * Wine wrapper for macos
  * https://github.com/Whisky-App/Whisky
  * https://getwhisky.app/

## Website running emulators

* Various list
    * https://bzhgames.xyz/amstrad/dsk/gauntlet.dsk (for amstrad cpc, use tiny8bits cpc and cpcbox)
    * https://www.retrogames.cc/
    * http://emulator.online/ (flash emulator)
    * https://lifehacker.com/the-best-web-sites-to-get-your-retro-gaming-fix-1823765757
    * http://pica-pic.com/ (flash)
    * https://dos.zczc.cz/ (with emularity and em-dosbox)
        * https://github.com/rwv/chinese-dos-games-web
        * https://github.com/rwv/chinese-dos-games (metadata)
    * https://www.myabandonware.com/ run only dosbox games
    * Vimmm vault use Emulatorjs https://vimm.net/
    
* From archive.org
    * Emularity software library of dos games : https://archive.org/details/softwarelibrary_msdos_games
    * Emularity sofware library for arcade games : https://archive.org/details/internetarcade
    * Emularity sofware library for console games : https://archive.org/details/consolelivingroom


## Games collection frontend

* gameyfin
    * Manage your video games in a web page
    * can download games from the web page
    * https://github.com/gameyfin/gameyfin
    * https://hub.docker.com/r/grimsi/gameyfin
    * scrap data from IGDB

## Emulator frontend

A frontend is a launcher of emulators

* List
    * https://emulation.gametechwiki.com/index.php/Comparison_of_Emulator_Frontends

* pegasus
    * https://pegasus-frontend.org/
    * https://github.com/mmatyas/pegasus-frontend
    * opensource
    * multiplatform (Windows, Linux, Mac, Android, all Raspberries, Odroids)
    * based on Qt
    * support games library from emulators and steam and gog
    * proposed in retropie installer
    * do not have any scrapper capability
    * can read metadata format of emulation station, skraper, steam, gog, launchbox, logiqx and its own (pegasus)
    * docker : https://github.com/games-on-whales/gow/tree/master/images/pegasus
    * Themes
        * Thema list https://pegasus-frontend.org/tools/themes/
        * Theme Switch-like adaptated for Retroid Pocket2 https://github.com/dragoonDorise/RP-Switch
        * skylineOS is a theme for Pegasus Frontend forked from switchOS that aims to recreate the experience of Nintendo's Switch https://github.com/RBertoCases/skylineOS
    * Guide and preconfiguration data to install pegasus on Retroid Pocket2 https://github.com/dragoonDorise/pegasus-rp2-metadata
    
* EmulationStation
    * https://emulationstation.org/
    * https://github.com/Aloshi/EmulationStation/tree/unstable
    * proposed as a choice when doing retropie install step
    * gamelist.xml file cli manager : https://github.com/JayCanuck/gamelist-utils
    * gamelist.xml file GUI editor (windows only) : https://github.com/andresdelcampo/GameList_Editor

* Dig
    * https://digdroid.com/
    * android only

* Launchbox (windows only) - game front end
    * have scrapper capability
    * closed source
    * Launchbox is free and have premium paid features too

* openemu (mac only) - game front end
* lutris (linux only) - game front end

* AttractMode
    * http://attractmode.org/
    * https://github.com/mickelson/attract
    * Attract-Mode is a graphical frontend for command line emulators such as MAME, MESS and Nestopia.
    * Linux and macos
    * proposed in retropie installer

* Snowflake
    * https://github.com/SnowflakePowered/snowflake
    * https://snowflakepowe.red/
    * framework to build frontend
    * able to build frontend with a metadata backend (server)    
    * under construction

* CoinOps
    * Frontend for XBox or PC
    * Runs under windows
    * CoinOps Next 2 : https://www.arcadepunks.com/coinops-next-2-up-to-date-january-2021-edition-from-furio-r2-r3-arcade-arcade-r2-r3-art/

* Retropie Frontend Chooser
    * https://github.com/mmatyas/retropie-frontendchooser
    * This is a graphical utility for installing various emulator frontends for RetroPie and choosing which one to start on system startup

* Artflix is a thema for some distributions
    * https://github.com/fagnerpc/Alekfull-ARTFLIX
    * compatible with BATOCERA, RETROBAT, EMUELEC and BATOCERA PLUS

## Emulation : Rom manager

Currently Used :

* Romcenter (well known)
    * http://www.romcenter.com/
    * tutorial : https://www.youtube.com/watch?v=1JtIh5u2Ko4
    * good enough
    * source code no available - closed source
    * issues : https://bitbucket.org/ebolefeysot/romcenter/

* Romvault (well known, BEST CHOICE)
    * http://www.romvault.com/ 
    * open source code (incomplete ?) https://github.com/RomVault/RVWorld
    * windows GUI only binary - code is in C# (try Mono?)
    * command line version binary for windows and linux
    * tutorial interesting : https://www.youtube.com/embed/yUOIYYbZuAg
    * can manipulate several DAT files simultaneously 
        * so we can build a folder structure for each device puting a wanted dat files
    * QUICK INSTALL :
        * download ROMVault.zip from https://www.romvault.com/ and unzip it in a folder
        * dowload RVCmd.zip for windows and linux from https://www.romvault.com/ and unzip it in the same folder
        * download TrrntZipUI.zip and TrrntZipCMD.zip https://www.romvault.com/trrntzip/ and unzip them in the same folder
        * create a "cache" folder in the same folder
        * Launch ROMVault.exe file
        * Settings / RomVault Settings / DAT Root Directory : DatRoot / Use SET button and choose your directory containing your dat files (i.e: W:\VIDEO_GAMES_ROM\[ROM_LAYOUT])
        * Settings / Directory settings / Rule Path : RomVault, Dir Location : your directory that will contains your rom files (i.e: W:\VIDEO_GAMES_ROM\[ROM_ROOT]) then use APPLY button
        * Click "Add ToSort" : 
            * Add any folders that contains roms to scan and make triage with dat files (i.e: W:\VIDEO_GAMES_ROM\[SCAN_VAULT])
            * Choose one as a primary
            * With right button, set the folder named "cache" as Cache. (by default its the folder named "ToSort"). This folder shloud de local, not on the network, for performance purpose. And there is no need to sync this folder elsewhere (ie with dropbox or synlogy drive sync), it's a temp folder
    * QUICK USAGE :
        * Button "Update DATs" to read and update dats files
        * Button "Scan ROMs" will scan all roms in each selected folder and index them. Regardless to what it belongs (RomVault output folder or folder added to sort). It will update the status of selected RomVault output folder about complete and missing rom.



* Romulus
    * https://romulus.cc/  https://romulus.dats.site/
    * closed source
    * windows - but may work with wine on linux and mac
    * weird behaviour : erase files
    * good updater and search of DAT files
    * easyier than romcenter or clrmamepro
    * DAT files format supported : Clrmame pro OLD and XML format, Romcenter, Offlinelist, MESS softlists
    * tutorial by recalbox (FR) : https://wiki.recalbox.com/fr/tutorials/utilities/rom-management/romulus-rom-manager

* gorom
    * https://github.com/shumatech/gorom
    * linux cli utility to manage ROM and manipulate DAT files
    * have a gui (Linux GTK, Windows, and OS X)

* igir [GOOD CHOICE]
    * https://github.com/emmercm/igir
    * A video game ROM collection manager to help filter, sort, patch, archive, and report on collections on any OS.
    * sample organisation with igir : https://igir.io/usage/personal/ [USE THIS to export rom to different platform (like analog pocket or RomM or adam image for anbernic RG350)]
    * cli only
    * windows linux macos
    * Scan for DATs, ROMs, and ROM patches - including those in archives
    * Organize ROM files by console
    * Support 1G1R mode (filter rom to obtain : 1 game 1 rom)
    * Name ROM files consistently, including the right extension
    * Filter out duplicate ROMs, or ROMs in languages you don't understand
    * Extract or archive ROMs in mass
    * Patch ROMs automatically in mass
    * Parse ROMs with headers, and optionally remove them
    * Build & re-build (un-merge, split, or merge) MAME ROM sets
    * Report on what ROMs are present or missing for each console, and create fixdats for missing ROMs
    * commands
      * launch with docker
        ```
        docker run -it --rm \
            --volume "$PWD:/pwd" \
            --workdir "/pwd" \
            node:lts \
            npx igir@latest --help
        ```

* oxyromon
    * https://github.com/alucryd/oxyromon
    * ROM organizer written in Rust. Like most ROM managers, it checks ROM files against known good databases. It is designed with archiving in mind
    * Use DAT files
    * support validation of CHD format
    * support NoIntro and Redump and MAME dat files

* cartridge
    * A self-hosted game library [OLD]
    * https://github.com/unclebacon-live/cartridge
    
* romm [SEEMS A GOOD CHOICE FOR WEB]
    * web based - A beautiful, powerful, self-hosted rom manager and player.
    * https://github.com/rommapp/romm
    * https://romm.app/
    * embed emulatorjs.org to play roms
    * https://korben.info/gerer-sa-collection-de-roms-de-jeux-retro-avec-romm-le-manager-ultime.html
    * have authentification mechanism but do not support SSO https://github.com/rommapp/romm/issues/580
    * compatible to use with MuOS(MustardOS) https://github.com/MustardOS a custom firmware for handled like anbernic device
    * compatible to use with playnite for windows (a gamelauncher)
    * can use rom file hash from hasheous https://github.com/gaseous-project/hasheous for identification

* gaseous-server [SEEMS A GOOD CHOICE FOR WEB]
    * web based
    * [Gaseous system.](https://github.com/gaseous-project/gaseous-server)
    * A game ROM manager, with a built in web based emulator using multiple sources to identify and provide metadata
    * support Dat files
    * embed emulatorjs.org to play roms
    * can use rom file hash from hasheous https://github.com/gaseous-project/hasheous for identification (hasheous is from same project)


* retrom
    * https://github.com/JMBeresford/retrom
    * A centralized game library/collection management service with a focus on emulation

Not Used :

* ClrmamePro (well known)
    * ​https://mamedev.emulab.it/clrmamepro/


* JRomManager (not really good)
    * https://github.com/optyfr/JRomManager
    * opensource


* ROMba (very limited, not known)
    * https://github.com/uwedeportivo/romba
    * command line ony
    * linux - macos
    * While its core functionality is similar to tools like ROMVault and CLRMamePRO, ROMba takes a unique approach by storing ROMs in a de-duplicated way, and allowing you to "build" any set you need on demand.
    * pb when using docker version to start it : first create some folders and mount them into /var/romba

* romen (not known)
    * https://gitlab.com/varikin/romen
    * linux mac and windows



## Emulation : Rom database

* DAT files
    * NOTINRO : Datomatic No Intro http://datomatic.no-intro.org/    [PREFERE]
    * REDUMP : http://redump.org/ [PREFERE]
    * TOSEC : https://www.tosecdev.org/ (The Old School Emulation Centre) : TOSEC try to index everything included cracked ROM while no-intro and redump only DAT 1:1 ROMs\ISOs.
    * TOSEC vs REDUMP vs NOINTRO : https://www.reddit.com/r/Roms/comments/y9jzcl/tosec_vs_redumpnointro/
    * MAME : https://www.progettosnaps.net/index.php
    * https://www.advanscene.com/ (mainly nintendo)
    * http://www.progettosnaps.net/dats/ (specialized for MAME)
    * DAT files format definition : https://github.com/SabreTools/SabreTools/wiki/DatFile-Formats
    * A list of known dat files : https://wiki.romvault.com/doku.php?id=supported_dats


* DAT files management
    * SabreTools 
        * https://github.com/SabreTools/SabreTools
        * multipurpose DAT file management tool
        * command line
        * windows
    * DatUtil (old)
        * http://www.logiqx.com/Tools/DatUtil/
        * command line windows binary
        * closed source
        * DatUtil was created to aid in the creation of dat files for Rom Managers such as ClrMamePro and RomCenter
        * tutorial (FR) : https://forum.recalbox.com/topic/4571/tutorial-datutil
    * Retool
        * https://github.com/unexpectedpanda/retool
        * GUI Tool
        * windows binary and linux/macos if python installed
        * modify existing DAT files to create 1G1R (1 game 1 rom) DAT converted files
        * can filter DAT content by language, area and several parameters   
    * Verify dump
        * can validate CHD files for a DAT files containing bin/cue files. (It convert CHD files to validate them)
        * https://github.com/j68k/verifydump
    * chdman
        * convert cue/bin and iso to CHD format
        * chdman is included in MAME
        * https://github.com/charlesthobe/chdman?tab=readme-ov-file
        * https://wiki.recalbox.com/fr/tutorials/utilities/rom-conversion/chdman
        * windows frontend : https://github.com/umageddon/namDHC
    * binmerge
        * merge bin files into one
        * https://github.com/putnam/binmerge

* EverDrive-Packs-Lists-Database
    * https://github.com/SmokeMonsterPacks/EverDrive-Packs-Lists-Database
    * The EverDrive Packs Lists Project is an archival research initiative with the goal of allowing users to build real-hardware optimized ROM packs based on suggested file/folder layouts compiled by SmokeMonster.
    * use SMDB file format

* Shiragame
    * shiragame is a games and ROM SQLite database that is automatically updated twice weekly by compiling DAT files from cataloguing organizations like Redump, No-Intro, or TOSEC and more
    * allows you to look up game titles by ROM hash, or serial. 
    * https://github.com/SnowflakePowered/shiragame
    * https://shiragame.snowflakepowe.red/
    * https://stone.snowflakepowe.red/#/defs/platforms list of platform managed by database
    * shiratsu : https://github.com/SnowflakePowered/shiratsu - scripts that aggregate data for shiragame

* lizardbyte db 
    * Video game database based on IGDB
    * https://db.lizardbyte.dev/
    * https://github.com/LizardByte/db

* Universal-DB
    * store information for 3DS/DS homebrews
    * https://db.universal-team.net/
    * https://github.com/Universal-Team/db
    * https://gbatemp.net/threads/universal-db-an-online-database-of-ds-and-3ds-homebrew.575218/

* DAT files used by retroarch to indentify rom
    * https://github.com/libretro/libretro-database
    * bios files used by retroarch https://github.com/libretro/libretro-database/blob/master/dat/System.dat 


## Scrapper

* Scrapers list from recalbox (FR) : https://recalbox.gitbook.io/documentation/v/francais/tutoriels/utilitaires/gestion-des-scrappes/liste-des-utilitaires-de-scrape

* Skyscraper : Lars Muldjord's Skyscraper
    * https://github.com/muldjord/skyscraper
    * integration with EmulationStation, AtrtractMode, Pegasus frontend
    * for linux (works on win and macos but nonofficaly)
    * use various source for games items
    * by default integrated into retropie and was designed for it

* Steven Selph's Scraper 
    * https://github.com/sselph/scraper
    * ssscraper with fastscraper : https://forum.recalbox.com/topic/2594/batch-scrape-your-roms-on-your-pc-fastscraper

* Skraper 
    * https://www.skraper.net/ 
    * client desktop win/linux/macos
    * support emulationstation (ES) metadata
    * use ScreenScraper.fr for games items, need an account for better speed
    * integration with recalbox, retropie and launchbox
    * tutorial (FR) : https://recalbox.gitbook.io/documentation/v/francais/tutoriels/utilitaires/gestion-des-scrappes/skraper-scrapper-ses-roms
    * needs a lot of space for downloaded metadata cache

* Arrm (Another Gamelist, Roms manager, and Scraper for Recalbox, Batocera, Retropie, Retrobat & Emulationstation)
    * http://jujuvincebros.fr/hard-soft/arrm-gamelist-roms-manager-scraper
    * windows - no Linux (nor Mono nor Wine on may 2019), no Mac OS


## Emulation : Rom NOTES

* Arcade ROM type https://forums.launchbox-app.com/uploads/monthly_2018_09/image.png.f013083ac5b1b2122d8f3c1e3a0b5c73.png
    * Full non merged rom set : all dependencies of the game in one zip archive including bios files
    * Non merged rom set : all dependencies of the game in one zip archive except bios files
    * Split rom set :  each element of a game are splitted in several zip
    * CHD : compressed hunks of data : game data extracted from cd rom. CHD format is a compressed version of iso bin/cue files. Some emulator support CHD format directly

* Guide : Convert SNES ROM's Into CIA's & Install Them ! (OLD/NEW 3DS/2DS) 
    * https://www.youtube.com/watch?v=G6zkMl9UTJM

* Parent/clone and 1G1R concept
    * The parent/clone dat format was created for MAME. A "parent" ROM in MAME contains the base or common files for a game, while "clone" ROMs contains only files that are different from the parent. If you load a clone game in MAME, it's smart enough to load the base files from the parent, and any of the modified files it needs from the clone.
    * ROM/Dat manager mode "1G1R" is a mode which uses the parent/clone relationships in a dat to set up a group of related titles. It selects a single title from that group based on your region and language preferences and ignores the other titles, in an effort to produce one specific rom versions.

* 3DS Encrypted / Decrypted ROM : https://www.reddit.com/r/Roms/comments/nfp3qp/comment/kjx49tk/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

* Split / Merged / Non split definition
    * https://wiki.recalbox.com/tutorials/utilities/rom-management/romulus/arcade/romulus1.png
    * https://forums.launchbox-app.com/uploads/monthly_2018_09/image.png.f013083ac5b1b2122d8f3c1e3a0b5c73.png


* Demystification and explanation about MAME roms https://choccyhobnob.com/demystifying-mame-roms/

## Emulation : Roms

* hack for roms : https://www.romhacking.net/hacks/
* translation for roms : https://www.romhacking.net/translations/

# Physical games

## board games

* vassal engine - The open-source boardgame engine
    * https://vassalengine.org/
    * https://github.com/vassalengine/vassal
    * modules : https://vassalengine.org/wiki/Category:Modules

* docker vassal engine :
    * https://hub.docker.com/r/iaalm/vassal
    * https://github.com/iaalm/vassal
    * https://github.com/vassalengine/vassal/issues/10948

* table top simulator
    * games : https://www.nexusmods.com/tabletopsimulator/

## card games

* cockatrice - Cockatrice is an open-source, multiplatform program for playing tabletop card games
    * https://cockatrice.github.io/
    * https://github.com/Cockatrice/Cockatrice

* octgn - Online Card and Tabletop Gaming Network
    * http://www.octgn.net/
    * https://github.com/octgn/OCTGN

* holotable - Star Wars CCG [OLD]
    * http://holotable.com/

* GEMP Star Wars CCG [OLD]
    * server/client for playing Star Wars CCG using a web browser. The program takes care of the rules so you don't have to
    * https://gemp.starwarsccg.org/gemp-swccg/
    * https://github.com/PlayersCommittee/gemp-swccg-public

* Star Wars CCG VARIOUS
    * Star Wars CCG Card IMAGE Files for use with Holotable. Images used by Holotable, Gemp, and Scomp https://github.com/swccgpc/holotable
    * PlayersCommitee fan association : https://www.starwarsccg.org/
    * online card database 
        * https://scomp.starwarsccg.org/
        * https://github.com/swccgpc/swccg-scomp
        * card data from https://github.com/swccgpc/swccg-card-json/
    * Online deck builder 
        * https://swccgdb.com/ 
        * https://github.com/PrestonStahley/swccgdb 
        * card data from from https://github.com/PrestonStahley/swccgdb-json-data

* GEMP LOTR TCG [OLD]
    * https://github.com/ketura/gemp-lotr
    * https://play.lotrtcgpc.net/gemp-lotr/

* DragnCards
    * https://dragncards.com/
    * https://github.com/seastan/DragnCards
    * DragnCards is a free online multiplayer card game platform for LOTR LCG