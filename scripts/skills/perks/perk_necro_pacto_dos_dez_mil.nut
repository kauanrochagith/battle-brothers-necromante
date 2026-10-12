// =====================================================================
// MOD NECROMANTE - Perk: Pacto dos Dez Mil Mortos (camada 7)
// ---------------------------------------------------------------------
// Toda vez que um inimigo morre: 25% de chance de ele se erguer como
// Esqueleto Fraturado ao lado do Necromante. Máx. 10 por combate e
// respeita o limite de mortos (Util.getMaxSummons).
// O vanilla não avisa outras habilidades quando alguém morre, então este
// perk coloca um "vigia" invisível em cada inimigo (necro_pact_watcher_effect)
// no começo de cada rodada e de cada turno do Necromante (pega também
// inimigos que entrarem no meio do combate).
// =====================================================================

this.perk_necro_pacto_dos_dez_mil <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_pacto_dos_dez_mil");
	}

	function attachWatchers()
	{
		local util = this.Const.Necro.Util;

		if (!util.isInCombat())
		{
			return;
		}

		local actor = this.getContainer().getActor();

		foreach( faction in this.Tactical.Entities.getAllInstances() )
		{
			foreach( e in faction )
			{
				if (!util.isValidActor(e) || e.isAlliedWith(actor) || e.getSkills().hasSkill("effects.necro_pact_watcher"))
				{
					continue;
				}

				local w = this.new("scripts/skills/effects/necro_pact_watcher_effect");
				w.setMasterID(actor.getID());
				e.getSkills().add(w);
			}
		}
	}

	function onNewRound()
	{
		this.attachWatchers();
	}

	function onTurnStart()
	{
		this.attachWatchers();
	}

});
