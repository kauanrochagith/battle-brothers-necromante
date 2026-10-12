// =====================================================================
// MOD NECROMANTE - Perk: Cadencia Perfeita
// Marcador: o efeito é aplicado em necro_maestro_order.nut.
// =====================================================================

this.perk_necro_cadencia_perfeita <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_cadencia_perfeita");
	}

});
