#include <a_samp>
#include <zcmd> // Komut sistemi için gerekli

public OnFilterScriptInit()
{
    print("[FS] Mclerson Plaka Sistemi Aktif!");

    // Sunucu açıldığında mevcut araçlara plaka ver
    for (new i = 1; i < MAX_VEHICLES; i++)
    {
        if (GetVehicleModel(i) != 0)
        {
            SetVehicleNumberPlate(i, "Mclerson");
        }
    }
    return 1;
}

public OnVehicleSpawn(vehicleid)
{
    SetVehicleNumberPlate(vehicleid, "Mclerson");
    return 1;
}

CMD:plaka(playerid, params[])
{
    if (!IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, 0xFF0000FF, "Araçta olmalısın!");

    new text[32];
    if (sscanf(params, "s[32]", text)) // girdi yoksa
        return SendClientMessage(playerid, 0xFFFF00FF, "Kullanım: /plaka [plaka_ismi]");

    new vehicleid = GetPlayerVehicleID(playerid);

    if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return SendClientMessage(playerid, 0xFF0000FF, "Sadece sürücü plaka değiştirebilir!");

    SetVehicleNumberPlate(vehicleid, text);

    new msg[64];
    format(msg, sizeof msg, "Plaka başarıyla '%s' olarak ayarlandı!", text);
    SendClientMessage(playerid, 0x00FF00FF, msg);

    return 1;
}
