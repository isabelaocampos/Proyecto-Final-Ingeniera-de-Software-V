"""
Locust Load Testing Script - Safe Mode for Azure Student Tier
==============================================================

Este script implementa pruebas de carga "Safe Mode" diseñadas específicamente
para infraestructuras con recursos limitados (Azure Student Tier).

Características de Seguridad:
- Wait time: 1-3 segundos entre peticiones (evita saturación)
- Verificación SSL deshabilitada (desarrollo/testing)
- Smoke Test distribuido (no stress testing agresivo)

Endpoints testeados:
- GET /product-service/api/products (Funcionalidad principal)
- GET /product-service/actuator/health (Health check)

URL Base: http://4.239.160.144:8080
"""

from locust import HttpUser, task, between


class WebsiteUser(HttpUser):
    """
    Clase de usuario simulado para pruebas de carga en modo seguro.
    
    Configuración:
    - wait_time: Espera entre 1 y 3 segundos entre cada tarea
    - host: Debe configurarse vía CLI o en la UI de Locust
    """
    
    # Tiempo de espera entre peticiones (1-3 segundos)
    # Esto previene saturación del backend en infraestructura limitada
    wait_time = between(1, 3)
    
    @task(3)  # Peso 3: Esta tarea se ejecuta 3 veces más que health_check
    def view_products(self):
        """
        Tarea 1: Consulta el catálogo de productos.
        
        Endpoint: GET /product-service/api/products
        Propósito: Simular usuarios navegando el catálogo de e-commerce
        Peso: 3 (75% de las peticiones)
        """
        with self.client.get(
            "/product-service/api/products",
            verify=False,  # Deshabilitar verificación SSL (entorno de desarrollo)
            catch_response=True
        ) as response:
            if response.status_code == 200:
                response.success()
            elif response.status_code == 404:
                response.failure("Endpoint not found (404)")
            elif response.status_code >= 500:
                response.failure(f"Server error ({response.status_code})")
            else:
                response.failure(f"Unexpected status code: {response.status_code}")
    
    @task(1)  # Peso 1: Esta tarea se ejecuta 1 vez por cada 3 de view_products
    def health_check(self):
        """
        Tarea 2: Verifica el estado de salud del servicio.
        
        Endpoint: GET /product-service/actuator/health
        Propósito: Monitorear disponibilidad del microservicio
        Peso: 1 (25% de las peticiones)
        """
        with self.client.get(
            "/product-service/actuator/health",
            verify=False,  # Deshabilitar verificación SSL
            catch_response=True
        ) as response:
            if response.status_code == 200:
                # Health check exitoso
                response.success()
            else:
                response.failure(f"Health check failed with status: {response.status_code}")


# Configuración adicional para ejecución desde CLI
# Estas variables se pueden sobrescribir con argumentos de línea de comandos
if __name__ == "__main__":
    import os
    # Configurar host por defecto si no se especifica
    os.environ.setdefault("LOCUST_HOST", "http://4.239.160.144:8080")
