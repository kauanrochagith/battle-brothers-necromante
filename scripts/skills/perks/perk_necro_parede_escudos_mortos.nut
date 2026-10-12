// =====================================================================
// MOD NECROMANTE - Perk: Parede Escudos Mortos
// Marcador: o efeito é aplicado em necro_undead_racial.nut (updateLegion).
// =====================================================================

this.perk_necro_parede_escudos_mortos <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_parede_escudos_mortos");
	}

});
