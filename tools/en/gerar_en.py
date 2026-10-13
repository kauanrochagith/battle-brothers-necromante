# =====================================================================
# Gera a versão em inglês do mod a partir do código em português.
#
#   python tools/en/gerar_en.py juntar   -> junta tools/en/en_*.txt ("índice<TAB>texto")
#                                           em textos_en.json (na ordem de extrair_en.py)
#   python tools/en/gerar_en.py <saida>  -> copia scripts/ para <saida>/scripts trocando
#                                           cada texto pela tradução (literal inteiro)
#
# Confere em cada texto: %variáveis%, [color=, [/color], \n, { } e |.
# =====================================================================
import sys, os, re, json, glob, shutil

RAIZ = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EN = os.path.join(RAIZ, "tools", "en")
JSON = os.path.join(EN, "textos_en.json")


def marcas(s):
    return (sorted(re.findall(r"%\w+%", s)), s.count("[color="), s.count("[/color]"),
            s.count("\\n"), s.count("{"), s.count("}"), s.count("|"))


def juntar():
    textos = json.load(open(JSON, encoding="utf-8"))
    chaves = list(textos.keys())
    traducoes = {}
    for f in sorted(glob.glob(os.path.join(EN, "en_*.txt"))):
        for linha in open(f, encoding="utf-8").read().split("\n"):
            if not linha:
                continue
            i, t = linha.split("\t", 1)
            traducoes[int(i)] = t
    erros = 0
    for i, k in enumerate(chaves):
        if i not in traducoes:
            print(f"FALTA {i}: {k[:70]}")
            erros += 1
            continue
        t = traducoes[i]
        # Espaços de borda do original são preservados (fragmentos colados a números).
        ini = k[: len(k) - len(k.lstrip(" "))]
        fim = k[len(k.rstrip(" ")):]
        t = ini + t.strip(" ") + fim
        if marcas(k) != marcas(t):
            print(f"MARCAS {i}: {k[:50]} => {t[:50]}")
            erros += 1
        if re.search(r'(?<!\\)"', t):
            print(f"ASPAS {i}: {t[:60]}")
            erros += 1
        textos[k] = t
    json.dump(textos, open(JSON, "w", encoding="utf-8", newline="\n"), ensure_ascii=False, indent=1)
    print(f"{len(chaves)} textos, {erros} problema(s)")
    return erros


def gerar(saida):
    textos = json.load(open(JSON, encoding="utf-8"))
    falta = [k for k, v in textos.items() if not v]
    if falta:
        sys.exit(f"ERRO: {len(falta)} textos sem tradução (rode extrair_en.py e traduza)")
    lit = re.compile(r'"((?:[^"\\]|\\.)*)"')
    destino = os.path.join(saida, "scripts")
    if os.path.exists(destino):
        shutil.rmtree(destino)
    trocas = 0
    for f in glob.glob(os.path.join(RAIZ, "scripts", "**", "*"), recursive=True):
        if os.path.isdir(f):
            continue
        rel = os.path.relpath(f, os.path.join(RAIZ, "scripts"))
        alvo = os.path.join(destino, rel)
        os.makedirs(os.path.dirname(alvo), exist_ok=True)
        if not f.endswith(".nut"):
            shutil.copy2(f, alvo)
            continue
        linhas = open(f, encoding="utf-8").read().split("\n")
        novas = []
        for linha in linhas:
            codigo = linha.lstrip()
            if codigo.startswith("//"):
                novas.append(linha)
                continue

            def troca(m):
                nonlocal trocas
                t = m.group(1)
                if t in textos and textos[t] != t:
                    trocas += 1
                    return '"' + textos[t] + '"'
                return m.group(0)

            novas.append(lit.sub(troca, linha))
        open(alvo, "w", encoding="utf-8", newline="\n").write("\n".join(novas))
    print(f"versão em inglês gerada em {destino} ({trocas} textos trocados)")


if __name__ == "__main__":
    if sys.argv[1] == "juntar":
        sys.exit(1 if juntar() else 0)
    gerar(sys.argv[1])
