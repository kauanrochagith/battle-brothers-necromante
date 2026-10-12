// ======================================================================
// Mini-ambiente que imita o runtime de scripts do Battle Brothers para
// testar o mod fora do jogo. Carrega os .nut REAIS do mod e do vanilla.
// ======================================================================
::MOD <- "C:/Users/User/mod_necromante/";
::VAN <- "C:/Users/User/mod_necromante/tools/vanilla/";
::HARNESS <- "C:/Users/User/mod_necromante/tests/";
::__classes <- {};
::__falhas <- 0;
::__ok <- 0;
::__log <- [];

function lastSeg( _p ) { local idx = 0; for (local i = 0; i < _p.len(); i++) if (_p[i] == '/') idx = i + 1; return _p.slice(idx); }
function fileExists( _f ) { try { local x = ::loadfile(_f); return true; } catch (e) { return false; } }

function loadClass( _path )
{
	if (_path in ::__classes) return ::__classes[_path];
	local name = lastSeg(_path);
	local f = ::MOD + _path + ".nut";
	if (!fileExists(f)) f = ::VAN + _path + ".nut";
	if (!fileExists(f)) f = ::HARNESS + _path + ".nut";
	::dofile(f);
	local obj = ::getroottable()[name];
	local desc;
	if ("__isInherit" in obj) desc = { Name = name, Parent = obj.Parent, Def = obj.Def };
	else desc = { Name = name, Parent = null, Def = obj };
	::__classes[_path] <- desc;
	return desc;
}

::inherit <- function ( _parentPath, _def ) { return { __isInherit = true, Parent = loadClass(_parentPath), Def = _def }; };

function deepCloneValue( _v )
{
	if (typeof _v == "table") { local t = {}; foreach (k, v in _v) t[k] <- deepCloneValue(v); return t; }
	if (typeof _v == "array") { local a = []; foreach (v in _v) a.push(deepCloneValue(v)); return a; }
	return _v;
}

::new <- function ( _path )
{
	local leaf = loadClass(_path);
	local chain = [];
	for (local d = leaf; d != null; d = d.Parent) chain.insert(0, d);
	local inst = {};
	inst.setdelegate(::getroottable());
	local m = {};
	local funcs = {};
	foreach (lvl in chain)
	{
		if ("m" in lvl.Def) foreach (k, v in lvl.Def.m) m[k] <- deepCloneValue(v);
		foreach (k, v in lvl.Def) if (typeof v == "function") funcs[k] <- v;
		if (lvl != leaf)
		{
			local proxy = {};
			foreach (k, v in funcs) proxy[k] <- v.bindenv(inst);
			inst[lvl.Name] <- proxy;
		}
	}
	foreach (k, v in funcs) inst[k] <- v;
	inst.m <- m;
	inst.ClassNameHash <- _path;
	if ("create" in inst) inst.create();
	return inst;
};

::isKindOf <- function ( _o, _n ) { return false; };
::logInfo <- function ( _s ) {};
::logDebug <- function ( _s ) {};
::logWarning <- function ( _s ) { ::__log.push("AVISO: " + _s); };
::logError <- function ( _s ) { ::__log.push("ERRO: " + _s); print("  logError: " + _s + "\n"); };
::Math <- {
	rand = function ( a, b ) { return a; },
	max = function ( a, b ) { return a > b ? a : b; }, min = function ( a, b ) { return a < b ? a : b; },
	maxf = function ( a, b ) { return a > b ? a : b; }, minf = function ( a, b ) { return a < b ? a : b; },
	round = function ( a ) { return (a + 0.5).tointeger(); }, floor = function ( a ) { return a.tointeger(); },
	ceil = function ( a ) { local i = a.tointeger(); return i < a ? i + 1 : i; },
	abs = function ( a ) { return a < 0 ? -a : a; }, pow = function ( a, b ) { local r = 1.0; for (local i = 0; i < b; i++) r *= a; return r; }
};
::Time <- { round = 1, getRound = function () { return ::Time.round; }, getVirtualTimeF = function () { return 0.0; }, getFrame = function () { return 0; } };
::Sound <- { play = function ( ... ) {} };

::dofile(::VAN + "scripts/tools/weak_table_ref.nut");

// ---------------- Const ----------------
::Const <- {
	SkillType = { None = 0, Active = 1, Trait = 2, Racial = 4, StatusEffect = 8, Special = 16, Item = 32, Perk = 64, Terrain = 128, Background = 512, DamageOverTime = 65536 },
	SkillOrder = { First = 0, Item = 1000, Perk = 5000, Background = 6000, Trait = 8000, UtilityTargeted = 20000, NonTargeted = 40000, Any = 50000, Last = 70000, VeryLast = 80000 },
	ProjectileType = { None = 0 },
	UI = { Color = { PositiveValue = "#4f8f1e", NegativeValue = "#8f1e1e" }, getColorizedEntityName = function ( _e ) { return _e.getName(); } },
	Faction = { Player = 1, PlayerAnimals = 2, Enemy = 3 },
	BodyPart = { Body = 0, Head = 1 },
	Tactical = { HitInfo = { DamageRegular = 0, DamageDirect = 0.0, BodyPart = 0, BodyDamageMult = 1.0, FatalityChanceMult = 1.0 }, RaiseUndeadParticles = [] },
	Items = { ItemType = { Ammo = 4 } },
	Movement = { AnnounceDiscoveredEntities = true },
	Bodies = { AllMale = [], Skinny = [] }, Faces = { AllMale = [] }, Hair = { UntidyMale = [] }, HairColors = { All = [] }, Beards = { Untidy = [] },
	Strings = { CharacterNames = [ "Fulano" ] },
	LevelXP = [0, 200, 500, 1000, 2000, 3500, 5000, 7000, 9000, 12000, 15000],
	SkillCounter = 0
};
::dofile(::MOD + "scripts/config/necro_constants.nut");
::dofile(::MOD + "scripts/config/necro_helpers.nut");

// ---------------- Mundo / Tático simulados ----------------
::EventLog <- [];
::TacticalEntities <- [];
::Tactical <- {
	State = null,
	Entities = {
		getInstancesOfFaction = function ( _f ) { local r = []; foreach (e in ::TacticalEntities) if (e.getFaction() == _f) r.push(e); return r; },
		getAllInstances = function () { return [ ::TacticalEntities ]; }
	},
	EventLog = { log = function ( _s ) { ::EventLog.push(_s); }, logEx = function ( _s ) { ::EventLog.push(_s); } },
	getEntityByID = function ( _id ) { foreach (e in ::TacticalEntities) if (e.getID() == _id) return e; foreach (e in ::Roster) if (e.getID() == _id) return e; return null; }
};
::Roster <- [];
::Stash <- { slots = 10, items = [], hasEmptySlot = function () { return ::Stash.items.len() < ::Stash.slots; }, add = function ( _i ) { ::Stash.items.push(_i); return _i; } };
::Money <- 0;
::SpecialEvents <- [];
::World <- {
	getPlayerRoster = function () { return { getAll = function () { return ::Roster; }, getSize = function () { return ::Roster.len(); } }; },
	Assets = { getStash = function () { return ::Stash; }, addMoney = function ( _f ) { ::Money += _f; } },
	Events = { m = { SpecialEvents = ::SpecialEvents }, getEvent = function ( _id ) { return {}; }, addSpecialEvent = function ( _id ) { ::SpecialEvents.push(_id); } }
};

// ---------------- Personagem simulado ----------------
function makeContainer( _actor )
{
	local c = { m = { Skills = [] }, actor = _actor };
	c.getActor <- function () { return this.actor; };
	c.add <- function ( _s ) {
		foreach (s in this.m.Skills) if (!s.m.IsGarbage && s.getID() == _s.getID() && !_s.isStacking()) return;
		_s.setContainer(this); this.m.Skills.push(_s); _s.onAdded();
	};
	c.removeByID <- function ( _id ) { foreach (i, s in this.m.Skills) if (s.getID() == _id && !s.m.IsGarbage) { s.m.IsGarbage = true; this.m.Skills.remove(i); s.onRemoved(); return; } };
	c.remove <- function ( _s ) { foreach (i, s in this.m.Skills) if (s == _s) { s.m.IsGarbage = true; this.m.Skills.remove(i); s.onRemoved(); return; } };
	c.getSkillByID <- function ( _id ) { foreach (s in this.m.Skills) if (s.getID() == _id && !s.m.IsGarbage) return s; return null; };
	c.hasSkill <- function ( _id ) { return this.getSkillByID(_id) != null; };
	c.update <- function () {};
	c.isUpdating <- function () { return false; };
	return c;
}
::__nextID <- 100;
function makeActor( _name, _faction = 1 )
{
	local a = {};
	a.setdelegate(::getroottable());
	a.m <- { ID = ::__nextID++, Name = _name, PerkPoints = 0, PerkPointsSpent = 0, Level = 1, XP = 0, Hitpoints = 50, Fatigue = 0, Faction = _faction, Alive = true, Background = null };
	a.flags <- ::new("scripts/tools/tag_collection");
	a.skills <- makeContainer(a);
	a.getID <- function () { return this.m.ID; };
	a.getName <- function () { return this.m.Name; };
	a.getFlags <- function () { return this.flags; };
	a.getSkills <- function () { return this.skills; };
	a.getLevel <- function () { return this.m.Level; };
	a.getPerkPoints <- function () { return this.m.PerkPoints; };
	a.getImagePath <- function () { return "img"; };
	a.getFaction <- function () { return this.m.Faction; };
	a.isAlive <- function () { return this.m.Alive; };
	a.isDying <- function () { return false; };
	a.isPlacedOnMap <- function () { return true; };
	a.isHiddenToPlayer <- function () { return true; };
	a.tile <- { ID = a.m.ID, IsVisibleForPlayer = false, IsVisibleForEntity = true, Level = 0, X = 0, hasNextTile = function ( _i ) { return false; }, getDistanceTo = function ( _t ) { return ::Math.abs(this.X - _t.X); } };
	a.getTile <- function () { return this.tile; };
	a.getTitle <- function () { return ""; };
	a.setTitle <- function ( _t ) {};
	a.isAlliedWith <- function ( _o ) { return (this.m.Faction <= 2) == (_o.getFaction() <= 2); };
	a.getHitpoints <- function () { return this.m.Hitpoints; };
	a.getXPValue <- function () { return 100; };
	a.addXP <- function ( _xp, _scale = true ) { this.m.XP += _xp; };
	a.updateLevel <- function () { while (this.m.Level < 11 && this.m.XP >= ::Const.LevelXP[this.m.Level]) { this.m.Level++; this.m.PerkPoints++; } };
	a.setFatigue <- function ( _f ) { this.m.Fatigue = _f; };
	a.getCurrentProperties <- function () { return { IsImmuneToPoison = false, AdditionalActionPointCost = 0, SkillCostAdjustments = [], IsSkillUseFree = false, IsSkillUseHalfCost = false, FatigueEffectMult = 1.0, FatigueOnSkillUse = 0 }; };
	a.getPreviewSkillID <- function () { return ""; };
	a.getPreviewActionPoints <- function () { return 9; };
	a.getPreviewFatigue <- function () { return 0; };
	a.getActionPoints <- function () { return 9; };
	a.getFatigue <- function () { return this.m.Fatigue; };
	a.getFatigueMax <- function () { return 100; };
	a.Damage <- 0;
	a.onDamageReceived <- function ( _att, _skill, _hit ) { this.Damage += _hit.DamageRegular; this.m.Hitpoints -= _hit.DamageRegular; return _hit.DamageRegular; };
	return a;
}

function makeNecro( _name, _level = 1 )
{
	local n = makeActor(_name);
	n.m.Level = _level;
	n.m.PerkPoints = _level - 1;
	n.m.Background <- null;
	local bg = ::new("scripts/skills/backgrounds/necromancer_background");
	n.getSkills().add(bg);
	::Roster.push(n);
	return n;
}

// ---------------- Asserções ----------------
function check( _nome, _cond )
{
	if (_cond) { ::__ok++; print("  ok   " + _nome + "\n"); }
	else { ::__falhas++; print("  FALHA " + _nome + "\n"); }
}
function secao( _t ) { print("\n== " + _t + " ==\n"); }
function novoCombate() { return { isScenarioMode = function () { return false; }, isFleeing = function () { return false; } }; }
function resetMundo()
{
	::Roster.clear(); ::TacticalEntities.clear(); ::Stash.items.clear(); ::Money = 0; ::SpecialEvents.clear();
	::Tactical.State = null; ::Const.Necro.Util.clearRuntime(); ::Const.Necro.Util.clearPendingSpoils();
}
