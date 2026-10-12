# Gera os perks "marcadores" das subclasses: o perk só existe no
# Necromante; quem lê e aplica o efeito são a racial dos mortos,
# Const.Necro.Util e as ativas (via cache de perks).
# Não sobrescreve arquivos que já existem (perks com lógica própria).
import os

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PASTA = os.path.join(RAIZ, "scripts", "skills", "perks")

MARCADORES = {
    # Legião
    "parede_escudos_mortos": "necro_undead_racial.nut (updateLegion)",
    "cadeia_de_comando": "Util.updateCaptain / necro_undead_racial.nut",
    "veteranos_eternos": "necro_undead_racial.nut (onTargetKilled / updateLegion)",
    "estandarte_osseo": "Util.raiseGroup / Util.updateBanner / necro_undead_racial.nut",
    "baixas_aceitaveis": "necro_undead_racial.nut (onDeath) + necro_baixas_effect.nut",
    "flanco_sombrio": "necro_undead_racial.nut (onAnySkillUsed)",
    "legiao_incontavel": "Util.getMaxSummons / necro_raise_dead.nut",
    # Lich
    "escola_de_magos": "Util.getMaxMages",
    "eco_perfeito": "necro_undead_racial.nut (getPassiveMult)",
    "conjuracao_paralela": "necro_mage_raise.nut (getTypeCooldown)",
    "livro_dos_mortos": "necro_mage_raise.nut (getMaxUses)",
    "arcano_profano": "necro_mago.nut (onNecroSpawned) + necro_mage_ray.nut",
    "silencio_da_cripta": "necro_sub_lich.nut + necro_enemy_aura_effect.nut",
    "arquimago": "necro_lich_ray.nut",
    # Peste
    "contagio": "necro_dot_effect.nut (spreadContagion)",
    "corpos_inchados": "necro_undead_racial.nut (onDeath)",
    "febre_cadaverica": "necro_dot_effect.nut (onUpdate)",
    "hospedeiro": "necro_dot_effect.nut (onDeath)",
    "virulencia": "Util.getStackCap / Util.getUndeadEffectMult",
    "pandemia": "necro_plague_epidemic.nut",
    # Cavaleiro
    "elite_funesta": "necro_undead.nut (getSpawnMults) / racial / necro_knight_call.nut",
    "lealdade_eterna": "necro_undead_racial.nut (onDeath)",
    # Atirador
    "disparo_triplo": "necro_undead_racial.nut (tryTripleShot)",
    "visao_espectral": "necro_undead_racial.nut (onUpdate)",
    "postura_fantasma": "necro_undead_racial.nut (onUpdate / onAnySkillUsed)",
    "chuva_de_flechas": "necro_sub_shooter.nut",
    "execucao_a_distancia": "necro_undead_racial.nut (onTargetKilled)",
    "flechas_perfurantes": "necro_undead_racial.nut (onAnySkillUsed)",
    "olho_do_cacador": "necro_undead_racial.nut (onUpdate)",
    # Coveiro
    "memoria_do_cadaver": "necro_reanimado.nut (setupFromCorpse)",
    "coveiro_eficiente": "necro_grave_raise.nut",
    "campo_de_batalha_antigo": "necro_sub_gravedigger.nut",
    "sem_descanso": "necro_reanimado.nut / necro_undead_racial.nut (onDeath)",
    "exercito_roubado": "necro_reanimado.nut / necro_undead_racial.nut",
    "cemiterio_itinerante": "Util.reanimateCorpse",
    "mestre_dos_cadaveres": "Util.getReanimateScale",
    "ceifador": "necro_undead_racial.nut (onDeath)",
    # Ossário
    "osso_fresco": "necro_undead.nut (getSpawnMults) / fusão",
    "colosso": "necro_abominacao.nut (setupFusion)",
    "esmagar_giratorio": "necro_abominacao.nut (setupFusion)",
    "fusao_rapida": "necro_ossuary_fuse.nut",
    "costura_de_ossos": "necro_undead_racial.nut (onTurnStart)",
    "artilharia_de_ossos": "necro_ossuary_fuse.nut",
    "linhagem_de_ossos": "Util.applyOnHit",
    "abominacao_alfa": "necro_ossuary_fuse.nut / necro_abominacao.nut / racial",
    "ressurgir_dos_ossos": "necro_undead_racial.nut (onDeath)",
    # Maestro
    "batuta_ossea": "Util.getOrderDuration",
    "sincronia": "necro_undead_racial.nut",
    "ordem_dupla": "Util.giveOrder",
    "partitura_tatica": "necro_undead_racial.nut (onAnySkillUsed)",
    "coro_de_ossos": "necro_sub_maestro.nut + necro_enemy_aura_effect.nut",
    "cadencia_perfeita": "necro_maestro_order.nut",
    "crescendo": "Util.tickOrders / Util.getCrescendoMult",
}

TEMPLATE = """// =====================================================================
// MOD NECROMANTE - Perk: {nome}
// Marcador: o efeito é aplicado em {onde}.
// =====================================================================

this.perk_necro_{id} <- this.inherit("scripts/skills/perks/perk_necro", {{
	m = {{}},
	function create()
	{{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_{id}");
	}}

}});
"""

def nome(id_):
    return id_.replace("_", " ").title()

criados = 0
for id_, onde in MARCADORES.items():
    caminho = os.path.join(PASTA, "perk_necro_%s.nut" % id_)
    if os.path.exists(caminho):
        continue
    open(caminho, "w", encoding="utf-8").write(TEMPLATE.format(id=id_, nome=nome(id_), onde=onde))
    criados += 1
print("%d perks marcadores criados" % criados)
