// =====================================================================
// MOD NECROMANTE - Perk: Estandarte Osseo
// Marcador: o efeito é aplicado em Util.raiseGroup / Util.updateBanner / necro_undead_racial.nut.
// =====================================================================

this.perk_necro_estandarte_osseo <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_estandarte_osseo");
	}

});
