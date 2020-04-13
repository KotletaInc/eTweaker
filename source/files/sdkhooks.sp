public Action SDK_OnWeaponEquip(int client, int weapon)
{
    if(!IsValidClient(client, true))
    {
        return Plugin_Continue;
    }

    if(!CSGOItems_IsValidWeapon(weapon))
    {
        return Plugin_Continue;
    }

    int iPrevOwner = GetEntProp(weapon, Prop_Send, "m_hPrevOwner");
    if(iPrevOwner > 0)
    {
        return Plugin_Continue;
    }

    if(IsMapWeapon(weapon, true))
    {
        DataPack datapack = new DataPack();
        datapack.WriteCell(client);
        datapack.WriteCell(weapon);

        CreateTimer(0.1, Timer_MapWeaponEquipped, datapack);
    }
    return Plugin_Continue;
}
public void SDK_OnWeaponSwitchPost(int client, int weapon)
{
    if(IsValidClient(client, true) && IsValidEntity(weapon))
    {
        int iWeaponNum = CSGOItems_GetWeaponNumByWeapon(weapon);
        if(iWeaponNum == -1)
        {
            return;
        }
        if(g_bIsChangingSkin[client])
        {
            if(-1 < iWeaponNum <= CSGOItems_GetWeaponCount())
            {
                ShowActiveWeaponSkinsMenu(client, iWeaponNum);
            }
        }
        else if(g_bIsChangingAllSkin[client])
        {
            ShowAllWeaponsPaints(client, iWeaponNum);
        }
        else if(g_bIsLookingAtCurrentSettings[client])
        {
            BuildInformationMenuForWeapon(client, iWeaponNum);
            g_bIsLookingAtCurrentSettings[client] = true;
        }
        else if(g_bIsChangingQuality[client])
        {
            BuildWeaponQualityMenu(client);
        }
        else if(g_bIsChangingWear[client])
        {
            BuildWeaponWearMenu(client);
        }
        else if(g_bIsChangingPattern[client])
        {
            BuilWeaponPatternMenu(client);
        }
        else if(g_bIsChangingStatTrack[client])
        {
            BuildWeaponStatTrackMenu(client);
        }
        else if(g_bIsChangingNametag[client])
        {
            BuildWeaponNametagMenu(client);
        }
        if(g_iPrevWeapon[client] != INVALID_ENT_REFERENCE)
        {
            int iPrevWeapon = EntRefToEntIndex(g_iPrevWeapon[client]);
            if(CSGOItems_IsValidWeapon(iPrevWeapon))
            {
                int iPrevWeaponNum = CSGOItems_GetWeaponNumByWeapon(iPrevWeapon);
                bool bStatTrackEnabled = view_as<bool>(g_ArrayStoredWeaponsStatTrackEnabled[client].Get(iPrevWeaponNum));
                if(bStatTrackEnabled)
                {
                    int iHasPrevWeapon = CSGOItems_FindWeaponByWeaponNum(client, iPrevWeaponNum);
                    int iCurrentStatTrackKills = GetEntProp(iPrevWeapon, Prop_Send, "m_nFallbackStatTrak");
                    int iPendingStatTrackKills = g_ArrayStoredWeaponsStatTrackKills[client].Get(iPrevWeaponNum);
                    if(iPrevWeapon == iHasPrevWeapon && iCurrentStatTrackKills != iPendingStatTrackKills)
                    {
                        CSGOItems_RespawnWeapon(client, iPrevWeapon);
                    }
                }
            }
        }
        g_iPrevWeapon[client] = EntIndexToEntRef(weapon);
    }
}