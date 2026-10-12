// =====================================================================
// MOD NECROMANTE - Perk: Golpe Fúnebre (Cavaleiro da Morte)
// Ataques do Necromante contra alvos com GolpeFunebreAcumulos+ acúmulos
// (Veneno + Necrose) ou marcados ignoram mais GolpeFunebreArmadura da
// armadura (DamageDirectAdd, a mesma propriedade do vanilla).
// =====================================================================

this.perk_necro_golpe_funebre <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_golpe_funebre");
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == null || !_skill.isAttack() || _targetEntity == null)
		{
			return;
		}

		local util = this.Const.Necro.Util;
		local CA = this.Const.Necro.Sub.Cavaleiro;
		local s = _targetEntity.getSkills();

		if (util.getTotalStacks(_targetEntity) >= CA.GolpeFunebreAcumulos || s.hasSkill(util.MarcaID) || s.hasSkill("effects.necro_hunter_mark"))
		{
			_properties.DamageDirectAdd += CA.GolpeFunebreArmadura;
		}
	}

});
