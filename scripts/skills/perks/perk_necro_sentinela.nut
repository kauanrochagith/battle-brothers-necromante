// =====================================================================
// MOD NECROMANTE - Perk: Sentinela (Cavaleiro da Morte)
// Mortos adjacentes ao Necromante contra-atacam quem o atacar, 1 vez por
// rodada cada um. Usa o mesmo caminho do contra-ataque (riposte) do
// vanilla: ataque agendado com Time.scheduleEvent + useForFree.
// =====================================================================

this.perk_necro_sentinela <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_sentinela");
	}

	function counter( _attacker )
	{
		local util = this.Const.Necro.Util;
		local actor = this.getContainer().getActor();

		if (!util.isInCombat() || !util.isValidActor(_attacker) || _attacker.isAlliedWith(actor) || !actor.isPlacedOnMap())
		{
			return;
		}

		local rt = util.getRuntime();
		local round = this.Time.getRound();
		local i = 0;

		foreach( e in util.getAdjacentActors(actor.getTile()) )
		{
			if (!util.isSummon(e) || util.isMage(e) || e.getFlags().getAsInt(util.FlagMestre) != actor.getID())
			{
				continue;
			}

			if ((e.getID() in rt.SentinelaUsada) && rt.SentinelaUsada[e.getID()] == round)
			{
				continue;
			}

			rt.SentinelaUsada[e.getID()] <- round;
			util.scheduleAttack(e, _attacker, this.Const.Combat.RiposteDelay + 200 * i, null);
			i = ++i;
		}
	}

	function onMissed( _attacker, _skill )
	{
		this.counter(_attacker);
	}

	function onDamageReceived( _attacker, _damageHitpoints, _damageArmor )
	{
		this.counter(_attacker);
	}

});
