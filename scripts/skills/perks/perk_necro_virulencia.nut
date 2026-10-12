// =====================================================================
// MOD NECROMANTE - Perk: Virulencia
// Marcador: o efeito é aplicado em Util.getStackCap / Util.getUndeadEffectMult.
// =====================================================================

this.perk_necro_virulencia <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_virulencia");
	}

});
