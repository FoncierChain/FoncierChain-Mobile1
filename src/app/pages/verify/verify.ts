import { Component, ChangeDetectionStrategy, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { LandService, Parcel, HistoryItem } from '../../services/land';

@Component({
  selector: 'app-verify',
  standalone: true,
  imports: [CommonModule, FormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="flex flex-col gap-6 animate-in slide-in-from-bottom duration-500">
      <header class="pt-4">
        <h1 class="text-2xl font-bold tracking-tight mb-2">Vérification de Titre</h1>
        <p class="text-[#94A3B8] text-sm">Entrez l'ID cadastral national pour vérifier le propriétaire légal.</p>
      </header>

      <!-- Search Box -->
      <div class="sophisticated-card p-4">
        <div class="relative">
          <input 
            type="text" 
            [(ngModel)]="searchTerm"
            (keyup.enter)="search()"
            placeholder="ex: BZV-45785-SECURE"
            class="w-full dark-input py-4 pl-12 pr-4 text-sm font-medium tracking-wide">
          <span class="material-icons absolute left-4 top-1/2 -translate-y-1/2 text-[#C5A059]">search</span>
          <button 
            (click)="search()"
            class="absolute right-2 top-1/2 -translate-y-1/2 accent-button px-4 py-2 rounded-lg text-xs font-bold">
            VÉRIFIER
          </button>
        </div>
      </div>

      @if (loading()) {
        <div class="flex justify-center py-12">
          <div class="w-8 h-8 border-4 border-[#C5A059]/30 border-t-[#C5A059] rounded-full animate-spin"></div>
        </div>
      }

      @if (parcel(); as p) {
        <!-- Result Details -->
        <div class="sophisticated-card overflow-hidden animate-in fade-in duration-300">
          <div class="bg-gradient-to-r from-[#C5A059]/20 to-transparent p-6 border-b border-white/5">
            <div class="flex justify-between items-start">
              <div>
                <span class="text-[10px] font-bold text-[#C5A059] uppercase tracking-widest">Identifiant Parcelle</span>
                <h3 class="text-xl font-bold mt-1 tracking-tight">{{ p.id }}</h3>
              </div>
              <div class="bg-[#10B981]/10 text-[#10B981] px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wide border border-[#10B981]/20">
                Statut Sécurisé
              </div>
            </div>
          </div>
          
          <div class="p-6 flex flex-col gap-6">
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 rounded-2xl bg-[#C5A059]/10 flex items-center justify-center text-[#C5A059]">
                <span class="material-icons">person</span>
              </div>
              <div>
                <span class="text-[10px] text-[#94A3B8] uppercase font-bold tracking-wider">Propriétaire Actuel</span>
                <h4 class="text-base font-bold">{{ p.ownerName }}</h4>
              </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div class="p-4 bg-white/5 rounded-2xl border border-white/5">
                <span class="text-[10px] text-[#94A3B8] uppercase font-bold">Surface</span>
                <p class="text-sm font-bold mt-1">{{ p.surface }} m²</p>
              </div>
              <div class="p-4 bg-white/5 rounded-2xl border border-white/5">
                <span class="text-[10px] text-[#94A3B8] uppercase font-bold">Usage</span>
                <p class="text-sm font-bold mt-1">{{ p.usage }}</p>
              </div>
            </div>

            <div class="p-4 bg-white/5 rounded-2xl border border-white/5">
              <span class="text-[10px] text-[#94A3B8] uppercase font-bold">Adresse Complète</span>
              <p class="text-sm mt-1 text-slate-300 leading-relaxed">{{ p.address }}</p>
            </div>

            <!-- Hash Badge -->
            <div class="bg-[#0F1115] p-4 rounded-xl border border-white/10 flex items-center justify-between">
              <div class="flex items-center gap-3 overflow-hidden">
                <span class="material-icons text-[#C5A059] text-sm shrink-0">lock</span>
                <span class="text-[9px] font-mono text-[#94A3B8] truncate max-w-[150px]">{{ p.hash }}</span>
              </div>
              <span class="text-[8px] font-bold text-[#C5A059] uppercase whitespace-nowrap">Hash Certifié</span>
            </div>
          </div>
        </div>

        <!-- History Timeline -->
        <div class="flex flex-col gap-4 mb-12">
          <h3 class="text-xs font-bold text-[#C5A059] uppercase tracking-widest pl-2">Historique des Transactions</h3>
          
          @for (h of history(); track $index) {
             <div class="sophisticated-card p-4 relative border-l-2 border-[#C5A059]/30 ml-2">
                <div class="absolute -left-[7px] top-5 w-3 h-3 rounded-full bg-[#C5A059] border-2 border-[#0F1115]"></div>
                
                <div class="flex justify-between items-start mb-2">
                  <div class="flex flex-col">
                    <span class="text-[10px] text-[#94A3B8] font-bold uppercase tracking-tighter">{{ h.date | date:'dd MMM yyyy HH:mm' }}</span>
                    <span class="text-[9px] font-bold text-[#C5A059] bg-[#C5A059]/10 px-2 py-0.5 rounded mt-1 w-fit uppercase">{{ h.type || 'Mutation' }}</span>
                  </div>
                  <span class="text-[8px] text-[#94A3B8] font-mono bg-white/5 px-2 py-1 rounded">REF: {{ h.documentHash.slice(0, 8) }}</span>
                </div>

                <div class="grid grid-cols-1 gap-2 mt-4 bg-black/20 p-3 rounded-xl">
                  <div class="flex flex-col">
                    <span class="text-[9px] text-[#94A3B8] uppercase">Cédant / Origine</span>
                    <span class="text-xs font-semibold">{{ h.previousOwner }}</span>
                  </div>
                  <div class="flex items-center py-1">
                    <span class="material-icons text-xs text-[#C5A059]">south</span>
                  </div>
                  <div class="flex flex-col">
                    <span class="text-[9px] text-[#94A3B8] uppercase">Acquéreur</span>
                    <span class="text-xs font-bold text-[#C5A059]">{{ h.newOwner }}</span>
                  </div>
                </div>
             </div>
          } @empty {
            <div class="text-center py-8 sophisticated-card border-dashed border-white/5">
              <span class="material-icons text-2xl text-[#94A3B8]/20 mb-2">history</span>
              <p class="text-[#94A3B8] text-xs italic">Aucun transfert historique enregistré.</p>
            </div>
          }
        </div>
      } @else if (searched() && !parcel()) {
        <div class="text-center py-12">
          <span class="material-icons text-4xl text-[#94A3B8]/20 mb-4">error_outline</span>
          <p class="text-[#94A3B8] text-sm font-medium">Aucune parcelle trouvée.</p>
          <p class="text-[11px] text-[#C5A059]/60 mt-2">Vérifiez l'ID cadastral et réessayez.</p>
        </div>
      }
    </div>
  `
})
export class Verify {
  landService = inject(LandService);
  
  searchTerm = '';
  loading = signal(false);
  parcel = signal<Parcel | null>(null);
  history = signal<HistoryItem[]>([]);
  searched = signal(false);

  async search() {
    if (!this.searchTerm) return;
    
    this.loading.set(true);
    this.searched.set(true);
    
    try {
      const results = await this.landService.searchParcels(this.searchTerm.toUpperCase());
      if (results.length > 0) {
        const p = results[0];
        this.parcel.set(p);
        
        // Load history using the correct method name from LandService
        this.landService.getParcelHistory(p.id, (items) => {
          this.history.set(items);
        });
      } else {
        this.parcel.set(null);
        this.history.set([]);
      }
    } finally {
      this.loading.set(false);
    }
  }
}
