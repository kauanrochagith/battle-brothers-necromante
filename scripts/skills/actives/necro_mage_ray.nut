// =====================================================================
// MOD NECROMANTE - Raio Necrótico dos Magos (perk Arcano Profano, Lich)
// ---------------------------------------------------------------------
// O Mago usa sozinho (IA ai_necro_mage_cast, sem alvo): escolhe o inimigo
// visível mais próximo no alcance. Dano MagoRaioDanoMin-Max, cooldown
// MagoRaioCD. Acerto fixo e alcance iguais aos do Lich (sem Arquimago).
// =====================================================================

this.necro_mage_ray <- this.inherit("scripts/skills/actives/necro_lich_ray", {
	m = {},
	function create()
	{
		this.necro_lich_ray.create();
		this.m.ID = "actives.necro_mage_ray";
		this.m.Name = "Raio Necrótico (Mago)";
		this.m.IsTargeted = false;
		this.m.IsTargetingActor = false;
		this.m.IsVisibleTileNeeded = false;
		this.m.MinRange = 0;
	}

	function hasArchmage()
	{
		return false;
	}

	function getCooldownMax()
	{
		return this.Const.Necro.Sub.Lich.MagoRaioCD;
	}

	function getDamageRange()
	{
		local LI = this.Const.Necro.Sub.Lich;
		return [
			LI.MagoRaioDanoMin,
			LI.MagoRaioDanoMax
		];
	}

	function onAfterUpdate( _properties )
	{
	}

	function findTarget()
	{
		local util = this.getUtil();
		local actor = this.getContainer().getActor();

		if (!actor.isPlacedOnMap())
		{
			return null;
		}

		local best = null;
		local bestDist = 999;

		foreach( e in util.getEnemiesOf(actor) )
		{
			local d = e.getTile().getDistanceTo(actor.getTile());

			if (d <= this.Const.Necro.Sub.Lich.RaioAlcance && d < bestDist && e.getTile().IsVisibleForEntity)
			{
				best = e;
				bestDist = d;
			}
		}

		return best;
	}

	function isUsable()
	{
		return this.necro_active_base.isUsable() && this.findTarget() != null;
	}

	function onUse( _user, _targetTile )
	{
		local target = this.findTarget();

		if (target == null)
		{
			return false;
		}

		this.fireAt(_user, target);
		this.startCooldown();
		return true;
	}

});
