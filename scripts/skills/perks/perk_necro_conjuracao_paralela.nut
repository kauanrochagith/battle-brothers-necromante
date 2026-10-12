// =====================================================================
// MOD NECROMANTE - Perk: Conjuracao Paralela
// Marcador: o efeito é aplicado em necro_mage_raise.nut (getTypeCooldown).
// =====================================================================

this.perk_necro_conjuracao_paralela <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_conjuracao_paralela");
	}

});
