public void BuildMainMenu(int client)
{
    if(IsValidClient(client))
    {
        Menu menu = new Menu(h_mainmenu);
        menu.SetTitle("- E'Tweaker -");
        menu.AddItem("paints", "Weapon paints");
        menu.AddItem("tweak", "Weapon tweak", IsPlayerAlive(client)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
        menu.AddItem("gloves", "Gloves");
        menu.AddItem("knives", "Knives");
        menu.AddItem("info", "Tweaker settings");
        menu.ExitButton = true;
        menu.Display(client, MENU_TIME_FOREVER);
    }
}
public void BuildInformationsMenu(int client)
{
    if(IsValidClient(client))
    {
        char szBuffer[128];
        char szDisplayName[32];
        char szSkinName[32];
        char szGlovesName[32];
        char szSkinDef[12];
        char szKnifePhase[32];
        Menu menu = new Menu(h_informationsmenu);
        menu.SetTitle("- Tweaker settings -");
        GetKnifeDisplayName(g_iStoredKnife[client], szDisplayName, sizeof(szDisplayName));
        Format(szBuffer, sizeof(szBuffer), "Selected Knife: \n%s",szDisplayName);
        if(g_iStoredKnife[client] != 0)
        {
            int iPaintKit = g_ArrayStoredWeaponsPaint[client].Get(CSGOItems_GetWeaponNumByDefIndex(g_iStoredKnife[client]));
            if(iPaintKit > 1)
            {
                CSGOItems_GetSkinDisplayNameByDefIndex(iPaintKit, szSkinName, sizeof(szSkinName));
                IntToString(iPaintKit, szSkinDef, sizeof(szSkinDef));
                if(g_SMPhaseList.GetString(szSkinDef, szKnifePhase, sizeof(szKnifePhase)))
                {
                    ReplaceString(szKnifePhase, sizeof(szKnifePhase), "(", "");
                    ReplaceString(szKnifePhase, sizeof(szKnifePhase), ")", "");
                    Format(szSkinName, sizeof(szSkinName), "%s - %s",szSkinName, szKnifePhase);
                }
                Format(szBuffer, sizeof(szBuffer), "%s (%s)",szBuffer, szSkinName);
            }
        }
        menu.AddItem("", szBuffer, ITEMDRAW_DISABLED);

        if(strlen(g_szStoredGloves[client]) > 0)
		{
			char szItemEx[2][32];
			if(ExplodeString(g_szStoredGloves[client], ";",szItemEx, sizeof(szItemEx), sizeof(szItemEx[])) == 2)
			{
                int iGloveDef = StringToInt(szItemEx[0]);
                int iSkinDef = StringToInt(szItemEx[1]);
                CSGOItems_GetGlovesDisplayNameByDefIndex(iGloveDef, szGlovesName, sizeof(szGlovesName));
                CSGOItems_GetSkinDisplayNameByDefIndex(iSkinDef, szSkinName, sizeof(szSkinName));
                Format(szDisplayName, sizeof(szDisplayName), "%s (%s)", szGlovesName, szSkinName);
			}
		}
        else
        {
            strcopy(szDisplayName, sizeof(szDisplayName), "Default");
        }
        Format(szBuffer, sizeof(szBuffer), "Selected Gloves: \n%s", szDisplayName);
        menu.AddItem("", szBuffer, ITEMDRAW_DISABLED);
        menu.AddItem("current", "Current weapon settings");
        menu.AddItem("primary", "Primary weapon settings");
        menu.AddItem("secondary", "Secondary weapon settings");
        menu.AddItem("knives", "Knives settings");
        menu.ExitBackButton = true;
        menu.Display(client, MENU_TIME_FOREVER); 
    }
}

stock void BuildInformationMenuForWeapon(int client, int iWeapon, bool bCurrent = true)
{
    Menu menu;
    if(bCurrent)
    {
        menu = new Menu(h_informationsmenuforcurrentweapon);
    }
    else
    {
        int iSlot = CSGOItems_GetWeaponSlotByWeaponNum(iWeapon);
        switch(iSlot)
        {
            case CS_SLOT_PRIMARY: menu = new Menu(h_informationsmenuforprimaryweapon);    
            case CS_SLOT_SECONDARY: menu = new Menu(h_informationsmenuforsecondaryweapon);
            case CS_SLOT_KNIFE: menu = new Menu(h_informationsmenuforknife);
        }
    }
    char szTitle[512];
    char szWeaponDisplayName[32];
    char szSkinDisplayName[32];
    char szSkinDef[12];
    char szKnifePhase[16];
    int iDefIndex = CSGOItems_GetWeaponDefIndexByWeaponNum(iWeapon);
    CSGOItems_GetWeaponDisplayNameByDefIndex(iDefIndex, szWeaponDisplayName, sizeof(szWeaponDisplayName));
    Format(szTitle, sizeof(szTitle), "- %s settings -\n \n", szWeaponDisplayName);
    int iWeaponNum = CSGOItems_GetWeaponNumByDefIndex(iDefIndex);
    int iWeaponSkinDef = g_ArrayStoredWeaponsPaint[client].Get(iWeaponNum);
    CSGOItems_GetSkinDisplayNameByDefIndex(iWeaponSkinDef, szSkinDisplayName, sizeof(szSkinDisplayName));
    if(CSGOItems_IsDefIndexKnife(iDefIndex))
    {
        IntToString(iWeaponSkinDef, szSkinDef, sizeof(szSkinDef));
        if(g_SMPhaseList.GetString(szSkinDef, szKnifePhase, sizeof(szKnifePhase)))
        {
            ReplaceString(szKnifePhase, sizeof(szKnifePhase), "(", "");
            ReplaceString(szKnifePhase, sizeof(szKnifePhase), ")", "");
            Format(szSkinDisplayName, sizeof(szSkinDisplayName), "%s - %s",szSkinDisplayName, szKnifePhase);
        }
    }
    Format(szTitle, sizeof(szTitle), "%sSkin: %s\n",szTitle, szSkinDisplayName);
    bool bStatTrackEnabled = view_as<bool>(g_ArrayStoredWeaponsStatTrackEnabled[client].Get(iWeaponNum));
    Format(szTitle, sizeof(szTitle), "%sStatTrak™: %s\n",szTitle, bStatTrackEnabled?"Enabled":"Disabled");
    int iStatTrakKills = g_ArrayStoredWeaponsStatTrackKills[client].Get(iWeaponNum);
    Format(szTitle, sizeof(szTitle), "%sStatTrak™ Kills: %i\n",szTitle, iStatTrakKills);
    char szQuality[12];
    GetWeaponQuality(client, iWeaponNum, szQuality, sizeof(szQuality));
    Format(szTitle, sizeof(szTitle), "%sQuality: %s\n",szTitle, szQuality);
    char szWear[16];
    GetWeaponWear(client, iWeaponNum, szWear, sizeof(szWear));
    Format(szTitle, sizeof(szTitle), "%sWear: %s\n",szTitle, szWear);
    int iPattern = g_ArrayStoredWeaponsPattern[client].Get(iWeaponNum);
    Format(szTitle, sizeof(szTitle), "%sPattern: %i\n \n",szTitle, iPattern);
    menu.SetTitle(szTitle);
    menu.AddItem("back", "Back");
    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public void BuildInformationMenuBySlot(int client, int slot)
{
    if(IsValidClient(client))
    {
        Menu menu = new Menu(h_informationsmenubyslot);
        char szWeaponDisplayName[32];
        int iWepDef;
        char szWepNum[12];
        menu.SetTitle("%s",slot == CS_SLOT_PRIMARY?"- Primary weapons -":slot == CS_SLOT_SECONDARY?"- Secondary weapons -":slot == CS_SLOT_KNIFE?"- Knives -":"");

        for(int iWeapon = 0; iWeapon < g_iWeaponCount; iWeapon++)
        {
            if(CSGOItems_GetWeaponSlotByWeaponNum(iWeapon) == slot)
            {
                CSGOItems_GetWeaponDisplayNameByWeaponNum(iWeapon, szWeaponDisplayName, sizeof(szWeaponDisplayName));
                iWepDef = CSGOItems_GetWeaponDefIndexByWeaponNum(iWeapon);
                if(IsWeaponForbiddenByCvar(iWepDef))
                {
                    continue;
                }
                if(IsKnifeForbidden(iWepDef))
                {
                    continue;
                }
                IntToString(iWeapon, szWepNum, sizeof(szWepNum));
                menu.AddItem(szWepNum, szWeaponDisplayName);
            }
        }
        menu.ExitBackButton = true;
        menu.Display(client, MENU_TIME_FOREVER);
    }
}

public void BuildWeaponPaintsMenu(int client)
{
    if(IsValidClient(client))
    {   
        Menu menu = new Menu(h_weaponpaintsmenu);
        menu.SetTitle("- Select weapon -");

        if(!(g_cvHideDisabledSelections.BoolValue && !g_cvAllowAllPaintsSelection.BoolValue))
        {
            menu.AddItem("all", "All paints", !IsPlayerAlive(client)?ITEMDRAW_DISABLED:(g_cvAllowAllPaintsSelection.BoolValue?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED));
        }
        menu.AddItem("current", "Current weapon", IsPlayerAlive(client)?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
        if(!(g_cvHideDisabledSelections.BoolValue && !g_cvAllowPrimarySkinSelection.BoolValue))
        {
            menu.AddItem("primary", "Primary weapons", g_cvAllowPrimarySkinSelection.BoolValue?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
        }
        if(!(g_cvHideDisabledSelections.BoolValue && !g_cvAllowSecondarySkinSelection.BoolValue))
        {
            menu.AddItem("secondary", "Secondary weapons", g_cvAllowSecondarySkinSelection.BoolValue?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
        }
        if(!(g_cvHideDisabledSelections.BoolValue && !g_cvAllowKnifeSkinSelection.BoolValue))
        {
            menu.AddItem("knives", "Knives", g_cvAllowKnifeSkinSelection.BoolValue?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
        }          
        menu.ExitBackButton = true;
        menu.Display(client, MENU_TIME_FOREVER);
    }
}
stock void ShowActiveWeaponSkinsMenu(int client, int iWeaponNum, int position = 0)
{
    if(IsValidClient(client, true) && iWeaponNum != -1)
    {
        Menu menu = new Menu(h_activewepskins);
        char szWeaponDisplayName[32];
        CSGOItems_GetWeaponDisplayNameByWeaponNum(iWeaponNum, szWeaponDisplayName, sizeof(szWeaponDisplayName));

        menu.SetTitle("- %s - Paints", szWeaponDisplayName);
        if(g_ArrayWeapons[iWeaponNum].Length > 0)
        {
            char szSkinDisplayName[32];
            char szSkinDef[12];
            int iCurrentSkinDef = g_ArrayStoredWeaponsPaint[client].Get(iWeaponNum);
            int iRandomSkin = GetRandomInt(0, g_ArrayWeapons[iWeaponNum].Length -1);
            int iRandomSkinDef = g_ArrayWeapons[iWeaponNum].Get(iRandomSkin);
            char szRandomSkinDef[12];
            char szKnifePhase[32];
            IntToString(iRandomSkinDef, szRandomSkinDef, sizeof(szRandomSkinDef));
            if(!(g_cvHideDisabledSelections.BoolValue && !g_cvAllowCurrentWeaponRandomSkin.BoolValue))
            {
                menu.AddItem(szRandomSkinDef, "Random skin", g_cvAllowCurrentWeaponRandomSkin.BoolValue?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
            }
            for(int iSkin = 0; iSkin < g_ArrayWeapons[iWeaponNum].Length; iSkin++)
            {
                int iSkinDef = g_ArrayWeapons[iWeaponNum].Get(iSkin);
                IntToString(iSkinDef, szSkinDef, sizeof(szSkinDef));
                CSGOItems_GetSkinDisplayNameByDefIndex(iSkinDef, szSkinDisplayName, sizeof(szSkinDisplayName));
                if(g_SMPhaseList.GetString(szSkinDef, szKnifePhase, sizeof(szKnifePhase)))
                {
                    Format(szSkinDisplayName, sizeof(szSkinDisplayName), "%s %s",szSkinDisplayName, szKnifePhase);
                }
                menu.AddItem(szSkinDef,szSkinDisplayName, iSkinDef != iCurrentSkinDef?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
            }
        }
        else
        {
            menu.AddItem("none", "No skin available", ITEMDRAW_DISABLED);
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

stock void ShowAllWeaponsPaints(int client, int iWeaponNum, int position = 0)
{
    if(IsValidClient(client))
    {
        Menu menu = new Menu(h_allweaponspaintsmenu);
        menu.SetTitle("- Select paint -");
        if(g_ArrayWeapons[iWeaponNum].Length > 0)
        {
            char szSkinDisplayName[32];
            char szMenuKey[12];
            int iCurrentSkinDef = g_ArrayStoredWeaponsPaint[client].Get(iWeaponNum);
            int iRandomSkin = GetRandomInt(0, g_iSkinCount - 1);
            int iRandomSkinDef = CSGOItems_GetSkinDefIndexBySkinNum(iRandomSkin);
            char szRandomSkinDef[12];
            char szSkinDef[12];
            char szKnifePhase[32];
            IntToString(iRandomSkinDef, szRandomSkinDef, sizeof(szRandomSkinDef));
            if(!(g_cvHideDisabledSelections.BoolValue && !g_cvAllowAllSkinsRandomSkin.BoolValue))
            {
                menu.AddItem(szRandomSkinDef, "Random skin", g_cvAllowAllSkinsRandomSkin.BoolValue?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
            }
            
            for(int iSkin = 0; iSkin < g_iSkinCount; iSkin++)
            {
                int iSkinDef = CSGOItems_GetSkinDefIndexBySkinNum(iSkin);
                IntToString(iSkinDef, szSkinDef, sizeof(szSkinDef));
                CSGOItems_GetSkinDisplayNameByDefIndex(iSkinDef, szSkinDisplayName, sizeof(szSkinDisplayName));
                if(g_SMPhaseList.GetString(szSkinDef, szKnifePhase, sizeof(szKnifePhase)))
                {
                    Format(szSkinDisplayName, sizeof(szSkinDisplayName), "%s %s",szSkinDisplayName, szKnifePhase);
                }
                menu.AddItem(szMenuKey, szSkinDisplayName, iCurrentSkinDef == iSkinDef?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
            }
        }
        else
        {
            menu.AddItem("none", "No skin available", ITEMDRAW_DISABLED);
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
public void ShowWeaponsBySlotMenu(int client, int slot)
{
    if(IsValidClient(client))
    {
        Menu menu = new Menu(h_slotweapons);
        char szWeaponDisplayName[32];
        int iWepDef;
        char szWepNum[12];
        menu.SetTitle("%s",slot == CS_SLOT_PRIMARY?"- Primary weapons -":slot == CS_SLOT_SECONDARY?"- Secondary weapons -":slot == CS_SLOT_KNIFE?"- Knives -":"");

        for(int iWeapon = 0; iWeapon < g_iWeaponCount; iWeapon++)
        {
            if(CSGOItems_GetWeaponSlotByWeaponNum(iWeapon) == slot)
            {
                CSGOItems_GetWeaponDisplayNameByWeaponNum(iWeapon, szWeaponDisplayName, sizeof(szWeaponDisplayName));
                iWepDef = CSGOItems_GetWeaponDefIndexByWeaponNum(iWeapon);
                if(IsWeaponForbiddenByCvar(iWepDef))
                {
                    continue;
                }
                if(IsKnifeForbidden(iWepDef))
                {
                    continue;
                }
                IntToString(iWeapon, szWepNum, sizeof(szWepNum));
                menu.AddItem(szWepNum, szWeaponDisplayName);
            }
        }
        menu.ExitBackButton = true;
        menu.Display(client, MENU_TIME_FOREVER);
    }
}
stock void ShowWeaponNumSkinsMenu(int client, int iWeaponNum, int position = 0)
{
    if(IsValidClient(client))
    {
        Menu menu = new Menu(h_wepnumskins);
        char szWeaponDisplayName[32];
        int iWepDef = CSGOItems_GetWeaponDefIndexByWeaponNum(iWeaponNum);
        CSGOItems_GetWeaponDisplayNameByWeaponNum(iWeaponNum, szWeaponDisplayName, sizeof(szWeaponDisplayName));
        menu.SetTitle("- %s - Paints", szWeaponDisplayName);
        if(g_ArrayWeapons[iWeaponNum].Length > 0)
        {
            char szSkinDisplayName[32];
            char szMenuKey[12];
            int iCurrentSkinDef = g_ArrayStoredWeaponsPaint[client].Get(iWeaponNum);
            int iRandomSkin = GetRandomInt(0, g_ArrayWeapons[iWeaponNum].Length -1);
            int iRandomSkinDef = g_ArrayWeapons[iWeaponNum].Get(iRandomSkin);
            char szRandomSkinDef[12];
            char szSkinDef[12];
            char szKnifePhase[32];
            IntToString(iRandomSkinDef, szRandomSkinDef, sizeof(szRandomSkinDef));
            Format(szMenuKey, sizeof(szMenuKey), "%i;%i", iWeaponNum, iRandomSkinDef);
            if(!(g_cvHideDisabledSelections.BoolValue && !g_cvAllowWeaponRandomSkin.BoolValue))
            {
                menu.AddItem(szMenuKey, "Random skin", g_cvAllowWeaponRandomSkin.BoolValue?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
            }
            for(int iSkin = 0; iSkin < g_ArrayWeapons[iWeaponNum].Length; iSkin++)
            {
            int iSkinDef = g_ArrayWeapons[iWeaponNum].Get(iSkin);
            Format(szMenuKey, sizeof(szMenuKey), "%i;%i", iWeaponNum, iSkinDef);
            CSGOItems_GetSkinDisplayNameByDefIndex(iSkinDef, szSkinDisplayName, sizeof(szSkinDisplayName));
            IntToString(iSkinDef, szSkinDef, sizeof(szSkinDef));
            if(g_SMPhaseList.GetString(szSkinDef, szKnifePhase, sizeof(szKnifePhase)))
            {
                Format(szSkinDisplayName, sizeof(szSkinDisplayName), "%s %s",szSkinDisplayName, szKnifePhase);
            }
            menu.AddItem(szMenuKey, szSkinDisplayName, iCurrentSkinDef == iSkinDef?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
            }
        }
        else
        {
            menu.AddItem("none", "No skin available", ITEMDRAW_DISABLED);
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
public void BuildWeaponTweakMenu(int client)
{
    if(IsValidClient(client, true))
    {
        Menu menu = new Menu(h_weapontweakmenu);
        menu.SetTitle("- Weapon Tweak-");
        menu.AddItem("quality", "Change quality");
        menu.AddItem("wear", "Change wear");
        menu.AddItem("pattern", "Change pattern");
        if(!(g_cvHideDisabledSelections.BoolValue && !g_cvAllowNametags.BoolValue))
        {
            menu.AddItem("nametag", "Change nametag", g_cvAllowNametags.BoolValue?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
        }
        menu.AddItem("stattrack", "StatTrak™");
        menu.ExitBackButton = true;
        menu.Display(client, MENU_TIME_FOREVER);
    }
}
stock void BuildWeaponQualityMenu(int client, int position = 0)
{
    if(IsValidClient(client, true))
    {
        char szWeaponDisplayName[32];
        int iActiveWeaponNum = CSGOItems_GetActiveWeaponNum(client);
        CSGOItems_GetWeaponDisplayNameByWeaponNum(iActiveWeaponNum, szWeaponDisplayName, sizeof(szWeaponDisplayName));
        int iWepQuality = g_ArrayStoredWeaponsQuality[client].Get(iActiveWeaponNum);
        Menu menu = new Menu(h_weaponqualitymenu);
        menu.SetTitle("- %s quality -", szWeaponDisplayName);
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
stock void BuildWeaponWearMenu(int client, int position = 0)
{
    if(IsValidClient(client, true))
    {
        char szWeaponDisplayName[32];
        int iActiveWeaponNum = CSGOItems_GetActiveWeaponNum(client);
        CSGOItems_GetWeaponDisplayNameByWeaponNum(iActiveWeaponNum, szWeaponDisplayName, sizeof(szWeaponDisplayName));
        float iWepWear = g_ArrayStoredWeaponsWear[client].Get(iActiveWeaponNum);
        Menu menu = new Menu(h_weaponwearmenu);
        menu.SetTitle("- %s wear -", szWeaponDisplayName);
        if(CSGOItems_GetWeaponSlotByWeaponNum(iActiveWeaponNum) <= CS_SLOT_KNIFE)
        {
            menu.AddItem("PR", "Pristine", iWepWear == 1.0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
            menu.AddItem("FN", "Factory New", iWepWear == 1000.0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
            menu.AddItem("MW", "Minimal Wear", iWepWear == 8000.0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
            menu.AddItem("FT", "Field-Tested", iWepWear == 16000.0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
            menu.AddItem("WW", "Well-Worn", iWepWear == 30000.0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
            menu.AddItem("BS", "Battle-Scarred", iWepWear == 55000.0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
            menu.AddItem("GR", "Garbage", iWepWear == 110000.0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
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
public void BuilWeaponPatternMenu(int client)
{
    if(IsValidClient(client, true))
    {
        char szWeaponDisplayName[32];
        int iActiveWeaponNum = CSGOItems_GetActiveWeaponNum(client);
        CSGOItems_GetWeaponDisplayNameByWeaponNum(iActiveWeaponNum, szWeaponDisplayName, sizeof(szWeaponDisplayName));
        int iWepPattern = g_ArrayStoredWeaponsPattern[client].Get(iActiveWeaponNum);
        int iWepPaint = g_ArrayStoredWeaponsPaint[client].Get(iActiveWeaponNum);
        Menu menu = new Menu(h_weaponpatternmenu);
        menu.SetTitle("- %s pattern [%i] -", szWeaponDisplayName, iWepPattern);
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
public void BuildWeaponNametagMenu(int client)
{
    if(IsValidClient(client, true))
    {
        char szWeaponDisplayName[32];
        char szNameTag[32];
        int iActiveWeaponNum = CSGOItems_GetActiveWeaponNum(client);
        g_ArrayStoredWeaponsNametag[client].GetString(iActiveWeaponNum, szNameTag, sizeof(szNameTag));
        CSGOItems_GetWeaponDisplayNameByWeaponNum(iActiveWeaponNum, szWeaponDisplayName, sizeof(szWeaponDisplayName));
        Menu menu = new Menu(h_weaponnametagmenu);
        menu.SetTitle("- %s NameTag -", szWeaponDisplayName);
        menu.AddItem("remove", "Remove nametag", strlen(szNameTag) > 0?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
        menu.AddItem("add", "Change nametag");
        menu.ExitBackButton = true;
        menu.Display(client, MENU_TIME_FOREVER);
        g_bIsChangingNametag[client] = true;
    }
}
public void BuildWeaponStatTrackMenu(int client)
{
    if(IsValidClient(client, true))
    {
        char szWeaponDisplayName[32];
        char szBuffer[32];
        int iActiveWeaponNum = CSGOItems_GetActiveWeaponNum(client);
        CSGOItems_GetWeaponDisplayNameByWeaponNum(iActiveWeaponNum, szWeaponDisplayName, sizeof(szWeaponDisplayName));
        bool bStatTrackEnabled = view_as<bool>(g_ArrayStoredWeaponsStatTrackEnabled[client].Get(iActiveWeaponNum));
        int iKills = g_ArrayStoredWeaponsStatTrackKills[client].Get(iActiveWeaponNum);
        Menu menu = new Menu(h_weaponstattrackmenu);
        menu.SetTitle("- %s StatTrak™ -", szWeaponDisplayName);
        if(g_ArrayWeapons[iActiveWeaponNum].Length > 0)
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
stock void BuildKnivesMenu(int client, int position = 0)
{
    if(IsValidClient(client))
    {
        char szWeaponDisplayName[32];
        char szWeaponDefIndex[32];
        Menu menu = new Menu(h_knivesmenu);
        menu.SetTitle("- Select knife -");
        menu.AddItem("weapon_knife", "Knife", g_iStoredKnife[client] == 0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        menu.AddItem("42", "CT Knife", g_iStoredKnife[client] == 42?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        menu.AddItem("59", "T Knife", g_iStoredKnife[client] == 59?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        menu.AddItem("41", "Golden Knife", g_iStoredKnife[client] == 41?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        for(int iWeapon = 0; iWeapon < g_iWeaponCount; iWeapon++)
        {
            if(CSGOItems_GetWeaponSlotByWeaponNum(iWeapon) == CS_SLOT_KNIFE)
            {
                CSGOItems_GetWeaponDisplayNameByWeaponNum(iWeapon, szWeaponDisplayName, sizeof(szWeaponDisplayName));
                int iWepDef = CSGOItems_GetWeaponDefIndexByWeaponNum(iWeapon);
                if(IsWeaponForbiddenByCvar(iWepDef))
                {
                    continue;
                }
                if(IsKnifeForbidden(iWepDef))
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
public void BuildGlovesMenu(int client)
{
    if(IsValidClient(client))
    {
        char szGlovesDisplayName[32];
        char szGlovesNum[12];
        Menu menu = new Menu(h_glovemenu);
        menu.SetTitle("- Gloves -");
        menu.AddItem("default", "Default", strlen(g_szStoredGloves[client]) == 0?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        if(!(g_cvHideDisabledSelections.BoolValue && !g_cvAllowGlovesRandomSkin.BoolValue))
        {
            menu.AddItem("random", "Random gloves", g_cvAllowGlovesRandomSkin.BoolValue?ITEMDRAW_DEFAULT:ITEMDRAW_DISABLED);
        }
        
        for(int iGlove = 0; iGlove < g_iGloveCount; iGlove++)
        {
            if(iGlove != 1 && iGlove != 2)
            {
                IntToString(iGlove, szGlovesNum, sizeof(szGlovesNum));
                CSGOItems_GetGlovesDisplayNameByGlovesNum(iGlove, szGlovesDisplayName, sizeof(szGlovesDisplayName));
                menu.AddItem(szGlovesNum, szGlovesDisplayName);
            }
        }
        menu.ExitBackButton = true;
        menu.Display(client, MENU_TIME_FOREVER);
    }
}
public void BuildGloveSkinsMenu(int client, int iGloveNum)
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
        menu.SetTitle("- %s -", szGlovesDisplayName);
        for(int iSkin = 0; iSkin < g_ArrayGloves[iGloveNum].Length; iSkin++)
        {
            int iSkinDef = g_ArrayGloves[iGloveNum].Get(iSkin);
            Format(szMenuKey, sizeof(szMenuKey), "%i;%i",iGloveDef,iSkinDef);
            CSGOItems_GetSkinDisplayNameByDefIndex(iSkinDef, szSkinDisplayName, sizeof(szSkinDisplayName));
            menu.AddItem(szMenuKey, szSkinDisplayName, iStoredSkinDef == iSkinDef?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
        }
        menu.ExitBackButton = true;
        menu.Display(client, MENU_TIME_FOREVER);
    }
}