// =====================================================================
// MOD NECROMANTE - Integração com o Legends (opcional)
// ---------------------------------------------------------------------
// O mod funciona no jogo original SEM hooks. Este arquivo só roda quando
// o carregador de mods (Modern Hooks, exigido pelo Legends) está presente;
// no jogo original ele é ignorado.
//
// Respec do Legends (actor.resetPerks): os perks do Grimório voltam como
// pontos do GRIMÓRIO, não como pontos de perk normais.
// =====================================================================

if ("mods_registerMod" in this.getroottable())
{
	::mods_registerMod("mod_necromante", "1.0.1", "Necromante");
	::mods_queue("mod_necromante", ">mod_legends", function ()
	{
		::mods_hookExactClass("entity/tactical/actor", function ( o )
		{
			if (!("resetPerks" in o))
			{
				return;
			}

			local resetPerks = o.resetPerks;
			o.resetPerks = function ()
			{
				local util = ::Const.Necro.Util;

				if (this.getSkills().hasSkill(util.BackgroundID))
				{
					// Antes do respec: tira os perks do Grimório e devolve os pontos a ele.
					util.respecGrimoire(this);
				}

				return resetPerks();
			};
		});
	});
}
