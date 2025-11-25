"""
ENTREGABLE 3 - Pruebas de Carga/Estrés con Locust
==================================================
Configurado para máquinas con 8GB RAM (Smoke Test - Bajo Consumo)

INSTALACIÓN:
    pip install locust

EJECUCIÓN MODO HEADLESS (Genera reporte HTML):
    locust -f locustfile.py --headless --users 10 --spawn-rate 2 --run-time 2m \\
           --host=https://your-azure-gateway.azurewebsites.net --html=report_locust.html

EJECUCIÓN MODO WEB UI (Más control):
    locust -f locustfile.py --host=https://your-azure-gateway.azurewebsites.net
    Luego abrir: http://localhost:8089

PARÁMETROS RECOMENDADOS PARA 8GB RAM (Smoke Test):
    - Users: 10-20 usuarios concurrentes
    - Spawn Rate: 2 usuarios/segundo
    - Run Time: 2-5 minutos

Autor: QA & DevOps Team
Fecha: 24 de noviembre de 2025
Tecnología: Locust 2.x + Python 3.x
"""

from locust import HttpUser, task, between
import urllib3

# Deshabilitar advertencias SSL para Azure
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


class EcommerceUser(HttpUser):
    """
    Simula un usuario del sistema de E-commerce
    Configuración ligera para máquinas de 8GB RAM (Smoke Test)
    """
    
    # Tiempo de espera entre requests (1-5 segundos)
    # Reduce carga y simula comportamiento humano real
    wait_time = between(1, 5)
    
    def on_start(self):
        """Configuración inicial - Ignora SSL para Azure"""
        self.client.verify = False
    
    @task(3)  # Peso 3 - Se ejecuta 3x más frecuente
    def get_products(self):
        """
        Tarea A - GET lista de productos (Alta prioridad)
        Simula navegación a catálogo de productos
        """
        with self.client.get(
            "/product-service/api/products",
            catch_response=True,
            name="GET /products"
        ) as response:
            if response.status_code == 200:
                response.success()
            elif response.status_code == 429:
                # Rate Limit esperado (Resilience4j configurado)
                response.success()  # No marcamos como fallo
            else:
                response.failure(f"Status: {response.status_code}")
    
    @task(1)  # Peso 1 - Menos frecuente
    def get_order(self):
        """
        Tarea B - GET orden específica (Menor prioridad)
        Simula consulta de estado de orden
        """
        with self.client.get(
            "/order-service/api/orders/1",
            catch_response=True,
            name="GET /orders/{id}"
        ) as response:
            if response.status_code == 200:
                response.success()
            elif response.status_code == 404:
                # Orden no encontrada (esperado)
                response.success()
            elif response.status_code == 429:
                # Rate Limit esperado
                response.success()
            else:
                response.failure(f"Status: {response.status_code}")


"""
═══════════════════════════════════════════════════════════════════
COMANDOS DE EJECUCIÓN
═══════════════════════════════════════════════════════════════════

1. SMOKE TEST (Recomendado para 8GB RAM):
   locust -f locustfile.py --headless \\
     --users 10 --spawn-rate 2 --run-time 2m \\
     --host=https://your-gateway.azurewebsites.net \\
     --html=report_smoke_test.html

2. MODO WEB UI (Control manual):
   locust -f locustfile.py --host=https://your-gateway.azurewebsites.net
   # Abrir: http://localhost:8089

3. LOAD TEST (Moderado):
   locust -f locustfile.py --headless \\
     --users 50 --spawn-rate 5 --run-time 5m \\
     --host=https://your-gateway.azurewebsites.net \\
     --html=report_load_test.html

═══════════════════════════════════════════════════════════════════
MÉTRICAS A MONITOREAR
═══════════════════════════════════════════════════════════════════
- Response Time (p50, p95, p99): Percentiles de tiempo de respuesta
- Requests per Second (RPS): Throughput del sistema
- Failure Rate: % de peticiones fallidas (< 1% aceptable)
- Rate Limit 429: Activaciones esperadas con Resilience4j

═══════════════════════════════════════════════════════════════════
RECOMENDACIONES
═══════════════════════════════════════════════════════════════════
1. Ejecutar primero con 10 usuarios para validar
2. Incrementar gradualmente si la RAM lo permite
3. Monitorear recursos: Task Manager (Windows) o htop (Linux)
4. En Azure: Revisar Azure Monitor durante el test
═══════════════════════════════════════════════════════════════════
"""
