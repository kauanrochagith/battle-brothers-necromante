// =====================================================================
// MOD NECROMANTE - Vigia de cadáveres do Coveiro (oculto)
// ---------------------------------------------------------------------
// Colocado em TODOS os atores do combate (inimigos, mercenários e
// terceiros, menos os nossos mortos) pela habilidade oculta do Coveiro.
// No onDeath anota script, atributos, itens e habilidades do morto
// (Const.Necro.Util.registerCorpse), para Reanimar Cadáver usar depois.
// =====================================================================

this.necro_corpse_watcher_effect <- this.inherit("scripts/skills/skill", {
	m = {},
	function create()
	{
		this.m.ID = "effects.necro_corpse_watcher";
		this.m.Name = "";
		this.m.Type = this.Const.SkillType.Special;
		this.m.Order = this.Const.SkillOrder.VeryLast;
		this.m.IsActive = false;
		this.m.IsHidden = true;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
		this.m.IsSerialized = false;
	}

	function onDeath( _fatalityType )
	{
		local util = this.Const.Necro.Util;

		if (!util.isInCombat())
		{
			return;
		}

		util.registerCorpse(this.getContainer().getActor());
	}

});
