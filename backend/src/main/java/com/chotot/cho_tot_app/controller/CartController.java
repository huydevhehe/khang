package com.chotot.cho_tot_app.controller;

import com.chotot.cho_tot_app.entity.Cart;
import com.chotot.cho_tot_app.entity.User;
import com.chotot.cho_tot_app.repository.CartRepository;
import com.chotot.cho_tot_app.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cart")
@CrossOrigin(origins = "*")
public class CartController {

    @Autowired
    private CartRepository cartRepository;

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/{userId}")
    public List<Cart> getCart(@PathVariable Long userId) {
        User user = userRepository.findById(userId).orElseThrow();
        return cartRepository.findByUser(user);
    }

    @PostMapping("/add")
    public Cart addToCart(@RequestBody Cart cart) {
        // Simple add logic
        User user = userRepository.findById(cart.getUser().getId()).orElseThrow();
        var existing = cartRepository.findByUserAndProductId(user, cart.getProduct().getId());
        if (existing.isPresent()) {
            Cart item = existing.get();
            item.setQuantity(item.getQuantity() + cart.getQuantity());
            return cartRepository.save(item);
        }
        cart.setUser(user);
        return cartRepository.save(cart);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> remove(@PathVariable Long id) {
        cartRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }
}
