# Procura textos em português que sobraram na versão em inglês (build_en/).
import re, glob, os, sys
RAIZ = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
lit = re.compile(r'"((?:[^"\\]|\\.)*)"')
pt = re.compile(r"[ãõçáéíóúâêôà]|\b(de|do|da|dos|das|os|as|um|uma|não|para|com|seus|ganham|turnos?|mortos?|vida|dano)\b", re.I)
for f in glob.glob(os.path.join(RAIZ, "build_en", "scripts", "**", "*.nut"), recursive=True):
    for n, linha in enumerate(open(f, encoding="utf-8").read().split("\n"), 1):
        if linha.lstrip().startswith("//"):
            continue
        for m in lit.finditer(linha):
            t = m.group(1)
            if pt.search(t) and not t.startswith(("scripts/", "ui/", "gfx/")):
                print(f"{os.path.relpath(f, RAIZ)}:{n}: {t[:90]}")
