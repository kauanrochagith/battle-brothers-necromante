// =====================================================================
// MOD NECROMANTE - Racial dos mortos invocados (oculta)
// ---------------------------------------------------------------------
// Toda a "inteligência" passiva de um morto fica aqui:
//   - aplica Veneno/Necrose ao acertar (onTargetHit);
//   - credita XP ao Necromante quando mata (onTargetKilled);
//   - bônus dos perks do Necromante (lidos do cache de perks);
//   - efeitos de classe (Carniceiro, Besteiro, aura do Paladino, Caçador,
//     Torre, Abominação, Reanimado);
//   - regras passivas das 8 subclasses (Legião, Lich, Peste, Cavaleiro,
//     Atirador, Coveiro, Ossário, Maestro);
//   - Elo Sombrio (onDamageReceived roda ANTES de o HP cair);
//   - Exército Sem Fim e demais gatilhos de morte (onDeath).
//
// IMPORTANTE: onAnySkillUsed também é chamado em PRÉVIAS (tooltip de
// acerto, avaliação da IA). Por isso aqui só se LÊ estado; contadores
// (Sincronia, Disparo Coordenado, Disparo Triplo) sobem só em
// onTargetHit/onTargetMissed, que acontecem em ataques de verdade.
// =====================================================================

this.necro_undead_racial <- this.inherit("scripts/skills/skill", {
	m = {},
	function create()
	{
		this.m.ID = "racial.necro_undead";
		this.m.Name = "Morto Erguido";
		this.m.Description = "Um morto erguido por um Necromante. Não sente medo, não foge e não sangra.";
		this.m.Icon = "skills/status_effect_69.png";
		this.m.Type = this.Const.SkillType.Racial | this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.Last;
		this.m.IsActive = false;
		this.m.IsHidden = false;
		this.m.IsStacking = false;
		this.m.IsSerialized = false;
	}

	function getActor()
	{
		return this.getContainer().getActor();
	}

	function getUtil()
	{
		return this.Const.Necro.Util;
	}

	function getMasterID()
	{
		return this.Const.Necro.Util.getMasterID(this.getActor());
	}

	function hasPerk( _id )
	{
		return this.getUtil().hasPerkByMasterID(this.getMasterID(), _id);
	}

	function getTipo()
	{
		return this.getActor().getFlags().get(this.Const.Necro.Util.FlagTipo);
	}

	function getTipoInfo()
	{
		local tipo = this.getTipo();
		return tipo != null && tipo in this.Const.Necro.Tipos ? this.Const.Necro.Tipos[tipo] : null;
	}

	function isMage()
	{
		return this.getUtil().isMage(this.getActor());
	}

	// Magos herdam 50% das passivas (Lich); "Eco Perfeito" sobe para 100%.
	function getPassiveMult()
	{
		if (!this.isMage())
		{
			return 1.0;
		}

		if (this.hasPerk("perk.necro_eco_perfeito"))
		{
			return 1.0;
		}

		return this.Const.Necro.Perks.ECO_POTENCIA;
	}

	function isRangedUnit()
	{
		local t = this.getTipoInfo();

		if (t != null && t.Distancia)
		{
			return true;
		}

		return this.getActor().getFlags().has("necro_reanimado_distancia");
	}

	function getRound()
	{
		return this.Time.getRound();
	}

	function getTooltip()
	{
		local ret = [
			{
				id = 1,
				type = "title",
				text = this.getName()
			},
			{
				id = 2,
				type = "description",
				text = this.getDescription()
			}
		];
		local flags = this.getActor().getFlags();

		if (flags.has(this.Const.Necro.Util.FlagFraturado))
		{
			ret.push({
				id = 10,
				type = "text",
				icon = "ui/icons/warning.png",
				text = "[color=" + this.Const.UI.Color.NegativeValue + "]Fraturado[/color]: metade da vida, da armadura e do dano"
			});
		}

		if (flags.has("necro_estandarte"))
		{
			ret.push({
				id = 11,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Porta o [color=" + this.Const.UI.Color.PositiveValue + "]Estandarte Ósseo[/color]"
			});
		}

		if (flags.has("necro_expira"))
		{
			ret.push({
				id = 12,
				type = "text",
				icon = "ui/icons/warning.png",
				text = "Vira pó em [color=" + this.Const.UI.Color.NegativeValue + "]" + flags.getAsInt("necro_expira") + "[/color] turno(s)"
			});
		}

		if (flags.has("necro_recarregando"))
		{
			ret.push({
				id = 13,
				type = "text",
				icon = "ui/icons/warning.png",
				text = "Recarregando o arco: não atira neste turno"
			});
		}

		return ret;
	}

	// ---------------------------------------------------------------
	// Atributos contínuos
	// ---------------------------------------------------------------
	function onUpdate( _properties )
	{
		local P = this.Const.Necro.Perks;
		local S = this.Const.Necro.Sub;
		local util = this.getUtil();
		local actor = this.getActor();
		local flags = actor.getFlags();
		local masterID = this.getMasterID();
		local passive = this.getPassiveMult();
		local t = this.getTipoInfo();
		local tipo = this.getTipo();
		local naMapa = actor.isPlacedOnMap() && util.isInCombat();

		// Mortos ignoram moral (MoraleState.Ignore) e estes efeitos da morte de aliados.
		_properties.IsAffectedByDyingAllies = false;
		_properties.IsAffectedByFleeingAllies = false;
		_properties.IsAffectedByLosingHitpoints = false;

		if (passive > 0 && this.hasPerk("perk.necro_ossos_reforcados"))
		{
			_properties.MeleeDefense += this.Math.round(P.OSSOS_DEFESA * passive);
			_properties.RangedDefense += this.Math.round(P.OSSOS_DEFESA * passive);
		}

		if (passive > 0 && naMapa && this.hasPerk("perk.necro_voz_do_necromante"))
		{
			local master = util.getMaster(actor);

			if (master != null && master.getTile().getDistanceTo(actor.getTile()) <= P.VOZ_RAIO)
			{
				_properties.Initiative += this.Math.round(P.VOZ_INICIATIVA * passive);
				_properties.Bravery += this.Math.round(P.VOZ_RESOLUCAO * passive);
			}
		}

		// Dano próprio do tipo (Rato, Caçador, Torre).
		if (t != null && "DanoMult" in t)
		{
			_properties.DamageTotalMult *= t.DanoMult;
		}

		// Torre de Ossos: não anda.
		if (t != null && "Imovel" in t && t.Imovel)
		{
			_properties.IsRooted = true;
		}

		// Abominação Alfa: imune a empurrão e atordoamento (moral já é ignorada).
		if (flags.has("necro_alfa"))
		{
			_properties.IsImmuneToKnockBackAndGrab = true;
			_properties.IsImmuneToStun = true;
		}

		// Exército Roubado: reanimado de elite.
		if (flags.has("necro_roubado"))
		{
			_properties.DamageTotalMult *= 1.0 + S.Coveiro.RoubadoBonus;
		}

		if (!this.isMage())
		{
			if (this.hasPerk("perk.necro_essencia_morta"))
			{
				local e = util.getEssence(masterID);
				_properties.MeleeSkillMult *= 1.0 + e * P.ESSENCIA_HAB;
				_properties.RangedSkillMult *= 1.0 + e * P.ESSENCIA_HAB;
			}

			if (this.isRangedUnit())
			{
				if (this.hasPerk("perk.necro_alcance_dos_mortos"))
				{
					_properties.Vision += P.ALCANCE_DOS_MORTOS_VISAO;
				}

				// Visão Espectral (Atirador).
				if (this.hasPerk("perk.necro_visao_espectral"))
				{
					_properties.Vision += S.Atirador.VisaoExtra;
				}

				// Postura Fantasma (Atirador): PA extra para andar e atirar.
				if (this.hasPerk("perk.necro_postura_fantasma"))
				{
					_properties.ActionPoints += S.Atirador.PosturaPA;
				}
			}

			if (P.PUTREFACAO_PENALIDADE_HP > 0 && this.hasPerk("perk.necro_putrefacao_redobrada"))
			{
				_properties.HitpointsMult *= 1.0 - P.PUTREFACAO_PENALIDADE_HP;
			}

			// Elite Funesta (Cavaleiro): +30% de dano.
			if (this.hasPerk("perk.necro_elite_funesta"))
			{
				_properties.DamageTotalMult *= 1.0 + S.Cavaleiro.EliteDano;
			}

			// Caçador Espectral: atira a cada 2 turnos (Olho do Caçador: todo turno, +10 Hab. Dist.).
			if (tipo == "cacador")
			{
				if (this.hasPerk("perk.necro_olho_do_cacador"))
				{
					_properties.RangedSkill += S.Atirador.OlhoHabDist;
				}
				else if (flags.has("necro_recarregando"))
				{
					_properties.IsAbleToUseWeaponSkills = false;
				}
			}

			if (naMapa)
			{
				this.updateLegion(_properties, masterID);
				this.updateOrders(_properties, masterID);
			}
		}
		else
		{
			// O Mago "chama" a atenção dos inimigos e é protegido pelos Paladinos/Sentinelas (ai_protect vanilla).
			_properties.TargetAttractionMult *= this.Const.Necro.Mago.AtracaoIA;
		}

		if (flags.has(util.FlagFraturado))
		{
			_properties.DamageTotalMult *= P.FRATURADO_MULT;
		}
	}

	// Senhor da Legião: Parede de Escudos Mortos, Capitão, Estandarte, Veteranos.
	function updateLegion( _properties, _masterID )
	{
		local L = this.Const.Necro.Sub.Legiao;
		local util = this.getUtil();
		local actor = this.getActor();
		local myTile = actor.getTile();

		if (this.hasPerk("perk.necro_parede_escudos_mortos"))
		{
			local n = 0;

			foreach( e in util.getAdjacentActors(myTile) )
			{
				if (util.isSummon(e) && e.getFlags().getAsInt(util.FlagMestre) == _masterID && e.isArmedWithShield())
				{
					n = ++n;
				}
			}

			local bonus = this.Math.min(L.ParedeDefesaMax, n * L.ParedeDefesaPorEscudo);
			_properties.MeleeDefense += bonus;
			_properties.RangedDefense += bonus;
		}

		if (this.hasPerk("perk.necro_cadeia_de_comando"))
		{
			local cap = util.getCaptain(_masterID);

			if (cap != null && cap.getTile().getDistanceTo(myTile) <= L.CapitaoRaio)
			{
				_properties.DamageTotalMult *= 1.0 + L.CapitaoDano;
				_properties.Bravery += L.CapitaoResolucao;
			}
		}

		if (this.hasPerk("perk.necro_estandarte_osseo"))
		{
			local bearer = util.getBannerBearer(_masterID);

			if (bearer != null && bearer.getTile().getDistanceTo(myTile) <= L.EstandarteRaio)
			{
				_properties.DamageTotalMult *= 1.0 + L.EstandarteDano;
				_properties.Bravery += L.EstandarteResolucao;
			}
		}

		if (this.hasPerk("perk.necro_veteranos_eternos"))
		{
			local kills = actor.getFlags().getAsInt("necro_kills");
			_properties.MeleeSkill += this.Math.min(L.VeteranoHabMax, kills * L.VeteranoHabPorKill);
		}
	}

	// Maestro dos Ossos: Ordens ativas (Ataque Total, Muralha) e Crescendo.
	function updateOrders( _properties, _masterID )
	{
		local M = this.Const.Necro.Sub.Maestro;
		local util = this.getUtil();
		local ataque = util.getOrderMult(_masterID, "ataque");
		local muralha = util.getOrderMult(_masterID, "muralha");

		if (ataque > 0)
		{
			_properties.DamageTotalMult *= 1.0 + M.AtaqueTotalDano * ataque;
			_properties.MeleeSkill += this.Math.round(M.AtaqueTotalHab * ataque);
			_properties.RangedSkill += this.Math.round(M.AtaqueTotalHab * ataque);
			_properties.MeleeDefense -= this.Math.round(M.AtaqueTotalDefesa * ataque);
			_properties.RangedDefense -= this.Math.round(M.AtaqueTotalDefesa * ataque);
		}

		if (muralha > 0)
		{
			_properties.MeleeDefense += this.Math.round(M.MuralhaDefesa * muralha);
			_properties.RangedDefense += this.Math.round(M.MuralhaDefesa * muralha);
		}

		if (util.getActiveOrders(_masterID).len() != 0)
		{
			_properties.DamageTotalMult *= util.getCrescendoMult(_masterID);
		}
	}

	// Alcance: depois que todas as habilidades foram atualizadas.
	function onAfterUpdate( _properties )
	{
		if (this.isMage())
		{
			return;
		}

		local t = this.getTipoInfo();
		local ranged = this.hasPerk("perk.necro_alcance_dos_mortos") ? this.Const.Necro.Perks.ALCANCE_DOS_MORTOS : 0;
		local all = this.hasPerk("perk.necro_alcance_independente") ? this.Const.Necro.Perks.ALCANCE_INDEPENDENTE : 0;

		if (t != null && "AlcanceExtra" in t)
		{
			ranged = ranged + t.AlcanceExtra;
		}

		this.getUtil().applyRangeBonus(this.getActor(), ranged, all);

		// Torre de Ossos: alcance fixo (mais os bônus de perk).
		if (t != null && "AlcanceFixo" in t)
		{
			foreach( s in this.getActor().getSkills().m.Skills )
			{
				if (!s.isGarbage() && s.isAttack() && s.isActive() && s.isRanged())
				{
					s.m.MaxRange = t.AlcanceFixo + ranged + all;
				}
			}
		}
	}

	// ---------------------------------------------------------------
	// Ataque
	// ---------------------------------------------------------------
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == null || !_skill.isAttack())
		{
			return;
		}

		local P = this.Const.Necro.Perks;
		local S = this.Const.Necro.Sub;
		local util = this.getUtil();
		local actor = this.getActor();
		local tipo = this.getTipo();
		local masterID = this.getMasterID();
		local rt = util.getRuntime();
		local ranged = _skill.isRanged();

		// Disciplina Morta: bônus por morto aliado adjacente.
		if (this.hasPerk("perk.necro_disciplina_morta") && actor.isPlacedOnMap())
		{
			local n = 0;

			foreach( e in util.getAdjacentActors(actor.getTile()) )
			{
				if (util.isSummon(e))
				{
					n = ++n;
				}
			}

			n = this.Math.min(n, P.DISCIPLINA_MAX_ALIADOS);
			_properties.DamageTotalMult *= 1.0 + n * P.DISCIPLINA_DANO;
			_properties.MeleeSkill += n * P.DISCIPLINA_HAB;
			_properties.RangedSkill += n * P.DISCIPLINA_HAB;
		}

		// Essência Morta: dano necromântico.
		_properties.DamageTotalMult *= util.getEssenceDamageMult(masterID);

		if (tipo == "carniceiro" && !ranged)
		{
			_properties.DamageDirectAdd += this.Const.Necro.CARNICEIRO_IGNORA_ARMADURA;
		}
		else if (tipo == "besteiro" && ranged)
		{
			_properties.DamageTotalMult *= 1.0 + this.Const.Necro.BESTEIRO_DANO;
			_properties.DamageDirectAdd += this.Const.Necro.BESTEIRO_IGNORA_ARMADURA;
		}

		// Ataque grátis com bônus (Carga Fúnebre, Execução Sombria, Saraivada, Disparo Triplo).
		if (actor.getID() in rt.AtaqueBonus)
		{
			local b = rt.AtaqueBonus[actor.getID()];
			_properties.MeleeSkill += b.Acerto;
			_properties.RangedSkill += b.Acerto;
			_properties.DamageTotalMult *= 1.0 + b.Dano;
		}

		// Baixas Aceitáveis: o efeito no morto guarda o bônus.
		local baixas = actor.getSkills().getSkillByID("effects.necro_baixas");

		if (baixas != null)
		{
			_properties.DamageTotalMult *= 1.0 + baixas.getBonus();
		}

		if (_targetEntity != null)
		{
			// Marca do Caçador (Atirador): +20% acerto e +15% dano à distância.
			local hunt = _targetEntity.getSkills().getSkillByID("effects.necro_hunter_mark");

			if (ranged && hunt != null && hunt.getMasterID() == masterID)
			{
				_properties.RangedSkill += S.Atirador.MarcaAcerto;
				_properties.DamageTotalMult *= 1.0 + S.Atirador.MarcaDano;
			}

			// Flanco Sombrio (Legião): alvo já cercado por outro morto aliado.
			if (!ranged && this.hasPerk("perk.necro_flanco_sombrio") && _targetEntity.isPlacedOnMap())
			{
				foreach( e in util.getAdjacentActors(_targetEntity.getTile()) )
				{
					if (e.getID() != actor.getID() && util.isSummon(e) && e.getFlags().getAsInt(util.FlagMestre) == masterID)
					{
						_properties.MeleeSkill += S.Legiao.FlancoAcerto;
						break;
					}
				}
			}

			// Sincronia (Maestro): 3+ ataques no mesmo alvo nesta rodada.
			if (this.hasPerk("perk.necro_sincronia"))
			{
				local key = this.getRound() + ":" + _targetEntity.getID();
				local n = (key in rt.Sincronia) ? rt.Sincronia[key] : 0;

				if (n >= S.Maestro.SincroniaMinimo)
				{
					_properties.DamageTotalMult *= 1.0 + this.Math.minf(S.Maestro.SincroniaDanoMax, (n - S.Maestro.SincroniaMinimo + 1) * S.Maestro.SincroniaDano);
				}
			}

			// Disparo Coordenado (Maestro): cada atirador depois do primeiro ganha acerto.
			local disparo = util.getOrderMult(masterID, "disparo");

			if (ranged && disparo > 0 && masterID in rt.CoordAlvo)
			{
				local c = rt.CoordAlvo[masterID];

				if (c.Alvo == _targetEntity.getID() && c.Rodada == this.getRound())
				{
					_properties.RangedSkill += this.Math.round(this.Math.min(S.Maestro.DisparoAcertoMax, c.Tiros * S.Maestro.DisparoAcertoPorAtirador) * disparo);
				}
			}
		}

		if (ranged)
		{
			// Flechas Perfurantes (Atirador).
			if (this.hasPerk("perk.necro_flechas_perfurantes"))
			{
				_properties.DamageDirectAdd += S.Atirador.PerfurantesIgnora;
			}

			// Postura Fantasma: tiro depois de andar neste turno tem penalidade.
			if (this.hasPerk("perk.necro_postura_fantasma") && actor.getFlags().getAsInt("necro_andou") == this.getRound())
			{
				_properties.RangedSkill -= S.Atirador.PosturaPenalidade;
			}
		}

		// Partitura Tática (Maestro): Ataque Total / Disparo Coordenado ignoram mais armadura.
		if (this.hasPerk("perk.necro_partitura_tatica"))
		{
			local m = this.Math.maxf(util.getOrderMult(masterID, "ataque"), ranged ? util.getOrderMult(masterID, "disparo") : 0.0);
			_properties.DamageDirectAdd += S.Maestro.PartituraIgnora * m;
		}
	}

	// Contadores de ataques REAIS (acerto ou erro).
	function onRealAttack( _skill, _targetEntity )
	{
		if (_skill == null || !_skill.isAttack() || _targetEntity == null)
		{
			return;
		}

		local S = this.Const.Necro.Sub;
		local util = this.getUtil();
		local actor = this.getActor();
		local masterID = this.getMasterID();
		local rt = util.getRuntime();

		if (this.hasPerk("perk.necro_sincronia"))
		{
			local key = this.getRound() + ":" + _targetEntity.getID();
			rt.Sincronia[key] <- ((key in rt.Sincronia) ? rt.Sincronia[key] : 0) + 1;
		}

		if (_skill.isRanged())
		{
			if (util.getOrderMult(masterID, "disparo") > 0)
			{
				if (masterID in rt.CoordAlvo && rt.CoordAlvo[masterID].Alvo == _targetEntity.getID() && rt.CoordAlvo[masterID].Rodada == this.getRound())
				{
					rt.CoordAlvo[masterID].Tiros = rt.CoordAlvo[masterID].Tiros + 1;
				}
				else
				{
					rt.CoordAlvo[masterID] <- {
						Alvo = _targetEntity.getID(),
						Tiros = 1,
						Rodada = this.getRound()
					};
				}
			}

			// Caçador Espectral: depois de atirar, recarrega no turno seguinte.
			if (this.getTipo() == "cacador")
			{
				actor.getFlags().add("necro_cacador_atirou");
			}

			this.tryTripleShot(_skill, _targetEntity);
		}
	}

	// Disparo Triplo (Atirador): primeiro tiro do turno com o PA cheio vira 3 tiros.
	function tryTripleShot( _skill, _targetEntity )
	{
		local S = this.Const.Necro.Sub.Atirador;
		local util = this.getUtil();
		local actor = this.getActor();
		local rt = util.getRuntime();

		if (!this.hasPerk("perk.necro_disparo_triplo") || actor.getID() in rt.AtaqueBonus)
		{
			return;
		}

		if (actor.getFlags().getAsInt("necro_triplo") == this.getRound())
		{
			return;
		}

		// PA cheio antes do tiro = PA atual + custo do tiro.
		if (actor.getActionPoints() + _skill.getActionPointCost() < actor.getActionPointsMax())
		{
			return;
		}

		actor.getFlags().set("necro_triplo", this.getRound());
		local bonus = {
			Acerto = -S.TriploPenalidade,
			Dano = 0.0
		};

		for( local i = 1; i < S.TriploTiros; i = ++i )
		{
			util.scheduleAttack(actor, _targetEntity, 400 * i, bonus);
		}

		actor.setActionPoints(0);
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		this.getUtil().applyOnHit(this.getActor(), _targetEntity, _skill, _damageInflictedHitpoints, _damageInflictedArmor);
		this.onRealAttack(_skill, _targetEntity);
	}

	function onTargetMissed( _skill, _targetEntity )
	{
		this.onRealAttack(_skill, _targetEntity);
	}

	// XP para o Necromante + carga de Essência Morta + Veteranos + Execução à Distância.
	function onTargetKilled( _targetEntity, _skill )
	{
		if (_targetEntity == null || _targetEntity.isAlliedWith(this.getActor()))
		{
			return;
		}

		local util = this.getUtil();
		local actor = this.getActor();
		local masterID = this.getMasterID();
		util.addEssence(masterID);
		local master = util.getMaster(actor);

		if (master != null)
		{
			local xp = this.Math.floor(_targetEntity.getXPValue() * this.Const.Necro.XP_MORTOS_PARA_NECRO);

			if (xp > 0)
			{
				master.addXP(xp);
			}
		}

		// Veteranos Eternos (Legião): conta kills.
		if (this.hasPerk("perk.necro_veteranos_eternos"))
		{
			actor.getFlags().set("necro_kills", actor.getFlags().getAsInt("necro_kills") + 1);
		}

		// Execução à Distância (Atirador): alvo marcado morto.
		if (this.hasPerk("perk.necro_execucao_a_distancia") && _targetEntity.getSkills().hasSkill("effects.necro_hunter_mark"))
		{
			if (master != null)
			{
				local mark = master.getSkills().getSkillByID("actives.necro_shooter_mark");

				if (mark != null)
				{
					mark.resetCooldown();
				}
			}

			actor.setActionPoints(this.Math.min(actor.getActionPointsMax(), actor.getActionPoints() + 1));
		}
	}

	// ---------------------------------------------------------------
	// Turno do morto
	// ---------------------------------------------------------------
	function onTurnStart()
	{
		local S = this.Const.Necro.Sub;
		local util = this.getUtil();
		local actor = this.getActor();
		local flags = actor.getFlags();
		local tipo = this.getTipo();

		// Caçador Espectral: atirou no turno anterior -> recarrega neste.
		if (tipo == "cacador")
		{
			if (flags.has("necro_cacador_atirou"))
			{
				flags.remove("necro_cacador_atirou");
				flags.add("necro_recarregando");
			}
			else
			{
				flags.remove("necro_recarregando");
			}
		}

		// Imunidade Mórbida (Peste): Putrefatos regeneram.
		if (tipo == "putrefato" && this.hasPerk("perk.necro_imunidade_morbida"))
		{
			util.heal(actor, S.Peste.PutrefatoRegen);
		}

		// Costura de Ossos (Ossário): Abominação com esqueleto adjacente regenera.
		if (tipo == "abominacao" && this.hasPerk("perk.necro_costura_de_ossos") && actor.isPlacedOnMap())
		{
			foreach( e in util.getAdjacentActors(actor.getTile()) )
			{
				local t = e.getFlags().get(util.FlagTipo);

				if (util.isSummon(e) && (t == "guerreiro" || t == "arqueiro"))
				{
					util.heal(actor, this.Math.max(1, this.Math.floor(actor.getHitpointsMax() * S.Ossario.CosturaRegen)));
					break;
				}
			}
		}

		// Escudeiro: escolta o Necromante (volta para o lado dele se ficou longe).
		if (tipo == "escudeiro")
		{
			this.guardStep();
		}

		// Reanimado do Coveiro: vira pó depois de alguns turnos.
		if (flags.has("necro_expira"))
		{
			local left = flags.getAsInt("necro_expira") - 1;

			if (left <= 0)
			{
				if (!actor.isHiddenToPlayer())
				{
					this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(actor) + " se desfaz em pó");
				}

				util.consumeSilently(actor);
				return;
			}

			flags.set("necro_expira", left);
		}
	}

	// Escudeiro Esquelético: se não está ao lado do Necromante, anda até um
	// tile livre adjacente a ele (até 4 tiles), antes de agir.
	function guardStep()
	{
		local util = this.getUtil();
		local actor = this.getActor();
		local master = util.getMaster(actor);

		if (master == null || !actor.isPlacedOnMap() || actor.getCurrentProperties().IsRooted)
		{
			return;
		}

		if (actor.getTile().getDistanceTo(master.getTile()) <= 1)
		{
			return;
		}

		local dest = util.findTileAdjacentTo(master.getTile(), actor.getTile(), 4);

		if (dest != null)
		{
			this.Tactical.getNavigator().teleport(actor, dest, null, null, false, 0.0);
		}
	}

	function onMovementFinished()
	{
		this.getActor().getFlags().set("necro_andou", this.getRound());
	}

	// ---------------------------------------------------------------
	// Defesa
	// ---------------------------------------------------------------
	function onBeforeDamageReceived( _attacker, _skill, _hitInfo, _properties )
	{
		local passive = this.getPassiveMult();
		local util = this.getUtil();

		// Ossos Reforçados: menos dano de ataques (físicos).
		if (passive > 0 && _skill != null && _skill.isAttack() && this.hasPerk("perk.necro_ossos_reforcados"))
		{
			_properties.DamageReceivedTotalMult *= 1.0 - this.Const.Necro.Perks.OSSOS_REDUCAO_DANO * passive;
		}

		// Muralha (Maestro): resistência a dano.
		local muralha = util.getOrderMult(this.getMasterID(), "muralha");

		if (muralha > 0)
		{
			_properties.DamageReceivedTotalMult *= 1.0 - this.Const.Necro.Sub.Maestro.MuralhaResistencia * muralha;
		}

		// Égide Funesta: morto adjacente a um Paladino Sepulcral recebe menos dano.
		local actor = this.getActor();

		if (!actor.isPlacedOnMap())
		{
			return;
		}

		foreach( e in util.getAdjacentActors(actor.getTile()) )
		{
			if (util.isSummon(e) && e.getFlags().get(util.FlagTipo) == "paladino")
			{
				_properties.DamageReceivedTotalMult *= 1.0 - this.Const.Necro.PALADINO_AURA_REDUCAO;
				break;
			}
		}
	}

	// Elo Sombrio (Lich): só os MAGOS repassam 25% do dano ao Lich como Fadiga.
	// Este callback roda ANTES de o vanilla descontar o HP (ver actor.onDamageReceived).
	function onDamageReceived( _attacker, _damageHitpoints, _damageArmor )
	{
		if (_damageHitpoints <= 0 || !this.isMage() || !this.hasPerk("perk.necro_elo_sombrio"))
		{
			return;
		}

		local master = this.getUtil().getMaster(this.getActor());

		if (master == null)
		{
			return;
		}

		local absorbed = this.Math.floor(_damageHitpoints * this.Const.Necro.Perks.ELO_FRACAO);

		if (absorbed <= 0 || master.getFatigueMax() - master.getFatigue() < absorbed)
		{
			return;
		}

		local actor = this.getActor();
		actor.m.Hitpoints = actor.m.Hitpoints + absorbed;
		master.setFatigue(master.getFatigue() + absorbed);
	}

	// ---------------------------------------------------------------
	// Morte
	// ---------------------------------------------------------------
	function onDeath( _fatalityType )
	{
		local util = this.getUtil();
		local actor = this.getActor();

		// Consumidos (fusão, colapso, pó do reanimado) não disparam nada.
		if (util.getRuntime().Colapsando || this.isMage() || !actor.isPlacedOnMap())
		{
			return;
		}

		local master = util.getMaster(actor);
		local masterID = this.getMasterID();
		local tile = actor.getTile();
		local tipo = this.getTipo();
		local S = this.Const.Necro.Sub;

		// Estandarte Ósseo: o estandarte cai onde o portador morreu.
		if (actor.getFlags().has("necro_estandarte"))
		{
			util.dropBanner(masterID, tile);
		}

		// Baixas Aceitáveis: mortos adjacentes ganham dano.
		if (this.hasPerk("perk.necro_baixas_aceitaveis"))
		{
			foreach( e in util.getAdjacentActors(tile) )
			{
				if (util.isSummon(e) && e.getFlags().getAsInt(util.FlagMestre) == masterID && e.getID() != actor.getID())
				{
					local b = e.getSkills().getSkillByID("effects.necro_baixas");

					if (b == null)
					{
						b = this.new("scripts/skills/effects/necro_baixas_effect");
						e.getSkills().add(b);
					}

					b.addStack();
				}
			}
		}

		// Corpos Inchados (Peste): Putrefato libera gás venenoso.
		if (tipo == "putrefato" && this.hasPerk("perk.necro_corpos_inchados"))
		{
			foreach( e in util.getActorsInRadius(tile, S.Peste.GasRaio) )
			{
				if (!e.isAlliedWith(actor))
				{
					util.addStacks(e, util.VenenoID, S.Peste.GasAcumulos, masterID);
				}
			}
		}

		// Ceifador (Coveiro): o corpo deste morto pode ser reanimado (uma vez).
		if (this.hasPerk("perk.necro_ceifador") && !actor.getFlags().has("necro_reanimado"))
		{
			util.registerCorpse(actor);
		}

		if (master == null)
		{
			return;
		}

		local owner = this.Tactical.getEntityByID(actor.getFlags().getAsInt(util.FlagDono));

		if (owner == null || !util.isValidActor(owner))
		{
			owner = master;
		}

		// Respawns acontecem depois que o corpo sai do tile.
		local respawn = null;

		if (tipo == "cavaleiro" && !actor.getFlags().has("necro_lealdade") && this.hasPerk("perk.necro_lealdade_eterna"))
		{
			// Lealdade Eterna: o Cavaleiro volta uma vez com 50% de vida.
			respawn = {
				Tipo = "cavaleiro",
				Qtd = 1,
				HP = S.Cavaleiro.LealdadeHP,
				Flag = "necro_lealdade",
				Fraturado = false,
				Log = " volta da morte, leal ao seu senhor"
			};
		}
		else if (tipo == "abominacao" && this.hasPerk("perk.necro_ressurgir_dos_ossos"))
		{
			// Ressurgir dos Ossos: a Abominação se divide em Fraturados.
			respawn = {
				Tipo = "guerreiro",
				Qtd = S.Ossario.RessurgirQuantidade,
				HP = 1.0,
				Flag = null,
				Fraturado = true,
				Log = " se ergue dos restos da Abominação"
			};
		}
		else if (tipo == "reanimado" && !actor.getFlags().has("necro_voltou") && this.hasPerk("perk.necro_sem_descanso"))
		{
			// Sem Descanso (Coveiro): o reanimado volta uma vez.
			local rt = util.getRuntime();
			local info = (actor.getID() in rt.Reanimados) && ("Info" in rt.Reanimados[actor.getID()]) ? rt.Reanimados[actor.getID()].Info : null;

			if (info != null)
			{
				respawn = {
					Tipo = "reanimado",
					Qtd = 1,
					HP = S.Coveiro.SemDescansoHP,
					Flag = "necro_voltou",
					Fraturado = false,
					Info = info,
					Log = " não aceita o descanso"
				};
			}
		}
		else if (!actor.getFlags().has(util.FlagFraturado) && this.hasPerk("perk.necro_exercito_sem_fim") && this.Math.rand(1, 100) <= this.Const.Necro.Perks.EXERCITO_CHANCE)
		{
			// Exército Sem Fim: chance de se reerguer como Fraturado (uma vez só).
			util.spawnFracturedNear(tipo, tile, master, owner);
		}

		if (respawn == null)
		{
			return;
		}

		respawn.Master <- master;
		respawn.Owner <- owner;
		respawn.Tile <- tile;
		this.Time.scheduleEvent(this.TimeUnit.Virtual, 250, function ( _r )
		{
			local u = this.Const.Necro.Util;

			if (!u.isInCombat() || !u.isValidActor(_r.Master))
			{
				return;
			}

			local t = this.Const.Necro.Tipos[_r.Tipo];

			for( local i = 0; i < _r.Qtd; i = ++i )
			{
				if (u.getFreeSlots(_r.Master.getID(), u.getTypeWeight(_r.Tipo)) <= 0)
				{
					return;
				}

				local tiles = u.findSpawnTiles(_r.Tile, 1, t.Distancia, _r.Owner);

				if (tiles.len() == 0)
				{
					return;
				}

				local e = u.spawnSummon(t.Script, tiles[0], _r.Master, _r.Owner, _r.Fraturado);

				if ("Info" in _r)
				{
					e.setupFromCorpse(_r.Info, u.getReanimateScale(_r.Master.getID()));
				}

				if (_r.Flag != null)
				{
					e.getFlags().add(_r.Flag);
				}

				if (_r.HP < 1.0)
				{
					e.setHitpoints(this.Math.max(1, this.Math.floor(e.getHitpointsMax() * _r.HP)));
				}

				if (!e.isHiddenToPlayer())
				{
					this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(e) + _r.Log);
				}
			}
		}.bindenv(this), respawn);
	}

});
