public Action SDK_OnWeaponEquip(int client, int weapon)
{
    if(IsValidClient(client, true) && CSGOItems_IsValidWeapon(weapon))
    {
        int iPrevOwner = GetEntProp(weapon, Prop_Send, "m_hPrevOwner");
        if(iPrevOwner > 0)
        {
            return Plugin_Continue;
        }
        UpdateClientWeapon(client, weapon);
    }
    return Plugin_Continue;
}
public void SDK_OnWeaponSwitchPost(int client, int weapon)
{
    if(IsValidClient(client, true) && IsValidEntity(weapon))
    {
        int iWeaponNum = CSGOItems_GetWeaponNumByWeapon(weapon);
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