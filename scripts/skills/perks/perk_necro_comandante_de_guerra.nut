// =====================================================================
// MOD NECROMANTE - Perk: Comandante de Guerra (Cavaleiro da Morte)
// +ComandantePA PA máximo. O cooldown menor da Execução Sombria fica em
// necro_knight_execute.nut.
// =====================================================================

this.perk_necro_comandante_de_guerra <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_comandante_de_guerra");
	}

	function onUpdate( _properties )
	{
		_properties.ActionPoints += this.Const.Necro.Sub.Cavaleiro.ComandantePA;
	}

});
