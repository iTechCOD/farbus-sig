# Farbus SIG — Entrega 2 | ICN292 · P101 · 2026-2

**Caso:** Sociedad de Transportes Farbus Ltda., San Fernando, Región de O'Higgins.  
**Autor:** Martín Farfán Cornejo, rol USM 202260632-0, paralelo 101.  
**Repositorio del proyecto:** https://github.com/iTechCOD/farbus-sig  
**Motor SQL verificado:** SQLite 3 (accesible a través del módulo `sqlite3` de Python 3.10 o superior).  
**Naturaleza:** prototipo técnico académico, no sistema desplegado en la PYME. **Los registros SQL del seed son sintéticos**, no datos operativos auténticos.

## 1. Propósito

Farbus lleva la programación de traslados en planillas desconectadas y hojas físicas; el diagnóstico E1 identificó cerca de 4 horas diarias de digitación y una consolidación quincenal de hasta 15 días. E2 convierte el diseño propuesto en un **modelo relacional 3FN ejecutable**, consultas verificables y una automatización de alertas de flota. Conserva las decisiones de negocio clave de E1: separar la programación de la vuelta realizada, preservar el historial de tarifas y registrar conductores solo mediante códigos anónimos.

## 2. Prueba de oro: ejecutar desde cero

Requisitos: **Python 3.10+**, sin paquetes externos ni internet; o Docker con Compose.

```bash
git clone https://github.com/iTechCOD/farbus-sig.git
cd farbus-sig
python3 scripts/run_demo.py
python3 scripts/alertas.py --fecha 2026-11-21
python3 -m unittest discover -s tests -v
```

En Windows puede usar `python` en lugar de `python3`.

**Alternativa de un comando con Docker:**

```bash
docker compose up --build --abort-on-container-exit
```

La imagen reconstruye la base, ejecuta las consultas y verifica las reglas de negocio. Si se ejecuta sin Docker, el primer comando también recrea la BD desde `db/schema.sql` + `db/seed.sql`, de modo que ningún resultado depende de un archivo previo. El archivo `db/farbus_demo.sqlite` es una copia opcional que puede abrirse con herramientas de SQLite; **no es la fuente autoritativa**.

## 3. Ubicación del material auditable

| Ruta | Contenido |
|---|---|
| `db/schema.sql` | DDL de 15 tablas, PK/FK, CHECK, índices y triggers |
| `db/seed.sql` | Datos de demostración explícitamente sintéticos |
| `consultas/01_...sql` a `05_...sql` | Cinco consultas de negocio independientes |
| `resultados/*.csv` | Salidas reproducidas desde la BD mediante `run_demo.py` |
| `resultados/alertas_demo.json` | Alertas de ejemplo generadas con fecha controlada |
| `scripts/run_demo.py` | Recrea la BD y ejecuta todas las consultas |
| `scripts/alertas.py` | Automatización homóloga a n8n, generadora de alertas |
| `tests/test_integridad.py` | Catorce pruebas automáticas de integridad y negocio |
| `assets/*.bpmn`, `assets/*.png`, `assets/*.svg` | BPMN finales, ER normalizado y visualizaciones |
| `docs/00-caso-pyme.md` | Continuidad y evidencia diagnóstica E1 |
| `docs/01-requerimientos.md` | Trazabilidad y estado real de implementación |
| `docs/02-bpmn.md` | Transición del AS-IS al TO-BE final |
| `docs/03-modelo-datos.md` | Dependencias funcionales, 3FN y diccionario de datos |
| `docs/04-sql-consultas.md` | Consultas y resultados interpretados |
| `docs/05-automatizacion-n8n.md` | Equivalencia BPMN ↔ script, pasos y límites |
| `docs/DECLARACION_IA.md` | Declaración obligatoria del apoyo de IA |
| `CHANGELOG.md` | Cambios de E1 a E2 |
| `informe/` | Informe Word/PDF con el mismo contenido |
| `presentacion/` | PPTX y PDF de 8 diapositivas para la defensa |

## 4. Orden de ejecución y verificaciones

1. `scripts/run_demo.py` crea la BD desde cero, ejecuta `PRAGMA integrity_check` y `PRAGMA foreign_key_check` y luego las cinco consultas `.sql`.
2. `scripts/alertas.py --fecha 2026-11-21` lee la BD y genera alertas sobre vencimiento de documentos (30 días) y mantención por kilometraje (500 km).
3. `python3 -m unittest discover -s tests -v` comprueba catorce casos, incluidos bloqueos por vehículo en mantención, licencia insuficiente, revisión técnica vencida, tarifa solapada, FK inexistente y duplicación de vuelta.

Resultados esperados al ejecutar el seed: **11 vueltas ejecutadas**, **2 contratos**, **$527.500 CLP** como consolidado de demostración (no ingreso real) y **5 alertas**. Estas cifras corresponden *exclusivamente al seed*.

## 5. Reglas de negocio que se demuestran

- Un vehículo en mantención no puede programarse.
- No se programa un conductor con licencia caducada o clase inferior a la del vehículo (modelo simplificado A2/A3).
- Un vehículo debe tener revisión técnica vigente al día del servicio.
- Una programación exige ruta, contrato y tarifa compatible con la fecha.
- No puede haber tarifas superpuestas del mismo contrato/recorrido.
- Una vuelta se asocia a una única programación; no se cobra dos veces en el detalle de preliquidación.
- Los montos históricos se obtienen de la tarifa vigente en la fecha de la vuelta, no de una tarifa actualizada.
- Las consultas no individualizan pasajeros ni guardan nombres/RUT de conductores.

## 6. Qué NO incluye el prototipo

No implementa interfaz web, autenticación de producción, un sistema de facturación electrónico, GPS, telemetría ni integración contable. El proceso de papel y WhatsApp permanece como interfaz de entrada humana; el sistema sí automatiza la validación y el cálculo en base de datos. La reducción de 4 a 1 hora y de 15 a 0 días fueron **metas de E1, no resultados medidos en terreno**. La automatización se ejecuta como script equivalente a n8n; no se afirma una instancia n8n desplegada.

## 7. Trazabilidad de la versión y defensa

El repositorio mantiene el historial documental y las evidencias originales de E1. Los archivos de E2 se identifican por las rutas indicadas en el informe y en `CHANGELOG.md`, con el commit de publicación registrado en `ENLACE_GITHUB.txt` cuando corresponda.

La defensa corresponde al paralelo P101, **viernes 27 de noviembre de 2026, 08:15–10:50**, en formato individual autorizado por el profesor. La presentación de ocho diapositivas y el guion argumental están en `presentacion/`. El tiempo previsto de exposición es de seis minutos y cuarenta segundos, bajo el máximo de siete minutos indicado por la pauta.
