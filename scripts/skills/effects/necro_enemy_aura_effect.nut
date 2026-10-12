// =====================================================================
// MOD NECROMANTE - Auras sobre inimigos (oculto)
// ---------------------------------------------------------------------
// O vanilla não tem "aura" que alcance inimigos sem uma habilidade neles.
// Por isso as habilidades ocultas de subclasse (necro_sub_*) colocam este
// efeito invisível em todo inimigo, a cada rodada:
//   - Silêncio da Cripta (Lich): atirador a até SilencioRaio de um Mago
//     perde SilencioHabDist de Habilidade à Distância;
//   - Coro de Ossos (Maestro): inimigo a até CoroRaio de CoroMinimo+
//     mortos perde CoroResolucao de Resolução;
//   - Nuvem de Peste (Peste): no início do turno, dentro de uma nuvem,
//     ganha NuvemAcumulos de Veneno.
// =====================================================================

this.necro_enemy_aura_effect <- this.inherit("scripts/skills/skill", {
	m = {
		LastCloudRound = -1
	},
	function create()
	{
		this.m.ID = "effects.necro_enemy_aura";
		this.m.Name = "";
		this.m.Type = this.Const.SkillType.Special;
		this.m.Order = this.Const.SkillOrder.VeryLast;
		this.m.IsActive = false;
		this.m.IsHidden = true;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
		this.m.IsSerialized = false;
	}

	function onUpdate( _properties )
	{
		local util = this.Const.Necro.Util;
		local actor = this.getContainer().getActor();

		if (!util.isInCombat() || !actor.isPlacedOnMap())
		{
			return;
		}

		local LI = this.Const.Necro.Sub.Lich;
		local MA = this.Const.Necro.Sub.Maestro;
		local myTile = actor.getTile();
		local ranged = actor.isArmedWithRangedWeapon();
		local silenciado = false;
		local coro = {};

		foreach( e in this.Tactical.Entities.getInstancesOfFaction(this.Const.Faction.PlayerAnimals) )
		{
			if (!util.isValidActor(e) || !util.isSummon(e) || e.isAlliedWith(actor) == true)
			{
				continue;
			}

			local masterID = e.getFlags().getAsInt(util.FlagMestre);
			local d = e.getTile().getDistanceTo(myTile);

			if (ranged && !silenciado && util.isMage(e) && d <= LI.SilencioRaio && util.hasPerkByMasterID(masterID, "perk.necro_silencio_da_cripta"))
			{
				silenciado = true;
			}

			if (d <= MA.CoroRaio && util.hasPerkByMasterID(masterID, "perk.necro_coro_de_ossos"))
			{
				coro[masterID] <- ((masterID in coro) ? coro[masterID] : 0) + 1;
			}
		}

		if (silenciado)
		{
			_properties.RangedSkill -= LI.SilencioHabDist;
		}

		foreach( id, n in coro )
		{
			if (n >= MA.CoroMinimo)
			{
				_properties.Bravery -= MA.CoroResolucao;
				break;
			}
		}
	}

	// Nuvem de Peste: no início do turno do inimigo.
	function onTurnStart()
	{
		local util = this.Const.Necro.Util;
		local actor = this.getContainer().getActor();

		if (!util.isInCombat() || !actor.isPlacedOnMap() || this.m.LastCloudRound == this.Time.getRound())
		{
			return;
		}

		this.m.LastCloudRound = this.Time.getRound();

		foreach( c in util.getRuntime().Nuvens )
		{
			if (c.Turnos > 0 && c.Tile.getDistanceTo(actor.getTile()) <= c.Raio)
			{
				util.addStacks(actor, util.VenenoID, this.Const.Necro.Sub.Peste.NuvemAcumulos, c.MasterID);
			}
		}
	}

});
