import { Injectable } from '@angular/core';
import { ApiService } from '../core/api.service';

@Injectable({ providedIn: 'root' })
export class PassesService {
  constructor(private api: ApiService) {}

  getAll() {
    return this.api.get('passes');
  }

  add(data: any) {
    return this.api.post('passes', data);
  }
}
