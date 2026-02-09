package com.kickboxing.model;

import lombok.Data;
import java.time.Instant;

@Data
public class Entry {
    private String id;
    private String participantId;
    private String passId;
    private String locationId;
    private Instant timestamp = Instant.now();
}
