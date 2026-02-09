package com.kickboxing.controller;

import com.kickboxing.service.EntryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/entries")
@RequiredArgsConstructor
public class EntryController {

    private final EntryService entryService;

    @PostMapping
    public ResponseEntity<?> addEntry(@RequestBody Map<String, String> req) throws Exception {
        entryService.registerEntry(
                req.get("participantId"),
                req.get("passId"),
                req.get("locationId")
        );
        return ResponseEntity.ok().build();
    }
}
