import { Component, ChangeDetectionStrategy } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="flex flex-col gap-8 animate-in fade-in duration-700">
      <!-- Header -->
      <header class="pt-4">
        <div class="flex items-center justify-between mb-2">
          <h1 class="text-2xl font-bold tracking-tight">FoncierChain</h1>
          <div class="w-10 h-10 bg-[#C5A059] rounded-full flex items-center justify-center text-[#0F1115] font-bold">
            FC
          </div>
        </div>
        <p class="text-[#94A3B8] text-sm">République du Congo</p>
      </header>

      <!-- Hero Section -->
      <div class="sophisticated-card p-1">
        <img 
          src="https://picsum.photos/seed/brazzaville/800/450" 
          alt="Brazzaville" 
          class="w-full h-48 object-cover rounded-t-[19px] opacity-60"
          referrerpolicy="no-referrer">
        <div class="p-6">
          <h2 class="text-xl font-bold mb-3 leading-tight">Sécurisez votre patrimoine foncier à Brazzaville.</h2>
          <p class="text-sm text-[#94A3B8] leading-relaxed mb-6">
            Utilisez la technologie blockchain pour garantir l'immutabilité des titres de propriété et éliminer la double attribution.
          </p>
          <div class="flex gap-3">
            <button routerLink="/verify" class="flex-1 accent-button py-3 rounded-xl text-sm shadow-lg shadow-[#C5A059]/10">
              Vérifier un titre
            </button>
            <button routerLink="/map" class="flex-1 bg-[#2C2F36] text-white py-3 rounded-xl text-sm border border-white/5">
              Explorer la carte
            </button>
          </div>
        </div>
      </div>

      <!-- Stats Grid -->
      <div class="grid grid-cols-2 gap-4">
        <div class="sophisticated-card p-4 flex flex-col gap-1">
          <span class="material-icons text-[#10B981] text-lg">verified</span>
          <span class="text-xl font-bold mt-2">12,450+</span>
          <span class="text-[10px] text-[#94A3B8] uppercase tracking-wider font-bold">Parcelles Sécurisées</span>
        </div>
        <div class="sophisticated-card p-4 flex flex-col gap-1 text-[#C5A059]">
          <span class="material-icons text-lg">history</span>
          <span class="text-xl font-bold mt-2">100%</span>
          <span class="text-[10px] text-[#94A3B8] uppercase tracking-wider font-bold">Historique Immuable</span>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="flex flex-col gap-3">
        <span class="text-[11px] font-bold text-[#C5A059] uppercase tracking-[2px]">Actions Rapides</span>
        
        <a routerLink="/verify" class="sophisticated-card p-4 flex items-center justify-between group hover:bg-white/5 transition-colors">
          <div class="flex items-center gap-4">
            <div class="w-10 h-10 rounded-xl bg-[#C5A059]/10 flex items-center justify-center text-[#C5A059]">
              <span class="material-icons">search</span>
            </div>
            <div>
              <h4 class="text-sm font-bold">Validation Publique</h4>
              <p class="text-[11px] text-[#94A3B8]">Recherche par identifiant cadastral</p>
            </div>
          </div>
          <span class="material-icons text-[#94A3B8] group-hover:translate-x-1 transition-transform">chevron_right</span>
        </a>

        <a routerLink="/agent" class="sophisticated-card p-4 flex items-center justify-between group hover:bg-white/5 transition-colors">
          <div class="flex items-center gap-4">
            <div class="w-10 h-10 rounded-xl bg-[#C5A059]/10 flex items-center justify-center text-[#C5A059]">
              <span class="material-icons">security</span>
            </div>
            <div>
              <h4 class="text-sm font-bold">Portail Agent Certifié</h4>
              <p class="text-[11px] text-[#94A3B8]">Enregistrement et transferts légaux</p>
            </div>
          </div>
          <span class="material-icons text-[#94A3B8] group-hover:translate-x-1 transition-transform">chevron_right</span>
        </a>
      </div>
    </div>
  `
})
export class Home {}
