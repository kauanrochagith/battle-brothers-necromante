// =====================================================================
// MOD NECROMANTE - Base de todos os mortos invocados (cap. 5 e 8)
// ---------------------------------------------------------------------
// Herda o esqueleto vanilla (sons, cadáver, aparência), mas troca o onInit:
//   - atributos vêm de Const.Necro.Tipos[TipoID];
//   - NÃO recebe os perks embutidos do esqueleto inimigo (Battle Forged,
//     Steel Brow etc.) nem a resistência a flechas, para seguir a especificação;
//   - imune a moral (MoraleState.Ignore), sangramento, veneno, ferimentos
//     e fadiga;
//   - XP 0 (a morte deles não mexe na moral de ninguém);
//   - equipamento nunca entra no loot normal; vira "Espólio dos Mortos"
//     num evento depois da batalha (necro_spoils_event.nut);
//   - cadáver não pode ser reerguido por necromantes inimigos.
// Cada classe de morto só define TipoID, agente de IA e equipamento.
// =====================================================================

this.necro_undead <- this.inherit("scripts/entity/tactical/skeleton", {
	m = {
		TipoID = "guerreiro",
		AgentScript = "scripts/ai/tactical/agents/necro_melee_agent",
		EntityType = 0,

		// Papel no Const.Necro.Equipamento (null = equipamento fixo da classe,
		// com a armadura da tabela Tipos, como Abominação, Torre, Mago e Rato).
		Papel = null,
		ItemScripts = []
	},
	function create()
	{
		this.m.ItemScripts = [];
		this.m.Type = this.m.EntityType == 0 ? this.Const.EntityType.SkeletonLight : this.m.EntityType;
		this.m.XP = 0;
		this.m.IsResurrectable = false;
		this.m.ResurrectWithScript = "";
		this.skeleton.create();
		this.getFlags().add(this.Const.Necro.Util.FlagMorto);
		this.getFlags().set(this.Const.Necro.Util.FlagTipo, this.m.TipoID);

		// Peso no limite de mortos (Abominação/Torre = 5).
		if (this.m.TipoID in this.Const.Necro.Tipos && "Peso" in this.Const.Necro.Tipos[this.m.TipoID])
		{
			this.getFlags().set(this.Const.Necro.Util.FlagPeso, this.Const.Necro.Tipos[this.m.TipoID].Peso);
		}
		this.m.AIAgent = this.new(this.m.AgentScript);
		this.m.AIAgent.setActor(this);
	}

	function getStats()
	{
		return this.Const.Necro.Tipos[this.m.TipoID];
	}

	// Mortos ignoram a regra do vanilla que entrega XP de "aliado".
	function getXPValue()
	{
		return 0;
	}

	function onInit()
	{
		this.actor.onInit();
		local t = this.getStats();
		local b = this.m.BaseProperties;
		b.ActionPoints = ("ActionPoints" in t) ? t.ActionPoints : 9;
		b.Hitpoints = t.Hitpoints;
		b.Bravery = 100;
		b.Stamina = "Stamina" in t ? t.Stamina : 100;
		b.MeleeSkill = t.MeleeSkill;
		b.RangedSkill = t.RangedSkill;
		b.MeleeDefense = t.MeleeDefense;
		b.RangedDefense = t.RangedDefense;
		b.Initiative = t.Initiative;

		// Imunidades (cap. 5, regra 3).
		b.IsAffectedByNight = false;
		b.IsAffectedByInjuries = false;
		b.IsAffectedByFreshInjuries = false;
		b.IsImmuneToBleeding = true;
		b.IsImmuneToPoison = true;
		b.IsAffectedByDyingAllies = false;
		b.IsAffectedByFleeingAllies = false;
		b.IsAffectedByLosingHitpoints = false;
		b.FatigueEffectMult = 0.0;
		b.FatigueRecoveryRate = 100;

		this.m.ActionPoints = b.ActionPoints;
		this.m.Hitpoints = b.Hitpoints;
		this.m.CurrentProperties = clone b;
		this.m.ActionPointCosts = this.Const.DefaultMovementAPCost;
		this.m.FatigueCosts = this.Const.DefaultMovementFatigueCost;
		this.setName(t.Nome);
		this.setupSprites();
		this.m.Skills.add(this.new("scripts/skills/racial/necro_undead_racial"));
		this.m.Skills.add(this.new("scripts/skills/special/double_grip"));
		this.m.Skills.add(this.new("scripts/skills/actives/hand_to_hand"));
	}

	// Copiado de skeleton.onInit (vanilla), só a parte visual.
	function setupSprites()
	{
		local hairColor = this.Const.HairColors.Zombie[this.Math.rand(0, this.Const.HairColors.Zombie.len() - 1)];
		this.addSprite("socket").setBrush("bust_base_undead");
		local body = this.addSprite("body");
		body.setBrush("bust_skeleton_body_0" + this.Math.rand(1, 2));
		body.setHorizontalFlipping(true);
		body.Saturation = 0.8;

		if (this.Math.rand(0, 100) < 75)
		{
			body.varySaturation(0.2);
		}

		if (this.Math.rand(0, 100) < 90)
		{
			body.varyColor(0.025, 0.025, 0.025);
		}

		this.m.BloodColor = body.Color;
		this.m.BloodSaturation = body.Saturation;
		this.addSprite("body_injury").setBrush("bust_skeleton_body_injured");
		this.addSprite("armor");
		local head = this.addSprite("head");
		head.setBrush("bust_skeleton_head");
		head.Color = body.Color;
		head.Saturation = body.Saturation;
		local injury = this.addSprite("injury");
		injury.setBrush("bust_skeleton_head_injured");
		local beard = this.addSprite("beard");
		beard.varyColor(0.02, 0.02, 0.02);

		if (this.Math.rand(1, 100) <= 25)
		{
			beard.setBrush("beard_" + hairColor + "_" + this.Const.Beards.ZombieOnly[this.Math.rand(0, this.Const.Beards.ZombieOnly.len() - 1)]);
		}

		local face = this.addSprite("face");
		face.setBrush("bust_skeleton_face_0" + this.Math.rand(1, 6));
		local hair = this.addSprite("hair");
		hair.setHorizontalFlipping(true);
		hair.Color = beard.Color;

		if (this.Math.rand(1, 100) <= 50)
		{
			hair.setBrush("hair_" + hairColor + "_" + this.Const.Hair.ZombieOnly[this.Math.rand(0, this.Const.Hair.ZombieOnly.len() - 1)]);
		}

		this.setSpriteOffset("hair", this.createVec(0, -3));
		this.addSprite("helmet");
		this.addSprite("helmet_damage");
		local beard_top = this.addSprite("beard_top");

		if (beard.HasBrush && this.doesBrushExist(beard.getBrush().Name + "_top"))
		{
			beard_top.setBrush(beard.getBrush().Name + "_top");
			beard_top.Color = beard.Color;
		}

		local body_blood = this.addSprite("body_blood");
		body_blood.setBrush("bust_body_bloodied_02");
		body_blood.setHorizontalFlipping(true);
		body_blood.Visible = false;
		local body_dirt = this.addSprite("dirt");
		body_dirt.setBrush("bust_body_dirt_02");
		body_dirt.setHorizontalFlipping(true);
		body_dirt.Visible = this.Math.rand(1, 100) <= 33;
		this.addDefaultStatusSprites();
		this.getSprite("status_rooted").Scale = 0.55;
	}

	// O vanilla chama isto para inimigos; nossos mortos são equipados por onNecroSpawned.
	function assignRandomEquipment()
	{
	}

	// Equipamento sorteado pela faixa de nível do Necromante (Const.Necro.Equipamento).
	// Classes com equipamento fixo sobrescrevem esta função.
	function onNecroEquip( _items )
	{
		if (this.m.Papel == null)
		{
			return;
		}

		local util = this.Const.Necro.Util;
		local level = util.getMasterLevel(this.getFlags().getAsInt(util.FlagMestre));

		foreach( script in util.pickEquipment(this.m.Papel, level) )
		{
			this.equipItem(script);
		}
	}

	// Chamado por Const.Necro.Util.spawnSummon depois de definir facção e flags.
	function onNecroSpawned()
	{
		this.onNecroEquip(this.m.Items);
		local mult = this.getSpawnMults();
		this.m.BaseProperties.Hitpoints = this.Math.max(1, this.Math.round(this.getStats().Hitpoints * mult.HP));

		if (this.m.Papel != null)
		{
			// Armadura = a do próprio item, só multiplicada pelos perks.
			this.scaleArmorValues(mult.Armadura);
		}
		else
		{
			this.applyArmorValues(this.Math.round(this.getStats().Armadura[0] * mult.Armadura), this.Math.round(this.getStats().Armadura[1] * mult.Armadura));
		}
		this.getSkills().update();
		this.m.Hitpoints = this.getHitpointsMax();
	}

	// Bônus de vida/armadura ao nascer, vindos dos perks do mestre.
	function getSpawnMults()
	{
		local util = this.Const.Necro.Util;
		local masterID = this.getFlags().getAsInt(util.FlagMestre);
		local tipo = this.m.TipoID;
		local ret = {
			HP = 1.0,
			Armadura = 1.0
		};

		// Linhagem Nobre (Legião): Soldados Nobres e Paladinos +20% vida e armadura.
		if ((tipo == "soldado" || tipo == "paladino") && util.hasPerkByMasterID(masterID, "perk.necro_linhagem_nobre"))
		{
			ret.HP *= 1.0 + this.Const.Necro.Sub.Legiao.LinhagemHP;
			ret.Armadura *= 1.0 + this.Const.Necro.Sub.Legiao.LinhagemArmadura;
		}

		// Elite Funesta (Cavaleiro): todos os mortos +30% vida.
		if (util.hasPerkByMasterID(masterID, "perk.necro_elite_funesta"))
		{
			ret.HP *= 1.0 + this.Const.Necro.Sub.Cavaleiro.EliteHP;
		}

		// Osso Fresco (Ossário): esqueletos invocados +10% vida.
		if ((tipo == "guerreiro" || tipo == "arqueiro") && util.hasPerkByMasterID(masterID, "perk.necro_osso_fresco"))
		{
			ret.HP *= 1.0 + this.Const.Necro.Sub.Ossario.OssoFrescoHP;
		}

		return ret;
	}

	// Multiplica a armadura que veio nos itens (equipamento por nível) e impede loot.
	function scaleArmorValues( _mult )
	{
		local head = this.m.Items.getItemAtSlot(this.Const.ItemSlot.Head);
		local body = this.m.Items.getItemAtSlot(this.Const.ItemSlot.Body);
		this.applyArmorValues(head != null ? this.Math.round(head.m.ConditionMax * _mult) : 0, body != null ? this.Math.round(body.m.ConditionMax * _mult) : 0);
	}

	// Ajusta a armadura para os valores exatos dados e impede loot.
	function applyArmorValues( _head, _body )
	{
		local head = this.m.Items.getItemAtSlot(this.Const.ItemSlot.Head);
		local body = this.m.Items.getItemAtSlot(this.Const.ItemSlot.Body);

		if (head != null)
		{
			head.m.Condition = _head * 1.0;
			head.m.ConditionMax = _head * 1.0;
		}

		if (body != null)
		{
			body.m.Condition = _body * 1.0;
			body.m.ConditionMax = _body * 1.0;
		}

		foreach( item in this.m.Items.getAllItems() )
		{
			item.m.IsDroppedAsLoot = false;

			if (item.isItemType(this.Const.Items.ItemType.Ammo))
			{
				item.m.Ammo = this.Const.Necro.MORTOS_MUNICAO;
				item.m.AmmoMax = this.Const.Necro.MORTOS_MUNICAO;
			}
		}
	}

	// Esqueleto Fraturado: 50% de vida e armadura; o dano é cortado na racial.
	function makeFractured()
	{
		local mult = this.Const.Necro.Perks.FRATURADO_MULT;
		this.getFlags().add(this.Const.Necro.Util.FlagFraturado);
		this.setName(this.getStats().Nome + " Fraturado");
		this.m.BaseProperties.Hitpoints = this.Math.max(1, this.Math.floor(this.m.BaseProperties.Hitpoints * mult));
		if (this.m.Papel != null)
		{
			this.scaleArmorValues(mult);
		}
		else
		{
			this.applyArmorValues(this.Math.floor(this.getStats().Armadura[0] * mult), this.Math.floor(this.getStats().Armadura[1] * mult));
		}

		this.getSkills().update();
		this.m.Hitpoints = this.getHitpointsMax();
	}

	function equipItem( _script )
	{
		this.m.Items.equip(this.new(_script));

		// Guarda o script para virar espólio no fim da batalha
		// (Const.Necro.Util.registerSpoils, chamado em spawnSummon).
		this.m.ItemScripts.push(_script);
	}

	function getItemScripts()
	{
		return this.m.ItemScripts;
	}

});
