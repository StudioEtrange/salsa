

### Game servers

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
    * Pterodactyl Panel
        * https://pterodactyl.io/
        * https://github.com/pterodactyl/panel
        * Used internally by some game servers commercial provider
        * pterodactyl games images : https://github.com/orgs/hcgcloud/repositories
        * pterodactyl image for source engine games : https://github.com/CreatorsTF/pterodactyl-srcds-debian-buster
    * LinuxGamePanel
        * https://github.com/Grimston/LinuxGamePanel


### Game Streaming

* moonlight
    * https://moonlight-stream.org/
    * https://github.com/moonlight-stream
    * open source implementation nvidia gamestream protocol
    * client android, iOS , win, linux,Mac, web chrome, PS Vita, raspberry Pi
    * non multitenant

* parsec
    * https://parsecgaming.com/ 
    * https://github.com/parsec-cloud/web-client
    * stream a game from a PC
    * client mac/win/linux/web
    * server Hosting is only available for Windows 8.1+
    * use H265 for encoding video
    * setup with VM on unraid and parsec : https://www.reddit.com/r/unRAID/comments/d2fgv8/my_experience_with_cloud_gaming_and_an_allinone/

* rainway
    * https://github.com/RainwayApp
    * https://rainway.com
    * server windows 10
    * client web https://play.rainway.com/
    * multitenant : non
    * stream the game (an non the entire pc)


### Tools & links

* nodejs library to ping game server https://github.com/gamedig/node-gamedig



### Storage

* Frontend launchbox on windows play machine + google drive + rclone to mount folder on windows play machine + windows batch script to download game on local host (with rclone copy) at game launch on launchbox instead of playing with rom from the cloud https://www.reddit.com/r/launchbox/comments/i6wnfi/launchbox_rclonegsuite_for_unlimited_game_storage/






### Complete retrogaming distribution

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
    * distribution emulation with EmulationStation (default frontend) + Retroarch + Others emulators
    * harder and more configurable than recalbox or batocera
    * https://retropie.org.uk/
    * https://github.com/RetroPie
    * https://github.com/RetroPie/EmulationStation
    * https://github.com/retropie/retropie-setup/wiki/themes
    * https://github.com/search?q=org%3ARetroPie+es-theme&unscoped_q=es-theme

* retrobat
    * https://www.retrobat.ovh/
    * distribution for windows
    * auto install emulation station, retroarch and other emulator

* recalbox vs retropie 
    * https://www.domo-blog.fr/comparatif-solutions-retrogaming-raspberry/
    * https://www.electromaker.io/blog/article/retropie-vs-recalbox-vs-lakka-for-retro-gaming-on-the-raspberry-pi

* Retroarch 
    * https://www.retroarch.com/
    * RetroArch is a kind frontend for emulators, game engines and media players.
    * it also includes a variety of emulators as cores

* Lakka.tv
    * http://www.lakka.tv/
    * distribution for pc and others based on retroarch

### Emulators

* list of emulators http://nonmame.retrogames.com/
* definition for MAME roms https://choccyhobnob.com/demystifying-mame-roms/

### Web Emulators


* List of web emulators https://github.com/pengan1987/computer-museum-dnbwg

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
    * web frontend (based on work from emularity) for dos games wjhch embed em-dosbox



### Web launcher


* Web retroarch
    * based on Retroarch and includes severals core compiled with emscript : https://buildbot.libretro.com/stable/1.9.9/emscripten/
    * https://web.libretro.com/
    * sample docker image standalone : https://github.com/Inglebard/dockerfiles/tree/retroarch-web

* WebtroPie
    * https://github.com/gazpan/WebtroPie
    * https://github.com/StudioEtrange/WebtroPie
    * technical discussion : https://retropie.org.uk/forum/topic/10164/webtropie
    * web rom brower and manager for retropie with emulationstation theme
    * adaptation for batocera : https://github.com/Broceliande/batocera.webtropie
    * some tests : https://gist.github.com/StudioEtrange/235cd22d786c4a0f7fe7ca7e336610ea

* Emularity
    * https://www.archiveteam.org/index.php?title=Emularity
    * https://github.com/db48x/emularity
    * technical documentation : https://github.com/db48x/emularity/blob/master/TECHNICAL.md
    * loader used by people from internet archive.org
    * 3 supported emulators : MAME (=JSMESS) for 60 systems, EM-DOSBox for DOS, and SAE for Amiga
    * documentaion of Internet Archive.org Emulation system : http://digitize.archiveteam.org/index.php/Internet_Archive_Emulation
    * emularity emulators and bios repository :
        * https://archive.org/download/emularity_engine_v1
        * https://archive.org/details/emularity_bios_v1 
    * Emularity software library of dos games (=ROM) : https://archive.org/details/softwarelibrary_msdos_games
    * Emularity sofware library for arcade games (=ROM) : https://archive.org/details/internetarcade
    * Emularity sofware library for console games (=ROM) : https://archive.org/details/consolelivingroom
    * list of all various items relative to emularity : https://archive.org/search.php?query=Emularity%20Engine


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
    * a video game web portal - which use Retrojolt
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
    * web os with some web version of old games embedded
    * https://github.com/Emupedia/emupedia.github.io
    * demo : https://emupedia.net/beta/emuos/
    * list of games : https://github.com/orgs/Emupedia/repositories?page=1



### Website running emulators

* Various list
    * https://www.retrogames.cc/
    * http://emulator.online/ (flash emulator)
    * https://lifehacker.com/the-best-web-sites-to-get-your-retro-gaming-fix-1823765757
    * http://pica-pic.com/ (flash)
    * https://dos.zczc.cz/ (with emularity and em-dosbox)
        * https://github.com/rwv/chinese-dos-games-web
        * https://github.com/rwv/chinese-dos-games (metadata)
    * https://www.myabandonware.com/ run only dosbox games
    
* From archive.org
    * Emularity software library of dos games : https://archive.org/details/softwarelibrary_msdos_games
    * Emularity sofware library for arcade games : https://archive.org/details/internetarcade
    * Emularity sofware library for console games : https://archive.org/details/consolelivingroom


### Emulator frontend

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
    * Themes
        * Thema list https://pegasus-frontend.org/tools/themes/
        * Theme Switch-like adaptated for Retroid Pocket2 https://github.com/dragoonDorise/RP-Switch
        * skylineOS is a theme for Pegasus Frontend forked from switchOS that aims to recreate the experience of Nintendo's Switch https://github.com/RBertoCases/skylineOS
    * Guide and preconfiguration data to install pegasus on Retroid Pocket2 https://github.com/dragoonDorise/pegasus-rp2-metadata

* EmulationStation
    * https://emulationstation.org/
    * https://github.com/Aloshi/EmulationStation/tree/unstable
    * proposed in retropie installer

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

### Emulation : Rom management tools

* List
    * (FR) http://www.emu-france.com/utilitaires/24-utilitaires-multi-systemes/316-managers/

* ClrmamePro (well known)
    * ​https://mamedev.emulab.it/clrmamepro/

* Romcenter (well known)
    * http://www.romcenter.com/
    * tutorial : https://www.youtube.com/watch?v=1JtIh5u2Ko4
    * good enough
    * source code no available - closed source

* Romvault
    * http://www.romvault.com/ 
    * https://github.com/RomVault/RVWorld
    * windows only
    * tutorial : https://www.youtube.com/embed/yUOIYYbZuAg
    * can manipulate several DAT files simultaneously



* Romulus
    * https://romulus.cc/ 
    * closed source
    * windows only - tested with wine on linux and mac
    * weird behaviour : erase files
    * good updater and search of DAT files
    * easyier than romcenter or clrmamepro
    * DAT files format supported : Clrmame pro OLD and XML format, Romcenter, Offlinelist, MESS softlists
    * tutorial by recalbox (FR) : https://recalbox.gitbook.io/documentation/v/francais/tutoriels/utilitaires/gestion-des-roms/romulus-rom-manager



* JRomManager 
    * https://github.com/optyfr/JRomManager
    * opensource


* ROMba
    * https://github.com/uwedeportivo/romba
    * command line
    * linux - macos
    * While its core functionality is similar to tools like ROMVault and CLRMamePRO, ROMba takes a unique approach by storing ROMs in a de-duplicated way, and allowing you to "build" any set you need on demand.

* Guide : Convert SNES ROM's Into CIA's & Install Them ! (OLD/NEW 3DS/2DS) 
    * https://www.youtube.com/watch?v=G6zkMl9UTJM


### Emulation : Rom database

* guide how to manage DAT and rom :
    * https://www.oreilly.com/library/view/gaming-hacks/0596007140/ch01s13.html
    * https://retropie.org.uk/docs/Validating%2C-Rebuilding%2C-and-Filtering-ROM-Collections/

* DAT files
    * Datomatic No Intro http://datomatic.no-intro.org/
    * TOSEC https://www.tosecdev.org/ (The Old School Emulation Centre)
    * https://www.advanscene.com/
    * http://www.progettosnaps.net/dats/

* DAT files management
    * SabreTools 
        * https://github.com/SabreTools/SabreTools
        * command line
        * windows
    * DatUtil
        * http://www.logiqx.com/Tools/DatUtil/
        * command line
        * DatUtil was created to aid in the creation of dat files for Rom Managers such as ClrMamePro and RomCenter
        * tutorial (FR) ! https://forum.recalbox.com/topic/4571/tutorial-datutil

* EverDrive-Packs-Lists-Database
    * https://github.com/SmokeMonsterPacks/EverDrive-Packs-Lists-Database
    * The EverDrive Packs Lists Project is an archival research initiative with the goal of allowing users to build real-hardware optimized ROM packs based on suggested file/folder layouts compiled by SmokeMonster.

* Shiragame
    * shiragame is a games and ROM SQLite database that is automatically updated twice weekly by compiling DAT files from cataloguing organizations like Redump, No-Intro, or TOSEC
    * allows you to look up game titles by ROM hash, or serial. 
    * https://github.com/SnowflakePowered/shiragame
    * https://shiragame.snowflakepowe.red/
    * shiratsu : https://github.com/SnowflakePowered/shiratsu - aggregate data for shiragame


* Universal-DB
    * store information on 3DS/DS homebrews
    * https://db.universal-team.net/
    * https://github.com/Universal-Team/db
    * https://gbatemp.net/threads/universal-db-an-online-database-of-ds-and-3ds-homebrew.575218/


### Scrapper

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
    * support emulationstation metadata
    * use ScreenScraper.fr for games items, need an account for better speed
    * integration with recalbox, retropie and launchbox
    * tutorial (FR) : https://recalbox.gitbook.io/documentation/v/francais/tutoriels/utilitaires/gestion-des-scrappes/skraper-scrapper-ses-roms
    * needs a lot of space for downloaded metadata cache

* Arrm (Another Gamelist, Roms manager, and Scraper for Recalbox, Batocera, Retropie, Retrobat & Emulationstation)
    * http://jujuvincebros.fr/hard-soft/arrm-gamelist-roms-manager-scraper
    * windows - no Linux (nor Mono nor Wine on may 2019), no Mac OS



### Emulation : Rom download

* Links
    * http://romhustler.net/
    * https://www.emurom.net/
    * https://romsmania.cc
    * https://www.nds-passion.xyz
    * https://www.3dscia.com/
    * http://www.3dsiso.com/
    * https://www.arcadepunks.com/
    * https://yelostech.com/working-best-rom-sites/
    * https://archive.org/details/MAME_0.151_ROMs
    * https://the-eye.eu/public/rom/
    * https://hshop.erista.me/
        * download CIA with direct link (valid for few hours), generate QRcode, and comptabible with FBI
    * CIA download for 3DS
        * https://www.softcobra.com/ntdo/ntdo-3ts/3ts-roms/
        * https://roms3ds.com/category/3ds-rom-eur/
        * https://isoroms.com/category/3ds/
        * ghost eshop
            * https://github.com/Ghost0159/Ghost-eShop-Homebrew
            * https://ghosteshop.com/

