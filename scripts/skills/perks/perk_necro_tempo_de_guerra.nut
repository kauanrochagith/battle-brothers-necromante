// =====================================================================
// MOD NECROMANTE - Perk: Tempo de Guerra
// Efeito aplicado em necro_raise_dead.nut (getTypeCooldown).
// =====================================================================

this.perk_necro_tempo_de_guerra <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_tempo_de_guerra");
	}

});
