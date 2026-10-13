// =====================================================================
// MOD NECROMANTE - Base de Veneno do Cadáver e Necrose (cap. 6)
// ---------------------------------------------------------------------
// Um único efeito por alvo com contador de acúmulos:
//   - cada acerto soma acúmulos (teto ACUMULO_MAX) e REINICIA a duração;
//   - no fim do turno do alvo (ou ao esperar): dano = acúmulos x dano
//     por acúmulo, ignorando armadura; a duração cai em 1;
//   - Veneno e Necrose são classes diferentes, então coexistem.
// Não é salvo no save (efeito de combate).
// =====================================================================

this.necro_dot_effect <- this.inherit("scripts/skills/skill", {
	m = {
		Stacks = 0,
		TurnsLeft = 0,
		DamagePerStack = 0.0,
		MasterID = -1,
		LastRoundApplied = -1,
		IconBrush = ""
	},
	function create()
	{
		this.m.Type = this.Const.SkillType.StatusEffect | this.Const.SkillType.DamageOverTime;
		this.m.Order = this.Const.SkillOrder.VeryLast;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
		this.m.IsSerialized = false;
	}

	function getStacks()
	{
		return this.m.Stacks;
	}

	function getTurnsLeft()
	{
		return this.m.TurnsLeft;
	}

	function getMasterID()
	{
		return this.m.MasterID;
	}

	function getName()
	{
		return this.m.Name + " (x" + this.m.Stacks + ")";
	}

	// Dano que será causado no próximo fim de turno do alvo.
	function getDamagePerTurn()
	{
		local actor = this.getContainer().getActor();
		local mult = this.Const.Necro.Util.getEffectDamageMult(actor, this.m.MasterID);
		return this.Math.round(this.m.Stacks * this.m.DamagePerStack * mult);
	}

	// Exigido pelo vanilla: a IA (ai_defend_shieldwall, ai_defend_riposte, ai_hex,
	// ai_adrenaline, ai_indomitable) chama getDamage() em todo efeito do tipo
	// DamageOverTime. Sem isto a IA dava erro e o turno travava.
	function getDamage()
	{
		return this.getDamagePerTurn();
	}

	// Dano total restante (usado pela Colheita da Morte).
	function getRemainingDamage()
	{
		return this.getDamagePerTurn() * this.m.TurnsLeft;
	}

	// Chamado por Const.Necro.Util.addStacks.
	// O dano por acúmulo fica no MAIOR valor já aplicado (ex.: um golpe com
	// Putrefação Redobrada não é "rebaixado" por um golpe comum depois).
	function addStacks( _n, _damagePerStack, _duration, _masterID )
	{
		// Teto de acúmulos do mestre (Virulência aumenta).
		this.m.Stacks = this.Math.min(this.Const.Necro.Util.getStackCap(_masterID), this.m.Stacks + _n);
		this.m.DamagePerStack = this.Math.maxf(this.m.DamagePerStack, _damagePerStack);

		// Novo acerto reinicia a duração.
		this.m.TurnsLeft = _duration;
		this.m.MasterID = _masterID;
	}

	function getTooltip()
	{
		local ret = [
			{
				id = 1,
				type = "title",
				text = this.getName()
			},
			{
				id = 2,
				type = "description",
				text = this.getDescription()
			},
			{
				id = 10,
				type = "text",
				icon = "ui/icons/health.png",
				text = "Perde [color=" + this.Const.UI.Color.NegativeValue + "]" + this.getDamagePerTurn() + "[/color] de vida no fim de cada turno, ignorando armadura"
			},
			{
				id = 11,
				type = "text",
				icon = "ui/icons/action_points.png",
				text = "Acúmulos: [color=" + this.Const.UI.Color.NegativeValue + "]" + this.m.Stacks + "/" + this.Const.Necro.Util.getStackCap(this.m.MasterID) + "[/color] | Turnos restantes: [color=" + this.Const.UI.Color.NegativeValue + "]" + this.m.TurnsLeft + "[/color]"
			}
		];
		this.onAddExtraTooltip(ret);
		return ret;
	}

	function onAddExtraTooltip( _tooltip )
	{
	}

	// O dano é atribuído ao Necromante (se vivo) para que kills por efeito deem XP a ele.
	function applyDamage()
	{
		local actor = this.getContainer().getActor();
		local damage = this.getDamagePerTurn();

		if (damage <= 0)
		{
			return;
		}

		if (!actor.isHiddenToPlayer())
		{
			this.spawnIcon(this.m.IconBrush, actor.getTile());
		}

		local master = this.Tactical.getEntityByID(this.m.MasterID);

		if (master == null || !master.isAlive())
		{
			master = null;
		}

		this.Const.Necro.Util.dealDirectDamage(actor, damage, master, this);
	}

	// O dano sai no FIM do turno do alvo (ou quando ele espera), como o
	// sangramento do vanilla. Matar o alvo no INÍCIO do turno travava o
	// combate: o jogo já tinha passado a vez para uma unidade morta.
	function onTurnEnd()
	{
		this.tick();
	}

	function onWaitTurn()
	{
		this.tick();
	}

	// Uma vez por rodada: contágio, dano e contagem da duração.
	function tick()
	{
		if (this.m.LastRoundApplied == this.Time.getRound())
		{
			return;
		}

		this.m.LastRoundApplied = this.Time.getRound();
		local actor = this.getContainer().getActor();

		if (!actor.isAlive())
		{
			return;
		}

		// Contágio antes do dano: o alvo pode morrer com o dano.
		this.spreadContagion();
		local turnsLeft = --this.m.TurnsLeft;
		this.applyDamage();

		if (turnsLeft <= 0 && !this.isGarbage() && actor.isAlive())
		{
			this.removeSelf();
		}
	}

	// -----------------------------------------------------------------
	// Perks do Mestre da Peste
	// -----------------------------------------------------------------
	function hasPerk( _id )
	{
		return this.Const.Necro.Util.hasPerkByMasterID(this.m.MasterID, _id);
	}

	// Veneno e Necrose coexistem; regras que valem para o TOTAL de acúmulos
	// rodam só em um deles ("principal" = Veneno se existir).
	function isPrimaryEffect()
	{
		local util = this.Const.Necro.Util;

		if (this.getID() == util.VenenoID)
		{
			return true;
		}

		return this.getContainer().getSkillByID(util.VenenoID) == null;
	}

	// Febre Cadavérica: -1 Iniciativa por acúmulo (total), máx. -15.
	function onUpdate( _properties )
	{
		if (this.m.MasterID < 0 || !this.isPrimaryEffect() || !this.hasPerk("perk.necro_febre_cadaverica"))
		{
			return;
		}

		local P = this.Const.Necro.Sub.Peste;
		local total = this.Const.Necro.Util.getTotalStacks(this.getContainer().getActor());
		_properties.Initiative -= this.Math.min(P.FebreMax, total * P.FebrePorAcumulo);
	}

	// Contágio: alvo com 5+ acúmulos espalha 1 acúmulo DESTE efeito por turno
	// para cada inimigo adjacente (aliado do alvo).
	function spreadContagion()
	{
		local util = this.Const.Necro.Util;

		if (!this.hasPerk("perk.necro_contagio"))
		{
			return;
		}

		local P = this.Const.Necro.Sub.Peste;
		local actor = this.getContainer().getActor();

		if (util.getTotalStacks(actor) < P.ContagioMinimo || !actor.isPlacedOnMap())
		{
			return;
		}

		foreach( e in util.getAdjacentActors(actor.getTile()) )
		{
			if (e.getID() != actor.getID() && e.isAlliedWith(actor) && !util.isSummon(e) && !util.isNecromancer(e))
			{
				util.addStacks(e, this.getID(), P.ContagioAcumulos, this.m.MasterID);
			}
		}
	}

	// Hospedeiro: inimigo que morre com 5+ acúmulos vira Putrefato do mestre.
	function onDeath( _fatalityType )
	{
		local util = this.Const.Necro.Util;

		if (this.m.MasterID < 0 || !this.isPrimaryEffect() || !this.hasPerk("perk.necro_hospedeiro"))
		{
			return;
		}

		local P = this.Const.Necro.Sub.Peste;
		local actor = this.getContainer().getActor();

		if (util.getTotalStacks(actor) < P.HospedeiroMinimo || !actor.isPlacedOnMap())
		{
			return;
		}

		local rt = util.getRuntime();
		local n = (this.m.MasterID in rt.HospedeiroContagem) ? rt.HospedeiroContagem[this.m.MasterID] : 0;

		if (n >= P.HospedeiroMax)
		{
			return;
		}

		local master = this.Tactical.getEntityByID(this.m.MasterID);

		if (master == null || !util.isValidActor(master))
		{
			return;
		}

		rt.HospedeiroContagem[this.m.MasterID] <- n + 1;

		// O corpo ainda ocupa o tile durante o onDeath: o Putrefato nasce um
		// instante depois, no tile livre mais próximo.
		this.Time.scheduleEvent(this.TimeUnit.Virtual, 200, function ( _tag )
		{
			local u = this.Const.Necro.Util;

			if (!u.isInCombat() || !u.isValidActor(_tag.Master) || u.getFreeSlots(_tag.Master.getID()) <= 0)
			{
				return;
			}

			local tiles = u.findSpawnTiles(_tag.Tile, 1, false, _tag.Master);

			if (tiles.len() != 0)
			{
				local e = u.spawnSummon(this.Const.Necro.Tipos.putrefato.Script, tiles[0], _tag.Master, _tag.Master);

				if (!e.isHiddenToPlayer())
				{
					this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(e) + " brota do corpo infectado");
				}
			}
		}.bindenv(this), {
			Master = master,
			Tile = actor.getTile()
		});
	}

});
