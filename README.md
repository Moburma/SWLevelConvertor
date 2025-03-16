# Syndicate Wars Level Convertor

Powershell 5 script to convert unplayable pre-alpha level files (file format version 12 or lower) from the game Syndicate Wars to the format used by the final game. Pre-Alpha levels use a different longer data structure to the final game level format, so either don't load at all, or run in a state that is nothing like intended without conversion. Conversion via this script allows the playing of approximately 72 new levels that were previously unplayable that shipped with the final game. Note there are still some known issues using, please see known limitations below. However, many levels can now be played successfully to completion.

## Usage

Run with SWLevelconvertor.ps1 {filename} {output directory} [-unguidedhair]

e.g. SWLevelconvertor.ps1 "D:\games\Syndicate Wars\Levels\C006L001.DAT" D:games\swars

e.g. SWLevelconvertor.ps1 "D:\games\Syndicate Wars\Levels\C006L001.DAT" D:games\swars -unguidedhair

Note input directory and output must be different (i.e. you cannot overwrite the file you are converting)

-unguidedhair is an optional switch that overrides what was set in the source file to randomly choose different hair colours/styles for female unguided, something rarely used in the final game.

For more information on some of the levels that can be converted, see the levels list here:

https://tcrf.net/Syndicate_Wars_(DOS)#Unused_Levels</br>

https://tcrf.net/Notes:Syndicate_Wars_(DOS)#Level_File_Versions

Data structure information from https://github.com/mefistotelis/swars-re-helpers


## Version 2.0:

* Re-written to match what was found and added to the main SWars project in regards of pre-alpha formats


It's recommended you also use the sister script https://github.com/Moburma/SWLevelReader in conjunction with this one. That script can identify corrupt levels (a few levels shipped with the game are corrupt, e.g. C045L015.D3, C046L008.DAT) and assist with reverse engineering, as well as confirm if a level has been converted successfully.
