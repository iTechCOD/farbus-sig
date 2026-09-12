# 01 — Requerimientos

Prioridad MoSCoW: **M** indispensable para la Entrega 2 · **S** importante pero postergable ·
**C** deseable si el tiempo lo permite · **W** explícitamente excluido de esta iteración.
La columna «Traza» apunta a las dimensiones del problema definidas en `00-caso-pyme.md`.

## Actores

| Actor | Rol en el proceso | Relación con el SIG |
|---|---|---|
| Administrador de logística (2) | Programa, asigna conductor y vehículo, y transcribe la ejecución | Usuario principal |
| Encargado de combustible | Registra las cargas desde los estanques propios | Usuario de registro acotado |
| Conductor (20) | Ejecuta las vueltas y registra en papel | No opera el sistema |
| Contadora | Prepara el resumen de montos | Consulta y exportación |
| Asistente contable | Apoya el respaldo documental | Consulta |
| Administradora | Supervisa la gestión administrativa | Consulta y tablero |
| Representante legal | Decide tarifas, renovación de flota y contratos | Tablero de indicadores |

Actores externos: empresas cliente (Dole, Patagoniafresh), mecánico externo, las planillas
Excel vigentes como sistema heredado, WhatsApp como canal de notificación y el sistema
contable, este último fuera del alcance.

El conductor queda fuera como usuario del sistema por decisión de la contraparte, y tomando
en cuenta el antecedente del registro de pasajeros con códigos QR que se implementó en la
pandemia y se abandonó al terminar la contingencia.

## Alcance

**Dentro:** catálogo de recorridos; programación diaria; registro de ejecución de vueltas;
ficha de flota; control documental (revisión técnica, permiso de circulación, seguro);
mantenciones y aviso por kilometraje; cargas de combustible; rendimiento km/L con detección
de desviaciones; contratos y tarifas con vigencias; consolidado por contrato en línea;
preliquidación y trazabilidad para reclamos; carga inicial desde los Excel vigentes.

**Fuera:** app móvil para conductores; GPS o telemetría; documentos tributarios electrónicos
e integración con el SII; cálculo de remuneraciones; registro de identidad de pasajeros;
compras e inventario; portal para clientes; despliegue en la nube.

## Requisitos funcionales

| ID | Requisito | Prio. | Traza |
|---|---|---|---|
| RF-01 | Mantener el catálogo de recorridos codificados, con nombre, turno, planta de destino y kilometraje estimado | M | P5 |
| RF-02 | Registrar la programación diaria asociando fecha, recorrido, vehículo y conductor | M | P1, P5 |
| RF-03 | Validar automáticamente, al asignar, que el vehículo esté operativo y con revisión técnica vigente y que el conductor tenga la licencia requerida | M | P4 |
| RF-04 | Registrar la ejecución de cada vuelta: sentido, hora real de salida y llegada, pasajeros, número de vale y estado | M | P1, P3 |
| RF-05 | Mantener la ficha de cada vehículo: patente, tipo, marca y modelo, año, capacidad, odómetro y estado | M | P5 |
| RF-06 | Registrar las cargas de combustible con patente, estanque, litros, odómetro y responsable | M | P3 |
| RF-07 | Calcular el rendimiento km/L por vehículo y periodo, y alertar cuando se desvíe del rango histórico | M | P3 |
| RF-08 | Registrar y controlar vencimientos de revisión técnica, permiso de circulación y seguro, con alerta anticipada | M | P4 |
| RF-09 | Mantener contratos y tarifas por recorrido, con vigencias que permitan reajustes sin perder el historial | M | P2, P5 |
| RF-10 | Generar el consolidado de vueltas ejecutadas por contrato y periodo, en línea | M | P2 |
| RF-11 | Consultar la trazabilidad completa de una vuelta para resolver reclamos de facturación | M | P2 |
| RF-12 | Autenticar usuarios y restringir funciones según perfil | M | P5 |
| RF-13 | Generar la hoja de ruta imprimible precargada para el conductor | S | P1 |
| RF-14 | Registrar mantenciones y generar aviso al alcanzar el umbral de kilometraje | S | P4 |
| RF-15 | Generar la preliquidación aplicando la tarifa vigente a cada vuelta ejecutada | S | P2 |
| RF-16 | Importar las planillas Excel vigentes para la carga inicial | S | P5 |
| RF-17 | Presentar un tablero con indicadores de operación, flota y cobro | S | P3 |
| RF-18 | Registrar incidencias en ruta: falla, reemplazo de unidad o de conductor | C | P1 |
| RF-19 | Exportar reportes y consolidados a Excel y PDF | C | P5 |
| RF-20 | Registrar la identidad de los pasajeros trasladados | W | — |
| RF-21 | Capturar la ejecución de vueltas mediante aplicación móvil del conductor | W | — |

RF-20 se excluye por minimización de datos personales y porque el proceso solo necesita el
conteo. RF-21 se excluye por decisión de la contraparte.

## Requisitos no funcionales

| ID | Requisito | Criterio de aceptación | Prio. |
|---|---|---|---|
| RNF-01 | Reproducibilidad | Se levanta en localhost con `docker compose up`, sin configuración previa | M |
| RNF-02 | Eficiencia del registro | Un día completo de toda la flota se registra en 60 min o menos, frente a las ≈4 h actuales | M |
| RNF-03 | Integridad referencial | No se puede registrar una vuelta sin programación válida ni una carga sin vehículo existente | M |
| RNF-04 | Protección de datos | No se almacena nombre, RUT ni domicilio de conductores ni de pasajeros. Credenciales con hash | M |
| RNF-05 | Auditabilidad | Toda creación o modificación queda asociada al usuario y a la marca de tiempo | S |
| RNF-06 | Rendimiento de consulta | El consolidado de un periodo se resuelve en menos de 3 s sobre ≈86.000 vueltas | S |
| RNF-07 | Respaldo | Respaldo diario automatizado con restauración documentada y verificada | S |
| RNF-08 | Sin dependencia de conectividad | Opera en la red local de la oficina, sin internet | S |
| RNF-09 | Mantenibilidad | Código en GitHub, migraciones versionadas y pruebas automatizadas | S |
| RNF-10 | Escalabilidad | Soporta 60 vehículos y 40 conductores sin rediseñar el esquema | C |

## Trazabilidad problema–requisito

| Dimensión | Requisitos |
|---|---|
| P1 | RF-02, RF-04, RF-13, RF-18, RNF-02 |
| P2 | RF-09, RF-10, RF-11, RF-15, RNF-06 |
| P3 | RF-04, RF-06, RF-07, RF-17 |
| P4 | RF-03, RF-08, RF-14 |
| P5 | RF-01, RF-05, RF-09, RF-12, RF-16, RF-19, RNF-01, RNF-03, RNF-04, RNF-05, RNF-07, RNF-08 |
