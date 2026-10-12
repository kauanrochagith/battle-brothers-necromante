// =====================================================================
// MOD NECROMANTE - Chamar o Cavaleiro (Cavaleiro da Morte)
// ---------------------------------------------------------------------
// Invoca ChamarQuantidade Cavaleiros Mortos (ChamarQuantidadeElite com
// Elite Funesta), respeitando o limite de mortos da subclasse.
// =====================================================================

this.necro_knight_call <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local CA = this.Const.Necro.Sub.Cavaleiro;
		this.m.ID = "actives.necro_knight_call";
		this.m.Name = "Chamar o Cavaleiro";
		this.m.Description = "Chama do túmulo cavaleiros mortos de elite, ligados ao Necromante.";
		this.m.Icon = "skills/active_139.png";
		this.m.IconDisabled = "skills/active_139_sw.png";
		this.m.Overlay = "active_139";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_01.wav",
			"sounds/enemies/necromancer_03.wav"
		];
		this.m.Order = this.Const.SkillOrder.NonTargeted + 10;
		this.m.IsTargeted = false;
		this.m.ActionPointCost = CA.ChamarPA;
		this.m.FatigueCost = CA.ChamarFadiga;
	}

	function getCooldownMax()
	{
		return this.Const.Necro.Sub.Cavaleiro.ChamarCD;
	}

	function getCount()
	{
		local CA = this.Const.Necro.Sub.Cavaleiro;
		return this.getUtil().hasPerkByMasterID(this.getContainer().getActor().getID(), "perk.necro_elite_funesta") ? CA.ChamarQuantidadeElite : CA.ChamarQuantidade;
	}

	function isUsable()
	{
		return this.necro_active_base.isUsable() && this.getUtil().getFreeSlots(this.getContainer().getActor().getID()) > 0;
	}

	function onAddTooltip( _tooltip )
	{
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Invoca [color=" + this.Const.UI.Color.PositiveValue + "]" + this.getCount() + "[/color] Cavaleiros Mortos"
		});
	}

	function onUse( _user, _targetTile )
	{
		local n = this.getUtil().raiseGroup("cavaleiro", _user, _user, false, this.getCount());

		if (n > 0)
		{
			this.startCooldown();
		}

		return n > 0;
	}

});
