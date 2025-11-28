# Script de ejecucion de tests
param(
    [ValidateSet("validate", "unit", "integration", "e2e", "coverage", "all")]
    [string]$TestType = "validate"
)

$projectRoot = $PSScriptRoot

Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host "  SCRIPT DE EJECUCION DE TESTS - E-COMMERCE" -ForegroundColor Cyan
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host ""

if ($TestType -eq "validate") {
    Write-Host "Validando entregables..." -ForegroundColor Yellow
    Write-Host ""
    
    $files = @(
        "pom.xml",
        "product-service\src\test\java\com\selimhorri\app\service\ProductServiceTest.java",
        "product-service\src\test\java\com\selimhorri\app\resource\ProductControllerIntegrationTest.java",
        "order-service\src\test\java\com\selimhorri\app\e2e\OrderFlowE2ETest.java",
        "tests\performance\locustfile.py",
        ".github\workflows\security-scan.yml",
        ".github\workflows\quality-gate.yml"
    )
    
    $count = 0
    foreach ($file in $files) {
        $fullPath = Join-Path $projectRoot $file
        if (Test-Path $fullPath) {
            Write-Host "[OK] $file" -ForegroundColor Green
            $count++
        } else {
            Write-Host "[FALTA] $file" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "Resultado: $count/$($files.Count) entregables encontrados" -ForegroundColor $(if ($count -eq $files.Count) { "Green" } else { "Yellow" })
    Write-Host ""
    
    if ($count -eq $files.Count) {
        Write-Host "Comandos disponibles:" -ForegroundColor Yellow
        Write-Host "  .\run-tests-simple.ps1 -TestType unit" -ForegroundColor White
        Write-Host "  .\run-tests-simple.ps1 -TestType integration" -ForegroundColor White
        Write-Host "  .\run-tests-simple.ps1 -TestType e2e" -ForegroundColor White
        Write-Host "  .\run-tests-simple.ps1 -TestType coverage" -ForegroundColor White
        Write-Host "  .\run-tests-simple.ps1 -TestType all" -ForegroundColor White
    }
}
elseif ($TestType -eq "unit") {
    Write-Host "Ejecutando tests unitarios..." -ForegroundColor Yellow
    Write-Host ""
    & .\mvnw.cmd -pl product-service test -Dtest=ProductServiceTest
}
elseif ($TestType -eq "integration") {
    Write-Host "Ejecutando tests de integracion..." -ForegroundColor Yellow
    Write-Host ""
    & .\mvnw.cmd -pl product-service test -Dtest=ProductControllerIntegrationTest
}
elseif ($TestType -eq "e2e") {
    Write-Host "Ejecutando tests E2E..." -ForegroundColor Yellow
    Write-Host ""
    & .\mvnw.cmd -pl order-service test -Dtest=OrderFlowE2ETest
}
elseif ($TestType -eq "coverage") {
    Write-Host "Generando cobertura JaCoCo..." -ForegroundColor Yellow
    Write-Host ""
    & .\mvnw.cmd -pl product-service clean verify
    
    $reportPath = Join-Path $projectRoot "product-service\target\site\jacoco\index.html"
    if (Test-Path $reportPath) {
        Write-Host ""
        Write-Host "Reporte generado en: $reportPath" -ForegroundColor Green
        Start-Process $reportPath
    }
}
elseif ($TestType -eq "all") {
    Write-Host "Ejecutando TODOS los tests..." -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "1/4 Tests unitarios..." -ForegroundColor Cyan
    & .\mvnw.cmd -pl product-service test -Dtest=ProductServiceTest
    
    Write-Host ""
    Write-Host "2/4 Tests de integracion..." -ForegroundColor Cyan
    & .\mvnw.cmd -pl product-service test -Dtest=ProductControllerIntegrationTest
    
    Write-Host ""
    Write-Host "3/4 Tests E2E..." -ForegroundColor Cyan
    & .\mvnw.cmd -pl order-service test -Dtest=OrderFlowE2ETest
    
    Write-Host ""
    Write-Host "4/4 Cobertura JaCoCo..." -ForegroundColor Cyan
    & .\mvnw.cmd -pl product-service clean verify
    
    Write-Host ""
    Write-Host "Ejecucion completa finalizada!" -ForegroundColor Green
}

Write-Host ""
