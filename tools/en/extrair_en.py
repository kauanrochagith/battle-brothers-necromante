# =====================================================================
# Versão em inglês do mod: lista os textos (literais de string) dos .nut
# que aparecem para o jogador, para traduzir em tools/en/textos_en.json.
#
# Uso: python tools/en/extrair_en.py          -> atualiza textos_en.json
#      (mantém traduções já feitas; textos novos entram com "" para traduzir)
# =====================================================================
import re, glob, json, os

RAIZ = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SAIDA = os.path.join(RAIZ, "tools", "en", "textos_en.json")
LITERAL = re.compile(r'"((?:[^"\\]|\\.)*)"')

# Chaves de código, caminhos e IDs nunca são traduzidos.
NAO_TEXTO = re.compile(
    r"^(scripts/|ui/|gfx/|sounds/|bust_|perk\.|actives\.|effects\.|special\.|racial\.|"
    r"background\.|event\.|trait\.|injury\.|scenario\.|items\.|necro_|mod_)"
)


def eh_texto(t):
    if not re.search(r"[A-Za-zÀ-ú]{2,}", t):
        return False
    if NAO_TEXTO.match(t):
        return False
    # Uma palavra só sem espaço: provável ID/chave (ex.: "Region", "guerreiro").
    if " " not in t and not re.search(r"[À-ú]", t) and not re.match(r"^[A-ZÀ-Ú][a-zà-ú]+[:!.?]?$", t):
        return False
    return True


def sem_comentarios(linha):
    # remove // comentário fora de string
    dentro = False
    i = 0
    while i < len(linha):
        c = linha[i]
        if c == "\\" and dentro:
            i += 2
            continue
        if c == '"':
            dentro = not dentro
        elif not dentro and linha.startswith("//", i):
            return linha[:i]
        i += 1
    return linha


def textos_do_arquivo(caminho):
    out = []
    for linha in open(caminho, encoding="utf-8").read().split("\n"):
        for m in LITERAL.finditer(sem_comentarios(linha)):
            t = m.group(1)
            if eh_texto(t):
                out.append(t)
    return out


def coletar():
    vistos = {}
    for f in sorted(glob.glob(os.path.join(RAIZ, "scripts", "**", "*.nut"), recursive=True)):
        rel = os.path.relpath(f, RAIZ).replace("\\", "/")
        for t in textos_do_arquivo(f):
            vistos.setdefault(t, rel)
    return vistos


if __name__ == "__main__":
    vistos = coletar()
    atual = json.load(open(SAIDA, encoding="utf-8")) if os.path.exists(SAIDA) else {}
    novo = {t: atual.get(t, "") for t in vistos}
    json.dump(novo, open(SAIDA, "w", encoding="utf-8", newline="\n"), ensure_ascii=False, indent=1)
    falta = sum(1 for v in novo.values() if not v)
    print(f"{len(novo)} textos, {falta} sem tradução, {sum(len(t.split()) for t in novo)} palavras")
