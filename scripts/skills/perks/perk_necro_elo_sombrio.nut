// =====================================================================
// MOD NECROMANTE - Perk: Elo Sombrio
// Efeito aplicado nos mortos por necro_undead_racial.nut (onDamageReceived).
// =====================================================================

this.perk_necro_elo_sombrio <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_elo_sombrio");
	}

});
