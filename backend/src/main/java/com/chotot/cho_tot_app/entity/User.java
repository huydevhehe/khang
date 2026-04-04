package com.chotot.cho_tot_app.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(nullable = false)
    private String password;

    private String fullName;

    private String role; // admin / seller / user

    // Shop Info
    private String shopName;
    private String shopAddress;
    private String shopStatus; // NONE, PENDING, APPROVED

    // Wallet Balance (For Sellers)
    private BigDecimal balance = BigDecimal.ZERO;

    // Bank Info (For Admin/Seller)
    private String bankName;
    private String accountNo;
    private String accountHolder;

    private LocalDateTime createdAt = LocalDateTime.now();
}
