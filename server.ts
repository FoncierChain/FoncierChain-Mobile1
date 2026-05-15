import express, { Request, Response } from 'express';
import cors from 'cors';
import path from 'path';

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// Mock Data
const parcels = [
  {
    parcelId: "BZV-PAL-001",
    id: "BZV-PAL-001",
    address: "Plateau des 15 ans, Brazzaville",
    currentOwner: "JEAN-PIERRE MOSSOSSO",
    owner: "JEAN-PIERRE MOSSOSSO",
    surface: 450,
    area: 450,
    usage: "Résidentiel",
    usage_type: "Résidentiel",
    hash: "0x3f4f99ef900e4b872db898880d9b0b3e8f432060",
    coordinates: [
      [-4.2634, 15.2832],
      [-4.2644, 15.2832],
      [-4.2644, 15.2842],
      [-4.2634, 15.2842]
    ],
    lat: -4.2634,
    lng: 15.2832,
    status: "FINALIZED",
    workflowStep: 8,
    neighborhood: "Plateau des 15 ans",
    city: "Brazzaville",
    createdAt: "2026-05-15 05:10:15",
    kyc_verified: true,
    trust_score: 98,
    risk_level: "LOW"
  },
  {
    parcelId: "42ede2e7e24b7f6a7b0a89b9d0e72ea5b5cba159c691f3080a47ed744cc809a7",
    id: "42ede2e7e24b7f6a7b0a89b9d0e72ea5b5cba159c691f3080a47ed744cc809a7",
    address: "MAKELEKELE, Brazzaville",
    currentOwner: "OBI****EY",
    owner: "OBI****EY",
    surface: 123,
    area: 123,
    usage: "Résidentiel",
    usage_type: "Résidentiel",
    hash: "0x3f4f99ef900e4b872db898880d9b0b3e8f432060",
    coordinates: [
      [-4.27815, 15.27935],
      [-4.27915, 15.27935],
      [-4.27915, 15.28035],
      [-4.27815, 15.28035]
    ],
    lat: -4.27815,
    lng: 15.27935,
    status: "PENDING_CONTROL",
    workflowStep: 0,
    neighborhood: "MAKELEKELE",
    city: "Brazzaville",
    createdAt: "2026-05-15 05:10:15",
    kyc_verified: false,
    trust_score: 75,
    risk_level: "LOW"
  }
];

// Auth & KYC
app.post('/api/v1/auth/login', (req: Request, res: Response) => {
  const { username } = req.body;
  
  // Mapping specific usernames to roles for demo
  const roleMap: Record<string, string> = {
    "ministre": "MINISTRY_OF_LAND_AFFAIRS",
    "cadastre_chef": "HEAD_OF_CADASTRAL_OFFICE",
    "geometre": "SURVEYOR",
    "chef_quartier": "NEIGHBORHOOD_CHIEF",
    "chef_bloc": "BLOC_CHIEF",
    "chef_village": "VILLAGE_CHIEF",
    "citoyen": "CITIZEN",
    "agent_ticket": "TICKET_AGENT",
    "agent_kyc": "KYC_AGENT",
    "controleur": "LAND_CONTROL_OFFICER",
    "support": "CUSTOMER_SUPPORT_AGENT",
    "heritier": "HEIR",
    "proprietaire": "OWNER",
    "admin": "ADMIN"
  };

  let role = "CITIZEN";
  for (const key in roleMap) {
    if (username.toLowerCase().includes(key)) {
      role = roleMap[key];
      break;
    }
  }

  res.json({
    token: "e44578a55ce1096169bcedb0df2eccbb4f46cc03",
    user: {
      id: 1,
      username: username,
      role: role,
      unique_id: `UID-${Math.floor(Math.random() * 1000)}`,
      email: `${username}@foncierchain.cg`,
      kyc_status: "APPROVED"
    }
  });
});

app.post('/api/v1/register/owner', (req: Request, res: Response) => {
  res.status(201).json({ status: "SUCCESS", message: "Inscription réussie" });
});

app.post('/api/v1/register/official', (req: Request, res: Response) => {
  res.status(201).json({ status: "SUCCESS", message: "Inscription officielle réussie" });
});

app.post('/api/v1/register/heir', (req: Request, res: Response) => {
  res.status(201).json({ status: "SUCCESS", message: "Inscription héritier réussie" });
});

app.post('/api/v1/kyc/submit', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", message: "KYC soumis" });
});

app.post('/api/v1/kyc/review', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", message: "KYC révisé" });
});

app.post('/api/v1/kyc/verify', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", kyc_verified: true });
});

// Land Management
app.post('/api/v1/land/signal-fraud', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", message: "Signalement enregistré" });
});

app.post('/api/v1/land/draft', (req: Request, res: Response) => {
  res.status(201).json({ status: "SUCCESS", message: "Brouillon créé" });
});

app.post('/api/v1/land/verify-survey', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", message: "Vérification terminée" });
});

app.post('/api/v1/land/local-advice', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", message: "Avis enregistré" });
});

app.post('/api/v1/land/notary-validate', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", message: "Validation notaire effectuée" });
});

app.post('/api/v1/land/ministry-approve', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", message: "Approbation ministérielle effectuée" });
});

app.post('/api/v1/land/list-sale', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", message: "Terrain mis en vente" });
});

app.post('/api/v1/land/execute-sale', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", message: "Vente exécutée" });
});

app.post('/api/v1/land/approve', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", message: "Draft approuvé" });
});

app.patch('/api/v1/land/validate', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", message: "Validation effectuée" });
});

app.patch('/api/v1/land/finalize', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", message: "Finalisation effectuée" });
});

app.post('/api/v1/land/oppose', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", message: "Opposition enregistrée" });
});

// Map & Registry
app.get('/api/v1/map', (req: Request, res: Response) => {
  res.json(parcels);
});

app.get('/api/v1/stats', (req: Request, res: Response) => {
  res.json({
    totalParcels: 4500,
    verifiedParcels: 3800,
    litiges: 120,
    onSale: 45,
  });
});

app.get('/api/v1/registry/public', (req: Request, res: Response) => {
  res.json(parcels.filter(p => p.status === 'FINALIZED'));
});

app.get('/api/v1/land/:land_id/history', (req: Request, res: Response) => {
  res.json({
    land_id: req.params.land_id,
    history: [
      { date: "2026-01-10", action: "CREATION", actor: "CADASTRE", description: "Brouillon initial" },
      { date: "2026-02-15", action: "VALIDATION", actor: "CHEF QUARTIER", description: "Validation communautaire" },
      { date: "2026-03-20", action: "FINALISATION", actor: "MINISTRE", description: "Titre foncier émis" }
    ]
  });
});

app.get('/api/v1/land/performance-audit', (req: Request, res: Response) => {
  res.json({
    uptime: "99.98%",
    transactionsPerSec: 12,
    blocksValidated: 45000,
    avg_response_time_days: {
      chef_quartier: 2,
      mairie: 5,
      cadastre: 10
    },
    efficiency_score: 94,
    total_escrows_active: 12
  });
});

app.get('/api/v1/geo/congo', (req: Request, res: Response) => {
  res.json({
    cities: {
      "Brazzaville": ["Makélékélé", "Bacongo", "Poto-Poto", "Moungali", "Ouenzé", "Talangaï", "Mfilou", "Madibou", "Djiri"],
      "Pointe-Noire": ["Lumumba", "Mvoumvou", "Tié-Tié", "Loandjili", "Mongo-Mpoucou", "Ngoyo"]
    }
  });
});

app.get('/api/v1/reports', (req: Request, res: Response) => {
  res.json({
    districts: [
      {
        id: 1,
        name: "MAKELEKELE",
        total_area: 45000,
        registered_count: 120,
        validation_rate: 85,
        total: 1240,
        finalized: 1100
      }
    ],
    audit_logs: [
      {
        id: 1,
        timestamp: "2026-05-15 05:10:15",
        agent: "geometre",
        action: "CREATE",
        entity: "42ede2e7e24b7f6a7b0a89b9d0e72ea5b5cba159c691f3080a47ed744cc809a7",
        status: "SUCCESS",
        details: "Brouillon créé par Géomètre"
      }
    ]
  });
});

app.get('/api/v1/citizen/verify', (req: Request, res: Response) => {
  const land_id = req.query.land_id;
  const p = parcels.find(x => x.parcelId === land_id);
  if (p) return res.json(p);
  res.status(404).json({ error: "Non trouvé" });
});

// Support & Escrow
app.post('/api/v1/support/tickets', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", ticket_id: "TICK-99" });
});

app.post('/api/v1/support/chat', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", response: "Un agent va vous répondre." });
});

app.post('/api/v1/land/escrow/open', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", escrow_id: "ESC-55" });
});

app.post('/api/v1/land/heritage-notify', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", message: "Succession notifiée" });
});

app.post('/api/v1/land/mutate', (req: Request, res: Response) => {
  res.json({ status: "SUCCESS", message: "Mutation effectuée" });
});

// Static assets for Flutter Web
const webBuildPath = path.join(__dirname, 'build/web');
app.use(express.static(webBuildPath));

app.get('*', (req: Request, res: Response) => {
  res.sendFile(path.join(webBuildPath, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
