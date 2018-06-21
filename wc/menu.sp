void BuildMainMenu(int client)
{
  if(IsValidClient(client))
  {
    Menu menu = new Menu(h_mainmenu);
    menu.SetTitle("- ESKO' Tweaker -");
    menu.AddItem("wep", "Weapon paints");
    menu.AddItem("wet", "Weapon tweak", IsPlayerAlive(client)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
    menu.AddItem("glo", "Gloves");
    menu.AddItem("kni", "Knives");
    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
  }
}
void BuildGlovesMenu(int client)
{
  if(IsValidClient(client))
  {
    char szGlovesDisplayName[32];
    char szGlovesNum[12];
    Menu menu = new Menu(h_glovemenu);
    menu.SetTitle("- E - Gloves");
    menu.AddItem("default", "Default", strlen(g_szStoredGloves[client]) == 0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    for(int a = 0; a < iGloveCount; a++)
    {
      if(a != 1 && a != 2)
      {
        IntToString(a, szGlovesNum, sizeof(szGlovesNum));
        CSGOItems_GetGlovesDisplayNameByGlovesNum(a, szGlovesDisplayName, sizeof(szGlovesDisplayName));
        menu.AddItem(szGlovesNum, szGlovesDisplayName);
      }
    }
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
  }
}
void BuildGloveSkinsMenu(int client, int iGloveNum)
{
  if(IsValidClient(client))
  {
    char szItemEx[2][32];
    ExplodeString(g_szStoredGloves[client], ";",szItemEx, sizeof(szItemEx), sizeof(szItemEx[]));
    int iStoredSkinDef = StringToInt(szItemEx[1]);
    char szGlovesDisplayName[32];
    char szSkinDisplayName[32];
    char szMenuKey[32];
    int iGloveDef = CSGOItems_GetGlovesDefIndexByGlovesNum(iGloveNum);
    CSGOItems_GetGlovesDisplayNameByGlovesNum(iGloveNum, szGlovesDisplayName, sizeof(szGlovesDisplayName));
    Menu menu = new Menu(h_gloveskinmenu);
    menu.SetTitle("- E - %s", szGlovesDisplayName);
    for(int a = 0; a < arGloves[iGloveNum].Length; a++)
    {
      int iSkinDef = arGloves[iGloveNum].Get(a);
      Format(szMenuKey, sizeof(szMenuKey), "%i;%i",iGloveDef,iSkinDef);
      CSGOItems_GetSkinDisplayNameByDefIndex(iSkinDef, szSkinDisplayName, sizeof(szSkinDisplayName));
      menu.AddItem(szMenuKey, szSkinDisplayName, iStoredSkinDef == iSkinDef?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    }
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
  }
}
void BuildWeaponTweakMenu(int client)
{
  if(IsValidClient(client, true))
  {
    Menu menu = new Menu(h_weapontweakmenu);
    menu.SetTitle("- E - Weapon Tweak");
    menu.AddItem("quality", "Change quality");
    menu.AddItem("wear", "Change wear");
    menu.AddItem("pattern", "Change pattern");
    menu.AddItem("nametag", "Change nametag");
    menu.AddItem("stattrack", "StatTrak™");
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
  }
}
void BuildWeaponNametagMenu(int client)
{
  if(IsValidClient(client, true))
  {
    char szWeaponDisplayName[32];
    char szNameTag[32];
    int iActiveWeaponNum = CSGOItems_GetActiveWeaponNum(client);
    arStoredWeaponsNametag[client].GetString(iActiveWeaponNum, szNameTag, sizeof(szNameTag));
    CSGOItems_GetWeaponDisplayNameByWeaponNum(iActiveWeaponNum, szWeaponDisplayName, sizeof(szWeaponDisplayName));
    Menu menu = new Menu(h_weaponnametagmenu);
    menu.SetTitle("- E - %s NameTag", szWeaponDisplayName);
    menu.AddItem("remove", "Remove nametag", strlen(szNameTag) > 0?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
    menu.AddItem("add", "Change nametag");
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
    g_bIsChangingNametag[client] = true;
  }
}
void BuildWeaponStatTrackMenu(int client)
{
  if(IsValidClient(client, true))
  {
    char szWeaponDisplayName[32];
    char szBuffer[32];
    int iActiveWeaponNum = CSGOItems_GetActiveWeaponNum(client);
    CSGOItems_GetWeaponDisplayNameByWeaponNum(iActiveWeaponNum, szWeaponDisplayName, sizeof(szWeaponDisplayName));
    bool bStatTrackEnabled = view_as<bool>(arStoredWeaponsStatTrackEnabled[client].Get(iActiveWeaponNum));
    int iKills = arStoredWeaponsStatTrackKills[client].Get(iActiveWeaponNum);
    Menu menu = new Menu(h_weaponstattrackmenu);
    menu.SetTitle("- E - %s StatTrak™", szWeaponDisplayName);
    if(arWeapons[iActiveWeaponNum].Length > 0)
    {
      Format(szBuffer, sizeof(szBuffer), "StatTrak: %s", bStatTrackEnabled?"Enabled":"Disabled");
      menu.AddItem("toggle", szBuffer);
      Format(szBuffer, sizeof(szBuffer), "Kills: %i", iKills);
      menu.AddItem("kills", szBuffer, ITEMDRAW_DISABLED);
    }
    else
    {
      menu.AddItem("nope", "Not available", ITEMDRAW_DISABLED);
    }
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
    g_bIsChangingStatTrack[client] = true;
  }
}
void BuilWeaponPatternMenu(int client)
{
  if(IsValidClient(client, true))
  {
    char szWeaponDisplayName[32];
    int iActiveWeaponNum = CSGOItems_GetActiveWeaponNum(client);
    CSGOItems_GetWeaponDisplayNameByWeaponNum(iActiveWeaponNum, szWeaponDisplayName, sizeof(szWeaponDisplayName));
    int iWepPattern = arStoredWeaponsPattern[client].Get(iActiveWeaponNum);
    int iWepPaint = arStoredWeaponsPaint[client].Get(iActiveWeaponNum);
    Menu menu = new Menu(h_weaponpatternmenu);
    menu.SetTitle("- E - %s pattern [%i]", szWeaponDisplayName, iWepPattern);
    if(CSGOItems_GetWeaponSlotByWeaponNum(iActiveWeaponNum) <= CS_SLOT_KNIFE && iWepPaint > 1)
    {
      menu.AddItem("inc10", "Increase by 10", iWepPattern + 10 <= 2147483647?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
      menu.AddItem("inc100", "Increase by 100", iWepPattern + 100 <= 2147483647?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
      menu.AddItem("default", "Default", iWepPattern != 0?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
      menu.AddItem("dec100", "Decrease by 100", iWepPattern - 100 >= 0?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
      menu.AddItem("dec10", "Decrease by 10", iWepPattern - 10 >= 0?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
      menu.AddItem("enter", "Enter value",g_bIsChangingPatternValue[client]?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    }
    else
    {
      menu.AddItem("none", "You cannot tweak this weapon", ITEMDRAW_DISABLED);
    }
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
    g_bIsChangingPattern[client] = true;
  }
}
stock void BuildWeaponWearMenu(int client, int position = 0)
{
  if(IsValidClient(client, true))
  {
    char szWeaponDisplayName[32];
    int iActiveWeaponNum = CSGOItems_GetActiveWeaponNum(client);
    CSGOItems_GetWeaponDisplayNameByWeaponNum(iActiveWeaponNum, szWeaponDisplayName, sizeof(szWeaponDisplayName));
    float iWepWear = arStoredWeaponsWear[client].Get(iActiveWeaponNum);
    Menu menu = new Menu(h_weaponwearmenu);
    menu.SetTitle("- E - %s wear", szWeaponDisplayName);
    if(CSGOItems_GetWeaponSlotByWeaponNum(iActiveWeaponNum) <= CS_SLOT_KNIFE)
    {
      menu.AddItem("PR", "Pristine", iWepWear == 0.000001?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("FN", "Factory New", iWepWear == 0.01?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("MW", "Minimal Wear", iWepWear == 0.08?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("FT", "Field-Tested", iWepWear == 0.16?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("WW", "Well-Worn", iWepWear == 0.30?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("BS", "Battle-Scarred", iWepWear == 0.55?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("GR", "Garbage", iWepWear == 1.10000?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    }
    else
    {
      menu.AddItem("none", "You cannot tweak this weapon", ITEMDRAW_DISABLED);
    }
    menu.ExitBackButton = true;
    if(position == 0)
    {
      menu.Display(client, MENU_TIME_FOREVER);
    }
    else
    {
      menu.DisplayAt(client, position, MENU_TIME_FOREVER);
    }
    g_bIsChangingWear[client] = true;
  }
}
stock void BuildWeaponQualityMenu(int client, int position = 0)
{
  if(IsValidClient(client, true))
  {
    char szWeaponDisplayName[32];
    int iActiveWeaponNum = CSGOItems_GetActiveWeaponNum(client);
    CSGOItems_GetWeaponDisplayNameByWeaponNum(iActiveWeaponNum, szWeaponDisplayName, sizeof(szWeaponDisplayName));
    int iWepQuality = arStoredWeaponsQuality[client].Get(iActiveWeaponNum);
    Menu menu = new Menu(h_weaponqualitymenu);
    menu.SetTitle("- E - %s quality", szWeaponDisplayName);
    if(CSGOItems_GetWeaponSlotByWeaponNum(iActiveWeaponNum) <= CS_SLOT_KNIFE)
    {
      menu.AddItem("0", "Normal", iWepQuality == 0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("1", "Genuine", iWepQuality == 1?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("2", "Vintage", iWepQuality == 2?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("3", "Unusual", iWepQuality == 3?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("5", "Community", iWepQuality == 5?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("6", "Valve", iWepQuality == 6?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("7", "Prototype", iWepQuality == 7?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("8", "Customized", iWepQuality == 8?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("9", "StatTrack™", iWepQuality == 9?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("10", "Completed", iWepQuality == 10?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      menu.AddItem("12", "Souvenir", iWepQuality == 12?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    }
    else
    {
      menu.AddItem("none", "You cannot tweak this weapon", ITEMDRAW_DISABLED);
    }
    menu.ExitBackButton = true;
    if(position == 0)
    {
      menu.Display(client, MENU_TIME_FOREVER);
    }
    else
    {
      menu.DisplayAt(client, position, MENU_TIME_FOREVER);
    }
    g_bIsChangingQuality[client] = true;
  }
}
stock void ShowAllWeaponsPaints(int client, int wepnum, int position = 0)
{
  if(IsValidClient(client))
  {
    Menu menu = new Menu(h_allweaponspaintsmenu);
    menu.SetTitle("- E - Select paint");
    if(arWeapons[wepnum].Length > 0)
    {
      char szSkinDisplayName[32];
      char szMenuKey[12];
      int iCurrentSkinDef = arStoredWeaponsPaint[client].Get(wepnum);
      for(int a = 0; a < iSkinCount; a++)
      {
        int iSkinDef = CSGOItems_GetSkinDefIndexBySkinNum(a);
        Format(szMenuKey, sizeof(szMenuKey), "%i", iSkinDef);
        CSGOItems_GetSkinDisplayNameByDefIndex(iSkinDef, szSkinDisplayName, sizeof(szSkinDisplayName));
        menu.AddItem(szMenuKey, szSkinDisplayName, iCurrentSkinDef == iSkinDef?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      }
    }
    else
    {
      menu.AddItem("none", "Žádný dostupný skin", ITEMDRAW_DISABLED);
    }
    menu.ExitBackButton = true;
    if(position == 0)
    {
      menu.Display(client, MENU_TIME_FOREVER);
    }
    else
    {
      menu.DisplayAt(client, position, MENU_TIME_FOREVER);
    }
    g_bIsChangingAllSkin[client] = true;
  }
}
void BuildWeaponPaintsMenu(int client)
{
  if(IsValidClient(client))
  {
    Menu menu = new Menu(h_weaponpaintsmenu);
    menu.SetTitle("- E - Select weapon");
    menu.AddItem("all", "All paints", IsPlayerAlive(client)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
    menu.AddItem("cur", "Current weapon", IsPlayerAlive(client)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
    menu.AddItem("pri", "Primary weapons");
    menu.AddItem("sec", "Secondary weapons");
    menu.AddItem("kni", "Knives");
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
  }
}
stock void BuildKnivesMenu(int client, int position = 0)
{
  if(IsValidClient(client))
  {
    char szWeaponDisplayName[32];
    char szWeaponDefIndex[32];
    Menu menu = new Menu(h_knivesmenu);
    menu.SetTitle("- E - Select knife");
    menu.AddItem("weapon_knife", "Knife", g_iStoredKnife[client] == 0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
    for(int a = 0; a < iWeaponCount; a++)
    {
      if(CSGOItems_GetWeaponSlotByWeaponNum(a) == CS_SLOT_KNIFE)
      {
        CSGOItems_GetWeaponDisplayNameByWeaponNum(a, szWeaponDisplayName, sizeof(szWeaponDisplayName));
        int iWepDef = CSGOItems_GetWeaponDefIndexByWeaponNum(a);
        if(iWepDef == 42 || iWepDef == 59 || iWepDef == 41)
        {
          continue;
        }
        IntToString(iWepDef, szWeaponDefIndex, sizeof(szWeaponDefIndex));
        menu.AddItem(szWeaponDefIndex, szWeaponDisplayName, iWepDef == g_iStoredKnife[client]?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      }
    }
    menu.ExitBackButton = true;
    if(position == 0)
    {
      menu.Display(client, MENU_TIME_FOREVER);
    }
    else
    {
      menu.DisplayAt(client, position, MENU_TIME_FOREVER);
    }
  }
}
stock void ShowWeaponNumSkinsMenu(int client, int wepnum, int position = 0)
{
  if(IsValidClient(client))
  {
    Menu menu = new Menu(h_wepnumskins);
    char szWeaponDisplayName[32];
    int iWepDef = CSGOItems_GetWeaponDefIndexByWeaponNum(wepnum);
    CSGOItems_GetWeaponDisplayNameByWeaponNum(wepnum, szWeaponDisplayName, sizeof(szWeaponDisplayName));
    menu.SetTitle("- %s - Paints", szWeaponDisplayName);
    if(arWeapons[wepnum].Length > 0)
    {
      char szSkinDisplayName[32];
      char szMenuKey[12];
      int iCurrentSkinDef = arStoredWeaponsPaint[client].Get(wepnum);
      for(int a = 0; a < arWeapons[wepnum].Length; a++)
      {
        int iSkinDef = arWeapons[wepnum].Get(a);
        Format(szMenuKey, sizeof(szMenuKey), "%i;%i", wepnum, iSkinDef);
        CSGOItems_GetSkinDisplayNameByDefIndex(iSkinDef, szSkinDisplayName, sizeof(szSkinDisplayName));
        menu.AddItem(szMenuKey, szSkinDisplayName, iCurrentSkinDef == iSkinDef?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
      }
    }
    else
    {
      menu.AddItem("none", "Žádný dostupný skin", ITEMDRAW_DISABLED);
    }
    if(CSGOItems_IsDefIndexKnife(iWepDef))
    {
      menu.ExitBackButton = true;
    }
    else
    {
      menu.ExitButton = true;
    }
    if(position == 0)
    {
      menu.Display(client, MENU_TIME_FOREVER);
    }
    else
    {
      menu.DisplayAt(client, position, MENU_TIME_FOREVER);
    }
  }
}
stock void ShowActiveWeaponSkinsMenu(int client, int wepnum, int position = 0)
{
  if(IsValidClient(client, true) && wepnum != -1)
  {
    Menu menu = new Menu(h_activewepskins);
    char szWeaponDisplayName[32];
    CSGOItems_GetWeaponDisplayNameByWeaponNum(wepnum, szWeaponDisplayName, sizeof(szWeaponDisplayName));
    menu.SetTitle("- %s - Paints", szWeaponDisplayName);
    if(arWeapons[wepnum].Length > 0)
    {
      char szSkinDisplayName[32];
      char szSkinDef[12];
      int iCurrentSkinDef = arStoredWeaponsPaint[client].Get(wepnum);
      for(int a = 0; a < arWeapons[wepnum].Length; a++)
      {
        int iSkinDef = arWeapons[wepnum].Get(a);
        IntToString(iSkinDef, szSkinDef, sizeof(szSkinDef));
        CSGOItems_GetSkinDisplayNameByDefIndex(iSkinDef, szSkinDisplayName, sizeof(szSkinDisplayName));
        menu.AddItem(szSkinDef,szSkinDisplayName, iSkinDef != iCurrentSkinDef?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
      }
    }
    else
    {
      menu.AddItem("none", "Žádný dostupný skin", ITEMDRAW_DISABLED);
    }
    menu.ExitBackButton = true;
    if(position == 0)
    {
      menu.Display(client, MENU_TIME_FOREVER);
    }
    else
    {
      menu.DisplayAt(client, position, MENU_TIME_FOREVER);
    }
    g_bIsChangingSkin[client] = true;
  }
}


char someString[] = "abcdefghijklmnopqrstuvwxyz";
stock bool FindLetter(const char[] string, const char character)
{
  bool found = false;
  if(strlen(string) > 0 && strlen(string) > 0)
  {
    int index = 0;
    while(!found && index < sizeof(someString))
    {
      if(string[index] == character)
      {
        found = true;
        break;
      }
      else
      {
        index++;
      }
    }
    return found;
  }
  return found;
}
public void ShowWeaponsBySlotMenu(int client, int slot)
{
  if(IsValidClient(client))
  {
    Menu menu = new Menu(h_slotweapons);
    char szWeaponDisplayName[32];
    int iWepDef;
    char szWepNum[12];
    menu.SetTitle("%s",slot == CS_SLOT_PRIMARY?"- E - Primary weapons":slot == CS_SLOT_SECONDARY?"- E - Secondary weapons":slot == CS_SLOT_KNIFE?"- E - Knives":"");
    for(int a = 0; a < iWeaponCount; a++)
    {
      if(CSGOItems_GetWeaponSlotByWeaponNum(a) == slot)
      {
        CSGOItems_GetWeaponDisplayNameByWeaponNum(a, szWeaponDisplayName, sizeof(szWeaponDisplayName));
        iWepDef = CSGOItems_GetWeaponDefIndexByWeaponNum(a);
        if(iWepDef == 42 || iWepDef == 59)
        {
          continue;
        }
        IntToString(a, szWepNum, sizeof(szWepNum));
        menu.AddItem(szWepNum, szWeaponDisplayName);
      }
    }
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
  }
}
