// =====================================================================
// MOD NECROMANTE - Perk: Mestre da Necromancia
// Efeito aplicado em Const.Necro.Util (getEffectParams / canReceiveEffect).
// =====================================================================

this.perk_necro_mestre_da_necromancia <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_mestre_da_necromancia");
	}

});
