// =====================================================================
// MOD NECROMANTE - Perk: Campo De Batalha Antigo
// Marcador: o efeito é aplicado em necro_sub_gravedigger.nut.
// =====================================================================

this.perk_necro_campo_de_batalha_antigo <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_campo_de_batalha_antigo");
	}

});
