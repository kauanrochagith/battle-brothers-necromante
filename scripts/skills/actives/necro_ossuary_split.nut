// =====================================================================
// MOD NECROMANTE - Dividir Abominação (Ossário)
// ---------------------------------------------------------------------
// Separa uma Abominação (ou Torre) em N Guerreiros Ossudos, N = quantos
// esqueletos foram fundidos nela. Cada um nasce com a mesma porcentagem
// de vida que a Abominação tinha. A Abominação é consumida sem gatilhos
// (não dispara Ressurgir dos Ossos). Spawna só o que couber no limite.
// =====================================================================

this.necro_ossuary_split <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local OS = this.Const.Necro.Sub.Ossario;
		this.m.ID = "actives.necro_ossuary_split";
		this.m.Name = "Dividir Abominação";
		this.m.Description = "Desfaz uma Abominação de Ossos de volta nos esqueletos que a formaram.";
		this.m.Icon = "skills/active_178.png";
		this.m.IconDisabled = "skills/active_178_sw.png";
		this.m.Overlay = "active_178";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_02.wav"
		];
		this.m.Order = this.Const.SkillOrder.UtilityTargeted + 11;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = true;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = false;
		this.m.ActionPointCost = OS.DividirPA;
		this.m.FatigueCost = OS.DividirFadiga;
		this.m.MinRange = 0;
		this.m.MaxRange = 10;
		this.m.MaxLevelDifference = 4;
	}

	function getCooldownMax()
	{
		return this.Const.Necro.Sub.Ossario.DividirCD;
	}

	function isBig( _e )
	{
		local util = this.getUtil();

		if (!util.isValidActor(_e) || !util.isSummon(_e) || _e.getFlags().getAsInt(util.FlagMestre) != this.getContainer().getActor().getID())
		{
			return false;
		}

		local t = _e.getFlags().get(util.FlagTipo);
		return t == "abominacao" || t == "torre";
	}

	function onAddTooltip( _tooltip )
	{
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Vira de novo os esqueletos fundidos, com a mesma porcentagem de vida"
		});
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		return _targetTile.IsOccupiedByActor && this.isBig(_targetTile.getEntity());
	}

	function onUse( _user, _targetTile )
	{
		local util = this.getUtil();
		local big = _targetTile.getEntity();
		local n = this.Math.max(1, big.getFlags().getAsInt("necro_fundidos"));
		local tipo = big.getFlags().get(util.FlagTipo) == "torre" ? "arqueiro" : "guerreiro";
		local hpPct = big.getHitpoints().tofloat() / this.Math.max(1, big.getHitpointsMax());
		local tile = big.getTile();
		util.consumeSilently(big);
		util.cachePerks(_user);
		local t = this.Const.Necro.Tipos[tipo];
		n = this.Math.min(n, util.getFreeSlots(_user.getID()));
		local tiles = [
			tile
		];

		foreach( x in util.findSpawnTiles(tile, n - 1, t.Distancia, _user) )
		{
			tiles.push(x);
		}

		local count = 0;

		foreach( x in tiles )
		{
			if (count >= n || !x.IsEmpty)
			{
				continue;
			}

			local e = util.spawnSummon(t.Script, x, _user, _user);
			e.setHitpoints(this.Math.max(1, this.Math.round(e.getHitpointsMax() * hpPct)));
			e.setSkipTurn(false);
			count = ++count;
		}

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " divide a Abominação em " + count + " esqueletos");
		}

		_user.getSkills().update();
		this.startCooldown();
		return true;
	}

});
