public Action Command_WeaponCosmetic(int client, int args)
{
  if(IsValidClient(client))
  {
    BuildMainMenu(client);
  }
  return Plugin_Handled;
}
public Action Command_NameTag(int client, int args)
{
  if(IsValidClient(client))
  {
    BuildWeaponNametagMenu(client);
  }
  return Plugin_Handled;
}
public Action Command_StatTrak(int client, int args)
{
  if(IsValidClient(client))
  {
    BuildWeaponStatTrackMenu(client);
  }
  return Plugin_Handled;
}
public Action Command_Knife(int client, int args)
{
  if(IsValidClient(client))
  {
    BuildKnivesMenu(client);
  }
  return Plugin_Handled;
}
public Action Command_Gloves(int client, int args)
{
  if(IsValidClient(client))
  {
    BuildGlovesMenu(client);
  }
  return Plugin_Handled;
}
public Action Command_Debug(int client, int args)
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
      LogMessage("    - DefIndex: %i | Name: %s", iSkinDef, szSkinDisplayName);
    }
  }
  return Plugin_Handled;
}
