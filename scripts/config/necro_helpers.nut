// =====================================================================
// MOD NECROMANTE - FUNÇÕES AUXILIARES (Const.Necro.Util)
// ---------------------------------------------------------------------
// Lógica compartilhada por habilidades, efeitos e entidades:
//   - estado por combate (contadores, cache de perks)
//   - quem é Necromante / morto / Mago e quem é o "mestre" de cada morto
//   - busca de tiles e spawn de mortos
//   - aplicação de Veneno do Cadáver e Necrose
//
// Carregado automaticamente por estar em scripts/config/.
// Aqui usamos "::" para acessar globais do jogo (Tactical, Const, Math...),
// porque dentro de uma tabela "this" é a própria tabela Util.
// =====================================================================

local gt = this.getroottable();

if (!("Necro" in gt.Const))
{
	gt.Const.Necro <- {};
}

gt.Const.Necro.Util <- {
	// -----------------------------------------------------------------
	// IDs usados em flags e skills
	// -----------------------------------------------------------------
	BackgroundID = "background.necro_necromancer",
	FlagMorto = "necro_summon",
	FlagMago = "necro_mago",
	FlagFraturado = "necro_fraturado",
	FlagMestre = "necro_master",
	FlagDono = "necro_owner",
	FlagTipo = "necro_tipo",
	FlagTipoSelecionado = "necro_tipo_sel",
	VenenoID = "effects.necro_poison",
	NecroseID = "effects.necro_necrosis",
	MarcaID = "effects.necro_mark",

	// =================================================================
	// ESTADO POR COMBATE
	// -----------------------------------------------------------------
	// Guardado numa tabela global que é recriada quando muda o combate
	// (comparamos com o objeto Tactical.State atual). Nada disso vai para
	// o save: o vanilla não salva no meio do combate.
	// =================================================================
	function getRuntime()
	{
		local root = ::getroottable();
		local state = ("State" in ::Tactical) ? ::Tactical.State : null;

		if (!("NecroRuntime" in root) || root.NecroRuntime == null || root.NecroRuntime.State != state)
		{
			root.NecroRuntime <- {
				State = state,
				PerkCache = {},
				SubclassCache = {},
				Essencia = {},
				PactoContagem = {},
				NivelMestre = {},         // ID do mestre -> nível (limite de mortos e equipamento)
				MagoInvocacoes = {},
				SubstitutoUsado = {},
				Colapsando = false,

				// Subclasses (tudo por ID do Necromante mestre)
				Nuvens = [],              // Peste: nuvens ativas {Tile, Raio, Turnos, MasterID}
				HospedeiroContagem = {},  // Peste: Putrefatos criados por Hospedeiro
				FilacterioUsado = {},     // Lich
				Capitao = {},             // Legião: {ID, Espera}
				Estandarte = {},          // Legião: {ID, Tile, Espera}
				Cadaveres = {},           // Coveiro: ID do morto -> dados do cadáver
				Reanimados = {},          // Coveiro: ID do reanimado -> itens (Cemitério Itinerante)
				CampoAntigoFeito = {},    // Coveiro
				Ordens = {},              // Maestro: mestre -> [{ID, Turnos, Mult}]
				OrdemCrescendo = {},      // Maestro: mestre -> {ID, Turnos}
				OpusUsado = {},           // Maestro
				Sincronia = {},           // Maestro: "rodada:alvo" -> nº de ataques
				CoordAlvo = {},           // Maestro: mestre -> {Alvo, Tiros, Rodada}
				ChuvaContador = {},       // Atirador
				AtaqueBonus = {},         // ataque grátis: ID do atacante -> {Acerto, Dano}
				SentinelaUsada = {}       // Cavaleiro: ID do morto -> rodada
			};
		}

		return root.NecroRuntime;
	}

	function clearRuntime()
	{
		::getroottable().NecroRuntime <- null;
	}

	function isInCombat()
	{
		return ("State" in ::Tactical) && ::Tactical.State != null;
	}

	// =================================================================
	// IDENTIFICAÇÃO
	// =================================================================
	function isValidActor( _a )
	{
		return _a != null && _a.isAlive() && !_a.isDying() && _a.isPlacedOnMap();
	}

	function isNecromancer( _a )
	{
		return _a != null && _a.getSkills().hasSkill(this.BackgroundID);
	}

	function isSummon( _a )
	{
		return _a != null && _a.getFlags().has(this.FlagMorto);
	}

	function isMage( _a )
	{
		return _a != null && _a.getFlags().has(this.FlagMago);
	}

	// ID do Necromante "mestre" (para o próprio Necromante, o ID dele mesmo).
	function getMasterID( _a )
	{
		if (_a == null)
		{
			return -1;
		}

		if (this.isSummon(_a))
		{
			// Antes de spawnSummon definir o mestre, a flag ainda não existe.
			return _a.getFlags().has(this.FlagMestre) ? _a.getFlags().getAsInt(this.FlagMestre) : -1;
		}

		if (this.isNecromancer(_a))
		{
			return _a.getID();
		}

		return -1;
	}

	// Retorna o Necromante vivo dono deste ator, ou null.
	function getMaster( _a )
	{
		local id = this.getMasterID(_a);

		if (id < 0)
		{
			return null;
		}

		local e = ::Tactical.getEntityByID(id);
		return this.isValidActor(e) ? e : null;
	}

	// =================================================================
	// PERKS
	// -----------------------------------------------------------------
	// Os mortos consultam os perks do Necromante por um cache montado no
	// início do turno dele e antes de cada invocação. Assim os mortos de um
	// Mago continuam com os bônus mesmo se o Necromante morrer.
	// =================================================================
	function cachePerks( _necro )
	{
		local set = {};

		foreach( id, info in ::Const.Necro.PerkInfo )
		{
			if (_necro.getSkills().hasSkill(id))
			{
				set[id] <- true;
			}
		}

		this.getRuntime().PerkCache[_necro.getID()] <- set;
		this.getRuntime().SubclassCache[_necro.getID()] <- this.getSubclass(_necro);
		return set;
	}

	// =================================================================
	// SUBCLASSES
	// -----------------------------------------------------------------
	// A subclasse jurada fica na flag "necro_subclass" do personagem (vai
	// para o save). null = ainda não jurou (níveis 1-2 ou save antigo).
	// =================================================================
	FlagSubclasse = "necro_subclass",

	function getSubclass( _necro )
	{
		if (_necro == null || !_necro.getFlags().has(this.FlagSubclasse))
		{
			return null;
		}

		local id = _necro.getFlags().get(this.FlagSubclasse);
		return (id in ::Const.Necro.Subclasses) ? id : null;
	}

	// Subclasse a partir do ID do Necromante (usa o cache do combate, para
	// funcionar mesmo depois que ele morre).
	function getSubclassByMasterID( _masterID )
	{
		local rt = this.getRuntime();

		if (_masterID in rt.SubclassCache)
		{
			return rt.SubclassCache[_masterID];
		}

		local e = ::Tactical.getEntityByID(_masterID);

		if (e != null && this.isNecromancer(e))
		{
			this.cachePerks(e);
			return rt.SubclassCache[_masterID];
		}

		return null;
	}

	function getSubclassInfo( _masterID )
	{
		local id = this.getSubclassByMasterID(_masterID);
		return id == null ? null : ::Const.Necro.Subclasses[id];
	}

	// Pode este personagem ter este perk? (tronco sempre; subclasse só a dele;
	// perks removidos só em save antigo, antes do Juramento)
	function isPerkAllowedFor( _necro, _perkID )
	{
		if (!(_perkID in ::Const.Necro.PerkInfo))
		{
			return true;
		}

		local dono = ::Const.Necro.PerkInfo[_perkID].Subclasse;
		local sub = this.getSubclass(_necro);

		if (dono == "tronco")
		{
			return true;
		}

		if (sub == null)
		{
			// Antes do Juramento só o tronco é oferecido; perks antigos de
			// saves anteriores ficam até a migração do Juramento.
			return true;
		}

		return dono == sub;
	}

	// Ativas concedidas pela subclasse (lista de scripts).
	function getSubclassActives( _subID )
	{
		return _subID == null ? [] : ::Const.Necro.Subclasses[_subID].Ativas;
	}

	function isActiveGrantedBySubclass( _necro, _activeID )
	{
		foreach( script in this.getSubclassActives(this.getSubclass(_necro)) )
		{
			if (this.getActiveIDFromScript(script) == _activeID)
			{
				return true;
			}
		}

		return false;
	}

	// Todas as ativas exclusivas de QUALQUER subclasse (para remover as que não pertencem).
	function getAllSubclassActiveIDs()
	{
		local ret = {};

		foreach( subID, s in ::Const.Necro.Subclasses )
		{
			foreach( script in s.Ativas )
			{
				ret[this.getActiveIDFromScript(script)] <- subID;
			}
		}

		return ret;
	}

	// "scripts/skills/actives/necro_mark" -> "actives.necro_mark"
	function getActiveIDFromScript( _script )
	{
		local idx = 0;

		for( local i = 0; i < _script.len(); i = ++i )
		{
			if (_script[i] == '/')
			{
				idx = i + 1;
			}
		}

		return "actives." + _script.slice(idx);
	}

	function hasPerkByMasterID( _masterID, _perkID )
	{
		local cache = this.getRuntime().PerkCache;

		if (_masterID in cache)
		{
			return _perkID in cache[_masterID];
		}

		local e = ::Tactical.getEntityByID(_masterID);

		if (e != null && this.isNecromancer(e))
		{
			return _perkID in this.cachePerks(e);
		}

		return false;
	}

	function hasPerk( _a, _perkID )
	{
		local id = this.getMasterID(_a);

		if (id < 0)
		{
			return false;
		}

		return this.hasPerkByMasterID(id, _perkID);
	}

	// =================================================================
	// TIPOS DE MORTO POR SUBCLASSE (SUBCLASS_TYPES)
	// -----------------------------------------------------------------
	// Erguer o Morto e Alternar Tipo só oferecem os tipos da subclasse.
	// Tipos que ainda não existem em Const.Necro.Tipos (chegam na etapa da
	// subclasse) são pulados.
	// =================================================================
	function getTypeEntries( _masterID )
	{
		local info = this.getSubclassInfo(_masterID);
		local ret = [];

		if (info == null)
		{
			foreach( tipo in ::Const.Necro.TIPOS_SEM_SUBCLASSE )
			{
				local t = ::Const.Necro.Tipos[tipo];
				ret.push({
					Tipo = tipo,
					Grupo = t.Grupo,
					Cooldown = t.Cooldown
				});
			}

			return ret;
		}

		foreach( e in info.Tipos )
		{
			if (e.Tipo in ::Const.Necro.Tipos)
			{
				ret.push(e);
			}
		}

		return ret;
	}

	function getTypeEntry( _masterID, _tipo )
	{
		foreach( e in this.getTypeEntries(_masterID) )
		{
			if (e.Tipo == _tipo)
			{
				return e;
			}
		}

		return null;
	}

	function isTypeUnlocked( _masterID, _tipo )
	{
		return this.getTypeEntry(_masterID, _tipo) != null;
	}

	function getUnlockedTypes( _masterID )
	{
		local ret = [];

		foreach( e in this.getTypeEntries(_masterID) )
		{
			ret.push(e.Tipo);
		}

		return ret;
	}

	// Tamanho do grupo e cooldown base do tipo NESTA subclasse.
	function getTypeGroup( _masterID, _tipo )
	{
		local e = this.getTypeEntry(_masterID, _tipo);
		return e != null ? e.Grupo : ::Const.Necro.Tipos[_tipo].Grupo;
	}

	function getTypeBaseCooldown( _masterID, _tipo )
	{
		local e = this.getTypeEntry(_masterID, _tipo);
		return e != null ? e.Cooldown : ::Const.Necro.Tipos[_tipo].Cooldown;
	}

	// =================================================================
	// CONTAGEM DE MORTOS
	// -----------------------------------------------------------------
	// Varre só a facção PlayerAnimals (onde ficam os mortos), então é
	// barato mesmo com 30 mortos em campo.
	// =================================================================
	function getSummonsOfMaster( _masterID, _includeMages = false )
	{
		local ret = [];

		foreach( e in ::Tactical.Entities.getInstancesOfFaction(::Const.Faction.PlayerAnimals) )
		{
			if (!this.isValidActor(e) || !this.isSummon(e))
			{
				continue;
			}

			if (e.getFlags().getAsInt(this.FlagMestre) != _masterID)
			{
				continue;
			}

			if (this.isMage(e) && !_includeMages)
			{
				continue;
			}

			ret.push(e);
		}

		return ret;
	}

	function countSummons( _masterID )
	{
		return this.getSummonsOfMaster(_masterID, false).len();
	}

	function countMages( _masterID )
	{
		local n = 0;

		foreach( e in this.getSummonsOfMaster(_masterID, true) )
		{
			if (this.isMage(e))
			{
				n = ++n;
			}
		}

		return n;
	}

	// -----------------------------------------------------------------
	// LIMITE COM PESO POR UNIDADE
	// -----------------------------------------------------------------
	// Cada morto ocupa "necro_peso" vagas (padrão 1; Abominação = 5).
	// A contagem é refeita a partir dos mortos vivos em campo, então spawn,
	// morte, fusão e divisão já ficam corretos sem contador separado.
	// Magos só contam no limite quando a subclasse diz (Lich).
	// -----------------------------------------------------------------
	FlagPeso = "necro_peso",

	function getWeight( _e )
	{
		return _e.getFlags().has(this.FlagPeso) ? _e.getFlags().getAsInt(this.FlagPeso) : ::Const.Necro.PESO_PADRAO;
	}

	function countSummonWeight( _masterID )
	{
		local info = this.getSubclassInfo(_masterID);
		local magesCount = info != null && info.MagosContamNoLimite;
		local total = 0;

		foreach( e in this.getSummonsOfMaster(_masterID, magesCount) )
		{
			total = total + this.getWeight(e);
		}

		return total;
	}

	// =================================================================
	// EQUIPAMENTO POR NÍVEL
	// =================================================================

	// Faixa (0 a 5) do nível, pela tabela Equipamento.Faixas.
	function getGearTier( _level )
	{
		local faixas = ::Const.Necro.Equipamento.Faixas;
		local tier = 0;

		foreach( i, minimo in faixas )
		{
			if (_level >= minimo)
			{
				tier = i;
			}
		}

		return tier;
	}

	function pickFrom( _list )
	{
		if (_list == null || _list.len() == 0)
		{
			return null;
		}

		return _list[::Math.rand(0, _list.len() - 1)];
	}

	// Lista de scripts de item para um morto do papel _papel no nível _level.
	function pickEquipment( _papel, _level )
	{
		local eq = ::Const.Necro.Equipamento;
		local tier = this.getGearTier(_level);
		local ultimo = eq.Corpo.len() - 1;
		local lista = (_papel in eq.MesmaListaDe) ? eq.MesmaListaDe[_papel] : _papel;
		local ret = [];

		if (lista in eq.Armas)
		{
			local arma = this.pickFrom(eq.Armas[lista][::Math.min(tier, eq.Armas[lista].len() - 1)]);

			if (arma != null)
			{
				ret.push(arma);
			}
		}

		if (lista in eq.Escudos)
		{
			local escudo = this.pickFrom(eq.Escudos[lista][::Math.min(tier, eq.Escudos[lista].len() - 1)]);

			if (escudo != null)
			{
				ret.push(escudo);
			}
		}

		if (_papel in eq.Municao)
		{
			ret.push(eq.Municao[_papel]);
		}

		local desloc = (_papel in eq.Deslocamento) ? eq.Deslocamento[_papel] : 0;
		local faixaArmadura = ::Math.max(0, ::Math.min(ultimo, tier + desloc));
		local corpo = this.pickFrom(eq.Corpo[faixaArmadura]);
		local cabeca = this.pickFrom(eq.Cabeca[faixaArmadura]);

		if (corpo != null)
		{
			ret.push(corpo);
		}

		if (cabeca != null)
		{
			ret.push(cabeca);
		}

		return ret;
	}

	// Limite que vem do nível do Necromante: LIMITE_BASE no nível 1,
	// +LIMITE_POR_NIVEL por nível até LIMITE_NIVEL_MAX.
	function getLevelSummonLimit( _level )
	{
		local n = ::Const.Necro;
		local lvl = ::Math.max(1, ::Math.min(_level, n.LIMITE_NIVEL_MAX));
		return n.LIMITE_BASE + n.LIMITE_POR_NIVEL * (lvl - 1);
	}

	// Nível do Necromante. Se ele não estiver em campo (ex.: morreu e um Mago
	// continua invocando), usa o nível anotado no cache de perks.
	function getMasterLevel( _masterID )
	{
		local e = ::Tactical.getEntityByID(_masterID);

		if (e != null)
		{
			try
			{
				local lvl = e.getLevel();
				this.getRuntime().NivelMestre[_masterID] <- lvl;
				return lvl;
			}
			catch( err )
			{
			}
		}

		local rt = this.getRuntime();
		return (_masterID in rt.NivelMestre) ? rt.NivelMestre[_masterID] : 1;
	}

	function getMaxSummons( _masterID )
	{
		local max = this.getLevelSummonLimit(this.getMasterLevel(_masterID));
		local info = this.getSubclassInfo(_masterID);

		if (info != null)
		{
			max = max + info.BonusMortos;

			// Legião Incontável: limite maior.
			if (this.hasPerkByMasterID(_masterID, "perk.necro_legiao_incontavel"))
			{
				max = max + ::Const.Necro.Sub.Legiao.IncontavelMortos;
			}
		}

		return ::Math.min(max, ::Const.Necro.MAX_MORTOS_TOTAL);
	}

	// Quantos mortos de um tipo este mestre tem em campo.
	function countType( _masterID, _tipo )
	{
		local n = 0;

		foreach( e in this.getSummonsOfMaster(_masterID, false) )
		{
			if (e.getFlags().get(this.FlagTipo) == _tipo)
			{
				n = ++n;
			}
		}

		return n;
	}

	// Limite por tipo (ex.: Escudeiros do Atirador, máx. 4). -1 = sem limite.
	function getTypeMaxUnits( _masterID, _tipo )
	{
		local e = this.getTypeEntry(_masterID, _tipo);
		return e != null && ("MaxUnidades" in e) ? e.MaxUnidades : -1;
	}

	function getTypeWeight( _tipo )
	{
		local t = ::Const.Necro.Tipos[_tipo];
		return ("Peso" in t) ? t.Peso : ::Const.Necro.PESO_PADRAO;
	}

	// Vagas livres. _peso = peso de cada unidade que se quer invocar.
	// Retorna QUANTAS unidades desse peso ainda cabem (spawn parcial).
	function getFreeSlots( _masterID, _peso = 1 )
	{
		local livre = ::Math.max(0, this.getMaxSummons(_masterID) - this.countSummonWeight(_masterID));
		return livre / _peso;
	}

	// Magos: só existem no Lich (MaxMagos = 0 nas outras subclasses).
	function getMaxMages( _masterID )
	{
		local info = this.getSubclassInfo(_masterID);

		if (info == null || info.MaxMagos <= 0)
		{
			return 0;
		}

		// Escola de Magos: +2 até o teto do Lich.
		if (this.hasPerkByMasterID(_masterID, "perk.necro_escola_de_magos"))
		{
			return ::Math.min(::Const.Necro.LICH_MAX_MAGOS_TETO, info.MaxMagos + ::Const.Necro.Sub.Lich.EscolaMagos);
		}

		return info.MaxMagos;
	}

	// =================================================================
	// TILES E SPAWN
	// =================================================================

	// Distância do tile até o inimigo mais próximo do invocador (99 se não houver).
	function getDistanceToNearestEnemy( _tile, _enemyTiles )
	{
		local best = 99;

		foreach( t in _enemyTiles )
		{
			local d = _tile.getDistanceTo(t);

			if (d < best)
			{
				best = d;
			}
		}

		return best;
	}

	function getEnemyTiles( _user )
	{
		local ret = [];

		foreach( faction in ::Tactical.Entities.getAllInstances() )
		{
			foreach( e in faction )
			{
				if (this.isValidActor(e) && !e.isAlliedWith(_user))
				{
					ret.push(e.getTile());
				}
			}
		}

		return ret;
	}

	// Procura tiles livres em volta de _origin (busca em largura, até SPAWN_RAIO).
	// _ranged = true: prefere tiles longe dos inimigos (atrás da linha);
	// _ranged = false: prefere tiles perto dos inimigos (à frente).
	// Retorna no máximo _count tiles; pode retornar menos (spawn parcial).
	function findSpawnTiles( _origin, _count, _ranged, _user )
	{
		local enemyTiles = this.getEnemyTiles(_user);
		local visited = {};
		local frontier = [
			_origin
		];
		local candidates = [];
		visited[_origin.ID] <- true;

		for( local depth = 0; depth < ::Const.Necro.SPAWN_RAIO; depth = ++depth )
		{
			local next = [];

			foreach( tile in frontier )
			{
				for( local i = 0; i < 6; i = ++i )
				{
					if (!tile.hasNextTile(i))
					{
						continue;
					}

					local n = tile.getNextTile(i);

					if (n.ID in visited)
					{
						continue;
					}

					visited[n.ID] <- true;
					next.push(n);

					if (n.IsEmpty && ::Math.abs(n.Level - _origin.Level) <= 2)
					{
						candidates.push({
							Tile = n,
							Enemy = this.getDistanceToNearestEnemy(n, enemyTiles),
							Origin = depth + 1
						});
					}
				}
			}

			frontier = next;
		}

		candidates.sort(function ( _a, _b )
		{
			local ea = _ranged ? -_a.Enemy : _a.Enemy;
			local eb = _ranged ? -_b.Enemy : _b.Enemy;

			if (ea != eb)
			{
				return ea < eb ? -1 : 1;
			}

			if (_a.Origin != _b.Origin)
			{
				return _a.Origin < _b.Origin ? -1 : 1;
			}

			return 0;
		});

		local ret = [];

		foreach( c in candidates )
		{
			if (ret.len() >= _count)
			{
				break;
			}

			ret.push(c.Tile);
		}

		return ret;
	}

	// Spawna UM morto (ou Mago) no tile, já na facção do jogador e controlado pela IA.
	// _master = Necromante dono (perks/XP) | _owner = quem invocou (Necromante ou Mago)
	function spawnSummon( _script, _tile, _master, _owner, _isFractured = false )
	{
		// Como o vanilla faz em tactical_entity_manager.onResurrect: não anunciar a "descoberta".
		::Const.Movement.AnnounceDiscoveredEntities = false;
		local e = ::Tactical.spawnEntity(_script, _tile.Coords.X, _tile.Coords.Y);
		::Const.Movement.AnnounceDiscoveredEntities = true;

		// Mesma facção dos cães de guerra: aliada do jogador, controlada pela IA.
		e.setFaction(::Const.Faction.PlayerAnimals);
		e.getFlags().set(this.FlagMestre, _master.getID());
		e.getFlags().set(this.FlagDono, _owner.getID());

		// Equipa e aplica os atributos (precisa vir depois das flags, por causa dos perks).
		e.onNecroSpawned();

		// Os itens deste morto viram espólio no fim da batalha.
		this.registerSpoils(_master, e.getItemScripts());

		if (_isFractured)
		{
			e.makeFractured();
		}

		e.riseFromGround();

		// Mortos agem a partir da próxima rodada (o vanilla zera isso em onRoundStart).
		e.setSkipTurn(true);
		return e;
	}

	// Invoca um grupo do tipo _tipo em volta de _owner, respeitando o limite global.
	// Retorna quantos nasceram.
	function raiseGroup( _tipo, _master, _owner, _isFractured = false, _forcedCount = -1 )
	{
		local t = ::Const.Necro.Tipos[_tipo];
		this.cachePerks(_master);

		// Tamanho do grupo vem da subclasse; spawna só o que cabe no limite (com peso).
		local wanted = _forcedCount >= 0 ? _forcedCount : this.getTypeGroup(_master.getID(), _tipo);
		local peso = ("Peso" in t) ? t.Peso : ::Const.Necro.PESO_PADRAO;
		local count = ::Math.min(wanted, this.getFreeSlots(_master.getID(), peso));

		// Limite por tipo (ex.: Escudeiros do Atirador).
		local maxUnits = this.getTypeMaxUnits(_master.getID(), _tipo);

		if (maxUnits >= 0)
		{
			count = ::Math.min(count, maxUnits - this.countType(_master.getID(), _tipo));
		}

		if (count <= 0)
		{
			return 0;
		}

		local tiles = this.findSpawnTiles(_owner.getTile(), count, t.Distancia, _owner);
		local spawned = [];

		foreach( tile in tiles )
		{
			spawned.push(this.spawnSummon(t.Script, tile, _master, _owner, _isFractured));
		}

		// Estandarte Ósseo (Legião): o grupo erguido traz um porta-estandarte
		// se ninguém estiver carregando.
		if (spawned.len() != 0 && !_isFractured && this.hasPerkByMasterID(_master.getID(), "perk.necro_estandarte_osseo"))
		{
			this.ensureBanner(_master.getID(), spawned[0]);
		}

		if (tiles.len() != 0 && !_owner.isHiddenToPlayer())
		{
			::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(_owner) + " ergue " + tiles.len() + "x " + t.Nome + (_isFractured ? " Fraturado" : ""));
		}

		// Atualiza bônus que dependem da quantidade de mortos (ex.: Nuvem de Ossos).
		_master.getSkills().update();
		return tiles.len();
	}

	// Mata todos os mortos invocados DIRETAMENTE por _ownerID (cap. 5, regra 7).
	function collapseSummonsOf( _ownerID )
	{
		local rt = this.getRuntime();
		rt.Colapsando = true;
		local toKill = [];

		foreach( e in ::Tactical.Entities.getInstancesOfFaction(::Const.Faction.PlayerAnimals) )
		{
			if (this.isValidActor(e) && this.isSummon(e) && e.getFlags().getAsInt(this.FlagDono) == _ownerID)
			{
				toKill.push(e);
			}
		}

		foreach( e in toKill )
		{
			if (e.isAlive())
			{
				e.killSilently();
			}
		}

		rt.Colapsando = false;
	}

	// =================================================================
	// ESPÓLIOS DOS MORTOS
	// -----------------------------------------------------------------
	// Cada item equipado num morto invocado é anotado aqui (só o script).
	// A lista fica numa tabela da RAIZ (::NecroEspolios), que sobrevive à
	// troca do combate para o mapa-múndi; o evento "Espólios dos Mortos"
	// (necro_spoils_event.nut) lê, mostra as 3 escolhas e limpa.
	// Os itens NÃO entram no loot normal do vanilla (IsDroppedAsLoot = false).
	// Limitação: a lista não vai para o save; se o jogo for fechado entre o
	// fim da batalha e a janela de espólios, eles se perdem.
	// =================================================================
	function getPendingSpoils()
	{
		local root = ::getroottable();

		if (!("NecroEspolios" in root) || root.NecroEspolios == null)
		{
			root.NecroEspolios <- [];
		}

		return root.NecroEspolios;
	}

	function registerSpoils( _master, _scripts )
	{
		if (!::Const.Necro.Espolios.ATIVO || _master == null)
		{
			return;
		}

		local list = this.getPendingSpoils();
		local nivel = 1;

		try
		{
			nivel = _master.getLevel();
		}
		catch( err )
		{
		}

		foreach( script in _scripts )
		{
			// Munição não vira espólio.
			if (script.find("scripts/items/ammo/") == 0)
			{
				continue;
			}

			// Teto de segurança da lista; o sorteio de MAX_ITENS é feito no evento.
			if (list.len() >= 300)
			{
				return;
			}

			list.push({
				Script = script,
				MasterID = _master.getID(),
				Nivel = nivel
			});
		}
	}

	// Quantos itens o evento de espólios entrega (MAX_ITENS + extra por nível).
	function getSpoilsItemCount( _maxLevel )
	{
		local e = ::Const.Necro.Espolios;
		local n = e.MAX_ITENS;

		if (e.ITENS_EXTRA_A_CADA_NIVEIS > 0)
		{
			n = n + _maxLevel / e.ITENS_EXTRA_A_CADA_NIVEIS;
		}

		return n;
	}

	function clearPendingSpoils()
	{
		::getroottable().NecroEspolios <- [];
	}

	// =================================================================
	// VENENO DO CADÁVER E NECROSE
	// =================================================================

	// Chamado no onTargetHit de mortos e do Necromante.
	function applyOnHit( _attacker, _target, _skill, _damageHP, _damageArmor )
	{
		if (_skill == null || !_skill.isAttack())
		{
			return;
		}

		if (!this.isValidActor(_target) || _target.isAlliedWith(_attacker))
		{
			return;
		}

		if (_damageHP + _damageArmor < ::Const.Necro.EFEITO_DANO_MINIMO)
		{
			return;
		}

		local masterID = this.getMasterID(_attacker);

		if (masterID < 0)
		{
			return;
		}

		local ranged = _skill.isRanged();
		local profana = this.hasPerkByMasterID(masterID, "perk.necro_municao_profana");

		if (this.isSummon(_attacker))
		{
			local tipo = _attacker.getFlags().get(this.FlagTipo);
			local t = (tipo != null && tipo in ::Const.Necro.Tipos) ? ::Const.Necro.Tipos[tipo] : null;
			local efeito = t != null && ("AplicaEfeito" in t) ? t.AplicaEfeito : (ranged ? "necrose" : "veneno");
			local n = 1;

			// Linhagem de Ossos (Ossário): golpes da Abominação aplicam mais Veneno.
			if (tipo == "abominacao" && this.hasPerkByMasterID(masterID, "perk.necro_linhagem_de_ossos"))
			{
				n = ::Const.Necro.Sub.Ossario.LinhagemAcumulos;
			}

			this.addStacks(_target, efeito == "necrose" ? this.NecroseID : this.VenenoID, n, masterID);

			if (ranged && profana)
			{
				this.addStacks(_target, this.VenenoID, 1, masterID);
			}
		}
		else if (ranged && profana)
		{
			// O próprio Necromante só aplica efeitos com Munição Profana (à distância).
			this.addStacks(_target, this.VenenoID, 1, masterID);
		}
	}

	// Teto de acúmulos de Veneno/Necrose (Virulência aumenta).
	function getStackCap( _masterID )
	{
		local cap = ::Const.Necro.ACUMULO_MAX;

		if (this.hasPerkByMasterID(_masterID, "perk.necro_virulencia"))
		{
			cap = cap + ::Const.Necro.Sub.Peste.VirulenciaAcumulos;
		}

		return cap;
	}

	// Total de acúmulos (Veneno + Necrose) no alvo.
	function getTotalStacks( _target )
	{
		local n = 0;

		foreach( id in [this.VenenoID, this.NecroseID] )
		{
			local e = _target.getSkills().getSkillByID(id);

			if (e != null)
			{
				n = n + e.getStacks();
			}
		}

		return n;
	}

	// Dano por acúmulo e duração com todos os modificadores de perk.
	function getEffectParams( _masterID, _effectID, _target )
	{
		local danoBase = _effectID == this.VenenoID ? ::Const.Necro.VENENO_DANO_POR_ACUMULO : ::Const.Necro.NECROSE_DANO_POR_ACUMULO;
		local dano = danoBase * 1.0;
		local duracao = ::Const.Necro.EFEITO_DURACAO;

		if (this.hasPerkByMasterID(_masterID, "perk.necro_mestre_da_necromancia"))
		{
			dano = dano + ::Const.Necro.Perks.MESTRE_DANO;
			duracao = duracao + ::Const.Necro.Perks.MESTRE_DURACAO;
		}

		if (this.hasPerkByMasterID(_masterID, "perk.necro_putrefacao_redobrada"))
		{
			dano = dano * ::Const.Necro.PUTREFACAO_MULT;
			duracao = duracao * ::Const.Necro.PUTREFACAO_MULT;
		}

		// Inimigos mortos-vivos: imunes, exceto com Mestre da Necromancia (Lich)
		// ou Virulência (Peste), com efeito reduzido.
		if (_target.getFlags().has("undead"))
		{
			dano = dano * this.getUndeadEffectMult(_masterID);
		}

		return {
			Dano = dano,
			Duracao = duracao
		};
	}

	// Fração do efeito que atinge inimigos mortos-vivos (0 = imunes).
	function getUndeadEffectMult( _masterID )
	{
		local mult = 0.0;

		if (this.hasPerkByMasterID(_masterID, "perk.necro_mestre_da_necromancia"))
		{
			mult = ::Const.Necro.Perks.MESTRE_MORTOVIVO_MULT;
		}

		if (this.hasPerkByMasterID(_masterID, "perk.necro_virulencia"))
		{
			mult = ::Math.maxf(mult, ::Const.Necro.Sub.Peste.VirulenciaMortoVivo);
		}

		return mult;
	}

	function canReceiveEffect( _target, _effectID, _masterID )
	{
		if (_target.getFlags().has("undead"))
		{
			return this.getUndeadEffectMult(_masterID) > 0;
		}

		// Veneno respeita a imunidade a veneno do vanilla; a Necrose não.
		if (_effectID == this.VenenoID && _target.getCurrentProperties().IsImmuneToPoison)
		{
			return false;
		}

		return true;
	}

	function addStacks( _target, _effectID, _n, _masterID )
	{
		if (!this.canReceiveEffect(_target, _effectID, _masterID))
		{
			return;
		}

		// Sangue Tóxico: chance de acúmulo extra.
		if (this.hasPerkByMasterID(_masterID, "perk.necro_sangue_toxico") && ::Math.rand(1, 100) <= ::Const.Necro.Perks.SANGUE_TOXICO_CHANCE)
		{
			_n = _n + 1;
		}

		local params = this.getEffectParams(_masterID, _effectID, _target);
		local effect = _target.getSkills().getSkillByID(_effectID);

		if (effect == null)
		{
			effect = ::new(_effectID == this.VenenoID ? "scripts/skills/effects/necro_poison_effect" : "scripts/skills/effects/necro_necrosis_effect");
			_target.getSkills().add(effect);
		}

		effect.addStacks(_n, params.Dano, params.Duracao, _masterID);
		_target.getSkills().update();
	}

	// Multiplicador de dano dos efeitos no alvo (Marca do Comando + Essência Morta).
	function getEffectDamageMult( _target, _masterID )
	{
		local mult = 1.0;
		local mark = _target.getSkills().getSkillByID(this.MarcaID);

		if (mark != null)
		{
			mult = mult * (1.0 + ::Const.Necro.Ativas.MarcaBonusEfeitos * mark.getPotency());
		}

		mult = mult * this.getEssenceDamageMult(_masterID);
		return mult;
	}

	// =================================================================
	// ESSÊNCIA MORTA
	// =================================================================
	function getEssence( _masterID )
	{
		local rt = this.getRuntime();
		return (_masterID in rt.Essencia) ? rt.Essencia[_masterID] : 0;
	}

	function addEssence( _masterID )
	{
		if (!this.hasPerkByMasterID(_masterID, "perk.necro_essencia_morta"))
		{
			return;
		}

		local rt = this.getRuntime();
		rt.Essencia[_masterID] <- ::Math.min(::Const.Necro.Perks.ESSENCIA_MAX, this.getEssence(_masterID) + 1);
	}

	function getEssenceDamageMult( _masterID )
	{
		if (!this.hasPerkByMasterID(_masterID, "perk.necro_essencia_morta"))
		{
			return 1.0;
		}

		return 1.0 + this.getEssence(_masterID) * ::Const.Necro.Perks.ESSENCIA_DANO;
	}

	// =================================================================
	// DANO DIRETO (Veneno/Necrose/Colheita): ignora armadura.
	// =================================================================
	function dealDirectDamage( _target, _amount, _attacker, _skill )
	{
		if (!this.isValidActor(_target) || _amount <= 0)
		{
			return;
		}

		local hitInfo = clone ::Const.Tactical.HitInfo;
		hitInfo.DamageRegular = _amount;
		hitInfo.DamageDirect = 1.0;
		hitInfo.BodyPart = ::Const.BodyPart.Body;
		hitInfo.BodyDamageMult = 1.0;
		hitInfo.FatalityChanceMult = 0.0;
		_target.onDamageReceived(_attacker != null ? _attacker : _target, _skill, hitInfo);
	}

	// =================================================================
	// ALCANCE (Alcance dos Mortos / Alcance Independente)
	// -----------------------------------------------------------------
	// Guardamos o alcance original de cada habilidade dentro dela mesma
	// (m.NecroBaseMaxRange) para nunca acumular bônus em cima de bônus.
	// =================================================================
	function applyRangeBonus( _actor, _rangedBonus, _allBonus )
	{
		foreach( s in _actor.getSkills().m.Skills )
		{
			if (s.isGarbage() || !s.isAttack() || !s.isActive())
			{
				continue;
			}

			if (!("NecroBaseMaxRange" in s.m))
			{
				s.m.NecroBaseMaxRange <- s.m.MaxRange;
			}

			local bonus = _allBonus + (s.isRanged() ? _rangedBonus : 0);
			s.m.MaxRange = s.m.NecroBaseMaxRange + bonus;
		}
	}

	// =================================================================
	// MORTOS FRATURADOS (Exército Sem Fim / Pacto dos Dez Mil Mortos)
	// =================================================================
	function spawnFracturedNear( _tipo, _nearTile, _master, _owner )
	{
		if (this.getFreeSlots(_master.getID()) <= 0)
		{
			return null;
		}

		local tiles = this.findSpawnTiles(_nearTile, 1, ::Const.Necro.Tipos[_tipo].Distancia, _owner);

		if (tiles.len() == 0)
		{
			return null;
		}

		local e = this.spawnSummon(::Const.Necro.Tipos[_tipo].Script, tiles[0], _master, _owner, true);

		if (!e.isHiddenToPlayer())
		{
			::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(e) + " se ergue dos mortos");
		}

		return e;
	}

	// =================================================================
	// SUBCLASSES - utilitários de mapa
	// =================================================================

	// Todos os tiles a até _radius de _center (inclui o centro), por busca em largura.
	function getTilesInRadius( _center, _radius )
	{
		local ret = [
			_center
		];
		local visited = {};
		visited[_center.ID] <- true;
		local frontier = [
			_center
		];

		for( local d = 0; d < _radius; d = ++d )
		{
			local next = [];

			foreach( tile in frontier )
			{
				for( local i = 0; i < 6; i = ++i )
				{
					if (!tile.hasNextTile(i))
					{
						continue;
					}

					local n = tile.getNextTile(i);

					if (n.ID in visited)
					{
						continue;
					}

					visited[n.ID] <- true;
					next.push(n);
					ret.push(n);
				}
			}

			frontier = next;
		}

		return ret;
	}

	// Atores vivos em volta de um tile (raio 1 = adjacentes, sem o centro).
	function getAdjacentActors( _tile )
	{
		local ret = [];

		for( local i = 0; i < 6; i = ++i )
		{
			if (!_tile.hasNextTile(i))
			{
				continue;
			}

			local t = _tile.getNextTile(i);

			if (t.IsOccupiedByActor)
			{
				local e = t.getEntity();

				if (this.isValidActor(e))
				{
					ret.push(e);
				}
			}
		}

		return ret;
	}

	function getActorsInRadius( _center, _radius )
	{
		local ret = [];

		foreach( t in this.getTilesInRadius(_center, _radius) )
		{
			if (t.IsOccupiedByActor)
			{
				local e = t.getEntity();

				if (this.isValidActor(e))
				{
					ret.push(e);
				}
			}
		}

		return ret;
	}

	// Inimigos vivos de _user em campo.
	function getEnemiesOf( _user )
	{
		local ret = [];

		foreach( faction in ::Tactical.Entities.getAllInstances() )
		{
			foreach( e in faction )
			{
				if (this.isValidActor(e) && !e.isAlliedWith(_user))
				{
					ret.push(e);
				}
			}
		}

		return ret;
	}

	// Tile livre adjacente ao alvo, a no máximo _maxDist de _fromTile (o mais perto).
	function findTileAdjacentTo( _targetTile, _fromTile, _maxDist )
	{
		local best = null;
		local bestDist = 999;

		for( local i = 0; i < 6; i = ++i )
		{
			if (!_targetTile.hasNextTile(i))
			{
				continue;
			}

			local t = _targetTile.getNextTile(i);

			if (!t.IsEmpty || ::Math.abs(t.Level - _fromTile.Level) > 1)
			{
				continue;
			}

			local d = _fromTile.getDistanceTo(t);

			if (d <= _maxDist && d < bestDist)
			{
				best = t;
				bestDist = d;
			}
		}

		return best;
	}

	function heal( _actor, _amount )
	{
		if (!this.isValidActor(_actor) || _amount <= 0)
		{
			return;
		}

		_actor.setHitpoints(::Math.min(_actor.getHitpointsMax(), _actor.getHitpoints() + _amount));
		_actor.setDirty(true);
	}

	// =================================================================
	// ATAQUES GRÁTIS (Carga Fúnebre, Execução Sombria, Saraivada, Sentinela)
	// -----------------------------------------------------------------
	// Igual ao contra-ataque (riposte) do vanilla: agenda o ataque com
	// Time.scheduleEvent e usa skill.useForFree no tile do alvo.
	// O bônus de acerto/dano do ataque grátis fica em AtaqueBonus e é lido
	// pela racial dos mortos (ou pelo background do Necromante) em
	// onAnySkillUsed, e apagado logo depois.
	// =================================================================
	function getMeleeAttack( _actor )
	{
		return _actor.getSkills().getAttackOfOpportunity();
	}

	function getRangedAttack( _actor, _targetTile )
	{
		foreach( s in _actor.getSkills().m.Skills )
		{
			if (s.isGarbage() || !s.isActive() || !s.isAttack() || !s.isRanged() || !s.isTargeted() || s.isDisabled() || !s.isUsable())
			{
				continue;
			}

			if (_targetTile == null || s.isInRange(_targetTile))
			{
				return s;
			}
		}

		return null;
	}

	// Ataque grátis imediato (sem custo de PA/Fadiga). Retorna true se atacou.
	function freeAttackNow( _attacker, _target, _bonus = null )
	{
		if (!this.isValidActor(_attacker) || !this.isValidActor(_target) || _attacker.isAlliedWith(_target))
		{
			return false;
		}

		local tile = _target.getTile();
		local skill = null;

		if (_attacker.getTile().getDistanceTo(tile) == 1)
		{
			skill = this.getMeleeAttack(_attacker);
		}

		if (skill == null)
		{
			skill = this.getRangedAttack(_attacker, tile);
		}

		if (skill == null)
		{
			return false;
		}

		if (_bonus != null)
		{
			this.getRuntime().AtaqueBonus[_attacker.getID()] <- _bonus;
		}

		local ok = skill.useForFree(tile);
		local rt = this.getRuntime();

		if (_attacker.getID() in rt.AtaqueBonus)
		{
			delete rt.AtaqueBonus[_attacker.getID()];
		}

		return ok;
	}

	function scheduleAttack( _attacker, _target, _delay, _bonus = null )
	{
		::Time.scheduleEvent(::TimeUnit.Virtual, _delay, function ( _tag )
		{
			::Const.Necro.Util.freeAttackNow(_tag.A, _tag.T, _tag.B);
		}, {
			A = _attacker,
			T = _target,
			B = _bonus
		});
	}

	// Anda até _maxMove tiles para ficar adjacente ao alvo e ataca de graça.
	// Retorna true se o ataque foi agendado.
	function moveAndAttack( _attacker, _target, _maxMove, _delay, _bonus = null )
	{
		if (!this.isValidActor(_attacker) || !this.isValidActor(_target))
		{
			return false;
		}

		local myTile = _attacker.getTile();
		local d = myTile.getDistanceTo(_target.getTile());

		// Atiradores atacam de onde estão, se o alvo estiver no alcance.
		if (d > 1 && this.getRangedAttack(_attacker, _target.getTile()) != null)
		{
			this.scheduleAttack(_attacker, _target, _delay, _bonus);
			return true;
		}

		if (d == 1)
		{
			this.scheduleAttack(_attacker, _target, _delay, _bonus);
			return true;
		}

		local dest = this.findTileAdjacentTo(_target.getTile(), myTile, _maxMove);

		if (dest == null)
		{
			return false;
		}

		// Ocupa o tile já, para dois mortos não escolherem o mesmo destino.
		::Tactical.getNavigator().teleport(_attacker, dest, function ( _entity, _tag )
		{
			::Const.Necro.Util.scheduleAttack(_entity, _tag.T, 100, _tag.B);
		}, {
			T = _target,
			B = _bonus
		}, false, 0.0);
		return true;
	}

	// =================================================================
	// MORTE / CONSUMO SEM GATILHOS
	// -----------------------------------------------------------------
	// Mortos consumidos (fusão do Ossário, colapso do Lich) morrem com
	// Colapsando = true: não disparam Exército Sem Fim, Ressurgir dos Ossos,
	// Lealdade Eterna nem nada que dependa de onDeath; e, como killSilently
	// não tem matador, não contam como kill para XP, Essência ou Pacto.
	// =================================================================
	function consumeSilently( _e )
	{
		local rt = this.getRuntime();
		local old = rt.Colapsando;
		rt.Colapsando = true;

		if (_e.isAlive())
		{
			_e.killSilently();
		}

		rt.Colapsando = old;
	}

	// Lich: se morre sem Filactério, TODOS os mortos dele desabam
	// (inclusive os erguidos pelos Magos).
	function collapseAllOfMaster( _masterID )
	{
		local list = [];

		foreach( e in ::Tactical.Entities.getInstancesOfFaction(::Const.Faction.PlayerAnimals) )
		{
			if (this.isValidActor(e) && this.isSummon(e) && e.getFlags().getAsInt(this.FlagMestre) == _masterID)
			{
				list.push(e);
			}
		}

		foreach( e in list )
		{
			this.consumeSilently(e);
		}
	}

	// =================================================================
	// LEGIÃO: Capitão (Cadeia de Comando) e Estandarte Ósseo
	// =================================================================
	function getCaptain( _masterID )
	{
		local rt = this.getRuntime();

		if (!(_masterID in rt.Capitao))
		{
			return null;
		}

		local e = ::Tactical.getEntityByID(rt.Capitao[_masterID].ID);
		return this.isValidActor(e) ? e : null;
	}

	// Chamado no início do turno do Necromante: promove um Soldado Nobre se
	// não houver Capitão (depois da espera de CapitaoPromocaoTurnos).
	function updateCaptain( _masterID )
	{
		if (!this.hasPerkByMasterID(_masterID, "perk.necro_cadeia_de_comando") || this.getCaptain(_masterID) != null)
		{
			return;
		}

		local rt = this.getRuntime();

		if (_masterID in rt.Capitao && rt.Capitao[_masterID].ID >= 0)
		{
			// Capitão acabou de morrer: começa a espera.
			rt.Capitao[_masterID] = {
				ID = -1,
				Espera = ::Const.Necro.Sub.Legiao.CapitaoPromocaoTurnos
			};
		}

		if (_masterID in rt.Capitao && rt.Capitao[_masterID].Espera > 0)
		{
			rt.Capitao[_masterID].Espera = rt.Capitao[_masterID].Espera - 1;
			return;
		}

		foreach( e in this.getSummonsOfMaster(_masterID, false) )
		{
			if (e.getFlags().get(this.FlagTipo) == "soldado")
			{
				rt.Capitao[_masterID] <- {
					ID = e.getID(),
					Espera = 0
				};
				e.setName(::Const.Necro.Tipos.soldado.Nome + " (Capitão)");

				if (!e.isHiddenToPlayer())
				{
					::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(e) + " assume o comando da legião");
				}

				return;
			}
		}
	}

	function getBannerBearer( _masterID )
	{
		local rt = this.getRuntime();

		if (!(_masterID in rt.Estandarte))
		{
			return null;
		}

		local e = ::Tactical.getEntityByID(rt.Estandarte[_masterID].ID);
		return this.isValidActor(e) ? e : null;
	}

	function setBannerBearer( _masterID, _e )
	{
		this.getRuntime().Estandarte[_masterID] <- {
			ID = _e.getID(),
			Tile = null
		};
		_e.getFlags().add("necro_estandarte");

		if (!_e.isHiddenToPlayer())
		{
			::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(_e) + " ergue o Estandarte Ósseo");
		}
	}

	// Ao erguer um grupo: se ninguém porta o estandarte e ele não está caído, o primeiro do grupo pega.
	function ensureBanner( _masterID, _candidate )
	{
		local rt = this.getRuntime();

		if (this.getBannerBearer(_masterID) != null)
		{
			return;
		}

		if (_masterID in rt.Estandarte && rt.Estandarte[_masterID].Tile != null)
		{
			return;
		}

		this.setBannerBearer(_masterID, _candidate);
	}

	// Início do turno do Necromante: estandarte caído é pego pelo morto mais perto de onde caiu.
	function updateBanner( _masterID )
	{
		local rt = this.getRuntime();

		if (!(_masterID in rt.Estandarte) || this.getBannerBearer(_masterID) != null)
		{
			return;
		}

		local info = rt.Estandarte[_masterID];

		if (info.Tile == null)
		{
			return;
		}

		local best = null;
		local bestDist = 999;

		foreach( e in this.getSummonsOfMaster(_masterID, false) )
		{
			local d = e.getTile().getDistanceTo(info.Tile);

			if (d < bestDist)
			{
				best = e;
				bestDist = d;
			}
		}

		if (best != null)
		{
			this.setBannerBearer(_masterID, best);
		}
	}

	// Chamado pela racial quando o portador morre.
	function dropBanner( _masterID, _tile )
	{
		local rt = this.getRuntime();

		if (_masterID in rt.Estandarte)
		{
			rt.Estandarte[_masterID] = {
				ID = -1,
				Tile = _tile
			};
		}
	}

	// =================================================================
	// MAESTRO: Ordens
	// -----------------------------------------------------------------
	// Lista de Ordens ativas por mestre: [{ID, Turnos, Mult}]. A primeira
	// da lista é a mais nova (100%); com Ordem Dupla a segunda fica com 50%.
	// Os Turnos caem no início do turno do Necromante.
	// =================================================================
	function getActiveOrders( _masterID )
	{
		local rt = this.getRuntime();

		if (!(_masterID in rt.Ordens))
		{
			rt.Ordens[_masterID] <- [];
		}

		return rt.Ordens[_masterID];
	}

	// Multiplicador (0, 0.5 ou 1.0) da Ordem _id para os mortos deste mestre.
	function getOrderMult( _masterID, _id )
	{
		local best = 0.0;

		foreach( o in this.getActiveOrders(_masterID) )
		{
			if (o.ID == _id && o.Mult > best)
			{
				best = o.Mult;
			}
		}

		return best;
	}

	function getOrderDuration( _masterID )
	{
		local d = ::Const.Necro.ORDEM_DURACAO;

		if (this.hasPerkByMasterID(_masterID, "perk.necro_batuta_ossea"))
		{
			d = d + ::Const.Necro.Sub.Maestro.BatutaTurnos;
		}

		return d;
	}

	function giveOrder( _masterID, _id )
	{
		local list = this.getActiveOrders(_masterID);
		local dupla = this.hasPerkByMasterID(_masterID, "perk.necro_ordem_dupla");
		local novas = [
			{
				ID = _id,
				Turnos = this.getOrderDuration(_masterID),
				Mult = 1.0
			}
		];

		// Ordem Dupla: a anterior continua, com metade do efeito.
		if (dupla)
		{
			foreach( o in list )
			{
				if (o.ID != _id && novas.len() < 2)
				{
					novas.push({
						ID = o.ID,
						Turnos = o.Turnos,
						Mult = ::Const.Necro.Sub.Maestro.OrdemDuplaMult
					});
				}
			}
		}

		this.getRuntime().Ordens[_masterID] <- novas;
	}

	// Opus Final: as 4 Ordens a 100%.
	function giveAllOrders( _masterID, _turns )
	{
		local novas = [];

		foreach( o in ::Const.Necro.Ordens )
		{
			novas.push({
				ID = o.ID,
				Turnos = _turns,
				Mult = 1.0
			});
		}

		this.getRuntime().Ordens[_masterID] <- novas;
	}

	// Início do turno do Maestro: Ordens perdem 1 turno; Crescendo conta
	// quantos turnos seguidos a mesma Ordem principal ficou ativa.
	function tickOrders( _masterID )
	{
		local rt = this.getRuntime();
		local list = this.getActiveOrders(_masterID);
		local kept = [];

		foreach( o in list )
		{
			o.Turnos = o.Turnos - 1;

			if (o.Turnos > 0)
			{
				kept.push(o);
			}
		}

		rt.Ordens[_masterID] <- kept;
		local principal = kept.len() != 0 ? kept[0].ID : null;
		local c = (_masterID in rt.OrdemCrescendo) ? rt.OrdemCrescendo[_masterID] : {
			ID = null,
			Turnos = 0
		};

		if (principal != null && principal == c.ID)
		{
			c.Turnos = c.Turnos + 1;
		}
		else
		{
			c = {
				ID = principal,
				Turnos = 0
			};
		}

		rt.OrdemCrescendo[_masterID] <- c;
	}

	function getCrescendoMult( _masterID )
	{
		if (!this.hasPerkByMasterID(_masterID, "perk.necro_crescendo"))
		{
			return 1.0;
		}

		local rt = this.getRuntime();

		if (!(_masterID in rt.OrdemCrescendo) || rt.OrdemCrescendo[_masterID].ID == null)
		{
			return 1.0;
		}

		local M = ::Const.Necro.Sub.Maestro;
		return 1.0 + ::Math.minf(M.CrescendoMax, rt.OrdemCrescendo[_masterID].Turnos * M.CrescendoDano);
	}

	// =================================================================
	// COVEIRO: registro de cadáveres
	// -----------------------------------------------------------------
	// O vanilla já deixa um cadáver no tile (tile.IsCorpseSpawned e
	// tile.Properties "Corpse"). Como ele não guarda o script nem os atributos
	// originais, um vigia (necro_corpse_watcher_effect) anota no onDeath de
	// cada ator: script, atributos, itens e habilidades próprias.
	// Os dados ficam em Runtime.Cadaveres (não vão para o save).
	// =================================================================
	function canBeReanimated( _actor )
	{
		local type = _actor.getType();

		foreach( name in ::Const.Necro.NaoReanimaveis )
		{
			if ((name in ::Const.EntityType) && ::Const.EntityType[name] == type)
			{
				return false;
			}
		}

		return true;
	}

	function hashToScript( _hash )
	{
		try
		{
			return ::IO.scriptFilenameByHash(_hash);
		}
		catch( e )
		{
			return null;
		}
	}

	function registerCorpse( _actor )
	{
		if (!_actor.isPlacedOnMap() || !this.canBeReanimated(_actor))
		{
			return;
		}

		local items = [];

		foreach( slot in [::Const.ItemSlot.Mainhand, ::Const.ItemSlot.Offhand, ::Const.ItemSlot.Head, ::Const.ItemSlot.Body, ::Const.ItemSlot.Ammo] )
		{
			local item = _actor.getItems().getItemAtSlot(slot);

			if (item != null)
			{
				local script = this.hashToScript(item.ClassNameHash);

				if (script != null)
				{
					items.push(script);
				}
			}
		}

		// Habilidades próprias (que não vêm de item): mordidas, garras etc.
		local actives = [];

		foreach( s in _actor.getSkills().m.Skills )
		{
			if (!s.isGarbage() && s.isActive() && s.isAttack() && s.getItem() == null && s.getID() != "actives.hand_to_hand")
			{
				local script = this.hashToScript(s.ClassNameHash);

				if (script != null)
				{
					actives.push(script);
				}
			}
		}

		local b = _actor.getBaseProperties();
		this.getRuntime().Cadaveres[_actor.getID()] <- {
			Nome = _actor.getName(),
			Tile = _actor.getTile(),
			Hitpoints = _actor.getHitpointsMax(),
			MeleeSkill = b.MeleeSkill,
			RangedSkill = b.RangedSkill,
			MeleeDefense = b.MeleeDefense,
			RangedDefense = b.RangedDefense,
			Initiative = b.Initiative,
			Distancia = _actor.isArmedWithRangedWeapon(),
			Elite = ("IsMiniboss" in _actor.m) && _actor.m.IsMiniboss,
			Itens = items,
			Ativas = actives,
			JaReanimado = _actor.getFlags().has("necro_reanimado")
		};
	}

	// Dados do cadáver neste tile (ou num tile vizinho com o mesmo corpo), ou null.
	function findCorpseInfo( _tile )
	{
		if (!_tile.IsCorpseSpawned)
		{
			return null;
		}

		local corpse = _tile.Properties.get("Corpse");
		local nome = corpse != null && ("CorpseName" in corpse) ? corpse.CorpseName : null;
		local fallback = null;

		foreach( id, info in this.getRuntime().Cadaveres )
		{
			if (info.JaReanimado)
			{
				continue;
			}

			if (info.Tile.isSameTileAs(_tile))
			{
				return {
					ID = id,
					Info = info
				};
			}

			// O vanilla às vezes põe o corpo no tile vizinho (findTileToSpawnCorpse).
			if (fallback == null && info.Tile.getDistanceTo(_tile) <= 1 && nome != null && info.Nome == nome)
			{
				fallback = {
					ID = id,
					Info = info
				};
			}
		}

		return fallback;
	}

	// Some com o cadáver do tile (reanimado ou consumido).
	function consumeCorpse( _tile, _id )
	{
		local rt = this.getRuntime();

		if (_id in rt.Cadaveres)
		{
			delete rt.Cadaveres[_id];
		}

		if (_tile.IsCorpseSpawned)
		{
			::Tactical.Entities.removeCorpse(_tile);
			_tile.clear(::Const.Tactical.DetailFlag.Corpse);
			_tile.Properties.remove("Corpse");
			_tile.Properties.remove("IsSpawningFlies");
		}
	}

	// Tiles com cadáver registrado, mais perto de _origin primeiro.
	function getCorpseTiles( _origin, _maxDist )
	{
		local ret = [];

		foreach( id, info in this.getRuntime().Cadaveres )
		{
			if (info.JaReanimado || !info.Tile.IsCorpseSpawned)
			{
				continue;
			}

			local d = _origin.getDistanceTo(info.Tile);

			if (d <= _maxDist)
			{
				ret.push({
					ID = id,
					Tile = info.Tile,
					Dist = d
				});
			}
		}

		ret.sort(function ( _a, _b )
		{
			return _a.Dist < _b.Dist ? -1 : (_a.Dist > _b.Dist ? 1 : 0);
		});
		return ret;
	}

	function getReanimateScale( _masterID )
	{
		if (this.hasPerkByMasterID(_masterID, "perk.necro_mestre_dos_cadaveres"))
		{
			return ::Const.Necro.Sub.Coveiro.MestreEscala;
		}

		return ::Const.Necro.COVEIRO_REANIMADO_ESCALA;
	}

	// Ergue o cadáver como "reanimado" do mestre. Retorna a entidade ou null.
	function reanimateCorpse( _master, _tile, _found )
	{
		if (this.getFreeSlots(_master.getID()) <= 0)
		{
			return null;
		}

		local info = _found.Info;
		this.consumeCorpse(_tile, _found.ID);

		if (!_tile.IsEmpty)
		{
			local tiles = this.findSpawnTiles(_tile, 1, info.Distancia, _master);

			if (tiles.len() == 0)
			{
				return null;
			}

			_tile = tiles[0];
		}

		local e = this.spawnSummon(::Const.Necro.Tipos.reanimado.Script, _tile, _master, _master);
		e.setupFromCorpse(info, this.getReanimateScale(_master.getID()));

		// Cemitério Itinerante: chance de o equipamento virar espólio no fim do combate.
		if (this.hasPerkByMasterID(_master.getID(), "perk.necro_cemiterio_itinerante") && ::Math.rand(1, 100) <= ::Const.Necro.Sub.Coveiro.CemiterioChance)
		{
			this.registerSpoils(_master, e.getCopiedItems());
		}

		if (!e.isHiddenToPlayer())
		{
			::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(_master) + " reanima " + info.Nome);
		}

		return e;
	}

	// Coloca um efeito oculto em todos os atores que ainda não têm
	// (usado pelos vigias do Coveiro e das auras de inimigos).
	function attachToAll( _script, _id, _filter )
	{
		foreach( faction in ::Tactical.Entities.getAllInstances() )
		{
			foreach( e in faction )
			{
				if (!this.isValidActor(e) || e.getSkills().hasSkill(_id) || !_filter(e))
				{
					continue;
				}

				e.getSkills().add(::new(_script));
			}
		}
	}

	// Dano físico comum (respeita armadura), usado pela Chuva de Flechas.
	function dealPhysicalDamage( _target, _amount, _attacker, _skill, _direct = 0.3 )
	{
		if (!this.isValidActor(_target) || _amount <= 0)
		{
			return;
		}

		local hitInfo = clone ::Const.Tactical.HitInfo;
		hitInfo.DamageRegular = _amount;
		hitInfo.DamageArmor = _amount;
		hitInfo.DamageDirect = _direct;
		hitInfo.BodyPart = ::Const.BodyPart.Body;
		hitInfo.BodyDamageMult = 1.0;
		hitInfo.FatalityChanceMult = 0.0;
		_target.onDamageReceived(_attacker != null ? _attacker : _target, _skill, hitInfo);
	}
};
