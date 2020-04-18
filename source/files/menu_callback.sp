public int h_mainmenu(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client))
    {
        if(action == MenuAction_Select)
        {
            char szMenuItem[12];
            menu.GetItem(index, szMenuItem, sizeof(szMenuItem));
            if(StrEqual(szMenuItem, "paints", false))
            {
                BuildWeaponPaintsMenu(client);
            }
            else if(StrEqual(szMenuItem, "tweak"))
            {
                if(IsPlayerAlive(client))
                {
                    BuildWeaponTweakMenu(client);
                }
                else
                {
                    PrintToChat(client, "[Weapon Tweak] You have to be alive!");
                    BuildMainMenu(client);
                }
            }
            else if(StrEqual(szMenuItem, "gloves", false))
            {
                BuildGlovesMenu(client);
            }
            else if(StrEqual(szMenuItem, "knives", false))
            {
                BuildKnivesMenu(client);
            }
            else if(StrEqual(szMenuItem, "info", false))
            {
                BuildInformationsMenu(client);
            }
        }
        if(action == MenuAction_End)
        {
            delete menu;
        }
    }
}

public int h_informationsmenubyslot(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client))
    {
        if(action == MenuAction_Select)
        {
            char szMenuItem[12];
            menu.GetItem(index, szMenuItem, sizeof(szMenuItem));
            int iWeaponNum = StringToInt(szMenuItem);
            BuildInformationMenuForWeapon(client, iWeaponNum, false);
        }
        if(action == MenuAction_End)
        {
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            if(index == MenuCancel_ExitBack)
            {
                BuildInformationsMenu(client);
            }
        }

    }
}

public int h_informationsmenuforcurrentweapon(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client))
    {
        if(action == MenuAction_Select)
        {
            char szMenuItem[12];
            menu.GetItem(index, szMenuItem, sizeof(szMenuItem));
            if(StrEqual(szMenuItem, "back", false))
            {
                g_bIsLookingAtCurrentSettings[client] = false;
                BuildInformationsMenu(client);
            }
        }
        if(action == MenuAction_End)
        {
            g_bIsLookingAtCurrentSettings[client] = false;
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            g_bIsLookingAtCurrentSettings[client] = false;
        }
    }
}

public int h_informationsmenuforprimaryweapon(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client))
    {
        if(action == MenuAction_Select)
        {
            char szMenuItem[12];
            menu.GetItem(index, szMenuItem, sizeof(szMenuItem));
            if(StrEqual(szMenuItem, "back", false))
            {
                BuildInformationMenuBySlot(client, CS_SLOT_PRIMARY);
            }
        }
        if(action == MenuAction_End)
        {
            delete menu;
        }
    }
}

public int h_informationsmenuforsecondaryweapon(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client))
    {
        if(action == MenuAction_Select)
        {
            char szMenuItem[12];
            menu.GetItem(index, szMenuItem, sizeof(szMenuItem));
            if(StrEqual(szMenuItem, "back", false))
            {
                BuildInformationMenuBySlot(client, CS_SLOT_SECONDARY);
            }
        }
        if(action == MenuAction_End)
        {
            delete menu;
        }
    }
}

public int h_informationsmenuforknife(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client))
    {
        if(action == MenuAction_Select)
        {
            char szMenuItem[12];
            menu.GetItem(index, szMenuItem, sizeof(szMenuItem));
            if(StrEqual(szMenuItem, "back", false))
            {
                BuildInformationMenuBySlot(client, CS_SLOT_KNIFE);
            }
        }
        if(action == MenuAction_End)
        {
            delete menu;
        }
    }
}

public int h_informationsmenu(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client))
    {
        if(action == MenuAction_Select)
        {
            char szMenuItem[12];
            menu.GetItem(index, szMenuItem, sizeof(szMenuItem));
            if(StrEqual(szMenuItem, "current", false))
            {
                g_bIsLookingAtCurrentSettings[client] = true;
                BuildInformationMenuForWeapon(client, eItems_GetActiveWeaponNum(client));
            }
            else if(StrEqual(szMenuItem, "primary", false))
            {
                BuildInformationMenuBySlot(client, CS_SLOT_PRIMARY);
            }
            else if(StrEqual(szMenuItem, "secondary", false))
            {
                BuildInformationMenuBySlot(client, CS_SLOT_SECONDARY);
            }
            else if(StrEqual(szMenuItem, "knives", false))
            {
                BuildInformationMenuBySlot(client, CS_SLOT_KNIFE);
            }
        }
        if(action == MenuAction_End)
        {
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            if(index == MenuCancel_ExitBack)
            {
                BuildMainMenu(client);
            }
        }
    }
}

public int h_weaponpaintsmenu(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client))
    {
        if(action == MenuAction_Select)
        {
            char szMenuItem[12];
            menu.GetItem(index, szMenuItem, sizeof(szMenuItem));
            int iActiveWeaponNum = eItems_GetActiveWeaponNum(client);
            if(StrEqual(szMenuItem, "current", false))
            {
                if(-1 < iActiveWeaponNum <= g_iWeaponCount)
                {
                    ShowActiveWeaponSkinsMenu(client, iActiveWeaponNum);
                }
            }
            else if(StrEqual(szMenuItem, "primary", false))
            {
                ShowWeaponsBySlotMenu(client, CS_SLOT_PRIMARY);
            }
            else if(StrEqual(szMenuItem, "secondary", false))
            {
                ShowWeaponsBySlotMenu(client, CS_SLOT_SECONDARY);
            }
            else if(StrEqual(szMenuItem, "knives", false))
            {
                ShowWeaponsBySlotMenu(client, CS_SLOT_KNIFE);
            }
            else if(StrEqual(szMenuItem, "all", false))
            {
                if(-1 < iActiveWeaponNum <= g_iWeaponCount)
                {

                    ShowAllWeaponsPaints(client, iActiveWeaponNum);
                }
            }
        }
        if(action == MenuAction_End)
        {
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            if(index == MenuCancel_ExitBack)
            {
                BuildMainMenu(client);
            }
        }
    }
}
public int h_activewepskins(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client, true))
    {
        if(action == MenuAction_Select)
        {
            if(IsPlayerAlive(client) == true)
            {
                if(g_bIsRoundEnd == false)
                {
                    char szSkinDef[12];
                    menu.GetItem(index, szSkinDef, sizeof(szSkinDef));
                    int iSkinDef = StringToInt(szSkinDef);
                    int iActiveWeapon = eItems_GetActiveWeapon(client);
                    int iActiveWeaponNum = eItems_GetActiveWeaponNum(client);

                    g_ArrayStoredWeaponsPaint[client].Set(iActiveWeaponNum, iSkinDef);
                    g_ArrayModifiedWeapons[client].Set(iActiveWeaponNum, 1);
                    eItems_RespawnWeapon(client, iActiveWeapon);
                    ShowActiveWeaponSkinsMenu(client, iActiveWeaponNum , GetMenuSelectionPosition());
                }
                else
                {
                    PrintToChat(client, "[E' Tweaker] You can not tweak weapon after round end!");
                }
            }
            else
            {
                g_bIsChangingSkin[client] = false;
            }
        }
        if(action == MenuAction_End)
        {
            g_bIsChangingSkin[client] = false;
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            if(index == MenuCancel_ExitBack)
            {
                BuildWeaponPaintsMenu(client);
            }
            g_bIsChangingSkin[client] = false;
        }
    }
}
public int h_allweaponspaintsmenu(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client, true))
    {
        if(action == MenuAction_Select)
        {
            if(IsPlayerAlive(client) == true)
            {
                if(g_bIsRoundEnd == false)
                {
                    char szSkinDef[12];
                    menu.GetItem(index, szSkinDef, sizeof(szSkinDef));
                    int iSkinDef = StringToInt(szSkinDef);
                    int iActiveWeapon = eItems_GetActiveWeapon(client);
                    int iActiveWeaponNum = eItems_GetActiveWeaponNum(client);
                    g_ArrayStoredWeaponsPaint[client].Set(iActiveWeaponNum, iSkinDef);
                    g_ArrayModifiedWeapons[client].Set(iActiveWeaponNum, 1);
                    eItems_RespawnWeapon(client, iActiveWeapon);
                    ShowAllWeaponsPaints(client, iActiveWeaponNum , GetMenuSelectionPosition());
                }
                else
                {
                    PrintToChat(client, "[E' Tweaker] You can not tweak weapon after round end!");
                }
            }
            else
            {
                g_bIsChangingAllSkin[client] = false;
            }
        }
        if(action == MenuAction_End)
        {
            g_bIsChangingAllSkin[client] = false;
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            if(index == MenuCancel_ExitBack)
            {
                BuildWeaponPaintsMenu(client);
            }
            g_bIsChangingAllSkin[client] = false;
        }
    }
}
public int h_slotweapons(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client))
    {
        if(action == MenuAction_Select)
        {
            char szWepNum[12];
            menu.GetItem(index, szWepNum, sizeof(szWepNum));
            int iWepNum = StringToInt(szWepNum);
            ShowWeaponNumSkinsMenu(client, iWepNum);
        }
        if(action == MenuAction_End)
        {
            delete menu;
            if(index == MenuEnd_ExitBack)
            {
                BuildWeaponPaintsMenu(client);
            }
        }
        if(action == MenuAction_Cancel)
        {
            if(index == MenuCancel_ExitBack)
            {
                BuildWeaponPaintsMenu(client);
            }
        }
    }
}
public int h_wepnumskins(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client))
    {
        if(action == MenuAction_Select)
        {
            if(g_bIsRoundEnd == false)
            {
                char szBuffer[12];
                char szBufferEx[2][12];
                menu.GetItem(index, szBuffer, sizeof(szBuffer));
                ExplodeString(szBuffer, ";", szBufferEx, sizeof(szBufferEx), sizeof(szBufferEx[]));
                int iSkinDef = StringToInt(szBufferEx[1]);
                int iWepNum = StringToInt(szBufferEx[0]);
                int iWeapon = eItems_FindWeaponByWeaponNum(client, iWepNum);
                g_ArrayStoredWeaponsPaint[client].Set(iWepNum, iSkinDef);
                g_ArrayModifiedWeapons[client].Set(iWepNum, 1);
                ShowWeaponNumSkinsMenu(client, iWepNum , GetMenuSelectionPosition());
                if(IsPlayerAlive(client) && eItems_IsValidWeapon(iWeapon))
                {
                    eItems_RespawnWeapon(client, iWeapon);
                }
            }
            else
            {
                PrintToChat(client, "[E' Tweaker] You can not tweak weapon after round end!");
            }
        }
        if(action == MenuAction_End)
        {
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            if(index == MenuCancel_ExitBack)
            {
                ShowWeaponsBySlotMenu(client, CS_SLOT_KNIFE);
            }
        }
    }
}
public int h_weapontweakmenu(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client, true))
    {
        if(action == MenuAction_Select)
        {
            char szItem[16];
            menu.GetItem(index, szItem, sizeof(szItem));
            if(StrEqual(szItem, "quality"))
            {
                BuildWeaponQualityMenu(client);
            }
            else if(StrEqual(szItem, "wear"))
            {
                BuildWeaponWearMenu(client);
            }
            else if(StrEqual(szItem, "pattern"))
            {
                BuilWeaponPatternMenu(client);
            }
            else if(StrEqual(szItem, "stattrack"))
            {
                BuildWeaponStatTrackMenu(client);
            }
            else if(StrEqual(szItem, "nametag"))
            {
                BuildWeaponNametagMenu(client);
            }
        }
        if(action == MenuAction_End)
        {
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            if(index == MenuCancel_ExitBack)
            {
                BuildMainMenu(client);
            }
        }
    }
}
public int h_weaponqualitymenu(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client, true))
    {
        if(action == MenuAction_Select)
        {
            char szItem[16];
            int iItem;
            int iActiveWeaponNum = eItems_GetActiveWeaponNum(client);
            int iActiveWeapon = eItems_GetActiveWeapon(client);
            if(iActiveWeaponNum > -1)
            {
                if(g_bIsRoundEnd == false)
                {
                    menu.GetItem(index, szItem, sizeof(szItem));
                    iItem = StringToInt(szItem);
                    g_ArrayStoredWeaponsQuality[client].Set(iActiveWeaponNum, iItem);
                    g_ArrayModifiedWeapons[client].Set(iActiveWeaponNum, 1);
                    eItems_RespawnWeapon(client, iActiveWeapon);
                    BuildWeaponQualityMenu(client, GetMenuSelectionPosition());
                }
                else
                {
                    PrintToChat(client, "[E' Tweaker] You can not tweak weapon after round end!");
                }
            }
        }
        if(action == MenuAction_End)
        {
            g_bIsChangingQuality[client] = false;
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            g_bIsChangingQuality[client] = false;
            if(index == MenuCancel_ExitBack)
            {
                BuildWeaponTweakMenu(client);
            }
        }
    }
}
public int h_weaponwearmenu(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client, true))
    {
        if(action == MenuAction_Select)
        {
            int iActiveWeaponNum = eItems_GetActiveWeaponNum(client);
            int iActiveWeapon = eItems_GetActiveWeapon(client);
            if(iActiveWeaponNum > -1)
            {
                if(g_bIsRoundEnd == false)
                {
                    g_ArrayStoredWeaponsWear[client].Set(iActiveWeaponNum, g_fWeaponWearLevel[index]);
                    g_ArrayModifiedWeapons[client].Set(iActiveWeaponNum, 1);
                    eItems_RespawnWeapon(client, iActiveWeapon);
                    BuildWeaponWearMenu(client, GetMenuSelectionPosition());
                }
                else
                {
                    PrintToChat(client, "[E' Tweaker] You can not tweak weapon after round end!");
                }
            }
        }
        if(action == MenuAction_End)
        {
            g_bIsChangingWear[client] = false;
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            g_bIsChangingWear[client] = false;
            if(index == MenuCancel_ExitBack)
            {
            BuildWeaponTweakMenu(client);
            }
        }
    }
}
public int h_weaponpatternmenu(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client, true))
    {
        if(action == MenuAction_Select)
        {
            char szItem[16];
            int iActiveWeaponNum = eItems_GetActiveWeaponNum(client);
            int iActiveWeapon = eItems_GetActiveWeapon(client);
            int pattern = g_ArrayStoredWeaponsPattern[client].Get(iActiveWeaponNum);
            if(iActiveWeaponNum > -1)
            {
                if(g_bIsRoundEnd == false)
                {
                    menu.GetItem(index, szItem, sizeof(szItem));
                    if(StrEqual(szItem, "inc10", false))
                    {
                        pattern += 10;
                    }
                    else if(StrEqual(szItem, "inc100", false))
                    {
                        pattern += 100;
                    }
                    else if(StrEqual(szItem, "default", false))
                    {
                        pattern = 0;
                    }
                    else if(StrEqual(szItem, "dec100", false))
                    {
                        pattern -= 100;
                    }
                    else if(StrEqual(szItem, "dec10", false))
                    {
                        pattern -= 10;
                    }
                    else if(StrEqual(szItem, "enter", false))
                    {
                        g_bIsChangingPatternValue[client] = true;
                        PrintToChat(client, "[E' Tweaker] Type value in chat to change pattern or 'cancel' to cancel changing!");
                    }
                    g_ArrayStoredWeaponsPattern[client].Set(iActiveWeaponNum, pattern);
                    g_ArrayModifiedWeapons[client].Set(iActiveWeaponNum, 1);
                    eItems_RespawnWeapon(client, iActiveWeapon);
                    BuilWeaponPatternMenu(client);
                }
                else
                {
                    PrintToChat(client, "[E' Tweaker] You can not tweak weapon after round end!");
                }
            }
        }
        if(action == MenuAction_End)
        {
            g_bIsChangingPattern[client] = false;
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            g_bIsChangingPattern[client] = false;
            if(index == MenuCancel_ExitBack)
            {
                BuildWeaponTweakMenu(client);
            }
        }
    }
}
public int h_weaponnametagmenu(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client, true))
    {
        if(action == MenuAction_Select)
        {
            char szBuffer[12];
            menu.GetItem(index, szBuffer, sizeof(szBuffer));
            int iActiveWeaponNum = eItems_GetActiveWeaponNum(client);
            int iActiveWeapon = eItems_GetActiveWeapon(client);
            if(iActiveWeaponNum > -1)
            {
                if(g_bIsRoundEnd == false)
                {
                    if(StrEqual(szBuffer, "remove") == true)
                    {
                        g_ArrayStoredWeaponsNametag[client].SetString(iActiveWeaponNum, "");
                        g_ArrayModifiedWeapons[client].Set(iActiveWeaponNum, 1);
                        eItems_RespawnWeapon(client, iActiveWeapon);
                    }
                    else if(StrEqual(szBuffer, "add") == true)
                    {
                        g_bIsChangingNametagValue[client] = true;
                        PrintToChat(client, "[E' Tweaker] Type text in chat to change nametag or 'cancel' to cancel changing!");
                    }
                    BuildWeaponNametagMenu(client);
                }
                else
                {
                    PrintToChat(client, "[E' Tweaker] You can not tweak weapon after round end!");
                }
            }
        }
        if(action == MenuAction_End)
        {
            g_bIsChangingNametag[client] = false;
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            g_bIsChangingNametag[client] = false;
            if(index == MenuCancel_ExitBack)
            {
                BuildWeaponTweakMenu(client);
            }
        }
    }
}
public int h_weaponstattrackmenu(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client, true))
    {
        if(action == MenuAction_Select)
        {
            char szItem[16];
            int iActiveWeaponNum = eItems_GetActiveWeaponNum(client);
            int iActiveWeapon = eItems_GetActiveWeapon(client);
            if(iActiveWeaponNum > -1)
            {
                if(g_bIsRoundEnd == false)
                {
                    menu.GetItem(index, szItem, sizeof(szItem));
                    if(StrEqual(szItem, "toggle", false))
                    {
                        bool bStatTrackEnabled = view_as<bool>(g_ArrayStoredWeaponsStatTrackEnabled[client].Get(iActiveWeaponNum));
                        g_ArrayStoredWeaponsStatTrackEnabled[client].Set(iActiveWeaponNum, bStatTrackEnabled?0:1);
                        g_ArrayModifiedWeapons[client].Set(iActiveWeaponNum, 1);
                        eItems_RespawnWeapon(client, iActiveWeapon);
                        BuildWeaponStatTrackMenu(client);
                    }
                }
                else
                {
                    PrintToChat(client, "[E' Tweaker] You can not tweak weapon after round end!");
                }
            }
        }
        if(action == MenuAction_End)
        {
            g_bIsChangingStatTrack[client] = false;
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            g_bIsChangingStatTrack[client] = false;
            if(index == MenuCancel_ExitBack)
            {
                BuildWeaponTweakMenu(client);
            }
        }
    }
}
public int h_knivesmenu(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client))
    {
        if(action == MenuAction_Select)
        {
            if(g_bIsRoundEnd == false)
            {
                char szItem[32];
                menu.GetItem(index, szItem, sizeof(szItem));
                int iKnifeNum = eItems_GetWeaponNumByDefIndex(g_iStoredKnife[client]);
                if(g_iStoredKnife[client] > 0)
                {
                    g_ArrayModifiedWeapons[client].Set(iKnifeNum, 1);
                }
                if(StrEqual(szItem, "weapon_knife"))
                {
                    g_iStoredKnife[client] = 0;
                    if(GetPlayerWeaponSlot(client, CS_SLOT_KNIFE) != -1)
                    {
                        //eItems_RemoveKnife(client);
                        //PTaH_GivePlayerItem(client, "weapon_knife");
                        eItems_GiveWeapon(client, "weapon_knife");
                    }
                }
                else
                {
                    g_iStoredKnife[client] = StringToInt(szItem);
                    iKnifeNum = eItems_GetWeaponNumByDefIndex(g_iStoredKnife[client]);
                    g_ArrayModifiedWeapons[client].Set(iKnifeNum, 1);
                    if(GetPlayerWeaponSlot(client, CS_SLOT_KNIFE) != -1)
                    {
                        char szClassname[64];
                        eItems_GetWeaponClassNameByDefIndex(g_iStoredKnife[client], szClassname, sizeof(szClassname));
                        //eItems_RemoveKnife(client);
                        //PTaH_GivePlayerItem(client, szClassname);
                        eItems_GiveWeapon(client, szClassname);
                    }
                }
                BuildKnivesMenu(client, GetMenuSelectionPosition());
            }
            else
            {
                PrintToChat(client, "[E' Tweaker] You can not change knife after round end!");
            }
        }
        if(action == MenuAction_End)
        {
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            if(index == MenuCancel_ExitBack)
            {
                BuildMainMenu(client);
            }
        }
    }
}
public int h_glovemenu(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client))
    {
        if(action == MenuAction_Select)
        {
            char szItem[12];
            menu.GetItem(index, szItem, sizeof(szItem));
            int iGloveNum = StringToInt(szItem);
            if(StrEqual(szItem, "default", false))
            {
                Format(g_szStoredGloves[client], sizeof(g_szStoredGloves[]), "");
                RemoveClientGloves(client);
                g_bChangedGloves[client] = true;
                BuildGlovesMenu(client);
            }
            else if(StrEqual(szItem, "random", false))
            {
                int iRandomGloveNum = GetRandomInt(3, g_iGloveCount - 1);                
                int iRandomGloveSkin = GetRandomInt(0, g_ArrayGloves[iRandomGloveNum].Length - 1);
                int iRandomGloveDef = eItems_GetGlovesDefIndexByGlovesNum(iRandomGloveNum);
                int iRandomGloveSkinDef = g_ArrayGloves[iRandomGloveNum].Get(iRandomGloveSkin);
                AttachGloveSkin(client, iRandomGloveDef, iRandomGloveSkinDef);
                Format(g_szStoredGloves[client], sizeof(g_szStoredGloves[]), "%i;%i", iRandomGloveDef, iRandomGloveSkinDef);
                g_bChangedGloves[client] = true;
                BuildGlovesMenu(client);
            }
            else
            {
                BuildGloveSkinsMenu(client, iGloveNum);
            }
        }
        if(action == MenuAction_End)
        {
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            if(index == MenuCancel_ExitBack)
            {
                BuildMainMenu(client);
            }
        }
    }
}
public int h_gloveskinmenu(Menu menu, MenuAction action, int client, int index)
{
    if(IsValidClient(client))
    {
        if(action == MenuAction_Select)
        {
            char szItem[32];
            char szItemEx[2][32];
            menu.GetItem(index, szItem, sizeof(szItem));
            ExplodeString(szItem, ";",szItemEx, sizeof(szItemEx), sizeof(szItemEx[]));
            int iGloveDef = StringToInt(szItemEx[0]);
            int iSkinDef = StringToInt(szItemEx[1]);
            int iGloveNum = eItems_GetGlovesNumByDefIndex(iGloveDef);
            AttachGloveSkin(client, iGloveDef, iSkinDef);
            Format(g_szStoredGloves[client], sizeof(g_szStoredGloves[]), szItem);
            BuildGloveSkinsMenu(client, iGloveNum);
            g_bChangedGloves[client] = true;
        }
        if(action == MenuAction_End)
        {
            delete menu;
        }
        if(action == MenuAction_Cancel)
        {
            if(index == MenuCancel_ExitBack)
            {
                BuildGlovesMenu(client);
            }
        }
    }
}