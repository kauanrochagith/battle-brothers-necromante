// =====================================================================
// MOD NECROMANTE - Regras passivas ocultas: Senhor da Legião
// (Capitão da Cadeia de Comando e Estandarte Ósseo)
// =====================================================================

this.necro_sub_legion <- this.inherit("scripts/skills/special/necro_sub_base", {
	m = {},
	function create()
	{
		this.necro_sub_base.create();
		this.m.ID = "actives.necro_sub_legion";
	}

	// Promove o Capitão e entrega o estandarte caído.
	function onOwnTurn()
	{
		local id = this.getActor().getID();
		this.getUtil().updateCaptain(id);
		this.getUtil().updateBanner(id);
	}

});
