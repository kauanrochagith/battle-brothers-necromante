// =====================================================================
// MOD NECROMANTE - Perk: Febre Cadaverica
// Marcador: o efeito é aplicado em necro_dot_effect.nut (onUpdate).
// =====================================================================

this.perk_necro_febre_cadaverica <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_febre_cadaverica");
	}

});
