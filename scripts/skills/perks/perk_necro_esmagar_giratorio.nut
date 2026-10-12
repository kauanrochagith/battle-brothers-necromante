// =====================================================================
// MOD NECROMANTE - Perk: Esmagar Giratorio
// Marcador: o efeito é aplicado em necro_abominacao.nut (setupFusion).
// =====================================================================

this.perk_necro_esmagar_giratorio <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_esmagar_giratorio");
	}

});
