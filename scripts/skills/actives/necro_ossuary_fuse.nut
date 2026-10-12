// =====================================================================
// MOD NECROMANTE - Fusão de Ossos (Ossário)
// ---------------------------------------------------------------------
// VIABILIDADE (spec, etapa E): a fusão é feita com o mesmo mecanismo do
// colapso dos mortos, que já roda no jogo:
//   1) escolhe 1 esqueleto aliado (Guerreiro Ossudo ou Arqueiro);
//   2) junta os FusaoMaxExtras esqueletos mais próximos dele a até
//      FusaoRaio tiles (mínimo FusaoMinimoTotal no total; Fusão Rápida: 2);
//   3) consome todos com Util.consumeSilently (killSilently com
//      Colapsando = true: NÃO disparam Exército Sem Fim nem contam como
//      kill para XP, Essência ou Pacto);
//   4) spawna a Abominação (ou a Torre de Ossos, se a maioria for de
//      arqueiros e houver Artilharia de Ossos) no tile do escolhido, com HP
//      pela fórmula e a vida proporcional à média dos consumidos.
// Limites: máx. OSSARIO_MAX_ABOMINACOES (Abominações + Torres) e o peso 5
// precisa caber no limite depois de liberar as vagas dos consumidos.
// =====================================================================

this.necro_ossuary_fuse <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local OS = this.Const.Necro.Sub.Ossario;
		this.m.ID = "actives.necro_ossuary_fuse";
		this.m.Name = "Fusão de Ossos";
		this.m.Description = "Funde um esqueleto e os mais próximos numa Abominação de Ossos.";
		this.m.Icon = "skills/active_177.png";
		this.m.IconDisabled = "skills/active_177_sw.png";
		this.m.Overlay = "active_177";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_03.wav"
		];
		this.m.Order = this.Const.SkillOrder.UtilityTargeted + 10;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = true;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = false;
		this.m.ActionPointCost = OS.FusaoPA;
		this.m.FatigueCost = OS.FusaoFadiga;
		this.m.MinRange = 0;
		this.m.MaxRange = 10;
		this.m.MaxLevelDifference = 4;
	}

	function hasPerk( _id )
	{
		return this.getUtil().hasPerkByMasterID(this.getContainer().getActor().getID(), _id);
	}

	function getCooldownMax()
	{
		local OS = this.Const.Necro.Sub.Ossario;
		return this.hasPerk("perk.necro_fusao_rapida") ? this.Math.max(1, OS.FusaoCD - OS.RapidaCD) : OS.FusaoCD;
	}

	function getMinTotal()
	{
		local OS = this.Const.Necro.Sub.Ossario;
		return this.hasPerk("perk.necro_fusao_rapida") ? OS.RapidaMinimoTotal : OS.FusaoMinimoTotal;
	}

	function isSkeleton( _e, _masterID )
	{
		local util = this.getUtil();

		if (!util.isValidActor(_e) || !util.isSummon(_e) || util.isMage(_e) || _e.getFlags().getAsInt(util.FlagMestre) != _masterID)
		{
			return false;
		}

		local t = _e.getFlags().get(util.FlagTipo);
		return t == "guerreiro" || t == "arqueiro";
	}

	function countBig( _masterID )
	{
		return this.getUtil().countType(_masterID, "abominacao") + this.getUtil().countType(_masterID, "torre");
	}

	// Lista do grupo que seria fundido a partir do escolhido (escolhido primeiro).
	function getGroup( _chosen )
	{
		local OS = this.Const.Necro.Sub.Ossario;
		local util = this.getUtil();
		local masterID = this.getContainer().getActor().getID();
		local others = [];

		foreach( e in util.getSummonsOfMaster(masterID, false) )
		{
			if (e.getID() == _chosen.getID() || !this.isSkeleton(e, masterID))
			{
				continue;
			}

			local d = e.getTile().getDistanceTo(_chosen.getTile());

			if (d <= OS.FusaoRaio)
			{
				others.push({
					E = e,
					D = d
				});
			}
		}

		others.sort(function ( _a, _b )
		{
			return _a.D < _b.D ? -1 : (_a.D > _b.D ? 1 : 0);
		});
		local ret = [
			_chosen
		];

		foreach( o in others )
		{
			if (ret.len() >= 1 + OS.FusaoMaxExtras)
			{
				break;
			}

			ret.push(o.E);
		}

		return ret;
	}

	function isUsable()
	{
		local id = this.getContainer().getActor().getID();
		return this.necro_active_base.isUsable() && this.countBig(id) < this.Const.Necro.OSSARIO_MAX_ABOMINACOES;
	}

	function onAddTooltip( _tooltip )
	{
		local OS = this.Const.Necro.Sub.Ossario;
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Funde " + this.getMinTotal() + " a " + (1 + OS.FusaoMaxExtras) + " esqueletos (a até " + OS.FusaoRaio + " tiles do escolhido). Vida = " + OS.AbominacaoHPBase + " + " + OS.AbominacaoHPPorFundido + " por esqueleto"
		});

		if (this.getUtil().isInCombat())
		{
			local id = this.getContainer().getActor().getID();
			_tooltip.push({
				id = 11,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Abominações/Torres: " + this.countBig(id) + "/" + this.Const.Necro.OSSARIO_MAX_ABOMINACOES + " (cada uma ocupa " + this.Const.Necro.OSSARIO_PESO_ABOMINACAO + " vagas)"
			});
		}
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!_targetTile.IsOccupiedByActor)
		{
			return false;
		}

		local chosen = _targetTile.getEntity();
		local masterID = this.getContainer().getActor().getID();

		if (!this.isSkeleton(chosen, masterID))
		{
			return false;
		}

		local group = this.getGroup(chosen);

		if (group.len() < this.getMinTotal())
		{
			return false;
		}

		// O peso da nova unidade precisa caber depois de liberar as vagas do grupo.
		local util = this.getUtil();
		local livre = util.getMaxSummons(masterID) - util.countSummonWeight(masterID) + group.len();
		return livre >= this.Const.Necro.OSSARIO_PESO_ABOMINACAO;
	}

	function onUse( _user, _targetTile )
	{
		local util = this.getUtil();
		local chosen = _targetTile.getEntity();
		local group = this.getGroup(chosen);
		local tile = chosen.getTile();
		local ranged = 0;
		local hpPct = 0.0;

		foreach( e in group )
		{
			if (e.getFlags().get(util.FlagTipo) == "arqueiro")
			{
				ranged = ++ranged;
			}

			hpPct = hpPct + e.getHitpoints().tofloat() / this.Math.max(1, e.getHitpointsMax());
		}

		hpPct = hpPct / group.len();
		local tipo = ranged * 2 > group.len() && this.hasPerk("perk.necro_artilharia_de_ossos") ? "torre" : "abominacao";
		local owner = this.Tactical.getEntityByID(chosen.getFlags().getAsInt(util.FlagDono));

		// Consome sem gatilhos de morte.
		foreach( e in group )
		{
			util.consumeSilently(e);
		}

		util.cachePerks(_user);
		local e = util.spawnSummon(this.Const.Necro.Tipos[tipo].Script, tile, _user, util.isValidActor(owner) ? owner : _user);

		// Abominação Alfa: a primeira Abominação (se ainda não houver Alfa).
		local alfa = false;

		if (tipo == "abominacao" && this.hasPerk("perk.necro_abominacao_alfa"))
		{
			alfa = true;

			foreach( o in util.getSummonsOfMaster(_user.getID(), false) )
			{
				if (o.getID() != e.getID() && o.getFlags().has("necro_alfa"))
				{
					alfa = false;
				}
			}
		}

		e.setupFusion(group.len(), hpPct, alfa);
		e.setSkipTurn(false);

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " funde " + group.len() + " esqueletos: " + this.Const.UI.getColorizedEntityName(e));
		}

		_user.getSkills().update();
		this.startCooldown();
		return true;
	}

});
