// =====================================================================
// MOD NECROMANTE - Perk: Chuva De Flechas
// Marcador: o efeito é aplicado em necro_sub_shooter.nut.
// =====================================================================

this.perk_necro_chuva_de_flechas <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_chuva_de_flechas");
	}

});
