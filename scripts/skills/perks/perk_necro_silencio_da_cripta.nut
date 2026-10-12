// =====================================================================
// MOD NECROMANTE - Perk: Silencio Da Cripta
// Marcador: o efeito é aplicado em necro_sub_lich.nut + necro_enemy_aura_effect.nut.
// =====================================================================

this.perk_necro_silencio_da_cripta <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_silencio_da_cripta");
	}

});
