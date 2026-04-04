package com.chotot.cho_tot_app.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "orders")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user; // Buyer

    @ManyToOne
    @JoinColumn(name = "seller_id")
    private User seller; // Seller

    private BigDecimal totalPrice;

    // PENDING, SHIPPING, RECEIVED, CANCELLED
    private String status; 

    // BANK, PICKUP
    private String paymentMethod; 

    // Escrow Fields
    private BigDecimal depositAmount = BigDecimal.ZERO;
    private boolean isDepositPaid = false;
    private boolean isSellerPaid = false; // When Admin releases deposit to Seller Wallet

    private LocalDateTime createdAt = LocalDateTime.now();
}
