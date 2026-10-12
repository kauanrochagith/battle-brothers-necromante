// =====================================================================
// MOD NECROMANTE - Perk: Alcance Independente (pedido B, camada 4)
// ---------------------------------------------------------------------
// +1 de alcance em TODAS as habilidades de ataque do Necromante e dos
// mortos, qualquer que seja a arma. Corpo a corpo passa a alcançar 2 tiles
// (como armas de haste).
//   - No Necromante: aplicado aqui, em onAfterUpdate.
//   - Nos mortos: aplicado por necro_undead_racial.nut.
// O alcance original fica guardado em cada habilidade (m.NecroBaseMaxRange),
// então trocar de arma ou atualizar várias vezes nunca acumula bônus.
// =====================================================================

this.perk_necro_alcance_independente <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_alcance_independente");
	}

	function onAfterUpdate( _properties )
	{
		this.Const.Necro.Util.applyRangeBonus(this.getContainer().getActor(), 0, this.Const.Necro.Perks.ALCANCE_INDEPENDENTE);
	}

});
