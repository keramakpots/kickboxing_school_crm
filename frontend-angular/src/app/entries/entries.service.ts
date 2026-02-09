import { Injectable } from '@angular/core';
import { ApiService } from '../core/api.service';

@Injectable({ providedIn: 'root' })
export class EntriesService {
  constructor(private api: ApiService) {}

  registerEntry(data: any) {
    return this.api.post('entries', data);
  }
}
