// =====================================================================
// MOD NECROMANTE - Torre de Ossos (Ossário, fusão de arqueiros)
// ---------------------------------------------------------------------
// Imóvel (IsRooted na racial). Arco de guerra com alcance fixo AlcanceFixo
// e dano x DanoMult ("Lanças de Osso"). HP = TorreHPBase + TorreHPPorFundido
// x arqueiros fundidos. Ocupa o mesmo peso de uma Abominação.
// =====================================================================

this.necro_torre <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "torre";
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_ranged_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonHeavy;
		this.necro_undead.create();
	}

	function onNecroEquip( _items )
	{
		this.equipItem("scripts/items/weapons/war_bow");
		this.equipItem("scripts/items/ammo/quiver_of_arrows");
		this.equipItem("scripts/items/armor/ancient/ancient_breastplate");
		this.equipItem("scripts/items/helmets/ancient/ancient_legionary_helmet");
	}

	function setupFusion( _n, _hpPct, _alfa )
	{
		local O = this.Const.Necro.Sub.Ossario;
		local util = this.Const.Necro.Util;
		local hp = (O.TorreHPBase + O.TorreHPPorFundido * _n) * 1.0;

		if (util.hasPerkByMasterID(this.getFlags().getAsInt(util.FlagMestre), "perk.necro_osso_fresco"))
		{
			hp = hp * (1.0 + O.OssoFrescoHP);
		}

		this.getFlags().set("necro_fundidos", _n);
		this.m.BaseProperties.Hitpoints = this.Math.max(1, this.Math.round(hp));
		this.getSkills().update();
		this.m.Hitpoints = this.Math.max(1, this.Math.round(this.getHitpointsMax() * _hpPct));
	}

	function makeFractured()
	{
	}

});
