import { Injectable } from '@angular/core';
import { ApiService } from '../core/api.service';

@Injectable({ providedIn: 'root' })
export class LocationsService {
  constructor(private api: ApiService) {}

  getAll() {
    return this.api.get('locations');
  }

  add(data: any) {
    return this.api.post('locations', data);
  }
}
