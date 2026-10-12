// =====================================================================
// MOD NECROMANTE - Perk: Batuta Ossea
// Marcador: o efeito é aplicado em Util.getOrderDuration.
// =====================================================================

this.perk_necro_batuta_ossea <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_batuta_ossea");
	}

});
