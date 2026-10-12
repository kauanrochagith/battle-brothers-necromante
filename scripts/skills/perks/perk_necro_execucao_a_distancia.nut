// =====================================================================
// MOD NECROMANTE - Perk: Execucao A Distancia
// Marcador: o efeito é aplicado em necro_undead_racial.nut (onTargetKilled).
// =====================================================================

this.perk_necro_execucao_a_distancia <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_execucao_a_distancia");
	}

});
