import express, { Request, Response } from 'express';
import cors from 'cors';
import path from 'path';

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// --- Mock Database ---
let parcels = [
  {
    parcelId: "34",
    id: "34",
    address: "AAZZ, Brazzaville",
    currentOwner: "1122SDE",
    owner: "1122SDE",
    surface: 12222,
    area: 12222,
    usage: "Résidentiel",
    usage_type: "Résidentiel",
    hash: "0x86e50149658661312a9e0b35558d84f6c6d3da79",
    lat: -4.2993,
    lng: 15.2823,
    status: "COMMUNITY_VALIDATED",
    workflowStep: 2,
    neighborhood: "AAZZ",
    city: "Brazzaville",
    createdAt: "2026-05-01 12:08:18"
  },
  {
    parcelId: "30",
    id: "30",
    address: "POTO-POTO, Brazzaville",
    currentOwner: "SHDH",
    owner: "SHDH",
    surface: 233,
    area: 233,
    usage: "Résidentiel",
    usage_type: "Résidentiel",
    hash: "0x624b60c58c9d8bfb6ff1886c2fd605d2adeb6ea4",
    lat: -4.2699,
    lng: 15.2838,
    status: "FINALIZED",
    workflowStep: 3,
    neighborhood: "POTO-POTO",
    city: "Brazzaville",
    createdAt: "2026-05-01 12:11:53"
  },
  {
    parcelId: "55",
    id: "55",
    address: "POTO-POTO, Brazzaville",
    currentOwner: "244",
    owner: "244",
    surface: 25,
    area: 25,
    usage: "Résidentiel",
    usage_type: "Résidentiel",
    hash: "0x02d20bbd7e394ad5999a4cebabac9619732c343a",
    lat: -4.2754,
    lng: 15.3313,
    status: "DRAFT",
    workflowStep: 1,
    neighborhood: "POTO-POTO",
    city: "Brazzaville",
    createdAt: "2026-05-01 12:18:51"
  },
  {
    parcelId: "1",
    id: "1",
    address: "POTO_POTO, Brazzaville",
    currentOwner: "12",
    owner: "12",
    surface: 12,
    area: 12,
    usage: "Résidentiel",
    usage_type: "Résidentiel",
    hash: "0x6b86b273ff34fce19d6b804eff5a3f5747ada4ea",
    lat: -4.2943,
    lng: 15.3271,
    status: "FINALIZED",
    workflowStep: 3,
    neighborhood: "POTO_POTO",
    city: "Brazzaville",
    createdAt: "2026-05-01 12:24:29"
  },
  {
    parcelId: "12",
    id: "12",
    address: "POTO-POTO, Brazzaville",
    currentOwner: "12",
    owner: "12",
    surface: 12,
    area: 12,
    usage: "Résidentiel",
    usage_type: "Résidentiel",
    hash: "0x6b51d431df5d7f141cbececcf79edf3dd861c3b4",
    lat: -4.2794,
    lng: 15.2939,
    status: "DRAFT",
    workflowStep: 1,
    neighborhood: "POTO-POTO",
    city: "Brazzaville",
    createdAt: "2026-05-01 14:31:03"
  },
  {
    parcelId: "15",
    id: "15",
    address: "POTO-POTO, Brazzaville",
    currentOwner: "12",
    owner: "12",
    surface: 12,
    area: 12,
    usage: "Résidentiel",
    usage_type: "Résidentiel",
    hash: "0xe629fa6598d732768f7c726b4b621285f9c3b853",
    lat: -4.2836,
    lng: 15.2920,
    status: "DRAFT",
    workflowStep: 1,
    neighborhood: "POTO-POTO",
    city: "Brazzaville",
    createdAt: "2026-05-01 14:38:17"
  }
];

const ledger = [
  { block_number: 18429, action: "CREATE", tx_id: "0x7a2...f41", proof: "ecdsa-sig-...", timestamp: new Date().toISOString() },
  { block_number: 18428, action: "VALIDATE", tx_id: "0x9b1...e22", proof: "ecdsa-sig-...", timestamp: new Date().toISOString() },
  { block_number: 18427, action: "FINALIZE", tx_id: "0x1c3...a88", proof: "ecdsa-sig-...", timestamp: new Date().toISOString() },
];

// --- Serve Flutter Web Build ---
const webBuildPath = path.join(__dirname, 'build', 'web');
app.use(express.static(webBuildPath));

// --- Auth & KYC Endpoints ---
app.post('/api/v1/auth/', (req: Request, res: Response) => {
  res.json({ 
    token: "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b",
    user: { id: 1, username: req.body.username, role: "AGENT" }
  });
});

app.post('/api/v1/register/owner/', (req: Request, res: Response) => {
  const { username, phone, email, id_recto, id_verso } = req.body;
  res.status(201).json({
    status: "PENDING",
    message: "Inscription reçue. Votre compte est en attente de vérification KYC.",
    email: email
  });
});

app.post('/api/v1/kyc/submit/', (req: Request, res: Response) => {
  const { id_number, id_recto, id_verso } = req.body;
  // Simulate processing
  res.status(202).json({
    status: "IN_PROCESS",
    message: "Analyse en cours par l'IA et l'équipe KYC.",
    uid_assigned: "FC-" + Math.random().toString(36).substring(2, 8).toUpperCase()
  });
});

app.post('/api/v1/kyc/review/', (req: Request, res: Response) => {
  const { action, username, reason } = req.body;
  res.json({
    status: action === 'APPROVE' ? "APPROVED" : "FAILED",
    username: username,
    reason: reason || "Vérification effectuée."
  });
});

// --- Land & Fraud ---
app.post('/api/v1/land/signal/', (req: Request, res: Response) => {
  const { parcel_id, cadastral_id, reason } = req.body;
  const p = parcels.find(x => x.parcelId === parcel_id || (cadastral_id && x.cadastralId === cadastral_id));
  if (p) {
    p.status = "LITIGE";
    (p as any).land_type = "Litige";
    return res.json({ status: "SUCCESS", message: "Parcelle mise sous séquestre pour litige.", parcel_id: p.parcelId });
  }
  res.status(404).json({ error: "Parcelle non trouvée pour signalement." });
});

app.post('/api/v1/land/approve-draft/', (req: Request, res: Response) => {
  const { parcel_id, action } = req.body;
  const p = parcels.find(x => x.parcelId === parcel_id);
  if (p) {
    if (action === 'APPROVE') {
      p.status = "COMMUNITY_VALIDATED";
    } else {
      parcels = parcels.filter(x => x.parcelId !== parcel_id); // Rejet
    }
    return res.json({ status: "SUCCESS", action: action });
  }
  res.status(404).json({ error: "Draft non trouvé." });
});

app.get('/api/v1/geo/congo/', (req: Request, res: Response) => {
  res.json({
    status: "SUCCESS",
    data: {
      "Brazzaville": ["Makélékélé", "Bacongo", "Poto-Poto", "Moungali", "Ouenzé", "Talangaï", "Mfilou", "Madibou", "Djiri"],
      "Pointe-Noire": ["Lumumba", "Mvoumvou", "Tié-Tié", "Loandjili", "Mongo-Mpoucou", "Ngoyo"],
      "Dolisie": ["District 1", "District 2"],
      "Owando": ["Quartier 1", "Quartier 2"]
    }
  });
});

app.get('/api/v1/reports/', (req: Request, res: Response) => {
  res.json({
    status: "SUCCESS",
    reports: [
      { id: "REP-001", type: "Fraud", parcelId: "34", reporter: "Comité Local", date: "2026-05-05" },
      { id: "REP-002", type: "Dispute", parcelId: "12", reporter: "Propriétaire Voisin", date: "2026-05-06" }
    ]
  });
});

app.patch('/api/v1/support/tickets/:ticket_id/', (req: Request, res: Response) => {
  const { status } = req.body;
  res.json({ status: "SUCCESS", ticket_id: req.params.ticket_id, new_status: status });
});

// --- Land Workflow ---
app.post('/api/v1/land/draft/', (req: Request, res: Response) => {
  const { parcelId } = req.body;
  if (parcels.find(p => p.parcelId === parcelId)) {
    return res.status(409).json({ status: "FAILED", message: "DOUBLE ATTRIBUTION REJETÉE", conflict: "parcel_id" });
  }
  const newParcel = { ...req.body, status: "DRAFT" };
  parcels.push(newParcel);
  res.status(201).json({ status: "SUCCESS", txId: "0x" + Math.random().toString(16).slice(2), id: parcelId });
});

app.patch('/api/v1/land/validate/', (req: Request, res: Response) => {
  const { land_id } = req.body;
  const p = parcels.find(x => x.parcelId === land_id);
  if (p) p.status = "COMMUNITY_VALIDATED";
  res.json({ status: "SUCCESS", message: "Validated successfully" });
});

app.patch('/api/v1/land/finalize/', (req: Request, res: Response) => {
  const { land_id } = req.body;
  const p = parcels.find(x => x.parcelId === land_id);
  if (p) p.status = "FINALIZED";
  res.json({ status: "SUCCESS", message: "Land permanently anchored" });
});

app.post('/api/v1/land/mutate/', (req: Request, res: Response) => {
  const { land_id, new_owner_id } = req.body;
  const p = parcels.find(x => x.parcelId === land_id);
  if (p) p.owner = new_owner_id;
  res.json({ status: "SUCCESS", message: "Ownership transferred" });
});

// --- Statistics ---
app.get('/api/v1/stats/', (req: Request, res: Response) => {
  res.json({
    total_parcels: parcels.length + 14829,
    finalized_parcels: 9241,
    validated_parcels: 4500,
    draft_parcels: 1091,
    total_area: 12450000.5,
    reliability: 100,
    land_usage: [
      { usage_type: "Résidentiel", count: 1000 },
      { usage_type: "Commercial", count: 500 }
    ]
  });
});

// --- Registry & Search ---
app.get('/api/v1/registry/public/', (req: Request, res: Response) => {
  res.json({
    parcels: parcels.filter(p => p.status === "FINALIZED"),
    blockchain_ledger: ledger,
    metrics: { total_titles: 14832, transfers_24h: 42, active_blocks: "842k+" }
  });
});

app.get('/api/v1/citizen/verify', (req: Request, res: Response) => {
  const query = (req.query.land_id as string || '').toLowerCase();
  const results = parcels.filter(p => p.parcelId.toLowerCase().includes(query));
  
  if (results.length === 0) {
    return res.status(404).json({ error: "Parcelle non trouvée" });
  }
  
  res.json(results);
});

// --- Support ---
app.post('/api/v1/support/chat', (req: Request, res: Response) => {
  const { message } = req.body;
  res.json({
    status: "SUCCESS",
    reply: `Réponse de l'IA FoncierChain à: "${message}". En tant qu'expert du Cadastre de Brazzaville, je vous conseille de vérifier le Trust Score sur la carte.`
  });
});

app.post('/api/v1/support/tickets', (req: Request, res: Response) => {
  res.status(201).json({
    status: "SUCCESS",
    message: "Ticket créé",
    ticket_id: "TKT-" + Math.floor(Math.random() * 10000)
  });
});

// --- Modified Map Data to include Land Type ---
const landTypes = ["Cadastre", "Coutumier", "Réserve État", "Agricole", "Minière", "Forestière", "En Vente"];

app.get('/api/v1/map/', (req: Request, res: Response) => {
  res.json(parcels.map((p, index) => ({
    ...p,
    address: `${p.neighborhood}, ${p.city}`,
    currentOwner: p.owner,
    land_type: (p as any).land_type || landTypes[index % landTypes.length],
    workflowStep: p.status === "FINALIZED" ? 3 : (p.status === "COMMUNITY_VALIDATED" ? 2 : 1)
  })));
});

// --- History ---
app.get('/api/v1/land/:land_id/history/', (req: Request, res: Response) => {
  res.json({
    land_id: req.params.land_id,
    history: [
      { txId: "0xabc...", action: "CREATED", timestamp: new Date().toISOString(), value: { status: "DRAFT" } }
    ]
  });
});

// Fallback to index.html for SPA routing
app.get('*', (req: Request, res: Response) => {
  res.sendFile(path.join(webBuildPath, 'index.html'));
});

// --- Start Server ---
app.listen(port, () => {
  console.log(`FoncierChain Unified Server running at http://0.0.0.0:${port}`);
});

