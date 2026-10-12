// =====================================================================
// MOD NECROMANTE - Execução Sombria (Cavaleiro da Morte)
// ---------------------------------------------------------------------
// O Necromante ataca com a arma corpo a corpo (+ExecDano de dano,
// +ExecAcerto de acerto, lidos pelo background via AtaqueBonus). Depois,
// todos os mortos a até ExecRaio tiles fazem 1 ataque grátis no mesmo
// alvo, andando até ExecMovimento tiles se precisarem.
// Comandante de Guerra: cooldown -1.
// =====================================================================

this.necro_knight_execute <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local CA = this.Const.Necro.Sub.Cavaleiro;
		this.m.ID = "actives.necro_knight_execute";
		this.m.Name = "Execução Sombria";
		this.m.Description = "Um golpe do Necromante seguido pelo ataque de todos os mortos próximos contra o mesmo alvo.";
		this.m.Icon = "skills/active_32.png";
		this.m.IconDisabled = "skills/active_32_sw.png";
		this.m.Overlay = "active_32";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_02.wav"
		];
		this.m.Order = this.Const.SkillOrder.UtilityTargeted + 10;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = true;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsShowingProjectile = false;
		this.m.ActionPointCost = CA.ExecPA;
		this.m.FatigueCost = CA.ExecFadiga;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
	}

	function getCooldownMax()
	{
		local CA = this.Const.Necro.Sub.Cavaleiro;
		local cd = CA.ExecCD;

		if (this.getUtil().hasPerkByMasterID(this.getContainer().getActor().getID(), "perk.necro_comandante_de_guerra"))
		{
			cd = cd - CA.ComandanteCD;
		}

		return this.Math.max(1, cd);
	}

	function getAttack()
	{
		return this.getUtil().getMeleeAttack(this.getContainer().getActor());
	}

	// Alcance = alcance da arma corpo a corpo (lanças longas etc.).
	function onAfterUpdate( _properties )
	{
		local a = this.getAttack();
		this.m.MaxRange = a != null ? a.getMaxRange() : 1;
	}

	function isUsable()
	{
		return this.necro_active_base.isUsable() && this.getAttack() != null;
	}

	function onAddTooltip( _tooltip )
	{
		local CA = this.Const.Necro.Sub.Cavaleiro;
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/regular_damage.png",
			text = "Seu golpe: [color=" + this.Const.UI.Color.PositiveValue + "]+" + this.Math.round(CA.ExecDano * 100) + "%[/color] de dano e [color=" + this.Const.UI.Color.PositiveValue + "]+" + CA.ExecAcerto + "%[/color] de acerto"
		});
		_tooltip.push({
			id = 11,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Depois, todos os mortos a até " + CA.ExecRaio + " tiles atacam o mesmo alvo (andando até " + CA.ExecMovimento + " tiles)"
		});
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.skill.onVerifyTarget(_originTile, _targetTile) || !_targetTile.IsOccupiedByActor)
		{
			return false;
		}

		local target = _targetTile.getEntity();
		return target != null && target.isAlive() && !target.isAlliedWith(this.getContainer().getActor());
	}

	function onUse( _user, _targetTile )
	{
		local CA = this.Const.Necro.Sub.Cavaleiro;
		local util = this.getUtil();
		local target = _targetTile.getEntity();
		local attack = this.getAttack();

		if (attack == null || !attack.isInRange(_targetTile))
		{
			return false;
		}

		// O golpe do Necromante (de graça: o custo é o desta habilidade).
		util.getRuntime().AtaqueBonus[_user.getID()] <- {
			Acerto = CA.ExecAcerto,
			Dano = CA.ExecDano
		};
		attack.useForFree(_targetTile);

		if (_user.getID() in util.getRuntime().AtaqueBonus)
		{
			delete util.getRuntime().AtaqueBonus[_user.getID()];
		}

		// Os mortos próximos seguem o golpe.
		local n = 0;

		foreach( e in util.getSummonsOfMaster(_user.getID(), false) )
		{
			if (!util.isValidActor(target))
			{
				break;
			}

			if (e.getTile().getDistanceTo(_user.getTile()) > CA.ExecRaio)
			{
				continue;
			}

			if (util.moveAndAttack(e, target, CA.ExecMovimento, 400 + 300 * n))
			{
				n = ++n;
			}
		}

		this.startCooldown();
		return true;
	}

});
