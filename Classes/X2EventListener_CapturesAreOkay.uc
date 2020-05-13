class X2EventListener_CapturesAreOkay extends X2EventListener;

var int TestInt;

static function array<X2DataTemplate> CreateTemplates() 
{
    local array<X2DataTemplate> Templates;

    `log("             CapturesAreOkay: CreateTemplates() called", , 'XCom_XP');

    Templates.AddItem(CreateTacticalGameEndTemplate());
    // Templates.AddItem(CreateUnitUnconsciousTemplate());

    return Templates;
}

// Want to reset capture counts at start of a mission. However, OnPreMission() hook in X2DownloadableContentInfo_CapturesAreOkay not working (5.13.2020).
// Figure the transition between days is a good enough workaround. 
static function X2EventListenerTemplate CreateTacticalGameEndTemplate()
{
    local X2EventListenerTemplate Template;

    `CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'TacticalGameEnd');

    // this isn't working. It couldb eregisterinstrategy not working. Or I have the wrong event name, as it may be a debug-command event.
    // Template.RegisterInStrategy = true;

    Template.RegisterInTactical = true;

    Template.AddEvent('TacticalGameEnd', OnTacticalGameEnd);

    return Template;
}

// static function X2EventListenerTemplate CreateUnitUnconsciousTemplate()
// {
// 	local X2EventListenerTemplate Template;

// 	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'UnitUnconscious');

// 	Template.RegisterInTactical = true;
// 	Template.AddEvent('UnitUnconscious', OnUnitUnconscious);

// 	return Template;
// }

static protected function EventListenerReturn OnTacticalGameEnd(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local XComGameStateHistory History;
    local XComGameState_BattleData BattleData;
   	local array<StateObjectReference> CapturedUnitRefs;
    local XComGameState_Unit CapturedUnit, DamagerUnit;
    local int i;

    `log("             CapturesAreOkay: OnTacticalGameEnd() called", , 'XCom_XP');

    History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
    CapturedUnitRefs = BattleData.CapturedUnconsciousUnits;

    // get the mission agents and set wetworkkills = 0; TODO

    for (i = 0; i < CapturedUnitRefs.Length; ++i)
    {
		CapturedUnit = XComGameState_Unit(GameState.ModifyStateObject(class'XComGameState_Unit', CapturedUnitRefs[i].ObjectID));
        DamagerUnit = XComGameState_Unit(GameState.ModifyStateObject(class'XComGameState_Unit', CapturedUnit.LastDamagedByUnitID));
        `log("             CapturesAreOkay: [" $ CapturedUnit.GetFullName() $ "] captured by [" $ DamagerUnit.GetFullName() $ " [" $ DamagerUnit.ObjectID $ "]]", , 'XCom_XP');
        DamagerUnit.WetWorkKills++;
        `log("             CapturesAreOkay: WetWorkKills [" $ DamagerUnit.WetWorkKills $ "]", , 'XCom_XP');

    }
        
    // I should try a little checking that these values work. Eg. ko an enemy, and see if it reports that was the one who KO'd. especially if it's a 1-hit KO, or if someone else hit first.

    /* We're assuming the captured used was last damaged by the unit that knocked it unconscious. That should be the case. 
    The only ways to knock an enemy unconscious require doing damage. Subdue. Zephyr's melee attack. Even Axiom's Smash has to hit before it can apply Unconscious.
    To be safer, we'll log the damager's name.
    */
    // the real test is whether this works; otherwise we're too late
    // CapturedUnit = XComGameState_Unit(GameState.ModifyStateObject(class'XComGameState_Unit', 20005));
	// `log("             CapturesAreOkay: Unit [" $ CapturedUnit.ObjectID $ "]", , 'XCom_XP');
    // `log("             CapturesAreOkay: LastDamagedByUnitID [" $ CapturedUnit.LastDamagedByUnitID $ "]", , 'XCom_XP');
    // DamagerUnit = XComGameState_Unit(GameState.ModifyStateObject(class'XComGameState_Unit', CapturedUnit.LastDamagedByUnitID));
    // `log("             CapturesAreOkay: LastDamagedByUnit [" $ DamagerUnit.GetFullName() $ " [" $ DamagerUnit.ObjectID $ "]]", , 'XCom_XP');

    // need to set this to 0 at the end of missionawardxp, or better yet, here;
    // DamagerUnit.WetWorkKills = 5;
    // try to modify the captor's CapturedUnitsLastTurn
    

	return ELR_NoInterrupt;
}

// static protected function EventListenerReturn OnUnitUnconscious(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
// {
//     // works!
// 	`log("             CapturesAreOkay: OnUnitUnconscious() called", , 'XCom_XP');
// 	return ELR_NoInterrupt;
// }
