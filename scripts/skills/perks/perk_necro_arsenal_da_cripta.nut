// =====================================================================
// MOD NECROMANTE - Perk: Arsenal da Cripta
// Desbloqueia tipos via Const.Necro.Tipos[...].Desbloqueio.
// =====================================================================

this.perk_necro_arsenal_da_cripta <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_arsenal_da_cripta");
	}

});
