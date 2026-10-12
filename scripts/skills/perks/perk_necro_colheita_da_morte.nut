// =====================================================================
// MOD NECROMANTE - Perk: Colheita da Morte
// Concede a ativa Colheita da Morte (recriada ao carregar o jogo).
// =====================================================================

this.perk_necro_colheita_da_morte <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_colheita_da_morte");
	}

	function onAdded()
	{
		if (!this.perk_necro.onAdded())
		{
			return;
		}

		this.grantActive("scripts/skills/actives/necro_harvest");
	}

	function onRemoved()
	{
		// Não remove a ativa se a subclasse a concede como inata
		// (ex.: Despertar do Mago no Lich, Marca do Comando no Maestro).
		if (!this.Const.Necro.Util.isActiveGrantedBySubclass(this.getContainer().getActor(), "actives.necro_harvest"))
		{
			this.getContainer().removeByID("actives.necro_harvest");
		}
	}

});
