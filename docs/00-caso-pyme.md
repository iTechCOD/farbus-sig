# 00 — Caso PYME: continuidad desde E1

## Empresa y fuente

**Sociedad de Transportes Farbus Ltda.**, San Fernando, Región de O'Higgins. El diagnóstico E1 registró 40 vehículos inscritos (36 operativos), 25 colaboradores (20 conductores), dos clientes de contrato fijo (Dole y Patagoniafresh) y un catálogo existente de recorridos. Estos antecedentes proceden del informe E1 y de su entrevista documentada de 11-09-2026, no del seed de E2.

## Problema original

La información se anota en papel, se transcribe a cuatro planillas Excel separadas y se mueve entre computadores por pendrive. Según la entrevista E1, la transcripción consume alrededor de una mañana para un día completo (≈4 horas) y el consolidado que sustenta el cobro se produce cada quince días. Los datos de cargas de combustible, kilometraje y vencimientos no se integran sistemáticamente.

**Dimensiones E1:** P1 digitación manual; P2 consolidación tardía; P3 combustible y pasajeros sin explotación analítica; P4 falta de control documental/mantenciones formal; P5 ausencia de base única.

## Solución delimitada para E2

Se entrega una **prueba de concepto auditable de la capa de datos**, no un despliegue productivo: tablas SQL 3FN con restricciones, carga sintética, cinco consultas de negocio y un script automatizado de alertas de documentos y mantenimiento. Se apoya en el BPMN TO-BE planteado en E1 y deja documentadas las funciones que todavía requieren interfaz y validación de campo.

## Evidencia y separación de fuentes

Los anexos primarios firmados, las capturas anonimizadas y el informe E1 están en el repositorio original bajo `anexos/` e `informe/`. No se copian aquí capturas o documentos de terceros. El seed E2 inventa **solo registros DEMO** (patentes `SIM`, conductores `COND`, contratos `SIM`, fechas y montos ficticios). Los nombres de clientes son antecedentes declarados en E1; el monto total simulado **no es facturación de Farbus**.

## Autor y situación del equipo

Martín Farfán Cornejo, rol USM 202260632-0, paralelo 101. La Entrega 1 se presentó individualmente. El profesor confirmó la excepción de modalidad individual también para la Entrega 2, de modo que el mismo estudiante desarrolla y defiende el proyecto.
