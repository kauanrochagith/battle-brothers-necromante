// =====================================================================
// MOD NECROMANTE - Perk: Fusao Rapida
// Marcador: o efeito é aplicado em necro_ossuary_fuse.nut.
// =====================================================================

this.perk_necro_fusao_rapida <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_fusao_rapida");
	}

});
