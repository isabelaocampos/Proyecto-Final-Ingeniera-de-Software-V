# Estrategia de Pruebas y Calidad de Software

Este documento detalla la implementación de la estrategia de pruebas "Shift-Left", cubriendo el 100% de los requisitos de aseguramiento de calidad del proyecto.

## 1. Pirámide de Pruebas Implementada

### A. Pruebas Unitarias (Unit Testing)
* **Tecnología:** JUnit 5 + Mockito.
* **Cobertura:** Validación aislada de la lógica de negocio en Servicios y Controladores.
* **Ejecución:** Automatizada en cada compilación con Maven.
* **Ubicación:** `src/test/java/**/ProductServiceTest.java`.
* [cite_start]**Cumplimiento:** [cite: 34]

### B. Pruebas de Integración (Integration Testing)
* **Tecnología:** `@SpringBootTest` + H2 Database (In-Memory).
* **Propósito:** Validar la comunicación entre los controladores REST y la capa de persistencia sin dependencias externas.
* **Ubicación:** `src/test/java/**/ProductControllerIntegrationTest.java`.
* **Cumplimiento:** [cite: 35]

### C. Pruebas End-to-End (E2E) de Flujo Crítico
* **Tecnología:** `MockMvc` (Enfoque ligero para CI/CD).
* **Escenario:** Flujo completo de creación y verificación de órdenes (Usuario -> Orden -> Consulta).
* **Beneficio:** Valida la integridad referencial y el flujo de datos entre microservicios simulados.
* **Ubicación:** `src/test/java/**/OrderFlowE2ETest.java`.
* **Cumplimiento:** [cite: 36]

---

## 2. Pruebas No Funcionales

### A. Pruebas de Rendimiento y Estrés (Performance)
* **Herramienta:** Locust (Python).
* **Escenario:** "Smoke Test" distribuido atacando la infraestructura en Azure.
* **Configuración:**
    * Usuarios Concurrentes: 20
    * Tasa despawn: 2 usuarios/seg
    * Duración: 2 minutos (FinOps compliant)
* **Archivo:** `locustfile.py` (Raíz del proyecto).
* **Cumplimiento:** [cite: 37]

### B. Pruebas de Seguridad (DAST)
* **Herramienta:** OWASP ZAP (Zed Attack Proxy).
* **Implementación:** Pipeline de GitHub Actions ejecutando `zaproxy/action-baseline`.
* **Objetivo:** Escaneo dinámico de vulnerabilidades web contra la URL pública de Azure.
* **Archivo:** `.github/workflows/security-scan.yml`.
* [cite_start]**Cumplimiento:** [cite: 38]

---

## 3. Automatización y Métricas (CI/CD)

### Reportes de Cobertura
* **Herramienta:** JaCoCo (Java Code Coverage).
* **Configuración:** Generación automática de reportes HTML/XML en fase `verify`.
* **Umbral de Calidad:** El pipeline alerta si la cobertura desciende del 30%.
* [cite_start]**Cumplimiento:** [cite: 39]

### Pipelines de Calidad (Quality Gates)
Se ha configurado un workflow de GitHub Actions (`quality-gate.yml`) que actúa como barrera de calidad, impidiendo el paso de código que no compile o falle en las pruebas unitarias.