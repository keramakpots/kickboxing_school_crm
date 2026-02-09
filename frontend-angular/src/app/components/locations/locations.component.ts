import { Component, OnInit } from '@angular/core';
import { ApiService } from '../../services/api.service';
import { Location } from '../../models/location.model';

@Component({
  selector: 'app-locations',
  standalone: true,
  template: `
    <h2>Siedziby</h2>

    <input [(ngModel)]="name" placeholder="Nazwa siedziby"/>
    <button (click)="add()">Dodaj</button>

    <ul>
      <li *ngFor="let l of locations">{{ l.name }}</li>
    </ul>
  `,
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
