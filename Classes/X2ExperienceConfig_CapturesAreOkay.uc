class X2ExperienceConfig_CapturesAreOkay extends X2ExperienceConfig
	// native(Core)
	config(GameData_XpData);

//---------------------------------------------------------------------------------------
//				DIO XP
//---------------------------------------------------------------------------------------

static function AwardMissionXP(XComGameState ModifyStateObject, XComGameState_StrategyAction_Mission MissionAction, bool bIgnoreMissionXP)
{
	local XComGameState_Unit Unit;
	local int i, UnitTotalXP, MissionXP, NumKills, CurrentAct;
	local float XPScalar, fScaledMissionXP, fKillsXP, fScaledKillsXP, fTotalXP, fMaxKillXP;

	local int NumCaptures, NumKillsAndCaptures;
	local int TotalKills, TotalCaptures;
	
	`log("             CapturesAreOkay: AwardMissionXP() called.", , 'XCom_XP');

	`Log("AWARD MISSION XP", , 'XCom_XP');

	XPScalar = MissionAction.XPScalar;
	// Early out: this mission awards no XP
	if (XPScalar <= 0.0)
	{
		`Log("** XPScalar is ZERO, mission awards no XP", , 'XCom_XP');
		return;
	}

	CurrentAct = class'DioStrategyAI'.static.GetCurrentActIndex();
	MissionXP = GetActMissionXP(CurrentAct);
	fKillsXP = GetActKillXP(CurrentAct);
	fMaxKillXP = GetActMaxKillXP(CurrentAct);
	
	// Base mission XP awarded to all units
	fScaledMissionXP = float(MissionXP) * XPScalar;

	`Log("** CurrentAct [" $ CurrentAct + 1 $ "]", , 'XCom_XP');
	`Log("** MissionXP [" $ fScaledMissionXP $ "]", , 'XCom_XP');
	`Log("** MaxKillXP per Agent [" $ fMaxKillXP $ "]", , 'XCom_XP');

	if (bIgnoreMissionXP) // if the mission was aborted etc, no mission XP
	{
		fScaledMissionXP = 0;
		`Log("** MissionXP [" @ fScaledMissionXP @ "] changed because of bIgnoreMissionXP (aborted likely)", , 'XCom_XP');
	}

	for (i = 0; i < MissionAction.AssignedUnitRefs.Length; ++i)
	{
		Unit = XComGameState_Unit(ModifyStateObject.ModifyStateObject(class'XComGameState_Unit', MissionAction.AssignedUnitRefs[i].ObjectID));
		NumKills = Unit.KilledUnitsLastMission.Length;//TODO-DIO-STRATEGY Confirm? [9/10/2019 dmcdonough]

		// This is a hack, as we can't add a CapturedUnitsLastMission variable to XComGameState_Unit. Assuming WetWorkKills isn't used in CS/Dio. (geoffhom; 5.13.2020)
		TotalKills += NumKills;
		NumCaptures = Unit.WetWorkKills;
		TotalCaptures += NumCaptures;
		NumKillsAndCaptures = NumKills + NumCaptures;

		`log(" ", , 'XCom_XP');
		`Log("** Unit [" $ Unit.GetNickName(true) $ "]", , 'XCom_XP');
		`Log("**** Kills [" $ NumKills $ "]", , 'XCom_XP');
		`Log("**** Captures [" $ NumCaptures $ "]", , 'XCom_XP');
		`Log("**** Kills + Captures [" $ NumKillsAndCaptures $ "]", , 'XCom_XP');

		if (NumKillsAndCaptures > 0)
		{
			fScaledKillsXP = (float(NumKillsAndCaptures) * fKillsXP) * XPScalar;
			if (fScaledKillsXP > fMaxKillXP)
			{
				`Log("**** Kill/Capture XP [" $ fScaledKillsXP $ "] clamped to max kill XP", , 'XCom_XP');
				fScaledKillsXP = fMaxKillXP;
			}
		}
		else
		{
			fScaledKillsXP = 0;
		}
		`Log("**** Kill + Capture XP [" $ fScaledKillsXP $ "]", , 'XCom_XP');

		fTotalXP = fScaledMissionXP + fScaledKillsXP;
		UnitTotalXP = Round(fTotalXP);
		`Log("**** Total XP [" $ UnitTotalXP $ "]", , 'XCom_XP');
		Unit.AddXp(UnitTotalXP);

		// Captures have been counted, so reset. 
		Unit.WetWorkKills = 0;
	}

	// So player can check log against what the tactical end said earlier. We show kills before captures because the game shows it that way.
	`log("             CapturesAreOkay: Mission Kills [" $ TotalKills $ "], Mission Captures [" $ TotalCaptures $ "]", , 'XCom_XP');
}
