// =====================================================================
// MOD NECROMANTE - Regras passivas ocultas: Coveiro
// (vigias de cadáver e Campo de Batalha Antigo)
// =====================================================================

this.necro_sub_gravedigger <- this.inherit("scripts/skills/special/necro_sub_base", {
	m = {},
	function create()
	{
		this.necro_sub_base.create();
		this.m.ID = "actives.necro_sub_gravedigger";
	}

	// Todo ator que não é morto nosso ganha o vigia que registra o cadáver
	// (inimigos, mercenários e terceiros: "de qualquer lado").
	function onRound()
	{
		local util = this.getUtil();
		util.attachToAll("scripts/skills/effects/necro_corpse_watcher_effect", "effects.necro_corpse_watcher", function ( _e )
		{
			return !util.isSummon(_e);
		});
	}

	// Campo de Batalha Antigo: Fraturados no primeiro turno do combate.
	function onOwnTurn()
	{
		if (!this.hasPerk("perk.necro_campo_de_batalha_antigo"))
		{
			return;
		}

		local util = this.getUtil();
		local actor = this.getActor();
		local rt = util.getRuntime();

		if (actor.getID() in rt.CampoAntigoFeito)
		{
			return;
		}

		rt.CampoAntigoFeito[actor.getID()] <- true;

		for( local i = 0; i < this.Const.Necro.Sub.Coveiro.CampoAntigoQuantidade; i = ++i )
		{
			util.spawnFracturedNear("guerreiro", actor.getTile(), actor, actor);
		}
	}

});
