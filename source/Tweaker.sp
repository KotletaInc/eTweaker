#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#include <eItems>
#include <cstrike>
#include <ptah>
#include <tweaker>

#pragma semicolon 1
#pragma newdecls required

#define AUTHOR "ESK0"
#define VERSION "2.0"
#define TAG_NOCLR "[eTweaker]"

#include "files/globals.sp"
#include "files/client.sp"
#include "files/commands.sp"
//#include "files/servercommands.sp"
#include "files/menu.sp"
#include "files/menu_callback.sp"
#include "files/sdkhooks.sp"
#include "files/func.sp"
#include "files/ptah.sp"
#include "files/native.sp"
#include "files/database.sp"

public Plugin myinfo =
{
	name = "eTweaker",
	author = AUTHOR,
	version = VERSION,
	description = "Tweaker",
	url = "www.steamcommunity.com/id/esk0"
};

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] chError, int iErrMax)
{
	g_bLateLoaded = bLate;
	CreateNative("Tweaker_GiveClientKnife", Native_GiveClientKnife);
}

public void OnPluginStart()
{
	if(GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("This plugin is for CSGO only.");
	}

	if(g_bLateLoaded)
	{
		if(eItems_AreItemsSynced())
		{
			eItems_OnItemsSynced();
		}
		else if(!eItems_AreItemsSyncing())
		{
			eItems_ReSync();
		}
	}

	RegConsoleCmd("sm_wc", Command_WeaponCosmetic);
	RegConsoleCmd("sm_ws", Command_WeaponCosmetic);
	RegConsoleCmd("sm_knife", Command_Knife);
	RegConsoleCmd("sm_gloves", Command_Gloves);
	RegConsoleCmd("sm_nametag", Command_NameTag);
	RegConsoleCmd("sm_stattrak", Command_StatTrak);

	//RegServerCmd("tweaker_updateweapon", ServerCommand_UpdateWeapon, "", ADMFLAG_RCON);

	HookEvent("round_start", Event_OnRoundStart);
	HookEvent("round_end", Event_OnRoundEnd);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("player_spawn", Event_OnPlayerSpawn);

	PTaH(PTaH_GiveNamedItemPre, Hook, GiveNamedItemPre);
	PTaH(PTaH_GiveNamedItemPost, Hook, GiveNamedItemPost);
	PTaH(PTaH_WeaponCanUsePre, Hook, WeaponCanUsePre);
	PTaH(PTaH_SetPlayerModelPost, Hook, SetPlayerModelPost);

	g_iNameTagOffset = FindNetVar("m_szCustomName");

	Handle hConfig = LoadGameConfigFile("eTweaker");
	if(hConfig == INVALID_HANDLE)
	{
		SetFailState("gamedata/eTweaker.txt missing");
	}

	g_hOnGlovesRemoved = CreateGlobalForward("Tweaker_OnGlovesRemoved", ET_Ignore, Param_Cell);

	int iEquipOffset = GameConfGetOffset(hConfig, "EquipWearable");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetVirtual(iEquipOffset);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hGiveWearableCall = EndPrepSDKCall();

	int iRemoveOffset = GameConfGetOffset(hConfig, "RemoveAllWearables");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetVirtual(iRemoveOffset);
	g_hRemoveWearableCall = EndPrepSDKCall();


	g_cvSurfFix = CreateConVar("etweaker_surffix", "0", "Possible issue fix for changing skins on Surf servers", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_cvSurfFix.AddChangeHook(OnConVarChanged);

	g_cvAllowSecondarySkinSelection = CreateConVar("etweaker_allow_secondary_skin_selection", "1", "Allow 'Secondary weapon' skin selection in WS menu", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_cvAllowSecondarySkinSelection.AddChangeHook(OnConVarChanged);

	g_cvAllowPrimarySkinSelection = CreateConVar("etweaker_allow_primary_skin_selection", "1", "Allow 'Primary weapon' skin selection in WS menu", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_cvAllowPrimarySkinSelection.AddChangeHook(OnConVarChanged);

	g_cvAllowKnifeSkinSelection = CreateConVar("etweaker_allow_knife_skin_selection", "1", "Allow 'Knife' skin selection in WS menu", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_cvAllowKnifeSkinSelection.AddChangeHook(OnConVarChanged);

	g_cvAllowAllPaintsSelection = CreateConVar("etweaker_allow_all_paints_selection", "1", "Allow 'All Paints' selection in WS menu", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_cvAllowAllPaintsSelection.AddChangeHook(OnConVarChanged);
	
	g_cvAllowAllSkinsRandomSkin = CreateConVar("etweaker_allow_allskins_randomskin", "1", "Allow 'Random skin' selection in 'All Skins' menu", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_cvAllowAllSkinsRandomSkin.AddChangeHook(OnConVarChanged);

	g_cvAllowGlovesRandomSkin = CreateConVar("etweaker_allow_gloves_randomskin", "1", "Allow 'Random skin' selection in 'Gloves' menu", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_cvAllowGlovesRandomSkin.AddChangeHook(OnConVarChanged);
	
	g_cvAllowCurrentWeaponRandomSkin = CreateConVar("etweaker_allow_currentweapon_randomskin", "1", "Allow 'Random skin' selection in 'Current Weapon' menu", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_cvAllowCurrentWeaponRandomSkin.AddChangeHook(OnConVarChanged);

	g_cvAllowWeaponRandomSkin = CreateConVar("etweaker_allow_weapon_randomskin", "1", "Allow 'Random skin' selection in 'your selected weapon' menu", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_cvAllowWeaponRandomSkin.AddChangeHook(OnConVarChanged);

	g_cvAllowKnifeBareHands = CreateConVar("etweaker_allow_knife_barehand", "1", "Allow 'Bare Hand' knife in 'Knives' menu", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_cvAllowKnifeBareHands.AddChangeHook(OnConVarChanged);

	g_cvAllowKnifeAxe = CreateConVar("etweaker_allow_knife_axe", "1", "Allow 'Axe' knife in 'Knives' menu", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_cvAllowKnifeAxe.AddChangeHook(OnConVarChanged);
	
	g_cvAllowKnifeHammer = CreateConVar("etweaker_allow_knife_hammer", "1", "Allow 'Hammer' knife in 'Knives' menu", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_cvAllowKnifeHammer.AddChangeHook(OnConVarChanged);

	g_cvAllowKnifeWrench = CreateConVar("etweaker_allow_knife_wrench", "1", "Allow 'Wrench' knife in 'Knives' menu", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_cvAllowKnifeWrench.AddChangeHook(OnConVarChanged);

	g_cvHideDisabledSelections = CreateConVar("etweaker_hide_disabled_selections", "0", "Hide disabled selections from menu", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_cvHideDisabledSelections.AddChangeHook(OnConVarChanged);

	g_cvAllowNametags = CreateConVar("etweaker_allow_nametags", "1", "Allow 'nametag' feature", FCVAR_PROTECTED, true, 0.0, true, 1.0);
	g_cvAllowNametags.AddChangeHook(OnConVarChanged);

	
	
	
	Database.Connect(Database_Connect, "tweaker");
	AutoExecConfig(true, "eTweaker");
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if(convar == g_cvSurfFix)
	{
		g_cvSurfFix.SetInt(StringToInt(newValue));
	}
	else if(convar == g_cvAllowSecondarySkinSelection)
	{
		g_cvAllowSecondarySkinSelection.SetInt(StringToInt(newValue));
	}
	else if(convar == g_cvAllowPrimarySkinSelection)
	{
		g_cvAllowPrimarySkinSelection.SetInt(StringToInt(newValue));
	}
	else if(convar == g_cvAllowKnifeSkinSelection)
	{
		g_cvAllowKnifeSkinSelection.SetInt(StringToInt(newValue));
	}
	else if(convar == g_cvAllowAllSkinsRandomSkin)
	{
		g_cvAllowAllSkinsRandomSkin.SetInt(StringToInt(newValue));
	}
	else if(convar == g_cvAllowAllPaintsSelection)
	{
		g_cvAllowAllPaintsSelection.SetInt(StringToInt(newValue));
	}
	else if(convar == g_cvAllowGlovesRandomSkin)
	{
		g_cvAllowGlovesRandomSkin.SetInt(StringToInt(newValue));
	}
	else if(convar == g_cvAllowCurrentWeaponRandomSkin)
	{
		g_cvAllowCurrentWeaponRandomSkin.SetInt(StringToInt(newValue));
	}
	else if(convar == g_cvAllowWeaponRandomSkin)
	{
		g_cvAllowWeaponRandomSkin.SetInt(StringToInt(newValue));
	}
	else if(convar == g_cvAllowKnifeBareHands)
	{
		g_cvAllowKnifeBareHands.SetInt(StringToInt(newValue));
		RemoveForbiddenWeaponFromPlayers(69); //AXE Def. Index 69	
	}
	else if(convar == g_cvAllowKnifeAxe)
	{
		g_cvAllowKnifeAxe.SetInt(StringToInt(newValue));
		RemoveForbiddenWeaponFromPlayers(75); //AXE Def. Index 75
	}
	else if(convar == g_cvAllowKnifeHammer)
	{
		g_cvAllowKnifeHammer.SetInt(StringToInt(newValue));
		RemoveForbiddenWeaponFromPlayers(76); //AXE Def. Index 76
	}
	else if(convar == g_cvAllowKnifeWrench)
	{
		g_cvAllowKnifeWrench.SetInt(StringToInt(newValue));
		RemoveForbiddenWeaponFromPlayers(78); //AXE Def. Index 78
	}
	else if(convar == g_cvHideDisabledSelections)
	{
		g_cvHideDisabledSelections.SetInt(StringToInt(newValue));
	}
	else if(convar == g_cvAllowNametags)
	{
		g_cvAllowNametags.SetInt(StringToInt(newValue));
	}
	

	
}

public void eItems_OnItemsSynced()
{
	g_iWeaponCount = eItems_GetWeaponCount();
	g_iSkinCount = eItems_GetPaintsCount();
	g_iGloveCount = eItems_GetGlovesCount();

	BuildSkinsArrayList();
}

public void BuildSkinsArrayList()
{
	for(int iWeapon = 0; iWeapon < g_iWeaponCount; iWeapon++)
	{
		if(g_ArrayWeapons[iWeapon] == null)
		{
			delete g_ArrayWeapons[iWeapon];
		}

		g_ArrayWeapons[iWeapon] = new ArrayList();
		g_ArrayWeapons[iWeapon].Clear();

		int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iWeapon);
		for(int iSkin = 0; iSkin < g_iSkinCount; iSkin++)
		{
			if(eItems_IsNativeSkin(iSkin, iWeapon, ITEMTYPE_WEAPON) && iWeaponDefIndex != 42 && iWeaponDefIndex != 59)
			{
				int iSkinDefIndex = eItems_GetSkinDefIndexBySkinNum(iSkin);
				if(iSkinDefIndex > 0 && iSkinDefIndex < 10000)
				{

					g_ArrayWeapons[iWeapon].Push(iSkinDefIndex);
				}
			}
		}
	}

	for(int iGlove = 0; iGlove < g_iGloveCount; iGlove++)
	{
		if(g_ArrayGloves[iGlove] == null)
		{
			delete g_ArrayGloves[iGlove];
		}

		g_ArrayGloves[iGlove] = new ArrayList();
		g_ArrayGloves[iGlove].Clear();

		for(int iGloveSkin = 0; iGloveSkin < g_iSkinCount; iGloveSkin++)
		{
			if(eItems_IsSkinNumGloveApplicable(iGloveSkin) && eItems_IsNativeSkin(iGloveSkin, iGlove,  ITEMTYPE_GLOVES))
			{
				int iGloveDefIndex = eItems_GetSkinDefIndexBySkinNum(iGloveSkin);
				g_ArrayGloves[iGlove].Push(iGloveDefIndex);
			}
		}
	}
	g_bDataFullySynced = true;
}

public void OnClientPostAdminCheck(int client)
{
	if(IsValidClient(client))
	{
		Database_OnClientConnect(client);
	}
}

public void OnClientDisconnect(int client)
{
	if(IsValidClient(client))
	{
		Database_SaveClientData(client);
	}
}

public void OnMapStart()
{
	if(g_arMapWeapons != null)
	{
		delete g_arMapWeapons;
		g_arMapWeapons = null;
	}

	g_arMapWeapons = new ArrayList();
}

public void OnClientPutInServer(int client)
{
	g_bIsChangingPatternValue[client] = false;
	g_bIsChangingNametag[client] = false;
	g_bIsChangingNametagValue[client] = false;
	g_bIsChangingPattern[client] = false;
	g_bIsChangingSkin[client] = false;
	g_bIsChangingAllSkin[client] = false;
	g_bIsChangingQuality[client] = false;
	g_bIsChangingWear[client] = false;
	g_bIsChangingStatTrack[client] = false;
	g_iPrevWeapon[client] = INVALID_ENT_REFERENCE;
	g_iStoredKnife[client] = 0;
	g_bChangedGloves[client] = false;
	g_bIsLookingAtCurrentSettings[client] = false;
	g_bHasGloves[client] = false;
	g_iUserDbId[client] = -1;
	Format(g_szStoredGloves[client], sizeof(g_szStoredGloves[]), "");
	SDKHook(client, SDKHook_WeaponSwitchPost, SDK_OnWeaponSwitchPost);
	SDKHook(client, SDKHook_WeaponEquip, SDK_OnWeaponEquip);
}

public Action Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{ 
	g_bIsRoundEnd = false;

	char szWeaponClassname[64];
	for(int i = MaxClients; i < GetMaxEntities(); i++)
	{
		if(!IsValidEntity(i))
		{
			continue;
		}

		GetEntityClassname(i, szWeaponClassname, sizeof(szWeaponClassname));
		if((StrContains(szWeaponClassname, "weapon_")) == -1)
		{
			continue;
		}

		if(GetEntProp(i, Prop_Send, "m_hOwnerEntity") != -1)
		{
			continue;
		}
		int iDefIndex;
		if((iDefIndex = eItems_GetWeaponDefIndexByClassName(szWeaponClassname)) == -1)
		{
			continue;
		}

		if(eItems_IsDefIndexKnife(iDefIndex))
		{
			continue;
		}

		g_arMapWeapons.Push(i);
	}

	return Plugin_Continue;
}

public Action Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_cvSurfFix.BoolValue)
	{
		g_bIsRoundEnd = true;
	}

	return Plugin_Continue;
}

public Action Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(IsValidClient(client, true))
	{
		if(strlen(g_szStoredGloves[client]) > 0)
		{
			char szItemEx[2][32];
			if(ExplodeString(g_szStoredGloves[client], ";",szItemEx, sizeof(szItemEx), sizeof(szItemEx[])) == 2)
			{
				int iGloveDef = StringToInt(szItemEx[0]);
				int iSkinDef = StringToInt(szItemEx[1]);
				AttachGloveSkin(client, iGloveDef, iSkinDef);
			}
		}
	}
	return Plugin_Continue;
}

public Action Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if(IsValidClient(client) && IsValidClient(victim) && client != victim)
	{
		char szWeapon[32];
		char szWeaponClassname[32];
		event.GetString("weapon", szWeapon, sizeof(szWeapon));
		Format(szWeaponClassname, sizeof(szWeaponClassname), "weapon_%s", szWeapon);
		int iWeaponNum = eItems_GetWeaponNumByClassName(szWeaponClassname);
		if(iWeaponNum >= 0 && iWeaponNum <= g_ArrayStoredWeaponsStatTrackEnabled[client].Length)
		{
			bool bStatTrackEnabled = view_as<bool>(g_ArrayStoredWeaponsStatTrackEnabled[client].Get(iWeaponNum));
			if(bStatTrackEnabled)
			{
				int iKills = g_ArrayStoredWeaponsStatTrackKills[client].Get(iWeaponNum);
				g_ArrayStoredWeaponsStatTrackKills[client].Set(iWeaponNum, iKills + 1);
				g_ArrayModifiedWeapons[client].Set(iWeaponNum, 1);
			}
		}
	}
	return Plugin_Continue;
}
public void ResetClientData(int client)
{
	if(g_ArrayStoredWeaponsPaint[client] == null)
	{
		g_ArrayStoredWeaponsPaint[client] = new ArrayList();
	}

	if(g_ArrayStoredWeaponsWear[client] == null)
	{
		g_ArrayStoredWeaponsWear[client] = new ArrayList();
	}

	if(g_ArrayStoredWeaponsPattern[client] == null)
	{
		g_ArrayStoredWeaponsPattern[client] = new ArrayList();
	}

	if(g_ArrayStoredWeaponsQuality[client] == null)
	{
		g_ArrayStoredWeaponsQuality[client] = new ArrayList();
	}

	if(g_ArrayStoredWeaponsNametag[client] == null)
	{
		g_ArrayStoredWeaponsNametag[client] = new ArrayList(1024);
	}

	if(g_ArrayModifiedWeapons[client] == null)
	{
		g_ArrayModifiedWeapons[client] = new ArrayList();
	}

	if(g_ArrayStoredWeaponsStatTrackEnabled[client] == null)
	{
		g_ArrayStoredWeaponsStatTrackEnabled[client] = new ArrayList();
	}

	if(g_ArrayStoredWeaponsStatTrackKills[client] == null)
	{
		g_ArrayStoredWeaponsStatTrackKills[client] = new ArrayList(32);
	}

	g_ArrayStoredWeaponsPaint[client].Clear();
	g_ArrayStoredWeaponsWear[client].Clear();
	g_ArrayStoredWeaponsPattern[client].Clear();
	g_ArrayStoredWeaponsQuality[client].Clear();
	g_ArrayStoredWeaponsNametag[client].Clear();
	g_ArrayModifiedWeapons[client].Clear();
	g_ArrayStoredWeaponsStatTrackEnabled[client].Clear();
	g_ArrayStoredWeaponsStatTrackKills[client].Clear();

	for(int c = 0; c < g_iWeaponCount; c++)
	{
		g_ArrayModifiedWeapons[client].Push(0);
		g_ArrayStoredWeaponsPaint[client].Push(1);
		g_ArrayStoredWeaponsWear[client].Push(1.0);
		g_ArrayStoredWeaponsPattern[client].Push(0);
		g_ArrayStoredWeaponsQuality[client].Push(0);
		g_ArrayStoredWeaponsNametag[client].PushString("");
		g_ArrayStoredWeaponsStatTrackEnabled[client].Push(0);
		g_ArrayStoredWeaponsStatTrackKills[client].Push(0);
	}
}
public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(IsValidClient(client, true))
	{
		if(StrEqual(command, "say", false) || StrEqual(command, "say_team"))
		{
			if(StrEqual(sArgs, "cancel", false) == false)
			{
				int iActiveWeaponNum = eItems_GetActiveWeaponNum(client);
				int iActiveWeapon = eItems_GetActiveWeapon(client);
				if(g_bIsChangingPatternValue[client])
				{
					if(IsStringNumeric(sArgs))
					{
						int pattern = StringToInt(sArgs);
						g_ArrayStoredWeaponsPattern[client].Set(iActiveWeaponNum, pattern);
						g_ArrayModifiedWeapons[client].Set(iActiveWeaponNum, 1);
						eItems_RespawnWeapon(client, iActiveWeapon);
						g_bIsChangingPatternValue[client] = false;
						if(g_bIsChangingPattern[client])
						{
							BuilWeaponPatternMenu(client);
						}
					}
					else
					{
						PrintToChat(client, "[E' Tweaker] Please enter valid number");
					}
					return Plugin_Handled;
				}
				else if(g_bIsChangingNametagValue[client])
				{
					if(strlen(sArgs) > 0)
					{
						g_ArrayStoredWeaponsNametag[client].SetString(iActiveWeaponNum, sArgs);
						g_ArrayModifiedWeapons[client].Set(iActiveWeaponNum, 1);
						eItems_RespawnWeapon(client, iActiveWeapon);
						g_bIsChangingNametagValue[client] = false;
						if(g_bIsChangingNametag[client])
						{
							BuildWeaponNametagMenu(client);
					}
					}
					else
					{
						PrintToChat(client, "[E' Tweaker] Nametag is too short");
					}
					return Plugin_Handled;
				}
			}
			else
			{
				if(g_bIsChangingPatternValue[client] == true)
				{
					g_bIsChangingPatternValue[client] = false;
					BuilWeaponPatternMenu(client);
				}
				else if(g_bIsChangingNametagValue[client] == true)
				{
					g_bIsChangingNametagValue[client] = false;
					BuildWeaponNametagMenu(client);
				}
				return Plugin_Handled;
			}
			return Plugin_Continue;
		}
	}
	return Plugin_Continue;
}