# 🚀 GUÍA RÁPIDA DE EJECUCIÓN DE TESTS

## ❌ PROBLEMA IDENTIFICADO

**Error en tu última ejecución:**
```powershell
# ❌ INCORRECTO - Estabas en order-service intentando ejecutar ProductServiceTest
cd order-service
.\mvnw.cmd test -Dtest=ProductServiceTest
# Error: No tests were executed! (Exit Code: 1)
```

**Causa:** `ProductServiceTest` está en `product-service`, no en `order-service`.

---

## ✅ COMANDOS CORRECTOS

### 📋 OPCIÓN 1: Usar el Script Automatizado (RECOMENDADO)

```powershell
# Validar que todos los entregables existen
.\run-tests.ps1 -TestType validate

# Ejecutar tests unitarios
.\run-tests.ps1 -TestType unit

# Ejecutar tests de integración
.\run-tests.ps1 -TestType integration

# Ejecutar tests E2E
.\run-tests.ps1 -TestType e2e

# Generar cobertura JaCoCo
.\run-tests.ps1 -TestType coverage

# Ejecutar TODO (unit + integration + e2e + coverage)
.\run-tests.ps1 -TestType all
```

---

### 📋 OPCIÓN 2: Comandos Manuales Individuales

#### 1️⃣ Tests Unitarios (ProductServiceTest)

```powershell
# Desde la RAÍZ del proyecto
cd "C:\Users\LENOVO\Documents\Universidad\Octavo semestre\Ingesoft V\Proyecto Final\Proyecto-Final-Ingeniera-de-Software-V"
.\mvnw.cmd -pl product-service test -Dtest=ProductServiceTest
```

**O bien:**

```powershell
# Desde product-service directamente
cd "C:\Users\LENOVO\Documents\Universidad\Octavo semestre\Ingesoft V\Proyecto Final\Proyecto-Final-Ingeniera-de-Software-V\product-service"
..\mvnw.cmd test -Dtest=ProductServiceTest
```

#### 2️⃣ Tests de Integración (ProductControllerIntegrationTest)

```powershell
# Desde la RAÍZ del proyecto
cd "C:\Users\LENOVO\Documents\Universidad\Octavo semestre\Ingesoft V\Proyecto Final\Proyecto-Final-Ingeniera-de-Software-V"
.\mvnw.cmd -pl product-service test -Dtest=ProductControllerIntegrationTest
```

#### 3️⃣ Tests E2E (OrderFlowE2ETest)

```powershell
# Desde la RAÍZ del proyecto
cd "C:\Users\LENOVO\Documents\Universidad\Octavo semestre\Ingesoft V\Proyecto Final\Proyecto-Final-Ingeniera-de-Software-V"
.\mvnw.cmd -pl order-service test -Dtest=OrderFlowE2ETest
```

**O bien:**

```powershell
# Desde order-service directamente
cd "C:\Users\LENOVO\Documents\Universidad\Octavo semestre\Ingesoft V\Proyecto Final\Proyecto-Final-Ingeniera-de-Software-V\order-service"
..\mvnw.cmd test -Dtest=OrderFlowE2ETest
```

#### 4️⃣ Cobertura JaCoCo (con todos los tests)

```powershell
# Desde la RAÍZ del proyecto
cd "C:\Users\LENOVO\Documents\Universidad\Octavo semestre\Ingesoft V\Proyecto Final\Proyecto-Final-Ingeniera-de-Software-V"
.\mvnw.cmd -pl product-service clean verify

# El reporte HTML se genera en:
# product-service\target\site\jacoco\index.html
```

#### 5️⃣ Solo generar reporte JaCoCo (si ya ejecutaste tests)

```powershell
# Desde la RAÍZ del proyecto
cd "C:\Users\LENOVO\Documents\Universidad\Octavo semestre\Ingesoft V\Proyecto Final\Proyecto-Final-Ingeniera-de-Software-V"
.\mvnw.cmd -pl product-service jacoco:report
```

---

## 📊 ESTRUCTURA DE TESTS

```
Proyecto-Final-Ingeniera-de-Software-V/
│
├── product-service/
│   └── src/test/java/.../
│       ├── ProductServiceTest.java              ← Tests Unitarios
│       └── ProductControllerIntegrationTest.java ← Tests Integración
│
├── order-service/
│   └── src/test/java/.../
│       └── OrderFlowE2ETest.java                ← Tests E2E
│
└── tests/performance/
    └── locustfile.py                            ← Tests Rendimiento
```

---

## 🔍 VALIDACIÓN RÁPIDA

```powershell
# Verificar que todos los archivos existen
.\run-tests.ps1 -TestType validate

# O manualmente:
Get-ChildItem -Path "product-service\src\test\java" -Filter "*Test.java" -Recurse
Get-ChildItem -Path "order-service\src\test\java" -Filter "*Test.java" -Recurse
```

---

## 🎯 RECORDATORIO IMPORTANTE

| ❌ ERROR COMÚN | ✅ SOLUCIÓN |
|----------------|-------------|
| Ejecutar desde el directorio incorrecto | Siempre ejecutar desde la RAÍZ del proyecto |
| Usar `.\mvnw.cmd` en subdirectorios sin `-pl` | Usar `..\mvnw.cmd` o ir a la raíz primero |
| Confundir nombres de tests | ProductServiceTest → product-service<br>OrderFlowE2ETest → order-service |
| No especificar módulo con `-pl` | Siempre usar `-pl product-service` o `-pl order-service` |

---

## 🚨 TROUBLESHOOTING

### Problema: "No tests were executed"

**Causa:** Estás en el directorio equivocado o el test no existe en ese módulo.

**Solución:**
```powershell
# 1. Ir a la raíz del proyecto
cd "C:\Users\LENOVO\Documents\Universidad\Octavo semestre\Ingesoft V\Proyecto Final\Proyecto-Final-Ingeniera-de-Software-V"

# 2. Verificar ubicación actual
pwd

# 3. Ejecutar con -pl especificando el módulo correcto
.\mvnw.cmd -pl product-service test -Dtest=ProductServiceTest
```

### Problema: "BUILD FAILURE - compilation errors"

**Solución:**
```powershell
# Limpiar y compilar primero
.\mvnw.cmd clean compile

# Luego ejecutar tests
.\mvnw.cmd -pl product-service test
```

### Problema: H2 database errors en tests

**Solución:**
Los tests ya están configurados con H2 en memoria. Si falla:
```powershell
# Verificar que H2 está en las dependencias
Get-Content product-service\pom.xml | Select-String -Pattern "h2"
```

---

## 📦 ENTREGABLES COMPLETOS

✅ **ENTREGABLE 1:** JaCoCo Plugin en `pom.xml`  
✅ **ENTREGABLE 2a:** Unit Tests en `ProductServiceTest.java`  
✅ **ENTREGABLE 2b:** Integration Tests en `ProductControllerIntegrationTest.java`  
✅ **ENTREGABLE 3:** E2E Tests en `OrderFlowE2ETest.java`  
✅ **ENTREGABLE 4:** Locust Script en `locustfile.py`  
✅ **ENTREGABLE 5:** OWASP ZAP en `security-scan.yml`  
✅ **ENTREGABLE 6:** Quality Gate en `quality-gate.yml`  

---

## 🎉 EJECUCIÓN COMPLETA (TODO DE UNA VEZ)

```powershell
# Opción A: Con el script (MÁS FÁCIL)
.\run-tests.ps1 -TestType all

# Opción B: Manual (comando por comando)
.\mvnw.cmd -pl product-service test -Dtest=ProductServiceTest
.\mvnw.cmd -pl product-service test -Dtest=ProductControllerIntegrationTest
.\mvnw.cmd -pl order-service test -Dtest=OrderFlowE2ETest
.\mvnw.cmd -pl product-service clean verify
```

---

**✨ Usa el script `run-tests.ps1` para evitar errores de rutas!**
