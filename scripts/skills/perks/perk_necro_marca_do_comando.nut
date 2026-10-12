// =====================================================================
// MOD NECROMANTE - Perk: Marca do Comando
// Concede a ativa Marca do Comando (recriada ao carregar o jogo).
// =====================================================================

this.perk_necro_marca_do_comando <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_marca_do_comando");
	}

	function onAdded()
	{
		if (!this.perk_necro.onAdded())
		{
			return;
		}

		this.grantActive("scripts/skills/actives/necro_mark");
	}

	function onRemoved()
	{
		// Não remove a ativa se a subclasse a concede como inata
		// (ex.: Despertar do Mago no Lich, Marca do Comando no Maestro).
		if (!this.Const.Necro.Util.isActiveGrantedBySubclass(this.getContainer().getActor(), "actives.necro_mark"))
		{
			this.getContainer().removeByID("actives.necro_mark");
		}
	}

});
