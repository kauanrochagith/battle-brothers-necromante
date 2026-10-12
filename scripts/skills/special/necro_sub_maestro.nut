// =====================================================================
// MOD NECROMANTE - Regras passivas ocultas: Maestro dos Ossos
// (contagem das Ordens e Coro de Ossos)
// =====================================================================

this.necro_sub_maestro <- this.inherit("scripts/skills/special/necro_sub_base", {
	m = {},
	function create()
	{
		this.necro_sub_base.create();
		this.m.ID = "actives.necro_sub_maestro";
	}

	function onRound()
	{
		if (this.hasPerk("perk.necro_coro_de_ossos"))
		{
			this.attachEnemyAura();
		}
	}

	function onOwnTurn()
	{
		this.getUtil().tickOrders(this.getActor().getID());
	}

});
