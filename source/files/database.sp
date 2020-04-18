public void Database_Connect(Database db, const char[] error, any data)
{
	if (db == null)
	{
		LogError("Database failure: %s", error);
	}
	else
	{
		g_hDatabase = db;
		Database_CreateTables();
	}	
}
public void Database_CreateTables()
{
	if(g_hDatabase != null)
	{
		char szBuffer[1024];
		Format(szBuffer, sizeof(szBuffer), "CREATE TABLE IF NOT EXISTS `tweaker_users`(`id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,`name` VARCHAR(255) NOT NULL ,`steamid` VARCHAR(18) NOT NULL ,`created_at` TIMESTAMP NULL ,`updated_at` TIMESTAMP NULL ,PRIMARY KEY (`id`), UNIQUE(`steamid`)) ENGINE = InnoDB;");
		g_hDatabase.Query(Database_CreatedTables, szBuffer);

		Format(szBuffer, sizeof(szBuffer), "CREATE TABLE IF NOT EXISTS `tweaker_user_items`(`fk_user` INT UNSIGNED NOT NULL,`fk_item` INT UNSIGNED NOT NULL,`fk_skin` INT UNSIGNED NULL DEFAULT 0,`nametag` VARCHAR(1024) NOT NULL DEFAULT '',`stattrack` INT UNSIGNED NOT NULL DEFAULT 0,`stattrack_enabled` BOOLEAN NOT NULL DEFAULT FALSE,`wear` FLOAT NOT NULL DEFAULT  1.0,`quality` INT UNSIGNED NOT NULL DEFAULT 0,`pattern` INT UNSIGNED NOT NULL DEFAULT 0,`is_wearable` BOOLEAN NOT NULL DEFAULT FALSE,`is_active` BOOLEAN NOT NULL DEFAULT FALSE, PRIMARY KEY (`fk_user`, `fk_item`),UNIQUE INDEX `UNIQUE1` (`fk_user` ASC, `fk_item` ASC, `fk_skin` ASC)) ENGINE = InnoDB;");
		g_hDatabase.Query(Database_CreatedTables, szBuffer);
	}
}
public void Database_CreatedTables(Database db, DBResultSet results, const char[] error, any data)
{
	if(results == null)
	{
		LogError("[1] Query failed! %s", error);
	}
}
public void Database_OnClientConnect(int client)
{
	if(g_hDatabase != null)
	{
		char szBuffer[1024];
		char szSteamId[64];
		char szClientName[128];
		char szClientNameEscaped[128];
		GetClientName(client, szClientName, sizeof(szClientName));
		g_hDatabase.Escape(szClientName, szClientNameEscaped, sizeof(szClientNameEscaped));
		GetClientAuthId(client, AuthId_SteamID64, szSteamId, sizeof(szSteamId));
		ResetClientData(client);
		Format(szBuffer, sizeof(szBuffer), "INSERT INTO tweaker_users (name, steamid, created_at, updated_at) VALUES ('%s', '%s', NOW(), NOW()) ON DUPLICATE KEY UPDATE name = '%s', updated_at = NOW()", szClientNameEscaped, szSteamId, szClientNameEscaped);
		g_hDatabase.Query(Database_OnClientConnected, szBuffer, GetClientUserId(client));
	}
}
public void Database_OnClientConnected(Database db, DBResultSet results, const char[] error, any data)
{
	if(g_bDataFullySynced)
	{
		int client = GetClientOfUserId(data);
		if(results == null)
		{
			LogError("[2] Query failed! %s", error);
		}
		else
		{
			if(IsValidClient(client))
			{
				char szBuffer[256];
				char szSteamId[64];
				GetClientAuthId(client, AuthId_SteamID64, szSteamId, sizeof(szSteamId));
				Format(szBuffer, sizeof(szBuffer), "SELECT user.id FROM tweaker_users user WHERE user.steamid = '%s'", szSteamId);
				g_hDatabase.Query(Database_OnGetClientUserId, szBuffer, GetClientUserId(client));
			}
		}
	}
}
public void Database_OnGetClientUserId(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientOfUserId(data);
	if(results == null)
	{
		LogError("[3] Query failed! %s", error);
	}
	else
	{
		if(IsValidClient(client))
		{
			if(results.FetchRow())
			{
				char szBuffer[256];
				g_iUserDbId[client] = results.FetchInt(0);
				Format(szBuffer, sizeof(szBuffer), "SELECT COUNT(*) > 0 as wearables FROM tweaker_user_items WHERE fk_user = '%i' AND is_wearable = 1", g_iUserDbId[client]);
				g_hDatabase.Query(Database_HasClientGloves, szBuffer, GetClientUserId(client));
				Database_LoadClientData(client);
			}
		}
	}
}
public void Database_HasClientGloves(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientOfUserId(data);
	if(results == null)
	{
		LogError("[4] Query failed! %s", error);
	}
	else
	{
		if(IsValidClient(client))
		{
			if(results.FetchRow())
			{
				g_bHasGloves[client] = view_as<bool>(results.FetchInt(0));
			}
		}
	}
}
public void Database_LoadClientData(int client)
{
	if(g_hDatabase != null)
	{
		char szBuffer[1024];
		char szSteamId[64];
		GetClientAuthId(client, AuthId_SteamID64, szSteamId, sizeof(szSteamId));
		Format(szBuffer, sizeof(szBuffer), "SELECT items.* FROM tweaker_users user LEFT JOIN tweaker_user_items items ON user.id = items.fk_user WHERE user.steamid = '%s'", szSteamId);
		g_hDatabase.Query(Database_OnClientDataRecived, szBuffer, GetClientUserId(client));
	}
}

public bool IsWeaponForbiddenByCvar(int iWepDef)
{
	return ((!g_cvAllowKnifeBareHands.BoolValue && iWepDef == 69) || (!g_cvAllowKnifeAxe.BoolValue && iWepDef == 75) || (!g_cvAllowKnifeHammer.BoolValue && iWepDef == 76) || (!g_cvAllowKnifeWrench.BoolValue && iWepDef == 78));
}

public void Database_OnClientDataRecived(Database db, DBResultSet results, const char[] error, any data)
{
	int client = GetClientOfUserId(data);
	if(results == null)
	{
		LogError("[6] Query failed! %s", error);
	}
	else
	{
		if(IsValidClient(client))
		{
			int iRowCount = results.RowCount;
			char szNameTag[1024];
			if(iRowCount > 0)
			{
				while(results.FetchRow())
				{
					int iDefIndex = results.FetchInt(1);
					int iSkinDefIndex = results.FetchInt(2);
					bool bWearable = view_as<bool>(results.FetchInt(9));
					bool bActive = view_as<bool>(results.FetchInt(10));
					if(iDefIndex > 0 && !IsWeaponForbiddenByCvar(iDefIndex))
					{
						if(bWearable == true)
						{
							int iSkinNum = eItems_GetSkinNumByDefIndex(iSkinDefIndex);
							if(eItems_IsSkinNumGloveApplicable(iSkinNum))
							{
								Format(g_szStoredGloves[client], sizeof(g_szStoredGloves[]), "%i;%i", iDefIndex, iSkinDefIndex);
							}
						}
						else
						{
							int iWeaponNum = eItems_GetWeaponNumByDefIndex(iDefIndex);
							if(iWeaponNum == -1)
							{
								continue;
							}
							results.FetchString(3, szNameTag, sizeof(szNameTag));
							int iStatTrack = results.FetchInt(4);
							int iStatTrack_Enabled = results.FetchInt(5);
							float fWear = results.FetchFloat(6);
							int iQuality = results.FetchInt(7);
							int iPattern = results.FetchInt(8);
							if(!IsValidWear(fWear))
							{
								fWear = g_fWeaponWearLevel[0];
							}
							g_ArrayStoredWeaponsQuality[client].Set(iWeaponNum, iQuality);
							g_ArrayStoredWeaponsPattern[client].Set(iWeaponNum, iPattern);
							g_ArrayStoredWeaponsNametag[client].SetString(iWeaponNum, szNameTag);
							g_ArrayStoredWeaponsWear[client].Set(iWeaponNum, fWear);
							g_ArrayStoredWeaponsStatTrackEnabled[client].Set(iWeaponNum, iStatTrack_Enabled);
							g_ArrayStoredWeaponsStatTrackKills[client].Set(iWeaponNum, iStatTrack);
							g_ArrayStoredWeaponsPaint[client].Set(iWeaponNum, iSkinDefIndex);
							if(eItems_IsDefIndexKnife(iDefIndex))
							{
								if(bActive == true && !IsKnifeForbidden(iDefIndex))
								{
									g_iStoredKnife[client] = iDefIndex;
								}
							}
						}
					}
				}
			}
		}
	}
}
public void Database_SaveClientData(int client)
{
	if(g_hDatabase != null)
	{
		if(g_ArrayModifiedWeapons[client].Length < 1)
		{
			return;
		}
		char szSteamId[64];
		GetClientAuthId(client, AuthId_SteamID64, szSteamId, sizeof(szSteamId));
		for(int iWeaponNum = 0; iWeaponNum < g_ArrayModifiedWeapons[client].Length; iWeaponNum++)
		{
			if(g_ArrayModifiedWeapons[client].Get(iWeaponNum) > 0)
			{
				int iDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iWeaponNum);
				int iSkinDef = g_ArrayStoredWeaponsPaint[client].Get(iWeaponNum);
				int iQuality = g_ArrayStoredWeaponsQuality[client].Get(iWeaponNum);
				int iPattern = g_ArrayStoredWeaponsPattern[client].Get(iWeaponNum);
				float fWear = g_ArrayStoredWeaponsWear[client].Get(iWeaponNum);
				int iStatTrack = g_ArrayStoredWeaponsStatTrackKills[client].Get(iWeaponNum);
				int iStatTrack_Enabled = g_ArrayStoredWeaponsStatTrackEnabled[client].Get(iWeaponNum);
				char szBuffer[2048];
				char szNameTag[1024];
				char szNameTagEscaped[1024];
				g_ArrayStoredWeaponsNametag[client].GetString(iWeaponNum, szNameTag, sizeof(szNameTag));
				g_hDatabase.Escape(szNameTag, szNameTagEscaped, sizeof(szNameTagEscaped));
				Format(szBuffer, sizeof(szBuffer), "INSERT INTO tweaker_user_items (fk_user, fk_item, fk_skin, nametag, stattrack, stattrack_enabled, wear, quality, pattern, is_wearable, is_active) VALUES ('%i', '%i', '%i', '%s', '%i', '%i', '%f', '%i', '%i', '0', '%i') ON DUPLICATE KEY UPDATE fk_skin = %i, nametag = '%s', stattrack = %i, stattrack_enabled = %i, wear = %f, quality = %i, pattern = %i, is_wearable = false, is_active = %i;", g_iUserDbId[client], iDefIndex, iSkinDef, szNameTagEscaped, iStatTrack, iStatTrack_Enabled, fWear, iQuality, iPattern, eItems_IsDefIndexKnife(iDefIndex)?(g_iStoredKnife[client] == iDefIndex?1:0):0 ,iSkinDef, szNameTagEscaped, iStatTrack ,iStatTrack_Enabled, fWear, iQuality, iPattern, eItems_IsDefIndexKnife(iDefIndex)?(g_iStoredKnife[client] == iDefIndex?1:0):0);
				g_hDatabase.Query(Database_DoNothing, szBuffer, GetClientUserId(client));
			}
		}
		if(g_bChangedGloves[client] == true)
		{
			char szBuffer[256];
			char szItemEx[2][32];
			int iGloveDef = 0;
			int iSkinDef = 0;
			if(ExplodeString(g_szStoredGloves[client], ";",szItemEx, sizeof(szItemEx), sizeof(szItemEx[])) == 2)
			{
				iGloveDef = StringToInt(szItemEx[0]);
				iSkinDef = StringToInt(szItemEx[1]);
			}
			if(strlen(g_szStoredGloves[client]) > 0)
			{
				if(g_bHasGloves[client])
				{
					Format(szBuffer, sizeof(szBuffer), "UPDATE `tweaker_user_items` SET `fk_item`= %i,`fk_skin`= %i WHERE fk_user = '%i' AND is_wearable = 1", iGloveDef, iSkinDef, g_iUserDbId[client]);
					g_hDatabase.Query(Database_DoNothing, szBuffer, GetClientUserId(client));
				}
				else
					{
					Format(szBuffer, sizeof(szBuffer), "INSERT INTO tweaker_user_items (fk_user, fk_item, fk_skin, nametag, stattrack, stattrack_enabled, wear, quality, pattern, is_wearable, is_active) VALUES ('%i', '%i', '%i', '', '0', '0', '0.00001', '0', '0', '1', '0')", g_iUserDbId[client], iGloveDef, iSkinDef);
					g_hDatabase.Query(Database_DoNothing, szBuffer, GetClientUserId(client));
				}
			}
			else
			{
			Format(szBuffer, sizeof(szBuffer), "DELETE FROM `tweaker_user_items` WHERE fk_user = '%i' AND is_wearable = 1", g_iUserDbId[client]);
			g_hDatabase.Query(Database_DoNothing, szBuffer, GetClientUserId(client));
			}
		}
		delete g_ArrayStoredWeaponsPaint[client];
		delete g_ArrayStoredWeaponsQuality[client];
		delete g_ArrayStoredWeaponsWear[client];
		delete g_ArrayStoredWeaponsPattern[client];
		delete g_ArrayModifiedWeapons[client];
		delete g_ArrayStoredWeaponsNametag[client];
		delete g_ArrayStoredWeaponsStatTrackEnabled[client];
		delete g_ArrayStoredWeaponsStatTrackKills[client];
	}
}
public void Database_DoNothing(Database db, DBResultSet results, const char[] error, any data)
{
  if(results == null)
  {
	LogError("[5] Query failed! %s", error);
  }
}