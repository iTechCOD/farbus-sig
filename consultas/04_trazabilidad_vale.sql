-- Q4: reconstrucción de un servicio específico para gestionar reclamos.
SELECT v.numero_vale,p.fecha_servicio,cl.nombre AS cliente,
 p.cod_recorrido,p.sentido,p.patente,co.codigo AS conductor_anonimizado,
 v.hora_salida,v.hora_llegada,v.pasajeros,v.estado,
 t.monto_clp AS tarifa_aplicable_clp
FROM vuelta v JOIN programacion p USING(id_programacion)
JOIN contrato c ON c.id_contrato=p.id_contrato
JOIN cliente cl ON cl.id_cliente=c.id_cliente
JOIN conductor co ON co.id_conductor=p.id_conductor
LEFT JOIN tarifa t ON t.id_contrato=p.id_contrato AND t.cod_recorrido=p.cod_recorrido
 AND p.fecha_servicio BETWEEN t.vigente_desde AND COALESCE(t.vigente_hasta,'9999-12-31')
WHERE v.numero_vale='SIM-VA-005';
