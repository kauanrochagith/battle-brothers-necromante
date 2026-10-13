// =====================================================================
// MOD NECROMANTE - Base dos perks do Necromante (cap. 11)
// ---------------------------------------------------------------------
// Nome, descrição e ícone vêm de Const.Necro.PerkInfo (necro_constants.nut).
// A maioria dos perks é só um "marcador": quem lê o perk e aplica o efeito
// são os mortos (necro_undead_racial.nut) e Const.Necro.Util, usando o
// cache de perks do Necromante.
// Os perks SÃO salvos no save (como perks vanilla) e não guardam dados
// extras, então o save continua compatível.
// =====================================================================

this.perk_necro <- this.inherit("scripts/skills/skill", {
	m = {},
	function create()
	{
		this.m.Type = this.Const.SkillType.Perk;
		this.m.Order = this.Const.SkillOrder.Perk;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsHidden = false;
	}

	function setupNecroPerk( _id )
	{
		local info = this.Const.Necro.PerkInfo[_id];
		this.m.ID = _id;
		this.m.Name = info.Nome;
		this.m.Description = info.Descricao;
		this.m.Icon = info.Icone;
	}

	function getTooltip()
	{
		return [
			{
				id = 1,
				type = "title",
				text = this.getName()
			},
			{
				id = 2,
				type = "description",
				text = this.getDescription()
			},
			{
				id = 3,
				type = "text",
				icon = "ui/icons/special.png",
				text = this.getOriginText()
			}
		];
	}

	function getOriginText()
	{
		local info = this.Const.Necro.PerkInfo[this.m.ID];

		if (info.Subclasse == "tronco")
		{
			return "Perk do Necromante - tronco comum";
		}

		if (info.Subclasse == "removido")
		{
			return "Perk antigo do Necromante (será devolvido no Juramento)";
		}

		return "Perk do Necromante - " + this.Const.Necro.Subclasses[info.Subclasse].Nome + ", fileira " + info.Fileira;
	}

	// FILTRO DE EXCLUSIVIDADE (última barreira): se este perk for adicionado
	// a um Necromante de OUTRA subclasse (por qualquer caminho), ele se remove
	// e devolve o ponto do Grimório. Retorna true se o perk pode ficar.
	function onAdded()
	{
		local actor = this.getContainer().getActor();

		if (this.Const.Necro.Util.isPerkAllowedFor(actor, this.m.ID))
		{
			return true;
		}

		this.removeSelf();

		this.Const.Necro.Util.refundGrimoirePoint(actor);

		this.logWarning("Necromante: perk " + this.m.ID + " bloqueado (outra subclasse)");
		return false;
	}

	// Perks que concedem uma ativa chamam isto no onAdded, depois do filtro.
	function grantActive( _script )
	{
		this.getContainer().add(this.new(_script));
	}

	function onRemoved()
	{
		this.skill.onRemoved();
	}

});
