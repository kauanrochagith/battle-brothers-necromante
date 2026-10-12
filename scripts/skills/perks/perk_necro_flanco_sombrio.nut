// =====================================================================
// MOD NECROMANTE - Perk: Flanco Sombrio
// Marcador: o efeito é aplicado em necro_undead_racial.nut (onAnySkillUsed).
// =====================================================================

this.perk_necro_flanco_sombrio <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_flanco_sombrio");
	}

});
