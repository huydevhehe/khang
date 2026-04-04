package com.chotot.cho_tot_app.repository;

import com.chotot.cho_tot_app.entity.Cart;
import com.chotot.cho_tot_app.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface CartRepository extends JpaRepository<Cart, Long> {
    List<Cart> findByUser(User user);
    Optional<Cart> findByUserAndProductId(User user, Long productId);
    void deleteByUser(User user);
}
