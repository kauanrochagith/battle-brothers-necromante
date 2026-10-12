// =====================================================================
// MOD NECROMANTE - Escudeiro Esquelético: lança + escudo (de torre a partir do nível 5), escolta o Necromante (Cavaleiro e Atirador)
// Atributos em Const.Necro.Tipos.escudeiro (necro_constants.nut).
// =====================================================================

this.necro_escudeiro <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "escudeiro";
		this.m.Papel = "escudeiro";   // equipamento por nível (Const.Necro.Equipamento)
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_melee_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonMedium;
		this.necro_undead.create();
	}

});
