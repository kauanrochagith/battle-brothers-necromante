// =====================================================================
// MOD NECROMANTE - Origem "O Necromante"
// ---------------------------------------------------------------------
// O vanilla carrega automaticamente toda origem em "scripts/scenarios/world/"
// (ver scenario_manager.nut), então esta origem aparece na tela de nova
// campanha sem precisar de hooks.
//
// Ela serve para duas coisas:
//   1. Começar a campanha com um Necromante para testar o mod.
//   2. Fazer o Necromante aparecer para recrutar nas cidades
//      (onUpdateDraftList), já que o vanilla não tem um jeito limpo de
//      adicionar backgrounds novos às listas de recrutamento sem hooks.
// =====================================================================

this.necromancer_scenario <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},
	function create()
	{
		this.m.ID = "scenario.necro_necromancer";
		this.m.Name = "O Necromante";
		this.m.Description = "[p=c][img]gfx/ui/events/event_76.png[/img][/p][p]Expulso de todas as vilas, você aprendeu que os vivos são caros e os mortos são leais. Com dois saqueadores de túmulos ao seu lado, é hora de montar um exército que não sangra, não foge e não cobra salário.\n\n[color=#bcad8c]Necromante:[/color] Comece com um Necromante e dois saqueadores de túmulos.\n[color=#bcad8c]Seguidores Sombrios:[/color] Outros Necromantes podem aparecer para recrutar nas cidades.[/p]";
		this.m.Difficulty = 2;
		this.m.Order = 85;
	}

	function isValid()
	{
		return true;
	}

	function onSpawnAssets()
	{
		local roster = this.World.getPlayerRoster();
		local names = [];

		for( local i = 0; i < 3; i = ++i )
		{
			local bro = roster.create("scripts/entity/tactical/player");
			bro.m.HireTime = this.Time.getVirtualTimeF();

			// Evita nomes repetidos, como na origem dos Cultistas.
			while (names.find(bro.getNameOnly()) != null)
			{
				bro.setName(this.Const.Strings.CharacterNames[this.Math.rand(0, this.Const.Strings.CharacterNames.len() - 1)]);
			}

			names.push(bro.getNameOnly());
		}

		local bros = roster.getAll();

		// O Necromante fica na segunda linha (índices 9+ são a linha de trás).
		bros[0].setStartValuesEx([
			"necromancer_background"
		]);
		bros[0].getBackground().m.RawDescription = "%name% não pediu para liderar ninguém. Mas os dois saqueadores que o seguem viram o que ele fez no cemitério de %townname%, e desde então não saem do seu lado.";
		bros[0].getBackground().buildDescription(true);
		bros[0].setPlaceInFormation(13);

		bros[1].setStartValuesEx([
			"graverobber_background"
		]);
		bros[1].setPlaceInFormation(3);

		bros[2].setStartValuesEx([
			"graverobber_background"
		]);
		bros[2].setPlaceInFormation(4);

		this.World.Assets.addMoralReputation(-10);
		this.World.Assets.getStash().add(this.new("scripts/items/supplies/ground_grains_item"));
	}

	function onSpawnPlayer()
	{
		// Mesmo procedimento da origem dos Cultistas: começa perto de uma vila pequena.
		local randomVillage;

		for( local i = 0; i != this.World.EntityManager.getSettlements().len(); i = ++i )
		{
			randomVillage = this.World.EntityManager.getSettlements()[i];

			if (!randomVillage.isMilitary() && !randomVillage.isIsolatedFromRoads() && randomVillage.getSize() == 1)
			{
				break;
			}
		}

		local randomVillageTile = randomVillage.getTile();
		local navSettings = this.World.getNavigator().createSettings();
		navSettings.ActionPointCosts = this.Const.World.TerrainTypeNavCost_Flat;

		do
		{
			local x = this.Math.rand(this.Math.max(2, randomVillageTile.SquareCoords.X - 4), this.Math.min(this.Const.World.Settings.SizeX - 2, randomVillageTile.SquareCoords.X + 4));
			local y = this.Math.rand(this.Math.max(2, randomVillageTile.SquareCoords.Y - 4), this.Math.min(this.Const.World.Settings.SizeY - 2, randomVillageTile.SquareCoords.Y + 4));

			if (!this.World.isValidTileSquare(x, y))
			{
			}
			else
			{
				local tile = this.World.getTileSquare(x, y);

				if (tile.Type == this.Const.World.TerrainType.Ocean || tile.Type == this.Const.World.TerrainType.Shore || tile.IsOccupied)
				{
				}
				else if (tile.getDistanceTo(randomVillageTile) <= 1)
				{
				}
				else if (tile.Type != this.Const.World.TerrainType.Plains && tile.Type != this.Const.World.TerrainType.Steppe && tile.Type != this.Const.World.TerrainType.Tundra && tile.Type != this.Const.World.TerrainType.Snow)
				{
				}
				else
				{
					local path = this.World.getNavigator().findPath(tile, randomVillageTile, navSettings, 0);

					if (!path.isEmpty())
					{
						randomVillageTile = tile;
						break;
					}
				}
			}
		}
		while (1);

		this.World.State.m.Player = this.World.spawnEntity("scripts/entity/world/player_party", randomVillageTile.Coords.X, randomVillageTile.Coords.Y);
		this.World.Assets.updateLook(7);
		this.World.getCamera().setPos(this.World.State.m.Player.getPos());
		this.Time.scheduleEvent(this.TimeUnit.Real, 1000, function ( _tag )
		{
			this.Music.setTrackList(this.Const.Music.CivilianTracks, this.Const.Music.CrossFadeTime);
		}, null);
	}

	function onUpdateDraftList( _list )
	{
		// Nesta origem, Necromantes podem aparecer para recrutar nas cidades maiores.
		if (_list.len() >= 10)
		{
			_list.push("necromancer_background");
		}
	}

});
