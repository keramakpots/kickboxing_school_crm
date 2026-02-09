import { Component, OnInit } from '@angular/core';
import { ApiService } from '../../services/api.service';
import { Participant } from '../../models/participant.model';

@Component({
  selector: 'app-passes',
  standalone: true,
  template: `
    <h2>Karnety</h2>

    <select [(ngModel)]="participantId">
      <option *ngFor="let p of participants" [value]="p.id">
        {{ p.firstName }} {{ p.lastName }}
      </option>
    </select>

    <input type="number" [(ngModel)]="entries" placeholder="Ilość wejść"/>
    <input type="date" [(ngModel)]="validUntil"/>

    <button (click)="add()">Dodaj karnet</button>
  `,
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
