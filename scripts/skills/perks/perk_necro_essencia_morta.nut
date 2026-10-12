// =====================================================================
// MOD NECROMANTE - Perk: Essência Morta
// Cargas guardadas por combate em Const.Necro.Util (addEssence/getEssence).
// =====================================================================

this.perk_necro_essencia_morta <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_essencia_morta");
	}

});
