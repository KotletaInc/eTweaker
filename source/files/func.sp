public void UpdateClientWeapon(int client, int iWeapon)
{
	if(IsValidClient(client, true))
	{
		if(iWeapon != INVALID_ENT_REFERENCE)
		{
			int iWeaponNum = CSGOItems_GetWeaponNumByWeapon(iWeapon);
			if(iWeaponNum == -1)
			{
				return;
			}
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
							SetEntPropFloat(iWeapon, Prop_Send, "m_flFallbackWear", (fWear / 100000));
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

			if(g_ArrayStoredWeaponsNametag[client].Length >= iWeaponNum && g_cvAllowNametags.BoolValue)
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

public void GetKnifeDisplayName(int iDefIndex, char[] buffer, int len)
{
    switch(iDefIndex)
    {
        case 0: strcopy(buffer, len, "Knife");
        case 42: strcopy(buffer, len, "CT Knife");
        case 59: strcopy(buffer, len, "T Knife");
        case 51: strcopy(buffer, len, "Golden Knife");
        default: CSGOItems_GetWeaponDisplayNameByDefIndex(iDefIndex, buffer, len);
    }
}

public void GetWeaponWear(int client, int iWeaponNum, char[] buffer, int len)
{
    float fWepWear = g_ArrayStoredWeaponsWear[client].Get(iWeaponNum);
    switch(fWepWear)
    {
        case 1.0: strcopy(buffer, len, "Pristine");
        case 1000.0: strcopy(buffer, len, "Factory New");
        case 8000.0: strcopy(buffer, len, "Minimal Wear");
        case 16000.0: strcopy(buffer, len, "Field-Tested");
        case 30000.0: strcopy(buffer, len, "Well-Worn");
        case 55000.0: strcopy(buffer, len, "Battle-Scarred");
        case 110000.0: strcopy(buffer, len, "Garbage");
    }
}

public void GetWeaponQuality(int client, int iWeaponNum, char[] buffer, int len)
{
    int iWepQuality = g_ArrayStoredWeaponsQuality[client].Get(iWeaponNum);
    switch(iWepQuality)
    {
        case 0: strcopy(buffer, len, "Normal");
        case 1: strcopy(buffer, len, "Genuine");
        case 2: strcopy(buffer, len, "Vintage");
        case 3: strcopy(buffer, len, "Unusual");
        case 5: strcopy(buffer, len, "Community");
        case 6: strcopy(buffer, len, "Valve");
        case 7: strcopy(buffer, len, "Prototype");
        case 8: strcopy(buffer, len, "Customized");
        case 9: strcopy(buffer, len, "StatTrack™");
        case 10: strcopy(buffer, len, "Completed");
        case 12: strcopy(buffer, len, "Souvenir");
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
		//SDKHook(iGloves, SDKHook_SetTransmit, EventSDK_SetTransmit);
	}
}

public bool IsValidWear(float wear)
{
	int found = 0;
	for(int i = 0; i <= 6; i++)
	{
		if(wear == g_fWeaponWearLevel[i])
		{
			found++;
		}
	}
	return (found > 0 ? true : false);
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

public void RemoveForbiddenWeaponFromPlayers(int iKnifeDef)
{
	for(int client = 0; client <= MaxClients; client++)
	{
		if(!IsValidClient(client))
		{
			continue;
		}
		if(g_iStoredKnife[client] != iKnifeDef)
		{
			continue;
		}
		g_iStoredKnife[client] = 0;
		int iWeapon = CSGOItems_FindWeaponByDefIndex(client, iKnifeDef);
		if(IsPlayerAlive(client) && CSGOItems_IsValidWeapon(iWeapon))
		{
			CSGOItems_GiveWeapon(client, "weapon_knife");
		}
	}
}

public bool IsKnifeForbidden(int iDefIndex)
{
	return (iDefIndex == 41 || iDefIndex == 42 || iDefIndex == 59 || iDefIndex == 74 || iDefIndex == 80);
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

stock bool IsMapWeapon(int weapon, bool bRemove = false)
{
	if(g_arMapWeapons == null)
	{
		return false;
	}
	for(int i = 0; i < g_arMapWeapons.Length; i++)
	{
		if(g_arMapWeapons.Get(i) != weapon)
		{
			continue;
		}

		if(bRemove)
		{
			g_arMapWeapons.Erase(i);
		}
		return true;
	}
	return false;
}

public Action Timer_MapWeaponEquipped(Handle timer, DataPack datapack)
{
	ResetPack(datapack);
	int client = ReadPackCell(datapack);
	int weapon = ReadPackCell(datapack);


	if(!IsValidClient(client, true))
	{
		return Plugin_Continue;
	}

	if(!CSGOItems_IsValidWeapon(weapon))
	{
		return Plugin_Continue;
	}

	int iWeaponSlot = CSGOItems_GetWeaponSlotByWeapon(weapon);
	if (iWeaponSlot == CS_SLOT_GRENADE || iWeaponSlot == CS_SLOT_C4)
	{
		return Plugin_Continue;
	}

	CSGOItems_RespawnWeapon(client, weapon);
	UpdateClientWeapon(client, weapon);
	return Plugin_Stop;
}