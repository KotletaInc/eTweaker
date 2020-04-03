public Action Command_WeaponCosmetic(int client, int args)
{
	if(IsValidClient(client))
	{
		BuildMainMenu(client);
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