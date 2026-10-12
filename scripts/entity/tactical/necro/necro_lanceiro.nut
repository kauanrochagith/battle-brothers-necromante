// =====================================================================
// MOD NECROMANTE - Lanceiro: arma de haste de duas mãos (alcance 2), por nível. Veneno. (cap. 8)
// Atributos em Const.Necro.Tipos.lanceiro (necro_constants.nut).
// =====================================================================

this.necro_lanceiro <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "lanceiro";
		this.m.Papel = "haste";   // equipamento por nível (Const.Necro.Equipamento)
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_melee_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonMedium;
		this.necro_undead.create();
	}

});
