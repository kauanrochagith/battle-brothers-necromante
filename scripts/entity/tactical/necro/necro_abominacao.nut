// =====================================================================
// MOD NECROMANTE - Abominação de Ossos (Ossário, só por fusão)
// ---------------------------------------------------------------------
// Nasce da Fusão de Ossos: HP = AbominacaoHPBase + AbominacaoHPPorFundido x
// esqueletos fundidos. O montante dá o "Esmagar" (swing: alvo + 2 tiles
// adjacentes). Ocupa OSSARIO_PESO_ABOMINACAO vagas no limite (flag necro_peso).
// Perks: Colosso, Esmagar Giratório, Costura de Ossos, Linhagem de Ossos,
// Abominação Alfa e Ressurgir dos Ossos (ver necro_undead_racial.nut).
// =====================================================================

this.necro_abominacao <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {},
	function create()
	{
		this.m.TipoID = "abominacao";
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_melee_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonHeavy;
		this.necro_undead.create();
	}

	function onNecroEquip( _items )
	{
		this.equipItem("scripts/items/weapons/greatsword");
		this.equipItem("scripts/items/armor/ancient/ancient_plate_harness");
		this.equipItem("scripts/items/helmets/ancient/ancient_honorguard_helmet");
	}

	// Chamado pela Fusão de Ossos depois do spawn.
	//   _n = esqueletos fundidos | _hpPct = vida média (0-1) dos fundidos
	function setupFusion( _n, _hpPct, _alfa )
	{
		local O = this.Const.Necro.Sub.Ossario;
		local util = this.Const.Necro.Util;
		local masterID = this.getFlags().getAsInt(util.FlagMestre);
		local hp = (O.AbominacaoHPBase + O.AbominacaoHPPorFundido * _n) * 1.0;

		// Osso Fresco: a fusão preserva o bônus de vida dos esqueletos.
		if (util.hasPerkByMasterID(masterID, "perk.necro_osso_fresco"))
		{
			hp = hp * (1.0 + O.OssoFrescoHP);
		}

		if (util.hasPerkByMasterID(masterID, "perk.necro_colosso"))
		{
			hp = hp * (1.0 + O.ColossoHP);
		}

		this.getFlags().set("necro_fundidos", _n);

		if (_alfa)
		{
			// Abominação Alfa: +50% de atributos; as imunidades ficam na racial.
			this.getFlags().add("necro_alfa");
			hp = hp * (1.0 + O.AlfaMult);
			local b = this.m.BaseProperties;
			b.MeleeSkill = this.Math.round(b.MeleeSkill * (1.0 + O.AlfaMult));
			b.MeleeDefense = this.Math.round(b.MeleeDefense * (1.0 + O.AlfaMult));
			b.RangedDefense = this.Math.round(b.RangedDefense * (1.0 + O.AlfaMult));
			b.Initiative = this.Math.round(b.Initiative * (1.0 + O.AlfaMult));
			this.setName(this.getStats().Nome + " Alfa");
		}

		this.m.BaseProperties.Hitpoints = this.Math.max(1, this.Math.round(hp));

		// Esmagar Giratório: ganha o ataque giratório (todos os adjacentes).
		if (util.hasPerkByMasterID(masterID, "perk.necro_esmagar_giratorio"))
		{
			this.m.Skills.add(this.new("scripts/skills/actives/round_swing"));
		}

		this.getSkills().update();
		this.m.Hitpoints = this.Math.max(1, this.Math.round(this.getHitpointsMax() * _hpPct));
	}

	function makeFractured()
	{
	}

});
