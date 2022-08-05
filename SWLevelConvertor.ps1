#Syndicate Wars Level Convertor by Moburma

#VERSION 1.2
#LAST MODIFIED: 05/08/2022

<#
.SYNOPSIS
   This script can convert pre-alpha Syndicate Wars level files (first byte of the file is an integer lower than 15) and convert
   them to a format that the final game can understand.

.DESCRIPTION    
    
    

.PARAMETER Filename
   
   The pre-alpha level file to open. E.g. C001L007.DAT


.PARAMETER Outputdir
   
   The directory to place the converted file. Must not be the same as source file directory!


.RELATED LINKS
    
    SWLevelReader: https://github.com/Moburma/SWLevelReader

    
#>

Param ($filename, $outputdir)

$levfile = Get-Content $filename -Encoding Byte -ReadCount 0

$outputfile = $outputdir.TrimEnd("\")+"\"+[io.path]::GetFileName("$filename")
$workingdir = Get-Location

#Error handling

if ((Test-Path -Path $filename -PathType Leaf) -eq 0){
write-host "Error - No file with that name found. Please supply a target level file to read!"
write-host ""
write-host "Example: SWLevelconvertor.ps1 C001L007.DAT D:/games/swars"
exit
}

if ($filename -eq $null){
write-host "Error - No argument provided. Please supply a target level file to read!"
write-host ""
write-host "Example: SWLevelconvertor.ps1 C001L007.DAT D:/games/swars"
exit
}

if ((Test-Path -Path $outputdir ) -eq 0){
write-host "Error - No output directory with that name found. Please supply an output directory to write the converted level to"
write-host ""
write-host "Example: SWLevelconvertor.ps1 C001L007.DAT D:/games/swars"
exit
}

if ((Split-path -path $filename) -eq $outputdir.TrimEnd("\")  ){
write-host "Error - Same directory detected for input and output. You MUST supply a different output directory to write the converted level to"
write-host ""
write-host "Example: SWLevelconvertor.ps1 C001L007.DAT D:/games/swars"
exit
}

$filetype = $levfile[0]
write-host "Level is of type $filetype"

if($filetype -gt 12){
write-host "File is already newer than version 12, no conversion needed"
exit
}


function convert16bitint($Byteone, $Bytetwo) {
   
    $converbytes16 = [byte[]]($Byteone,$Bytetwo)
    $converted16 =[bitconverter]::ToInt16($converbytes16,0)

    return $converted16

}

function levelwriter($Posone, $Postwo) {
   
    $range = $Posone..$Postwo
    $bytes = $levfile[$range]

    Add-content $outputfile -Value $bytes -Encoding Byte

}

function write-progresshelper  {
Write-Progress -Activity "Converting level $file" -Status "Converting character $counter / $pcharcount" -PercentComplete ( ($counter/$pcharcount) * 100)

}

#Check if count is two bytes or not
if( $levfile[5] -ne 0){
$charcount = convert16bitint $levfile[4] $levfile[5]
}
else{
$charcount = $levfile[4]
}

write-host "$charcount characters detected"

$pcharcount = $charcount

if($Charcount -eq 0){
write-host "No characters found, is this actually a Syndicate Wars level file?"
write-host "Nothing to do - Exiting"
exit
}

$file = Split-Path $filename -leaf

$header = $levfile[1..5]

#write new version number so file can't be converted again by accident

$newversion = [byte[]] $varray = 0x00  #init blank array first or it will fail
$newversion = [byte[]] $varray = 16    #Set version 16, NOT 17, as this dictates vehicle health behaviour
Set-Content $outputfile -Value $newversion -Encoding Byte

#write header
Add-Content $outputfile -Value $header -Encoding Byte

$fpos = 6
$zerobyte = [System.Convert]::ToString(0,16) -as [Byte] # Use this for zero byte entries going forward
$counter = 0

write-host "Working...."

DO
{

#echo $fpos

#get some vars up front for later manipulation

$type = $levfile[$fpos+8]
$thingtype = $levfile[$fpos+9]
$state = convert16bitint $levfile[$fpos+10] $levfile[$fpos+11]
$vehiclearmour = [byte[]] $vaarray = 0x00 #init array
$counter = $counter+1

write-progresshelper 


#output first block of data unchanged. Byte 18
 
levelwriter  ($fpos) ($fpos+17)

#get LinkSameGroup from half of Flag2 area
  
levelwriter ($fpos+70) ($fpos+71)

#Output up to thingoffset

levelwriter ($fpos+20) ($fpos+21)

#write thing offset from part of VY
    
levelwriter ($fpos+50) ($fpos+51)

# Continue to startframe

levelwriter ($fpos+24) ($fpos+37)

#Startframe byte 39 - 40 fpos38 - 39

levelwriter ($fpos+38) ($fpos+39)


#write up to speed stat

levelwriter ($fpos+40) ($fpos+43)

Add-content $outputfile -Value $zerobyte -Encoding Byte  #Zero out VX - leftover data in these three causes weird bugs for flying cars when they move
Add-content $outputfile -Value $zerobyte -Encoding Byte
Add-content $outputfile -Value $zerobyte -Encoding Byte
Add-content $outputfile -Value $zerobyte -Encoding Byte

Add-content $outputfile -Value $zerobyte -Encoding Byte  #Zero out VY
Add-content $outputfile -Value $zerobyte -Encoding Byte
Add-content $outputfile -Value $zerobyte -Encoding Byte
Add-content $outputfile -Value $zerobyte -Encoding Byte

Add-content $outputfile -Value $zerobyte -Encoding Byte  #Zero out VZ
Add-content $outputfile -Value $zerobyte -Encoding Byte
Add-content $outputfile -Value $zerobyte -Encoding Byte
Add-content $outputfile -Value $zerobyte -Encoding Byte


#write speed stat from path index values
 
levelwriter ($fpos+76) ($fpos+77)

#write health stat from uniqueid values
   
levelwriter ($fpos+78) ($fpos+79)

#write Owner from Lastdist values

levelwriter ($fpos+100) ($fpos+101)

#continue to Flag2

levelwriter ($fpos+62) ($fpos+67)

Add-content $outputfile -Value $zerobyte -Encoding Byte  #Zero out Flag2 as it causes invisible NPCs!
Add-content $outputfile -Value $zerobyte -Encoding Byte
Add-content $outputfile -Value $zerobyte -Encoding Byte
Add-content $outputfile -Value $zerobyte -Encoding Byte

#Write up to uniqueid

levelwriter ($fpos+72) ($fpos+77)

#get uniqueid from flag3 data

levelwriter ($fpos+128) ($fpos+129)

#Add group data from Specialtimer variable where it is found in old level structure. Byte 81, fpos 80

$bytes = $levfile[$fpos+86]

Add-content $outputfile -Value $bytes -Encoding Byte

#write effective group.. this is wrong just copying group above, ot sure it exists in the early format, but will do for now. Byte 82  fpos 81
$bytes = $levfile[$fpos+86]

Add-content $outputfile -Value $bytes -Encoding Byte

#write comhead with data that is in bumpmode in early format. Byte 84  fpos 83

levelwriter ($fpos+92) ($fpos+93)

#write comcurrent with data that is in animmode in early format. Byte 86  fpos 85

levelwriter ($fpos+108) ($fpos+109)

#Blank SpecialTimer as it's got group info here TODO find real data 

Add-content $outputfile -Value $zerobyte -Encoding Byte

#Blank Angle
Add-content $outputfile -Value $zerobyte -Encoding Byte

#Blank WeaponTurn - TODO not sure what this is
Add-content $outputfile -Value $zerobyte -Encoding Byte
Add-content $outputfile -Value $zerobyte -Encoding Byte

#Blank Brightness
Add-content $outputfile -Value $zerobyte -Encoding Byte

#Blank ComRange
Add-content $outputfile -Value $zerobyte -Encoding Byte

#Blank Bumpmode as the data is group membership and therefore wrong. Need to find real values if they exist. Byte 93

Add-content $outputfile -Value $zerobyte -Encoding Byte

#Continue until lastdist 

levelwriter ($fpos+93) ($fpos+99)

#Blank LastDist aas it has owner data
Add-content $outputfile -Value $zerobyte -Encoding Byte
Add-content $outputfile -Value $zerobyte -Encoding Byte

#Continue until animmode 

levelwriter ($fpos+102) ($fpos+107)

#Blank Animmode as it contains comcurrent data

Add-content $outputfile -Value $zerobyte -Encoding Byte

#Continue until bad umod data

levelwriter ($fpos+109) ($fpos+111)

#Zero bytes 113 and 114 (UMOD) as they usually make all characters invincible!
Add-content $outputfile -Value $zerobyte -Encoding Byte
Add-content $outputfile -Value $zerobyte -Encoding Byte

#Continue until bad frameid data  Byte 116

levelwriter ($fpos+114) ($fpos+115)

#Blank bytes 117 and 118 as they put bad data into Frameid value that causes weird missing body parts for characters
Add-content $outputfile -Value $zerobyte -Encoding Byte
Add-content $outputfile -Value $zerobyte -Encoding Byte

#Continue until maxhealth. Byte 126

levelwriter ($fpos+118) ($fpos+125)

#write maxhealth from person11. Probably doesn't need to come from here, but just in case they are different. Byte 128
if($thingtype -eq 2){  #If vehicle need to look 36 bytes later
    levelwriter ($fpos+226) ($fpos+227)
}
Else{
    levelwriter ($fpos+190) ($fpos+191)
}


#Zero out wrong Flag3 values
Add-content $outputfile -Value $zerobyte -Encoding Byte
Add-content $outputfile -Value $zerobyte -Encoding Byte   #byte 130

#Set shieldenergy. Byte 132

levelwriter ($fpos+132) ($fpos+133)

#Zero out wrong shieldglow and weapondir values
Add-content $outputfile -Value $zerobyte -Encoding Byte
Add-content $outputfile -Value $zerobyte -Encoding Byte

if($thingtype -eq 2){  #If vehicle, add vehicle health here, first place it can go, not sure why it is needed, however
 
    levelwriter ($fpos+78) ($fpos+79)

}
Else{
    #Zero out if not vehicle, other characters don't seem to have this
    Add-content $outputfile -Value $zerobyte -Encoding Byte
    Add-content $outputfile -Value $zerobyte -Encoding Byte
}



if($thingtype -eq 2){  #If vehicle, get wobble data from start of extra bytes
    levelwriter ($fpos+204) ($fpos+207)
}
Else{
    #Zero out if not vehicle, other characters don't seem to have this
    Add-content $outputfile -Value $zerobyte -Encoding Byte
    Add-content $outputfile -Value $zerobyte -Encoding Byte
    Add-content $outputfile -Value $zerobyte -Encoding Byte
    Add-content $outputfile -Value $zerobyte -Encoding Byte
}

#Continue until weapons definition. Byte 144

levelwriter ($fpos+140) ($fpos+143)

#Set Maxshieldenergy. Byte 146

levelwriter ($fpos+132) ($fpos+133)

#Continue until weapons definition. Byte 148

levelwriter ($fpos+146) ($fpos+147)

#Get MaxEnergy and Energy from frameid and shieldglow. Byte 152

levelwriter ($fpos+116) ($fpos+117)

levelwriter ($fpos+132) ($fpos+133)

#Continue until Stamina definitions. Byte 160

levelwriter ($fpos+152) ($fpos+159)

if($thingtype -eq 2){ # If a vehicle, copy the values from health/uniqueid to here, this is where vehicle health needs to be

   # $vehiclearmour = [System.Convert]::ToString(4,16) -as [Byte]   #set armour to 4 for vehicles
   # Add-content $outputfile -Value $vehiclearmour -Encoding Byte
    Add-content $outputfile -Value $zerobyte -Encoding Byte #In version 16 and lower vehicle health not set in armour field
    Add-content $outputfile -Value $zerobyte -Encoding Byte #Blank out bytes of stamina. 
    
    #Set maxstamina based on uniqueid value. 
    levelwriter ($fpos+78) ($fpos+79) 
}
Else{
    #Stamina definitions. Ptarget. Byte 164
    levelwriter ($fpos+64) ($fpos+67)
}

#Weaponscarried defined here Byte 168

levelwriter ($fpos+88) ($fpos+91)

#finished basic char data

if ($thingtype -eq 2){  #Vehicles have an extra 36 bytes of data in their character definition. This contains model starting orientation 
#write-host "vehicle detected"

#Dump vehicle data

#There are three main sets of bytes that seem to represent mandatory vehicle data that control scaling. First is width of model, second height, third length

levelwriter ($fpos+216) ($fpos+251)  #Bytes 216 - 252 of the extra data

$fpos = $fpos + 36
}

#move on to next char
$fpos = $fpos + 168

#skip old version extra char data
$fpos = $fpos + 48

$charcount = $charcount - 1

#echo $fpos
}
UNTIL ($charcount -eq 0)

write-host "Character data re-written"

#Continue until end of file

$arrayend = $levfile.length

$endrange = $fpos..$arrayend
$fileend = $levfile[$endrange]

Add-content $outputfile -Value $fileend -Encoding Byte 

write-host "All Done"
