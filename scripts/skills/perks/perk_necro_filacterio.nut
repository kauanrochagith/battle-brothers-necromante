// =====================================================================
// MOD NECROMANTE - Perk: Filactério (Lich)
// ---------------------------------------------------------------------
// Uma vez por combate, quando o Lich receberia um golpe fatal, ele "volta"
// com FilacterioHP da vida e cada Mago ganha +FilacterioDanoMagos de dano
// por FilacterioTurnos turnos (necro_phylactery_buff_effect).
// Como o Cadáver Substituto: onDamageReceived roda ANTES de o vanilla
// descontar o HP, então ajustamos o HP para que, depois do desconto, sobre
// exatamente FilacterioHP. Assim o Lich não morre e os mortos não desabam.
// =====================================================================

this.perk_necro_filacterio <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_filacterio");
	}

	function onDamageReceived( _attacker, _damageHitpoints, _damageArmor )
	{
		local util = this.Const.Necro.Util;
		local actor = this.getContainer().getActor();

		if (!util.isInCombat() || _damageHitpoints < actor.getHitpoints())
		{
			return;
		}

		local rt = util.getRuntime();

		if (actor.getID() in rt.FilacterioUsado)
		{
			return;
		}

		// O Cadáver Substituto (se houver) já anulou o golpe.
		if (_damageHitpoints < actor.m.Hitpoints)
		{
			return;
		}

		rt.FilacterioUsado[actor.getID()] <- true;
		local LI = this.Const.Necro.Sub.Lich;
		local restante = this.Math.max(1, this.Math.floor(actor.getHitpointsMax() * LI.FilacterioHP));
		actor.m.Hitpoints = restante + _damageHitpoints;

		foreach( e in util.getSummonsOfMaster(actor.getID(), true) )
		{
			if (util.isMage(e))
			{
				e.getSkills().removeByID("effects.necro_phylactery_buff");
				e.getSkills().add(this.new("scripts/skills/effects/necro_phylactery_buff_effect"));
			}
		}

		if (!actor.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(actor) + " se recompõe do Filactério!");
		}
	}

});
