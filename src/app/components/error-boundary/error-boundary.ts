import { Component, signal } from '@angular/core';

@Component({
  selector: 'app-error-boundary',
  standalone: true,
  template: `
    @if (errorMessage()) {
      <div class="fixed top-4 right-4 z-50 bg-red-900/90 border border-red-500 text-white p-4 rounded-xl shadow-2xl backdrop-blur-md max-w-md animate-in fade-in slide-in-from-top-4">
        <div class="flex items-start gap-3">
          <span class="material-icons text-red-400">error_outline</span>
          <div>
            <h3 class="font-bold mb-1">Erreur de Système</h3>
            <p class="text-sm text-red-100 opacity-90">{{ errorMessage() }}</p>
            <button (click)="clear()" class="mt-3 text-xs font-semibold uppercase tracking-wider text-red-300 hover:text-white">
              Fermer
            </button>
          </div>
        </div>
      </div>
    }
  `
})
export class ErrorBoundary {
  errorMessage = signal<string | null>(null);

  showError(msg: string) {
    this.errorMessage.set(msg);
    setTimeout(() => this.clear(), 8000);
  }

  clear() {
    this.errorMessage.set(null);
  }
}
