// =====================================================================
// MOD NECROMANTE - Perk: Putrefação Redobrada
// Efeito aplicado em Const.Necro.Util.getEffectParams e na racial (penalidade de HP).
// =====================================================================

this.perk_necro_putrefacao_redobrada <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_putrefacao_redobrada");
	}

});
