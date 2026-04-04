package com.chotot.cho_tot_app.service;

import com.chotot.cho_tot_app.dto.AuthRequest;
import com.chotot.cho_tot_app.entity.User;
import com.chotot.cho_tot_app.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    public User register(AuthRequest request) {
        if (userRepository.findByUsername(request.getUsername()).isPresent()) {
            throw new RuntimeException("Username already exists!");
        }
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(request.getPassword()); // Plain text for demo
        user.setFullName(request.getFullName());
        user.setRole("user"); // Default role
        return userRepository.save(user);
    }

    public User login(AuthRequest request) {
        Optional<User> userOpt = userRepository.findByUsername(request.getUsername());
        if (userOpt.isPresent() && userOpt.get().getPassword().equals(request.getPassword())) {
            return userOpt.get();
        }
        throw new RuntimeException("Invalid username or password!");
    }
}
