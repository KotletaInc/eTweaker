bool g_bLateLoaded;
int g_iWeaponCount;
int g_iSkinCount;
int g_iGloveCount;

bool g_bDataFullySynced = false;
Database g_hDatabase;
int g_iUserDbId[MAXPLAYERS+1] = {0,...};


ArrayList g_ArrayWeapons[128] = {null,...};
ArrayList g_ArrayGloves[128] = {null,...};
ArrayList g_ArrayStoredWeaponsPaint[MAXPLAYERS+1] = {null,...};
ArrayList g_ArrayStoredWeaponsWear[MAXPLAYERS+1] = {null,...};
ArrayList g_ArrayStoredWeaponsPattern[MAXPLAYERS+1] = {null,...};
ArrayList g_ArrayStoredWeaponsQuality[MAXPLAYERS+1] = {null,...};
ArrayList g_ArrayStoredWeaponsNametag[MAXPLAYERS+1] = {null,...};
ArrayList g_ArrayModifiedWeapons[MAXPLAYERS+1] = {null,...};
ArrayList g_ArrayStoredWeaponsStatTrackEnabled[MAXPLAYERS+1] = {null,...};
ArrayList g_ArrayStoredWeaponsStatTrackKills[MAXPLAYERS+1] = {null,...};


bool g_bIsChangingPattern[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingPatternValue[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingNametag[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingNametagValue[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingSkin[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingAllSkin[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingQuality[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingWear[MAXPLAYERS+1] = {false,...};
bool g_bIsChangingStatTrack[MAXPLAYERS+1] = {false,...};
int g_iPrevWeapon[MAXPLAYERS+1] = {INVALID_ENT_REFERENCE,...};
int g_iStoredKnife[MAXPLAYERS+1] = {0,...};
char g_szStoredGloves[MAXPLAYERS+1][64];
bool g_bChangedGloves[MAXPLAYERS+1] = {false,...};
char g_szDefaultGloves[MAXPLAYERS+1][64];
bool g_bHasGloves[MAXPLAYERS+1] = {false,...};

float g_fWeaponWearLevel[7] = {0.000001,0.01,0.08,0.16,0.30,0.55,1.10000};
bool g_bIsRoundEnd = false;
int g_iNameTagOffset = -1;

Handle g_hGiveWearableCall;
Handle g_hRemoveWearableCall;
Handle g_hOnGlovesRemoved;

ConVar g_cvSurfFix;
ConVar g_cvAllowAllPaintsSelection;
ConVar g_cvAllowAllSkinsRandomSkin;
ConVar g_cvAllowGlovesRandomSkin;
ConVar g_cvAllowCurrentWeaponRandomSkin;
ConVar g_cvAllowWeaponRandomSkin;
ConVar g_cvAllowPrimarySkinSelection;
ConVar g_cvAllowSecondarySkinSelection;
ConVar g_cvAllowKnifeSkinSelection;
ConVar g_cvAllowKnifeBareHands;
ConVar g_cvAllowKnifeAxe;
ConVar g_cvAllowKnifeHammer;
ConVar g_cvAllowKnifeWrench;