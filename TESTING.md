# Estrategia de Pruebas Completas - E-commerce Microservices

## 📋 Resumen Ejecutivo

Este documento describe la estrategia integral de pruebas implementada para el proyecto de e-commerce basado en microservicios, adoptando un enfoque **Shift-Left** y principios de **FinOps** para optimizar recursos técnicos y económicos en un entorno de infraestructura limitada (Azure Student Tier).

---

## 🔺 1. Pirámide de Pruebas

La estrategia de testing sigue la pirámide de pruebas de Mike Cohn, optimizada para desarrollo local con recursos limitados (8GB RAM).

```
       /\
      /  \     E2E (Ligero)
     /____\    MockMvc + TestRestTemplate
    /      \   
   /________\  Integración
  /          \ H2 In-Memory + @SpringBootTest
 /____________\
/   Unitarias  \
 JUnit 5 + Mockito
```

### 1.1 Pruebas Unitarias (Base de la Pirámide)

**Framework:** JUnit 5 + Mockito + AssertJ

**Cobertura:** 
- Servicios (`@Service`)
- Recursos REST (`@RestController`)
- Lógica de negocio aislada

**Beneficios:**
- ✅ Ejecución rápida (<5ms por test)
- ✅ Bajo consumo de memoria (~50MB por suite)
- ✅ Feedback inmediato en desarrollo local
- ✅ Alta cobertura de código (>20% actual, objetivo 30%)

**Ejemplo:**
```java
@Test
void testFindAllOrders_Unit() {
    // Given
    List<Order> mockOrders = Arrays.asList(
        Order.builder().orderId(1).orderDesc("Test Order").build()
    );
    when(orderRepository.findAll()).thenReturn(mockOrders);
    
    // When
    List<OrderDto> result = orderService.findAll();
    
    // Then
    assertThat(result).hasSize(1);
}
```

### 1.2 Pruebas de Integración (Nivel Medio)

**Framework:** Spring Boot Test + H2 Database + TestRestTemplate

**Configuración:**
- Base de datos H2 en memoria (`MODE=MySQL`)
- Flyway deshabilitado en perfil `test`
- Spring Cloud Config deshabilitado
- Puerto aleatorio (`webEnvironment = RANDOM_PORT`)

**Ventajas:**
- ✅ Valida contratos REST reales
- ✅ Prueba serialización/deserialización JSON
- ✅ Bajo consumo de recursos (sin Docker/MySQL)
- ✅ Isolation entre tests (`@DirtiesContext`)

**Configuración (`application.yml` de pruebas):**
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb;MODE=MySQL
  jpa:
    hibernate:
      ddl-auto: create-drop
  flyway:
    enabled: false
  cloud:
    config:
      enabled: false
```

### 1.3 Pruebas E2E Ligeras (Cima de la Pirámide)

**Framework:** MockMvc + TestRestTemplate

**Estrategia:**
- Tests de flujo completo dentro del mismo contexto Spring
- Sin levantar Docker Compose completo (ahorro de ~2GB RAM)
- Validación de endpoints HTTP sin infraestructura externa

**Limitaciones Aceptadas:**
- ❌ No prueba Eureka Discovery real
- ❌ No prueba API Gateway routing
- ❌ Foreign Key constraints en H2 (aceptable en test)

**Justificación FinOps:**
En lugar de levantar 10 contenedores Docker (Eureka, Config Server, Gateway, MySQL, Zipkin, etc.) consumiendo ~4GB RAM, se opta por pruebas E2E "ligeras" que validan los contratos REST y la lógica de negocio sin la sobrecarga de infraestructura completa.

---

## ⚡ 2. Estrategia de Performance: Smoke Test Distribuido

### 2.1 Decisión Arquitectónica: ¿Por qué NO Stress Testing?

**Contexto:**
- Infraestructura: Azure Student Tier (recursos limitados)
- Presupuesto: Crédito estudiantil limitado ($100 USD/año)
- Riesgo: Stress Testing agresivo puede saturar CPU y causar downtime

**Decisión:**
Se adoptó un **Smoke Test Distribuido** en lugar de Stress Testing masivo, siguiendo principios de **FinOps** (Financial Operations).

### 2.2 Implementación con Locust

**Herramienta:** Locust (Python-based load testing)

**Configuración Safe Mode:**
```python
class WebsiteUser(HttpUser):
    wait_time = between(1, 3)  # Espera 1-3s entre peticiones
    
    @task(3)
    def view_products(self):
        self.client.get("/product-service/api/products", verify=False)
    
    @task(1)
    def health_check(self):
        self.client.get("/product-service/actuator/health", verify=False)
```

**Parámetros de Ejecución:**
- **Usuarios:** 20 usuarios concurrentes (no 500+)
- **Spawn Rate:** 1 usuario/segundo (crecimiento gradual)
- **Duración:** 2 minutos (suficiente para detectar issues)
- **Wait Time:** 1-3 segundos entre peticiones

**Justificación FinOps:**
| Métrica | Stress Testing | Smoke Test (Nuestra Estrategia) |
|---------|---------------|----------------------------------|
| Usuarios concurrentes | 500-1000 | 20 |
| Duración | 10-30 min | 2 min |
| CPU Spike | >90% (riesgo throttling) | <50% |
| Costo estimado | ~$5-10/ejecución | <$0.10/ejecución |
| Riesgo de downtime | Alto | Bajo |

### 2.3 Objetivos del Smoke Test

✅ **Validar disponibilidad:** Endpoints responden HTTP 200  
✅ **Detectar memory leaks:** Monitorear uso de memoria durante 2 minutos  
✅ **Medir latencia base:** P50, P95, P99 bajo carga moderada  
✅ **Verificar health checks:** Actuator endpoints funcionan correctamente  

**No es objetivo:**
❌ Encontrar el punto de quiebre del sistema  
❌ Saturar todos los recursos disponibles  
❌ Simular Black Friday (10,000+ usuarios)  

---

## 🔒 3. Seguridad: DAST con OWASP ZAP

### 3.1 Escaneo Dinámico de Seguridad

**Herramienta:** OWASP ZAP (Zed Attack Proxy)

**Configuración:**
- **Target:** `http://4.239.160.144:8080/product-service`
- **Modo:** Spider + Active Scan
- **Policy:** Baseline (no invasivo)

**Vulnerabilidades Evaluadas:**
- SQL Injection
- XSS (Cross-Site Scripting)
- Security Headers (CSP, X-Frame-Options, HSTS)
- Exposed Actuator Endpoints
- Cookie Security (HttpOnly, Secure flags)

**Integración CI/CD:**
```yaml
- name: OWASP ZAP Scan
  uses: zaproxy/action-baseline@v0.7.0
  with:
    target: 'http://4.239.160.144:8080'
    rules_file_name: '.zap/rules.tsv'
    fail_action: true
```

### 3.2 Recomendaciones de Mitigación

| Vulnerabilidad | Severidad | Mitigación |
|----------------|-----------|------------|
| Actuator sin autenticación | 🟡 Media | Agregar Spring Security |
| CORS permisivo | 🟡 Media | Configurar allowedOrigins específicos |
| Headers faltantes | 🟢 Baja | Agregar Security Headers Filter |

---

## 🤖 4. Automatización: CI/CD con GitHub Actions

### 4.1 Pipeline de Quality Gates

**Workflow:** `.github/workflows/quality-gate.yml`

**Etapas:**
1. **Build & Test:** Compilación Maven + JUnit
2. **Coverage Check:** JaCoCo valida cobertura mínima (20%)
3. **SAST:** SonarCloud analiza código estático
4. **DAST:** OWASP ZAP escanea endpoints desplegados
5. **Performance:** Locust ejecuta smoke test

**Quality Gates:**
```yaml
- name: Maven Verify
  run: mvn -B clean verify
  
- name: JaCoCo Coverage Check
  run: mvn -B jacoco:check
  # Falla si cobertura < 20%
  
- name: SonarCloud Scan
  run: mvn -B sonar:sonar
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

### 4.2 Configuración de JaCoCo

**Umbral Mínimo:** 20% de cobertura (LINE + INSTRUCTION)

**Exclusiones:**
- Módulos de infraestructura (Eureka, Config Server, Gateway)
- Clases sin lógica de negocio (`*Application.class`)

**Configuración (`pom.xml`):**
```xml
<execution>
    <id>jacoco-check</id>
    <phase>verify</phase>
    <goals>
        <goal>check</goal>
    </goals>
    <configuration>
        <rules>
            <rule>
                <element>BUNDLE</element>
                <limits>
                    <limit>
                        <counter>LINE</counter>
                        <value>COVEREDRATIO</value>
                        <minimum>0.20</minimum>
                    </limit>
                </limits>
            </rule>
        </rules>
    </configuration>
</execution>
```

---

## 📊 5. Métricas y Reportes

### 5.1 Métricas de Calidad

| Métrica | Valor Actual | Objetivo |
|---------|--------------|----------|
| Cobertura de Código | 26-29% | 30% |
| Tests Unitarios | 11/11 ✅ | 100% pass |
| Tests Integración | 8/8 ✅ | 100% pass |
| Tests E2E | 3/3 ✅ | 100% pass |
| Latencia P95 (Locust) | TBD | <500ms |
| Disponibilidad | 99%+ | 99.9% |

### 5.2 Reportes Generados

**JaCoCo HTML Report:**
```
target/site/jacoco/index.html
```

**Locust Performance Report:**
```
performance_report.html
```

**OWASP ZAP Report:**
```
zap-report.html
```

---

## 🎯 6. Conclusiones y Mejores Prácticas

### 6.1 Lecciones Aprendidas

✅ **Shift-Left Testing:** Detectar bugs en etapas tempranas (unit tests) es 10x más barato que en producción  
✅ **FinOps:** Optimizar costos de nube mediante Smoke Tests en lugar de Stress Tests masivos  
✅ **Pragmatismo:** Aceptar limitaciones de infraestructura (FK constraints en H2) y validar lo esencial  
✅ **Automatización:** Quality Gates en CI/CD previenen regresiones  

### 6.2 Próximos Pasos

🔜 **Testcontainers:** Integrar MySQL real con Docker en tests de integración  
🔜 **Contract Testing:** Implementar Pact para validar contratos entre microservicios  
🔜 **Chaos Engineering:** Introducir fallos controlados (Circuit Breaker, Timeout)  
🔜 **APM:** Integrar New Relic/Dynatrace para monitoreo en producción  

---

## 📚 Referencias

- [Testing Pyramid - Martin Fowler](https://martinfowler.com/articles/practical-test-pyramid.html)
- [FinOps Foundation](https://www.finops.org/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Locust Documentation](https://docs.locust.io/)
- [JaCoCo Maven Plugin](https://www.jacoco.org/jacoco/trunk/doc/maven.html)

---

**Elaborado por:** Equipo de QA y DevOps  
**Fecha:** 27 de Noviembre de 2025  
**Versión:** 1.0

### Pipelines de Calidad (Quality Gates)
Se ha configurado un workflow de GitHub Actions (`quality-gate.yml`) que actúa como barrera de calidad, impidiendo el paso de código que no compile o falle en las pruebas unitarias.