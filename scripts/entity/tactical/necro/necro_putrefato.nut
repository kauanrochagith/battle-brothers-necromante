// =====================================================================
// MOD NECROMANTE - Putrefato: zumbi lento e resistente que morde e aplica Veneno; trapos de duas faixas abaixo (Mestre da Peste)
// Atributos em Const.Necro.Tipos.putrefato (necro_constants.nut).
// =====================================================================

this.necro_putrefato <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "putrefato";
		this.m.Papel = "putrido";   // equipamento por nível (Const.Necro.Equipamento)
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_melee_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonLight;
		this.necro_undead.create();
	}

	function onInit()
	{
		this.necro_undead.onInit();
		this.m.Skills.add(this.new("scripts/skills/actives/zombie_bite"));

		// Tom esverdeado de carne podre.
		foreach( name in ["body", "head"] )
		{
			local sp = this.getSprite(name);
			sp.Color = this.createColor("#7f9a6a");
			sp.Saturation = 0.6;
		}
	}

});
