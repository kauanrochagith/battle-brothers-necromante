// =====================================================================
// MOD NECROMANTE - Perk: Legiao Incontavel
// Marcador: o efeito é aplicado em Util.getMaxSummons / necro_raise_dead.nut.
// =====================================================================

this.perk_necro_legiao_incontavel <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_legiao_incontavel");
	}

});
