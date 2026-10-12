// =====================================================================
// MOD NECROMANTE - Despertar do Mago (cap. 7.3)
// ---------------------------------------------------------------------
// Invoca 1 Mago Sepulcral atrás da linha de frente (tile mais longe dos
// inimigos no raio de spawn). Máx. de magos = MaxMagos da subclasse (só o
// Lich tem magos). Ativa inata do Lich, concedida no Juramento (antes era o
// perk "Despertar do Mago"). Magos não têm esta habilidade (sem recursão).
// =====================================================================

this.necro_awaken_mage <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		this.m.ID = "actives.necro_awaken_mage";
		this.m.Name = "Despertar do Mago";
		this.m.Description = "Desperta um Mago Sepulcral atrás da linha de frente. O Mago ergue mortos sozinho, com cooldown próprio.";
		this.m.Icon = "skills/active_176.png";
		this.m.IconDisabled = "skills/active_176_sw.png";
		this.m.Overlay = "active_176";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_01.wav",
			"sounds/enemies/necromancer_02.wav",
			"sounds/enemies/necromancer_03.wav"
		];
		this.m.Order = this.Const.SkillOrder.NonTargeted + 3;
		this.m.IsTargeted = false;
		this.m.ActionPointCost = this.Const.Necro.Ativas.MagoPA;
		this.m.FatigueCost = this.Const.Necro.Ativas.MagoFadiga;
	}

	function getCooldownMax()
	{
		return this.Const.Necro.Ativas.MagoCooldown;
	}

	function isUsable()
	{
		if (!this.necro_active_base.isUsable())
		{
			return false;
		}

		// Limite de magos da subclasse e, no Lich, uma vaga livre no limite de mortos.
		local id = this.getContainer().getActor().getID();
		local util = this.getUtil();
		local info = util.getSubclassInfo(id);

		if (util.countMages(id) >= util.getMaxMages(id))
		{
			return false;
		}

		return info == null || !info.MagosContamNoLimite || util.getFreeSlots(id) > 0;
	}

	function onAddTooltip( _tooltip )
	{
		if (this.getUtil().isInCombat())
		{
			_tooltip.push({
				id = 10,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Magos ativos: " + this.getUtil().countMages(this.getContainer().getActor().getID()) + "/" + this.getUtil().getMaxMages(this.getContainer().getActor().getID())
			});
		}

		_tooltip.push({
			id = 11,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Cada Mago ergue mortos até " + this.Const.Necro.MAGO_MAX_INVOCACOES_POR_COMBATE + " vezes por combate, com " + this.Const.Necro.COOLDOWN_MAGO_MULT + "x o cooldown de cada tipo"
		});
	}

	function onUse( _user, _targetTile )
	{
		local util = this.getUtil();
		util.cachePerks(_user);
		local tiles = util.findSpawnTiles(_user.getTile(), 1, true, _user);

		if (tiles.len() == 0)
		{
			return false;
		}

		util.spawnSummon(this.Const.Necro.Mago.Script, tiles[0], _user, _user);

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " desperta um " + this.Const.Necro.Mago.Nome);
		}

		this.startCooldown();
		return true;
	}

});
