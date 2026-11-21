# 05 — Automatización homóloga a n8n: alertas de flota

## Justificación

La pauta permite un flujo **n8n u homólogo** exportado o documentado paso a paso. Se implementó una **automatización Python ejecutable** (`scripts/alertas.py`) sobre la misma base SQL y con trazabilidad explícita al BPMN TO-BE de alertas. No se declara haber instalado o ejecutado n8n.

## Correspondencia de tareas BPMN ↔ código

| Tarea de BPMN | Código/consulta | Entrada → salida |
|---|---|---|
| Evento de tiempo: control diario | Ejecución programable de `alertas.py` | Fecha de control y horizonte |
| Leer documentos y mantenimientos | `SELECT` a `documento_vehiculo`, `mantencion`, `vehiculo` | Lecturas más recientes |
| Evaluar umbrales | Diferencia de fechas; `proximo_control_km - odometro_actual` | Tipo y prioridad de alerta |
| Compuerta: ¿hay alertas? | `cantidad_alertas > 0` | Con alertas / sin alertas |
| Emitir reporte | Escritura `resultados/alertas_demo.json` | Evidencia persistida |
| Revisión humana | Lectura del JSON por logística | Coordinación, fuera del script |

## Reproducción exacta

```bash
python3 scripts/run_demo.py
python3 scripts/alertas.py --fecha 2026-11-21 --dias 30
```

Salida del ejemplo: **cinco alertas**: tres revisiones técnicas por vencer (SIM003, SIM001, SIM004), una mantención cercana (SIM002) y una mantención con umbral excedido (SIM003). La primera fecha es un parámetro controlado de la prueba; en una ejecución diaria sin `--fecha` se utiliza el día actual del computador.

## Programación automática opcional

En Linux/macOS, `crontab -e` puede incluir lo siguiente, tras sustituir `/RUTA/farbus-sig` por la ubicación real:

```cron
0 8 * * * cd /RUTA/farbus-sig && /usr/bin/python3 scripts/alertas.py --salida resultados/alertas_diarias.json
```

Este `cron` es una **instrucción de despliegue**, no una evidencia de que esté programado en Farbus. En Windows, Programador de tareas puede invocar el mismo comando una vez por día. Equivalencia n8n conceptual: Schedule Trigger → Execute Command → Read JSON → decisión → comunicación a responsable; se eligió el script homólogo por ser ejecutable offline sin credenciales externas.

## Control de excepciones y límites

La automatización genera el JSON y no envía mensajes, no programa órdenes de taller y no modifica las fechas de la BD. Las mantenciones se evalúan respecto de la **última** mantención por patente y de una tolerancia de 500 km. Los documentos ya vencidos también se incluyen con prioridad `VENCIDO`, aunque Q3 solo lista los próximos 30 días. La validación administrativa de fechas y odómetros continúa siendo responsabilidad humana. El diseño puede evolucionar a n8n cuando exista ambiente y destinatarios aprobados.
