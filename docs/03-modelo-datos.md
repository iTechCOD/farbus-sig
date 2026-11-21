# 03 — Modelo ER en 3FN y diccionario de datos

## Diagrama

Véase `assets/03_modelo_er_3fn.svg` (editable/escalable) y `.png`. El esquema implementado está en `db/schema.sql` y contiene **15 tablas**.

## Justificación de 3FN

1. **Primera forma normal (1FN):** cada atributo es atómico: una vuelta por fila, una carga por fila, un documento por tipo y vigencia. No hay columnas repetidas `revision_1`, `revision_2`, etc.
2. **Segunda forma normal (2FN):** las entidades de hecho poseen PK simple; `detalle_preliquidacion` usa una PK compuesta pero su monto pertenece a la fila de detalle completa. `id_vuelta` es además único, evitando doble cobro.
3. **Tercera forma normal (3FN):** información del cliente vive solo en `cliente`, de la planta solo en `planta`, del recorrido en `recorrido`, de la tarifa por contrato/ruta/vigencia en `tarifa`. El nombre del cliente no se repite en `vuelta` ni en `programacion`; se reconstruye mediante claves foráneas.

**Anomalías evitadas:** modificar razón comercial de un cliente no requiere actualizar cientos de vueltas (actualización); se puede crear un vehículo aún no programado (inserción); borrar una vuelta no elimina la tarifa histórica ni los datos del cliente (eliminación). El precio del recorrido no depende del recorrido solamente: depende del contrato y del periodo de vigencia, por eso se modela aparte.

**Redundancia controlada:** `vehiculo.odometro_actual` es un estado operacional para alertas; `carga_combustible.odometro` y `mantencion.odometro` son observaciones históricas. Se acepta conscientemente porque representan conceptos temporales diferentes; en producción debe sincronizarse mediante transacción al registrar una lectura nueva. `detalle_preliquidacion.monto_clp` conserva un importe congelado para auditar el documento, mientras la consulta histórica puede recalcularse con la tarifa vigente.

## Diccionario de tablas

| Tabla | PK | FK principales | Atributos de negocio / reglas |
|---|---|---|---|
| `cliente` | `id_cliente` | — | `nombre` único |
| `planta` | `id_planta` | `id_cliente` | Nombre y localidad; única por cliente/nombre |
| `contrato` | `id_contrato` | `id_cliente` | Código único, fechas, estado |
| `recorrido` | `cod_recorrido` | `id_planta` | Turno, nombre, km estimados positivos |
| `tarifa` | `id_tarifa` | `id_contrato`, `cod_recorrido` | Monto CLP positivo, fechas válidas, no solape por trigger |
| `conductor` | `id_conductor` | — | Código anónimo, clase A2/A3, licencia y activo |
| `vehiculo` | `patente` | — | Tipo, capacidad, odómetro, clase mínima y estado |
| `documento_vehiculo` | `id_documento` | `patente` | Revisión, permiso o SOAP; emisión y vencimiento |
| `estanque` | `id_estanque` | — | Código y capacidad en litros |
| `carga_combustible` | `id_carga` | `patente`, `id_estanque` | Litros, fecha, odómetro, indicador de llenado completo |
| `mantencion` | `id_mantencion` | `patente` | Fecha, odómetro, próximo control km, tipo |
| `programacion` | `id_programacion` | Contrato, recorrido, vehículo, conductor | Fecha, sentido y estado; turno derivado del recorrido; validación trigger |
| `vuelta` | `id_vuelta` | `id_programacion` único | Hora real, pasajeros, vale único, estado |
| `preliquidacion` | `id_preliquidacion` | `id_contrato` | Periodo y fecha de creación |
| `detalle_preliquidacion` | `(id_preliquidacion,id_vuelta)` | Ambas columnas | Monto congelado; `id_vuelta` único |

## Cardinalidades relevantes

Cliente 1:N Planta y Contrato; Planta 1:N Recorrido; Contrato 1:N Tarifa y Programacion; Recorrido 1:N Tarifa y Programacion; Vehiculo 1:N Programacion, Documento, Carga y Mantencion; Conductor 1:N Programacion; Programacion 1:0..1 Vuelta; Contrato 1:N Preliquidacion; Preliquidacion 1:N Detalle; Vuelta 1:0..1 Detalle.

## Controles de integridad y limitaciones

El trigger `trg_programacion_validar` comprueba estado del vehículo, licencia suficiente y vigente, revisión técnica, compatibilidad entre cliente/planta/contrato y tarifa aplicable **al insertar y al editar los campos de asignación**. El trigger de tarifa evita periodos solapados también al actualizar. Los triggers de vueltas controlan capacidad y estados de cancelación. Los detalles de preliquidación deben corresponder al contrato, periodo y tarifa histórica. Continúan pendientes controles de asignaciones simultáneas, actualizaciones retroactivas de vehículos y renovación documental; esta versión **no es un motor completo de despacho**. La demostración implementa A2/A3 en forma simplificada; la habilitación legal definitiva depende del tipo preciso de vehículo, la normativa vigente y la gestión de la empresa.

Los códigos `SIM` y `COND` y el seed completo se documentan como ficticios. Ninguna tabla guarda identidad o domicilio de pasajeros.
