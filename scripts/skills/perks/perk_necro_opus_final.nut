// =====================================================================
// MOD NECROMANTE - Perk: Opus Final (Maestro dos Ossos)
// Concede a ativa Opus Final (recriada ao carregar o jogo).
// =====================================================================

this.perk_necro_opus_final <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_opus_final");
	}

	function onAdded()
	{
		if (!this.perk_necro.onAdded())
		{
			return;
		}

		this.grantActive("scripts/skills/actives/necro_maestro_opus");
	}

	function onRemoved()
	{
		this.getContainer().removeByID("actives.necro_maestro_opus");
	}

});
