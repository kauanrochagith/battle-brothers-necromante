// =====================================================================
// MOD NECROMANTE - Perk: Sangue Tóxico
// Efeito aplicado em Const.Necro.Util.addStacks.
// =====================================================================

this.perk_necro_sangue_toxico <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_sangue_toxico");
	}

});
