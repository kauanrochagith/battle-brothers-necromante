// =====================================================================
// MOD NECROMANTE - Regras passivas ocultas: Lich
// (colapso total ao morrer e Silêncio da Cripta)
// =====================================================================

this.necro_sub_lich <- this.inherit("scripts/skills/special/necro_sub_base", {
	m = {},
	function create()
	{
		this.necro_sub_base.create();
		this.m.ID = "actives.necro_sub_lich";
	}

	function onRound()
	{
		if (this.hasPerk("perk.necro_silencio_da_cripta"))
		{
			this.attachEnemyAura();
		}
	}

	// Regra do Lich: se ele morre (o Filactério já não salvou), TODOS os
	// mortos dele desabam, inclusive os erguidos pelos Magos.
	function onDeath( _fatalityType )
	{
		if (this.getUtil().isInCombat())
		{
			this.getUtil().collapseAllOfMaster(this.getActor().getID());
		}
	}

});
