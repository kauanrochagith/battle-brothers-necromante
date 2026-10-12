// =====================================================================
// MOD NECROMANTE - IA do Mago Sepulcral (cap. 9.3)
// ---------------------------------------------------------------------
//   - ai_necro_mage_cast: usa Erguer o Morto (espelhada), Marca e Colheita
//     assim que estiverem disponíveis (baseado no "ai_always_use" vanilla);
//   - ai_keep_safe / ai_disengage: fica longe dos inimigos e sai do corpo a
//     corpo (isso NÃO é fuga por moral: o Mago também ignora moral);
//   - nunca foge (sem ai_flee/ai_retreat).
// =====================================================================

this.necro_mage_agent <- this.inherit("scripts/ai/tactical/agent", {
	m = {},
	function create()
	{
		this.agent.create();
		this.m.ID = this.Const.AI.Agent.ID.Necromancer;
		this.m.Properties.BehaviorMult[this.Const.AI.Behavior.ID.EngageMelee] = 0.0;
		this.m.Properties.OverallMagnetismMult = 2.0;
		this.m.Properties.OverallDefensivenessMult = 2.0;
	}

	function onAddBehaviors()
	{
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_necro_mage_cast"));
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_break_free"));
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_disengage"));
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_keep_safe"));
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_attack_default"));
	}

});
