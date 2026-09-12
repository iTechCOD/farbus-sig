# 00 — La PYME y el problema

## Identificación

| Atributo | Detalle |
|---|---|
| Razón social | Sociedad de Transportes Farbus Ltda. |
| RUT | 76.366.560-7 |
| Giro SII | Alquiler de vehículos motorizados |
| Inicio de actividades | 7 de octubre de 2005 |
| Domicilio | Negrete 549, San Fernando, Región de O'Higgins |
| Representante legal | Juan Pablo Farfán Alarcón |
| Correo institucional | administracion@farbus.cl |
| Dotación | 25 colaboradores (20 conductores) |
| Flota | 40 vehículos inscritos, 36 operativos |
| Clientes con contrato fijo | 2 (Dole y Patagoniafresh) |

Farbus presta transporte de personal a empresas agroindustriales de la zona central. La
unidad de servicio es la **vuelta**: un traslado en un sentido, que consiste en recoger
trabajadores en sus domicilios o paraderos y llevarlos a la planta (entrada), o retirarlos
de la planta y devolverlos (salida). Se factura por vuelta ejecutada, con un valor por ruta,
y se cobra cada quince días.

La empresa opera un catálogo de al menos 48 recorridos codificados que cubren localidades de
Colchagua, Cachapoal y Curicó —San Fernando, Chimbarongo, Pelequén, Rengo, Requínoa,
Rancagua, San Vicente, Nancagua, Santa Cruz, Malloa, Molina, Curicó y Teno, entre otras—
cada uno en variante diurna y nocturna.

## Cómo se acredita que la empresa existe

La PYME se acredita por las dos vías que admite la pauta al mismo tiempo.

**Entrevista documentada.** Realizada el 11 de septiembre de 2026 con Juan Pablo Farfán
Alarcón, representante legal, con 21 años en la empresa. Cuestionario de 59 preguntas en
siete bloques. El acta fue respondida, firmada y timbrada, y el entrevistado autorizó por
escrito el uso del nombre de la empresa y del material con fines académicos.

**Presencia pública verificable.** Perfil institucional en Facebook e Instagram
(@transportes_farbus), dominio propio farbus.cl con el correo institucional publicado, y
registro público de ubicación en Negrete 549, San Fernando.

| # | Evidencia | Tipo |
|---|---|---|
| A1 | Acta de entrevista firmada y timbrada | Documento primario |
| A2 | Captura de la planilla Excel de tráfico diario, anonimizada | Captura de sistema |
| A3 | Captura de la planilla Excel de patentes para permiso de circulación | Captura de sistema |
| A4 | Listado impreso de flota con columnas de vencimiento de revisión técnica | Documento primario |
| A5 | Formulario en papel «Ingreso de Vueltas Conductores», con 48 recorridos | Documento primario |
| A6 | Formulario en papel de control de carga de combustible y estanques | Documento primario |
| A7–A10 | Facebook, Instagram, farbus.cl y registro público de ubicación | Presencia pública |
| A11 | Autorización docente para desarrollo individual | Documento administrativo |

## El problema

Farbus ya captura casi todos los datos que necesitaría para gestionar su operación. El
problema no es que falten datos, sino que nacen en papel, se pasan a mano a planillas que no
se comunican entre sí y se mueven físicamente entre computadores en un pendrive.

> La operación se registra en papel y se transcribe a mano hacia cuatro planillas Excel
> desconectadas que se trasladan por pendrive, lo que consume unas 4 horas diarias de los dos
> administradores de logística (≈80 h al mes), retrasa hasta 15 días el consolidado que
> sustenta la facturación, e impide usar para gestión datos que la empresa ya captura
> —pasajeros por vuelta y kilometraje por carga—, además de no sostener ningún registro
> formal de mantenciones ni de vencimientos de revisión técnica.

### Dimensiones

| Código | Dimensión |
|---|---|
| P1 | Transcripción manual desde papel hacia planillas, con alto consumo de horas administrativas |
| P2 | Latencia de hasta quince días entre la ejecución del servicio y el consolidado que sustenta el cobro |
| P3 | Datos ya capturados —pasajeros y odómetro— que no se explotan para gestión |
| P4 | Ausencia de registro formal de mantenciones y de vencimientos documentales de la flota |
| P5 | Dispersión en cuatro planillas sin integración, trasladadas por pendrive |

### Impacto

- **Tiempo.** Digitar un día completo de operación toma cerca de una mañana de trabajo.
- **Costo.** El combustible es aproximadamente un tercio del costo total, y los datos que
  permitirían controlarlo se capturan pero no se cruzan con las vueltas ejecutadas.
- **Error.** En el listado de flota los encabezados están corridos respecto del contenido, y
  las cinco columnas de vencimiento de revisión técnica están vacías aunque la empresa
  declara controlar esos vencimientos.
- **Servicio.** Una diferencia de cobro se detecta hasta dos semanas después de ocurrida.

### Una hipótesis que quedó refutada

Antes de la entrevista se pensaba que la empresa no podía determinar el costo por recorrido.
El representante legal respondió que ese costo sí lo estiman, a partir del kilometraje y el
rendimiento de cada vehículo. La hipótesis se descartó y el problema se reformuló a partir de
la evidencia, y no al revés.

### Un hallazgo de calidad de datos

La composición de la flota no coincide entre las fuentes: la entrevista detalla 24 unidades
por tipo, el listado impreso tiene 30 filas y la planilla de permisos de circulación indica
40 registros. Más que un error, es una señal del problema: los datos de un mismo vehículo
están en registros paralelos que nadie cruza. Se toma como cifra oficial la del representante
legal: 40 inscritos y 36 operativos.
