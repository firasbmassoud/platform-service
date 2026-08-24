package com.example.platformservice;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(GreetingController.class)
class GreetingControllerTest {

	@Autowired
	private MockMvc mockMvc;

	@Test
	void returnsGreeting() throws Exception {
		mockMvc.perform(get("/"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.message").value("Hello from platform-service"))
				.andExpect(jsonPath("$.instance").exists());
	}

	// The load balancer takes this endpoint returning 200 as the signal to send
	// traffic to a task, so it is worth guarding against an accidental change.
	@Test
	void healthEndpointReportsOk() throws Exception {
		mockMvc.perform(get("/health"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.status").value("ok"));
	}

}
