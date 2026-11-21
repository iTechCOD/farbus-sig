-- Q2: estimación km/L entre dos llenados completos consecutivos.
-- El odómetro de cada carga es la lectura al término del periodo;
-- se usa la cantidad de litros de la carga actual como aproximación de consumo.
WITH pares AS (
 SELECT patente, fecha_carga, odometro, litros,
 LAG(odometro) OVER (PARTITION BY patente ORDER BY fecha_carga,id_carga) AS km_anterior
 FROM carga_combustible WHERE carga_completa=1
), validos AS (
 SELECT patente, (odometro-km_anterior) AS km, litros
 FROM pares WHERE km_anterior IS NOT NULL AND odometro>km_anterior
)
SELECT patente, SUM(km) AS km_entre_llenados,
 ROUND(SUM(litros),1) AS litros_repuestos,
 ROUND(SUM(km)*1.0/SUM(litros),2) AS rendimiento_km_l
FROM validos GROUP BY patente ORDER BY patente;
