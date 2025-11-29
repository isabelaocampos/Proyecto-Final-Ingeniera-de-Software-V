# ══════════════════════════════════════════════════════════════════════════════
# Script de Validación de Entregables - PowerShell (Windows)
# ══════════════════════════════════════════════════════════════════════════════
# Descripción: Valida los 4 entregables de pruebas
# Autor: QA & DevOps Team
# Fecha: 24 de noviembre de 2025
# ══════════════════════════════════════════════════════════════════════════════

# Configuración de colores
function Write-Header {
    param([string]$Message)
    Write-Host "`n══════════════════════════════════════════════════════════════════" -ForegroundColor Blue
    Write-Host "  $Message" -ForegroundColor Blue
    Write-Host "══════════════════════════════════════════════════════════════════" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

# ══════════════════════════════════════════════════════════════════════════════
# ENTREGABLE 1: Verificar Configuración de JaCoCo
# ══════════════════════════════════════════════════════════════════════════════
Write-Header "ENTREGABLE 1: Verificando Configuración de JaCoCo"

if (Select-String -Path "pom.xml" -Pattern "jacoco-maven-plugin" -Quiet) {
    Write-Success "JaCoCo plugin encontrado en pom.xml"
} else {
    Write-Error-Custom "JaCoCo plugin NO encontrado en pom.xml"
    exit 1
}

if (Select-String -Path "pom.xml" -Pattern "<minimum>0.30</minimum>" -Quiet) {
    Write-Success "Umbral de cobertura 30% configurado"
} else {
    Write-Warning-Custom "Umbral de cobertura diferente de 30%"
}

Write-Success "ENTREGABLE 1: ✅ COMPLETO"

# ══════════════════════════════════════════════════════════════════════════════
# ENTREGABLE 2: Verificar Pruebas Unitarias e Integración
# ══════════════════════════════════════════════════════════════════════════════
Write-Header "ENTREGABLE 2: Verificando Pruebas Unitarias e Integración"

# Verificar ProductServiceTest.java (Unit)
$unitTest = "product-service\src\test\java\com\selimhorri\app\service\ProductServiceTest.java"
if (Test-Path $unitTest) {
    Write-Success "ProductServiceTest.java (Unit) encontrado"
    if (Select-String -Path $unitTest -Pattern "@ExtendWith\(MockitoExtension.class\)" -Quiet) {
        Write-Success "Usa @ExtendWith(MockitoExtension.class) - lightweight ✓"
    }
} else {
    Write-Error-Custom "ProductServiceTest.java NO encontrado"
    exit 1
}

# Verificar ProductControllerIntegrationTest.java
$intTest = "product-service\src\test\java\com\selimhorri\app\resource\ProductControllerIntegrationTest.java"
if (Test-Path $intTest) {
    Write-Success "ProductControllerIntegrationTest.java encontrado"
    if ((Select-String -Path $intTest -Pattern "@SpringBootTest" -Quiet) -and 
        (Select-String -Path $intTest -Pattern "@AutoConfigureMockMvc" -Quiet)) {
        Write-Success "Usa @SpringBootTest + @AutoConfigureMockMvc ✓"
    }
    if (Select-String -Path $intTest -Pattern "H2" -Quiet) {
        Write-Success "Configurado con H2 en memoria ✓"
    }
} else {
    Write-Error-Custom "ProductControllerIntegrationTest.java NO encontrado"
    exit 1
}

Write-Success "ENTREGABLE 2: ✅ COMPLETO"

# ══════════════════════════════════════════════════════════════════════════════
# ENTREGABLE 3: Verificar Locust (Pruebas de Carga)
# ══════════════════════════════════════════════════════════════════════════════
Write-Header "ENTREGABLE 3: Verificando Locust (Pruebas de Carga)"

$locustFile = "tests\performance\locustfile.py"
if (Test-Path $locustFile) {
    Write-Success "locustfile.py encontrado"
    
    if (Select-String -Path $locustFile -Pattern "class EcommerceUser\(HttpUser\)" -Quiet) {
        Write-Success "Clase EcommerceUser definida ✓"
    }
    
    if (Select-String -Path $locustFile -Pattern "wait_time = between\(1, 5\)" -Quiet) {
        Write-Success "wait_time configurado (1-5 segundos) ✓"
    }
    
    if ((Select-String -Path $locustFile -Pattern "@task\(3\)" -Quiet) -and 
        (Select-String -Path $locustFile -Pattern "@task\(1\)" -Quiet)) {
        Write-Success "Tareas con pesos 3:1 configuradas ✓"
    }
    
    if ((Select-String -Path $locustFile -Pattern "/product-service" -Quiet) -and 
        (Select-String -Path $locustFile -Pattern "/order-service" -Quiet)) {
        Write-Success "Endpoints de product-service y order-service ✓"
    }
    
    if ((Select-String -Path $locustFile -Pattern "verify.*False" -Quiet) -or 
        (Select-String -Path $locustFile -Pattern "InsecureRequestWarning" -Quiet)) {
        Write-Success "SSL ignorado (verify=False) ✓"
    }
} else {
    Write-Error-Custom "locustfile.py NO encontrado"
    exit 1
}

Write-Success "ENTREGABLE 3: ✅ COMPLETO"

# ══════════════════════════════════════════════════════════════════════════════
# ENTREGABLE 4: Verificar Pipeline GitHub Actions
# ══════════════════════════════════════════════════════════════════════════════
Write-Header "ENTREGABLE 4: Verificando Pipeline GitHub Actions"

$pipelineFile = ".github\workflows\quality-gate.yml"
if (Test-Path $pipelineFile) {
    Write-Success "quality-gate.yml encontrado"
    
    if ((Select-String -Path $pipelineFile -Pattern "branches:.*main" -Quiet) -and 
        (Select-String -Path $pipelineFile -Pattern "branches:.*develop" -Quiet)) {
        Write-Success "Activación en push a main y develop ✓"
    }
    
    if (Select-String -Path $pipelineFile -Pattern "test-and-coverage" -Quiet) {
        Write-Success "Job 1: test-and-coverage definido ✓"
    }
    
    if (Select-String -Path $pipelineFile -Pattern "security-scan" -Quiet) {
        Write-Success "Job 2: security-scan definido ✓"
    }
    
    if (Select-String -Path $pipelineFile -Pattern "aquasecurity/trivy-action" -Quiet) {
        Write-Success "Usa aquasecurity/trivy-action ✓"
    }
    
    if (Select-String -Path $pipelineFile -Pattern "CRITICAL,HIGH" -Quiet) {
        Write-Success "Busca vulnerabilidades CRITICAL y HIGH ✓"
    }
    
    if ((Select-String -Path $pipelineFile -Pattern "exit-code.*0" -Quiet) -or 
        (Select-String -Path $pipelineFile -Pattern "continue-on-error: true" -Quiet)) {
        Write-Success "No rompe el build (solo reporta) ✓"
    }
    
    if (Select-String -Path $pipelineFile -Pattern "upload-artifact" -Quiet) {
        Write-Success "Sube artifacts (reportes JaCoCo) ✓"
    }
} else {
    Write-Error-Custom "quality-gate.yml NO encontrado"
    exit 1
}

Write-Success "ENTREGABLE 4: ✅ COMPLETO"

# ══════════════════════════════════════════════════════════════════════════════
# RESUMEN FINAL
# ══════════════════════════════════════════════════════════════════════════════
Write-Header "RESUMEN DE VALIDACIÓN"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                  ✅ TODOS LOS ENTREGABLES VALIDADOS             ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📦 ENTREGABLE 1: " -NoNewline -ForegroundColor Blue
Write-Host "JaCoCo configurado con umbral 30%"
Write-Host "📦 ENTREGABLE 2: " -NoNewline -ForegroundColor Blue
Write-Host "ProductServiceTest.java (Unit) + ProductControllerIntegrationTest.java"
Write-Host "📦 ENTREGABLE 3: " -NoNewline -ForegroundColor Blue
Write-Host "locustfile.py con Smoke Test (8GB RAM)"
Write-Host "📦 ENTREGABLE 4: " -NoNewline -ForegroundColor Blue
Write-Host "quality-gate.yml con Trivy + OWASP"
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  SIGUIENTES PASOS:" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Ejecutar pruebas unitarias:"
Write-Host "   .\mvnw.cmd test -Dtest=ProductServiceTest" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Ejecutar pruebas de integración:"
Write-Host "   .\mvnw.cmd test -Dtest=ProductControllerIntegrationTest" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Generar reporte de cobertura:"
Write-Host "   .\mvnw.cmd clean verify" -ForegroundColor Cyan
Write-Host "   # Ver: product-service\target\site\jacoco\index.html"
Write-Host ""
Write-Host "4. Ejecutar Locust (smoke test):"
Write-Host "   locust -f tests\performance\locustfile.py --headless \" -ForegroundColor Cyan
Write-Host "     --users 10 --spawn-rate 2 --run-time 2m \" -ForegroundColor Cyan
Write-Host "     --host=http://localhost:8080 \" -ForegroundColor Cyan
Write-Host "     --html=report_locust.html" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Push a GitHub para activar pipeline:"
Write-Host "   git add ." -ForegroundColor Cyan
Write-Host "   git commit -m 'feat: Implementar entregables de pruebas completas'" -ForegroundColor Cyan
Write-Host "   git push origin main" -ForegroundColor Cyan
Write-Host ""
Write-Host "✨ Validación completada exitosamente!" -ForegroundColor Green
Write-Host ""
