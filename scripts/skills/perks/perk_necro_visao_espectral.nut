// =====================================================================
// MOD NECROMANTE - Perk: Visao Espectral
// Marcador: o efeito é aplicado em necro_undead_racial.nut (onUpdate).
// =====================================================================

this.perk_necro_visao_espectral <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_visao_espectral");
	}

});
