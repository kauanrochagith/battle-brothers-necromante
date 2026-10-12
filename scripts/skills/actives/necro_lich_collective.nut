// =====================================================================
// MOD NECROMANTE - Conjuração Coletiva (Lich)
// ---------------------------------------------------------------------
// Todos os Magos fora de cooldown conjuram Erguer o Morto na hora.
// Cada Mago usa a PRÓPRIA instância (necro_mage_raise): respeita o
// cooldown e o limite de usos dele, e o limite de mortos do Lich.
// =====================================================================

this.necro_lich_collective <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local LI = this.Const.Necro.Sub.Lich;
		this.m.ID = "actives.necro_lich_collective";
		this.m.Name = "Conjuração Coletiva";
		this.m.Description = "Todos os Magos Sepulcrais prontos erguem mortos ao mesmo tempo.";
		this.m.Icon = "skills/active_176.png";
		this.m.IconDisabled = "skills/active_176_sw.png";
		this.m.Overlay = "active_176";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_03.wav"
		];
		this.m.Order = this.Const.SkillOrder.NonTargeted + 11;
		this.m.IsTargeted = false;
		this.m.ActionPointCost = LI.ColetivaPA;
		this.m.FatigueCost = LI.ColetivaFadiga;
	}

	function getCooldownMax()
	{
		return this.Const.Necro.Sub.Lich.ColetivaCD;
	}

	function getReadyMages()
	{
		local util = this.getUtil();
		local ret = [];

		foreach( e in util.getSummonsOfMaster(this.getContainer().getActor().getID(), true) )
		{
			if (!util.isMage(e))
			{
				continue;
			}

			local s = e.getSkills().getSkillByID("actives.necro_mage_raise");

			if (s != null && s.isUsable())
			{
				ret.push(s);
			}
		}

		return ret;
	}

	function isUsable()
	{
		return this.necro_active_base.isUsable() && this.getReadyMages().len() != 0;
	}

	function onAddTooltip( _tooltip )
	{
		if (this.getUtil().isInCombat())
		{
			_tooltip.push({
				id = 10,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Magos prontos: " + this.getReadyMages().len()
			});
		}
	}

	function onUse( _user, _targetTile )
	{
		local n = 0;

		foreach( s in this.getReadyMages() )
		{
			local mage = s.getContainer().getActor();

			// Revalida: o mago anterior pode ter enchido o limite.
			if (s.isUsable() && s.useForFree(mage.getTile()))
			{
				n = ++n;
			}
		}

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " rege a Conjuração Coletiva (" + n + " Magos)");
		}

		this.startCooldown();
		return n > 0;
	}

});
