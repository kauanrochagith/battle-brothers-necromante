// =====================================================================
// MOD NECROMANTE - IA dos mortos corpo a corpo (cap. 10)
// ---------------------------------------------------------------------
// Baseada em skeleton_melee_agent (vanilla), sem a lógica de "esperar o Lich"
// e sem nenhum comportamento de fuga/recuo: sempre avançam e atacam.
// Prioridade de alvo: o vanilla já usa TargetAttractionMult, que a Marca
// do Comando multiplica por 3.
// Leve de propósito: só comportamentos padrão do jogo (sem pathfinding extra).
// =====================================================================

this.necro_melee_agent <- this.inherit("scripts/ai/tactical/agent", {
	m = {},
	function create()
	{
		this.agent.create();
		this.m.ID = this.Const.AI.Agent.ID.SkeletonMelee;
		this.m.Properties.BehaviorMult[this.Const.AI.Behavior.ID.Shieldwall] = 4.0;
		this.m.Properties.TargetPriorityMoraleMult = 0.25;
		this.m.Properties.TargetPriorityBraveryMult = 0.25;
		this.m.Properties.OverallDefensivenessMult = 0.0;
		this.m.Properties.OverallFormationMult = 1.0;
		this.m.Properties.EngageTargetArmedWithRangedWeaponMult = 1.25;
		this.m.Properties.EngageWhenAlreadyEngagedMult = 0.1;
		this.m.Properties.EngageFlankingMult = 0.5;
		this.m.Properties.EngageTargetAlreadyBeingEngagedMult = 2.0;
		this.m.Properties.EngageTileLimit = 0;
		this.m.Properties.IgnoreTargetValueOnEngage = false;
	}

	function onAddBehaviors()
	{
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_engage_melee"));
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_break_free"));
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_attack_default"));
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_attack_swing"));
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_attack_reap"));
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_attack_split"));
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_attack_decapitate"));
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_attack_splitshield"));
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_defend_shieldwall"));
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_defend_spearwall"));
		this.addBehavior(this.new("scripts/ai/tactical/behaviors/ai_defend_knock_back"));
	}

	function onUpdate()
	{
		this.setEngageRangeBasedOnWeapon();
		this.m.Properties.DontEngage = false;

		// Ordem "Muralha" (Maestro): os mortos não avançam além de MuralhaRaio
		// tiles do Necromante; continuam atacando quem chegar perto.
		local util = this.Const.Necro.Util;
		local actor = this.getActor();

		if (actor != null && actor.isPlacedOnMap() && util.isInCombat())
		{
			local masterID = util.getMasterID(actor);

			if (masterID >= 0 && util.getOrderMult(masterID, "muralha") > 0)
			{
				local master = util.getMaster(actor);

				if (master != null && master.getTile().getDistanceTo(actor.getTile()) >= this.Const.Necro.Sub.Maestro.MuralhaRaio)
				{
					this.m.Properties.DontEngage = true;
				}
			}
		}
	}

});
