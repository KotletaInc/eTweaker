bool g_bLateLoad = false;
bool g_bCSGOItems = false;
bool g_bArraySynced = false;


Database g_hDatabase;

int g_iUserDbId[MAXPLAYERS+1] = {0,...};

int iWeaponCount;
int iSkinCount;
int iGloveCount;

Handle g_hGiveWearableCall;
Handle g_hRemoveWearableCall;
Handle g_hOnGlovesRemoved;

ArrayList arWeapons[65] = {null,...};
ArrayList arGloves[65] = {null,...};
ArrayList arStoredWeaponsPaint[MAXPLAYERS+1] = {null,...};
ArrayList arStoredWeaponsQuality[MAXPLAYERS+1] = {null,...};
ArrayList arStoredWeaponsWear[MAXPLAYERS+1] = {null,...};
ArrayList arStoredWeaponsPattern[MAXPLAYERS+1] = {null,...};
ArrayList arModifiedWeapons[MAXPLAYERS+1] = {null,...};
ArrayList arStoredWeaponsNametag[MAXPLAYERS+1] = {null,...};
ArrayList arStoredWeaponsStatTrackEnabled[MAXPLAYERS+1] = {null,...};
ArrayList arStoredWeaponsStatTrackKills[MAXPLAYERS+1] = {null,...};

ConVar gCvKnifeEnabled;
bool g_bKnifeEnabled = true;

int g_iPrevWeapon[MAXPLAYERS+1] = {INVALID_ENT_REFERENCE,...};
int g_iStoredKnife[MAXPLAYERS+1] = {0,...};
bool g_bIsChangingSkin[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingAllSkin[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingQuality[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingWear[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingPattern[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingPatternValue[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingStatTrack[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingNametag[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingNametagValue[MAXPLAYERS+1] = {false,...};
bool g_bChangedGloves[MAXPLAYERS+1] = {false,...};
bool g_bHasGloves[MAXPLAYERS+1] = {false,...};
char g_szDefaultGloves[MAXPLAYERS+1][64];

bool g_bDataFullySynced = false;

char g_szStoredGloves[MAXPLAYERS+1][64];

bool g_bIsRoundEnd = false;

float g_fWeaponWearLevel[7] = {0.000001,0.01,0.08,0.16,0.30,0.55,1.10000};
int g_NameTag_Offset = -1;
