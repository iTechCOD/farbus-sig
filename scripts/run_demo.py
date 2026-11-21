#!/usr/bin/env python3
"""Reproduce los resultados E2 desde cero, usando solamente SQLite de Python."""
from pathlib import Path
import sqlite3, csv, argparse, json, sys
ROOT = Path(__file__).resolve().parents[1]
def build(db_path: Path):
    db_path.parent.mkdir(parents=True,exist_ok=True)
    if db_path.exists(): db_path.unlink()
    con=sqlite3.connect(str(db_path))
    con.execute('PRAGMA foreign_keys=ON')
    con.executescript((ROOT/'db/schema.sql').read_text(encoding='utf-8'))
    con.executescript((ROOT/'db/seed.sql').read_text(encoding='utf-8'))
    return con

def run_queries(con, output_dir):
    output_dir.mkdir(parents=True,exist_ok=True)
    info=[]
    for f in sorted((ROOT/'consultas').glob('*.sql')):
        cursor=con.execute(f.read_text(encoding='utf-8'))
        rows=cursor.fetchall()
        columns=[item[0] for item in cursor.description]
        with (output_dir/(f.stem+'.csv')).open('w',newline='',encoding='utf-8-sig') as out:
            w=csv.writer(out);w.writerow(columns);w.writerows(rows)
        info.append({'consulta':f.name,'filas':len(rows),'columnas':columns,'resultados':rows})
        print(f'[{f.stem}] {len(rows)} filas')
        for row in rows: print('  ', ' | '.join(str(v) if v is not None else 'NULL' for v in row))
    (output_dir/'resumen_resultados.json').write_text(json.dumps(info,ensure_ascii=False,indent=2),encoding='utf-8')
    return info

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--db',default=str(ROOT/'db/farbus_demo.sqlite'))
    ap.add_argument('--salida',default=str(ROOT/'resultados'))
    a=ap.parse_args()
    con=build(Path(a.db))
    print('Integridad:',con.execute('PRAGMA integrity_check').fetchone()[0])
    print('FK invalidas:',len(con.execute('PRAGMA foreign_key_check').fetchall()))
    run_queries(con,Path(a.salida))
    con.close()
if __name__=='__main__': main()
