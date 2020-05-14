# CapturesAreOkay README

This is the README for the XCOM: Chimera Squad mod, "Captures Are Okay." 

The game has a bug where kills are rewarded XP but captures aren't. What kind of message is that sending? This mod is to fix that bug.

## Features

The trivial way for Firaxis to fix this bug is to add a variable like XComGameState_Unit.CapturedUnitsLastMission, then update it each time a unit goes unconscious. Then modify X2ExperienceConfig.AwardMissionXP(). 

As mods can't modify XComGameState_Unit directly, I'm using a workaround. I override AwardMissionXP(), and I get the captures count via XComGameState_Unit.WetWorkKills. How/why? It's an unused variable. I reset the variable after the event "OnUnitBeginPlay." 

The variable is set after the event "TacticalGameEnd." 
I'm assuming the captor is the same as unconsciousUnit.LastDamagedByUnitID. So far, that seems to work.

Note: I wanted to set WetWorkKills after the event "UnitUnconscious." But changes to WetWorkKills wouldn't persist. I don't know enough about GameStates, etc. to know how to fix that.
On the bright side, if you install the mod and load a game mid-mission, it should run fine!

Note: OnPreMission() and OnPostMission() hooks don't work in Chimera Squad.

> Tip: The mod logs XP gains in the Balance log. There is also a mod in the Steam Workshop to show XP in the Armory. You can combine these to make sure the mod is working. If you find a bug, please include such logs/Armory pics.

> Tip: There's a bug in XComGameState_Unit.OnUnitUnconscious(). What it refers to as the "Captor" is actually the unit that was knocked unconscious. So don't trust CapturedUnitsLastTurn and CapturedUnits.

## Requirements

The mod overrides X2ExperienceConfig.AwardMissionXP(). 

It also writes to XComGameState_Unit.WetWorkKills, as I think this is unused in Chimera Squad.

This mod listens to the events "OnUnitBeginPlay" and "TacticalGameEnd."

