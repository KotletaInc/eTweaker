public void WC_UpdateClientWeapon(int client, int iWeapon)
{
  if(iWeapon != INVALID_ENT_REFERENCE)
  {
    int iWeaponNum = CSGOItems_GetWeaponNumByWeapon(iWeapon);
    int iPaintKit = arStoredWeaponsPaint[client].Get(iWeaponNum);
    SetEntProp(iWeapon, Prop_Send, "m_iAccountID", GetSteamAccountID(client));

    if(iPaintKit > 1)
    {
      SetEntProp(iWeapon, Prop_Send, "m_iItemIDLow", -1);
      SetEntProp(iWeapon, Prop_Send, "m_nFallbackPaintKit", iPaintKit);
      float fWear = arStoredWeaponsWear[client].Get(iWeaponNum);
      if(fWear > 0.0)
      {
        SetEntPropFloat(iWeapon, Prop_Send, "m_flFallbackWear", fWear);
      }
      int iPattern = arStoredWeaponsPattern[client].Get(iWeaponNum);
      if(iPattern > 0)
      {
        SetEntProp(iWeapon, Prop_Send, "m_nFallbackSeed", iPattern);
      }
    }
    
    int iQuality = arStoredWeaponsQuality[client].Get(iWeaponNum);
    if(iQuality > 0)
    {
      SetEntProp(iWeapon, Prop_Send, "m_iEntityQuality", iQuality);
    }
    bool bStatTrackEnabled = view_as<bool>(arStoredWeaponsStatTrackEnabled[client].Get(iWeaponNum));
    int iStatTrackKills = arStoredWeaponsStatTrackKills[client].Get(iWeaponNum);
    if(bStatTrackEnabled)
    {
      SetEntProp(iWeapon, Prop_Send, "m_nFallbackStatTrak", iStatTrackKills);
    }

    char szNameTag[1024];
    arStoredWeaponsNametag[client].GetString(iWeaponNum, szNameTag, sizeof(szNameTag));
    if(strlen(szNameTag) > 0)
    {
      SetEntDataString(iWeapon, g_NameTag_Offset, szNameTag, sizeof(szNameTag));
    }
  }
}
public void ResetClientData(int client)
{
  if(arStoredWeaponsPaint[client] == null)
  {
    arStoredWeaponsPaint[client] = new ArrayList();
  }

  if(arStoredWeaponsQuality[client] == null)
  {
    arStoredWeaponsQuality[client] = new ArrayList();
  }

  if(arStoredWeaponsWear[client] == null)
  {
    arStoredWeaponsWear[client] = new ArrayList();
  }

  if(arStoredWeaponsPattern[client] == null)
  {
    arStoredWeaponsPattern[client] = new ArrayList();
  }

  if(arModifiedWeapons[client] == null)
  {
    arModifiedWeapons[client] = new ArrayList();
  }

  if(arStoredWeaponsNametag[client] == null)
  {
    arStoredWeaponsNametag[client] = new ArrayList(1024);
  }

  if(arStoredWeaponsStatTrackEnabled[client] == null)
  {
    arStoredWeaponsStatTrackEnabled[client] = new ArrayList();
  }

  if(arStoredWeaponsStatTrackKills[client] == null)
  {
    arStoredWeaponsStatTrackKills[client] = new ArrayList(32);
  }

  arStoredWeaponsPaint[client].Clear();
  arStoredWeaponsQuality[client].Clear();
  arStoredWeaponsWear[client].Clear();
  arStoredWeaponsPattern[client].Clear();
  arModifiedWeapons[client].Clear();
  arStoredWeaponsNametag[client].Clear();
  arStoredWeaponsStatTrackEnabled[client].Clear();
  arStoredWeaponsStatTrackKills[client].Clear();

  for(int c = 0; c < iWeaponCount; c++)
  {
    arModifiedWeapons[client].Push(0);
    arStoredWeaponsPaint[client].Push(1);
    arStoredWeaponsQuality[client].Push(0);
    arStoredWeaponsPattern[client].Push(0);
    arStoredWeaponsNametag[client].PushString("");
    arStoredWeaponsWear[client].Push(0.00001);
    arStoredWeaponsStatTrackEnabled[client].Push(0);
    arStoredWeaponsStatTrackKills[client].Push(0);
  }
}
public void LateLoad()
{
  for(int client = 0; client <= MaxClients; client++)
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
    if(IsValidClient(client))
    {
      SDKHook(client, SDKHook_WeaponEquip, SDK_OnWeaponEquip);
      SDKHook(client, SDKHook_WeaponSwitchPost, SDK_OnWeaponSwitchPost);
    }
  }
}
public void SyncItems()
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
public void CSGOItems_OnItemsSynced()
{
  iWeaponCount = CSGOItems_GetWeaponCount();
  iSkinCount = CSGOItems_GetSkinCount();
  iGloveCount = CSGOItems_GetGlovesCount();
  OnPluginStartPost();
}
public void DivideSkinsToArrayList()
{
  float fResult = view_as<float>(iWeaponCount) / 2.0;
  int iResult = RoundToFloor(fResult);
  for(int a = 0; a < iResult; a++)
  {
    AddWeaponSkinsToWeaponArray(a);
  }
  for(int b = iResult; b < iWeaponCount; b++)
  {
    AddWeaponSkinsToWeaponArray(b);
  }
  for(int c = 0; c < iGloveCount; c++)
  {
    AddGloveSkinsToGlovesArray(c);
  }
  PrintToServer("[TWEAKER] DATA SYNCED!");
  g_bDataFullySynced = true;
}
public void AddGloveSkinsToGlovesArray(int iGloveNum)
{
  arGloves[iGloveNum] = new ArrayList();
  arGloves[iGloveNum].Clear();
  for(int a = 0; a < iSkinCount; a++)
  {
    if(CSGOItems_IsSkinNumGloveApplicable(a) && CSGOItems_IsNativeSkin(a, iGloveNum,  ITEMTYPE_GLOVES))
    {
      int iGloveSkin = CSGOItems_GetSkinDefIndexBySkinNum(a);
      arGloves[iGloveNum].Push(iGloveSkin);
    }
  }
}
public void AddWeaponSkinsToWeaponArray(int iWeaponNum)
{
  arWeapons[iWeaponNum] = new ArrayList();
  arWeapons[iWeaponNum].Clear();
  int iWeaponDef = CSGOItems_GetWeaponDefIndexByWeaponNum(iWeaponNum);
  for(int a = 0; a < iSkinCount; a++)
  {
    if(CSGOItems_IsNativeSkin(a, iWeaponNum, ITEMTYPE_WEAPON) && iWeaponDef != 42 && iWeaponDef != 59)
    {
      int iSkinDef = CSGOItems_GetSkinDefIndexBySkinNum(a);
      if(iSkinDef != 0 && iSkinDef < 10000)
      {
        arWeapons[iWeaponNum].Push(iSkinDef);
      }
    }
  }
  SortADTArray(arWeapons[iWeaponNum], Sort_Ascending, Sort_Integer);
}
public void RemoveClientGloves(int client)
{
  if(IsValidClient(client))
  {
    SDKCall(g_hRemoveWearableCall, client);
    SetEntPropString(client, Prop_Send, "m_szArmsModel", g_szDefaultGloves[client]);
    RefreshVM(client);
    Call_StartForward(g_hOnGlovesRemoved);
    Call_PushCell(client);
    Call_Finish();
  }
}
public void AttachGloveSkin(int client, int iGloveDef, int iSkinDef)
{
  int iGloves = CreateEntityByName("wearable_item");
  if(iGloves != -1 && iSkinDef != -1)
  {
    char szGloveWorldModel[256];
    CSGOItems_GetGlovesWorldModelByDefIndex(iGloveDef, szGloveWorldModel, sizeof(szGloveWorldModel));
    int iModelIndex = PrecacheModel(szGloveWorldModel, true);
    SetEntProp(iGloves, Prop_Send, "m_bInitialized", 1);
    SetEntProp(iGloves, Prop_Send, "m_iItemDefinitionIndex", iGloveDef);
    SetEntProp(iGloves, Prop_Send, "m_iAccountID", GetSteamAccountID(client));
    SetEntProp(iGloves, Prop_Send, "m_iItemIDHigh", 0);
    SetEntProp(iGloves, Prop_Send, "m_OriginalOwnerXuidLow", 0);
    SetEntProp(iGloves, Prop_Send, "m_OriginalOwnerXuidHigh", 0);
    SetEntProp(iGloves, Prop_Send, "m_iItemIDLow", -1);
    SetEntProp(iGloves, Prop_Send, "m_nFallbackPaintKit", iSkinDef);
    SetEntProp(iGloves, Prop_Send, "m_iEntityQuality", 4);
    SetEntPropFloat(iGloves, Prop_Send, "m_flFallbackWear", 0.0001);
    SetEntPropEnt(iGloves, Prop_Send, "m_hOwnerEntity", client);
    SetEntProp(iGloves, Prop_Send, "m_nModelIndex", iModelIndex);
    SetEntPropEnt(iGloves, Prop_Data, "m_hParent", client);
    SetEntPropEnt(iGloves, Prop_Data, "m_hOwnerEntity", client);
    SetEntPropEnt(iGloves, Prop_Data, "m_hMoveParent", client);
    SetEntProp(client, Prop_Send, "m_nBody", 1);
    SetEntityModel(iGloves, szGloveWorldModel);
    SetEntProp(iGloves, Prop_Send, "m_iTeamNum", GetClientTeam(client));
    SetEntProp(client, Prop_Send, "m_nBody", 1);
    SetEntPropString(client, Prop_Send, "m_szArmsModel", "");
    SDKCall(g_hGiveWearableCall, client, iGloves);
    RefreshVM(client);
    SDKHook(iGloves, SDKHook_SetTransmit, EventSDK_SetTransmit);
  }
}
public Action EventSDK_SetTransmit(int iGloves, int client)
{
	if(IsValidClient(client))
	{
    int iOwner = GetEntPropEnt(iGloves, Prop_Data, "m_hOwnerEntity");
    int iTarget = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
    if(iOwner != client && iTarget != iOwner)
    {
      return Plugin_Handled;
    }
	}
	return Plugin_Continue;
}
public void DebugSkins()
{
  char szWeaponDisplayName[32];
  char szSkinDisplayName[32];
  for(int a = 0; a < iWeaponCount; a++)
  {
    CSGOItems_GetWeaponDisplayNameByWeaponNum(a, szWeaponDisplayName, sizeof(szWeaponDisplayName));
    LogMessage("---- %s ----", szWeaponDisplayName);
    for(int b = 0; b < arWeapons[a].Length; b++)
    {
      int iSkinDef = arWeapons[a].Get(b);
      CSGOItems_GetSkinDisplayNameByDefIndex(iSkinDef, szSkinDisplayName, sizeof(szSkinDisplayName));
      LogMessage("    - SkinDef: %i | Name: %s", iSkinDef, szSkinDisplayName);
    }
  }
}
stock bool RefreshVM(int client)
{
  if(IsValidClient(client, true))
  {
    Event event = CreateEvent("player_spawn", true);
    if (event != null)
    {
      event.SetInt("userid", GetClientUserId(client));
      event.FireToClient(client);
      event.Cancel();
      return true;
    }
  }
  return false;
}
stock bool IsStringNumeric(const char[] szText)
{
  int iLen = strlen(szText);
  for (int i = 0; i < iLen; i++)
  {
    if (!IsCharNumeric(szText[i]))
    {
      return false;
    }
  }
  return true;
}
stock int FindNetVar(const char[] szProp)
{
	int iIter = 0;
	int iInfo = 0;

	char pClasses[][] =
	{
		"Player", "CSPlayer", "CCSPlayer", "GameResource", "GameResources",
		"CGameResource", "CGameResources", "CSGameResource", "CSGameResources",
		"CCSGameResource", "CCSGameResources", "BasePlayer", "CBasePlayer",
		"BaseEntity", "CBaseEntity", "BaseWeapon", "CBaseWeapon", "BaseGrenade",
		"CBaseGrenade", "BaseCombatWeapon", "CBaseCombatWeapon", "WeaponCSBase",
		"CWeaponCSBase", "CSWeaponCSBase", "CCSWeaponCSBase", "PlayerResource",
		"CPlayerResource", "CSPlayerResource", "CCSPlayerResource", "PlayerResources",
		"CPlayerResources", "CSPlayerResources", "CCSPlayerResources", "BaseAnimating",
		"CBaseAnimating", "BaseCombatCharacter", "CBaseCombatCharacter",
		"BaseMultiplayerPlayer", "CBaseMultiplayerPlayer", "BaseFlex", "CBaseFlex"
	};
	for (iIter = 0; iIter < sizeof(pClasses); iIter++)
	{
		if((iInfo = FindSendPropInfo(pClasses[iIter], szProp)) > 0)
    {
      return iInfo;
    }
	}
	return 0;
}
