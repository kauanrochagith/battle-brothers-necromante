// =====================================================================
// MOD NECROMANTE - Background "Necromante"
// ---------------------------------------------------------------------
// Etapa 1: só o background (atributos, aparência, equipamento, textos).
// As habilidades inatas (Erguer o Morto, Alternar Tipo de Morto e
// Vontade Inquebrável) entram nas próximas etapas.
//
// Estrutura copiada dos backgrounds vanilla (ex.: witchhunter_background).
// Os atributos ficam em scripts/config/necro_constants.nut.
// =====================================================================

this.necromancer_background <- this.inherit("scripts/skills/backgrounds/character_background", {
	m = {},
	function create()
	{
		this.character_background.create();
		this.m.ID = "background.necro_necromancer";
		this.m.Name = "Necromante";
		// Ícone do Cultista do vanilla (o jogo não tem ícone de necromante para backgrounds).
		this.m.Icon = "ui/backgrounds/background_34.png";
		this.m.BackgroundDescription = "Necromantes são comandantes, não lutadores. Frágeis de corpo, mas de vontade inabalável, eles erguem os mortos para lutar em seu lugar.";
		this.m.GoodEnding = "%name%, o necromante, deixou a %companyname% numa noite sem lua. Dizem que hoje ele governa uma fortaleza esquecida no norte, guardada por fileiras de mortos que nunca dormem.";
		this.m.BadEnding = "%name%, o necromante, deixou a companhia e foi caçado por uma ordem de caçadores de bruxas. Queimaram-no na praça de uma vila qualquer. Os aldeões juram que, naquela noite, os mortos do cemitério se agitaram nos túmulos.";
		this.m.HiringCost = this.Const.Necro.Background.CustoContratacao;
		this.m.DailyCost = this.Const.Necro.Background.SalarioDiario;
		this.m.Excluded = [
			"trait.fear_undead",
			"trait.hate_undead",
			"trait.superstitious",
			"trait.craven",
			"trait.fainthearted",
			"trait.insecure",
			"trait.dastard",
			"trait.huge",
			"trait.strong",
			"trait.iron_jaw"
		];
		this.m.Titles = [
			"o Necromante",
			"o Profanador",
			"o Pálido",
			"Mestre dos Ossos",
			"o Sepulcral",
			"Senhor dos Túmulos"
		];
		this.m.Faces = this.Const.Faces.AllMale;
		this.m.Hairs = this.Const.Hair.UntidyMale;
		this.m.HairColors = this.Const.HairColors.All;
		this.m.Beards = this.Const.Beards.Untidy;
		this.m.Bodies = this.Const.Bodies.Skinny;
		this.m.Level = 1;
		this.m.IsCombatBackground = false;
	}

	// O vanilla mostra "Background: <nome>"; trocamos o prefixo para português.
	function getName()
	{
		return "Antecedente: " + this.m.Name;
	}

	function getTooltip()
	{
		return [
			{
				id = 1,
				type = "title",
				text = this.getName()
			},
			{
				id = 2,
				type = "description",
				text = this.getDescription()
			},
			{
				id = 10,
				type = "text",
				icon = "ui/icons/health.png",
				text = "Corpo frágil: [color=" + this.Const.UI.Color.NegativeValue + "]menos Pontos de Vida[/color]"
			},
			{
				id = 11,
				type = "text",
				icon = "ui/icons/bravery.png",
				text = "Vontade de ferro: [color=" + this.Const.UI.Color.PositiveValue + "]Resolução alta[/color]"
			}
		];
	}

	function onBuildDescription()
	{
		return "{%name% foi expulso de %townname% depois que os coveiros encontraram túmulos abertos e vazios. | Ninguém em %townname% sabe de onde %name% veio, apenas que os cães uivam quando ele passa. | %name% passou anos estudando tomos proibidos numa cripta abandonada perto de %townname%.} {Ele fala com os mortos como quem fala com velhos amigos, e às vezes jura que eles respondem. | Dizem que ele não teme a morte porque já negociou com ela. | Os sacerdotes o chamam de abominação; ele os chama de desperdício de bons cadáveres.} {Agora procura uma companhia de mercenários: onde há guerra, há mortos, e onde há mortos, há soldados. | Uma companhia mercenária lhe dá o que nenhuma vila daria: um campo de batalha cheio de recrutas que não pedem salário.}";
	}

	function onChangeAttributes()
	{
		// Copiamos as listas para não alterar a tabela de constantes por engano.
		local a = this.Const.Necro.Background.Atributos;
		local c = {
			Hitpoints = clone a.Hitpoints,
			Bravery = clone a.Bravery,
			Stamina = clone a.Stamina,
			MeleeSkill = clone a.MeleeSkill,
			RangedSkill = clone a.RangedSkill,
			MeleeDefense = clone a.MeleeDefense,
			RangedDefense = clone a.RangedDefense,
			Initiative = clone a.Initiative
		};
		return c;
	}

	function onAddEquipment()
	{
		// Equipamento leve, no mesmo estilo do necromante inimigo do vanilla.
		local items = this.getContainer().getActor().getItems();
		local r = this.Math.rand(0, 1);

		if (r == 0)
		{
			items.equip(this.new("scripts/items/weapons/dagger"));
		}
		else
		{
			items.equip(this.new("scripts/items/weapons/knife"));
		}

		r = this.Math.rand(0, 1);

		if (r == 0)
		{
			items.equip(this.new("scripts/items/armor/ragged_dark_surcoat"));
		}
		else
		{
			items.equip(this.new("scripts/items/armor/thick_dark_tunic"));
		}

		if (this.Math.rand(1, 100) <= 50)
		{
			items.equip(this.new("scripts/items/helmets/dark_cowl"));
		}
	}

	// -----------------------------------------------------------------
	// Habilidades inatas (cap. 4). Não vão para o save: são recriadas aqui
	// sempre que o background é adicionado (inclusive ao carregar o jogo).
	// -----------------------------------------------------------------
	function onAdded()
	{
		this.character_background.onAdded();
		local actor = this.getContainer().getActor();
		local skills = this.getContainer();
		skills.add(this.new("scripts/skills/actives/necro_raise_dead"));
		skills.add(this.new("scripts/skills/actives/necro_cycle_type"));
		skills.add(this.new("scripts/skills/special/necro_unbreakable_will"));

		// Spec de subclasses, cap. 1: tronco nos níveis 1 e 2. O vanilla só dá o
		// primeiro ponto no nível 2, então o Necromante ganha 1 ponto extra uma vez.
		if (this.Const.Necro.PONTO_EXTRA_NIVEL_1 && !actor.getFlags().has("necro_ponto_inicial"))
		{
			actor.getFlags().add("necro_ponto_inicial");
			++actor.m.PerkPoints;
		}

		// Saves antigos: a migração dos pontos do Grimório roda depois, na primeira
		// consulta no mapa (ao carregar, o background vem ANTES dos perks).
		// As flags são carregadas antes das habilidades (entity.onDeserialize),
		// então aqui já sabemos a subclasse e recriamos as ativas dela.
		this.syncSubclassActives();
		this.registerGrimoire();
	}

	// -----------------------------------------------------------------
	// ATIVAS POR SUBCLASSE
	// Concede as ativas da subclasse jurada e remove as de outras subclasses.
	// Sem subclasse (antes do Juramento) não removemos nada: um save antigo
	// pode ter ativas vindas de perks da base, que a migração do Juramento trata.
	// -----------------------------------------------------------------
	function syncSubclassActives()
	{
		local util = this.Const.Necro.Util;
		local actor = this.getContainer().getActor();
		local sub = util.getSubclass(actor);

		if (sub == null)
		{
			return;
		}

		local allowed = {};

		foreach( script in util.getSubclassActives(sub) )
		{
			allowed[util.getActiveIDFromScript(script)] <- true;
			this.getContainer().add(this.new(script));
		}

		foreach( id, dono in util.getAllSubclassActiveIDs() )
		{
			if (!(id in allowed) && this.getContainer().hasSkill(id))
			{
				this.getContainer().removeByID(id);
			}
		}
	}

	function onUpdate( _properties )
	{
		this.character_background.onUpdate(_properties);
		this.registerGrimoire();
	}

	// O Grimório (escolha de perks do Necromante) é um "evento especial" do
	// vanilla: dispara sozinho assim que fica válido. A lista de eventos
	// especiais não é salva, então registramos de novo sempre que preciso.
	function registerGrimoire()
	{
		if (!("Events" in this.World) || this.World.Events == null)
		{
			return;
		}

		// Grimório (perks/Juramento) e Espólios dos Mortos (depois da batalha).
		foreach( id in [
			"event.necro_grimorio",
			"event.necro_espolios"
		] )
		{
			if (this.World.Events.m.SpecialEvents.find(id) == null && this.World.Events.getEvent(id) != null)
			{
				this.World.Events.addSpecialEvent(id);
			}
		}
	}

	// -----------------------------------------------------------------
	// Regras globais em combate (cap. 5)
	// -----------------------------------------------------------------
	function onTurnStart()
	{
		this.Const.Necro.Util.cachePerks(this.getContainer().getActor());
	}

	// Bônus do ataque grátis (Execução Sombria) e Marca do Caçador nos tiros do Necromante.
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == null || !_skill.isAttack())
		{
			return;
		}

		local util = this.Const.Necro.Util;
		local actor = this.getContainer().getActor();
		local rt = util.getRuntime();

		if (actor.getID() in rt.AtaqueBonus)
		{
			local b = rt.AtaqueBonus[actor.getID()];
			_properties.MeleeSkill += b.Acerto;
			_properties.RangedSkill += b.Acerto;
			_properties.DamageTotalMult *= 1.0 + b.Dano;
		}

		if (_targetEntity != null && _skill.isRanged())
		{
			local hunt = _targetEntity.getSkills().getSkillByID("effects.necro_hunter_mark");

			if (hunt != null && hunt.getMasterID() == actor.getID())
			{
				_properties.RangedSkill += this.Const.Necro.Sub.Atirador.MarcaAcerto;
				_properties.DamageTotalMult *= 1.0 + this.Const.Necro.Sub.Atirador.MarcaDano;
			}
		}
	}

	// Munição Profana: os tiros do próprio Necromante aplicam Veneno.
	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		this.Const.Necro.Util.applyOnHit(this.getContainer().getActor(), _targetEntity, _skill, _damageInflictedHitpoints, _damageInflictedArmor);
	}

	// Essência Morta: kills por Veneno/Necrose/Colheita contam carga.
	// (O dano dos efeitos é atribuído ao Necromante, então ele é o "matador".)
	function onTargetKilled( _targetEntity, _skill )
	{
		if (_skill == null)
		{
			return;
		}

		local id = _skill.getID();

		if (id == "effects.necro_poison" || id == "effects.necro_necrosis" || id == "actives.necro_harvest")
		{
			this.Const.Necro.Util.addEssence(this.getContainer().getActor().getID());
		}
	}

	// Morte do Necromante: os mortos que ELE invocou diretamente desabam
	// (inclusive os Magos). Mortos invocados por um Mago continuam.
	function onDeath( _fatalityType )
	{
		if (this.Const.Necro.Util.isInCombat())
		{
			this.Const.Necro.Util.collapseSummonsOf(this.getContainer().getActor().getID());
		}
	}

	function onCombatStarted()
	{
		this.character_background.onCombatStarted();
		this.Const.Necro.Util.clearRuntime();
		this.Const.Necro.Util.cachePerks(this.getContainer().getActor());
	}

	function onCombatFinished()
	{
		this.character_background.onCombatFinished();
		this.Const.Necro.Util.clearRuntime();
	}

});
