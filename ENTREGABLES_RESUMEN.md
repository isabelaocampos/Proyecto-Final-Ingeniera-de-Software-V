# 🎯 ENTREGABLES - PRUEBAS COMPLETAS
## Soluciones Ligeras para Máquinas de 8GB RAM

```
╔════════════════════════════════════════════════════════════════════════╗
║                     ✅ 4 ENTREGABLES IMPLEMENTADOS                      ║
╚════════════════════════════════════════════════════════════════════════╝
```

---

## 📦 ENTREGABLE 1: Configuración de Cobertura (JaCoCo)

### 📍 Archivo
```
pom.xml (líneas 129-166)
```

### ✅ Configuración
- ✅ Plugin `jacoco-maven-plugin` v0.8.8
- ✅ Reporte HTML en `target/site/jacoco` durante fase `test`
- ✅ Regla con umbral del **30%** (advertencia, no falla)

### 🚀 Comandos
```bash
# Generar reporte
mvn clean test

# Verificar umbral
mvn verify

# Abrir reporte HTML
start product-service/target/site/jacoco/index.html
```

---

## 📦 ENTREGABLE 2: Pruebas Unitarias y de Integración

### 📍 Archivos Creados

#### 1️⃣ Prueba Unitaria (Lightweight - Sin Spring)
```
product-service/src/test/java/com/selimhorri/app/service/ProductServiceTest.java
```

**Características:**
- ✅ JUnit 5 + Mockito
- ✅ `@ExtendWith(MockitoExtension.class)`
- ✅ NO carga contexto Spring (rápido, bajo consumo)
- ✅ Prueba `findAll()` + 4 métodos más
- ✅ 5 tests con verificación de mocks

**Comando:**
```bash
mvn test -Dtest=ProductServiceTest
```

---

#### 2️⃣ Prueba de Integración (Con Spring Boot + H2)
```
product-service/src/test/java/com/selimhorri/app/resource/ProductControllerIntegrationTest.java
```

**Características:**
- ✅ `@SpringBootTest` + `@AutoConfigureMockMvc`
- ✅ Base de datos H2 en memoria
- ✅ Prueba GET `/api/products` con status 200
- ✅ 6 tests (GET, POST, PUT, DELETE)
- ✅ Desactiva Eureka/Config para reducir consumo

**Comando:**
```bash
mvn test -Dtest=ProductControllerIntegrationTest
```

---

## 📦 ENTREGABLE 3: Pruebas de Carga/Estrés (Locust)

### 📍 Archivo Actualizado
```
tests/performance/locustfile.py
```

### ✅ Configuración (Smoke Test para 8GB RAM)
- ✅ Clase `EcommerceUser` con `wait_time = between(1, 5)`
- ✅ **Tarea A (Peso 3):** GET `/product-service/api/products`
- ✅ **Tarea B (Peso 1):** GET `/order-service/api/orders/1`
- ✅ `verify = False` para ignorar SSL
- ✅ Logging mejorado con emojis

### 🚀 Instalación y Ejecución

```bash
# 1. Instalar Locust
pip install locust

# 2. SMOKE TEST (Recomendado - 8GB RAM)
locust -f tests/performance/locustfile.py --headless \
  --users 10 --spawn-rate 2 --run-time 2m \
  --host=https://your-azure-gateway.azurewebsites.net \
  --html=report_smoke_test.html

# 3. Modo Web UI
locust -f tests/performance/locustfile.py \
  --host=https://your-gateway.azurewebsites.net
# Abrir: http://localhost:8089
```

### 📊 Parámetros Recomendados
| Tipo | Users | Spawn Rate | Duración | RAM |
|------|-------|------------|----------|-----|
| Smoke | 10 | 2/s | 2 min | < 2GB |
| Load | 50 | 5/s | 5 min | < 4GB |
| Stress | 200 | 10/s | 10 min | > 8GB |

---

## 📦 ENTREGABLE 4: Pipeline de Seguridad y Automatización

### 📍 Archivo Creado
```
.github/workflows/quality-gate.yml
```

### ✅ Configuración

#### Activación Automática
```yaml
on:
  push:
    branches: [ "main", "develop" ]
  pull_request:
    branches: [ "main", "develop" ]
```

#### Job 1: Test & Coverage ✅
- ✅ Instala JDK 11 con cache Maven
- ✅ Ejecuta tests unitarios (lightweight)
- ✅ Ejecuta tests de integración (H2)
- ✅ Ejecuta `mvn clean verify`
- ✅ Sube reporte JaCoCo como artifact
- ✅ Verifica umbral 30% (no rompe build)

#### Job 2: Security Scan (Trivy) ✅
- ✅ Usa `aquasecurity/trivy-action@master`
- ✅ Escanea código fuente (`scan-type: fs`)
- ✅ Busca vulnerabilidades **CRITICAL** y **HIGH**
- ✅ `exit-code: 0` (NO rompe build, solo reporta)
- ✅ Sube resultados a GitHub Security (SARIF)
- ✅ Genera reporte human-readable (TXT)

#### Job 3: OWASP Dependency Check (Bonus) ✅
- ✅ Analiza dependencias Maven
- ✅ Genera reporte HTML + XML

#### Job 4: Quality Gate Summary ✅
- ✅ Consolida todos los reportes
- ✅ Genera resumen en GitHub Actions Summary

### 📦 Artifacts Generados
1. `jacoco-coverage-report` - Reporte HTML de cobertura
2. `test-results` - Resultados de Surefire/Failsafe
3. `trivy-security-report` - Escaneo de seguridad SARIF
4. `trivy-readable-report` - Reporte en texto plano
5. `owasp-dependency-check-report` - Análisis de dependencias

---

## ✅ VALIDACIÓN COMPLETA

### 🔍 Script de Validación
```bash
# Ejecutar script de validación (Linux/Mac)
chmod +x validate-entregables.sh
./validate-entregables.sh
```

### 📋 Checklist Manual
- [x] **ENTREGABLE 1:** JaCoCo en `pom.xml` con umbral 30%
- [x] **ENTREGABLE 2:** `ProductServiceTest.java` (Unit - Mockito)
- [x] **ENTREGABLE 2:** `ProductControllerIntegrationTest.java` (Integration - H2)
- [x] **ENTREGABLE 3:** `locustfile.py` actualizado (Smoke Test)
- [x] **ENTREGABLE 4:** `quality-gate.yml` con Trivy + OWASP

---

## 🚀 COMANDOS RÁPIDOS

```bash
# 1️⃣ Ejecutar TODAS las pruebas + cobertura
mvn clean verify

# 2️⃣ Solo pruebas unitarias (rápido)
mvn test -Dtest=*UnitTest,*ServiceTest

# 3️⃣ Solo pruebas de integración
mvn test -Dtest=*IntegrationTest,*ControllerIntegrationTest

# 4️⃣ Ver reporte de cobertura
start product-service/target/site/jacoco/index.html

# 5️⃣ Locust - Smoke Test local
locust -f tests/performance/locustfile.py --headless \
  --users 10 --spawn-rate 2 --run-time 1m \
  --host=http://localhost:8080 \
  --html=report.html

# 6️⃣ Commit y push para activar pipeline
git add .
git commit -m "feat: Implementar entregables de pruebas completas"
git push origin main
```

---

## 📊 MÉTRICAS ESPERADAS

### Cobertura (JaCoCo)
```
✅ Mínimo:     30% (configurado)
⭐ Recomendado: 60%+
🏆 Óptimo:     80%+
```

### Pruebas de Carga (Locust)
```
✅ Response Time p95:  < 500ms
✅ Success Rate:       > 95%
✅ RPS (Smoke Test):   50-100
```

### Seguridad (Trivy)
```
✅ Vulnerabilidades CRITICAL: 0 (objetivo)
✅ Vulnerabilidades HIGH:     < 5 (aceptable)
```

---

## 🎓 ESTRUCTURA DE ARCHIVOS

```
proyecto/
├── pom.xml                               # ENTREGABLE 1: JaCoCo
├── product-service/
│   └── src/test/java/com/selimhorri/app/
│       ├── service/
│       │   └── ProductServiceTest.java   # ENTREGABLE 2: Unit Test
│       └── resource/
│           └── ProductControllerIntegrationTest.java  # ENTREGABLE 2: Integration Test
├── tests/
│   └── performance/
│       └── locustfile.py                 # ENTREGABLE 3: Locust
├── .github/
│   └── workflows/
│       └── quality-gate.yml              # ENTREGABLE 4: Pipeline
├── TESTING_ENTREGABLES.md                # 📋 Documentación completa
└── validate-entregables.sh               # 🔍 Script de validación
```

---

## 💡 TIPS PARA 8GB RAM

### Durante Desarrollo
```bash
# Limitar memoria de Maven
export MAVEN_OPTS="-Xmx512m -XX:MaxMetaspaceSize=256m"

# Ejecutar solo tests unitarios (sin Spring)
mvn test -Dtest=*UnitTest

# Limpiar target periódicamente
mvn clean
```

### Durante Locust
```bash
# Empezar con pocos usuarios
locust --users 5 --spawn-rate 1

# Monitorear RAM
# Windows: Task Manager
# Linux/Mac: htop
```

### En GitHub Actions
```yaml
# Configuración ya optimizada en quality-gate.yml
env:
  MAVEN_OPTS: '-Xmx512m -XX:MaxMetaspaceSize=256m'
```

---

## 🎯 RESULTADO FINAL

```
╔════════════════════════════════════════════════════════════════╗
║         ✅ 4 ENTREGABLES COMPLETADOS Y DOCUMENTADOS             ║
║                                                                ║
║  📦 ENTREGABLE 1: JaCoCo configurado (30% threshold)           ║
║  📦 ENTREGABLE 2: Unit + Integration Tests (JUnit 5)           ║
║  📦 ENTREGABLE 3: Locust Smoke Test (8GB optimizado)           ║
║  📦 ENTREGABLE 4: GitHub Actions Pipeline (Trivy + OWASP)      ║
║                                                                ║
║             🎓 LISTO PARA EVALUACIÓN                           ║
╚════════════════════════════════════════════════════════════════╝
```

---

**📅 Fecha:** 24 de noviembre de 2025  
**👥 Autor:** QA & DevOps Team  
**📝 Documentación:** Ver `TESTING_ENTREGABLES.md` para detalles completos
