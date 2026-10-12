// =====================================================================
// MOD NECROMANTE - Perk: Despertar do Mago
// Concede a ativa Despertar do Mago (recriada ao carregar o jogo).
// =====================================================================

this.perk_necro_despertar_do_mago <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_despertar_do_mago");
	}

	function onAdded()
	{
		if (!this.perk_necro.onAdded())
		{
			return;
		}

		this.grantActive("scripts/skills/actives/necro_awaken_mage");
	}

	function onRemoved()
	{
		// Não remove a ativa se a subclasse a concede como inata
		// (ex.: Despertar do Mago no Lich, Marca do Comando no Maestro).
		if (!this.Const.Necro.Util.isActiveGrantedBySubclass(this.getContainer().getActor(), "actives.necro_awaken_mage"))
		{
			this.getContainer().removeByID("actives.necro_awaken_mage");
		}
	}

});
