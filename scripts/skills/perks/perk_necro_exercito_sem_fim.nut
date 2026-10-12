// =====================================================================
// MOD NECROMANTE - Perk: Exército Sem Fim
// Efeito aplicado nos mortos por necro_undead_racial.nut (onDeath).
// =====================================================================

this.perk_necro_exercito_sem_fim <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_exercito_sem_fim");
	}

});
