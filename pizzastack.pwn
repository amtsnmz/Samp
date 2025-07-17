#include <a_samp>

// Pizza Stack bölgesine giren oyunculara 3D TextDraw ile "Mclerson" yazısı göster
new Text:mclerson3DText[MAX_PLAYERS];

// Pizza Stack koordinat sınırları (örnek)
#define PIZZA_MINX 1200.0
#define PIZZA_MAXX 1300.0
#define PIZZA_MINY -1600.0
#define PIZZA_MAXY -1500.0
#define PIZZA_MINZ 10.0
#define PIZZA_MAXZ 20.0

public OnFilterScriptInit()
{
    print("[FS] Pizza Stack Mclerson yazısı aktif!");
    return 1;
}

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

    // Pizza Stack bölgesinde mi kontrolü
    if(x >= PIZZA_MINX && x <= PIZZA_MAXX && y >= PIZZA_MINY && y <= PIZZA_MAXY && z >= PIZZA_MINZ && z <= PIZZA_MAXZ)
    {
        if(mclerson3DText[playerid] == INVALID_3DTEXT_ID)
        {
            mclerson3DText[playerid] = CreatePlayer3DText(playerid, "Mclerson", x, y, z + 2.0, 5.0, 0xFFFF0000);
        }
        else
        {
            // Pozisyonu güncelle
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
