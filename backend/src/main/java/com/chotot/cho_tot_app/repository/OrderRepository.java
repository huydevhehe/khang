package com.chotot.cho_tot_app.repository;

import com.chotot.cho_tot_app.entity.Order;
import com.chotot.cho_tot_app.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {
    @org.springframework.data.jpa.repository.Query("SELECT o FROM Order o JOIN FETCH o.user LEFT JOIN FETCH o.seller ORDER BY o.id DESC")
    List<Order> findAllWithUsers();

    List<Order> findByUserOrderByCreatedAtDesc(User user);
}
