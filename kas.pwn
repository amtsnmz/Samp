#include <a_samp>

#define MAX_KASGUCU 100.0

new Float:kasGucu[MAX_PLAYERS];
new Text:KasGucuText[MAX_PLAYERS];

public OnFilterScriptInit()
{
    print("Kas Gücü Sistemi Yüklendi.");
    return 1;
}

public OnPlayerConnect(playerid)
{
    kasGucu[playerid] = 10.0;

    // Kas gücü TextDraw oluştur
    KasGucuText[playerid] = TextDrawCreate(10.0, 100.0, "Kas Gucu: 10.0");
    TextDrawFont(KasGucuText[playerid], 1);
    TextDrawLetterSize(KasGucuText[playerid], 0.3, 1.0);
    TextDrawColor(KasGucuText[playerid], 0xFFFFFFFF);
    TextDrawSetOutline(KasGucuText[playerid], 1);
    TextDrawShowForPlayer(playerid, KasGucuText[playerid]);

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    TextDrawHideForPlayer(playerid, KasGucuText[playerid]);
    TextDrawDestroy(KasGucuText[playerid]);
    return 1;
}

public OnPlayerUpdate(playerid)
{
    if(GetPlayerSpeed(playerid) > 5.0)
    {
        IncreaseKasGucu(playerid, 0.01);
    }
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if((newkeys & KEY_JUMP) && !(oldkeys & KEY_JUMP))
    {
        IncreaseKasGucu(playerid, 0.05);
    }
    return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
    if(weaponid == 0 && IsPlayerConnected(damagedid))
    {
        new Float:damage;
        damage = 2.0 + (kasGucu[playerid] / MAX_KASGUCU) * 18.0;

        new Float:hp;
        GetPlayerHealth(damagedid, hp);
        hp -= damage;

        if(hp > 0.0) SetPlayerHealth(damagedid, hp);
        else SetPlayerHealth(damagedid, 0.0);
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if(strcmp(cmdtext, "/kasgucu", true) == 0)
    {
        new msg[64];
        format(msg, sizeof(msg), "[Kas Gücün]: %.1f / 100", kasGucu[playerid]);
        SendClientMessage(playerid, 0x00FF00FF, msg);
        return 1;
    }
    return 0;
}

stock IncreaseKasGucu(playerid, Float:amount)
{
    kasGucu[playerid] += amount;
    if(kasGucu[playerid] > MAX_KASGUCU)
        kasGucu[playerid] = MAX_KASGUCU;

    new string[64];
    format(string, sizeof(string), "Kas Gucu: %.1f", kasGucu[playerid]);
    TextDrawSetString(KasGucuText[playerid], string);
}

stock Float:GetPlayerSpeed(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerVelocity(playerid, x, y, z);
    return floatsqroot(x*x + y*y + z*z) * 100.0;
}
