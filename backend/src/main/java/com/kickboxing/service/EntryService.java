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
