import {Routes} from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./pages/home/home').then(m => m.Home)
  },
  {
    path: 'verify',
    loadComponent: () => import('./pages/verify/verify').then(m => m.Verify)
  },
  {
    path: 'map',
    loadComponent: () => import('./pages/map-view/map-view').then(m => m.MapView)
  },
  {
    path: 'agent',
    loadComponent: () => import('./pages/agent/agent').then(m => m.Agent)
  }
];
