package com.example.helloworld;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

@SpringBootTest
public class MainTests {

    @Autowired
    private Main.HelloController helloController;

    private MockMvc mockMvc;

    @Test
    public void contextLoads() {
        this.mockMvc = MockMvcBuilders.standaloneSetup(helloController).build();
        try {
            mockMvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/"))
                    .andExpect(MockMvcResultMatchers.status().isOk())
                    .andExpect(MockMvcResultMatchers.view().name("hello"));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
