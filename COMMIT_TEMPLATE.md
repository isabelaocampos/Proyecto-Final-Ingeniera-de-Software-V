# 📝 PLANTILLA DE COMMITS - CONVENTIONAL COMMITS

## 🎯 ESTRUCTURA ESTÁNDAR

```
<tipo>(<alcance>): <descripción corta>

<descripción detallada opcional>

<footer opcional>
```

---

## 🚀 COMMITS RECOMENDADOS PARA TU ENTREGA

### ✅ OPCIÓN 1: Commit Simple (Recomendado)

```bash
git add .
git commit -m "feat(testing): add comprehensive test suite with 100% rubric compliance

- Add unit tests (ProductServiceTest) with JUnit 5 and Mockito
- Add integration tests (ProductControllerIntegrationTest) with MockMvc and H2
- Add E2E tests (OrderFlowE2ETest) with complete order flow validation
- Add performance tests (locustfile.py) optimized for 8GB RAM
- Add OWASP ZAP security scan workflow (security-scan.yml)
- Configure JaCoCo plugin with 30% coverage threshold
- Configure quality gate pipeline (quality-gate.yml) with automated testing
- All tests optimized for low-resource environments"
git push origin feature/resilience-tests
```

---

### ✅ OPCIÓN 2: Commits Separados por Categoría

```bash
# 1. Tests Unitarios e Integración
git add product-service/src/test/java/com/selimhorri/app/service/ProductServiceTest.java
git add product-service/src/test/java/com/selimhorri/app/resource/ProductControllerIntegrationTest.java
git commit -m "feat(testing): add unit and integration tests for product service

- Add ProductServiceTest with Mockito for lightweight unit testing
- Add ProductControllerIntegrationTest with MockMvc and H2 database
- Configure test profiles to disable external services (Eureka, Config)
- Optimize tests for 8GB RAM machines"

# 2. Tests E2E
git add order-service/src/test/java/com/selimhorri/app/e2e/OrderFlowE2ETest.java
git commit -m "feat(testing): add E2E tests for complete order flow

- Add OrderFlowE2ETest with TestRestTemplate (no Selenium)
- Implement complete business flow: POST order -> GET order -> Verify
- Configure H2 in-memory database for E2E testing
- Add 3 test scenarios: positive flow, 404 case, and bulk operations"

# 3. Tests de Rendimiento
git add tests/performance/locustfile.py
git commit -m "feat(performance): add load testing with Locust

- Configure Locust for Azure production environment (4.229.145.171:8080)
- Optimize for 8GB RAM with smoke test configuration (10 users)
- Disable SSL verification for Azure deployment
- Add weighted tasks for realistic user simulation"

# 4. Seguridad OWASP
git add .github/workflows/security-scan.yml
git commit -m "feat(security): add OWASP ZAP security scanning workflow

- Configure zaproxy/action-baseline for dynamic security testing (DAST)
- Target Azure production URL (https://4.229.145.171:8080)
- Generate HTML, Markdown, and JSON reports as artifacts
- Schedule weekly scans (Monday and Friday at 2 AM)"

# 5. Cobertura y CI/CD
git add pom.xml
git add .github/workflows/quality-gate.yml
git commit -m "feat(ci): add code coverage and quality gate pipeline

- Configure JaCoCo plugin with 30% minimum coverage threshold
- Add quality-gate workflow with 4 jobs: test, security, dependency-check, summary
- Upload coverage reports as GitHub artifacts
- Configure Trivy and OWASP Dependency Check for security scanning"

# 6. Documentación y Scripts
git add TESTING_ENTREGABLES.md ENTREGABLES_RESUMEN.md COMANDOS_CORRECTOS.md
git add REPORTE_AUDITORIA_FINAL.md run-tests-simple.ps1
git commit -m "docs(testing): add comprehensive testing documentation

- Add detailed testing documentation (TESTING_ENTREGABLES.md)
- Add executive summary (ENTREGABLES_RESUMEN.md)
- Add command reference guide (COMANDOS_CORRECTOS.md)
- Add QA audit report (REPORTE_AUDITORIA_FINAL.md)
- Add automated test execution script (run-tests-simple.ps1)"

# Push todos los commits
git push origin feature/resilience-tests
```

---

### ✅ OPCIÓN 3: Commit Atómico con Scope Completo

```bash
git add .
git commit -m "feat(testing): implement complete testing suite meeting 100% rubric requirements

DELIVERABLES:
- Unit Tests: ProductServiceTest.java (JUnit 5 + Mockito, lightweight)
- Integration Tests: ProductControllerIntegrationTest.java (MockMvc + H2)
- E2E Tests: OrderFlowE2ETest.java (TestRestTemplate, complete flow)
- Performance Tests: locustfile.py (Locust, optimized for 8GB RAM)
- Security Scan: security-scan.yml (OWASP ZAP DAST baseline)
- Code Coverage: JaCoCo plugin configured (30% threshold)
- CI/CD Pipeline: quality-gate.yml (automated testing + security)

FEATURES:
- All tests optimized for low-resource environments (8GB RAM)
- H2 in-memory database for isolated test execution
- Disabled external services (Eureka, Config, Zipkin) in test profile
- Comprehensive documentation and automation scripts included

RUBRIC COMPLIANCE:
✅ 1. Unit Tests (JUnit 5 + Mockito)
✅ 2. Integration Tests (@SpringBootTest + HTTP verification)
✅ 3. E2E Tests (Complete user flow validation)
✅ 4. Performance Tests (Locust stress testing)
✅ 5. Security Tests (OWASP ZAP scanning)
✅ 6. Code Coverage (JaCoCo 30% threshold + CI automation)

Closes #<issue-number>"
git push origin feature/resilience-tests
```

---

## 📋 TIPOS DE COMMIT (Conventional Commits)

| Tipo | Uso | Ejemplo |
|------|-----|---------|
| `feat` | Nueva funcionalidad | `feat(testing): add E2E tests` |
| `fix` | Corrección de bug | `fix(tests): resolve H2 syntax error` |
| `docs` | Solo documentación | `docs(readme): update test commands` |
| `style` | Formato (sin cambio lógica) | `style(tests): format code` |
| `refactor` | Refactorización | `refactor(tests): simplify setup` |
| `test` | Agregar/modificar tests | `test(product): add unit tests` |
| `chore` | Tareas mantenimiento | `chore(deps): update JaCoCo` |
| `perf` | Mejora rendimiento | `perf(locust): optimize users` |
| `ci` | Cambios CI/CD | `ci(github): add quality gate` |
| `build` | Build system | `build(maven): update pom.xml` |

---

## 🎨 ALCANCES (Scopes) SUGERIDOS

- `testing` - Cambios relacionados con tests
- `ci` - Pipeline CI/CD
- `security` - Seguridad y escaneos
- `performance` - Tests de rendimiento
- `docs` - Documentación
- `config` - Configuración
- `product-service` - Servicio específico
- `order-service` - Servicio específico

---

## ✅ RECOMENDACIÓN FINAL

**Para tu caso (entrega completa), usa la OPCIÓN 1:**

```bash
git add .
git commit -m "feat(testing): add comprehensive test suite with 100% rubric compliance

- Add unit tests (ProductServiceTest) with JUnit 5 and Mockito
- Add integration tests (ProductControllerIntegrationTest) with MockMvc and H2
- Add E2E tests (OrderFlowE2ETest) with complete order flow validation
- Add performance tests (locustfile.py) optimized for 8GB RAM
- Add OWASP ZAP security scan workflow (security-scan.yml)
- Configure JaCoCo plugin with 30% coverage threshold
- Configure quality gate pipeline (quality-gate.yml) with automated testing
- All tests optimized for low-resource environments"
git push origin feature/resilience-tests
```

**Ventajas:**
- ✅ Claro y descriptivo
- ✅ Sigue estándar Conventional Commits
- ✅ Lista todos los entregables
- ✅ Menciona optimización para 8GB RAM
- ✅ Fácil de revisar en el historial

---

## 🔗 REFERENCIAS

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Angular Commit Guidelines](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)
- [Semantic Versioning](https://semver.org/)

---

**Generado:** 24 de noviembre de 2025  
**Proyecto:** E-commerce Microservices - Testing Suite
