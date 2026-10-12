// =====================================================================
// MOD NECROMANTE - Perk: Coveiro Eficiente
// Marcador: o efeito é aplicado em necro_grave_raise.nut.
// =====================================================================

this.perk_necro_coveiro_eficiente <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_coveiro_eficiente");
	}

});
