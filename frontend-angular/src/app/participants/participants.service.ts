import { Injectable } from '@angular/core';
import { ApiService } from '../core/api.service';

@Injectable({ providedIn: 'root' })
export class ParticipantsService {
  constructor(private api: ApiService) {}

  getAll() {
    return this.api.get('participants');
  }

  add(data: any) {
    return this.api.post('participants', data);
  }
}
