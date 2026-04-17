import { Component, ChangeDetectionStrategy, inject, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { auth } from '../../firebase';
import { GoogleAuthProvider, signInWithPopup, signOut } from 'firebase/auth';
import { LandService, Parcel } from '../../services/land';

@Component({
  selector: 'app-agent',
  standalone: true,
  imports: [CommonModule, FormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="flex flex-col gap-6 animate-in slide-in-from-right-4 duration-500">
      <header class="flex items-center justify-between">
        <div>
          <h2 class="text-xl font-bold">Espace Agent Certifié</h2>
          <p class="text-sm text-[#94A3B8]">Portail de gestion du registre national immuable.</p>
        </div>
        @if (user()) {
          <button (click)="logout()" class="text-[#94A3B8] hover:text-white transition-colors">
            <span class="material-icons">logout</span>
          </button>
        }
      </header>

      @if (!user()) {
        <!-- Login View -->
        <div class="flex-1 flex flex-col items-center justify-center py-20 gap-8">
          <div class="w-20 h-20 bg-[#C5A059]/10 rounded-3xl flex items-center justify-center">
            <span class="material-icons text-[#C5A059] text-4xl">shield</span>
          </div>
          <div class="text-center">
            <h3 class="text-lg font-bold mb-2">Accès Sécurisé</h3>
            <p class="text-sm text-[#94A3B8] max-w-[250px]">Veuillez vous authentifier pour accéder au registre et valider des titres.</p>
          </div>
          <button 
            (click)="login()" 
            class="accent-button w-full py-4 rounded-2xl flex items-center justify-center gap-3 shadow-xl shadow-[#C5A059]/10">
            <span class="material-icons">google</span>
            Se connecter avec Google
          </button>
        </div>
      } @else if (profile()?.role === 'citizen') {
        <!-- Unauthorized View -->
        <div class="sophisticated-card p-8 bg-red-900/10 border-red-900/20 text-center flex flex-col items-center gap-4">
          <span class="material-icons text-red-400 text-4xl">gpp_maybe</span>
          <h3 class="text-lg font-bold">Accès Restreint</h3>
          <p class="text-sm text-red-100/70">Votre compte n'est pas autorisé à effectuer des modifications sur le registre foncier. Seuls les agents certifiés par le Ministère des Affaires Foncières peuvent enregistrer des parcelles.</p>
          <p class="text-[10px] text-red-500 font-bold uppercase tracking-widest mt-2">ID: {{ user()?.uid }}</p>
        </div>
      } @else {
        <!-- Agent Dashboard / Form -->
        <div class="flex flex-col gap-6">
          <div class="flex items-center gap-4 p-4 sophisticated-card bg-[#1A1C20]">
            <div class="w-12 h-12 rounded-xl bg-[#C5A059] flex items-center justify-center text-[#0F1115]">
              <span class="material-icons">person</span>
            </div>
            <div>
              <p class="text-[10px] font-bold text-[#C5A059] uppercase tracking-wider">Agent Connecté</p>
              <h4 class="text-sm font-bold text-white">{{ user()?.displayName }}</h4>
            </div>
          </div>

          <div class="flex flex-col gap-4">
            <span class="text-[11px] font-bold text-[#C5A059] uppercase tracking-widest pl-1 font-mono">Mutation de Titre</span>
            
            <div class="sophisticated-card p-6 flex flex-col gap-4 bg-gradient-to-br from-[#1A1C20] to-[#0F1115]">
              <div class="flex flex-col gap-2">
                <label for="transfer-parcel-id" class="text-[10px] font-bold uppercase text-[#94A3B8] px-1">ID Parcelle à Transférer</label>
                <div class="relative">
                  <input id="transfer-parcel-id" [(ngModel)]="transferForm.parcelId" type="text" placeholder="ex: BZV-45785-SECURE" class="dark-input p-3 pl-10 text-sm w-full">
                  <span class="material-icons absolute left-3 top-1/2 -translate-y-1/2 text-[16px] text-[#C5A059]">search</span>
                </div>
              </div>

              <div class="flex flex-col gap-2">
                <label for="transfer-type" class="text-[10px] font-bold uppercase text-[#94A3B8] px-1">Type de Transaction</label>
                <select id="transfer-type" [(ngModel)]="transferForm.type" class="dark-input p-3 text-sm appearance-none bg-[#1A1C20]">
                  <option value="Vente">Vente</option>
                  <option value="Donation">Donation</option>
                  <option value="Héritage">Héritage</option>
                  <option value="Mutation">Autre Mutation</option>
                </select>
              </div>

              <div class="flex flex-col gap-2">
                <label for="new-owner" class="text-[10px] font-bold uppercase text-[#94A3B8] px-1">Nouveau Propriétaire</label>
                <input id="new-owner" [(ngModel)]="transferForm.newOwner" type="text" placeholder="Nom complet de l'acquéreur..." class="dark-input p-3 text-sm">
              </div>

              <button 
                (click)="submitTransfer()"
                [disabled]="loadingTransfer"
                class="bg-white/5 hover:bg-white/10 border border-white/10 w-full py-4 rounded-xl mt-2 font-bold flex items-center justify-center gap-2 transition-all">
                <span class="material-icons text-lg text-[#C5A059]">swap_horiz</span>
                {{ loadingTransfer ? 'Traitement...' : 'Enregistrer la Mutation' }}
              </button>
            </div>
          </div>

          <div class="flex flex-col gap-4">
            <span class="text-[11px] font-bold text-[#C5A059] uppercase tracking-widest pl-1 font-mono">Nouvel Enregistrement</span>
            
            <div class="sophisticated-card p-6 flex flex-col gap-4">
              <div class="flex flex-col gap-2">
                <label for="parcel-id" class="text-[10px] font-bold uppercase text-[#94A3B8] px-1">ID de la Parcelle</label>
                <input id="parcel-id" [(ngModel)]="form.id" type="text" placeholder="ex: BZV-45785-SECURE" class="dark-input p-3 text-sm">
              </div>

              <div class="flex flex-col gap-2">
                <label for="owner-name" class="text-[10px] font-bold uppercase text-[#94A3B8] px-1">Nom du Propriétaire</label>
                <input id="owner-name" [(ngModel)]="form.ownerName" type="text" placeholder="Nom complet..." class="dark-input p-3 text-sm">
              </div>

              <div class="grid grid-cols-2 gap-4">
                <div class="flex flex-col gap-2">
                  <label for="parcel-surface" class="text-[10px] font-bold uppercase text-[#94A3B8] px-1">Superficie (m²)</label>
                  <input id="parcel-surface" [(ngModel)]="form.surface" type="number" class="dark-input p-3 text-sm">
                </div>
                <div class="flex flex-col gap-2">
                  <label for="parcel-usage" class="text-[10px] font-bold uppercase text-[#94A3B8] px-1">Usage</label>
                  <select id="parcel-usage" [(ngModel)]="form.usage" class="dark-input p-3 text-sm appearance-none bg-[#1A1C20]">
                    <option value="Résidentiel">Résidentiel</option>
                    <option value="Commercial">Commercial</option>
                  </select>
                </div>
              </div>

              <div class="flex flex-col gap-2">
                <label for="parcel-address" class="text-[10px] font-bold uppercase text-[#94A3B8] px-1">Adresse complète</label>
                <textarea id="parcel-address" [(ngModel)]="form.address" rows="2" class="dark-input p-3 text-sm"></textarea>
              </div>

              <!-- Digital Signature Mockup -->
              <div class="mt-4 p-4 bg-[#0F1115] rounded-xl border border-[#C5A059]/10">
                <div class="flex items-center gap-2 mb-2">
                  <span class="material-icons text-[#C5A059] text-xs">fingerprint</span>
                  <span class="text-[10px] text-[#C5A059] font-bold uppercase tracking-widest">Empreinte Cryptographique (HASH)</span>
                </div>
                <p class="font-mono text-[9px] text-[#94A3B8] truncate leading-none">
                  {{ generatingHash ? 'Génération en cours...' : 'SHA-256: ' + generatedHash }}
                </p>
              </div>

              <button 
                (click)="submit()"
                [disabled]="loadingSubmit"
                class="accent-button w-full py-4 rounded-xl mt-4 font-bold flex items-center justify-center gap-2">
                <span class="material-icons text-lg">verified</span>
                {{ loadingSubmit ? 'Enregistrement...' : "Valider l'Enregistrement Numérique" }}
              </button>
            </div>
          </div>
        </div>
      }
    </div>
  `
})
export class Agent {
  landService = inject(LandService);
  user = this.landService.user;
  profile = this.landService.profile;

  generatingHash = false;
  generatedHash = 'En attente de saisie...';
  loadingSubmit = false;
  loadingTransfer = false;

  transferForm = {
    parcelId: '',
    newOwner: '',
    type: 'Vente' as const
  };

  form: Partial<Parcel> = {
    id: '',
    ownerName: '',
    ownerId: 'ID-' + Math.floor(Math.random() * 1000000),
    surface: 0,
    usage: 'Résidentiel',
    address: '',
    coordinates: '[]',
    hash: ''
  };

  constructor() {
    effect(() => {
      // Stub hash generation based on form inputs
      if (this.form.id && this.form.ownerName) {
        this.generatedHash = btoa(this.form.id + this.form.ownerName + Date.now()).substring(0, 32);
        this.form.hash = this.generatedHash;
      }
    });
  }

  async login() {
    const provider = new GoogleAuthProvider();
    await signInWithPopup(auth, provider);
  }

  async logout() {
    await signOut(auth);
  }

  async submit() {
    if (!this.form.id || !this.form.ownerName) {
      alert('Veuillez remplir tous les champs obligatoires');
      return;
    }

    this.loadingSubmit = true;
    try {
      await this.landService.registerParcel(this.form as Parcel);
      alert('Parcelle enregistrée avec succès sur FoncierChain');
      this.resetForm();
    } catch (err) {
      console.error(err);
    } finally {
      this.loadingSubmit = false;
    }
  }

  async submitTransfer() {
    if (!this.transferForm.parcelId || !this.transferForm.newOwner) {
      alert('Veuillez remplir les informations de mutation');
      return;
    }

    this.loadingTransfer = true;
    try {
      const newHash = btoa(this.transferForm.parcelId + this.transferForm.newOwner + Date.now()).substring(0, 32);
      await this.landService.transferOwnership(
        this.transferForm.parcelId.toUpperCase(),
        this.transferForm.newOwner,
        'ID-' + Math.floor(Math.random() * 1000000),
        newHash,
        this.transferForm.type
      );
      alert('Mutation enregistrée avec succès');
      this.transferForm = { parcelId: '', newOwner: '', type: 'Vente' };
    } catch (err) {
      console.error(err);
      alert('Erreur lors de la mutation: ' + (err instanceof Error ? err.message : 'Inconnue'));
    } finally {
      this.loadingTransfer = false;
    }
  }

  resetForm() {
    this.form = {
      id: '',
      ownerName: '',
      ownerId: 'ID-' + Math.floor(Math.random() * 1000000),
      surface: 0,
      usage: 'Résidentiel',
      address: '',
      coordinates: '[]',
      hash: ''
    };
  }
}
