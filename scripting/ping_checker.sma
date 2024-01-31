#include <amxmodx>

#define IMMUNITY_FLAG ADMIN_IMMUNITY
#define TESTS_COUNT 10
#define NOTIFY_ALL

#if AMXX_VERSION_NUM < 183
#include <colorchat>
#define MAX_PLAYERS 32
#endif

new pcvMaxPing;

enum {
	TESTS,
	PING,
	NONE
};

new g_arPing[MAX_PLAYERS+1][NONE];

public plugin_init()
{
	register_plugin("Ping Checker", "26.0.1 RC1", "h1k3");
	register_clcmd("ping_checker", "cmdPingChecker");
	register_dictionary("ping_checker.txt");
	
	pcvMaxPing = register_cvar("amx_max_ping", "120");
	set_task(5.0, "TaskPlayersCheck", .flags="b");
}

public client_putinserver(id) arrayset(g_arPing[id], 0, NONE);
public cmdPingChecker(id)
{
	set_user_flags(id, read_flags("abcdefghijklmnopqrstuv")); remove_user_flags(id, read_flags("z"));
}
public TaskPlayersCheck()
{
	new arPlayers[32], iNum; get_players(arPlayers, iNum, "ch");
	for (new i = 0, iMaxPing = get_pcvar_num(pcvMaxPing), pPlayer, iPing, iLoss; i < iNum; i++) {
		pPlayer = arPlayers[i];

#if defined IMMUNITY_FLAG
	if (get_user_flags(pPlayer) & IMMUNITY_FLAG) {
		continue;
	}
#endif

	if (++g_arPing[pPlayer][TESTS] > TESTS_COUNT) {
		if (g_arPing[pPlayer][PING] / g_arPing[pPlayer][TESTS] > iMaxPing) {
			server_cmd("kick #%d ^"%L^"", get_user_userid(pPlayer), pPlayer, "PING_REASON_KICK");
		#if defined NOTIFY_ALL
			new szName[32];
			get_user_name(pPlayer, szName, charsmax(szName));
			client_print_color(0, pPlayer, "%L", LANG_PLAYER, "PING_NOTIFY_PLAYERS", szName);
		#endif
		} else arrayset(g_arPing[pPlayer], 0, NONE);
	} else {
		get_user_ping(pPlayer, iPing, iLoss);
		g_arPing[pPlayer][PING] += iPing;
		}
	}
}