// =====================================================================
// MOD NECROMANTE - Perk: Cadáver Substituto (camada 6)
// ---------------------------------------------------------------------
// Uma vez por combate, quando o Necromante receberia um golpe fatal, um
// morto adjacente absorve o golpe e morre no lugar.
// Como funciona: o vanilla chama onDamageReceived das habilidades ANTES
// de descontar o HP (ver actor.onDamageReceived). Se o dano vai matar,
// devolvemos esse dano ao HP (o golpe "não pega") e matamos o morto.
// =====================================================================

this.perk_necro_cadaver_substituto <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_cadaver_substituto");
	}

	function onDamageReceived( _attacker, _damageHitpoints, _damageArmor )
	{
		local util = this.Const.Necro.Util;
		local actor = this.getContainer().getActor();

		if (!util.isInCombat() || _damageHitpoints < actor.getHitpoints() || !actor.isPlacedOnMap())
		{
			return;
		}

		local rt = util.getRuntime();

		if (actor.getID() in rt.SubstitutoUsado)
		{
			return;
		}

		// Procura um morto adjacente (Magos não servem de escudo).
		local myTile = actor.getTile();
		local victim = null;

		for( local i = 0; i < 6; i = ++i )
		{
			if (!myTile.hasNextTile(i))
			{
				continue;
			}

			local t = myTile.getNextTile(i);

			if (t.IsOccupiedByActor)
			{
				local e = t.getEntity();

				if (util.isValidActor(e) && util.isSummon(e) && !util.isMage(e) && e.getFlags().getAsInt(util.FlagMestre) == actor.getID())
				{
					victim = e;
					break;
				}
			}
		}

		if (victim == null)
		{
			return;
		}

		rt.SubstitutoUsado[actor.getID()] <- true;

		// Anula o golpe: o vanilla vai subtrair _damageHitpoints logo depois.
		actor.m.Hitpoints = actor.m.Hitpoints + _damageHitpoints;

		if (!actor.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(victim) + " se joga na frente do golpe e morre no lugar de " + this.Const.UI.getColorizedEntityName(actor));
		}

		victim.kill(_attacker, null, this.Const.FatalityType.None, false);
	}

});
