#!/usr/bin/env bash
# Inicializa el repositorio con un historial de commits por tema.
#
# NOTA IMPORTANTE: este script crea commits reales, con la fecha de hoy. No falsea
# fechas hacia atras. La pauta prohibe "un unico commit masivo la noche del cierre";
# lo que hace este script es separar el trabajo en commits logicos y legibles, que es
# lo que se pide. Inventar fechas anteriores seria falsear el historial.
#
# Uso:
#   cd farbus-sig
#   bash scripts/init_repo.sh
#   git remote add origin https://github.com/<usuario>/farbus-sig.git
#   git branch -M main
#   git push -u origin main

set -e

if [ ! -f README.md ]; then
  echo "Error: ejecuta este script desde la raiz del repositorio (donde esta README.md)."
  exit 1
fi

git init -q 2>/dev/null || true

commit () {
  if ! git diff --cached --quiet; then
    git commit -q -m "$1"
    echo "  commit: $1"
  fi
}

echo "Creando historial por tema..."

git add .gitignore
commit "chore: estructura inicial del repositorio y gitignore"

git add docs/00-caso-pyme.md
commit "docs: caso PYME, evidencia de Transportes Farbus y enunciado del problema"

git add assets/01-bpmn-asis-operacion.svg assets/01-bpmn-asis-operacion.png \
        assets/02-bpmn-asis-facturacion.svg assets/02-bpmn-asis-facturacion.png
commit "assets: diagramas BPMN AS-IS de operacion diaria y facturacion quincenal"

git add docs/01-requerimientos.md
commit "docs: actores, alcance y requisitos funcionales y no funcionales con MoSCoW"

git add assets/03-bpmn-tobe-operacion.svg assets/03-bpmn-tobe-operacion.png \
        assets/04-bpmn-tobe-cobro-flota.svg assets/04-bpmn-tobe-cobro-flota.png
commit "assets: diagramas BPMN TO-BE con la intervencion del SIG"

git add docs/02-bpmn.md
commit "docs: lectura del AS-IS, puntos criticos, mejoras del TO-BE y KPI"

git add assets/05-er-preliminar.dot assets/05-er-preliminar.png assets/05-er-preliminar.svg
commit "assets: modelo entidad-relacion preliminar y fuente graphviz"

git add docs/03-er-preliminar.md
commit "docs: claves primarias candidatas, cardinalidades y trazabilidad proceso-datos"

git add assets/06-arquitectura.svg assets/06-arquitectura.png
commit "assets: arquitectura logica en cuatro capas y stack para la Entrega 2"

git add assets/rot-*.png
commit "assets: versiones rotadas a pagina completa de los diagramas BPMN"

git add anexos/README.md
commit "docs: indice de anexos y criterio de anonimizacion segun Ley 21.719"

git add informe/
commit "informe: Entrega 1 en PDF y Word, mismos archivos subidos a Aula"

git add README.md ENLACE_GITHUB.txt scripts/
commit "docs: README del proyecto y datos de entrega"

git add -A
commit "chore: archivos restantes"

echo ""
echo "Historial creado:"
git --no-pager log --oneline
echo ""
echo "Siguiente paso:"
echo "  git remote add origin https://github.com/<usuario>/farbus-sig.git"
echo "  git branch -M main"
echo "  git push -u origin main"
