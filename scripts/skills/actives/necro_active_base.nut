// =====================================================================
// MOD NECROMANTE - Base das habilidades ativas (cooldown por turno)
// ---------------------------------------------------------------------
// Sem MSU, o cooldown é um contador próprio de CADA instância da habilidade
// (cap. 0, item 3). Como Necromante e cada Mago têm sua própria instância,
// os cooldowns são naturalmente independentes.
//   - Ao usar: CooldownLeft = cooldown.
//   - No início de cada turno do dono: CooldownLeft - 1.
//   - Usável quando CooldownLeft == 0.
// Não são salvas no save (IsSerialized = false); o background/perk que
// concede a habilidade a recria ao carregar.
// =====================================================================

this.necro_active_base <- this.inherit("scripts/skills/skill", {
	m = {
		CooldownLeft = 0,
		Potency = 1.0
	},
	function create()
	{
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.UtilityTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsStacking = false;
		this.m.IsAttack = false;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsUsingHitchance = false;
		this.m.IsRemovedAfterBattle = false;
	}

	function getUtil()
	{
		return this.Const.Necro.Util;
	}

	function getCooldownMax()
	{
		return 0;
	}

	function getCooldownLeft()
	{
		return this.m.CooldownLeft;
	}

	function startCooldown()
	{
		this.m.CooldownLeft = this.getCooldownMax();
	}

	function resetCooldown()
	{
		this.m.CooldownLeft = 0;
	}

	function isUsable()
	{
		return this.skill.isUsable() && this.m.CooldownLeft <= 0 && this.Const.Necro.Util.isInCombat();
	}

	function onTurnStart()
	{
		if (this.m.CooldownLeft > 0)
		{
			--this.m.CooldownLeft;
		}
	}

	function onCombatFinished()
	{
		this.skill.onCombatFinished();
		this.m.CooldownLeft = 0;
	}

	function getCooldownTooltip()
	{
		if (this.m.CooldownLeft > 0)
		{
			return {
				id = 20,
				type = "text",
				icon = "ui/icons/warning.png",
				text = "[color=" + this.Const.UI.Color.NegativeValue + "]Em recarga: " + this.m.CooldownLeft + " turno(s)[/color]"
			};
		}

		return {
			id = 20,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Cooldown: [color=" + this.Const.UI.Color.PositiveValue + "]" + this.getCooldownMax() + "[/color] turnos"
		};
	}

	function getTooltip()
	{
		local ret = this.getDefaultUtilityTooltip();
		this.onAddTooltip(ret);
		ret.push(this.getCooldownTooltip());
		return ret;
	}

	function onAddTooltip( _tooltip )
	{
	}

});
