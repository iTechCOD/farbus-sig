# 01 — Requerimientos y trazabilidad E1 → E2

## Alcance del prototipo entregado

Se priorizaron los requisitos asociados a operación, flota y cobro que **pueden demostrarse con una base de datos y consultas**, como exige la pauta de E2. No se presentan como implementadas funciones sin interfaz o pruebas de usuario. El motor cambió de PostgreSQL 16 propuesto en E1 (tentativo) a SQLite 3 para facilitar la auditoría offline y ejecutar el código en cualquier computador con Python. Se documenta como decisión de alcance, no como migración ya desplegada.

| Requisito E1 | Estado E2 | Evidencia verificable |
|---|---|---|
| RF-01: catálogo recorridos | Modelado y poblado DEMO (4 de 48) | `recorrido`, seed |
| RF-02: programación diaria | Modelo y registros DEMO | `programacion`, consulta 05 |
| RF-03: vehículo/RT/licencia | **Validación ejecutable** de inserción | `trg_programacion_validar`, tests |
| RF-04: ejecución de vueltas | **Modelo y registros ejecutables** | `vuelta`, consulta 04 |
| RF-05: ficha de vehículo | Modelo y registros DEMO | `vehiculo`, seed |
| RF-06: carga combustible | Modelo y registros DEMO | `carga_combustible`, consulta 02 |
| RF-07: rendimiento km/L | Consulta ejecutable; alerta de anomalía pendiente | consulta 02 |
| RF-08: vencimiento documental | **Consulta y alerta ejecutable** | consulta 03, `alertas.py` |
| RF-09: contratos y tarifas históricas | **Modelo/triggers ejecutables** | `contrato`, `tarifa`, consulta 01 |
| RF-10: consolidado por periodo | **Consulta ejecutable** (sin latencia técnica tras ingresar) | consulta 01 |
| RF-11: trazabilidad de vuelta | **Consulta ejecutable** | consulta 04 |
| RF-12: autenticación por perfil | **Pendiente**: requiere capa de aplicación | No se afirma implementación |
| RF-13: hoja de ruta | Pendiente, requiere interfaz | Fuera de demo SQL |
| RF-14: mantenciones y aviso km | **Modelo y script** | `mantencion`, `alertas.py` |
| RF-15: preliquidación | Modelo, detalle y consulta con tarifa histórica | `preliquidacion`, `detalle_preliquidacion`, consulta 01 |
| RF-16: importación Excel real | Pendiente; se usa seed sintético | `db/seed.sql` |
| RF-17: tablero | Pendiente; datos disponibles vía SQL | consultas 01–05 |
| RF-18/19 | No abordados | Priorización E1: Could |
| RF-20/21 | Excluidos intencionalmente | Identificación de pasajeros / app móvil |

## No funcionales y criterios honestos

RNF-01: reproducible localmente con `python3 scripts/run_demo.py` o Docker Compose. **Cumplido en la prueba técnica**. RNF-03: FK y triggers probados; **cumplido sobre tablas entregadas**. RNF-04: sin datos identificativos y uso de seed sintético; **cumplido en la demostración** (las credenciales aún no existen porque RF-12 está pendiente). RNF-09: código y catorce pruebas versionables; **cumplido para este prototipo**. RNF-02 (≤60 min de registro), RNF-06 (86.000 vueltas en 3 s), RNF-07 (backup diario) y RNF-08 (oficina sin internet) **no están validados en operación real**. El tiempo de consolidación "0 días" es capacidad de consulta una vez registrada la vuelta, no evidencia de reducción efectiva del plazo administrativo.

## Correspondencia con los cinco problemas

- P1: separación programación/ejecución y un solo registro relacional; la interfaz futura debe reemplazar la digitación física.
- P2: consulta 01 y tarifas temporales, sin conciliación manual para el seed.
- P3: consulta 02 de km/L y pasajeros en consulta 01.
- P4: validador de revisión técnica y script de alerta documental/mantención.
- P5: esquema 3FN con 15 tablas, FK e integridad formal.
