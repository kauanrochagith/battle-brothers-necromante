// =====================================================================
// MOD NECROMANTE - Acólito Espectral: arco por nível, armadura uma faixa abaixo. Necrose à distância (Lich)
// Atributos em Const.Necro.Tipos.acolito (necro_constants.nut).
// =====================================================================

this.necro_acolito <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "acolito";
		this.m.Papel = "arco";   // equipamento por nível (Const.Necro.Equipamento)
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_ranged_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonLight;
		this.necro_undead.create();
	}

});
