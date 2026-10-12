// =====================================================================
// MOD NECROMANTE - Caçador Espectral: arco um degrau acima do arqueiro, alcance +2, dano x1.5, atira a cada 2 turnos (Atirador Espectral)
// Atributos em Const.Necro.Tipos.cacador (necro_constants.nut).
// =====================================================================

this.necro_cacador <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "cacador";
		this.m.Papel = "cacador";   // equipamento por nível (Const.Necro.Equipamento)
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_ranged_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonLight;
		this.necro_undead.create();
	}

});
