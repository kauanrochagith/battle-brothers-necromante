// =====================================================================
// MOD NECROMANTE - Perk: Pandemia
// Marcador: o efeito é aplicado em necro_plague_epidemic.nut.
// =====================================================================

this.perk_necro_pandemia <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_pandemia");
	}

});
