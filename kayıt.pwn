#include <a_samp>
#include <dini> // dini dosya işlemleri için

new bool:girisYapti[MAX_PLAYERS]; // Oyuncu giriş yaptı mı?

public OnFilterScriptInit()
{
    print(">> Giriş/Kayıt Sistemi yüklendi.");
    return 1;
}

public OnPlayerConnect(playerid)
{
    girisYapti[playerid] = false;

    new isim[MAX_PLAYER_NAME], dosya[64];
    GetPlayerName(playerid, isim, sizeof(isim));
    format(dosya, sizeof(dosya), "Kullanicilar/%s.ini", isim);

    if(dini_Exists(dosya))
    {
        SendClientMessage(playerid, 0xFFFF00FF, "[Sunucu] Hosgeldin. Lutfen /giris [sifre] komutunu kullan.");
    }
    else
    {
        SendClientMessage(playerid, 0x00FFFFAA, "[Sunucu] Hosgeldin. Hesabin yok. /kayit [sifre] yazarak kayit ol.");
    }

    TogglePlayerControllable(playerid, 0); // Giriş yapmadan hareket edemez
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    girisYapti[playerid] = false;
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    new cmd[32], param[64];
    sscanf(cmdtext, "%s %s", cmd, param);

    if(strcmp(cmd, "/kayit", true) == 0)
    {
        if(girisYapti[playerid]) return SendClientMessage(playerid, -1, "Zaten giris yaptin.");

        new isim[MAX_PLAYER_NAME], dosya[64];
        GetPlayerName(playerid, isim, sizeof(isim));
        format(dosya, sizeof(dosya), "Kullanicilar/%s.ini", isim);

        if(dini_Exists(dosya)) return SendClientMessage(playerid, -1, "Zaten kayit olmusun. /giris yaz.");

        if(strlen(param) < 3) return SendClientMessage(playerid, -1, "Kullanım: /kayit [sifre]");

        dini_Create(dosya);
        dini_Set(dosya, "Sifre", param);

        girisYapti[playerid] = true;
        TogglePlayerControllable(playerid, 1);

        SendClientMessage(playerid, 0x00FF00FF, "Kayit tamamlandi. Giris yaptin.");
        return 1;
    }

    if(strcmp(cmd, "/giris", true) == 0)
    {
        if(girisYapti[playerid]) return SendClientMessage(playerid, -1, "Zaten giris yaptin.");

        new isim[MAX_PLAYER_NAME], dosya[64];
        GetPlayerName(playerid, isim, sizeof(isim));
        format(dosya, sizeof(dosya), "Kullanicilar/%s.ini", isim);

        if(!dini_Exists(dosya)) return SendClientMessage(playerid, -1, "Kayit bulunamadi. /kayit [sifre] kullan.");

        new kayitliSifre[64];
        format(kayitliSifre, sizeof(kayitliSifre), dini_Get(dosya, "Sifre"));

        if(strcmp(param, kayitliSifre, false) == 0)
        {
            girisYapti[playerid] = true;
            TogglePlayerControllable(playerid, 1);
            SendClientMessage(playerid, 0x00FF00FF, "Giris basarili. Hosgeldin!");
        }
        else
        {
            SendClientMessage(playerid, 0xFF0000FF, "Sifre hatali!");
        }
        return 1;
    }

    return 0;
}
