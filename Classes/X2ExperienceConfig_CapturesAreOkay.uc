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

	// local XComGameStateHistory History;
	// local XComGameState_BattleData BattleData;
	// local array<StateObjectReference> CapturedUnitRefs;

	// local int NumCaptured;
	// local XComGameState_Unit CapturedUnit;
	
	//testing
	`log("             CapturesAreOkay: AwardMissionXP() called", , 'XCom_XP');


    // History = `XCOMHISTORY;
	// BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	// CapturedUnitRefs = BattleData.CapturedUnconsciousUnits;

	/*
	In Firaxis' code, captures don't give XP, but kills do. This doesn't seem right. 

	I tried to assign capture XP to the Agent who knocked the enemy unconscious. 
	However, at this point in the game, the references to those enemies have been deleted. 
	One solution is to find a hook during mission cleanup, then check UnconsciousUnit.LastDamagedByUnitID for the Agent,
	then keep track of that data until here. TODO: update with info on static vars, and then use of unused vars in Agent class.

	Of course, Firaxis can just add CapturedUnitsLastMission to the Unit class. <sigh>

	The current workaround is to get the number of captured enemies last mission, then divide those kills evenly among the assigned Agents.

	(geoffhom, 5.13.2020)
	*/
	// NumCaptured = BattleData.CapturedUnconsciousUnits.Length;

		// `log("             CapturesAreOkay: NumCaptured [" $ NumCaptured $ "]", , 'XCom_XP');

	// NumCaptured = BattleData.CapturedUnconsciousUnits.Length;

	// how do I convert this unitref to a unit
	// 		Unit = XComGameState_Unit(ModifyStateObject.ModifyStateObject(class'XComGameState_Unit', MissionAction.AssignedUnitRefs[i].ObjectID));
	// CapturedUnit = XComGameState_Unit(ModifyStateObject.ModifyStateObject(class'XComGameState_Unit', CapturedUnitRefs[i].ObjectID));
		
	// what is ModifyStateObject vs CreateStateObject?
	// modify works with agents, but not with enemies, for some reason... or the enemies aren't gs_u? no, they are
	// perhaps it keeps a list of these objects, and they got wiped out after the battle; which makes sense

	// so, we could just take the total and divide it evenly among agents. or, we could grab the info before mission end, and save it somewhere
	// let's do sharing; 
	// the other route, I'd need a good event to hook into; let's say I got that; then I'd need to just populate an array by looping thru the battledata
	// I guess I can save that as a comment. 

	// CapturedUnit = XComGameState_Unit(ModifyStateObject.ModifyStateObject(class'XComGameState_Unit', 20005));
	// `log("             CapturesAreOkay: Test Unit [" $ CapturedUnit.ObjectID $ "]", , 'XCom_XP');
	// CapturedUnit = XComGameState_Unit(ModifyStateObject.ModifyStateObject(class'XComGameState_Unit', 104));
	// `log("             CapturesAreOkay: Test Unit [" $ CapturedUnit.ObjectID $ "]", , 'XCom_XP');

	// `log("             CapturesAreOkay: X2EventListener_CapturesAreOkay.TestInt [" $ X2EventListener_CapturesAreOkay.TestInt $ "]", , 'XCom_XP');
	// `log("             CapturesAreOkay: X2EventListener_CapturesAreOkay.TestInt [" $ TestGameInfo.TestInt $ "]", , 'XCom_XP');

	
	// for (i = 0; i < CapturedUnitRefs.Length; ++i)
	// {
	// 	CapturedUnit = XComGameState_Unit(ModifyStateObject.ModifyStateObject(class'XComGameState_Unit', CapturedUnitRefs[i].ObjectID));
	// 	`log("             CapturesAreOkay: 1 CapturedUnconsciousUnits", , 'XCom_XP');
	// 	`log("             CapturesAreOkay: Unit [" $ CapturedUnit.ObjectID $ "]", , 'XCom_XP');

	// }

	// add GitHub so I don't lose this. (geoffhom 5.13.2020)

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

		// This is a hack, as we can't add a CapturedUnitsLastMission variable to the class. Assuming WetWorkKills isn't used in CS/Dio. (geoffhom; 5.13.2020)
		TotalKills += NumKills;
		NumCaptures = Unit.WetWorkKills;
		TotalCaptures += NumCaptures;
		NumKillsAndCaptures = NumKills + NumCaptures;

		`Log("** Unit [" $ Unit.GetNickName(true) $ "] [" $ Unit.ObjectID $ "]", , 'XCom_XP');
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
	}

	// So player can check log against what the tactical end said earlier. We show kills before captures because the game shows it that way.
	`log("             CapturesAreOkay: Mission Kills [" $ TotalKills $ "], Mission Captures [" $ TotalCaptures $ "]", , 'XCom_XP');
}
