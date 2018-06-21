#include <sourcemod>
#include <cstrike>
#include <csgoitems>
#include <sdkhooks>
#include <ptah>
#include <sdktools>
#include <tweaker>

#pragma semicolon 1
#pragma newdecls required

#include "wc/globals.sp"
#include "wc/client.sp"
#include "wc/sdkhooks.sp"
#include "wc/func.sp"
#include "wc/commands.sp"
#include "wc/menu.sp"
#include "wc/menu_callback.sp"
#include "wc/ptah.sp"
#include "wc/database.sp"
#include "wc/native.sp"

public Plugin myinfo =
{
  name = "E' Tweaker",
  version = "1.34",
  author = "ESK0",
  description = "",
  url = "www.github.com/ESK0"
};

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] szError, int iErrMax)
{
  g_bLateLoad = bLate;
  CreateNative("Tweaker_GiveClientKnife", Native_GiveClientKnife);
}

public void OnPluginStart()
{
  g_hOnGlovesRemoved = CreateGlobalForward("Tweaker_OnGlovesRemoved", ET_Ignore, Param_Cell);

  gCvKnifeEnabled = CreateConVar("Tweaker_EnableKnife", "1", "", FCVAR_NONE, true, 0.0, true, 1.0);
  gCvKnifeEnabled.AddChangeHook(OnConVarChanged);

  RegConsoleCmd("sm_wc", Command_WeaponCosmetic);
  RegConsoleCmd("sm_ws", Command_WeaponCosmetic);
  RegConsoleCmd("sm_knife", Command_Knife);
  RegConsoleCmd("sm_gloves", Command_Gloves);
  RegAdminCmd("sm_nametag", Command_NameTag, ADMFLAG_RESERVATION|ADMFLAG_CUSTOM2);
  RegAdminCmd("sm_stattrak", Command_StatTrak, ADMFLAG_RESERVATION|ADMFLAG_CUSTOM2);

  HookEvent("round_start", Event_OnRoundStart);
  HookEvent("round_end", Event_OnRoundEnd);
  HookEvent("player_spawn", Event_OnPlayerSpawn);
  HookEvent("player_death", Event_OnPlayerDeath);

  PTaH(PTaH_GiveNamedItemPre, Hook, GiveNamedItemPre);
  PTaH(PTaH_WeaponCanUse, Hook, WeaponCanUse);


  if(g_bLateLoad)
  {
		if(!g_bCSGOItems)
    {
			g_bCSGOItems = LibraryExists("CSGO_Items");
		}
		if(g_bCSGOItems)
    {
			SyncItems();
		}
	}
  Handle hConfig = LoadGameConfigFile("eTweaker");
  if(hConfig == INVALID_HANDLE)
  {
    SetFailState("gamedata/eTweaker.txt missing");
  }
  g_NameTag_Offset = FindNetVar("m_szCustomName");
  int iEquipOffset = GameConfGetOffset(hConfig, "EquipWearable");
  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetVirtual(iEquipOffset);
  PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
  g_hGiveWearableCall = EndPrepSDKCall();

  int iRemoveOffset = GameConfGetOffset(hConfig, "RemoveAllWearables");
  StartPrepSDKCall(SDKCall_Player);
  PrepSDKCall_SetVirtual(iRemoveOffset);
  g_hRemoveWearableCall = EndPrepSDKCall();
  LateLoad();

  Database.Connect(Database_Connect, "tweaker");
}
public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
  if(convar == gCvKnifeEnabled)
  {
    g_bKnifeEnabled = view_as<bool>(StringToInt(newValue));
  }
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
  if(IsClientInGame(client) && !IsFakeClient(client))
  {
    Database_SaveClientData(client);
  }
}
public Action Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
  g_bIsRoundEnd = false;
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
    int iWeaponNum = CSGOItems_GetWeaponNumByClassName(szWeaponClassname);
    if(iWeaponNum >= 0 && iWeaponNum <= arStoredWeaponsStatTrackEnabled[client].Length)
    {
      bool bStatTrackEnabled = view_as<bool>(arStoredWeaponsStatTrackEnabled[client].Get(iWeaponNum));
      if(bStatTrackEnabled)
      {
        int iKills = arStoredWeaponsStatTrackKills[client].Get(iWeaponNum);
        arStoredWeaponsStatTrackKills[client].Set(iWeaponNum, iKills + 1);
        arModifiedWeapons[client].Set(iWeaponNum, 1);
      }
    }
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
public Action Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
  g_bIsRoundEnd = true;
  return Plugin_Continue;
}
public void OnPluginStartPost()
{
  if(g_bArraySynced)
  {
    return;
  }
  DivideSkinsToArrayList();
  g_bArraySynced = true;
}
public void OnAllPluginsLoaded()
{
	g_bCSGOItems = LibraryExists("CSGO_Items");
	if(g_bCSGOItems)
  {
		SyncItems();
	}
}
public void OnClientPutInServer(int client)
{
  g_iPrevWeapon[client] = INVALID_ENT_REFERENCE;
  g_bIsChangingQuality[client] = false;
  g_bIsChangingSkin[client] = false;
  g_bIsChangingAllSkin[client] = false;
  g_bIsChangingPatternValue[client] = false;
  g_bIsChangingWear[client] = false;
  g_bIsChangingPattern[client] = false;
  g_bIsChangingStatTrack[client] = false;
  g_bIsChangingNametag[client] = false;
  g_bIsChangingNametagValue[client] = false;
  g_bChangedGloves[client] = false;
  g_bHasGloves[client] = false;
  g_iUserDbId[client] = -1;
  g_iStoredKnife[client] = 0;
  Format(g_szStoredGloves[client], sizeof(g_szStoredGloves[]), "");
  SDKHook(client, SDKHook_WeaponEquip, SDK_OnWeaponEquip);
  SDKHook(client, SDKHook_WeaponSwitchPost, SDK_OnWeaponSwitchPost);
}
public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
  if(IsValidClient(client, true))
  {
    if(StrEqual(command, "say", false) || StrEqual(command, "say_team"))
    {
      if(StrEqual(sArgs, "cancel", false) == false)
      {
        int iActiveWeaponNum = CSGOItems_GetActiveWeaponNum(client);
        int iActiveWeapon = CSGOItems_GetActiveWeapon(client);
        if(g_bIsChangingPatternValue[client])
        {
          if(IsStringNumeric(sArgs))
          {
            int pattern = StringToInt(sArgs);
            arStoredWeaponsPattern[client].Set(iActiveWeaponNum, pattern);
            arModifiedWeapons[client].Set(iActiveWeaponNum, 1);
            CSGOItems_RespawnWeapon(client, iActiveWeapon);
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
            arStoredWeaponsNametag[client].SetString(iActiveWeaponNum, sArgs);
            arModifiedWeapons[client].Set(iActiveWeaponNum, 1);
            CSGOItems_RespawnWeapon(client, iActiveWeapon);
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
public void OnLibraryAdded(const char[] szName)
{
	if(StrEqual(szName, "CSGO_Items"))
  {
		g_bCSGOItems = true;
		SyncItems();
	}
}
public void OnLibraryRemoved(const char[] szName)
{
	if(StrEqual(szName, "CSGO_Items"))
  {
		g_bCSGOItems = false;
	}
}
