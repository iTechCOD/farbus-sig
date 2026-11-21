-- Farbus SIG | Entrega 2 | Motor: SQLite >= 3.37
-- Esquema normalizado (3FN), con restricciones de integridad y controles de negocio.
PRAGMA foreign_keys = ON;
BEGIN TRANSACTION;
CREATE TABLE cliente (
 id_cliente INTEGER PRIMARY KEY,
 nombre TEXT NOT NULL UNIQUE
);
CREATE TABLE planta (
 id_planta INTEGER PRIMARY KEY,
 id_cliente INTEGER NOT NULL REFERENCES cliente(id_cliente),
 nombre TEXT NOT NULL,
 localidad TEXT NOT NULL,
 UNIQUE(id_cliente,nombre)
);
CREATE TABLE contrato (
 id_contrato INTEGER PRIMARY KEY,
 id_cliente INTEGER NOT NULL REFERENCES cliente(id_cliente),
 codigo TEXT NOT NULL UNIQUE,
 fecha_inicio TEXT NOT NULL,
 fecha_fin TEXT,
 estado TEXT NOT NULL CHECK(estado IN ('VIGENTE','CERRADO')),
 CHECK(fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);
CREATE TABLE recorrido (
 cod_recorrido TEXT PRIMARY KEY,
 id_planta INTEGER NOT NULL REFERENCES planta(id_planta),
 nombre TEXT NOT NULL,
 turno TEXT NOT NULL CHECK(turno IN ('DIURNO','NOCTURNO')),
 km_estimados REAL NOT NULL CHECK(km_estimados > 0)
);
CREATE TABLE tarifa (
 id_tarifa INTEGER PRIMARY KEY,
 id_contrato INTEGER NOT NULL REFERENCES contrato(id_contrato),
 cod_recorrido TEXT NOT NULL REFERENCES recorrido(cod_recorrido),
 monto_clp INTEGER NOT NULL CHECK(monto_clp > 0),
 vigente_desde TEXT NOT NULL,
 vigente_hasta TEXT,
 CHECK(vigente_hasta IS NULL OR vigente_hasta >= vigente_desde),
 UNIQUE(id_contrato,cod_recorrido,vigente_desde)
);
CREATE TABLE conductor (
 id_conductor INTEGER PRIMARY KEY,
 codigo TEXT NOT NULL UNIQUE,
 clase_licencia TEXT NOT NULL CHECK(clase_licencia IN ('A2','A3')),
 licencia_vence TEXT NOT NULL,
 activo INTEGER NOT NULL DEFAULT 1 CHECK(activo IN (0,1))
);
CREATE TABLE vehiculo (
 patente TEXT PRIMARY KEY,
 tipo TEXT NOT NULL CHECK(tipo IN ('MINIBUS','TAXIBUS','BUS')),
 marca TEXT NOT NULL,
 modelo TEXT NOT NULL,
 anio INTEGER NOT NULL CHECK(anio BETWEEN 1990 AND 2100),
 capacidad INTEGER NOT NULL CHECK(capacidad > 0),
 licencia_minima TEXT NOT NULL CHECK(licencia_minima IN ('A2','A3')),
 odometro_actual INTEGER NOT NULL CHECK(odometro_actual >= 0),
 estado TEXT NOT NULL CHECK(estado IN ('OPERATIVO','MANTENCION','INACTIVO'))
);
CREATE TABLE documento_vehiculo (
 id_documento INTEGER PRIMARY KEY,
 patente TEXT NOT NULL REFERENCES vehiculo(patente),
 tipo TEXT NOT NULL CHECK(tipo IN ('REVISION_TECNICA','PERMISO_CIRCULACION','SOAP')),
 fecha_emision TEXT NOT NULL,
 fecha_vencimiento TEXT NOT NULL,
 CHECK(fecha_vencimiento >= fecha_emision),
 UNIQUE(patente,tipo,fecha_emision)
);
CREATE TABLE estanque (
 id_estanque INTEGER PRIMARY KEY,
 codigo TEXT NOT NULL UNIQUE,
 capacidad_litros REAL NOT NULL CHECK(capacidad_litros > 0)
);
CREATE TABLE carga_combustible (
 id_carga INTEGER PRIMARY KEY,
 patente TEXT NOT NULL REFERENCES vehiculo(patente),
 id_estanque INTEGER NOT NULL REFERENCES estanque(id_estanque),
 fecha_carga TEXT NOT NULL,
 odometro INTEGER NOT NULL CHECK(odometro >= 0),
 litros REAL NOT NULL CHECK(litros > 0),
 carga_completa INTEGER NOT NULL DEFAULT 1 CHECK(carga_completa IN (0,1)),
 responsable_codigo TEXT NOT NULL
);
CREATE TABLE mantencion (
 id_mantencion INTEGER PRIMARY KEY,
 patente TEXT NOT NULL REFERENCES vehiculo(patente),
 fecha_mantencion TEXT NOT NULL,
 odometro INTEGER NOT NULL CHECK(odometro >= 0),
 tipo TEXT NOT NULL,
 proximo_control_km INTEGER NOT NULL CHECK(proximo_control_km > odometro),
 observacion TEXT
);
CREATE TABLE programacion (
 id_programacion INTEGER PRIMARY KEY,
 fecha_servicio TEXT NOT NULL,
 id_contrato INTEGER NOT NULL REFERENCES contrato(id_contrato),
 cod_recorrido TEXT NOT NULL REFERENCES recorrido(cod_recorrido),
 patente TEXT NOT NULL REFERENCES vehiculo(patente),
 id_conductor INTEGER NOT NULL REFERENCES conductor(id_conductor),
 sentido TEXT NOT NULL CHECK(sentido IN ('ENTRADA','SALIDA')),
 estado TEXT NOT NULL DEFAULT 'PROGRAMADA' CHECK(estado IN ('PROGRAMADA','CERRADA','CANCELADA'))
);
CREATE TABLE vuelta (
 id_vuelta INTEGER PRIMARY KEY,
 id_programacion INTEGER NOT NULL UNIQUE REFERENCES programacion(id_programacion),
 hora_salida TEXT,
 hora_llegada TEXT,
 pasajeros INTEGER NOT NULL DEFAULT 0 CHECK(pasajeros >= 0),
 numero_vale TEXT UNIQUE,
 estado TEXT NOT NULL CHECK(estado IN ('EJECUTADA','CANCELADA')),
 CHECK(estado = 'CANCELADA' OR
       (hora_salida IS NOT NULL AND hora_llegada IS NOT NULL AND
        hora_llegada > hora_salida AND numero_vale IS NOT NULL))
);
CREATE TABLE preliquidacion (
 id_preliquidacion INTEGER PRIMARY KEY,
 id_contrato INTEGER NOT NULL REFERENCES contrato(id_contrato),
 periodo_desde TEXT NOT NULL,
 periodo_hasta TEXT NOT NULL,
 creado_en TEXT NOT NULL,
 CHECK(periodo_hasta >= periodo_desde),
 UNIQUE(id_contrato,periodo_desde,periodo_hasta)
);
CREATE TABLE detalle_preliquidacion (
 id_preliquidacion INTEGER NOT NULL REFERENCES preliquidacion(id_preliquidacion),
 id_vuelta INTEGER NOT NULL UNIQUE REFERENCES vuelta(id_vuelta),
 monto_clp INTEGER NOT NULL CHECK(monto_clp > 0),
 PRIMARY KEY(id_preliquidacion,id_vuelta)
);

-- Misma ruta/contrato: las tarifas no pueden solaparse.
CREATE TRIGGER trg_tarifa_sin_solape BEFORE INSERT ON tarifa
BEGIN
 SELECT RAISE(ABORT,'TARIFA_SOLAPADA') WHERE EXISTS (
   SELECT 1 FROM tarifa t WHERE t.id_contrato=NEW.id_contrato
    AND t.cod_recorrido=NEW.cod_recorrido
    AND COALESCE(t.vigente_hasta,'9999-12-31') >= NEW.vigente_desde
    AND COALESCE(NEW.vigente_hasta,'9999-12-31') >= t.vigente_desde
 );
 SELECT RAISE(ABORT,'TARIFA_CLIENTE_INCOMPATIBLE') WHERE NOT EXISTS (
   SELECT 1 FROM contrato c JOIN planta p ON p.id_cliente=c.id_cliente
     JOIN recorrido r ON r.id_planta=p.id_planta
    WHERE c.id_contrato=NEW.id_contrato AND r.cod_recorrido=NEW.cod_recorrido
 );
END;
CREATE TRIGGER trg_tarifa_sin_solape_update BEFORE UPDATE ON tarifa
BEGIN
 SELECT RAISE(ABORT,'TARIFA_SOLAPADA') WHERE EXISTS (
 SELECT 1 FROM tarifa t WHERE t.id_tarifa<>OLD.id_tarifa
 AND t.id_contrato=NEW.id_contrato AND t.cod_recorrido=NEW.cod_recorrido
 AND COALESCE(t.vigente_hasta,'9999-12-31') >= NEW.vigente_desde
 AND COALESCE(NEW.vigente_hasta,'9999-12-31') >= t.vigente_desde);
END;

-- Validaciones de asignación: la decisión final es del administrador.
CREATE TRIGGER trg_programacion_validar BEFORE INSERT ON programacion
BEGIN
 SELECT RAISE(ABORT,'VEHICULO_NO_OPERATIVO') WHERE NOT EXISTS
 (SELECT 1 FROM vehiculo WHERE patente=NEW.patente AND estado='OPERATIVO');
 SELECT RAISE(ABORT,'CONDUCTOR_NO_HABILITADO') WHERE NOT EXISTS
 (SELECT 1 FROM conductor c JOIN vehiculo v ON v.patente=NEW.patente
  WHERE c.id_conductor=NEW.id_conductor AND c.activo=1
  AND c.licencia_vence>=NEW.fecha_servicio
  AND (c.clase_licencia='A3' OR v.licencia_minima='A2'));
 SELECT RAISE(ABORT,'REVISION_TECNICA_NO_VIGENTE') WHERE NOT EXISTS
 (SELECT 1 FROM documento_vehiculo d WHERE d.patente=NEW.patente
  AND d.tipo='REVISION_TECNICA' AND d.fecha_vencimiento>=NEW.fecha_servicio);
 SELECT RAISE(ABORT,'CONTRATO_O_RECORRIDO_INCOMPATIBLE') WHERE NOT EXISTS
 (SELECT 1 FROM contrato c JOIN planta p ON p.id_cliente=c.id_cliente
  JOIN recorrido r ON r.id_planta=p.id_planta
  WHERE c.id_contrato=NEW.id_contrato AND r.cod_recorrido=NEW.cod_recorrido
  AND NEW.fecha_servicio>=c.fecha_inicio
  AND (c.fecha_fin IS NULL OR NEW.fecha_servicio<=c.fecha_fin)
  AND c.estado='VIGENTE');
 SELECT RAISE(ABORT,'SIN_TARIFA_VIGENTE') WHERE NOT EXISTS
 (SELECT 1 FROM tarifa t WHERE t.id_contrato=NEW.id_contrato
 AND t.cod_recorrido=NEW.cod_recorrido AND NEW.fecha_servicio>=t.vigente_desde
 AND (t.vigente_hasta IS NULL OR NEW.fecha_servicio<=t.vigente_hasta));
END;
CREATE TRIGGER trg_vuelta_cerrar AFTER INSERT ON vuelta
WHEN NEW.estado='EJECUTADA'
BEGIN
 UPDATE programacion SET estado='CERRADA' WHERE id_programacion=NEW.id_programacion;
END;
CREATE INDEX idx_prog_fecha_contrato ON programacion(fecha_servicio,id_contrato);
CREATE INDEX idx_carga_patente_fecha ON carga_combustible(patente,fecha_carga,id_carga);
CREATE INDEX idx_doc_patente_tipo ON documento_vehiculo(patente,tipo,fecha_vencimiento);
CREATE INDEX idx_tarifa_periodo ON tarifa(id_contrato,cod_recorrido,vigente_desde);

-- Protección consistente también ante ediciones de programación.
CREATE TRIGGER trg_programacion_validar_update BEFORE UPDATE OF fecha_servicio,id_contrato,cod_recorrido,patente,id_conductor ON programacion
BEGIN
 SELECT RAISE(ABORT,'VEHICULO_NO_OPERATIVO') WHERE NOT EXISTS
  (SELECT 1 FROM vehiculo WHERE patente=NEW.patente AND estado='OPERATIVO');
 SELECT RAISE(ABORT,'CONDUCTOR_NO_HABILITADO') WHERE NOT EXISTS
  (SELECT 1 FROM conductor c JOIN vehiculo v ON v.patente=NEW.patente
   WHERE c.id_conductor=NEW.id_conductor AND c.activo=1
   AND c.licencia_vence>=NEW.fecha_servicio
   AND (c.clase_licencia='A3' OR v.licencia_minima='A2'));
 SELECT RAISE(ABORT,'REVISION_TECNICA_NO_VIGENTE') WHERE NOT EXISTS
  (SELECT 1 FROM documento_vehiculo d WHERE d.patente=NEW.patente
   AND d.tipo='REVISION_TECNICA' AND d.fecha_vencimiento>=NEW.fecha_servicio);
 SELECT RAISE(ABORT,'CONTRATO_O_RECORRIDO_INCOMPATIBLE') WHERE NOT EXISTS
  (SELECT 1 FROM contrato c JOIN planta p ON p.id_cliente=c.id_cliente
   JOIN recorrido r ON r.id_planta=p.id_planta
   WHERE c.id_contrato=NEW.id_contrato AND r.cod_recorrido=NEW.cod_recorrido
   AND NEW.fecha_servicio>=c.fecha_inicio
   AND (c.fecha_fin IS NULL OR NEW.fecha_servicio<=c.fecha_fin)
   AND c.estado='VIGENTE');
 SELECT RAISE(ABORT,'SIN_TARIFA_VIGENTE') WHERE NOT EXISTS
  (SELECT 1 FROM tarifa t WHERE t.id_contrato=NEW.id_contrato
   AND t.cod_recorrido=NEW.cod_recorrido AND NEW.fecha_servicio>=t.vigente_desde
   AND (t.vigente_hasta IS NULL OR NEW.fecha_servicio<=t.vigente_hasta));
END;
-- Una vuelta cancelada debe cancelar su programación (y nunca entrar al cobro).
CREATE TRIGGER trg_vuelta_cancelar AFTER INSERT ON vuelta
WHEN NEW.estado='CANCELADA'
BEGIN
 UPDATE programacion SET estado='CANCELADA' WHERE id_programacion=NEW.id_programacion;
END;
-- Capacidad: los pasajeros no pueden superar los asientos del vehículo asignado.
CREATE TRIGGER trg_vuelta_capacidad BEFORE INSERT ON vuelta
WHEN NEW.estado='EJECUTADA'
BEGIN
 SELECT RAISE(ABORT,'EXCEDE_CAPACIDAD') WHERE NEW.pasajeros >
   (SELECT v.capacidad FROM programacion p JOIN vehiculo v ON v.patente=p.patente
    WHERE p.id_programacion=NEW.id_programacion);
END;
CREATE TRIGGER trg_vuelta_capacidad_update BEFORE UPDATE OF pasajeros,estado,id_programacion ON vuelta
WHEN NEW.estado='EJECUTADA'
BEGIN
 SELECT RAISE(ABORT,'EXCEDE_CAPACIDAD') WHERE NEW.pasajeros >
   (SELECT v.capacidad FROM programacion p JOIN vehiculo v ON v.patente=p.patente
    WHERE p.id_programacion=NEW.id_programacion);
END;
-- La preliquidación solo admite vueltas ejecutadas del mismo contrato, al valor histórico correcto.
CREATE TRIGGER trg_detalle_preliquidacion BEFORE INSERT ON detalle_preliquidacion
BEGIN
 SELECT RAISE(ABORT,'DETALLE_CONTRATO_O_ESTADO_INVALIDO') WHERE NOT EXISTS (
  SELECT 1 FROM preliquidacion l JOIN vuelta v ON v.id_vuelta=NEW.id_vuelta
   JOIN programacion p ON p.id_programacion=v.id_programacion
   WHERE l.id_preliquidacion=NEW.id_preliquidacion
    AND l.id_contrato=p.id_contrato AND v.estado='EJECUTADA'
    AND p.fecha_servicio BETWEEN l.periodo_desde AND l.periodo_hasta);
 SELECT RAISE(ABORT,'DETALLE_MONTO_INCORRECTO') WHERE NOT EXISTS (
  SELECT 1 FROM vuelta v JOIN programacion p ON p.id_programacion=v.id_programacion
   JOIN tarifa t ON t.id_contrato=p.id_contrato AND t.cod_recorrido=p.cod_recorrido
   WHERE v.id_vuelta=NEW.id_vuelta AND p.fecha_servicio>=t.vigente_desde
   AND (t.vigente_hasta IS NULL OR p.fecha_servicio<=t.vigente_hasta)
   AND t.monto_clp=NEW.monto_clp);
END;
CREATE TRIGGER trg_detalle_preliquidacion_update BEFORE UPDATE ON detalle_preliquidacion
BEGIN
 SELECT RAISE(ABORT,'DETALLE_CONTRATO_O_ESTADO_INVALIDO') WHERE NOT EXISTS (
  SELECT 1 FROM preliquidacion l JOIN vuelta v ON v.id_vuelta=NEW.id_vuelta
   JOIN programacion p ON p.id_programacion=v.id_programacion
   WHERE l.id_preliquidacion=NEW.id_preliquidacion
    AND l.id_contrato=p.id_contrato AND v.estado='EJECUTADA'
    AND p.fecha_servicio BETWEEN l.periodo_desde AND l.periodo_hasta);
 SELECT RAISE(ABORT,'DETALLE_MONTO_INCORRECTO') WHERE NOT EXISTS (
  SELECT 1 FROM vuelta v JOIN programacion p ON p.id_programacion=v.id_programacion
   JOIN tarifa t ON t.id_contrato=p.id_contrato AND t.cod_recorrido=p.cod_recorrido
   WHERE v.id_vuelta=NEW.id_vuelta AND p.fecha_servicio>=t.vigente_desde
   AND (t.vigente_hasta IS NULL OR p.fecha_servicio<=t.vigente_hasta)
   AND t.monto_clp=NEW.monto_clp);
END;
-- Toda edición de tarifa sigue respetando el cliente asociado a la ruta.
CREATE TRIGGER trg_tarifa_update_cliente BEFORE UPDATE OF id_contrato,cod_recorrido ON tarifa
BEGIN
 SELECT RAISE(ABORT,'TARIFA_CLIENTE_INCOMPATIBLE') WHERE NOT EXISTS
 (SELECT 1 FROM contrato c JOIN planta p ON p.id_cliente=c.id_cliente
   JOIN recorrido r ON r.id_planta=p.id_planta
   WHERE c.id_contrato=NEW.id_contrato AND r.cod_recorrido=NEW.cod_recorrido);
END;
COMMIT;
