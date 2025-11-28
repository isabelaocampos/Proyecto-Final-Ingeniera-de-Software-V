# Catálogo de Patrones de Diseño de Microservicios

[cite_start]Este documento detalla los patrones de diseño implementados en la arquitectura, cumpliendo con el requisito de identificación e implementación de nuevos patrones de resiliencia y configuración.

## 1. Patrones de Configuración e Infraestructura

### External Configuration (Configuración Externalizada) [MEJORADO]
* **Tipo:** Configuración.
* **Herramienta:** Spring Cloud Config Server (Modo Native).
* [cite_start]**Propósito:** Desacoplar las propiedades de configuración del código fuente de los microservicios[cite: 23].
* **Mejora Implementada:** Se migró de una dependencia Git remota a un **Backend Nativo Local**.
* **Beneficio:** Aumenta la estabilidad del entorno de desarrollo al eliminar la dependencia de red externa para el arranque de la infraestructura, permitiendo despliegues offline y más rápidos.

### Service Discovery (Descubrimiento de Servicios) [EXISTENTE]
* **Tipo:** Infraestructura.
* **Herramienta:** Netflix Eureka.
* **Propósito:** Permitir que los servicios se localicen dinámicamente sin hardcodear direcciones IP/puertos.
* **Beneficio:** Facilita el escalado horizontal (agregar más instancias de un servicio) sin reconfigurar los clientes.

### API Gateway (Puerta de Enlace) [EXISTENTE]
* **Tipo:** Enrutamiento.
* **Herramienta:** Spring Cloud Gateway.
* **Propósito:** Actuar como punto de entrada único para todas las peticiones externas.
* **Beneficio:** Centraliza preocupaciones transversales como seguridad, monitoreo y enrutamiento, ocultando la topología interna al cliente.

---

## 2. Patrones de Resiliencia y Tolerancia a Fallos
[cite_start]*Implementación de patrones adicionales requeridos utilizando Resilience4j[cite: 22].*

### Circuit Breaker (Cortocircuito)
* **Estado:** Implementado.
* **Propósito:** Detectar fallos continuos en un servicio y dejar de enviarle tráfico temporalmente para evitar fallos en cascada.
* **Configuración:** Umbral de fallo del 50%. Si la mitad de las peticiones fallan, el circuito se abre.
* **Beneficio:** Permite que el sistema falle de manera elegante (fail-fast) en lugar de dejar hilos colgados esperando respuesta de un servicio muerto.

### Rate Limiter (Limitador de Tasa) [NUEVO]
* **Estado:** Implementado.
* **Propósito:** Controlar la cantidad de tráfico que un servicio puede recibir en un periodo de tiempo.
* **Configuración:** Límite de 5 peticiones por ráfaga.
* **Beneficio:** Protege a los microservicios (y a la base de datos H2 en memoria) de ser saturados por picos de tráfico o ataques de denegación de servicio.

### Retry Pattern (Patrón de Reintento) [NUEVO]
* **Estado:** Implementado.
* **Propósito:** Manejar fallos transitorios de red (ej. un parpadeo en la conexión) reintentando la operación automáticamente.
* **Configuración:** 3 intentos con espera de 500ms.
* **Beneficio:** Mejora la experiencia de usuario al "salvar" peticiones que fallaron por errores momentáneos de infraestructura.

---

## 3. Patrones de Observabilidad

### Distributed Tracing (Trazabilidad Distribuida)
* **Herramienta:** Zipkin + Spring Cloud Sleuth.
* [cite_start]**Propósito:** Asignar un ID único (Trace ID) a cada petición para rastrearla a través de todos los microservicios[cite: 51].
* **Beneficio:** Permite diagnosticar cuellos de botella y errores en flujos complejos de microservicios.