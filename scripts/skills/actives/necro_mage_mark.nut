// =====================================================================
// MOD NECROMANTE - Marca do Comando do Mago (Eco do Mago, cap. 11)
// ---------------------------------------------------------------------
// 50% de potência, cooldown próprio. Sem alvo manual: a IA usa quando há
// um inimigo visível a até 7 tiles sem marca, e a própria habilidade
// escolhe o alvo com mais acúmulos (empate: o mais próximo).
// =====================================================================

this.necro_mage_mark <- this.inherit("scripts/skills/actives/necro_mark", {
	m = {},
	function create()
	{
		this.necro_mark.create();
		this.m.ID = "actives.necro_mage_mark";
		this.m.Name = "Marca do Comando (Mago)";
		this.m.IsTargeted = false;
		this.m.MinRange = 0;
		this.m.MaxRange = 0;
		this.m.Potency = this.Const.Necro.Perks.ECO_POTENCIA;
	}

	function findTarget()
	{
		local util = this.getUtil();
		local user = this.getContainer().getActor();
		local myTile = user.getTile();
		local best = null;
		local bestStacks = -1;
		local bestDist = 99;

		foreach( faction in this.Tactical.Entities.getAllInstances() )
		{
			foreach( e in faction )
			{
				if (!util.isValidActor(e) || e.isAlliedWith(user) || e.getSkills().hasSkill(util.MarcaID))
				{
					continue;
				}

				local d = e.getTile().getDistanceTo(myTile);

				if (d > this.Const.Necro.Ativas.MarcaAlcance || !e.getTile().IsVisibleForEntity)
				{
					continue;
				}

				local stacks = 0;

				foreach( id in [
					util.VenenoID,
					util.NecroseID
				] )
				{
					local eff = e.getSkills().getSkillByID(id);

					if (eff != null)
					{
						stacks = stacks + eff.getStacks();
					}
				}

				if (stacks > bestStacks || stacks == bestStacks && d < bestDist)
				{
					best = e;
					bestStacks = stacks;
					bestDist = d;
				}
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

		this.markTarget(_user, target);
		return true;
	}

});
