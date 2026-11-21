-- Q1: consolidado de vueltas EJECUTADAS por contrato, 17-20 nov 2026.
-- La tarifa se resuelve por fecha de servicio, no por valor actual.
SELECT c.codigo AS contrato, cl.nombre AS cliente,
 COUNT(*) AS vueltas_ejecutadas,
 SUM(v.pasajeros) AS pasajeros_trasladados,
 SUM(t.monto_clp) AS monto_preliquidado_clp
FROM vuelta v
JOIN programacion p ON p.id_programacion=v.id_programacion
JOIN contrato c ON c.id_contrato=p.id_contrato
JOIN cliente cl ON cl.id_cliente=c.id_cliente
JOIN tarifa t ON t.id_contrato=p.id_contrato AND t.cod_recorrido=p.cod_recorrido
 AND p.fecha_servicio BETWEEN t.vigente_desde AND COALESCE(t.vigente_hasta,'9999-12-31')
WHERE v.estado='EJECUTADA' AND p.fecha_servicio BETWEEN '2026-11-17' AND '2026-11-20'
GROUP BY c.codigo,cl.nombre ORDER BY c.codigo;
