// =====================================================================
// MOD NECROMANTE - Perk: Hospedeiro
// Marcador: o efeito é aplicado em necro_dot_effect.nut (onDeath).
// =====================================================================

this.perk_necro_hospedeiro <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_hospedeiro");
	}

});
