#include <a_samp>
#include <zcmd>
#include <dini>
#include <sscanf2>
#include <streamer>

#define MAX_NAME 24
#define KLASOR "Kullanicilar/"

#define SINYAL_OBJE_ID 18646
#define FAR_OBJE_ID 18648
#define MAX_SIGNAL_OBJ 2

// Oyuncu durumları
new oyuncuGiris[MAX_PLAYERS];
new oyuncuAdminSeviye[MAX_PLAYERS];

// Araç objeleri
new sinyalObjeleri[MAX_VEHICLES][MAX_SIGNAL_OBJ];
new farObjeleri[MAX_VEHICLES][2];

// Yardım TextDrawlar
new Text:tdYardimBG[MAX_PLAYERS];
new Text:tdKomutSatiri[MAX_PLAYERS][10];
new bool:yardimAcik[MAX_PLAYERS];

// Yardım komut listesi admin seviyelerine göre
new const KomutListeleri[5][] = 
{
    "/kaydol, /giris, /yardim",
    "/cek, /adminsay",
    "/kickla",
    "/verarac",
    "/setadmin, /plaka"
};

// ----- Filterscript Başlangıcı -----
public OnFilterScriptInit()
{
    print("[FS] Tam sistem aktif! Far, sinyal, admin, plaka, kayıt ve yardim.");
    
    // Var olan tüm araçların plakalarını "Mclerson" yap
    for(new i = 1; i < MAX_VEHICLES; i++)
    {
        if(GetVehicleModel(i) != 0)
        {
            SetVehicleNumberPlate(i, "Mclerson");
            FarlariOlustur(i);
        }
    }
    SetTimer("SistemKontrol", 500, true);
    return 1;
}

public OnPlayerConnect(playerid)
{
    oyuncuGiris[playerid] = 0;
    oyuncuAdminSeviye[playerid] = 0;
    yardimAcik[playerid] = false;
    return 1;
}

public OnVehicleSpawn(vehicleid)
{
    SetVehicleNumberPlate(vehicleid, "Mclerson");
    FarlariOlustur(vehicleid);
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        FarlariOlustur(vehicleid);
    }
    else if(newstate == PLAYER_STATE_ONFOOT)
    {
        // Araçta değilse far objelerini temizleyebiliriz
        // İstersen açarız
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    // Yardım menüsünü kapat
    if(yardimAcik[playerid])
        KapatYardimTexdraw(playerid);
    return 1;
}

// --- Sistem Kontrol Timer ---
forward SistemKontrol();
public SistemKontrol()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && IsPlayerInAnyVehicle(i) && oyuncuGiris[i])
        {
            new vehicleid = GetPlayerVehicleID(i);

            // Otomatik far açma
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
            if(engine == VEHICLE_PARAMS_ON)
                SetVehicleParamsEx(vehicleid, engine, 1, alarm, doors, bonnet, boot, objective);

            // Sinyal kontrol
            new keys, ud, lr;
            GetPlayerKeys(i, keys, ud, lr);

            if(lr < 0)
                SinyalVer(vehicleid, 1);
            else if(lr > 0)
                SinyalVer(vehicleid, 2);
            else
                SinyalleriKapat(vehicleid);
        }
    }
    return 1;
}

// ----------------------
// Araç far objesi oluşturma
stock FarlariOlustur(vehicleid)
{
    if(!IsValidVehicle(vehicleid)) return;

    // Önce varsa temizle
    FarTemizle(vehicleid);

    for(new i = 0; i < 2; i++)
    {
        new Float:x, y, z;
        GetVehiclePos(vehicleid, x, y, z);
        farObjeleri[vehicleid][i] = CreateDynamicObject(FAR_OBJE_ID, x, y, z, 0.0, 0.0, 0.0, -1, vehicleid);
        AttachDynamicObjectToVehicle(farObjeleri[vehicleid][i], vehicleid, (i == 0) ? 1.0 : -1.0, 2.5, -0.2, 0, 0, 0);
    }
}

// Far objesini temizle
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

// Sinyal objesi verme
stock SinyalVer(vehicleid, direction)
{
    SinyalleriKapat(vehicleid);

    new Float:x, y, z;
    GetVehiclePos(vehicleid, x, y, z);

    if(direction == 1) // sol sinyal
    {
        sinyalObjeleri[vehicleid][0] = CreateDynamicObject(SINYAL_OBJE_ID, x, y, z, 0, 0, 0, -1, vehicleid);
        AttachDynamicObjectToVehicle(sinyalObjeleri[vehicleid][0], vehicleid, -1.0, -1.8, 0.2, 0, 0, 0);
    }
    else if(direction == 2) // sağ sinyal
    {
        sinyalObjeleri[vehicleid][1] = CreateDynamicObject(SINYAL_OBJE_ID, x, y, z, 0, 0, 0, -1, vehicleid);
        AttachDynamicObjectToVehicle(sinyalObjeleri[vehicleid][1], vehicleid, 1.0, -1.8, 0.2, 0, 0, 0);
    }
}

// Sinyal objelerini kapat
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

// ----------------------
// KOMUTLAR
// /kaydol [şifre]
CMD:kaydol(playerid, params[])
{
    new sifre[32], dosya[64], isim[MAX_NAME];
    if(sscanf(params, "s[32]", sifre))
        return SendClientMessage(playerid, 0xFF5555FF, "Kullanım: /kaydol [şifre]");

    GetPlayerName(playerid, isim, MAX_NAME);
    format(dosya, sizeof dosya, "%s%s.ini", KLASOR, isim);

    if(dini_Exists(dosya))
        return SendClientMessage(playerid, 0xFF5555FF, "Zaten kayıtlısın!");

    dini_Create(dosya);
    dini_Set(dosya, "sifre", sifre);
    dini_IntSet(dosya, "admin", 0);

    SendClientMessage(playerid, 0x55FF55FF, "Kayıt başarılı! Şimdi /giris yap.");
    return 1;
}

// /giris [şifre]
CMD:giris(playerid, params[])
{
    new sifre[32], dosya[64], kayitsifre[32], isim[MAX_NAME];
    if(sscanf(params, "s[32]", sifre))
        return SendClientMessage(playerid, 0xFF5555FF, "Kullanım: /giris [şifre]");

    GetPlayerName(playerid, isim, MAX_NAME);
    format(dosya, sizeof dosya, "%s%s.ini", KLASOR, isim);

    if(!dini_Exists(dosya))
        return SendClientMessage(playerid, 0xFF5555FF, "Kayıt bulunamadı!");

    format(kayitsifre, 32, dini_Get(dosya, "sifre"));
    if(!strcmp(sifre, kayitsifre, false))
    {
        oyuncuGiris[playerid] = 1;
        oyuncuAdminSeviye[playerid] = dini_Int(dosya, "admin");
        SendClientMessage(playerid, 0x55FF55FF, "Giriş başarılı.");
    }
    else
        SendClientMessage(playerid, 0xFF5555FF, "Şifre yanlış!");
    return 1;
}

// /plaka [yeni_plaka]
CMD:plaka(playerid, params[])
{
    if(!IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, 0xFF5555FF, "Araçta olmalısın!");

    new text[32];
    if(sscanf(params, "s[32]", text))
        return SendClientMessage(playerid, 0xFFFF55FF, "Kullanım: /plaka [yeni_plaka]");

    new vehicleid = GetPlayerVehicleID(playerid);
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return SendClientMessage(playerid, 0xFF5555FF, "Sadece sürücü plakayı değiştirebilir!");

    SetVehicleNumberPlate(vehicleid, text);
    new msg[64];
    format(msg, sizeof msg, "Plaka başarıyla '%s' olarak ayarlandı!", text);
    SendClientMessage(playerid, 0x55FF55FF, msg);
    return 1;
}

// /adminsay
CMD:adminsay(playerid, params[])
{
    if(oyuncuAdminSeviye[playerid] < 1) return 0;
    new count = 0;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && oyuncuAdminSeviye[i] > 0)
            count++;
    }
    new msg[64];
    format(msg, sizeof msg, "Sunucuda %d admin aktif.", count);
    SendClientMessage(playerid, 0x55FF55FF, msg);
    return 1;
}

// /cek [id]
CMD:cek(playerid, params[])
{
    if(oyuncuAdminSeviye[playerid] < 1) return 0;

    new hedefid;
    if(sscanf(params, "u", hedefid))
        return SendClientMessage(playerid, 0xFF5555FF, "Kullanım: /cek [id]");

    if(!IsPlayerConnected(hedefid))
        return SendClientMessage(playerid, 0xFF5555FF, "Oyuncu bulunamadı.");

    new Float:x, y, z;
    GetPlayerPos(playerid, x, y, z);
    SetPlayerPos(hedefid, x+1.0, y, z);
    SendClientMessage(hedefid, 0x55FFFFFF, "Bir admin seni yanına çekti.");
    return 1;
}

// /kickla [id]
CMD:kickla(playerid, params[])
{
    if(oyuncuAdminSeviye[playerid] < 2) return 0;

    new hedefid;
    if(sscanf(params, "u", hedefid))
        return SendClientMessage(playerid, 0xFF5555FF, "Kullanım: /kickla [id]");

    if(!IsPlayerConnected(hedefid))
        return SendClientMessage(playerid, 0xFF5555FF, "Oyuncu bulunamadı.");

    Kick(hedefid);
    return 1;
}

// /verarac [modelid]
CMD:verarac(playerid, params[])
{
    if(oyuncuAdminSeviye[playerid] < 3) return 0;

    new modelid;
    if(sscanf(params, "d", modelid))
        return SendClientMessage(playerid, 0xFF5555FF, "Kullanım: /verarac [modelid]");

    new Float:x, y, z, a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    CreateVehicle(modelid, x + 2.0, y, z, a, -1, -1, 300);
    return 1;
}

// /setadmin [id] [seviye]
CMD:setadmin(playerid, params[])
{
    if(oyuncuAdminSeviye[playerid] < 4) return 0;

    new hedefid, level;
    if(sscanf(params, "ud", hedefid, level))
        return SendClientMessage(playerid, 0xFF5555FF, "Kullanım: /setadmin [id] [seviye]");

    if(level < 0 || level > 4)
        return SendClientMessage(playerid, 0xFF5555FF, "Seviye 0-4 arasında olmalı.");

    if(!IsPlayerConnected(hedefid))
        return SendClientMessage(playerid, 0xFF5555FF, "Oyuncu bulunamadı.");

    oyuncuAdminSeviye[hedefid] = level;

    new isim[MAX_NAME], dosya[64];
    GetPlayerName(hedefid, isim, MAX_NAME);
    format(dosya, sizeof dosya, "%s%s.ini", KLASOR, isim);
    if(dini_Exists(dosya))
        dini_IntSet(dosya, "admin", level);

    new msg[64];
    format(msg, sizeof msg, "%s adlı oyuncunun admin seviyesi %d olarak ayarlandı.", isim, level);
    SendClientMessage(playerid, 0x55FF55FF, msg);
    return 1;
}

// /yardim (TextDraw destekli)
CMD:yardim(playerid, params[])
{
    if(yardimAcik[playerid])
    {
        KapatYardimTexdraw(playerid);
        return SendClientMessage(playerid, 0xFFFFFFAA, "Yardım menüsü kapatıldı.");
    }
    GosterYardimTexdraw(playerid);
    return SendClientMessage(playerid, 0xFFFFFFAA, "Yardım menüsü açıldı.");
}

// Yardım menüsü açma
stock GosterYardimTexdraw(playerid)
{
    if(yardimAcik[playerid]) return;

    tdYardimBG[playerid] = TextDrawCreate(150.0, 100.0, "");
    TextDrawUseBox(tdYardimBG[playerid], 1);
    TextDrawBoxColor(tdYardimBG[playerid], 0xAA000000);
    TextDrawColor(tdYardimBG[playerid], 0xFFFFFFFF);
    TextDrawFont(tdYardimBG[playerid], 1);
    TextDrawLetterSize(tdYardimBG[playerid], 0.5, 1.0);
    TextDrawTextSize(tdYardimBG[playerid], 340.0, 200.0);
    TextDrawShowForPlayer(playerid, tdYardimBG[playerid]);

    new yPos = 110;
    new index = 0;
    for(new lvl = 0; lvl <= oyuncuAdminSeviye[playerid] && lvl < sizeof KomutListeleri; lvl++)
    {
        new komutlar[128];
        format(komutlar, sizeof komutlar, "Seviye %d: %s", lvl, KomutListeleri[lvl]);
        tdKomutSatiri[playerid][index] = TextDrawCreate(160.0, float(yPos), komutlar);
        TextDrawFont(tdKomutSatiri[playerid][index], 1);
        TextDrawColor(tdKomutSatiri[playerid][index], 0xFFFFFFFF);
        TextDrawShowForPlayer(playerid, tdKomutSatiri[playerid][index]);
        yPos += 18;
        index++;
    }

    yardimAcik[playerid] = true;
}

// Yardım menüsü kapatma
stock KapatYardimTexdraw(playerid)
{
    if(!yardimAcik[playerid]) return;

    TextDrawHideForPlayer(playerid, tdYardimBG[playerid]);
    TextDrawDestroy(tdYardimBG[playerid]);

    for(new i = 0; i < 10; i++)
    {
        if(IsValidTextDraw(tdKomutSatiri[playerid][i]))
        {
            TextDrawHideForPlayer(playerid, tdKomutSatiri[playerid][i]);
            TextDrawDestroy(tdKomutSatiri[playerid][i]);
        }
    }

    yardimAcik[playerid] = false;
}
