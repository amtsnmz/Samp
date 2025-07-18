#include <a_samp>
#include <zcmd>
#include <streamer>
#include <sscanf>

#define MAX_REGIONS 50

enum RegionData
{
    Text3D:regionLabel,
    areaID,
    gangZoneID,
    Float:minX,
    Float:minY,
    Float:maxX,
    Float:maxY,
    color,
    name[32],
    inRegion[MAX_PLAYERS]
}

new Regions[MAX_REGIONS][RegionData];
new totalRegions = 0;

CMD:createzone(playerid, params[])
{
    if(totalRegions >= MAX_REGIONS) return SendClientMessage(playerid, -1, "Maksimum bölge sayısına ulaşıldı.");

    new Float:minX, Float:minY, Float:maxX, Float:maxY, color, zoneName[32];
    if(sscanf(params, "ffffis[32]", minX, minY, maxX, maxY, color, zoneName))
        return SendClientMessage(playerid, -1, "Kullanım: /createzone minX minY maxX maxY renk_isim");

    new idx = totalRegions;

    Regions[idx][minX] = minX;
    Regions[idx][minY] = minY;
    Regions[idx][maxX] = maxX;
    Regions[idx][maxY] = maxY;
    Regions[idx][color] = color;
    format(Regions[idx][name], 32, zoneName);

    Regions[idx][areaID] = CreateDynamicRectangle(minX, minY, maxX, maxY, -1, 0);

    new Float:centerX = (minX + maxX) / 2;
    new Float:centerY = (minY + maxY) / 2;

    new labelText[64];
    format(labelText, sizeof(labelText), "{%06x}%s Bölgesi", color >>> 8, zoneName);
    Regions[idx][regionLabel] = Create3DTextLabel(labelText, color, centerX, centerY, 10.0, 100.0, 0, 1);

    // Gang Zone için ID atanıyor
    Regions[idx][gangZoneID] = GangZoneCreate(minX, minY, maxX, maxY);
    GangZoneShowForAll(Regions[idx][gangZoneID], color);

    totalRegions++;
    SendClientMessage(playerid, -1, "✔ Bölge başarıyla oluşturuldu.");
    return 1;
}

// Giriş / çıkış kontrolü
public OnPlayerUpdate(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    for(new i = 0; i < totalRegions; i++)
    {
        new bool:inside =
            x >= Regions[i][minX] && x <= Regions[i][maxX] &&
            y >= Regions[i][minY] && y <= Regions[i][maxY];

        if(inside && !Regions[i][inRegion][playerid])
        {
            Regions[i][inRegion][playerid] = true;
            new msg[64];
            format(msg, sizeof(msg), "[!] %s bölgesine girdiniz.", Regions[i][name]);
            SendClientMessage(playerid, -1, msg);
        }
        else if(!inside && Regions[i][inRegion][playerid])
        {
            Regions[i][inRegion][playerid] = false;
            new msg[64];
            format(msg, sizeof(msg), "[!] %s bölgesinden çıktınız.", Regions[i][name]);
            SendClientMessage(playerid, -1, msg);
        }
    }
    return 1;
}

// Bölgelerde sadece bıçak-sopa-yumruk hasarı geçerli
public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
    new Float:x, y, z;
    GetPlayerPos(playerid, x, y, z);

    for(new i = 0; i < totalRegions; i++)
    {
        if(x >= Regions[i][minX] && x <= Regions[i][maxX] &&
           y >= Regions[i][minY] && y <= Regions[i][maxY])
        {
            if(weaponid != 0 && weaponid != 4 && weaponid != 5)
                return 0; // silah hasarı iptal
        }
    }
    return 1;
}

public OnFilterScriptInit()
{
    print(">> Bölge sistemi aktif.");
    return 1;
}

public OnFilterScriptExit()
{
    for(new i = 0; i < totalRegions; i++)
    {
        if(IsValidDynamicArea(Regions[i][areaID]))
            DestroyDynamicArea(Regions[i][areaID]);

        if(IsValid3DTextLabel(Regions[i][regionLabel]))
            Delete3DTextLabel(Regions[i][regionLabel]);

        GangZoneDestroy(Regions[i][gangZoneID]);
    }
    return 1;
}
