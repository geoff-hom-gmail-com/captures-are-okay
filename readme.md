# CapturesAreOkay README

This is the README for the XCOM: Chimera Squad mod, "Captures Are Okay." 

The game has a bug where kills are rewarded XP but captures aren't. What kind of message is that sending? This mod is to fix that bug.

## Features

The trivial way for Firaxis to fix this bug is to add a variable like XComGameState_Unit.CapturedUnitsLastMission, then update it each time a unit goes unconscious. Then modify X2ExperienceConfig.AwardMissionXP(). 

As mods can't modify XComGameState_Unit directly, I'm using a workaround. I override AwardMissionXP(), and I get the captures count via XComGameState_Unit.WetWorkKills. How/why? It's an unused variable. I reset the variable after "OnUnitBeginPlay" and set the variable after "TacticalGameEnd." Note that OnPreMission() and OnPostMission() hooks don't work in Chimera Squad.

Another way to do the capture count would be to listen for "UnitUnconscious." However, the current way works from a save game in mid-mission. In the long run, "UnitUnconscious."

> Tip: The mod logs XP gains in the Balance log. There is also a mod in the Steam Workshop to show XP in the Armory. You can combine these to make sure the mod is working. If you find a bug, please include such logs/Armory pics.

## Requirements

The mod overrides X2ExperienceConfig.AwardMissionXP(). 

It also writes to XComGameState_Unit.WetWorkKills, as I think this is unused in Chimera Squad.

This mod listens to the events "TacticalGameEnd" and "OnUnitBeginPlay."