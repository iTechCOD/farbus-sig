from pathlib import Path
import unittest, sqlite3, tempfile, sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'scripts'))
from run_demo import build
from alertas import generar_alertas
class ModeloTest(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory()
        self.db_path=Path(self.tmp.name)/'demo.db'
        self.con=build(self.db_path)
    def tearDown(self):
        self.con.close();self.tmp.cleanup()
    def test_integridad_y_contenido(self):
        self.assertEqual(self.con.execute('PRAGMA integrity_check').fetchone()[0],'ok')
        self.assertEqual(self.con.execute('PRAGMA foreign_key_check').fetchall(),[])
        self.assertEqual(self.con.execute('SELECT count(*) FROM vuelta WHERE estado="EJECUTADA"').fetchone()[0],11)
    def test_bloquea_vehiculo_en_mantencion(self):
        with self.assertRaisesRegex(sqlite3.IntegrityError,'VEHICULO_NO_OPERATIVO'):
            self.con.execute("""INSERT INTO programacion(fecha_servicio,id_contrato,cod_recorrido,patente,id_conductor,sentido)
            VALUES('2026-11-20',1,'R01-D','SIM004',1,'ENTRADA')""")
    def test_bloquea_licencia_incompatible(self):
        with self.assertRaisesRegex(sqlite3.IntegrityError,'CONDUCTOR_NO_HABILITADO'):
            self.con.execute("""INSERT INTO programacion(fecha_servicio,id_contrato,cod_recorrido,patente,id_conductor,sentido)
            VALUES('2026-11-20',1,'R01-D','SIM001',2,'ENTRADA')""")
    def test_bloquea_revision_vencida(self):
        with self.assertRaisesRegex(sqlite3.IntegrityError,'REVISION_TECNICA_NO_VIGENTE'):
            self.con.execute("""INSERT INTO programacion(fecha_servicio,id_contrato,cod_recorrido,patente,id_conductor,sentido)
            VALUES('2026-12-10',2,'R02-D','SIM003',4,'ENTRADA')""")
    def test_bloquea_tarifa_solapada(self):
        with self.assertRaisesRegex(sqlite3.IntegrityError,'TARIFA_SOLAPADA'):
            self.con.execute("""INSERT INTO tarifa(id_contrato,cod_recorrido,monto_clp,vigente_desde,vigente_hasta)
            VALUES(1,'R01-D',55000,'2026-11-10','2026-12-01')""")
    def test_vuelta_no_puede_duplicarse(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.con.execute("INSERT INTO vuelta(id_programacion,estado) VALUES(1,'CANCELADA')")
    def test_fk_obligatoria(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.con.execute("INSERT INTO carga_combustible(patente,id_estanque,fecha_carga,odometro,litros,responsable_codigo) VALUES('SINEX',1,'2026-11-21',100,10,'SIM')")
    def test_consolidado_montos(self):
        q=(ROOT/'consultas/01_consolidado_cobro.sql').read_text()
        self.assertEqual([(row[0],row[-1]) for row in self.con.execute(q)], [('SIM-DOLE-2026',327000),('SIM-PF-2026',200500)])
    def test_alertas_automaticas(self):
        result=generar_alertas(self.db_path,'2026-11-21',30)
        self.assertGreaterEqual(result['cantidad_alertas'],3)
        self.assertTrue(any(x['tipo']=='MANTENCION' and x['patente']=='SIM003' for x in result['alertas']))

    def test_cancelacion_actualiza_estado_programacion(self):
        self.assertEqual(self.con.execute("SELECT estado FROM programacion WHERE id_programacion=12").fetchone()[0],'CANCELADA')
    def test_bloquea_pasajeros_sobre_capacidad(self):
        with self.assertRaisesRegex(sqlite3.IntegrityError,'EXCEDE_CAPACIDAD'):
            self.con.execute("""INSERT INTO vuelta(id_programacion,hora_salida,hora_llegada,pasajeros,numero_vale,estado)
            VALUES(13,'07:00','07:45',13,'SIM-VA-013','EJECUTADA')""")
    def test_bloquea_detalle_contrato_ajeno(self):
        with self.assertRaisesRegex(sqlite3.IntegrityError,'DETALLE_CONTRATO_O_ESTADO_INVALIDO'):
            self.con.execute("INSERT INTO detalle_preliquidacion VALUES(2,1,45000)")
    def test_bloquea_detalle_monto_alterado(self):
        with self.assertRaisesRegex(sqlite3.IntegrityError,'DETALLE_MONTO_INCORRECTO'):
            self.con.execute("UPDATE detalle_preliquidacion SET monto_clp=99999 WHERE id_vuelta=1")
    def test_bloquea_edicion_programacion_invalida(self):
        with self.assertRaisesRegex(sqlite3.IntegrityError,'VEHICULO_NO_OPERATIVO'):
            self.con.execute("UPDATE programacion SET patente='SIM004' WHERE id_programacion=13")

if __name__=='__main__': unittest.main()
