package com.chotot.cho_tot_app.controller;

import com.chotot.cho_tot_app.entity.Cart;
import com.chotot.cho_tot_app.entity.Order;
import com.chotot.cho_tot_app.entity.User;
import com.chotot.cho_tot_app.repository.CartRepository;
import com.chotot.cho_tot_app.repository.OrderRepository;
import com.chotot.cho_tot_app.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
public class OrderController {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private CartRepository cartRepository;

    @Autowired
    private UserRepository userRepository;

    // Hàm bổ trợ để chuyển đổi Order sang Map (Tránh lỗi vòng lặp JSON 500)
    private Map<String, Object> mapToResponse(Order order) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", order.getId());
        map.put("totalPrice", order.getTotalPrice());
        map.put("status", order.getStatus());
        map.put("paymentMethod", order.getPaymentMethod());
        map.put("depositAmount", order.getDepositAmount());
        map.put("isDepositPaid", order.isDepositPaid());
        map.put("isSellerPaid", order.isSellerPaid());
        map.put("createdAt", order.getCreatedAt() != null ? order.getCreatedAt().toString() : "");
        
        Map<String, String> userMap = new HashMap<>();
        userMap.put("username", order.getUser() != null ? order.getUser().getUsername() : "Khách");
        map.put("user", userMap);
        
        return map;
    }

    @PostMapping("/create")
    public ResponseEntity<?> createOrder(@RequestBody Map<String, Object> payload) {
        try {
            Long userId = Long.valueOf(payload.get("userId").toString());
            String paymentMethod = payload.get("paymentMethod").toString();
            
            User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
            List<Cart> cartItems = cartRepository.findByUser(user);
            
            if (cartItems.isEmpty()) return ResponseEntity.badRequest().body("Giỏ hàng của bạn đang trống!");

            // Kiểm tra xem sản phẩm có người bán không
            User seller = cartItems.get(0).getProduct().getOwner();
            if (seller == null) {
                return ResponseEntity.badRequest().body("Lỗi: Sản phẩm này chưa được gán cho Người bán nào (Dữ liệu cũ). Vui lòng dùng tài khoản Seller đăng tin mới để test!");
            }

            BigDecimal total = cartItems.stream()
                    .map(item -> item.getProduct().getPrice().multiply(new BigDecimal(item.getQuantity())))
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            Order order = new Order();
            order.setUser(user);
            order.setSeller(seller);
            order.setTotalPrice(total);
            order.setPaymentMethod(paymentMethod);
            order.setStatus("PENDING");

            if ("BANK".equals(paymentMethod)) {
                order.setDepositAmount(total.multiply(new BigDecimal("0.2")));
                order.setDepositPaid(false);
            } else {
                order.setDepositAmount(BigDecimal.ZERO);
                order.setDepositPaid(true); // Pickup coi như xong cọc
            }
            
            Order savedOrder = orderRepository.save(order);
            cartRepository.deleteAll(cartItems);
            
            return ResponseEntity.ok(mapToResponse(savedOrder));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Lỗi hệ thống: " + e.getMessage());
        }
    }

    @GetMapping("/user/{userId}")
    public List<Map<String, Object>> getUserOrders(@PathVariable Long userId) {
        return orderRepository.findAllWithUsers().stream()
                .filter(o -> o.getUser() != null && o.getUser().getId().equals(userId))
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @GetMapping("/seller/{sellerId}")
    public List<Map<String, Object>> getSellerOrders(@PathVariable Long sellerId) {
        return orderRepository.findAllWithUsers().stream()
                .filter(o -> o.getSeller() != null && o.getSeller().getId().equals(sellerId))
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @GetMapping("/admin/all")
    public List<Map<String, Object>> getAllOrdersForAdmin() {
        return orderRepository.findAllWithUsers().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateOrderStatus(@PathVariable Long id, @RequestBody Map<String, String> payload) {
        try {
            String status = payload.get("status");
            Order order = orderRepository.findById(id).orElseThrow(() -> new RuntimeException("Order not found"));
            order.setStatus(status);
            return ResponseEntity.ok(mapToResponse(orderRepository.save(order)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PutMapping("/{id}/confirm-deposit")
    public ResponseEntity<?> confirmDeposit(@PathVariable Long id) {
        try {
            Order order = orderRepository.findById(id).orElseThrow(() -> new RuntimeException("Order not found"));
            order.setDepositPaid(true);
            return ResponseEntity.ok(mapToResponse(orderRepository.save(order)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PutMapping("/{id}/release-payout")
    public ResponseEntity<?> releasePayout(@PathVariable Long id) {
        try {
            Order order = orderRepository.findById(id).orElseThrow(() -> new RuntimeException("Order not found"));
            if (order.isSellerPaid()) return ResponseEntity.badRequest().body("Already paid");
            if (!"RECEIVED".equals(order.getStatus())) return ResponseEntity.badRequest().body("Order not completed");

            User seller = order.getSeller();
            if (seller != null) {
                seller.setBalance(seller.getBalance().add(order.getDepositAmount()));
                userRepository.save(seller);
                order.setSellerPaid(true);
            }
            return ResponseEntity.ok(mapToResponse(orderRepository.save(order)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
