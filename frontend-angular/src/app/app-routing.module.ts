import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

const routes: Routes = [
  { path: 'login', loadChildren: () => import('./auth/auth-module').then(m => m.AuthModule) },
  { path: 'participants', loadChildren: () => import('./participants/participants-module').then(m => m.ParticipantsModule) },
  { path: 'passes', loadChildren: () => import('./passes/passes-module').then(m => m.PassesModule) },
  { path: 'locations', loadChildren: () => import('./locations/locations-module').then(m => m.LocationsModule) },
  { path: 'entries', loadChildren: () => import('./entries/entries-module').then(m => m.EntriesModule) },
  { path: '', redirectTo: 'participants', pathMatch: 'full' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule {}
