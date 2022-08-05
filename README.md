# Syndicate Wars Level Convertor

Powershell 5 script to convert unplayable pre-alpha level files (file format version 12 or lower) from the game Syndicate Wars to the format used by the final game. Pre-Alpha levels use a different longer data structure to the final game level format, so either don't load at all, or run in a state that is nothing like intended without conversion. Conversion via this script allows the playing of approximately 72 new levels that were previously unplayable that shipped with the final game. Note there are still some known issues using, please see known limitations below. However, many levels can now be played successfully to completion.

## Usage

Run with SWLevelconvertor.ps1 {filename} {output directory}

e.g. SWLevelReader.ps1 "D:\games\Syndicate Wars\Levels\C006L001.DAT" D:games\swars

Note input directory and output must be different (i.e. you cannot overwrite the file you are converting)

For more information on some of the levels that can be converted, see the levels list here:

https://tcrf.net/Syndicate_Wars_(DOS)#Unused_Levels</br>

https://tcrf.net/Notes:Syndicate_Wars_(DOS)#Level_File_Versions

Data structure information from https://github.com/mefistotelis/swars-re-helpers


## Known Limitations:

* Character Flag2 data is not written/known. This is somewhat rarely used but for one is used to make characters invisible for various effects (e.g. aiming satellite rain at the player on levels where it seemingly comes from nowhere)
* Character Health/Shield Energy/Energy/Stamina - not sure if these are all correct, they may be in the wrong order currently
* Misc other fields may be wrong without obvious effect but may cause bugs in levels.

It's recommended you also use the sister script https://github.com/Moburma/SWLevelReader in conjunction with this one. That script can identify corrupt levels (a few levels shipped with the game are corrupt, e.g. C045L015.D3, C046L008.DAT) and assist with reverse engineering, as well as confirm if a level has been converted successfully.
