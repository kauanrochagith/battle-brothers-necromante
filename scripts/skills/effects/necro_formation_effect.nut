// =====================================================================
// MOD NECROMANTE - Formação (Formar Linha, Senhor da Legião)
// ---------------------------------------------------------------------
// FormarDuracao turnos: +FormarDefesa de Defesa CaC e Dist, imune a
// empurrão/derrubar (IsImmuneToKnockBackAndGrab). Mais
// +FormarDefesaAdjacente se houver outro morto em formação ao lado.
// =====================================================================

this.necro_formation_effect <- this.inherit("scripts/skills/skill", {
	m = {
		TurnsLeft = 0
	},
	function create()
	{
		this.m.ID = "effects.necro_formation";
		this.m.Name = "Em Formação";
		this.m.Description = "Este morto fecha fileira com os outros: escudos juntos, pés plantados no chão.";
		this.m.Icon = "skills/status_effect_03.png";
		this.m.IconMini = "status_effect_03_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.VeryLast;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
		this.m.IsSerialized = false;
		this.m.TurnsLeft = this.Const.Necro.Sub.Legiao.FormarDuracao;
	}

	function refresh()
	{
		this.m.TurnsLeft = this.Const.Necro.Sub.Legiao.FormarDuracao;
	}

	function hasFormationNeighbour()
	{
		local actor = this.getContainer().getActor();

		if (!actor.isPlacedOnMap())
		{
			return false;
		}

		foreach( e in this.Const.Necro.Util.getAdjacentActors(actor.getTile()) )
		{
			if (e.getSkills().hasSkill(this.m.ID))
			{
				return true;
			}
		}

		return false;
	}

	function getTooltip()
	{
		local L = this.Const.Necro.Sub.Legiao;
		return [
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
				icon = "ui/icons/melee_defense.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + L.FormarDefesa + "[/color] de Defesa Corpo a Corpo e à Distância (+" + L.FormarDefesaAdjacente + " ao lado de outro morto em formação)"
			},
			{
				id = 11,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Imune a ser empurrado ou derrubado | Turnos restantes: " + this.m.TurnsLeft
			}
		];
	}

	function onUpdate( _properties )
	{
		local L = this.Const.Necro.Sub.Legiao;
		local bonus = L.FormarDefesa + (this.hasFormationNeighbour() ? L.FormarDefesaAdjacente : 0);
		_properties.MeleeDefense += bonus;
		_properties.RangedDefense += bonus;
		_properties.IsImmuneToKnockBackAndGrab = true;
	}

	function onTurnEnd()
	{
		if (--this.m.TurnsLeft <= 0)
		{
			this.removeSelf();
		}
	}

});
