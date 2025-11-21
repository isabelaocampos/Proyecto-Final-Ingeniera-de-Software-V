"""
Script de Pruebas de Carga con Locust
======================================

Este script implementa pruebas de rendimiento para el sistema de microservicios
de e-commerce, evaluando el comportamiento bajo carga de los servicios:
- product-service: Servicio de productos
- order-service: Servicio de órdenes

Autor: QA Team
Fecha: 20 de noviembre de 2025
Tecnología: Locust 2.x + Python 3.x
"""

from locust import HttpUser, task, between


class EcommerceUser(HttpUser):
    """
    Clase que simula el comportamiento de un usuario del sistema e-commerce.
    
    Cada instancia de esta clase representa un usuario virtual que realiza
    peticiones HTTP a los diferentes microservicios del sistema.
    
    Atributos:
        wait_time: Tiempo de espera entre tareas (1-5 segundos)
                   Simula el tiempo que un usuario real tarda entre acciones
    """
    
    # Tiempo de espera aleatorio entre 1 y 5 segundos entre cada tarea
    # Esto simula el comportamiento real de usuarios navegando el sitio
    wait_time = between(1, 5)
    
    @task(3)
    def get_products(self):
        """
        Tarea A: Consultar lista de productos (Peso: 3)
        
        Endpoint: GET /product-service/api/products
        Propósito: Simula usuarios navegando el catálogo de productos
        Peso 3: Esta tarea se ejecuta 3 veces más frecuentemente que get_order
                porque los usuarios típicamente consultan productos más seguido
        
        Métricas evaluadas:
        - Tiempo de respuesta
        - Tasa de éxito/fallo
        - Throughput (peticiones/segundo)
        """
        with self.client.get(
            "/product-service/api/products",
            catch_response=True,
            name="GET /product-service/api/products"
        ) as response:
            if response.status_code == 200:
                # Petición exitosa
                response.success()
            else:
                # Petición fallida - registrar el error
                response.failure(f"Error {response.status_code}: {response.text}")
    
    @task(1)
    def get_order(self):
        """
        Tarea B: Consultar orden específica (Peso: 1)
        
        Endpoint: GET /order-service/api/orders/1
        Propósito: Simula usuarios consultando el detalle de una orden
        Peso 1: Esta tarea se ejecuta con menor frecuencia porque representa
                una acción específica (ver detalle de orden)
        
        Métricas evaluadas:
        - Tiempo de respuesta para consultas específicas
        - Rendimiento del servicio de órdenes
        - Impacto de Rate Limiter (5 req/10s configurado)
        """
        with self.client.get(
            "/order-service/api/orders/1",
            catch_response=True,
            name="GET /order-service/api/orders/1"
        ) as response:
            if response.status_code == 200:
                # Petición exitosa
                response.success()
            elif response.status_code == 429:
                # Rate Limit alcanzado (esperado con Resilience4j)
                response.failure("Rate Limit: Demasiadas peticiones")
            else:
                # Otro tipo de error
                response.failure(f"Error {response.status_code}: {response.text}")


"""
Instrucciones de Ejecución:
===========================

1. Instalar Locust:
   pip install locust

2. Ejecutar prueba desde línea de comandos:
   locust -f tests/performance/locustfile.py --host=http://localhost:8080

3. Ejecutar con parámetros específicos (sin UI):
   locust -f tests/performance/locustfile.py --host=http://localhost:8080 \
          --users 10 --spawn-rate 2 --run-time 1m --headless

4. Acceder a la interfaz web:
   http://localhost:8089

Parámetros recomendados para pruebas:
======================================
- Usuarios: 10-50 (usuarios concurrentes)
- Spawn rate: 2-5 (usuarios nuevos por segundo)
- Duración: 1-5 minutos

Interpretación de Resultados:
==============================
- Response Time (avg): Tiempo promedio de respuesta (< 200ms es excelente)
- Requests/s: Throughput del sistema (más alto = mejor)
- Failure Rate: Porcentaje de peticiones fallidas (< 1% es aceptable)
- 95th percentile: 95% de las peticiones responden en este tiempo o menos

Validación de Patrones de Resiliencia:
======================================
- Rate Limiter: Observar errores 429 en order-service al superar 5 req/10s
- Retry: Las peticiones fallidas deberían reintentar automáticamente
- Circuit Breaker: Después de múltiples fallos, el servicio abre el circuito

Notas Importantes:
==================
- Asegurarse de que los servicios estén ejecutándose antes de la prueba
- El API Gateway debe estar en puerto 8500
- Monitorear uso de CPU y memoria durante las pruebas
- Revisar logs de los servicios para detectar errores no reportados
"""
