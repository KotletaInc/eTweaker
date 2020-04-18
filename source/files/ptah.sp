public void SetPlayerModelPost(int client, const char[] szModel)
{
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
}
public Action WeaponCanUsePre(int client, int iEnt, bool& CanUse)
{
    int iDefIndex = eItems_GetWeaponDefIndexByWeapon(iEnt);
    if (eItems_IsDefIndexKnife(iDefIndex))
    {
        CanUse = true;
        return Plugin_Changed;
    }
    return Plugin_Continue;
}
public void GiveNamedItemPost(int client, const char[] classname, const CEconItemView item, int entity, bool OriginIsNULL, const float Origin[3])
{
    if(IsValidClient(client, true) && eItems_IsValidWeapon(entity))
    {
        /*int iDefIndex = eItems_GetWeaponDefIndexByClassName(classname);
        if(eItems_IsDefIndexKnife(iDefIndex))
        {
            EquipPlayerWeapon(client, entity);
        }*/

        int iPrevOwner = GetEntProp(entity, Prop_Send, "m_hPrevOwner");
        if(iPrevOwner == -1)
        {
            UpdateClientWeapon(client, entity);
        }
    }
}
public Action GiveNamedItemPre(int client, char szClassname[64], CEconItemView &Item, bool &IgnoredCEconItemView, bool &OriginIsNULL, float Origin[3])
{
    if(g_iStoredKnife[client] != 0)
    {
        if(IsFakeClient(client))
        {
            return Plugin_Continue;
        }
        int clientTeam = GetClientTeam(client);

        if(clientTeam < CS_TEAM_T)
        {
            return Plugin_Handled;
        }
        
        
        int iDefIndex = eItems_GetWeaponDefIndexByClassName(szClassname);

        if(iDefIndex <= -1)
        {
            return Plugin_Continue;
        }
        
        if(!eItems_IsDefIndexKnife(iDefIndex))
        {
            return Plugin_Continue;
        }

        if(!eItems_IsDefIndexKnife(g_iStoredKnife[client]))
        {
            return Plugin_Continue;
        }



        eItems_GetWeaponClassNameByDefIndex(g_iStoredKnife[client], szClassname, sizeof(szClassname));
        IgnoredCEconItemView = true;

        int iWeapon = CreateEntityByName(szClassname);

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
    return Plugin_Changed;
}
