package com.example.myupconfigclient;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class MyupconfigClientApplication {

    public static void main(String[] args) {
        SpringApplication.run(MyupconfigClientApplication.class, args);
    }

}

@RefreshScope
@RestController
class MessageRestController {

    private final Configuration conf;

    @Autowired
    public MessageRestController(final Configuration conf) {
        this.conf = conf;
    }

    private String message;

    @RequestMapping("/message")
    String getMessage() {
        return this.conf.getPwd();
    }
}

@Component
@ConfigurationProperties("app")
class Configuration {
    private String name;
    private String env;

    private String pwd;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEnv() {
        return env;
    }

    public void setEnv(String env) {
        this.env = env;
    }

    public String getPwd() {
        return pwd;
    }

    public void setPwd(String pwd) {
        this.pwd = pwd;
    }
}