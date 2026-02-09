#!/bin/bash

BASE=backend/src/main/java/com/kickboxing

mkdir -p backend
mkdir -p $BASE/{config,controller,model,repository,service,security}

#################### pom.xml ####################
cat <<EOF > backend/pom.xml
<project>
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.kickboxing</groupId>
    <artifactId>backend</artifactId>
    <version>0.0.1</version>

    <properties>
        <java.version>17</java.version>
        <spring.boot.version>3.2.0</spring.boot.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>

        <dependency>
            <groupId>com.google.firebase</groupId>
            <artifactId>firebase-admin</artifactId>
            <version>9.2.0</version>
        </dependency>

        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt</artifactId>
            <version>0.9.1</version>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <scope>provided</scope>
        </dependency>
    </dependencies>
</project>
EOF

#################### Application ####################
cat <<EOF > $BASE/KickboxingApplication.java
package com.kickboxing;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class KickboxingApplication {
    public static void main(String[] args) {
        SpringApplication.run(KickboxingApplication.class, args);
    }
}
EOF

#################### FirebaseConfig ####################
cat <<EOF > $BASE/config/FirebaseConfig.java
package com.kickboxing.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.cloud.FirestoreClient;
import com.google.cloud.firestore.Firestore;
import jakarta.annotation.PostConstruct;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.FileInputStream;

@Configuration
public class FirebaseConfig {

    @PostConstruct
    public void init() throws Exception {
        FileInputStream serviceAccount =
                new FileInputStream("firebase-service-account.json");

        FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                .build();

        FirebaseApp.initializeApp(options);
    }

    @Bean
    public Firestore firestore() {
        return FirestoreClient.getFirestore();
    }
}
EOF

#################### SecurityConfig ####################
cat <<EOF > $BASE/config/SecurityConfig.java
package com.kickboxing.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .anyRequest().authenticated()
            )
            .httpBasic();

        return http.build();
    }
}
EOF

#################### MODELE ####################
cat <<EOF > $BASE/model/Participant.java
package com.kickboxing.model;

import lombok.Data;

@Data
public class Participant {
    private String id;
    private String firstName;
    private String lastName;
    private boolean active = true;
}
EOF

cat <<EOF > $BASE/model/Pass.java
package com.kickboxing.model;

import lombok.Data;

@Data
public class Pass {
    private String id;
    private String participantId;
    private int totalEntries;
    private int remainingEntries;
}
EOF

cat <<EOF > $BASE/model/Location.java
package com.kickboxing.model;

import lombok.Data;

@Data
public class Location {
    private String id;
    private String name;
}
EOF

cat <<EOF > $BASE/model/Entry.java
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
EOF

#################### SERVICE ####################
cat <<EOF > $BASE/service/EntryService.java
package com.kickboxing.service;

import com.kickboxing.model.Entry;
import com.kickboxing.model.Pass;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.Firestore;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class EntryService {

    private final Firestore firestore;

    public void registerEntry(String participantId, String passId, String locationId) throws Exception {

        DocumentReference passRef =
                firestore.collection("passes").document(passId);

        Pass pass = passRef.get().get().toObject(Pass.class);

        if (pass.getRemainingEntries() <= 0) {
            throw new RuntimeException("Brak wejść w karnecie");
        }

        pass.setRemainingEntries(pass.getRemainingEntries() - 1);
        passRef.set(pass);

        Entry entry = new Entry();
        entry.setId(UUID.randomUUID().toString());
        entry.setParticipantId(participantId);
        entry.setPassId(passId);
        entry.setLocationId(locationId);

        firestore.collection("entries")
                .document(entry.getId())
                .set(entry);
    }
}
EOF

#################### CONTROLLER ####################
cat <<EOF > $BASE/controller/EntryController.java
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
EOF

echo "✅ Backend wygenerowany w katalogu ./backend"
