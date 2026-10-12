// =====================================================================
// MOD NECROMANTE - Colheita da Morte do Mago (Eco do Mago, cap. 11)
// ---------------------------------------------------------------------
// 50% de potência, cooldown próprio. A IA só usa quando o dano total
// somado passa de Const.Necro.Ativas.MagoColheitaDanoMinimo.
// =====================================================================

this.necro_mage_harvest <- this.inherit("scripts/skills/actives/necro_harvest", {
	m = {},
	function create()
	{
		this.necro_harvest.create();
		this.m.ID = "actives.necro_mage_harvest";
		this.m.Name = "Colheita da Morte (Mago)";
		this.m.Potency = this.Const.Necro.Perks.ECO_POTENCIA;
	}

	function isUsable()
	{
		return this.necro_harvest.isUsable() && this.getTotalHarvestDamage() >= this.Const.Necro.Ativas.MagoColheitaDanoMinimo;
	}

});
