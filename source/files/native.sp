public int Native_GiveClientKnife(Handle hPlugin, int iNumParams)
{
    int client = GetNativeCell(1);
    if(IsValidClient(client, true))
    {
        if(g_iStoredKnife[client] == 0)
        {
            CSGOItems_GiveWeapon(client, "weapon_knife");
        }
        else
        {
            char szClassname[64];
            CSGOItems_GetWeaponClassNameByDefIndex(g_iStoredKnife[client], szClassname, sizeof(szClassname));
            CSGOItems_GiveWeapon(client, szClassname);
        }
        return 1;
    }
    return -1;
}
