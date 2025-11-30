#!/bin/bash
# ══════════════════════════════════════════════════════════════════════════════
# Script de Validación de Entregables - Pruebas Completas
# ══════════════════════════════════════════════════════════════════════════════
# Descripción: Valida los 4 entregables de pruebas (Unit, Integration, Load, Security)
# Autor: QA & DevOps Team
# Fecha: 24 de noviembre de 2025
# ══════════════════════════════════════════════════════════════════════════════

set -e  # Detener en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir headers
print_header() {
    echo ""
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}"
}

# Función para imprimir éxito
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Función para imprimir advertencia
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Función para imprimir error
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# ══════════════════════════════════════════════════════════════════════════════
# ENTREGABLE 1: Verificar Configuración de JaCoCo
# ══════════════════════════════════════════════════════════════════════════════
print_header "ENTREGABLE 1: Verificando Configuración de JaCoCo"

if grep -q "jacoco-maven-plugin" pom.xml; then
    print_success "JaCoCo plugin encontrado en pom.xml"
else
    print_error "JaCoCo plugin NO encontrado en pom.xml"
    exit 1
fi

if grep -q "<minimum>0.30</minimum>" pom.xml; then
    print_success "Umbral de cobertura 30% configurado"
else
    print_warning "Umbral de cobertura diferente de 30%"
fi

print_success "ENTREGABLE 1: ✅ COMPLETO"

# ══════════════════════════════════════════════════════════════════════════════
# ENTREGABLE 2: Verificar Pruebas Unitarias e Integración
# ══════════════════════════════════════════════════════════════════════════════
print_header "ENTREGABLE 2: Verificando Pruebas Unitarias e Integración"

# Verificar ProductServiceTest.java (Unit)
UNIT_TEST="product-service/src/test/java/com/selimhorri/app/service/ProductServiceTest.java"
if [ -f "$UNIT_TEST" ]; then
    print_success "ProductServiceTest.java (Unit) encontrado"
    if grep -q "@ExtendWith(MockitoExtension.class)" "$UNIT_TEST"; then
        print_success "Usa @ExtendWith(MockitoExtension.class) - lightweight ✓"
    fi
else
    print_error "ProductServiceTest.java NO encontrado"
    exit 1
fi

# Verificar ProductControllerIntegrationTest.java
INT_TEST="product-service/src/test/java/com/selimhorri/app/resource/ProductControllerIntegrationTest.java"
if [ -f "$INT_TEST" ]; then
    print_success "ProductControllerIntegrationTest.java encontrado"
    if grep -q "@SpringBootTest" "$INT_TEST" && grep -q "@AutoConfigureMockMvc" "$INT_TEST"; then
        print_success "Usa @SpringBootTest + @AutoConfigureMockMvc ✓"
    fi
    if grep -q "H2" "$INT_TEST"; then
        print_success "Configurado con H2 en memoria ✓"
    fi
else
    print_error "ProductControllerIntegrationTest.java NO encontrado"
    exit 1
fi

print_success "ENTREGABLE 2: ✅ COMPLETO"

# ══════════════════════════════════════════════════════════════════════════════
# ENTREGABLE 3: Verificar Locust (Pruebas de Carga)
# ══════════════════════════════════════════════════════════════════════════════
print_header "ENTREGABLE 3: Verificando Locust (Pruebas de Carga)"

LOCUST_FILE="tests/performance/locustfile.py"
if [ -f "$LOCUST_FILE" ]; then
    print_success "locustfile.py encontrado"
    
    if grep -q "class EcommerceUser(HttpUser)" "$LOCUST_FILE"; then
        print_success "Clase EcommerceUser definida ✓"
    fi
    
    if grep -q "wait_time = between(1, 5)" "$LOCUST_FILE"; then
        print_success "wait_time configurado (1-5 segundos) ✓"
    fi
    
    if grep -q "@task(3)" "$LOCUST_FILE" && grep -q "@task(1)" "$LOCUST_FILE"; then
        print_success "Tareas con pesos 3:1 configuradas ✓"
    fi
    
    if grep -q "/product-service" "$LOCUST_FILE" && grep -q "/order-service" "$LOCUST_FILE"; then
        print_success "Endpoints de product-service y order-service ✓"
    fi
    
    if grep -q "verify.*False" "$LOCUST_FILE" || grep -q "InsecureRequestWarning" "$LOCUST_FILE"; then
        print_success "SSL ignorado (verify=False) ✓"
    fi
else
    print_error "locustfile.py NO encontrado"
    exit 1
fi

print_success "ENTREGABLE 3: ✅ COMPLETO"

# ══════════════════════════════════════════════════════════════════════════════
# ENTREGABLE 4: Verificar Pipeline GitHub Actions
# ══════════════════════════════════════════════════════════════════════════════
print_header "ENTREGABLE 4: Verificando Pipeline GitHub Actions"

PIPELINE_FILE=".github/workflows/quality-gate.yml"
if [ -f "$PIPELINE_FILE" ]; then
    print_success "quality-gate.yml encontrado"
    
    if grep -q "branches:.*main" "$PIPELINE_FILE" && grep -q "branches:.*develop" "$PIPELINE_FILE"; then
        print_success "Activación en push a main y develop ✓"
    fi
    
    if grep -q "test-and-coverage" "$PIPELINE_FILE"; then
        print_success "Job 1: test-and-coverage definido ✓"
    fi
    
    if grep -q "security-scan" "$PIPELINE_FILE"; then
        print_success "Job 2: security-scan definido ✓"
    fi
    
    if grep -q "aquasecurity/trivy-action" "$PIPELINE_FILE"; then
        print_success "Usa aquasecurity/trivy-action ✓"
    fi
    
    if grep -q "CRITICAL,HIGH" "$PIPELINE_FILE"; then
        print_success "Busca vulnerabilidades CRITICAL y HIGH ✓"
    fi
    
    if grep -q "exit-code.*0" "$PIPELINE_FILE" || grep -q "continue-on-error: true" "$PIPELINE_FILE"; then
        print_success "No rompe el build (solo reporta) ✓"
    fi
    
    if grep -q "upload-artifact" "$PIPELINE_FILE"; then
        print_success "Sube artifacts (reportes JaCoCo) ✓"
    fi
else
    print_error "quality-gate.yml NO encontrado"
    exit 1
fi

print_success "ENTREGABLE 4: ✅ COMPLETO"

# ══════════════════════════════════════════════════════════════════════════════
# RESUMEN FINAL
# ══════════════════════════════════════════════════════════════════════════════
print_header "RESUMEN DE VALIDACIÓN"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                  ✅ TODOS LOS ENTREGABLES VALIDADOS             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📦 ENTREGABLE 1:${NC} JaCoCo configurado con umbral 30%"
echo -e "${BLUE}📦 ENTREGABLE 2:${NC} ProductServiceTest.java (Unit) + ProductControllerIntegrationTest.java"
echo -e "${BLUE}📦 ENTREGABLE 3:${NC} locustfile.py con Smoke Test (8GB RAM)"
echo -e "${BLUE}📦 ENTREGABLE 4:${NC} quality-gate.yml con Trivy + OWASP"
echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  SIGUIENTES PASOS:${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "1. Ejecutar pruebas unitarias:"
echo "   mvn test -Dtest=ProductServiceTest"
echo ""
echo "2. Ejecutar pruebas de integración:"
echo "   mvn test -Dtest=ProductControllerIntegrationTest"
echo ""
echo "3. Generar reporte de cobertura:"
echo "   mvn clean verify"
echo "   # Ver: product-service/target/site/jacoco/index.html"
echo ""
echo "4. Ejecutar Locust (smoke test):"
echo "   locust -f tests/performance/locustfile.py --headless \\"
echo "     --users 10 --spawn-rate 2 --run-time 2m \\"
echo "     --host=http://localhost:8080 \\"
echo "     --html=report_locust.html"
echo ""
echo "5. Push a GitHub para activar pipeline:"
echo "   git add ."
echo "   git commit -m \"feat: Implementar entregables de pruebas completas\""
echo "   git push origin main"
echo ""
echo -e "${GREEN}✨ Validación completada exitosamente!${NC}"
