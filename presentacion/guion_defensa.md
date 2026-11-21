# Guion de defensa — ICN292 E2, Farbus (≈6 min 40 s)

> Guion orientativo para practicar; no es para leer de forma literal. **Si la defensa es individual, ratificar antes la excepción docente de E1 para E2.**

| Minuto | Diapositiva | Qué explicar |
|---|---|---|
| 0:00–0:35 | 1 · Portada | «Soy Martín Farfán. Continué el caso de Sociedad de Transportes Farbus Ltda. y pasé del diagnóstico inicial a una solución SIG verificable en datos y procesos». |
| 0:35–1:20 | 2 · Problema | «Farbus tiene 40 vehículos inscritos, 36 operativos y contratos de traslado. El problema que detectamos es que el servicio se registra en papel, se transcribe a planillas que no se comunican y eso ocupa alrededor de 4 horas y retrasa el consolidado hasta 15 días. Es la línea base levantada en E1». |
| 1:20–2:05 | 3 · Entregables | «E2 ya no es solo un diseño: tenemos BPMN final, modelo normalizado, scripts SQL que crean las tablas y sus datos de prueba, cinco consultas y una automatización de alertas. El motor es SQLite para priorizar facilidad de reproducción». |
| 2:05–2:55 | 4 · BPMN | «Logística programa una vuelta; el sistema valida que el vehículo esté operativo, la revisión técnica vigente y el conductor habilitado. Si no cumple, se corrige. El conductor ejecuta y logística registra lo efectivamente realizado; luego el consolidado se calcula directamente desde la base». |
| 2:55–3:40 | 5 · Alertas | «El script equivalente a n8n revisa documentos próximos a vencer y mantenciones por kilometraje. En el ejemplo produce cinco alertas guardadas en JSON, que logística puede revisar. No afirmamos que ya está instalado en la empresa». |
| 3:40–4:35 | 6 · ER | «La clave es separar programación y vuelta: si una se cancela no la cobro. Además, la tarifa es histórica por contrato, recorrido y vigencia. El modelo tiene 15 tablas, normalización a 3FN y FK; así no duplicamos clientes y rutas en cada movimiento». |
| 4:35–5:35 | 7 · SQL | «La consulta de cobro cuenta 7 vueltas para Dole y 4 para Patagoniafresh, con total simulado de $527.500. También calculamos km/L, vencimientos, trazabilidad por vale y cumplimiento de programación. Los números son de un seed ficticio y se reproducen ejecutando el README». |
| 5:35–6:40 | 8 · Cierre | «Se aprobaron catorce pruebas, incluyendo bloqueos de vehículo en mantención y tarifas superpuestas. El límite es claro: todavía no hay interfaz productiva ni migración de datos reales; el siguiente paso es un piloto, medición de tiempos y control de accesos». |

## Preguntas probables del profesor

**¿Por qué SQLite si en E1 prometiste PostgreSQL?** Fue una arquitectura tentativa. Para esta entrega se priorizó un prototipo de datos auditable con Python estándar, sin que el docente deba crear un servidor. El modelo y las consultas pueden migrarse, pero requieren adaptación de funciones y triggers específicas del motor.

**¿Por qué dices que está en 3FN?** Cada hecho tiene una fila; sus atributos dependen de la PK y los datos de cliente, ruta y tarifa no se repiten en la tabla de vueltas. El precio pertenece a una relación contrato-recorrido-vigencia.

**¿Qué está realmente automatizado?** Validaciones SQL al insertar la programación, consolidado por consulta, alerta documental y mantención por script. La digitación desde papel, el criterio de asignación y la decisión de mantención siguen siendo humanos.

**¿Se validaron las cuatro horas y los quince días?** Son líneas base de E1. E2 prueba factibilidad técnica del consolidado, pero no mide resultados reales postimplantación.

**¿Son datos de la empresa?** No. La carga demo es sintética y lo dice en SQL, README, informe y diapositivas. Los antecedentes del caso derivan de E1.

**¿Cómo lo demuestras en un equipo limpio?** `python3 scripts/run_demo.py`, luego `python3 scripts/alertas.py --fecha 2026-11-21` y `python3 -m unittest discover -s tests -v`.
