package com.example.demo;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {

    public List<User> getAllUsers() {
        // Mock service logic, replace with real database interaction
        return List.of(new User("John", "Doe"), new User("Jane", "Doe"));
    }

    public User createUser(User user) {
        // Mock service logic, replace with real database interaction
        return user;
    }
}
