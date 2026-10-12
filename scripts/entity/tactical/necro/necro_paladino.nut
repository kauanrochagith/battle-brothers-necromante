// =====================================================================
// MOD NECROMANTE - Paladino Sepulcral: arma de uma mão + escudo, armadura uma faixa acima. Veneno; aura Égide Funesta (ver necro_undead_racial.nut). (cap. 8)
// Atributos em Const.Necro.Tipos.paladino (necro_constants.nut).
// =====================================================================

this.necro_paladino <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "paladino";
		this.m.Papel = "pesado";   // equipamento por nível (Const.Necro.Equipamento)
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_paladin_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonHeavy;
		this.necro_undead.create();
	}

});
