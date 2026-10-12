// =====================================================================
// MOD NECROMANTE - Perk: Livro Dos Mortos
// Marcador: o efeito é aplicado em necro_mage_raise.nut (getMaxUses).
// =====================================================================

this.perk_necro_livro_dos_mortos <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_livro_dos_mortos");
	}

});
