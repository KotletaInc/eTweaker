
public bool WeaponCanUse(int iClient, int iEnt, bool CanUse)
{
	int iDefIndex = CSGOItems_GetWeaponDefIndexByWeapon(iEnt);
	if (CSGOItems_IsDefIndexKnife(iDefIndex))
	{
		return true;
	}
	return CanUse;
}
public Action GiveNamedItemPre(int client, char szClassname[64], CEconItemView &Item, bool &IgnoredCEconItemView)
{
	if(g_bKnifeEnabled)
	{
		if(g_iStoredKnife[client] != 0)
		{
			IgnoredCEconItemView = false;
			if(IsFakeClient(client))
			{
				return Plugin_Continue;
			}
			int clientTeam = GetClientTeam(client);

			if(clientTeam < CS_TEAM_T)
			{
				return Plugin_Handled;
			}

			int iDefIndex = CSGOItems_GetWeaponDefIndexByClassName(szClassname);

			if(iDefIndex <= -1)
			{
				return Plugin_Continue;
			}
			if(!CSGOItems_IsDefIndexKnife(iDefIndex))
			{
				return Plugin_Continue;
			}

			if(!CSGOItems_IsDefIndexKnife(g_iStoredKnife[client]))
			{
				return Plugin_Continue;
			}
			float fOrigin[3]; GetClientAbsOrigin(client, fOrigin);
			float fAngles[3]; GetClientAbsAngles(client, fAngles);

			CSGOItems_GetWeaponClassNameByDefIndex(g_iStoredKnife[client], szClassname, sizeof(szClassname));

			int iWeapon = CreateEntityByName(szClassname);
			//int iWeapon = PTaH_SpawnItemFromDefIndex(g_iStoredKnife[client], fOrigin, fAngles);

			if (!IsValidEntity(iWeapon))
			{
				return Plugin_Changed;
			}
			SetEntProp(iWeapon, Prop_Send, "m_iItemIDLow", -1);
			SetEntProp(iWeapon, Prop_Send, "m_iAccountID", GetSteamAccountID(client));
			SetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex", g_iStoredKnife[client]);
			SetEntProp(iWeapon, Prop_Send, "m_bInitialized", 1);

			Item = PTaH_GetEconItemViewFromWeapon(iWeapon);
			AcceptEntityInput(iWeapon, "Kill");
		}
	}
	return Plugin_Changed;
}
