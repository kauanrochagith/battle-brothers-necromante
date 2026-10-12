// =====================================================================
// MOD NECROMANTE - Regras passivas ocultas: Cavaleiro da Morte
// A classe base é frágil; o Cavaleiro ganha Fadiga máxima para usar
// armadura média/pesada.
// =====================================================================

this.necro_sub_knight <- this.inherit("scripts/skills/special/necro_sub_base", {
	m = {},
	function create()
	{
		this.necro_sub_base.create();
		this.m.ID = "actives.necro_sub_knight";
	}

	function onUpdate( _properties )
	{
		_properties.Stamina += this.Const.Necro.Sub.Cavaleiro.FadigaExtra;
	}

});
