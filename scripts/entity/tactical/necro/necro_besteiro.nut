// =====================================================================
// MOD NECROMANTE - Besteiro: besta por nível (atira e recarrega, então dispara a cada 2 turnos). Necrose; +15% de dano e +10% ignora armadura (ver necro_undead_racial.nut). (cap. 8)
// Atributos em Const.Necro.Tipos.besteiro (necro_constants.nut).
// =====================================================================

this.necro_besteiro <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "besteiro";
		this.m.Papel = "besta";   // equipamento por nível (Const.Necro.Equipamento)
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_ranged_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonLight;
		this.necro_undead.create();
	}

});
