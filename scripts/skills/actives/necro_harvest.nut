// =====================================================================
// MOD NECROMANTE - Colheita da Morte (cap. 7.5)
// ---------------------------------------------------------------------
// Atinge TODOS os inimigos em campo com Veneno ou Necrose:
//   dano = soma(dano por turno x turnos restantes) x COLHEITA_MULT,
//   ignorando armadura; depois remove Veneno e Necrose.
// Não pode ser usada se nenhum inimigo tiver efeitos.
// A versão do Mago (necro_mage_harvest.nut) herda daqui com 50% de potência.
// =====================================================================

this.necro_harvest <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		this.m.ID = "actives.necro_harvest";
		this.m.Name = "Colheita da Morte";
		this.m.Description = "Detona de uma vez todo o Veneno do Cadáver e a Necrose de todos os inimigos em campo.";
		this.m.Icon = "skills/active_96.png";
		this.m.IconDisabled = "skills/active_96_sw.png";
		this.m.Overlay = "active_96";
		this.m.SoundOnUse = [
			"sounds/enemies/dlc2/giant_spider_poison_01.wav",
			"sounds/enemies/dlc2/giant_spider_poison_02.wav"
		];
		this.m.Order = this.Const.SkillOrder.NonTargeted + 4;
		this.m.IsTargeted = false;
		this.m.ActionPointCost = this.Const.Necro.Ativas.ColheitaPA;
		this.m.FatigueCost = this.Const.Necro.Ativas.ColheitaFadiga;
	}

	function getCooldownMax()
	{
		return this.Const.Necro.Ativas.ColheitaCooldown;
	}

	// Lista de { Alvo, Dano } com o dano que a Colheita causaria agora.
	function getHarvestTargets()
	{
		local util = this.getUtil();
		local user = this.getContainer().getActor();
		local ret = [];

		if (!util.isInCombat())
		{
			return ret;
		}

		foreach( faction in this.Tactical.Entities.getAllInstances() )
		{
			foreach( e in faction )
			{
				if (!util.isValidActor(e) || e.isAlliedWith(user))
				{
					continue;
				}

				local total = 0;

				foreach( id in [
					util.VenenoID,
					util.NecroseID
				] )
				{
					local eff = e.getSkills().getSkillByID(id);

					if (eff != null && !eff.isGarbage())
					{
						total = total + eff.getRemainingDamage();
					}
				}

				if (total > 0)
				{
					ret.push({
						Alvo = e,
						Dano = this.Math.round(total * this.Const.Necro.COLHEITA_MULT * this.m.Potency)
					});
				}
			}
		}

		return ret;
	}

	function getTotalHarvestDamage()
	{
		local sum = 0;

		foreach( t in this.getHarvestTargets() )
		{
			sum = sum + t.Dano;
		}

		return sum;
	}

	function isUsable()
	{
		return this.necro_active_base.isUsable() && this.getHarvestTargets().len() != 0;
	}

	function onAddTooltip( _tooltip )
	{
		local targets = this.getHarvestTargets();
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/regular_damage.png",
			text = "Multiplicador: [color=" + this.Const.UI.Color.PositiveValue + "]x" + this.Const.Necro.COLHEITA_MULT * this.m.Potency + "[/color] do dano restante, ignorando armadura"
		});

		if (this.getUtil().isInCombat())
		{
			_tooltip.push({
				id = 11,
				type = "text",
				icon = "ui/icons/health.png",
				text = "Agora: " + targets.len() + " inimigo(s), " + this.getTotalHarvestDamage() + " de dano no total"
			});
		}
	}

	function onUse( _user, _targetTile )
	{
		local util = this.getUtil();
		local targets = this.getHarvestTargets();

		foreach( t in targets )
		{
			// Remove os efeitos ANTES do dano, para não contar duas vezes.
			t.Alvo.getSkills().removeByID(util.VenenoID);
			t.Alvo.getSkills().removeByID(util.NecroseID);

			if (t.Alvo.getTile().IsVisibleForPlayer)
			{
				this.spawnIcon("status_effect_123", t.Alvo.getTile());
			}

			util.dealDirectDamage(t.Alvo, t.Dano, _user, this);
		}

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " usa Colheita da Morte em " + targets.len() + " inimigo(s)");
		}

		this.startCooldown();
		return true;
	}

});
