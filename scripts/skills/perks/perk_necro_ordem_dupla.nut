// =====================================================================
// MOD NECROMANTE - Perk: Ordem Dupla
// Marcador: o efeito é aplicado em Util.giveOrder.
// =====================================================================

this.perk_necro_ordem_dupla <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_ordem_dupla");
	}

});
