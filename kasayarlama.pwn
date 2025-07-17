#include <a_samp>
#include <zcmd> // Komutları kolayca yazmak için

CMD:kasgucu(playerid, params[])
{
    new strength;
    if (sscanf(params, "d", strength)) {
        SendClientMessage(playerid, 0xFF0000FF, "Kullanım: /kasgucu [0 - 100]");
        return 1;
    }

    if (strength < 0 || strength > 100) {
        SendClientMessage(playerid, 0xFF0000FF, "Geçersiz değer! 0 ile 100 arasında bir değer girin.");
        return 1;
    }

    SetPlayerStat(playerid, STAT_MUSCLE, strength);
    new msg[64];
    format(msg, sizeof(msg), "💪 Kas gücünüz %d olarak ayarlandı.", strength);
    SendClientMessage(playerid, 0x00FF00FF, msg);
    return 1;
}
