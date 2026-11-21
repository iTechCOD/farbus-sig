-- Q3: revisiones técnicas que vencen dentro de 30 días desde 21-nov-2026.
WITH ultima AS (
 SELECT patente,tipo,MAX(fecha_emision) AS ultima_emision
 FROM documento_vehiculo GROUP BY patente,tipo
)
SELECT d.patente,d.tipo,d.fecha_vencimiento,
 CAST(julianday(d.fecha_vencimiento)-julianday('2026-11-21') AS INTEGER) AS dias_restantes
FROM documento_vehiculo d JOIN ultima u
 ON d.patente=u.patente AND d.tipo=u.tipo AND d.fecha_emision=u.ultima_emision
WHERE d.fecha_vencimiento BETWEEN '2026-11-21' AND date('2026-11-21','+30 days')
ORDER BY d.fecha_vencimiento,d.patente;
