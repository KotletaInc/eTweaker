#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#include <csgoitems>
#include <cstrike>
#include <ptah>
#include <tweaker>

#pragma semicolon 1
#pragma newdecls required

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
  name = "e'Tweaker",
  author = "ESK0",
  version = "1.5",
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
    if(CSGOItems_AreItemsSynced())
    {
      CSGOItems_OnItemsSynced();
    }
    else if(!CSGOItems_AreItemsSyncing())
    {
      CSGOItems_ReSync();
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
  PTaH(PTaH_WeaponCanUsePre, Hook, WeaponCanUsePre);

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

  Database.Connect(Database_Connect, "tweaker");
}

public Action test(int client, int args)
{
  PrintToChat(client, "%i, %i, %i", g_iWeaponCount, g_iSkinCount, g_iGloveCount);
}
public void CSGOItems_OnItemsSynced()
{
  g_iWeaponCount = CSGOItems_GetWeaponCount();
  g_iSkinCount = CSGOItems_GetSkinCount();
  g_iGloveCount = CSGOItems_GetGlovesCount();

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

    int iWeaponDefIndex = CSGOItems_GetWeaponDefIndexByWeaponNum(iWeapon);
    for(int iSkin = 0; iSkin < g_iSkinCount; iSkin++)
    {
      if(CSGOItems_IsNativeSkin(iSkin, iWeapon, ITEMTYPE_WEAPON) && iWeaponDefIndex != 42 && iWeaponDefIndex != 59)
      {
        int iSkinDefIndex = CSGOItems_GetSkinDefIndexBySkinNum(iSkin);
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
      if(CSGOItems_IsSkinNumGloveApplicable(iGloveSkin) && CSGOItems_IsNativeSkin(iGloveSkin, iGlove,  ITEMTYPE_GLOVES))
      {
        int iGloveDefIndex = CSGOItems_GetSkinDefIndexBySkinNum(iGloveSkin);
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
  if(IsClientInGame(client) && !IsFakeClient(client))
  {
    Database_SaveClientData(client);
  }
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
  g_bHasGloves[client] = false;
  g_iUserDbId[client] = -1;
  Format(g_szStoredGloves[client], sizeof(g_szStoredGloves[]), "");
  SDKHook(client, SDKHook_WeaponEquip, SDK_OnWeaponEquip);
  SDKHook(client, SDKHook_WeaponSwitchPost, SDK_OnWeaponSwitchPost);
}

public Action Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
  g_bIsRoundEnd = false;
  return Plugin_Continue;
}

public Action Event_OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
  g_bIsRoundEnd = true;
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
    int iWeaponNum = CSGOItems_GetWeaponNumByClassName(szWeaponClassname);
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
    g_ArrayStoredWeaponsWear[client].Push(0.00001);
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
        int iActiveWeaponNum = CSGOItems_GetActiveWeaponNum(client);
        int iActiveWeapon = CSGOItems_GetActiveWeapon(client);
        if(g_bIsChangingPatternValue[client])
        {
          if(IsStringNumeric(sArgs))
          {
            int pattern = StringToInt(sArgs);
            g_ArrayStoredWeaponsPattern[client].Set(iActiveWeaponNum, pattern);
            g_ArrayModifiedWeapons[client].Set(iActiveWeaponNum, 1);
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
            g_ArrayStoredWeaponsNametag[client].SetString(iActiveWeaponNum, sArgs);
            g_ArrayModifiedWeapons[client].Set(iActiveWeaponNum, 1);
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