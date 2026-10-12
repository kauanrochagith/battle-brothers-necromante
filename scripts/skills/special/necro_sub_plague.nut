// =====================================================================
// MOD NECROMANTE - Regras passivas ocultas: Mestre da Peste
// (duração das Nuvens de Peste)
// =====================================================================

this.necro_sub_plague <- this.inherit("scripts/skills/special/necro_sub_base", {
	m = {},
	function create()
	{
		this.necro_sub_base.create();
		this.m.ID = "actives.necro_sub_plague";
	}

	function onRound()
	{
		if (this.getUtil().getRuntime().Nuvens.len() != 0)
		{
			this.attachEnemyAura();
		}
	}

	// As nuvens deste Necromante perdem 1 turno no início do turno dele.
	function onOwnTurn()
	{
		local rt = this.getUtil().getRuntime();
		local id = this.getActor().getID();
		local kept = [];

		foreach( c in rt.Nuvens )
		{
			if (c.MasterID == id)
			{
				c.Turnos = c.Turnos - 1;
			}

			if (c.Turnos > 0)
			{
				kept.push(c);
			}
		}

		rt.Nuvens = kept;
	}

});
