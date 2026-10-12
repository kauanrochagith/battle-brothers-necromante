// =====================================================================
// MOD NECROMANTE - Perk: Artilharia De Ossos
// Marcador: o efeito é aplicado em necro_ossuary_fuse.nut.
// =====================================================================

this.perk_necro_artilharia_de_ossos <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_artilharia_de_ossos");
	}

});
