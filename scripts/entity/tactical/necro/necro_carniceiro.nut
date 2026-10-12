// =====================================================================
// MOD NECROMANTE - Carniceiro: arma pesada de duas mãos, armadura uma faixa abaixo. Veneno; ignora +20% de armadura (ver necro_undead_racial.nut). (cap. 8)
// Atributos em Const.Necro.Tipos.carniceiro (necro_constants.nut).
// =====================================================================

this.necro_carniceiro <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "carniceiro";
		this.m.Papel = "bruto";   // equipamento por nível (Const.Necro.Equipamento)
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_melee_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonLight;
		this.necro_undead.create();
	}

});
