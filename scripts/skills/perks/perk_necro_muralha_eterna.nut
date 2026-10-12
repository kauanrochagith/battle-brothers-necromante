// =====================================================================
// MOD NECROMANTE - Perk: Muralha Eterna (Senhor da Legião)
// Soldados Nobres e Paladinos a até MuralhaRaio do Necromante absorvem
// MuralhaFracao do dano à vida que ele receberia, dividido entre eles.
// onDamageReceived roda antes de o vanilla descontar o HP: devolvemos a
// parte absorvida ao Necromante e causamos esse dano nos guardas.
// =====================================================================

this.perk_necro_muralha_eterna <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_muralha_eterna");
	}

	function onDamageReceived( _attacker, _damageHitpoints, _damageArmor )
	{
		local util = this.Const.Necro.Util;
		local L = this.Const.Necro.Sub.Legiao;
		local actor = this.getContainer().getActor();

		if (!util.isInCombat() || _damageHitpoints <= 0 || !actor.isPlacedOnMap())
		{
			return;
		}

		local guardas = [];

		foreach( e in util.getSummonsOfMaster(actor.getID(), false) )
		{
			local t = e.getFlags().get(util.FlagTipo);

			if ((t == "soldado" || t == "paladino") && e.getTile().getDistanceTo(actor.getTile()) <= L.MuralhaRaio)
			{
				guardas.push(e);
			}
		}

		local absorvido = this.Math.floor(_damageHitpoints * L.MuralhaFracao);

		if (guardas.len() == 0 || absorvido <= 0)
		{
			return;
		}

		actor.m.Hitpoints = actor.m.Hitpoints + absorvido;
		local parte = this.Math.max(1, absorvido / guardas.len());

		foreach( e in guardas )
		{
			util.dealDirectDamage(e, parte, _attacker, this);
		}
	}

});
