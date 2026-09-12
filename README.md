# SIG para Sociedad de Transportes Farbus Ltda.

**ICN292 — Gestión y Rediseño de Procesos · Entrega 1 · Paralelo 101**
Universidad Técnica Federico Santa María — Campus Santiago Vitacura

Diagnóstico de los sistemas de información de una PYME real y propuesta de un Sistema de
Información de Gestión (SIG) que será construido en la Entrega 2.

---

## 1. Qué PYME es y qué problema tiene

**Sociedad de Transportes Farbus Ltda.** (RUT 76.366.560-7) es una empresa de San Fernando,
Región de O'Higgins, que presta transporte de personal a empresas agroindustriales bajo
contrato fijo. Opera 40 vehículos inscritos (36 operativos), 25 colaboradores —20 de ellos
conductores— y un catálogo de 48 recorridos codificados en turno día y noche.

**El problema, en una frase:**

> La operación se registra en papel y se transcribe a mano hacia cuatro planillas Excel
> desconectadas que se trasladan por pendrive. Esto consume unas 4 horas diarias de los dos
> administradores de logística (≈80 h al mes), retrasa hasta 15 días el consolidado que
> sustenta la facturación, e impide usar para gestión datos que la empresa ya captura
> —pasajeros por vuelta y kilometraje por carga de combustible—, además de no sostener
> ningún registro formal de mantenciones ni de vencimientos de revisión técnica.

El problema no se le propuso a la empresa para que lo confirmara: sale de lo que respondió
por su cuenta el representante legal al preguntarle qué arreglaría si pudiera cambiar una
sola cosa. Ver `docs/00-caso-pyme.md`.

**Objetivo del SIG:** centralizar en una base de datos única el registro de la operación
diaria —programación, vueltas ejecutadas, combustible, kilometraje y estado de flota—
eliminando la transcripción entre planillas y habilitando el control de indicadores con
datos que ya existen.

---

## 2. Qué hay en cada carpeta

| Carpeta | Contenido |
|---|---|
| `docs/` | Documentación del proyecto en Markdown, dividida por tema |
| `docs/00-caso-pyme.md` | La PYME, la evidencia que acredita su existencia y el problema de negocio |
| `docs/01-requerimientos.md` | Actores, alcance in/out, 21 requisitos funcionales y 10 no funcionales con MoSCoW |
| `docs/02-bpmn.md` | Procesos AS-IS y TO-BE, puntos críticos, mejoras y KPI |
| `docs/03-er-preliminar.md` | Modelo entidad-relación, claves primarias candidatas y cardinalidades |
| `assets/` | Los seis diagramas exportados en PNG y SVG, más el fuente `.dot` del ER |
| `informe/` | El informe completo en PDF y en Word — los mismos archivos subidos a Aula |
| `anexos/` | Evidencia levantada en terreno: acta firmada y capturas anonimizadas (A1 a A6) |
| `scripts/` | Utilitarios del repositorio |

---

## 3. Diagramas

| Figura | Archivo | Contenido |
|---|---|---|
| 1 | `assets/01-bpmn-asis-operacion.png` | BPMN AS-IS — programación y ejecución de vueltas |
| 2 | `assets/02-bpmn-asis-facturacion.png` | BPMN AS-IS — consolidación quincenal y facturación |
| 3 | `assets/03-bpmn-tobe-operacion.png` | BPMN TO-BE — operación con el SIG |
| 4 | `assets/04-bpmn-tobe-cobro-flota.png` | BPMN TO-BE — cobro en línea y control de flota |
| 5 | `assets/05-er-preliminar.png` | Modelo entidad-relación preliminar |
| 6 | `assets/06-arquitectura.png` | Arquitectura lógica en cuatro capas y stack |

Los diagramas son anchos. Para leerlos en detalle conviene abrir el `.svg`, que escala sin
perder calidad, o el Anexo B del informe, donde están rotados a página completa.

---

## 4. Cómo se conecta con la Entrega 2 (localhost)

La Entrega 2 implementa el TO-BE de las Figuras 3 y 4 sobre el modelo de datos de la
Figura 5, desplegado localmente y reproducible con un solo comando:

```bash
git clone <repositorio>
cd farbus-sig
cp .env.example .env
docker compose up --build
# aplicación disponible en http://localhost:8000
```

**Stack tentativo:** Python 3.12 · FastAPI · SQLAlchemy 2 + Alembic · PostgreSQL 16 ·
Jinja2 + HTMX + Bootstrap 5 · Pandas para la carga inicial · Docker Compose · Pytest.

Solo los 12 requisitos de prioridad **Must** se comprometen para la Entrega 2. El detalle
de hitos, responsables y riesgos está en la sección G del informe.

---

## 5. Integrante y rol

| Integrante | RUT | Rol USM | Paralelo | Rol en el proyecto |
|---|---|---|---|---|
| Martín Farfán Cornejo | 21.076.161-6 | 202260632-0 | 101 | Responsable integral: levantamiento, modelamiento BPMN, modelo de datos, arquitectura y documentación |

**Nota:** la pauta pide equipos de 4 o 5 integrantes. Este proyecto se desarrolla de forma
individual con autorización previa del profesor, otorgada antes del cierre de la Entrega 1.
La constancia está en `anexos/` como Anexo A11.

---

## 6. Informe y entrega en Aula

El informe está en `informe/`, en PDF y en Word, y son exactamente los mismos archivos
subidos a Aula:

- `informe/ICN292_P101_E1_Farfan_Cornejo.pdf`
- `informe/ICN292_P101_E1_Farfan_Cornejo.docx`

En Aula se sube además `ENLACE_GITHUB.txt` con la URL de este repositorio.

---

## 7. Sobre los datos personales

Este repositorio es público y las evidencias vienen de planillas operativas reales, así que
**toda la evidencia fue anonimizada antes de publicarse**, anticipándose a la Ley 21.719.

No se publica ni se almacena: nombres, RUT o domicilios de conductores y trabajadores;
sueldos ni datos previsionales; nombres de pasajeros ni listas de personal de las empresas
cliente. El modelo de datos excluye por diseño la identificación de personas: de un conductor
solo guarda identificador, clase de licencia y vencimiento, y de una vuelta solo la cantidad
de pasajeros trasladados. Ver sección G.3 del informe.
