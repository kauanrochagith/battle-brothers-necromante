// =====================================================================
// MOD NECROMANTE - Perk: Linhagem Nobre
// Desbloqueia tipos via Const.Necro.Tipos[...].Desbloqueio.
// =====================================================================

this.perk_necro_linhagem_nobre <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_linhagem_nobre");
	}

});
