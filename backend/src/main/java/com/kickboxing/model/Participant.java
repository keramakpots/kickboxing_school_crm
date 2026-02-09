package com.kickboxing.model;

import lombok.Data;

@Data
public class Participant {
    private String id;
    private String firstName;
    private String lastName;
    private boolean active = true;
}
