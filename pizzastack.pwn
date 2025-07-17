#include <a_samp>

// Pizza Stack bölgesi sınırları (örnek)
#define PIZZA_MINX 1200.0
#define PIZZA_MAXX 1300.0
#define PIZZA_MINY -1600.0
#define PIZZA_MAXY -1500.0
#define PIZZA_MINZ 10.0
#define PIZZA_MAXZ 20.0

// Mevcut tabela objesinin ID'si ve konumu (örnek)
#define PIZZA_TABLE_OBJID 1234    // Gerçek ID ile değiştir
#define PIZZA_TABLE_X 1250.0
#define PIZZA_TABLE_Y -1550.0
#define PIZZA_TABLE_Z 15.0
#define PIZZA_TABLE_RotX 0.0
#define PIZZA_TABLE_RotY 0.0
#define PIZZA_TABLE_RotZ 0.0

// Yeni "Mclerson" tabela objesi ID ve konumu
#define MCLERSON_TABLE_OBJID 1235  // Kendi özel tabela objen
#define MCLERSON_TABLE_X PIZZA_TABLE_X
#define MCLERSON_TABLE_Y PIZZA_TABLE_Y
#define MCLERSON_TABLE_Z PIZZA_TABLE_Z
#define MCLERSON_TABLE_RotX PIZZA_TABLE_RotX
#define MCLERSON_TABLE_RotY PIZZA_TABLE_RotY
#define MCLERSON_TABLE_RotZ PIZZA_TABLE_RotZ

// 3D TextDraw ID'leri
new Text:mclerson3DText[MAX_PLAYERS];

// Objelerimiz
new pizzaOldObj = INVALID_OBJECT_ID;
new mclersonObj = INVALID_OBJECT_ID;

public OnFilterScriptInit()
{
    print("[FS] Pizza Stack Mclerson sistemi aktif!");

    pizzaOldObj = CreateObject(PIZZA_TABLE_OBJID, PIZZA_TABLE_X, PIZZA_TABLE_Y, PIZZA_TABLE_Z, PIZZA_TABLE_RotX, PIZZA_TABLE_RotY, PIZZA_TABLE_RotZ);
    
    SetTimer("ReplaceTableObj", 1000, false);

    return 1;
}

public ReplaceTableObj()
{
    if(pizzaOldObj != INVALID_OBJECT_ID)
    {
        DestroyObject(pizzaOldObj);
        pizzaOldObj = INVALID_OBJECT_ID;
    }

    mclersonObj = CreateObject(MCLERSON_TABLE_OBJID, MCLERSON_TABLE_X, MCLERSON_TABLE_Y, MCLERSON_TABLE_Z, MCLERSON_TABLE_RotX, MCLERSON_TABLE_RotY, MCLERSON_TABLE_RotZ);
}

// 3D TextDraw
public OnPlayerConnect(playerid)
{
    mclerson3DText[playerid] = INVALID_3DTEXT_ID;
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(mclerson3DText[playerid] != INVALID_3DTEXT_ID)
    {
        DeletePlayer3DText(playerid, mclerson3DText[playerid]);
        mclerson3DText[playerid] = INVALID_3DTEXT_ID;
    }
    return 1;
}

public OnPlayerUpdate(playerid)
{
    new Float:x, y, z;
    GetPlayerPos(playerid, x, y, z);

    if(x >= PIZZA_MINX && x <= PIZZA_MAXX && y >= PIZZA_MINY && y <= PIZZA_MAXY && z >= PIZZA_MINZ && z <= PIZZA_MAXZ)
    {
        if(mclerson3DText[playerid] == INVALID_3DTEXT_ID)
        {
            mclerson3DText[playerid] = CreatePlayer3DText(playerid, "Mclerson", x, y, z + 2.0, 5.0, 0xFFFF0000);
        }
        else
        {
            SetPlayer3DTextPos(mclerson3DText[playerid], x, y, z + 2.0);
        }
    }
    else
    {
        if(mclerson3DText[playerid] != INVALID_3DTEXT_ID)
        {
            DeletePlayer3DText(playerid, mclerson3DText[playerid]);
            mclerson3DText[playerid] = INVALID_3DTEXT_ID;
        }
    }
    return 1;
}

// --- Hasar filtreleme ---
// Pizza Stack bölgesinde sadece bıçak(4) ve sopa(5) ile hasar alınır
public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
    new Float:x, y, z;
    GetPlayerPos(playerid, x, y, z);

    if(x >= PIZZA_MINX && x <= PIZZA_MAXX && y >= PIZZA_MINY && y <= PIZZA_MAXY && z >= PIZZA_MINZ && z <= PIZZA_MAXZ)
    {
        if(weaponid != 4 && weaponid != 5) // Bıçak=4, Sopa=5
        {
            // Hasar iptal
            return 0;
        }
    }

    return 1; // Normal hasar işle
}
