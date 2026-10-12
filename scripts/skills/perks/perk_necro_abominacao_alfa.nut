// =====================================================================
// MOD NECROMANTE - Perk: Abominacao Alfa
// Marcador: o efeito é aplicado em necro_ossuary_fuse.nut / necro_abominacao.nut / racial.
// =====================================================================

this.perk_necro_abominacao_alfa <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_abominacao_alfa");
	}

});
