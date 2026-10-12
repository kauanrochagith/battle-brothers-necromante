// =====================================================================
// MOD NECROMANTE - Reanimado (Coveiro)
// ---------------------------------------------------------------------
// Um esqueleto que veste o equipamento do morto e copia o papel dele:
//   - HP e habilidades = COVEIRO_REANIMADO_ESCALA (80% com Mestre dos
//     Cadáveres) do original, lidos do registro do cadáver;
//   - atirador se o morto usava arma à distância;
//   - Memória do Cadáver: mantém metade das habilidades próprias (mordidas etc.);
//   - Exército Roubado: original de elite dá +20% de vida e dano;
//   - se desfaz depois de ReanimadoDuracao turnos (Sem Descanso tira isto).
// Por que um esqueleto e não o script original: o onInit de cada inimigo do
// vanilla espera estar na própria facção e IA; a base dos mortos é estável.
// Os itens são cópias novas que NÃO viram espólio (só com Cemitério Itinerante).
// =====================================================================

this.necro_reanimado <- this.inherit("scripts/entity/tactical/necro/necro_undead", {
	m = {
		CopiedItems = []
	},
	function create()
	{
		this.m.TipoID = "reanimado";
		this.m.AgentScript = "scripts/ai/tactical/agents/necro_melee_agent";
		this.m.EntityType = this.Const.EntityType.SkeletonMedium;
		this.necro_undead.create();
		this.getFlags().add("necro_reanimado");
	}

	function onNecroEquip( _items )
	{
	}

	function getCopiedItems()
	{
		return this.m.CopiedItems;
	}

	function setupFromCorpse( _info, _escala )
	{
		local util = this.Const.Necro.Util;
		local C = this.Const.Necro.Sub.Coveiro;
		local masterID = this.getFlags().getAsInt(util.FlagMestre);
		local bonus = 1.0;

		if (_info.Elite && util.hasPerkByMasterID(masterID, "perk.necro_exercito_roubado"))
		{
			bonus = 1.0 + C.RoubadoBonus;
			this.getFlags().add("necro_roubado");
		}

		local b = this.m.BaseProperties;
		b.Hitpoints = this.Math.max(1, this.Math.round(_info.Hitpoints * _escala * bonus));
		b.MeleeSkill = this.Math.round(_info.MeleeSkill * _escala);
		b.RangedSkill = this.Math.round(_info.RangedSkill * _escala);
		b.MeleeDefense = this.Math.round(_info.MeleeDefense * _escala);
		b.RangedDefense = this.Math.round(_info.RangedDefense * _escala);
		b.Initiative = this.Math.round(_info.Initiative * _escala);
		this.setName("Reanimado: " + _info.Nome);

		// Equipamento do morto (cópias novas, fora do loot).
		this.m.CopiedItems = [];

		foreach( script in _info.Itens )
		{
			try
			{
				local item = this.new(script);
				item.m.IsDroppedAsLoot = false;

				if (item.isItemType(this.Const.Items.ItemType.Ammo))
				{
					item.m.Ammo = this.Const.Necro.MORTOS_MUNICAO;
					item.m.AmmoMax = this.Const.Necro.MORTOS_MUNICAO;
				}

				this.m.Items.equip(item);
				this.m.CopiedItems.push(script);
			}
			catch( e )
			{
				this.logWarning("Necromante: item do cadáver não pôde ser copiado: " + script);
			}
		}

		// Memória do Cadáver: metade das habilidades próprias do original.
		if (util.hasPerkByMasterID(masterID, "perk.necro_memoria_do_cadaver"))
		{
			local n = this.Math.ceil(_info.Ativas.len() * C.MemoriaFracao);

			for( local i = 0; i < n; i = ++i )
			{
				try
				{
					this.m.Skills.add(this.new(_info.Ativas[i]));
				}
				catch( e )
				{
				}
			}
		}

		if (_info.Distancia)
		{
			this.m.AIAgent = this.new("scripts/ai/tactical/agents/necro_ranged_agent");
			this.m.AIAgent.setActor(this);
			this.getFlags().add("necro_reanimado_distancia");
		}

		// Sem Descanso: não se desfaz; senão, conta os turnos.
		if (!util.hasPerkByMasterID(masterID, "perk.necro_sem_descanso"))
		{
			this.getFlags().set("necro_expira", C.ReanimadoDuracao);
		}

		util.getRuntime().Reanimados[this.getID()] <- {
			MasterID = masterID,
			Itens = this.m.CopiedItems,
			Info = _info
		};
		this.getSkills().update();
		this.m.Hitpoints = this.getHitpointsMax();
	}

	function makeFractured()
	{
	}

});
