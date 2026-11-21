-- Q5: comparación entre servicios programados, ejecutados, cancelados y pendientes.
SELECT p.fecha_servicio,
 COUNT(*) AS servicios_programados,
 SUM(CASE WHEN v.estado='EJECUTADA' THEN 1 ELSE 0 END) AS ejecutados,
 SUM(CASE WHEN v.estado='CANCELADA' THEN 1 ELSE 0 END) AS cancelados,
 SUM(CASE WHEN v.id_vuelta IS NULL THEN 1 ELSE 0 END) AS pendientes
FROM programacion p LEFT JOIN vuelta v ON v.id_programacion=p.id_programacion
GROUP BY p.fecha_servicio ORDER BY p.fecha_servicio;
