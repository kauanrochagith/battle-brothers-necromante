// =====================================================================
// MOD NECROMANTE - Arqueiro: arco por nível, armadura uma faixa abaixo. Necrose à distância. (cap. 8)
// Atributos em Const.Necro.Tipos.arqueiro (necro_constants.nut).
// =====================================================================

this.necro_arqueiro <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "arqueiro";
		this.m.Papel = "arco";   // equipamento por nível (Const.Necro.Equipamento)
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_ranged_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonLight;
		this.necro_undead.create();
	}

});
