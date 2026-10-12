// =====================================================================
// MOD NECROMANTE - Perk: Postura Fantasma
// Marcador: o efeito é aplicado em necro_undead_racial.nut (onUpdate / onAnySkillUsed).
// =====================================================================

this.perk_necro_postura_fantasma <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_postura_fantasma");
	}

});
