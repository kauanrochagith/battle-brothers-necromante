// =====================================================================
// MOD NECROMANTE - Comportamento de IA do Mago: conjurar sempre que puder
// ---------------------------------------------------------------------
// Reaproveita o "ai_always_use" do vanilla (o mesmo usado por habilidades
// que a IA usa assim que estão disponíveis). As habilidades do Mago não
// têm alvo: cada uma escolhe sozinha onde/quem atingir e só fica "usável"
// quando vale a pena (cooldown pronto, espaço livre, alvos com efeitos...).
// =====================================================================

this.ai_necro_mage_cast <- this.inherit("scripts/ai/tactical/behaviors/ai_always_use", {
	m = {},
	function create()
	{
		this.ai_always_use.create();
		this.m.PossibleSkills = [
			"actives.necro_mage_raise",
			"actives.necro_mage_mark",
			"actives.necro_mage_harvest",
			"actives.necro_mage_ray"
		];
	}

});
