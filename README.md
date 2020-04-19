# wowc

A wrapper around the (BigWigs packager)[https://github.com/BigWigsMods/packager] 
so that I can copy an addon to different wow client addon folders

## What it does

Packages up wow addon in a source directory and copies it over to the 
Interface/AddOns folder for a given game client. Files no longer in the source
directory are removed from the addon's folder.

The script will check for a .pkgmeta-client file and use that if it exists. It 
will also remove any directories that start with a !. I use the combination of 
these two things so that I can can do things like exclude Dominos_Encounter from
the classic build of Dominos since it isn't relevant there.

## Usage

```bash
# copy to [client]
wowc.sh -c [retail | ptr | classic | beta | alpha | classic-alpha | classic-beta | classic-ptr]
# copy to retail
wowc.sh 
# copy to beta
wowc.sh -B 
# copy to classic
wowc.sh -C
# copy to ptr
wowc.sh -P
```
## Assumptions

* wowpkg exists as an alias to release.sh 
* WOW_ROOT is defined and points to your World of Warcraft install directory
* That I know what I'm doing when it comes to writing a shell script file