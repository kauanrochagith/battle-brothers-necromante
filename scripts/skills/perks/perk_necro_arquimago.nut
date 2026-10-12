// =====================================================================
// MOD NECROMANTE - Perk: Arquimago
// Marcador: o efeito é aplicado em necro_lich_ray.nut.
// =====================================================================

this.perk_necro_arquimago <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_arquimago");
	}

});
