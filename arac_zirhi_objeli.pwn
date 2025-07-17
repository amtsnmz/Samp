
#include <a_samp>
#include <zcmd>

new Float:vehicleArmor[MAX_VEHICLES];
new Text:vehicleArmorTD[MAX_PLAYERS];
new bool:vehicleArmorEnabled[MAX_VEHICLES];
new armorObject[MAX_VEHICLES]; // Objeli zırh için

public OnFilterScriptInit()
{
    print("Araç Zırh Sistemi (Objeli) Başladı.");
    for(new i = 0; i < MAX_VEHICLES; i++) {
        vehicleArmor[i] = 0.0;
        vehicleArmorEnabled[i] = false;
        armorObject[i] = INVALID_OBJECT_ID;
    }
    return 1;
}

public OnPlayerConnect(playerid)
{
    vehicleArmorTD[playerid] = TextDrawCreate(320.0, 400.0, "");
    TextDrawLetterSize(vehicleArmorTD[playerid], 0.3, 1.0);
    TextDrawColor(vehicleArmorTD[playerid], 0x00FF00FF);
    TextDrawSetOutline(vehicleArmorTD[playerid], 1);
    TextDrawBackgroundColor(vehicleArmorTD[playerid], 0x000000FF);
    TextDrawFont(vehicleArmorTD[playerid], 1);
    TextDrawHideForPlayer(playerid, vehicleArmorTD[playerid]);
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if (newstate == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if (vehicleArmorEnabled[vehicleid])
        {
            ShowVehicleArmorTD(playerid, vehicleid);
        }
    }
    else if (oldstate == PLAYER_STATE_DRIVER)
    {
        TextDrawHideForPlayer(playerid, vehicleArmorTD[playerid]);
    }
    return 1;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
    if (!vehicleArmorEnabled[vehicleid]) return 1;

    vehicleArmor[vehicleid] -= 10.0;
    if (vehicleArmor[vehicleid] < 0.0) vehicleArmor[vehicleid] = 0.0;

    UpdateVehicleArmorTD(playerid, vehicleid);

    if (vehicleArmor[vehicleid] <= 0.0)
    {
        vehicleArmorEnabled[vehicleid] = false;
        TextDrawHideForPlayer(playerid, vehicleArmorTD[playerid]);
        SendClientMessage(playerid, 0xFF0000FF, "⚠️ Araç zırhı tükendi!");

        // Objeyi kaldır
        if (armorObject[vehicleid] != INVALID_OBJECT_ID)
        {
            DestroyObject(armorObject[vehicleid]);
            armorObject[vehicleid] = INVALID_OBJECT_ID;
        }
    }

    return 1;
}

CMD:araczirhi(playerid, params[])
{
    if (!IsPlayerInAnyVehicle(playerid)) {
        SendClientMessage(playerid, 0xFF0000FF, "Bu komutu sadece araçtayken kullanabilirsiniz.");
        return 1;
    }

    new vehicleid = GetPlayerVehicleID(playerid);

    vehicleArmor[vehicleid] = 100.0;
    vehicleArmorEnabled[vehicleid] = true;
    SendClientMessage(playerid, 0x00FF00FF, "✅ Araç zırhı etkinleştirildi (%100).");

    // TextDraw göster
    ShowVehicleArmorTD(playerid, vehicleid);

    // Görsel zırh objesi ekle
    if (armorObject[vehicleid] != INVALID_OBJECT_ID)
    {
        DestroyObject(armorObject[vehicleid]);
    }
    armorObject[vehicleid] = CreateObject(978, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0); // Metal kapak objesi
    AttachObjectToVehicle(armorObject[vehicleid], vehicleid, 0.0, 0.0, 1.2);

    return 1;
}

stock ShowVehicleArmorTD(playerid, vehicleid)
{
    new str[64];
    format(str, sizeof(str), "Araç Zırhı: %.0f%%", vehicleArmor[vehicleid]);
    TextDrawSetString(vehicleArmorTD[playerid], str);
    TextDrawShowForPlayer(playerid, vehicleArmorTD[playerid]);
}

stock UpdateVehicleArmorTD(playerid, vehicleid)
{
    new str[64];
    format(str, sizeof(str), "Araç Zırhı: %.0f%%", vehicleArmor[vehicleid]);

    TextDrawSetString(vehicleArmorTD[playerid], str);
    TextDrawShowForPlayer(playerid, vehicleArmorTD[playerid]);
}
