class X2EventListener_CapturesAreOkay extends X2EventListener;

var int TestInt;

static function array<X2DataTemplate> CreateTemplates() 
{
    local array<X2DataTemplate> Templates;

    `log("             CapturesAreOkay: CreateTemplates() called", , 'XCom_XP');

    Templates.AddItem(CreateTacticalGameEndTemplate());
    Templates.AddItem(CreateUnitBeginPlayTemplate());

    return Templates;
}

// Listen for a time to count the mission's captures for each agent. OnPostMission() hook in X2DownloadableContentInfo_CapturesAreOkay not working (5.13.2020).
static function X2EventListenerTemplate CreateTacticalGameEndTemplate()
{
    local X2EventListenerTemplate Template;

    `CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'TacticalGameEnd');
    Template.RegisterInTactical = true;
    Template.AddEvent('TacticalGameEnd', OnTacticalGameEnd);

    return Template;
}

// Listen for a time to reset the number of mission captures for each agent. OnPreMission() hook in X2DownloadableContentInfo_CapturesAreOkay not working (5.13.2020).
static function X2EventListenerTemplate CreateUnitBeginPlayTemplate()
{
	local X2EventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'OnUnitBeginPlay');
	Template.RegisterInTactical = true;
	Template.AddEvent('OnUnitBeginPlay', OnUnitBeginPlay);

	return Template;
}

// Listen for ?? a time to reset the number of mission captures for each agent. OnPreMission() hook in X2DownloadableContentInfo_CapturesAreOkay not working (5.13.2020).
static function X2EventListenerTemplate CreateUnitUnconsciousTemplate()
{
	local X2EventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'UnitUnconscious');
	Template.RegisterInTactical = true;
	Template.AddEvent('UnitUnconscious', OnUnitUnconscious);

	return Template;
}

    // commit this to github. Then comment it out and try doing onunitunconc. instead. more robust

// Count the mission's captures for each agent.
static protected function EventListenerReturn OnTacticalGameEnd(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local XComGameStateHistory History;
    local XComGameState_BattleData BattleData;
   	local array<StateObjectReference> CapturedUnitRefs;
    local XComGameState_Unit AgentUnit, CapturedUnit, DamagerUnit;
    local int i;

    local XComGameState NewGameState;
	local XComGameState_HeadquartersDio DioHQ;
	local XComGameState_MissionSite MissionState;
	local XComGameState_StrategyAction_Mission MissionAction;
    
    `log("             CapturesAreOkay: OnTacticalGameEnd() called", , 'XCom_XP');

    History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
    CapturedUnitRefs = BattleData.CapturedUnconsciousUnits;
	
    /* We're assuming the captured used was last damaged by the unit that knocked it unconscious. That should be the case. 
    The only ways to knock an enemy unconscious require doing damage. Subdue. Zephyr's melee attack. Even Axiom's Smash has to hit before it can apply Unconscious.
    To be safer, we'll log the damager's name.
    */

    // [X] captured by [Y (total [Z])]
    for (i = 0; i < CapturedUnitRefs.Length; ++i)
    {
		CapturedUnit = XComGameState_Unit(GameState.ModifyStateObject(class'XComGameState_Unit', CapturedUnitRefs[i].ObjectID));
        DamagerUnit = XComGameState_Unit(GameState.ModifyStateObject(class'XComGameState_Unit', CapturedUnit.LastDamagedByUnitID));
        DamagerUnit.WetWorkKills++;
        `log("             CapturesAreOkay: [" $ CapturedUnit.GetFullName() $ "] captured by [" $ DamagerUnit.GetNickName(true) $ " (total [" $ DamagerUnit.WetWorkKills $ "])]", , 'XCom_XP');
    }

	return ELR_NoInterrupt;
}

// Reset the number of mission captures for each agent. 
// This currently runs for all units, including enemies, as they all begin play.
static protected function EventListenerReturn OnUnitBeginPlay(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local XComGameState_Unit Unit;
    
    Unit = XComGameState_Unit(EventSource);
    Unit.WetWorkKills = 0;

    // `log("             CapturesAreOkay: Agent [" $ Unit.GetFullName() $ "]", , 'XCom_XP');

	return ELR_NoInterrupt;
}

// ??
static protected function EventListenerReturn OnUnitUnconscious(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit Captor;

    Captor = XComGameState_Unit(EventData);
    Captor.WetWorkKills++;
    `log("             CapturesAreOkay: [" $ DamagerUnit.GetNickName(true) $ "] knocked out an enemy.", , 'XCom_XP');
    
	return ELR_NoInterrupt;
}
