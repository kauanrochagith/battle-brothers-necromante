// =====================================================================
// MOD NECROMANTE - Sentinela de Osso: arma de uma mão + escudo, armadura uma faixa acima. Fica perto dos Magos e do Lich (Lich)
// Atributos em Const.Necro.Tipos.sentinela (necro_constants.nut).
// =====================================================================

this.necro_sentinela <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "sentinela";
		this.m.Papel = "pesado";   // equipamento por nível (Const.Necro.Equipamento)
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_paladin_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonMedium;
		this.necro_undead.create();
	}

});
