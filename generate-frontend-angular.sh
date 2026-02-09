#!/bin/bash

APP=frontend-angular

echo "📦 Tworzenie projektu Angular..."
ng new $APP --routing --style=scss --skip-tests --skip-git

cd $APP || exit 1

echo "📦 Dodawanie Angular Material..."
ng add @angular/material --theme=indigo-pink --typography --animations --skip-confirmation

echo "📁 Tworzenie modułów..."
ng g module auth --routing
ng g module participants --routing
ng g module passes --routing
ng g module locations --routing
ng g module entries --routing

echo "📁 Tworzenie komponentów..."
ng g component auth/login
ng g component participants/participant-list
ng g component passes/pass-list
ng g component locations/location-list
ng g component entries/entry-list
ng g component layout/navbar

echo "📁 Tworzenie serwisów..."
ng g service core/api
ng g service auth/auth
ng g service participants/participants
ng g service passes/passes
ng g service locations/locations
ng g service entries/entries

#################### API SERVICE ####################
cat <<EOF > src/app/core/api.service.ts
import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private baseUrl = 'http://localhost:8080/api';

  constructor(private http: HttpClient) {}

  get<T>(url: string) {
    return this.http.get<T>(\`\${this.baseUrl}/\${url}\`);
  }

  post<T>(url: string, body: any) {
    return this.http.post<T>(\`\${this.baseUrl}/\${url}\`, body);
  }
}
EOF

#################### PARTICIPANTS SERVICE ####################
cat <<EOF > src/app/participants/participants.service.ts
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
EOF

#################### PASSES SERVICE ####################
cat <<EOF > src/app/passes/passes.service.ts
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
EOF

#################### LOCATIONS SERVICE ####################
cat <<EOF > src/app/locations/locations.service.ts
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
EOF

#################### ENTRIES SERVICE ####################
cat <<EOF > src/app/entries/entries.service.ts
import { Injectable } from '@angular/core';
import { ApiService } from '../core/api.service';

@Injectable({ providedIn: 'root' })
export class EntriesService {
  constructor(private api: ApiService) {}

  registerEntry(data: any) {
    return this.api.post('entries', data);
  }
}
EOF

#################### ROUTING ####################
cat <<EOF > src/app/app-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

const routes: Routes = [
  { path: 'login', loadChildren: () => import('./auth/auth.module').then(m => m.AuthModule) },
  { path: 'participants', loadChildren: () => import('./participants/participants.module').then(m => m.ParticipantsModule) },
  { path: 'passes', loadChildren: () => import('./passes/passes.module').then(m => m.PassesModule) },
  { path: 'locations', loadChildren: () => import('./locations/locations.module').then(m => m.LocationsModule) },
  { path: 'entries', loadChildren: () => import('./entries/entries.module').then(m => m.EntriesModule) },
  { path: '', redirectTo: 'participants', pathMatch: 'full' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule {}
EOF

#################### NAVBAR ####################
cat <<EOF > src/app/layout/navbar/navbar.component.html
<mat-toolbar color="primary">
  <span>Kickboxing Admin</span>
  <span class="spacer"></span>
  <a mat-button routerLink="/participants">Uczestnicy</a>
  <a mat-button routerLink="/passes">Karnety</a>
  <a mat-button routerLink="/locations">Siedziby</a>
  <a mat-button routerLink="/entries">Wejścia</a>
</mat-toolbar>
EOF

cat <<EOF > src/app/layout/navbar/navbar.component.scss
.spacer {
  flex: 1 1 auto;
}
EOF

#################### APP COMPONENT ####################
cat <<EOF > src/app/app.component.html
<app-navbar></app-navbar>
<div class="container">
  <router-outlet></router-outlet>
</div>
EOF

echo "✅ Frontend Angular wygenerowany w ./frontend-angular"
