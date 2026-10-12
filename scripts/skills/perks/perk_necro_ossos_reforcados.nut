// =====================================================================
// MOD NECROMANTE - Perk: Ossos Reforçados
// Efeito aplicado nos mortos por necro_undead_racial.nut (onUpdate / onBeforeDamageReceived).
// =====================================================================

this.perk_necro_ossos_reforcados <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_ossos_reforcados");
	}

});
