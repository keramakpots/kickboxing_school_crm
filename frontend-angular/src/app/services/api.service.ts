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
    return this.http.get<Location[]>(`${this.baseUrl}/locations`);
  }

  addLocation(location: Location) {
    return this.http.post<Location>(`${this.baseUrl}/locations`, location);
  }

  // PARTICIPANTS
  getParticipants() {
    return this.http.get<Participant[]>(`${this.baseUrl}/participants`);
  }

  addParticipant(p: Participant) {
    return this.http.post<Participant>(`${this.baseUrl}/participants`, p);
  }

  // PASSES
  addPass(pass: Pass) {
    return this.http.post<Pass>(`${this.baseUrl}/passes`, pass);
  }
}
