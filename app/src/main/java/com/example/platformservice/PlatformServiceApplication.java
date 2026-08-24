package com.example.platformservice;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class PlatformServiceApplication {

	private static final Logger log = LoggerFactory.getLogger(PlatformServiceApplication.class);

	public static void main(String[] args) {
		SpringApplication.run(PlatformServiceApplication.class, args);
		log.info("platform-service started - GET / returns the greeting");
	}

}
