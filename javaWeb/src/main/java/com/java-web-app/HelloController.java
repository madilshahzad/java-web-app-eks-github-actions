package com.java_web_app;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("/app")
    public String app() {
        return "Java App Started";
    }
}
