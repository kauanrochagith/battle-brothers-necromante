// =====================================================================
// MOD NECROMANTE - Perk: Elo de Sangue (Cavaleiro da Morte)
// EloSangueFracao do dano à vida que o Necromante causa vira cura,
// dividida igualmente entre os mortos feridos dele.
// =====================================================================

this.perk_necro_elo_de_sangue <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_elo_de_sangue");
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		local util = this.Const.Necro.Util;
		local actor = this.getContainer().getActor();

		if (!util.isInCombat() || _damageInflictedHitpoints <= 0 || _targetEntity == null || _targetEntity.isAlliedWith(actor))
		{
			return;
		}

		local total = this.Math.floor(_damageInflictedHitpoints * this.Const.Necro.Sub.Cavaleiro.EloSangueFracao);
		local feridos = [];

		foreach( e in util.getSummonsOfMaster(actor.getID(), false) )
		{
			if (e.getHitpoints() < e.getHitpointsMax())
			{
				feridos.push(e);
			}
		}

		if (total <= 0 || feridos.len() == 0)
		{
			return;
		}

		local parte = this.Math.max(1, total / feridos.len());

		foreach( e in feridos )
		{
			util.heal(e, parte);
		}
	}

});
