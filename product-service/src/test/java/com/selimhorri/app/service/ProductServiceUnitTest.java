package com.selimhorri.app.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.selimhorri.app.domain.Product;
import com.selimhorri.app.dto.CategoryDto;
import com.selimhorri.app.dto.ProductDto;
import com.selimhorri.app.exception.wrapper.ProductNotFoundException;
import com.selimhorri.app.repository.ProductRepository;
import com.selimhorri.app.service.impl.ProductServiceImpl;

/**
 * Pruebas Unitarias Puras para ProductService
 * 
 * Características:
 * - No carga contexto de Spring (@ExtendWith(MockitoExtension.class))
 * - Usa Mockito para simular dependencias
 * - Ejecución rápida y ligera
 * - Cobertura de código con JaCoCo
 * 
 * @author QA Team
 * @version 1.0
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("ProductService - Unit Tests (Pure)")
class ProductServiceUnitTest {

    @Mock
    private ProductRepository productRepository;

    @InjectMocks
    private ProductServiceImpl productService;

    private Product product1;
    private Product product2;
    private ProductDto productDto1;
    private com.selimhorri.app.domain.Category category1;

    @BeforeEach
    void setUp() {
        // Preparar datos de prueba
        category1 = com.selimhorri.app.domain.Category.builder()
                .categoryId(1)
                .categoryTitle("Electronics")
                .build();

        product1 = Product.builder()
                .productId(1)
                .productTitle("Laptop Dell")
                .imageUrl("http://example.com/laptop.jpg")
                .sku("LAPTOP-001")
                .priceUnit(999.99)
                .quantity(10)
                .category(category1)
                .build();

        product2 = Product.builder()
                .productId(2)
                .productTitle("Mouse Logitech")
                .imageUrl("http://example.com/mouse.jpg")
                .sku("MOUSE-001")
                .priceUnit(29.99)
                .quantity(50)
                .category(category1)
                .build();

        productDto1 = ProductDto.builder()
                .productId(1)
                .productTitle("Laptop Dell")
                .imageUrl("http://example.com/laptop.jpg")
                .sku("LAPTOP-001")
                .priceUnit(999.99)
                .quantity(10)
                .categoryDto(CategoryDto.builder().categoryId(1).build())
                .build();
    }

    @Test
    @DisplayName("findAll() - Debe retornar lista de productos")
    void testFindAll_ShouldReturnProductList() {
        // Arrange
        when(productRepository.findAll()).thenReturn(Arrays.asList(product1, product2));

        // Act
        List<ProductDto> result = productService.findAll();

        // Assert
        assertNotNull(result, "La lista no debe ser nula");
        assertEquals(2, result.size(), "Debe retornar 2 productos");
        verify(productRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("findAll() - Debe retornar lista vacía cuando no hay productos")
    void testFindAll_ShouldReturnEmptyList_WhenNoProducts() {
        // Arrange
        when(productRepository.findAll()).thenReturn(Arrays.asList());

        // Act
        List<ProductDto> result = productService.findAll();

        // Assert
        assertNotNull(result);
        assertTrue(result.isEmpty(), "La lista debe estar vacía");
        verify(productRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("findById() - Debe retornar producto cuando existe")
    void testFindById_ShouldReturnProduct_WhenExists() {
        // Arrange
        when(productRepository.findById(1)).thenReturn(Optional.of(product1));

        // Act
        ProductDto result = productService.findById(1);

        // Assert
        assertNotNull(result);
        assertEquals(1, result.getProductId());
        assertEquals("Laptop Dell", result.getProductTitle());
        verify(productRepository, times(1)).findById(1);
    }

    @Test
    @DisplayName("findById() - Debe lanzar excepción cuando no existe")
    void testFindById_ShouldThrowException_WhenNotExists() {
        // Arrange
        when(productRepository.findById(999)).thenReturn(Optional.empty());

        // Act & Assert
        ProductNotFoundException exception = assertThrows(
            ProductNotFoundException.class,
            () -> productService.findById(999),
            "Debe lanzar ProductNotFoundException"
        );

        assertTrue(exception.getMessage().contains("999"));
        verify(productRepository, times(1)).findById(999);
    }

    @Test
    @DisplayName("save() - Debe guardar producto correctamente")
    void testSave_ShouldSaveProduct() {
        // Arrange
        when(productRepository.save(any(Product.class))).thenReturn(product1);

        // Act
        ProductDto result = productService.save(productDto1);

        // Assert
        assertNotNull(result);
        assertEquals("Laptop Dell", result.getProductTitle());
        verify(productRepository, times(1)).save(any(Product.class));
    }

    @Test
    @DisplayName("update() - Debe actualizar producto existente")
    void testUpdate_ShouldUpdateProduct() {
        // Arrange
        ProductDto updatedDto = ProductDto.builder()
                .productId(1)
                .productTitle("Laptop Dell XPS")
                .imageUrl("http://example.com/laptop-xps.jpg")
                .sku("LAPTOP-001")
                .priceUnit(1299.99)
                .quantity(5)
                .categoryDto(CategoryDto.builder().categoryId(1).build())
                .build();

        Product updatedProduct = Product.builder()
                .productId(1)
                .productTitle("Laptop Dell XPS")
                .imageUrl("http://example.com/laptop-xps.jpg")
                .sku("LAPTOP-001")
                .priceUnit(1299.99)
                .quantity(5)
                .category(category1)
                .build();

        when(productRepository.save(any(Product.class))).thenReturn(updatedProduct);

        // Act
        ProductDto result = productService.update(updatedDto);

        // Assert
        assertNotNull(result);
        assertEquals("Laptop Dell XPS", result.getProductTitle());
        assertEquals(1299.99, result.getPriceUnit());
        verify(productRepository, times(1)).save(any(Product.class));
    }

    @Test
    @DisplayName("deleteById() - Debe eliminar producto cuando existe")
    void testDeleteById_ShouldDeleteProduct_WhenExists() {
        // Arrange
        when(productRepository.findById(1)).thenReturn(Optional.of(product1));
        doNothing().when(productRepository).delete(any(Product.class));

        // Act
        productService.deleteById(1);

        // Assert
        verify(productRepository, times(1)).findById(1);
        verify(productRepository, times(1)).delete(any(Product.class));
    }

    @Test
    @DisplayName("deleteById() - Debe lanzar excepción cuando no existe")
    void testDeleteById_ShouldThrowException_WhenNotExists() {
        // Arrange
        when(productRepository.findById(999)).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(
            ProductNotFoundException.class,
            () -> productService.deleteById(999),
            "Debe lanzar ProductNotFoundException al intentar eliminar producto inexistente"
        );

        verify(productRepository, times(1)).findById(999);
        verify(productRepository, never()).delete(any(Product.class));
    }

    @Test
    @DisplayName("findAll() - Debe retornar productos sin duplicados")
    void testFindAll_ShouldReturnDistinctProducts() {
        // Arrange
        when(productRepository.findAll()).thenReturn(Arrays.asList(product1, product1, product2));

        // Act
        List<ProductDto> result = productService.findAll();

        // Assert
        assertNotNull(result);
        assertEquals(2, result.size(), "Debe eliminar duplicados y retornar 2 productos únicos");
        verify(productRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("save() - Debe manejar productos con precio cero")
    void testSave_ShouldHandleZeroPrice() {
        // Arrange
        Product freeProduct = Product.builder()
                .productId(3)
                .productTitle("Free Sample")
                .priceUnit(0.0)
                .quantity(100)
                .category(category1)
                .build();

        ProductDto freeProductDto = ProductDto.builder()
                .productId(3)
                .productTitle("Free Sample")
                .priceUnit(0.0)
                .quantity(100)
                .categoryDto(CategoryDto.builder().categoryId(1).build())
                .build();

        when(productRepository.save(any(Product.class))).thenReturn(freeProduct);

        // Act
        ProductDto result = productService.save(freeProductDto);

        // Assert
        assertNotNull(result);
        assertEquals(0.0, result.getPriceUnit());
        verify(productRepository, times(1)).save(any(Product.class));
    }
}
