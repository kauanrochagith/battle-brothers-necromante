// =====================================================================
// MOD NECROMANTE - Guerreiro Ossudo: arma de uma mão + escudo (equipamento por nível). Veneno corpo a corpo. (cap. 8)
// Atributos em Const.Necro.Tipos.guerreiro (necro_constants.nut).
// =====================================================================

this.necro_guerreiro <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "guerreiro";
		this.m.Papel = "infantaria";   // equipamento por nível (Const.Necro.Equipamento)
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_melee_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonLight;
		this.necro_undead.create();
	}

});
