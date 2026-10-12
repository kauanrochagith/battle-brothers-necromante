// =====================================================================
// MOD NECROMANTE - Soldado Nobre: arma de uma mão + escudo (equipamento por nível). Veneno corpo a corpo. (cap. 8)
// Atributos em Const.Necro.Tipos.soldado (necro_constants.nut).
// =====================================================================

this.necro_soldado <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "soldado";
		this.m.Papel = "infantaria";   // equipamento por nível (Const.Necro.Equipamento)
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_melee_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonMedium;
		this.necro_undead.create();
	}

});
