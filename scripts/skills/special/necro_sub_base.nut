// =====================================================================
// MOD NECROMANTE - Base das habilidades OCULTAS de subclasse
// ---------------------------------------------------------------------
// Cada subclasse recebe no Juramento uma habilidade invisível
// (necro_sub_<id>) com as regras passivas dela. Ela fica no Necromante e
// recebe os eventos do vanilla:
//   onRound()   -> início de cada rodada (auras e vigias em inimigos)
//   onOwnTurn() -> início do turno do Necromante (contadores, promoções)
// O ID segue o padrão "actives.<script>" usado por syncSubclassActives.
// Não vai para o save: o background recria a partir da flag da subclasse.
// =====================================================================

this.necro_sub_base <- this.inherit("scripts/skills/skill", {
	m = {},
	function create()
	{
		this.m.Name = "";
		this.m.Type = this.Const.SkillType.Special;
		this.m.Order = this.Const.SkillOrder.VeryLast;
		this.m.IsActive = false;
		this.m.IsHidden = true;
		this.m.IsStacking = false;
		this.m.IsSerialized = false;
		this.m.IsRemovedAfterBattle = false;
	}

	function getUtil()
	{
		return this.Const.Necro.Util;
	}

	function getActor()
	{
		return this.getContainer().getActor();
	}

	function hasPerk( _id )
	{
		return this.getUtil().hasPerkByMasterID(this.getActor().getID(), _id);
	}

	function onNewRound()
	{
		if (this.getUtil().isInCombat() && this.getActor().isPlacedOnMap())
		{
			this.onRound();
		}
	}

	function onTurnStart()
	{
		if (this.getUtil().isInCombat() && this.getActor().isPlacedOnMap())
		{
			this.getUtil().cachePerks(this.getActor());
			this.onRound();
			this.onOwnTurn();
		}
	}

	function onRound()
	{
	}

	function onOwnTurn()
	{
	}

	// Coloca a aura oculta em todos os inimigos (ver necro_enemy_aura_effect).
	function attachEnemyAura()
	{
		local actor = this.getActor();
		this.getUtil().attachToAll("scripts/skills/effects/necro_enemy_aura_effect", "effects.necro_enemy_aura", function ( _e )
		{
			return !_e.isAlliedWith(actor);
		});
	}

});
