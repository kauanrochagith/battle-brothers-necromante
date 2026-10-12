// =====================================================================
// MOD NECROMANTE - Perk: Armadura de Ossos (Cavaleiro da Morte)
// Devolve ArmaduraOssosPenalidade (30%) da penalidade de Fadiga da
// armadura e do elmo (como o perk Brawny do vanilla, que usa 0.7 em
// items/armor/armor.nut) e dá +ArmaduraOssosFadiga de Fadiga máxima.
// =====================================================================

this.perk_necro_armadura_de_ossos <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_armadura_de_ossos");
	}

	function onUpdate( _properties )
	{
		local CA = this.Const.Necro.Sub.Cavaleiro;
		local items = this.getContainer().getActor().getItems();
		local penalidade = 0;

		foreach( slot in [this.Const.ItemSlot.Body, this.Const.ItemSlot.Head] )
		{
			local item = items.getItemAtSlot(slot);

			if (item != null && ("StaminaModifier" in item.m) && item.m.StaminaModifier < 0)
			{
				penalidade = penalidade - item.m.StaminaModifier;
			}
		}

		_properties.Stamina += this.Math.floor(penalidade * CA.ArmaduraOssosPenalidade) + CA.ArmaduraOssosFadiga;
	}

});
