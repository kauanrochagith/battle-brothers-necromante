// =====================================================================
// MOD NECROMANTE - Perk: Voz do Necromante
// Efeito aplicado nos mortos por necro_undead_racial.nut (onUpdate).
// =====================================================================

this.perk_necro_voz_do_necromante <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_voz_do_necromante");
	}

});
