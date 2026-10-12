// =====================================================================
// MOD NECROMANTE - Veneno do Cadáver (cap. 6.1)
// Aplicado por golpes CORPO A CORPO dos mortos (e à distância com Munição Profana).
// Toda a mecânica de acúmulo/duração está em necro_dot_effect.nut.
// =====================================================================

this.necro_poison_effect <- this.inherit("scripts/skills/effects/necro_dot_effect", {
	m = {},
	function create()
	{
		this.necro_dot_effect.create();
		this.m.ID = "effects.necro_poison";
		this.m.Name = "Veneno do Cadáver";
		this.m.KilledString = "Morreu envenenado";
		this.m.Description = "Um veneno pútrido de cadáver corre pelas veias deste personagem.";
		this.m.Icon = "skills/status_effect_54.png";
		this.m.IconMini = "status_effect_54_mini";
		this.m.IconBrush = "status_effect_54";
	}

});
