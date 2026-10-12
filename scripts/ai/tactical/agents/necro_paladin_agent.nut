// =====================================================================
// MOD NECROMANTE - IA do Paladino Sepulcral (cap. 10)
// ---------------------------------------------------------------------
// Igual à IA corpo a corpo, mais o comportamento vanilla "ai_protect":
// o Paladino se posiciona para proteger aliados "VIP" (TargetAttractionMult > 1).
// O Mago Sepulcral é marcado como VIP na racial (Const.Necro.Mago.AtracaoIA).
// =====================================================================

this.necro_paladin_agent <- this.inherit("scripts/ai/tactical/agents/necro_melee_agent", {
	m = {},
	function create()
	{
		this.necro_melee_agent.create();
		this.m.Properties.BehaviorMult[this.Const.AI.Behavior.ID.Protect] = 1.0;
	}

	function onAddBehaviors()
	{
		this.necro_melee_agent.onAddBehaviors();
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_protect"));
	}

});
