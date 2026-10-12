// =====================================================================
// MOD NECROMANTE - Perk: Munição Profana
// Efeito aplicado em Const.Necro.Util.applyOnHit.
// =====================================================================

this.perk_necro_municao_profana <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_municao_profana");
	}

});
