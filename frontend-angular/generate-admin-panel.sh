#!/bin/bash

echo "🖥️ Generowanie panelu administracyjnego (MVP)..."

SRC=src/app

##################################
# MODELE
##################################
mkdir -p $SRC/models

cat <<EOF > $SRC/models/location.model.ts
export interface Location {
  id?: string;
  name: string;
}
EOF

cat <<EOF > $SRC/models/participant.model.ts
export interface Participant {
  id?: string;
  firstName: string;
  lastName: string;
  locationId: string;
}
EOF

cat <<EOF > $SRC/models/pass.model.ts
export interface Pass {
  id?: string;
  participantId: string;
  entries: number;
  validUntil: string;
}
EOF

##################################
# SERWIS API
##################################
mkdir -p $SRC/services

cat <<EOF > $SRC/services/api.service.ts
import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Location } from '../models/location.model';
import { Participant } from '../models/participant.model';
import { Pass } from '../models/pass.model';

@Injectable({ providedIn: 'root' })
export class ApiService {

  private baseUrl = 'http://localhost:8080/api';

  constructor(private http: HttpClient) {}

  // LOCATIONS
  getLocations() {
    return this.http.get<Location[]>(\`\${this.baseUrl}/locations\`);
  }

  addLocation(location: Location) {
    return this.http.post<Location>(\`\${this.baseUrl}/locations\`, location);
  }

  // PARTICIPANTS
  getParticipants() {
    return this.http.get<Participant[]>(\`\${this.baseUrl}/participants\`);
  }

  addParticipant(p: Participant) {
    return this.http.post<Participant>(\`\${this.baseUrl}/participants\`, p);
  }

  // PASSES
  addPass(pass: Pass) {
    return this.http.post<Pass>(\`\${this.baseUrl}/passes\`, pass);
  }
}
EOF

##################################
# KOMPONENT: LOCATIONS
##################################
mkdir -p $SRC/components/locations

cat <<EOF > $SRC/components/locations/locations.component.ts
import { Component, OnInit } from '@angular/core';
import { ApiService } from '../../services/api.service';
import { Location } from '../../models/location.model';

@Component({
  selector: 'app-locations',
  standalone: true,
  template: \`
    <h2>Siedziby</h2>

    <input [(ngModel)]="name" placeholder="Nazwa siedziby"/>
    <button (click)="add()">Dodaj</button>

    <ul>
      <li *ngFor="let l of locations">{{ l.name }}</li>
    </ul>
  \`,
  imports: []
})
export class LocationsComponent implements OnInit {

  locations: Location[] = [];
  name = '';

  constructor(private api: ApiService) {}

  ngOnInit() {
    this.api.getLocations().subscribe(r => this.locations = r);
  }

  add() {
    this.api.addLocation({ name: this.name })
      .subscribe(() => this.ngOnInit());
  }
}
EOF

##################################
# KOMPONENT: PARTICIPANTS
##################################
mkdir -p $SRC/components/participants

cat <<EOF > $SRC/components/participants/participants.component.ts
import { Component, OnInit } from '@angular/core';
import { ApiService } from '../../services/api.service';
import { Participant } from '../../models/participant.model';
import { Location } from '../../models/location.model';

@Component({
  selector: 'app-participants',
  standalone: true,
  template: \`
    <h2>Uczestnicy</h2>

    <input [(ngModel)]="firstName" placeholder="Imię"/>
    <input [(ngModel)]="lastName" placeholder="Nazwisko"/>

    <select [(ngModel)]="locationId">
      <option *ngFor="let l of locations" [value]="l.id">
        {{ l.name }}
      </option>
    </select>

    <button (click)="add()">Dodaj</button>

    <ul>
      <li *ngFor="let p of participants">
        {{ p.firstName }} {{ p.lastName }}
      </li>
    </ul>
  \`,
  imports: []
})
export class ParticipantsComponent implements OnInit {

  participants: Participant[] = [];
  locations: Location[] = [];

  firstName = '';
  lastName = '';
  locationId = '';

  constructor(private api: ApiService) {}

  ngOnInit() {
    this.api.getParticipants().subscribe(p => this.participants = p);
    this.api.getLocations().subscribe(l => this.locations = l);
  }

  add() {
    this.api.addParticipant({
      firstName: this.firstName,
      lastName: this.lastName,
      locationId: this.locationId
    }).subscribe(() => this.ngOnInit());
  }
}
EOF

##################################
# KOMPONENT: PASSES
##################################
mkdir -p $SRC/components/passes

cat <<EOF > $SRC/components/passes/passes.component.ts
import { Component, OnInit } from '@angular/core';
import { ApiService } from '../../services/api.service';
import { Participant } from '../../models/participant.model';

@Component({
  selector: 'app-passes',
  standalone: true,
  template: \`
    <h2>Karnety</h2>

    <select [(ngModel)]="participantId">
      <option *ngFor="let p of participants" [value]="p.id">
        {{ p.firstName }} {{ p.lastName }}
      </option>
    </select>

    <input type="number" [(ngModel)]="entries" placeholder="Ilość wejść"/>
    <input type="date" [(ngModel)]="validUntil"/>

    <button (click)="add()">Dodaj karnet</button>
  \`,
  imports: []
})
export class PassesComponent implements OnInit {

  participants: Participant[] = [];

  participantId = '';
  entries = 10;
  validUntil = '';

  constructor(private api: ApiService) {}

  ngOnInit() {
    this.api.getParticipants().subscribe(p => this.participants = p);
  }

  add() {
    this.api.addPass({
      participantId: this.participantId,
      entries: this.entries,
      validUntil: this.validUntil
    }).subscribe(() => alert('Karnet dodany'));
  }
}
EOF

##################################
# INFO
##################################
echo "✅ Panel admin MVP wygenerowany"
echo "⚠️ Upewnij się, że masz HttpClientModule i FormsModule w main.ts"
