// =====================================================================
// MOD NECROMANTE - Mago Sepulcral (cap. 9)
// ---------------------------------------------------------------------
// Visual de Sacerdote Antigo. Tem sua PRÓPRIA instância de "Erguer o Morto
// (espelhada)", com cooldowns próprios, por isso não compartilha cooldown
// com o Necromante nem com outros Magos. Magos não invocam Magos.
// Com Eco do Mago também recebe Marca e Colheita (50% de potência),
// se o Necromante tiver essas habilidades.
// Atributos em Const.Necro.Mago.
// =====================================================================

this.necro_mago <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "mago";
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_mage_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonPriest;
		this.necro_undead.create();
		this.getFlags().add(this.Const.Necro.Util.FlagMago);
	}

	function getStats()
	{
		return this.Const.Necro.Mago;
	}

	function onInit()
	{
		this.necro_undead.onInit();
		this.m.Skills.add(this.new("scripts/skills/actives/necro_mage_raise"));
	}

	function onNecroEquip( _items )
	{
		this.equipItem("scripts/items/armor/ancient/ancient_priest_attire");
		this.equipItem("scripts/items/helmets/ancient/ancient_priest_diadem");
	}

	function onNecroSpawned()
	{
		this.necro_undead.onNecroSpawned();
		local util = this.Const.Necro.Util;
		local masterID = this.getFlags().getAsInt(util.FlagMestre);

		// Arcano Profano (Lich): o Mago usa Raio Necrótico sozinho.
		if (util.hasPerkByMasterID(masterID, "perk.necro_arcano_profano"))
		{
			this.m.Skills.add(this.new("scripts/skills/actives/necro_mage_ray"));
		}

		if (util.hasPerkByMasterID(masterID, "perk.necro_eco_do_mago"))
		{
			if (util.hasPerkByMasterID(masterID, "perk.necro_marca_do_comando"))
			{
				this.m.Skills.add(this.new("scripts/skills/actives/necro_mage_mark"));
			}

			if (util.hasPerkByMasterID(masterID, "perk.necro_colheita_da_morte"))
			{
				this.m.Skills.add(this.new("scripts/skills/actives/necro_mage_harvest"));
			}
		}
	}

	// O Mago não vira Fraturado.
	function makeFractured()
	{
	}

});
