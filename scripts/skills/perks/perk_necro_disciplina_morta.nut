// =====================================================================
// MOD NECROMANTE - Perk: Disciplina Morta
// Efeito aplicado nos mortos por necro_undead_racial.nut (onAnySkillUsed).
// =====================================================================

this.perk_necro_disciplina_morta <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_disciplina_morta");
	}

});
