// =====================================================================
// MOD NECROMANTE - Formar Linha (Senhor da Legião)
// ---------------------------------------------------------------------
// Todos os mortos CORPO A CORPO a até FormarRaio tiles do Necromante
// entram em Formação por FormarDuracao turnos (necro_formation_effect):
// +FormarDefesa de Defesa, imunes a empurrão/derrubar e +bônus extra ao
// lado de outro morto em formação.
// =====================================================================

this.necro_legion_form_line <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local L = this.Const.Necro.Sub.Legiao;
		this.m.ID = "actives.necro_legion_form_line";
		this.m.Name = "Formar Linha";
		this.m.Description = "Os mortos corpo a corpo ao redor fecham fileira: escudos juntos, imunes a empurrões.";
		this.m.Icon = "skills/active_15.png";
		this.m.IconDisabled = "skills/active_15_sw.png";
		this.m.Overlay = "active_15";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_01.wav"
		];
		this.m.Order = this.Const.SkillOrder.NonTargeted + 10;
		this.m.IsTargeted = false;
		this.m.ActionPointCost = L.FormarPA;
		this.m.FatigueCost = L.FormarFadiga;
	}

	function getCooldownMax()
	{
		return this.Const.Necro.Sub.Legiao.FormarCD;
	}

	function getTargets()
	{
		local util = this.getUtil();
		local actor = this.getContainer().getActor();
		local ret = [];

		foreach( e in util.getSummonsOfMaster(actor.getID(), false) )
		{
			local t = e.getFlags().get(util.FlagTipo);

			if (t in this.Const.Necro.Tipos && !this.Const.Necro.Tipos[t].Distancia && e.getTile().getDistanceTo(actor.getTile()) <= this.Const.Necro.Sub.Legiao.FormarRaio)
			{
				ret.push(e);
			}
		}

		return ret;
	}

	function isUsable()
	{
		return this.necro_active_base.isUsable() && this.getTargets().len() != 0;
	}

	function onAddTooltip( _tooltip )
	{
		local L = this.Const.Necro.Sub.Legiao;
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/melee_defense.png",
			text = "Mortos corpo a corpo a até " + L.FormarRaio + " tiles: [color=" + this.Const.UI.Color.PositiveValue + "]+" + L.FormarDefesa + "[/color] de Defesa por " + L.FormarDuracao + " turnos, imunes a empurrão (+" + L.FormarDefesaAdjacente + " ao lado de outro em formação)"
		});
	}

	function onUse( _user, _targetTile )
	{
		local n = 0;

		foreach( e in this.getTargets() )
		{
			local f = e.getSkills().getSkillByID("effects.necro_formation");

			if (f != null)
			{
				f.refresh();
			}
			else
			{
				e.getSkills().add(this.new("scripts/skills/effects/necro_formation_effect"));
			}

			e.getSkills().update();
			n = ++n;
		}

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " ordena: formar linha! (" + n + " mortos)");
		}

		this.startCooldown();
		return true;
	}

});
