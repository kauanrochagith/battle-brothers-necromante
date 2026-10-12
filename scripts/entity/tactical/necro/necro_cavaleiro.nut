// =====================================================================
// MOD NECROMANTE - Cavaleiro Morto: arma de uma mão + escudo, armadura uma faixa acima; elite (Cavaleiro da Morte)
// Atributos em Const.Necro.Tipos.cavaleiro (necro_constants.nut).
// =====================================================================

this.necro_cavaleiro <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "cavaleiro";
		this.m.Papel = "pesado";   // equipamento por nível (Const.Necro.Equipamento)
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_melee_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonHeavy;
		this.necro_undead.create();
	}

});
