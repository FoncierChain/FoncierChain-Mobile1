import { Injectable, signal } from '@angular/core';
import { 
  collection, 
  doc, 
  getDoc, 
  getDocs, 
  query, 
  where, 
  addDoc, 
  setDoc, 
  updateDoc, 
  onSnapshot,
  orderBy
} from 'firebase/firestore';
import { auth, db, handleFirestoreError, OperationType } from '../firebase';
import { onAuthStateChanged, User } from 'firebase/auth';

export interface Parcel {
  id: string;
  ownerName: string;
  ownerId: string;
  surface: number;
  usage: string;
  address: string;
  coordinates: string;
  status: 'validé' | 'en_attente';
  hash: string;
  lastUpdate: string;
  agentUid: string;
}

export interface UserProfile {
  uid: string;
  email: string;
  role: 'citizen' | 'agent' | 'admin';
  displayName: string;
}

export interface HistoryItem {
  parcelId: string;
  previousOwner: string;
  newOwner: string;
  date: string;
  type: 'Vente' | 'Donation' | 'Héritage' | 'Mutation';
  documentHash: string;
  agentUid: string;
}

@Injectable({
  providedIn: 'root'
})
export class LandService {
  user = signal<User | null>(null);
  profile = signal<UserProfile | null>(null);

  constructor() {
    onAuthStateChanged(auth, (user) => {
      this.user.set(user);
      if (user) {
        this.loadProfile(user.uid);
      } else {
        this.profile.set(null);
      }
    });
  }

  private async loadProfile(uid: string) {
    try {
      const docRef = doc(db, 'users', uid);
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        this.profile.set(docSnap.data() as UserProfile);
      } else {
        // Default register for new users as citizen
        const newProfile: UserProfile = {
          uid,
          email: this.user()?.email || '',
          role: 'citizen',
          displayName: this.user()?.displayName || ''
        };
        await setDoc(docRef, newProfile);
        this.profile.set(newProfile);
      }
    } catch (err) {
      console.error('Error loading profile', err);
    }
  }

  async getParcelById(id: string): Promise<Parcel | null> {
    try {
      const q = query(collection(db, 'parcels'), where('id', '==', id));
      const querySnapshot = await getDocs(q);
      if (!querySnapshot.empty) {
        return querySnapshot.docs[0].data() as Parcel;
      }
      return null;
    } catch (err) {
      handleFirestoreError(err, OperationType.GET, 'parcels');
      return null;
    }
  }

  async getAllParcels(): Promise<Parcel[]> {
    try {
      const querySnapshot = await getDocs(collection(db, 'parcels'));
      return querySnapshot.docs.map(doc => doc.data() as Parcel);
    } catch (err) {
      handleFirestoreError(err, OperationType.LIST, 'parcels');
      return [];
    }
  }

  async searchParcels(id: string): Promise<Parcel[]> {
    const p = await this.getParcelById(id);
    return p ? [p] : [];
  }

  async registerParcel(parcel: Omit<Parcel, 'agentUid' | 'lastUpdate' | 'status'>) {
    if (!this.user() || this.profile()?.role === 'citizen') {
      throw new Error('Unauthorized: Seuls les agents peuvent enregistrer des parcelles.');
    }

    const fullParcel: Parcel = {
      ...parcel,
      status: 'en_attente',
      agentUid: this.user()!.uid,
      lastUpdate: new Date().toISOString()
    };

    try {
      await setDoc(doc(db, 'parcels', parcel.id), fullParcel);
      // Create history item
      await addDoc(collection(db, 'parcels', parcel.id, 'history'), {
        parcelId: parcel.id,
        previousOwner: 'N/A (Nouveau)',
        newOwner: parcel.ownerName,
        date: new Date().toISOString(),
        type: 'Mutation',
        documentHash: parcel.hash,
        agentUid: this.user()!.uid
      } as HistoryItem);
    } catch (err) {
      handleFirestoreError(err, OperationType.CREATE, 'parcels');
    }
  }

  async transferOwnership(parcelId: string, newOwnerName: string, newOwnerId: string, newHash: string, type: HistoryItem['type'] = 'Vente') {
    const parcelRef = doc(db, 'parcels', parcelId);
    const snap = await getDoc(parcelRef);
    if (!snap.exists()) throw new Error('Parcelle introuvable');
    
    const parcelItem = snap.data() as Parcel;
    const oldOwner = parcelItem.ownerName;

    try {
      await updateDoc(parcelRef, {
        ownerName: newOwnerName,
        ownerId: newOwnerId,
        hash: newHash,
        lastUpdate: new Date().toISOString()
      });

      await addDoc(collection(db, 'parcels', parcelId, 'history'), {
        parcelId,
        previousOwner: oldOwner,
        newOwner: newOwnerName,
        date: new Date().toISOString(),
        type,
        documentHash: newHash,
        agentUid: this.user()?.uid || 'system'
      } as HistoryItem);
    } catch (err) {
      handleFirestoreError(err, OperationType.UPDATE, `parcels/${parcelId}`);
    }
  }

  getParcelHistory(parcelId: string, callback: (history: HistoryItem[]) => void) {
    const q = query(collection(db, 'parcels', parcelId, 'history'), orderBy('date', 'desc'));
    return onSnapshot(q, (snap) => {
      callback(snap.docs.map(doc => doc.data() as HistoryItem));
    }, (err) => {
      handleFirestoreError(err, OperationType.GET, `parcels/${parcelId}/history`);
    });
  }
}
