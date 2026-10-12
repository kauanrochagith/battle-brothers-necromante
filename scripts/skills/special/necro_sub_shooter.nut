// =====================================================================
// MOD NECROMANTE - Regras passivas ocultas: Atirador Espectral
// ---------------------------------------------------------------------
// Chuva de Flechas: a cada ChuvaIntervalo turnos do Atirador, os
// arqueiros disparam ChuvaFlechas flechas numa área de raio ChuvaRaio em
// volta do ponto com mais inimigos. Cada flecha rola acerto com a Hab.
// Dist. de um arqueiro sorteado contra a Def. Dist. do alvo.
// =====================================================================

this.necro_sub_shooter <- this.inherit("scripts/skills/special/necro_sub_base", {
	m = {},
	function create()
	{
		this.necro_sub_base.create();
		this.m.ID = "actives.necro_sub_shooter";
	}

	function onOwnTurn()
	{
		if (!this.hasPerk("perk.necro_chuva_de_flechas"))
		{
			return;
		}

		local A = this.Const.Necro.Sub.Atirador;
		local util = this.getUtil();
		local actor = this.getActor();
		local id = actor.getID();
		local rt = util.getRuntime();
		rt.ChuvaContador[id] <- ((id in rt.ChuvaContador) ? rt.ChuvaContador[id] : 0) + 1;

		if (rt.ChuvaContador[id] < A.ChuvaIntervalo)
		{
			return;
		}

		local archers = [];

		foreach( e in util.getSummonsOfMaster(id, false) )
		{
			local t = e.getFlags().get(util.FlagTipo);

			if (t == "arqueiro" || t == "cacador" || t == "acolito")
			{
				archers.push(e);
			}
		}

		local enemies = util.getEnemiesOf(actor);

		if (archers.len() == 0 || enemies.len() == 0)
		{
			return;
		}

		rt.ChuvaContador[id] = 0;

		// Centro = inimigo com mais inimigos a até ChuvaRaio.
		local center = null;
		local best = -1;

		foreach( e in enemies )
		{
			local n = 0;

			foreach( o in enemies )
			{
				if (o.getTile().getDistanceTo(e.getTile()) <= A.ChuvaRaio)
				{
					n = ++n;
				}
			}

			if (n > best)
			{
				best = n;
				center = e.getTile();
			}
		}

		local alvos = [];

		foreach( e in enemies )
		{
			if (e.getTile().getDistanceTo(center) <= A.ChuvaRaio)
			{
				alvos.push(e);
			}
		}

		if (!actor.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log("Os arqueiros de " + this.Const.UI.getColorizedEntityName(actor) + " soltam uma chuva de flechas");
		}

		for( local i = 0; i < A.ChuvaFlechas; i = ++i )
		{
			local alvo = alvos[this.Math.rand(0, alvos.len() - 1)];

			if (!util.isValidActor(alvo))
			{
				continue;
			}

			local shooter = archers[this.Math.rand(0, archers.len() - 1)];
			local chance = this.Math.max(5, this.Math.min(95, shooter.getCurrentProperties().getRangedSkill() - alvo.getCurrentProperties().getRangedDefense()));

			if (this.Math.rand(1, 100) <= chance)
			{
				util.dealPhysicalDamage(alvo, this.Math.rand(A.ChuvaDanoMin, A.ChuvaDanoMax), actor, this);
			}
		}
	}

});
