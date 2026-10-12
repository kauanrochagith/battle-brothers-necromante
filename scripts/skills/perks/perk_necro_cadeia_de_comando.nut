// =====================================================================
// MOD NECROMANTE - Perk: Cadeia De Comando
// Marcador: o efeito é aplicado em Util.updateCaptain / necro_undead_racial.nut.
// =====================================================================

this.perk_necro_cadeia_de_comando <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_cadeia_de_comando");
	}

});
