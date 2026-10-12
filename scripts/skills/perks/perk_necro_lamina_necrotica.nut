// =====================================================================
// MOD NECROMANTE - Perk: Lâmina Necrótica (Cavaleiro da Morte)
// Golpes corpo a corpo do Necromante aplicam LaminaAcumulos de Necrose
// (LaminaAcumulosCritico em acerto na cabeça).
// =====================================================================

this.perk_necro_lamina_necrotica <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_lamina_necrotica");
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		local util = this.Const.Necro.Util;
		local actor = this.getContainer().getActor();

		if (_skill == null || !_skill.isAttack() || _skill.isRanged() || !util.isValidActor(_targetEntity) || _targetEntity.isAlliedWith(actor))
		{
			return;
		}

		local CA = this.Const.Necro.Sub.Cavaleiro;
		local n = _bodyPart == this.Const.BodyPart.Head ? CA.LaminaAcumulosCritico : CA.LaminaAcumulos;
		util.addStacks(_targetEntity, util.NecroseID, n, actor.getID());
	}

});
