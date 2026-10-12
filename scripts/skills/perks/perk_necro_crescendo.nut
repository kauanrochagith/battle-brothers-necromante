// =====================================================================
// MOD NECROMANTE - Perk: Crescendo
// Marcador: o efeito é aplicado em Util.tickOrders / Util.getCrescendoMult.
// =====================================================================

this.perk_necro_crescendo <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_crescendo");
	}

});
