# 02 — BPMN TO-BE final y actualización desde E1

## Diagrama 1: operación y consolidado

- Artefactos: `assets/BPMN_TOBE_operacion.bpmn` (XML editable) y `assets/01_bpmn_tobe_operacion.svg/.png` (versión visual de lectura).
- **Inicio:** el cliente solicita traslado y logística define conductor, vehículo, recorrido y fecha.
- **Validación automática:** un trigger SQL bloquea un vehículo no operativo, revisión técnica vencida, licencia no habilitada o ausencia de tarifa/contrato compatible.
- **Compuerta de decisión:** si falla la regla, logística corrige la asignación y reintenta; si cumple, se comunica la hoja de ruta (WhatsApp continúa como canal externo).
- **Ejecución humana:** el conductor realiza el servicio y completa papel; logística registra en `vuelta` la ejecución real.
- **Resultado:** los servicios ejecutados quedan disponibles para el consolidado SQL y preliquidación, sin tarea de sumar a mano al cierre quincenal.

## Diagrama 2: alertas de flota

- Artefactos: `assets/BPMN_TOBE_alertas.bpmn` y `assets/02_bpmn_tobe_alertas.svg/.png`.
- Cada ejecución de `scripts/alertas.py` lee el documento más reciente por vehículo y el último mantenimiento de cada unidad, compara las fechas y odómetros con umbrales y genera un JSON con alertas.
- La compuerta decide si existen alertas. Logística revisa y coordina la mantención o renovación documental. No se envían correos ni WhatsApp sin autorización: la tarea automatizada termina en el **reporte auditable**.

## Diferencias respecto de E1

1. La validación de habilitación deja de ser una intención conceptual: ahora se aplica mediante `trg_programacion_validar`, comprobado por tests.
2. El consolidado por contrato se materializa como consulta con fechas y tarifas históricas, no como sumar filas impresas.
3. El aviso de revisión y mantención se materializa como script invocable por planificador (`cron`/Programador de tareas), equivalente documentado a un flujo n8n.
4. El sistema de E2 es una **demostración de capa de datos**. A diferencia de la interfaz planteada en E1, no se implementó autenticación, generación PDF de hoja de ruta ni aplicación web.

## Semántica y límites

Los archivos `.bpmn` modelan eventos, tareas, compuertas y flujos de secuencia; las vistas SVG/PNG son simplificaciones gráficas para la presentación. Los nombres de tareas de SQL no suponen automatización del registro en terreno: se conserva el paso humano de transcripción hasta diseñar interfaz. La versión ejecutable automatiza solo las operaciones explícitamente relacionadas con las consultas y triggers del repositorio.
