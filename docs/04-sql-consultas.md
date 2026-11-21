# 04 — SQL: scripts, consultas y resultados interpretados

## Reproducibilidad

`db/schema.sql` crea el diseño, sus índices, restricciones y triggers. `db/seed.sql` incorpora **datos exclusivamente sintéticos**. `python3 scripts/run_demo.py` crea desde cero `db/farbus_demo.sqlite`, ejecuta los cinco SQL bajo `consultas/` y sobrescribe `resultados/*.csv`. Las tablas y consultas pertenecen al motor SQLite 3 indicado en el README, no se afirma equivalencia automática con PostgreSQL sin portar `PRAGMA`, fechas y triggers.

## Q1. Cobro por cliente y contrato

**Archivo:** `consultas/01_consolidado_cobro.sql`. Agrupa solo vueltas `EJECUTADA`, une fecha de servicio con intervalo de tarifa y suma valores.

**Resultado del seed:** Dole: 7 vueltas, 196 pasajeros, **$327.000 CLP**; Patagoniafresh: 4 vueltas, 36 pasajeros, **$200.500 CLP**. Total simulado: **11 vueltas y $527.500 CLP**. **Interpretación:** el consolidado es consultable inmediatamente después de ingresar las vueltas sin rehacer sumas en Excel. Estos montos no son ingresos reales de Farbus.

## Q2. Rendimiento de combustible

**Archivo:** `consultas/02_rendimiento_combustible.sql`. Usa la función de ventana `LAG` para comparar lecturas de odómetro en **cargas completas consecutivas**.

**Resultado del seed:** SIM001: **2,96 km/L**; SIM002: **6,82 km/L**; SIM003: **5,88 km/L**. **Interpretación:** SIM001 podría requerir revisión operativa si su propia línea base histórica fuera mayor. No se puede catalogar automáticamente como anómalo sin umbral histórico por tipo y validación de la condición de llenado; por eso no se implementa todavía una alerta formal de bajo rendimiento.

## Q3. Documentos por vencer

**Archivo:** `consultas/03_alertas_documentos.sql`. Toma el registro de emisión más reciente por patente y tipo y busca vencimientos en los próximos treinta días desde **2026-11-21**.

**Resultado del seed:** SIM003 el 30-11 (9 días), SIM001 el 09-12 (18 días), SIM004 el 10-12 (19 días). **Interpretación:** logística puede priorizar renovaciones antes del vencimiento. La fecha se fija para que el ayudante reproduzca el mismo resultado, no para indicar el estado documental actual de una unidad real.

## Q4. Trazabilidad del vale

**Archivo:** `consultas/04_trazabilidad_vale.sql`. Reconstruye `SIM-VA-005`: 18-11-2026, cliente Dole, ruta R01-N, vehículo SIM001, conductor anónimo COND-01, salida 21:30, llegada 22:15, 37 pasajeros y tarifa simulada $51.000. **Interpretación:** una diferencia de cobro puede investigarse sin abrir cuatro planillas.

## Q5. Cumplimiento de programación

**Archivo:** `consultas/05_cumplimiento_programacion.sql`. Separa la jornada ejecutada, cancelada y pendiente: 20-11 tiene 4 programadas, **3 ejecutadas y 1 cancelada**; 21-11 tiene 1 pendiente. **Interpretación:** el modelo de E2 distingue lo comprometido de lo realmente efectuado; los pendientes no deben confundirse con servicios cobrables.

## Resultados y control

El directorio `resultados/` contiene los CSV y un JSON generados por `run_demo.py`; el propio script comprueba `integrity_check='ok'` y cero violaciones FK. Hay catorce pruebas para reglas críticas. La prueba local no acredita rendimiento con 86.000 vueltas ni efectividad en la operación real.
