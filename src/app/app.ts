import {ChangeDetectionStrategy, Component, viewChild} from '@angular/core';
import {RouterOutlet, RouterLink, RouterLinkActive} from '@angular/router';
import {ErrorBoundary} from './components/error-boundary/error-boundary';

@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  selector: 'app-root',
  imports: [RouterOutlet, RouterLink, RouterLinkActive, ErrorBoundary],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App {
  errorBoundary = viewChild(ErrorBoundary);

  handleError(msg: string) {
    this.errorBoundary()?.showError(msg);
  }
}
