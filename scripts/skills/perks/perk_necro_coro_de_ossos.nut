// =====================================================================
// MOD NECROMANTE - Perk: Coro De Ossos
// Marcador: o efeito é aplicado em necro_sub_maestro.nut + necro_enemy_aura_effect.nut.
// =====================================================================

this.perk_necro_coro_de_ossos <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_coro_de_ossos");
	}

});
