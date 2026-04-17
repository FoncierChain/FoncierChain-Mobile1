import { Component, OnDestroy, ElementRef, ViewChild, inject, AfterViewInit } from '@angular/core';
import { LandService } from '../../services/land';
import * as L from 'leaflet';

@Component({
  selector: 'app-map-view',
  standalone: true,
  template: `
    <div class="flex flex-col h-full gap-4 animate-in fade-in duration-500">
      <header class="pt-4">
        <h1 class="text-2xl font-bold tracking-tight mb-2">Carte du Cadastre</h1>
        <p class="text-[#94A3B8] text-sm">Visualisez les zones sécurisées par FoncierChain en temps réel.</p>
      </header>

      <div class="flex-1 relative sophisticated-card overflow-hidden">
        <div #mapContainer id="map" class="z-0"></div>
        
        <!-- Map Legend Floating -->
        <div class="absolute bottom-4 left-4 bg-[#1A1C20]/90 backdrop-blur-md p-3 rounded-xl border border-white/10 z-10 flex flex-col gap-2 shadow-2xl">
          <div class="flex items-center gap-2">
            <div class="w-3 h-3 rounded-full bg-[#10B981]"></div>
            <span class="text-[10px] font-bold text-white uppercase tracking-wider">Sécurisé</span>
          </div>
          <div class="flex items-center gap-2">
            <div class="w-3 h-3 rounded-full bg-[#F59E0B]"></div>
            <span class="text-[10px] font-bold text-white uppercase tracking-wider">En Validation</span>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    :host { display: block; height: calc(100vh - 160px); }
  `]
})
export class MapView implements OnDestroy, AfterViewInit {
  @ViewChild('mapContainer') mapContainer!: ElementRef;
  private map?: L.Map;
  private landService = inject(LandService);

  ngAfterViewInit() {
    this.initMap();
    this.loadParcels();
  }

  private initMap() {
    // Brazzaville coordinates
    this.map = L.map(this.mapContainer.nativeElement, {
      center: [-4.2634, 15.2832],
      zoom: 13,
      zoomControl: false
    });

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors',
      className: 'map-tiles'
    }).addTo(this.map);
    
    // Add zoom control to top right instead of default top left
    L.control.zoom({ position: 'topright' }).addTo(this.map);
  }

  private loadParcels() {
    this.landService.watchAllParcels();
    
    // In a real app we would use polygons, but for this demo markers/circles are easier
    const parcels = [
      { id: 'BZV-POTO-001', lat: -4.2650, lng: 15.2850, owner: 'Jean-Paul Makosso', status: 'Validé' },
      { id: 'BZV-MOUN-042', lat: -4.2580, lng: 15.2750, owner: 'Marie Ngosso', status: 'Validé' },
      { id: 'BZV-CENT-101', lat: -4.2700, lng: 15.2950, owner: 'Société IMMO-CG', status: 'En Validation' },
    ];

    parcels.forEach(p => {
      const color = p.status === 'Validé' ? '#10B981' : '#F59E0B';
      const circle = L.circle([p.lat, p.lng], {
        color: color,
        fillColor: color,
        fillOpacity: 0.5,
        radius: 150
      }).addTo(this.map!);

      circle.bindPopup(`
        <div style="color: #0F1115; font-family: sans-serif; min-width: 150px">
          <h4 style="font-weight: 700; margin: 0 0 4px 0">${p.id}</h4>
          <p style="font-size: 11px; margin: 0 0 8px 0; color: #64748B">Proprio: <b>${p.owner}</b></p>
          <div style="background: ${color}; color: white; display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 9px; font-weight: 700; text-transform: uppercase">
            ${p.status}
          </div>
        </div>
      `);
    });
  }

  ngOnDestroy() {
    if (this.map) {
      this.map.remove();
    }
  }
}
