// =====================================================================
// MOD NECROMANTE - Perk: Baixas Aceitaveis
// Marcador: o efeito é aplicado em necro_undead_racial.nut (onDeath) + necro_baixas_effect.nut.
// =====================================================================

this.perk_necro_baixas_aceitaveis <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_baixas_aceitaveis");
	}

});
