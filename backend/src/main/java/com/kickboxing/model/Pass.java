package com.kickboxing.model;

import lombok.Data;

@Data
public class Pass {
    private String id;
    private String participantId;
    private int totalEntries;
    private int remainingEntries;
}
