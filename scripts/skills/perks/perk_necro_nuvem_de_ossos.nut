// =====================================================================
// MOD NECROMANTE - Perk: Nuvem de Ossos (camada 6)
// +15 Def CaC e +15 Def Dist enquanto houver pelo menos 5 mortos em campo.
// (A contagem é refeita sempre que o personagem atualiza os atributos;
// Erguer o Morto força essa atualização logo depois de invocar.)
// =====================================================================

this.perk_necro_nuvem_de_ossos <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_nuvem_de_ossos");
	}

	function onUpdate( _properties )
	{
		local util = this.Const.Necro.Util;

		if (!util.isInCombat())
		{
			return;
		}

		local actor = this.getContainer().getActor();

		if (util.countSummons(actor.getID()) >= this.Const.Necro.Perks.NUVEM_MIN_MORTOS)
		{
			_properties.MeleeDefense += this.Const.Necro.Perks.NUVEM_DEFESA;
			_properties.RangedDefense += this.Const.Necro.Perks.NUVEM_DEFESA;
		}
	}

});
