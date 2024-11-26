package com.java_web_app.service;

import org.springframework.stereotype.Service;

@Service
public class HelloService {
    public String getGreeting() {
        return "Java Web App is Running!";
    }
}
