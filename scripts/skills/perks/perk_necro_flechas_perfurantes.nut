// =====================================================================
// MOD NECROMANTE - Perk: Flechas Perfurantes
// Marcador: o efeito é aplicado em necro_undead_racial.nut (onAnySkillUsed).
// =====================================================================

this.perk_necro_flechas_perfurantes <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_flechas_perfurantes");
	}

});
