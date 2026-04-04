package com.chotot.cho_tot_app.controller;

import com.chotot.cho_tot_app.entity.User;
import com.chotot.cho_tot_app.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @PutMapping("/{id}/profile")
    public ResponseEntity<?> updateProfile(
            @PathVariable Long id,
            @RequestBody User updatedUser) {
        try {
            User user = userRepository.findById(id).orElseThrow(() -> new RuntimeException("User not found"));
            
            if (updatedUser.getFullName() != null) user.setFullName(updatedUser.getFullName());
            if (updatedUser.getBankName() != null) user.setBankName(updatedUser.getBankName());
            if (updatedUser.getAccountNo() != null) user.setAccountNo(updatedUser.getAccountNo());
            if (updatedUser.getAccountHolder() != null) user.setAccountHolder(updatedUser.getAccountHolder());
            
            return ResponseEntity.ok(userRepository.save(user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/{id}/request-shop")
    public ResponseEntity<?> requestShop(
            @PathVariable Long id,
            @RequestBody Map<String, String> payload) {
        try {
            User user = userRepository.findById(id).orElseThrow(() -> new RuntimeException("User not found"));
            user.setShopName(payload.get("shopName"));
            user.setShopAddress(payload.get("shopAddress"));
            user.setShopStatus("PENDING");
            return ResponseEntity.ok(userRepository.save(user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PutMapping("/{id}/approve-shop")
    public ResponseEntity<?> approveShop(@PathVariable Long id) {
        try {
            User user = userRepository.findById(id).orElseThrow(() -> new RuntimeException("User not found"));
            user.setShopStatus("APPROVED");
            user.setRole("seller");
            return ResponseEntity.ok(userRepository.save(user));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/pending-shops")
    public List<User> getPendingShops() {
        return userRepository.findAll().stream()
                .filter(u -> "PENDING".equals(u.getShopStatus()))
                .collect(Collectors.toList());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getUser(@PathVariable Long id) {
        return userRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/admin-info")
    public ResponseEntity<?> getAdminInfo() {
        return userRepository.findAll().stream()
                .filter(u -> "admin".equals(u.getRole()))
                .findFirst()
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
