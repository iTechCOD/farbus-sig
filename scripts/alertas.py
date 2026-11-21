#!/usr/bin/env python3
"""Automatización homóloga a n8n: chequeo programable de vencimientos y mantención."""
import sqlite3, argparse, json
from datetime import date, timedelta
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def generar_alertas(db_path, fecha, dias=30):
    con=sqlite3.connect(str(db_path))
    con.row_factory=sqlite3.Row
    con.execute('PRAGMA foreign_keys=ON')
    limite=(date.fromisoformat(fecha)+timedelta(days=dias)).isoformat()
    docs=con.execute('''WITH ultimos AS (
      SELECT patente,tipo,MAX(fecha_emision) ultima
      FROM documento_vehiculo GROUP BY patente,tipo)
      SELECT d.patente,d.tipo,d.fecha_vencimiento
      FROM documento_vehiculo d JOIN ultimos u
      ON u.patente=d.patente AND u.tipo=d.tipo AND u.ultima=d.fecha_emision
      WHERE d.fecha_vencimiento <= ?
      ORDER BY d.fecha_vencimiento,d.patente''',(limite,)).fetchall()
    al=[]
    for d in docs:
        delta=(date.fromisoformat(d['fecha_vencimiento'])-date.fromisoformat(fecha)).days
        al.append({'tipo':'DOCUMENTO','patente':d['patente'],'documento':d['tipo'],
                   'vencimiento':d['fecha_vencimiento'],'dias_restantes':delta,
                   'prioridad':'VENCIDO' if delta<0 else 'POR_VENCER'})
    manten=con.execute('''WITH ultimos AS (
      SELECT patente,MAX(fecha_mantencion) AS ultima FROM mantencion GROUP BY patente)
      SELECT v.patente,v.odometro_actual,m.proximo_control_km
      FROM vehiculo v JOIN ultimos u ON u.patente=v.patente
      JOIN mantencion m ON m.patente=u.patente AND m.fecha_mantencion=u.ultima
      WHERE v.odometro_actual>=m.proximo_control_km-500
      ORDER BY v.patente''').fetchall()
    for m in manten:
        resta=m['proximo_control_km']-m['odometro_actual']
        al.append({'tipo':'MANTENCION','patente':m['patente'],
                   'km_restantes':resta,
                   'prioridad':'VENCIDA' if resta<=0 else 'PROXIMA'})
    con.close()
    return {'fecha_control':fecha,'horizonte_dias':dias,'cantidad_alertas':len(al),'alertas':al}

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--db',default=str(ROOT/'db/farbus_demo.sqlite'))
    ap.add_argument('--fecha',default=date.today().isoformat())
    ap.add_argument('--dias',type=int,default=30)
    ap.add_argument('--salida',default=str(ROOT/'resultados/alertas_demo.json'))
    a=ap.parse_args()
    if not Path(a.db).exists(): raise SystemExit('Primero ejecutar: python scripts/run_demo.py')
    r=generar_alertas(a.db,a.fecha,a.dias)
    Path(a.salida).parent.mkdir(parents=True,exist_ok=True)
    Path(a.salida).write_text(json.dumps(r,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps(r,ensure_ascii=False,indent=2))
if __name__=='__main__': main()
