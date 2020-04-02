public void UpdateClientWeapon(int client, int iWeapon)
{
  if(IsValidClient(client, true))
  {
    if(iWeapon != INVALID_ENT_REFERENCE)
    {
      int iWeaponNum = CSGOItems_GetWeaponNumByWeapon(iWeapon);
      SetEntProp(iWeapon, Prop_Send, "m_iAccountID", GetSteamAccountID(client));
      if(g_ArrayStoredWeaponsPaint[client].Length >= iWeaponNum)
      {
        int iPaintKit = g_ArrayStoredWeaponsPaint[client].Get(iWeaponNum);
        if(iPaintKit > 1)
        {
          SetEntProp(iWeapon, Prop_Send, "m_iItemIDLow", -1);
          SetEntProp(iWeapon, Prop_Send, "m_nFallbackPaintKit", iPaintKit);

          if(g_ArrayStoredWeaponsWear[client].Length >= iWeaponNum)
          {
            float fWear = g_ArrayStoredWeaponsWear[client].Get(iWeaponNum);
            if(fWear > 0.0)
            {
              SetEntPropFloat(iWeapon, Prop_Send, "m_flFallbackWear", fWear);
            }
          }
          if(g_ArrayStoredWeaponsPattern[client].Length >= iWeaponNum)
          {
            int iPattern = g_ArrayStoredWeaponsPattern[client].Get(iWeaponNum);
            if(iPattern > 0)
            {
              SetEntProp(iWeapon, Prop_Send, "m_nFallbackSeed", iPattern);
            }
          }
        }
      }
      if(g_ArrayStoredWeaponsQuality[client].Length >= iWeaponNum)
      {
        int iQuality = g_ArrayStoredWeaponsQuality[client].Get(iWeaponNum);
        if(iQuality > 0)
        {
          SetEntProp(iWeapon, Prop_Send, "m_iEntityQuality", iQuality);
        }
      }
      if((g_ArrayStoredWeaponsStatTrackEnabled[client].Length >= iWeaponNum) && (g_ArrayStoredWeaponsStatTrackKills[client].Length >= iWeaponNum))
      {
        bool bStatTrackEnabled = view_as<bool>(g_ArrayStoredWeaponsStatTrackEnabled[client].Get(iWeaponNum));
        int iStatTrackKills = g_ArrayStoredWeaponsStatTrackKills[client].Get(iWeaponNum);
        if(bStatTrackEnabled)
        {
          SetEntProp(iWeapon, Prop_Send, "m_nFallbackStatTrak", iStatTrackKills);
        }
      }  

      if(g_ArrayStoredWeaponsNametag[client].Length >= iWeaponNum)
      {
        char szNameTag[1024];
        g_ArrayStoredWeaponsNametag[client].GetString(iWeaponNum, szNameTag, sizeof(szNameTag));
        if(strlen(szNameTag) > 0)
        {
          SetEntDataString(iWeapon, g_iNameTagOffset, szNameTag, sizeof(szNameTag));
        }
      }
      
    }
  }
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
    //SDKHook(iGloves, SDKHook_SetTransmit, EventSDK_SetTransmit);
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

public bool IsKnifeForbidden(int iDefIndex)
{
    if(iDefIndex == 42 || iDefIndex == 59 || iDefIndex == 41 || iDefIndex == 74 || iDefIndex == 80)
    {
        return true;
    }
    return false;
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
stock int FindClientBySteamID64(const char[] szSteamID64)
{
  for(int i = 0; i <= MaxClients; i++)
  {
    if(IsValidClient(i))
    {
      char szClientSteamID64[64];
      if(GetClientAuthId(i, AuthId_SteamID64, szClientSteamID64, sizeof(szClientSteamID64)))
      {
        if(StrEqual(szSteamID64, szClientSteamID64, false))
        {
          return i;
        }
      }
    }
  }
  return -1;
}