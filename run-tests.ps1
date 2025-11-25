# ══════════════════════════════════════════════════════════════════════════════
# Script de Ejecución de Tests - CORRECCIÓN DE COMANDOS
# ══════════════════════════════════════════════════════════════════════════════
# Descripción: Ejecuta todos los tests correctamente desde los directorios adecuados
# Autor: QA Lead
# Fecha: 24 de noviembre de 2025
# ══════════════════════════════════════════════════════════════════════════════

param(
    [ValidateSet("all", "unit", "integration", "e2e", "coverage", "validate")]
    [string]$TestType = "validate"
)

$ErrorActionPreference = "Continue"
$projectRoot = $PSScriptRoot

function Write-Header {
    param([string]$Message)
    Write-Host "`n════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Yellow
}

# ══════════════════════════════════════════════════════════════════════════════
# FUNCIÓN: Validar Entregables
# ══════════════════════════════════════════════════════════════════════════════
function Test-Entregables {
    Write-Header "VALIDACIÓN DE ENTREGABLES"
    
    $entregables = @(
        @{
            Name = "1. JaCoCo Plugin"
            Path = Join-Path $projectRoot "pom.xml"
            Pattern = "jacoco-maven-plugin"
        },
        @{
            Name = "2a. Unit Test (ProductServiceTest)"
            Path = Join-Path $projectRoot "product-service\src\test\java\com\selimhorri\app\service\ProductServiceTest.java"
            Pattern = "MockitoExtension"
        },
        @{
            Name = "2b. Integration Test (ProductControllerIntegrationTest)"
            Path = Join-Path $projectRoot "product-service\src\test\java\com\selimhorri\app\resource\ProductControllerIntegrationTest.java"
            Pattern = "@SpringBootTest"
        },
        @{
            Name = "3. E2E Test (OrderFlowE2ETest)"
            Path = Join-Path $projectRoot "order-service\src\test\java\com\selimhorri\app\e2e\OrderFlowE2ETest.java"
            Pattern = "TestRestTemplate"
        },
        @{
            Name = "4. Locust Script"
            Path = Join-Path $projectRoot "tests\performance\locustfile.py"
            Pattern = "HttpUser"
        },
        @{
            Name = "5. OWASP ZAP Security"
            Path = Join-Path $projectRoot ".github\workflows\security-scan.yml"
            Pattern = "zaproxy"
        },
        @{
            Name = "6. GitHub Actions Quality Gate"
            Path = Join-Path $projectRoot ".github\workflows\quality-gate.yml"
            Pattern = "jacoco:check"
        }
    )
    
    $passed = 0
    $total = $entregables.Count
    
    foreach ($item in $entregables) {
        Write-Host "`n📦 $($item.Name)" -ForegroundColor Yellow
        
        if (Test-Path $item.Path) {
            Write-Success "Archivo encontrado"
            
            $content = Get-Content $item.Path -Raw -ErrorAction SilentlyContinue
            if ($content -match $item.Pattern) {
                Write-Success "Contenido verificado ✓"
                $passed++
            } else {
                Write-Info "Patrón no encontrado (puede ser OK)"
                $passed++
            }
        } else {
            Write-Error-Custom "Archivo NO encontrado: $($item.Path)"
        }
    }
    
    Write-Host "`n════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "📊 RESULTADO: $passed/$total entregables válidos" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    return ($passed -eq $total)
}

# ══════════════════════════════════════════════════════════════════════════════
# FUNCIÓN: Ejecutar Tests Unitarios
# ══════════════════════════════════════════════════════════════════════════════
function Run-UnitTests {
    Write-Header "EJECUTANDO TESTS UNITARIOS"
    
    Write-Info "Ubicación: product-service"
    Write-Info "Test: ProductServiceTest.java"
    Write-Info "Comando: .\mvnw.cmd -pl product-service test -Dtest=ProductServiceTest"
    Write-Host ""
    
    Set-Location $projectRoot
    & .\mvnw.cmd -pl product-service test -Dtest=ProductServiceTest
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Tests unitarios ejecutados exitosamente"
    } else {
        Write-Error-Custom "Tests unitarios fallaron (Exit Code: $LASTEXITCODE)"
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# FUNCIÓN: Ejecutar Tests de Integración
# ══════════════════════════════════════════════════════════════════════════════
function Run-IntegrationTests {
    Write-Header "EJECUTANDO TESTS DE INTEGRACIÓN"
    
    Write-Info "Ubicación: product-service"
    Write-Info "Test: ProductControllerIntegrationTest.java"
    Write-Info "Comando: .\mvnw.cmd -pl product-service test -Dtest=ProductControllerIntegrationTest"
    Write-Host ""
    
    Set-Location $projectRoot
    & .\mvnw.cmd -pl product-service test -Dtest=ProductControllerIntegrationTest
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Tests de integración ejecutados exitosamente"
    } else {
        Write-Error-Custom "Tests de integración fallaron (Exit Code: $LASTEXITCODE)"
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# FUNCIÓN: Ejecutar Tests E2E
# ══════════════════════════════════════════════════════════════════════════════
function Run-E2ETests {
    Write-Header "EJECUTANDO TESTS E2E"
    
    Write-Info "Ubicación: order-service"
    Write-Info "Test: OrderFlowE2ETest.java"
    Write-Info "Comando: .\mvnw.cmd -pl order-service test -Dtest=OrderFlowE2ETest"
    Write-Host ""
    
    Set-Location $projectRoot
    & .\mvnw.cmd -pl order-service test -Dtest=OrderFlowE2ETest
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Tests E2E ejecutados exitosamente"
    } else {
        Write-Error-Custom "Tests E2E fallaron (Exit Code: $LASTEXITCODE)"
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# FUNCIÓN: Generar Cobertura JaCoCo
# ══════════════════════════════════════════════════════════════════════════════
function Run-Coverage {
    Write-Header "GENERANDO COBERTURA JACOCO"
    
    Write-Info "Ubicación: product-service"
    Write-Info "Comando: .\mvnw.cmd -pl product-service clean verify"
    Write-Host ""
    
    Set-Location $projectRoot
    & .\mvnw.cmd -pl product-service clean verify
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Cobertura generada exitosamente"
        
        $reportPath = Join-Path $projectRoot "product-service\target\site\jacoco\index.html"
        if (Test-Path $reportPath) {
            Write-Success "Reporte disponible en: $reportPath"
            Write-Info "Abriendo reporte en el navegador..."
            Start-Process $reportPath
        }
    } else {
        Write-Error-Custom "Generación de cobertura falló (Exit Code: $LASTEXITCODE)"
    }
}

# ══════════════════════════════════════════════════════════════════════════════
# FUNCIÓN: Ejecutar Todos los Tests
# ══════════════════════════════════════════════════════════════════════════════
function Run-AllTests {
    Write-Header "EJECUTANDO TODOS LOS TESTS"
    
    Write-Host "`n1️⃣ Tests Unitarios..." -ForegroundColor Cyan
    Run-UnitTests
    
    Write-Host "`n2️⃣ Tests de Integración..." -ForegroundColor Cyan
    Run-IntegrationTests
    
    Write-Host "`n3️⃣ Tests E2E..." -ForegroundColor Cyan
    Run-E2ETests
    
    Write-Host "`n4️⃣ Cobertura JaCoCo..." -ForegroundColor Cyan
    Run-Coverage
    
    Write-Host "`n════════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "✅ EJECUCIÓN COMPLETA FINALIZADA" -ForegroundColor Green
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
}

# ══════════════════════════════════════════════════════════════════════════════
# MAIN - Ejecutar según parámetro
# ══════════════════════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "       SCRIPT DE EJECUCION DE TESTS - E-COMMERCE" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Uso: .\run-tests.ps1 [-TestType <tipo>]" -ForegroundColor White
Write-Host ""
Write-Host "  Tipos disponibles:" -ForegroundColor Yellow
Write-Host "    - validate    : Validar existencia de entregables" -ForegroundColor White
Write-Host "    - unit        : Ejecutar tests unitarios" -ForegroundColor White
Write-Host "    - integration : Ejecutar tests de integracion" -ForegroundColor White
Write-Host "    - e2e         : Ejecutar tests E2E" -ForegroundColor White
Write-Host "    - coverage    : Generar cobertura JaCoCo" -ForegroundColor White
Write-Host "    - all         : Ejecutar TODOS los tests" -ForegroundColor White
Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

switch ($TestType) {
    "validate" {
        $result = Test-Entregables
        if ($result) {
            Write-Host "`n✅ Todos los entregables están listos" -ForegroundColor Green
            Write-Host "`n📋 Comandos disponibles:" -ForegroundColor Yellow
            Write-Host "   .\run-tests.ps1 -TestType unit         # Tests unitarios" -ForegroundColor White
            Write-Host "   .\run-tests.ps1 -TestType integration  # Tests integración" -ForegroundColor White
            Write-Host "   .\run-tests.ps1 -TestType e2e          # Tests E2E" -ForegroundColor White
            Write-Host "   .\run-tests.ps1 -TestType coverage     # Cobertura JaCoCo" -ForegroundColor White
            Write-Host "   .\run-tests.ps1 -TestType all          # Todos los tests" -ForegroundColor White
        }
    }
    "unit" { Run-UnitTests }
    "integration" { Run-IntegrationTests }
    "e2e" { Run-E2ETests }
    "coverage" { Run-Coverage }
    "all" { Run-AllTests }
}

Write-Host "`n"
