// =====================================================================
// MOD NECROMANTE - Perk: Necrófago (Coveiro)
// Concede a ativa Necrófago (recriada ao carregar o jogo).
// =====================================================================

this.perk_necro_necrofago <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_necrofago");
	}

	function onAdded()
	{
		if (!this.perk_necro.onAdded())
		{
			return;
		}

		this.grantActive("scripts/skills/actives/necro_grave_devour");
	}

	function onRemoved()
	{
		this.getContainer().removeByID("actives.necro_grave_devour");
	}

});
