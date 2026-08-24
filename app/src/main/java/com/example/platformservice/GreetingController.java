package com.example.platformservice;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Map;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
class GreetingController {

	private static final String GREETING = "Hello from platform-service";

	/**
	 * Returns the greeting along with the hostname of the container that served
	 * it. The hostname is not decoration: with two tasks behind the load
	 * balancer, repeated calls return different values, which is the simplest
	 * way to show that traffic really is being spread across both.
	 */
	@GetMapping(value = "/", produces = MediaType.APPLICATION_JSON_VALUE)
	Map<String, String> greeting() {
		return Map.of(
				"message", GREETING,
				"instance", hostname());
	}

	/**
	 * Health endpoint polled by the ALB target group.
	 *
	 * Deliberately trivial. It answers "is this process able to serve HTTP",
	 * which is the only question the load balancer needs answered before it
	 * sends traffic. Spring Boot Actuator would give richer checks and metrics,
	 * but it is another dependency and more exposed surface than this service
	 * currently justifies.
	 */
	@GetMapping(value = "/health", produces = MediaType.APPLICATION_JSON_VALUE)
	Map<String, String> health() {
		return Map.of("status", "ok");
	}

	private String hostname() {
		try {
			return InetAddress.getLocalHost().getHostName();
		} catch (UnknownHostException e) {
			return "unknown";
		}
	}

}
