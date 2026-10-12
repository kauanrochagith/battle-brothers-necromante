// =====================================================================
// MOD NECROMANTE - Vigia do Pacto dos Dez Mil Mortos (oculto)
// ---------------------------------------------------------------------
// O vanilla não avisa "alguém morreu" para habilidades de terceiros.
// Por isso o perk Pacto coloca este efeito invisível em cada inimigo:
// quando o inimigo morre, o onDeath daqui rola a chance de ele se erguer
// como Esqueleto Fraturado ao lado do Necromante.
// Limites: PACTO_MAX_POR_COMBATE e o limite de mortos (Util.getMaxSummons). Não loopa: os
// esqueletos criados são aliados e nunca recebem este vigia.
// =====================================================================

this.necro_pact_watcher_effect <- this.inherit("scripts/skills/skill", {
	m = {
		MasterID = -1
	},
	function create()
	{
		this.m.ID = "effects.necro_pact_watcher";
		this.m.Name = "";
		this.m.Type = this.Const.SkillType.Special;
		this.m.Order = this.Const.SkillOrder.VeryLast;
		this.m.IsActive = false;
		this.m.IsHidden = true;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
		this.m.IsSerialized = false;
	}

	function setMasterID( _id )
	{
		this.m.MasterID = _id;
	}

	function onDeath( _fatalityType )
	{
		local util = this.Const.Necro.Util;
		local rt = util.getRuntime();
		local master = this.Tactical.getEntityByID(this.m.MasterID);

		if (master == null || !util.isValidActor(master))
		{
			return;
		}

		local count = (this.m.MasterID in rt.PactoContagem) ? rt.PactoContagem[this.m.MasterID] : 0;

		if (count >= this.Const.Necro.Perks.PACTO_MAX_POR_COMBATE)
		{
			return;
		}

		if (this.Math.rand(1, 100) > this.Const.Necro.Perks.PACTO_CHANCE)
		{
			return;
		}

		// Inimigo à distância vira Arqueiro; corpo a corpo vira Guerreiro Ossudo.
		local victim = this.getContainer().getActor();
		local tipo = victim.isArmedWithRangedWeapon() ? "arqueiro" : "guerreiro";

		if (util.spawnFracturedNear(tipo, master.getTile(), master, master) != null)
		{
			rt.PactoContagem[this.m.MasterID] <- count + 1;
		}
	}

});
