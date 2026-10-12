// =====================================================================
// MOD NECROMANTE - Perk: Sem Descanso
// Marcador: o efeito é aplicado em necro_reanimado.nut / necro_undead_racial.nut (onDeath).
// =====================================================================

this.perk_necro_sem_descanso <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_sem_descanso");
	}

});
