// =====================================================================
// MOD NECROMANTE - Perk: Partitura Tatica
// Marcador: o efeito é aplicado em necro_undead_racial.nut (onAnySkillUsed).
// =====================================================================

this.perk_necro_partitura_tatica <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_partitura_tatica");
	}

});
