import { Component, OnInit } from '@angular/core';
import { ApiService } from '../../services/api.service';
import { Participant } from '../../models/participant.model';
import { Location } from '../../models/location.model';

@Component({
  selector: 'app-participants',
  standalone: true,
  template: `
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
  `,
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
