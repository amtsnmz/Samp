#include <a_samp>
#include <streamer> // Yüklü değilse eklemeyi unutma
#include <foreach>

#define MAX_SIGNAL_OBJ 2
#define SINYAL_OBJE_ID 18646 // Sarı ışık efekti için obje
#define FAR_OBJE_ID 18648 // Beyaz far ışığı

new sinyalObjeleri[MAX_VEHICLES][MAX_SIGNAL_OBJ];
new farObjeleri[MAX_VEHICLES][2];
new sinyalDurumu[MAX_PLAYERS];

public OnFilterScriptInit()
{
    print("[FS] Far & Sinyal Sistemi Aktif!");
    SetTimer("SistemKontrol", 500, true);
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        FarlariOlustur(vehicleid);
    }
    return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
    SinyalleriKapat(vehicleid);
    FarTemizle(vehicleid);
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    SinyalleriKapat(vehicleid);
    return 1;
}

forward SistemKontrol();
public SistemKontrol()
{
    foreach(Player, i)
    {
        if(IsPlayerInAnyVehicle(i) && GetPlayerState(i) == PLAYER_STATE_DRIVER)
        {
            new vehicleid = GetPlayerVehicleID(i);
            new keys, ud, lr;
            GetPlayerKeys(i, keys, ud, lr);

            // Otomatik far yakma
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
            if(engine == VEHICLE_PARAMS_ON)
            {
                SetVehicleParamsEx(vehicleid, engine, 1, alarm, doors, bonnet, boot, objective);
            }

            // Sinyal kontrol
            if(lr < 0 && sinyalDurumu[i] != 1) // Sol
            {
                SinyalVer(vehicleid, 1);
                sinyalDurumu[i] = 1;
            }
            else if(lr > 0 && sinyalDurumu[i] != 2) // Sağ
            {
                SinyalVer(vehicleid, 2);
                sinyalDurumu[i] = 2;
            }
            else if(lr == 0 && sinyalDurumu[i] != 0) // Düz gidiyor
            {
                SinyalleriKapat(vehicleid);
                sinyalDurumu[i] = 0;
            }
        }
    }
    return 1;
}

// 3D Far Objesi Oluştur
stock FarlariOlustur(vehicleid)
{
    if(!IsValidVehicle(vehicleid)) return;
    for(new i = 0; i < 2; i++)
    {
        Float:x, y, z;
        GetVehiclePos(vehicleid, x, y, z);
        farObjeleri[vehicleid][i] = CreateDynamicObject(FAR_OBJE_ID, x, y, z, 0.0, 0.0, 0.0, -1, vehicleid);
        AttachDynamicObjectToVehicle(farObjeleri[vehicleid][i], vehicleid, (i==0) ? 1.0 : -1.0, 2.5, -0.2, 0, 0, 0);
    }
}

// Far Objesini Temizle
stock FarTemizle(vehicleid)
{
    for(new i = 0; i < 2; i++)
    {
        if(IsValidDynamicObject(farObjeleri[vehicleid][i]))
        {
            DestroyDynamicObject(farObjeleri[vehicleid][i]);
            farObjeleri[vehicleid][i] = INVALID_OBJECT_ID;
        }
    }
}

// Sinyal Efekti
stock SinyalVer(vehicleid, direction)
{
    SinyalleriKapat(vehicleid); // Önce kapat
    new Float:x, y, z;
    GetVehiclePos(vehicleid, x, y, z);

    if(direction == 1) // Sol
    {
        sinyalObjeleri[vehicleid][0] = CreateDynamicObject(SINYAL_OBJE_ID, x, y, z, 0, 0, 0, -1, vehicleid);
        AttachDynamicObjectToVehicle(sinyalObjeleri[vehicleid][0], vehicleid, -1.0, -1.8, 0.2, 0, 0, 0);
    }
    else if(direction == 2) // Sağ
    {
        sinyalObjeleri[vehicleid][1] = CreateDynamicObject(SINYAL_OBJE_ID, x, y, z, 0, 0, 0, -1, vehicleid);
        AttachDynamicObjectToVehicle(sinyalObjeleri[vehicleid][1], vehicleid, 1.0, -1.8, 0.2, 0, 0, 0);
    }
}

// Sinyalleri Kapat
stock SinyalleriKapat(vehicleid)
{
    for(new i = 0; i < MAX_SIGNAL_OBJ; i++)
    {
        if(IsValidDynamicObject(sinyalObjeleri[vehicleid][i]))
        {
            DestroyDynamicObject(sinyalObjeleri[vehicleid][i]);
            sinyalObjeleri[vehicleid][i] = INVALID_OBJECT_ID;
        }
    }
}
