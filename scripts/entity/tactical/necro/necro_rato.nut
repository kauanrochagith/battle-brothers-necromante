// =====================================================================
// MOD NECROMANTE - Rato Ossudo: rápido (11 PA), mordida aplica Necrose (Mestre da Peste)
// Atributos em Const.Necro.Tipos.rato (necro_constants.nut).
// =====================================================================

this.necro_rato <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "rato";
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_melee_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonLight;
		this.necro_undead.create();
	}

	function onInit()
	{
		this.necro_undead.onInit();
		this.m.Skills.add(this.new("scripts/skills/actives/wolf_bite"));
	}

	function onNecroEquip( _items )
	{
	}

});
