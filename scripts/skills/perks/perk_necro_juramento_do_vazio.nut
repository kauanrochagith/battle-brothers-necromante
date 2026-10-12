// =====================================================================
// MOD NECROMANTE - Perk: Juramento do Vazio (Cavaleiro da Morte)
// Imune a atordoamento (IsImmuneToStun) e a moral/medo: em combate o
// Necromante fica em MoraleState.Ignore, como os mortos-vivos do vanilla
// (checkMorale e as habilidades de medo ignoram quem está assim).
// =====================================================================

this.perk_necro_juramento_do_vazio <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_juramento_do_vazio");
	}

	function onUpdate( _properties )
	{
		_properties.IsImmuneToStun = true;
	}

	function setIgnoreMorale()
	{
		if (this.Const.Necro.Util.isInCombat())
		{
			this.getContainer().getActor().setMoraleState(this.Const.MoraleState.Ignore);
		}
	}

	function onCombatStarted()
	{
		this.setIgnoreMorale();
	}

	function onTurnStart()
	{
		this.setIgnoreMorale();
	}

	function onCombatFinished()
	{
		this.skill.onCombatFinished();
		this.getContainer().getActor().setMoraleState(this.Const.MoraleState.Steady);
	}

});
