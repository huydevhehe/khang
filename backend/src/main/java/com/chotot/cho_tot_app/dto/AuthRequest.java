package com.chotot.cho_tot_app.dto;

import lombok.Data;

@Data
public class AuthRequest {
    private String username;
    private String password;
    private String fullName; // Optional for login
}
