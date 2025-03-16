#Syndicate Wars Level Convertor by Moburma

#VERSION 2.0
#LAST MODIFIED: 16/03/2022

<#
.SYNOPSIS
   This script can convert pre-alpha Syndicate Wars level files (first byte of the file is an integer lower than 15) and convert
   them to a format that the final game can understand.

.DESCRIPTION    
    
    

.PARAMETER Filename
   
   The pre-alpha level file to open. E.g. C001L007.DAT

.PARAMETER Outputdir
   
   The directory to place the converted file. Must not be the same as source file directory!

.PARAMETER unguidedhair

    Switch to enable optional feature of giving female unguided random hair colours

.RELATED LINKS
    
    SWLevelReader: https://github.com/Moburma/SWLevelReader

    
#>

Param ($filename, $outputdir,  [switch] $unguidedhair)

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


if ($outputdir -eq $null){
write-host "Error - No output directory provided. Please supply a target directory to write to!"
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
Write-Progress -Activity "Converting level $file" -Status "Converting character $totalcount / $pcharcount" -PercentComplete ( ($totalcount/$pcharcount) * 100)

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
$zerobyte = [System.BitConverter]::GetBytes(0) # Use this for zero byte entries going forward
$counter = 0

write-host "Working...."

DO
{
write-progresshelper
#echo $fpos

    $Parent =  $levfile[($fpos)..($fpos+1)]
    $Next =  $levfile[($fpos+2)..($fpos+3)]
    $LinkParent = $levfile[($fpos+4)..($fpos+5)]
    $LinkChild =  $levfile[($fpos+6)..($fpos+7)]
    $type = $levfile[($fpos+8)]
    $thingtype = $levfile[($fpos+9)]
    $state =  $levfile[($fpos+10)..($fpos+11)]
    $Flag =  $levfile[($fpos+12)..($fpos+15)]
    $LinkSame = $levfile[($fpos+16)..($fpos+17)]
    $Object =  $levfile[($fpos+18)..($fpos+19)]
    $Radius =  $levfile[($fpos+20)..($fpos+21)]
    $TngUnkn22 =  $levfile[($fpos+22)..($fpos+23)]
    $x =  $levfile[($fpos+24)..($fpos+27)]
    $y =  $levfile[($fpos+28)..($fpos+31)]
    $z =  $levfile[($fpos+32)..($fpos+35)]
    $Frame =  $levfile[($fpos+36)..($fpos+37)]
    $StartFrame =  $levfile[($fpos+38)..($fpos+39)]
    $Timer1 =  $levfile[($fpos+40)..($fpos+41)]
    $StartTimer1 =  $levfile[($fpos+42)..($fpos+43)]
    $Timer2 =  $levfile[($fpos+44)..($fpos+45)] 
    $StartTimer2 =  $levfile[($fpos+46)..($fpos+47)]
    $AnimMode = $levfile[($fpos+48)] 
    $OldAnimMode = $levfile[($fpos+49)] 
    $ThingOffset =  $levfile[($fpos+50)..($fpos+51)]
    $VX =  $levfile[($fpos+52)..($fpos+55)]
    $VY =  $levfile[($fpos+56)..($fpos+59)]
    $VZ =  $levfile[($fpos+60)..($fpos+63)]
    $Stamina =  $levfile[($fpos+64)..($fpos+65)] 
    $MaxStamina =  $levfile[($fpos+66)..($fpos+67)]
    $VehicleAngleZ =  $levfile[($fpos+68)..($fpos+69)]
    $LinkSameGroup =  $levfile[($fpos+70)..($fpos+71)]
    $TngUnkn72 =  $levfile[($fpos+72)..($fpos+73)]
    $PersonAngle =  $levfile[($fpos+74)]
    $EffectiveGroup = $levfile[($fpos+75)]
    $Speed =  $levfile[($fpos+76)..($fpos+77)]
    $Health =  $levfile[($fpos+78)..($fpos+79)]
    $PersonGotoX =  $levfile[($fpos+80)..($fpos+81)]
    $PersonGotoY  =  $levfile[($fpos+82)..($fpos+83)]
    $PersonGotoZ =  $levfile[($fpos+84)..($fpos+85)]
    $Group = $levfile[($fpos+86)]
    $TngUnkn87 = $levfile[($fpos+87)]
    $WeaponsCarried =  $levfile[($fpos+88)..($fpos+91)]
    $ComHead =  $levfile[($fpos+92)..($fpos+93)]
    $ComCur =   $levfile[($fpos+94)..($fpos+95)]
    $ComTimer =  $levfile[($fpos+96)..($fpos+97)]
    $TngUnkn98 =  $levfile[($fpos+98)..($fpos+99)]
    $Owner =  $levfile[($fpos+100)..($fpos+101)]
    $CurrentWeapon =  $levfile[($fpos+102)..($fpos+103)]
    $TngUnkn104 =  $levfile[($fpos+104)..($fpos+105)]
    $WeaponTurn =  $levfile[($fpos+106)..($fpos+107)]
    $VehicleMatrixIndex =  $levfile[($fpos+108)..($fpos+109)]
    $Brightness =  $levfile[($fpos+110)] 
    $PathOffset = $levfile[($fpos+111)]
    $UnkFrame =  $levfile[($fpos+112)..($fpos+113)]
    $PathIndex =  $levfile[($fpos+114)..($fpos+115)]
    $MaxShieldEnergy  =  $levfile[($fpos+116)..($fpos+117)] 
    $TngUnkn118 =   $levfile[($fpos+118)..($fpos+119)] 
    $TngUnkn120 =  $levfile[($fpos+120)..($fpos+123)]
    $TngUnkn124 =  $levfile[($fpos+124)..($fpos+125)]
    $TngUnkn126 =  $levfile[($fpos+126)..($fpos+127)]
    $UniqueID =  $levfile[($fpos+128)..($fpos+129)]
    $TngUnkn130 =  $levfile[($fpos+130)..($fpos+131)]
    $ShieldEnergy  =  $levfile[($fpos+132)..($fpos+133)]
    $SpecialTimer =  $levfile[($fpos+134)] 
    $TngUnkn135 =  $levfile[($fpos+135)] 
    $TngUnkn136 =  $levfile[($fpos+136)..($fpos+137)]
    $TngUnkn138 =  $levfile[($fpos+138)..($fpos+139)] 
    $BumpMode = $levfile[($fpos+140)] 
    $BumpCount = $levfile[($fpos+141)] 
    $Vehicle =  $levfile[($fpos+142)..($fpos+143)]
    $LinkPassenger =  $levfile[($fpos+144)..($fpos+145)]
    $Within  =  $levfile[($fpos+146)..($fpos+147)]
    $LastDist =  $levfile[($fpos+148)..($fpos+149)]
    $TngUnkn150 =  $levfile[($fpos+150)..($fpos+151)]
    $PTarget =  $levfile[($fpos+152)..($fpos+155)]
    $TngUnkn156 =  $levfile[($fpos+156)..($fpos+157)]
    $OnFace =  $levfile[($fpos+158)..($fpos+159)]
    $PersonUnkn160 =  $levfile[($fpos+160)..($fpos+161)]
    $SubState = $levfile[($fpos+162)]
    $ComRange = $levfile[($fpos+163)]
    $ReqdSpeed =  $levfile[($fpos+164)..($fpos+165)]
    $WeaponTimer =  $levfile[($fpos+166)..($fpos+167)]
    $PassengerHead =  $levfile[($fpos+168)..($fpos+169)]
    $TNode =  $levfile[($fpos+170)..($fpos+171)]
    $AngleDY =  $levfile[($fpos+172)..($fpos+173)]
    $TngUnkn174 =  $levfile[($fpos+174)..($fpos+175)]
    $MaxEnergy  =  $levfile[($fpos+176)..($fpos+177)]
    $Energy =  $levfile[($fpos+178)..($fpos+179)]
    $TngUnkn180 =  $levfile[($fpos+180)..($fpos+181)]
    $TngUnkn182 =  $levfile[($fpos+182)..($fpos+183)]
    $TngUnkn18 =  $levfile[($fpos+184)] 
    $Shadows1 = $levfile[($fpos+185)]
    $Shadows2 =  $levfile[($fpos+186)] 
    $Shadows3 = $levfile[($fpos+187)]
    $Shadows4 = $levfile[($fpos+188)]
    $RecoilTimer = $levfile[($fpos+189)]
    $MaxHealth =  $levfile[($fpos+190)..($fpos+191)]
    $RecoilDir = $levfile[($fpos+192)] 
    $TngUnkn193 = $levfile[($fpos+193)]
    $GotoThingIndex =  $levfile[($fpos+194)..($fpos+195)]
    $TngUnkn196 =  $levfile[($fpos+196)..($fpos+197)]
    $TngUnkn198 =  $levfile[($fpos+198)..($fpos+199)]
    $TngUnkn200 =  $levfile[($fpos+200)..($fpos+201)]
    $GotoX =  $levfile[($fpos+202)..($fpos+203)]
    $GotoZ =  $levfile[($fpos+204)..($fpos+205)]
    $TempWeapon =  $levfile[($fpos+206)..($fpos+207)]
    $TngUnkn208 =  $levfile[($fpos+208)..($fpos+209)]
    $TngUnkn210 =  $levfile[($fpos+210)..($fpos+211)]
    $TngUnkn212 =  $levfile[($fpos+212)..($fpos+213)]
    $TngUnkn214 =  $levfile[($fpos+214)..($fpos+215)]

    if ($thingtype -eq 2){
    #Get extra vehicle position data only for vehicles

    $vehicleData = $levfile[($fpos+216)..($fpos+251)]
    $fpos = $fpos + 36

    }

    $fpos = $fpos + 216

    #write-host "thingtype is $thingtype"

    if ($thingtype -lt 4){
       # write-host "writing thing, $tcount left" 

        $Fileoutput += $Parent
        $Fileoutput += $Next
        $Fileoutput += $LinkParent 
        $Fileoutput += $LinkChild
        $Fileoutput += $type
        $Fileoutput += $thingtype
        $Fileoutput += $state
        $Fileoutput += $Flag
        $Fileoutput += $LinkSame
        $Fileoutput += $LinkSameGroup
        $Fileoutput += $Radius
        $Fileoutput += $ThingOffset
        $Fileoutput += $X
        $Fileoutput += $Y
        $Fileoutput += $Z
        $Fileoutput += $Frame
        $Fileoutput += $StartFrame
        $Fileoutput += $Timer1
        $Fileoutput += $StartTimer1
        $Fileoutput += $VX
        $Fileoutput += $VY
        $Fileoutput += $VZ
        $Fileoutput += $Speed
        $Fileoutput += $Health
        $Fileoutput += $Owner
        $Fileoutput += $PathOffset
        $Fileoutput += $SubState
        $Fileoutput += $PTarget
        $Fileoutput += $zerobyte[0..3] #flag2
        $Fileoutput += $GotoThingIndex
        $Fileoutput += $zerobyte[0..1] #oldtarget
        $Fileoutput += $PathIndex
        $Fileoutput += $UniqueID
        $Fileoutput += $EffectiveGroup #group - nothing here so use effective
        $Fileoutput += $EffectiveGroup
        $Fileoutput += $ComHead
        $Fileoutput += $ComCur
        $Fileoutput += $SpecialTimer
        $Fileoutput += $PersonAngle 
        $Fileoutput += $WeaponTurn
        $Fileoutput += $Brightness
        $Fileoutput += $ComRange
        $Fileoutput += $BumpMode
        $Fileoutput += $BumpCount
        $Fileoutput += $Vehicle
        $Fileoutput += $LinkPassenger
        $Fileoutput += $Within
        $Fileoutput += $LastDist
        $Fileoutput += $ComTimer
        $Fileoutput += $Timer2
        $Fileoutput += $StartTimer2
        $Fileoutput += $AnimMode
        $Fileoutput += $OldAnimMode
        $Fileoutput += $OnFace
        $Fileoutput += $zerobyte[0..1] #umod
        $Fileoutput += $zerobyte[0..1] #mood
        if($type -eq 3){ #set female unguideds to have random hair colours

            $hairrandom = Get-Random -Minimum 0 -Maximum 10
        
            if ($hairrandom -eq 1 -or $hairrandom -eq 2){
            
            $Fileoutput += [byte[]] $vaarray = 0x01 # Blonde hair

            write-host "Female punk - setting blonde hair"
            }
            elseif ($hairrandom -eq 3 -or $hairrandom -eq 4){
            
            $Fileoutput += [byte[]] $vaarray = 0x02 # Blue hair
            write-host "Female punk - setting blue hair"
            }
            Else{   #Normal red hair
            $Fileoutput += $zerobyte[0] 
            write-host "Female punk - setting normal hair"
            }
        
        }
        Else{
            $Fileoutput += $zerobyte[0] #frameid1
        }
        $Fileoutput += $zerobyte[0] #frameid2
        $Fileoutput += $zerobyte[0] #frameid3
        $Fileoutput += $zerobyte[0] #frameid4
        $Fileoutput += $zerobyte[0] #frameid5
        $Fileoutput += $Shadows1
        $Fileoutput += $Shadows2
        $Fileoutput += $Shadows3
        $Fileoutput += $Shadows4
        $Fileoutput += $RecoilTimer
        $Fileoutput += $MaxHealth
        $Fileoutput += $zerobyte[0] #flag3
        $Fileoutput += $zerobyte[0] #oldsubtype
        $Fileoutput += $ShieldEnergy
        $Fileoutput += $zerobyte[0] #shieldglowtimer
        $Fileoutput += $zerobyte[0] #weapondir
        $Fileoutput += $zerobyte[0..1] #specialowner
        $Fileoutput += $zerobyte[0..1] #workplace
        $Fileoutput += $zerobyte[0..1] #leisureplace
        $Fileoutput += $WeaponTimer
        $Fileoutput += $zerobyte[0..1] #target2
        $Fileoutput += $MaxShieldEnergy
        $Fileoutput += $zerobyte[0..1] #persuadepower
        $Fileoutput += $MaxEnergy
        $Fileoutput += $Energy
        $Fileoutput += $RecoilDir
        $Fileoutput += $CurrentWeapon
        $Fileoutput += $GotoX
        $Fileoutput += $GotoZ
        $Fileoutput += $TempWeapon
        $Fileoutput += $zerobyte[0]
        $Fileoutput += $MaxStamina
        $Fileoutput += $WeaponsCarried
        if ($thingtype -eq 2){
        $Fileoutput += $vehicledata
        }

        $totalcount = $totalcount +1

    }
    $charcount = $charcount -1
}
UNTIL ($charcount -eq 0)

write-host "Character data re-written"

#Continue until end of file

$arrayend = $levfile.length

$endrange = $fpos..$arrayend
$fileend = $levfile[$endrange]
$Fileoutput += $fileend



add-Content $outputfile -Value $Fileoutput  -Encoding Byte

write-host "All Done"
