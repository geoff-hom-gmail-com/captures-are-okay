class X2EventListener_CapturesAreOkay extends X2EventListener;

var int TestInt;

// Create templates for this mod.
static function array<X2DataTemplate> CreateTemplates() 
{
    local array<X2DataTemplate> Templates;

    `log("             CapturesAreOkay: CreateTemplates() called.", , 'XCom_XP');

    Templates.AddItem(CreateUnitBeginPlayTemplate());
    // Templates.AddItem(CreateUnitUnconsciousTemplate());
    Templates.AddItem(CreateTacticalGameEndTemplate());

    return Templates;
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

// Listen for when a unit is knocked unconscious, to increment the captor's count.
// static function X2EventListenerTemplate CreateUnitUnconsciousTemplate()
// {
// 	local X2EventListenerTemplate Template;

// 	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'UnitUnconscious');
// 	Template.RegisterInTactical = true;
// 	Template.AddEvent('UnitUnconscious', OnUnitUnconscious);

// 	return Template;
// }

// Listen for a time to count the mission's captures for each agent. OnPostMission() hook in X2DownloadableContentInfo_CapturesAreOkay not working (5.13.2020).
static function X2EventListenerTemplate CreateTacticalGameEndTemplate()
{
    local X2EventListenerTemplate Template;

    `CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'TacticalGameEnd');
    Template.RegisterInTactical = true;
    Template.AddEvent('TacticalGameEnd', OnTacticalGameEnd);

    return Template;
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

// This is bugged, so we're not using it. Captor.WetWorkKills isn't persisting. E.g., KO two enemies in one mission, and it'll report just 1. I'm sure it's an easy fix, but I don't know how, and documentation is lacking. Going thru event "TacticalGameEnd" instead.
// Increase the captor's capture count for this mission.
// static protected function EventListenerReturn OnUnitUnconscious(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
// {
// 	local XComGameState_Unit CapturedUnit, Captor;

//     CapturedUnit = XComGameState_Unit(EventData);
//     Captor = XComGameState_Unit(GameState.ModifyStateObject(class'XComGameState_Unit', CapturedUnit.LastDamagedByUnitID));
//     Captor.WetWorkKills++;
    
//     // "[Axiom] knocked out [Purifier]. Axiom KOs [1]."
//     `log("             CapturesAreOkay: [" $ Captor.GetNickName(true) $ "] knocked out [" $ CapturedUnit.GetFullName() $ "]. " $ Captor.GetNickName(true) $ " KOs [" $ Captor.WetWorkKills $ "].", , 'XCom_XP');

// 	return ELR_NoInterrupt;
// }
    
// Count the mission's captures for each agent.
static protected function EventListenerReturn OnTacticalGameEnd(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local XComGameStateHistory History;
    local XComGameState_BattleData BattleData;
   	local array<StateObjectReference> CapturedUnitRefs;
    local XComGameState_Unit CapturedUnit, DamagerUnit;
    local int i;
    
    `log("             CapturesAreOkay: OnTacticalGameEnd() called.", , 'XCom_XP');

    History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
    CapturedUnitRefs = BattleData.CapturedUnconsciousUnits;
    
    /* We're assuming the captured used was last damaged by the unit that knocked it unconscious. That should be the case. 
    The only ways to knock an enemy unconscious require doing damage. Subdue. Zephyr's melee attack. Even Axiom's Smash has to hit before it can apply Unconscious.
    To be safer, we'll log the damager's name.
    */
    for (i = 0; i < CapturedUnitRefs.Length; ++i)
    {
		CapturedUnit = XComGameState_Unit(GameState.ModifyStateObject(class'XComGameState_Unit', CapturedUnitRefs[i].ObjectID));
        DamagerUnit = XComGameState_Unit(GameState.ModifyStateObject(class'XComGameState_Unit', CapturedUnit.LastDamagedByUnitID));
        DamagerUnit.WetWorkKills++;

        // "[Axiom] knocked out [Purifier]. Axiom KOs [1]."
        `log("             CapturesAreOkay: [" $ DamagerUnit.GetNickName(true) $ "] knocked out [" $ CapturedUnit.GetFullName() $ "]. " $ DamagerUnit.GetNickName(true) $ " KOs [" $ DamagerUnit.WetWorkKills $ "].", , 'XCom_XP');
    }

	return ELR_NoInterrupt;
}