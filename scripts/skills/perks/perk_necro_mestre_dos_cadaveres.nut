// =====================================================================
// MOD NECROMANTE - Perk: Mestre Dos Cadaveres
// Marcador: o efeito é aplicado em Util.getReanimateScale.
// =====================================================================

this.perk_necro_mestre_dos_cadaveres <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_mestre_dos_cadaveres");
	}

});
