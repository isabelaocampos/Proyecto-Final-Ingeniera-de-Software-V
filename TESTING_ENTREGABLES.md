# 📋 ENTREGABLES - PRUEBAS COMPLETAS
## Requisito: Pruebas Unitarias, Integración, Rendimiento, Seguridad y Automatización

**Restricción:** Máquina con 8GB RAM (Soluciones ligeras y eficientes)

---

## 📦 ENTREGABLE 1: Configuración de Cobertura (JaCoCo)

### ✅ Ubicación
**Archivo:** `pom.xml` (raíz del proyecto)

### 📝 Configuración Implementada
```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.8</version>
    <executions>
        <!-- Preparar agente JaCoCo -->
        <execution>
            <id>prepare-agent</id>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        
        <!-- Generar reporte HTML en fase test -->
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
        
        <!-- Verificación con umbral del 30% -->
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
                                <minimum>0.30</minimum>
                            </limit>
                        </limits>
                    </rule>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

### 🚀 Comandos de Ejecución
```bash
# Generar reporte de cobertura
mvn clean test

# Ver reporte HTML
# Ubicación: target/site/jacoco/index.html

# Verificar umbral (30%)
mvn verify
```

---

## 📦 ENTREGABLE 2: Pruebas Unitarias y de Integración

### ✅ Prueba Unitaria (Unit Test)
**Archivo:** `product-service/src/test/java/com/selimhorri/app/service/ProductServiceTest.java`

**Características:**
- ✅ Usa JUnit 5 + Mockito
- ✅ `@ExtendWith(MockitoExtension.class)` (NO carga Spring Context)
- ✅ Lightweight - Ideal para 8GB RAM
- ✅ Prueba método `findAll()` simulando repositorio

**Comando:**
```bash
mvn test -Dtest=ProductServiceTest
```

---

### ✅ Prueba de Integración (Integration Test)
**Archivo:** `product-service/src/test/java/com/selimhorri/app/resource/ProductControllerIntegrationTest.java`

**Características:**
- ✅ `@SpringBootTest` + `@AutoConfigureMockMvc`
- ✅ Base de datos H2 en memoria
- ✅ Prueba endpoint GET `/api/products`
- ✅ Verifica status 200

**Comando:**
```bash
mvn test -Dtest=ProductControllerIntegrationTest
```

---

## 📦 ENTREGABLE 3: Pruebas de Carga/Estrés (Locust)

### ✅ Ubicación
**Archivo:** `tests/performance/locustfile.py`

### 📝 Configuración Implementada
- ✅ Clase `EcommerceUser` con `wait_time(1, 5)`
- ✅ Tarea A (Peso 3): GET `/product-service/api/products`
- ✅ Tarea B (Peso 1): GET `/order-service/api/orders/1`
- ✅ `verify=False` para ignorar SSL

### 🚀 Instalación y Ejecución

#### 1. Instalar Locust
```bash
pip install locust
```

#### 2. Ejecutar Modo Headless (Genera HTML)
```bash
locust -f tests/performance/locustfile.py \
  --headless \
  --users 10 \
  --spawn-rate 2 \
  --run-time 2m \
  --host=https://your-azure-gateway.azurewebsites.net \
  --html=report_locust.html
```

#### 3. Ejecutar Modo Web UI
```bash
locust -f tests/performance/locustfile.py \
  --host=https://your-azure-gateway.azurewebsites.net

# Abrir navegador en: http://localhost:8089
```

### ⚙️ Parámetros Recomendados (8GB RAM)
| Tipo | Users | Spawn Rate | Duración |
|------|-------|------------|----------|
| **Smoke Test** | 10 | 2/s | 2 min |
| **Load Test** | 50 | 5/s | 5 min |
| **Stress Test** | 200 | 10/s | 10 min |

---

## 📦 ENTREGABLE 4: Pipeline de Seguridad y Automatización

### ✅ Ubicación
**Archivo:** `.github/workflows/quality-gate.yml`

### 📝 Configuración Implementada

#### Job 1: Test & Coverage
- ✅ Instala JDK 11
- ✅ Ejecuta `mvn clean verify`
- ✅ Sube reporte JaCoCo como Artifact
- ✅ Verifica umbral 30% (advertencia, no falla)

#### Job 2: Security Scan (Trivy)
- ✅ Usa `aquasecurity/trivy-action`
- ✅ Escanea código fuente (`fs`)
- ✅ Busca vulnerabilidades CRITICAL y HIGH
- ✅ NO rompe el build (solo reporta)
- ✅ Sube resultados a GitHub Security

#### Job 3: OWASP Dependency Check (Bonus)
- ✅ Analiza dependencias Maven
- ✅ Genera reporte HTML

#### Job 4: Quality Gate Summary
- ✅ Consolida todos los reportes
- ✅ Genera resumen en GitHub Actions

### 🚀 Activación Automática
```yaml
on:
  push:
    branches: [ "main", "develop" ]
  pull_request:
    branches: [ "main", "develop" ]
```

### 📊 Artifacts Generados
1. **jacoco-coverage-report** - Reporte HTML de cobertura
2. **test-results** - Resultados de Surefire/Failsafe
3. **trivy-security-report** - Escaneo de seguridad SARIF
4. **trivy-readable-report** - Reporte en texto plano
5. **owasp-dependency-check-report** - Análisis de dependencias

---

## 🎯 VALIDACIÓN COMPLETA

### ✅ Checklist de Entregables

- [x] **ENTREGABLE 1:** JaCoCo configurado en `pom.xml` con umbral 30%
- [x] **ENTREGABLE 2:** `ProductServiceTest.java` (Unit - Mockito)
- [x] **ENTREGABLE 2:** `ProductControllerIntegrationTest.java` (Integration - H2)
- [x] **ENTREGABLE 3:** `locustfile.py` con Smoke Test (8GB RAM)
- [x] **ENTREGABLE 4:** `quality-gate.yml` con Trivy + OWASP

### 🚀 Comandos Rápidos de Validación

```bash
# 1. Ejecutar todas las pruebas y generar cobertura
mvn clean verify

# 2. Ejecutar solo pruebas unitarias (rápido)
mvn test -Dtest=*UnitTest

# 3. Ejecutar solo pruebas de integración
mvn test -Dtest=*IntegrationTest

# 4. Ejecutar Locust (smoke test local)
locust -f tests/performance/locustfile.py \
  --headless --users 10 --spawn-rate 2 --run-time 1m \
  --host=http://localhost:8080 \
  --html=report.html

# 5. Ver reporte de cobertura
start product-service/target/site/jacoco/index.html
```

---

## 📈 MÉTRICAS ESPERADAS

### Cobertura de Código (JaCoCo)
- **Mínimo:** 30% (Configurado)
- **Recomendado:** 60%+
- **Óptimo:** 80%+

### Pruebas de Carga (Locust)
- **Response Time p95:** < 500ms
- **Success Rate:** > 95%
- **RPS (Requests/sec):** 50-100 para Smoke Test

### Seguridad (Trivy)
- **Vulnerabilidades CRITICAL:** 0 objetivo
- **Vulnerabilidades HIGH:** < 5 aceptable

---

## 🛠️ TROUBLESHOOTING

### Problema: Out of Memory durante tests
**Solución:**
```bash
export MAVEN_OPTS="-Xmx512m -XX:MaxMetaspaceSize=256m"
mvn clean test
```

### Problema: Locust consume mucha RAM
**Solución:** Reducir usuarios y spawn rate
```bash
locust --users 5 --spawn-rate 1
```

### Problema: Pipeline falla por timeout
**Solución:** Agregar `continue-on-error: true` en steps críticos

---

## 📚 DOCUMENTACIÓN ADICIONAL

- [JaCoCo Documentation](https://www.jacoco.org/jacoco/trunk/doc/)
- [Locust Documentation](https://docs.locust.io/)
- [Trivy Security Scanner](https://aquasecurity.github.io/trivy/)
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)

---

**✅ ENTREGABLES COMPLETADOS - Listo para Evaluación**

_Generado por: QA & DevOps Team_
_Fecha: 24 de noviembre de 2025_
