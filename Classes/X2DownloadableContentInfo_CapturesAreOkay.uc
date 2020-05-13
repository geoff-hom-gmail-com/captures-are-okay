//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_CapturesAreOkay.uc
//           
//	The X2DownloadableContentInfo class provides basic hooks into XCOM gameplay events. 
//  Ex. behavior when the player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_CapturesAreOkay extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{	
}

/// <summary>
/// This method is run when the player loads a saved game directly into Strategy while this DLC is installed
/// </summary>
static event OnLoadedSavedGameToStrategy()
{

}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed. When a new campaign is started the initial state of the world
/// is contained in a strategy start state. Never add additional history frames inside of InstallNewCampaign, add new state objects to the start state
/// or directly modify start state objects
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{
}

/// <summary>
/// Called just before the player launches into a tactical a mission while this DLC / Mod is installed.
/// Allows dlcs/mods to modify the start state before launching into the mission
/// </summary>
static event OnPreMission(XComGameState StartGameState, XComGameState_MissionSite MissionState)
{
	// Not working. Never called.
	`log("             CapturesAreOkay: OnPreMission() called", , 'XCom_XP');
}

/// <summary>
/// Called when the player completes a mission while this DLC / Mod is installed.
/// </summary>
static event OnPostMission()
{
}



	// hmm, if I override the unit class, then anything new should be made with my class. the issue is that agents must be made at the start of a campaign, as it tracks everything. i'd have to find a way to upgrade them when first loading a save. also, if the mod was ever uninstalled, wouldn't that destroy the save?

	// I could do a screen listener to do a reset in strategy. so, how is the kill counter working from history?

	// this `HISTORY thing is interesting. perhaps I can grab that in awardmissionxp and just calc from there? 
	// what is XComGameStateHistory ?
	// what is XComGameState_BattleData?
	// andromedons could also be an issue, as it may be two separate units? just an outlier

	// shucks; I think it sends the captor data only when a unit is KO'd. So it has to be intercepted there?! Then a savegame mid-mission won't work. 
	// though it's definitely saving how many captures a unit/agent has had thru the game

	// well, battledata does have a list of units who were captured last mission; does that unit store data about who KO'd it? 
	// LastDamagedByUnitID ?!!
	// ugh; I don't see the list of troops in battledata. just agents

	// note that a bleeding-out agent can be saved and thus would be unconscious. so we just need to check that the unit who ko'd it is an agent
	// I could also hack a solution. Since it does record the number of capturedEnemies in the mission
	// no wait. bd has capturedunc units; and that list will account for andromedon, or bleeding out heroes

	// ugh, how do I access my array statically? or from one function to the listener...? there aren't static vars, unless maybe in XComGameInfo. do I subclass that? subclass gameinfo?
	// well, I guess I could go up a level, to the class that calls awardMissionXP(). Then I could call a new function and pass in something. So then that class needs to be able to access my eventlistener class. Same issue?
	

/// <summary>
/// Called when the player is doing a direct tactical->tactical mission transfer. Allows mods to modify the
/// start state of the new transfer mission if needed
/// </summary>
static event ModifyTacticalTransferStartState(XComGameState TransferStartState)
{

}

/// <summary>
/// Called after the player exits the post-mission sequence while this DLC / Mod is installed.
/// </summary>
static event OnExitPostMissionSequence()
{

}

/// <summary>
/// Called after the Templates have been created (but before they are validated) while this DLC / Mod is installed.
/// </summary>
static event OnPostTemplatesCreated()
{
	`log("             -----------CapturesAreOkay mod is running; OnPostTemplatesCreated---------", , 'XCom_XP');

}

/// <summary>
/// Called when the difficulty changes and this DLC is active
/// </summary>
static event OnDifficultyChanged()
{

}

/// <summary>
/// Called by the Geoscape tick
/// </summary>
static event UpdateDLC()
{

}

/// <summary>
/// Called after HeadquartersAlien builds a Facility
/// </summary>
static event OnPostAlienFacilityCreated(XComGameState NewGameState, StateObjectReference MissionRef)
{

}

/// <summary>
/// Called after a new Alien Facility's doom generation display is completed
/// </summary>
static event OnPostFacilityDoomVisualization()
{

}

/// <summary>
/// Called when viewing mission blades, used primarily to modify tactical tags for spawning
/// Returns true when the mission's spawning info needs to be updated
/// </summary>
static function bool ShouldUpdateMissionSpawningInfo(StateObjectReference MissionRef)
{
	return false;
}

/// <summary>
/// Called when viewing mission blades, used primarily to modify tactical tags for spawning
/// Returns true when the mission's spawning info needs to be updated
/// </summary>
static function bool UpdateMissionSpawningInfo(StateObjectReference MissionRef)
{
	return false;
}

/// <summary>
/// Called when viewing mission blades, used to add any additional text to the mission description
/// </summary>
static function string GetAdditionalMissionDesc(StateObjectReference MissionRef)
{
	return "";
}

/// <summary>
/// Called from X2AbilityTag:ExpandHandler after processing the base game tags. Return true (and fill OutString correctly)
/// to indicate the tag has been expanded properly and no further processing is needed.
/// </summary>
static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	return false;
}

/// <summary>
/// Called from XComGameState_Unit:GatherUnitAbilitiesForInit after the game has built what it believes is the full list of
/// abilities for the unit based on character, class, equipment, et cetera. You can add or remove abilities in SetupData.
/// </summary>
static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{

}

/// <summary>
/// Calls DLC specific popup handlers to route messages to correct display functions
/// </summary>
static function bool DisplayQueuedDynamicPopup(DynamicPropertySet PropertySet)
{

}