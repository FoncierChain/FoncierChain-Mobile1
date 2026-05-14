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
    address: "Moungali, Brazzaville",
    currentOwner: "1122SDE",
    owner: "1122SDE",
    surface: 450,
    area: 450,
    usage: "Résidentiel",
    usage_type: "Résidentiel",
    hash: "0x86e50149658661312a9e0b35558d84f6c6d3da79",
    lat: -4.2634,
    lng: 15.2832,
    coords: [[-4.2630, 15.2830], [-4.2630, 15.2835], [-4.2635, 15.2835], [-4.2635, 15.2830]],
    status: "COMMUNITY_VALIDATED",
    workflowStep: 2,
    land_type: "Cadastre",
    neighborhood: "Moungali",
    city: "Brazzaville",
    createdAt: "2026-05-01 12:08:18"
  },
  {
    parcelId: "30",
    id: "30",
    address: "Poto-Poto, Brazzaville",
    currentOwner: "SHDH",
    owner: "SHDH",
    surface: 300,
    area: 300,
    usage: "Commercial",
    usage_type: "Commercial",
    hash: "0x624b60c58c9d8bfb6ff1886c2fd605d2adeb6ea4",
    lat: -4.2700,
    lng: 15.2850,
    coords: [[-4.2690, 15.2845], [-4.2690, 15.2855], [-4.2710, 15.2855], [-4.2710, 15.2845]],
    status: "FINALIZED",
    workflowStep: 3,
    land_type: "Cadastre",
    neighborhood: "Poto-Poto",
    city: "Brazzaville",
    createdAt: "2026-05-01 12:11:53"
  },
  {
    parcelId: "55",
    id: "55",
    address: "Bacongo, Brazzaville",
    currentOwner: "244",
    owner: "244",
    surface: 600,
    area: 600,
    usage: "Résidentiel",
    usage_type: "Résidentiel",
    hash: "0x02d20bbd7e394ad5999a4cebabac9619732c343a",
    lat: -4.2850,
    lng: 15.2750,
    coords: [[-4.2840, 15.2740], [-4.2840, 15.2760], [-4.2860, 15.2760], [-4.2860, 15.2740]],
    status: "DRAFT",
    workflowStep: 1,
    land_type: "Coutumier",
    neighborhood: "Bacongo",
    city: "Brazzaville",
    createdAt: "2026-05-01 12:18:51"
  },
  {
    parcelId: "1",
    id: "1",
    address: "Ouenzé, Brazzaville",
    currentOwner: "12",
    owner: "12",
    surface: 1000,
    area: 1000,
    usage: "Agricole",
    usage_type: "Agricole",
    hash: "0x6b86b273ff34fce19d6b804eff5a3f5747ada4ea",
    lat: -4.2500,
    lng: 15.3000,
    coords: [[-4.2490, 15.2990], [-4.2490, 15.3010], [-4.2510, 15.3010], [-4.2510, 15.2990]],
    status: "FINALIZED",
    workflowStep: 3,
    land_type: "Agricole",
    neighborhood: "Ouenzé",
    city: "Brazzaville",
    createdAt: "2026-05-01 12:24:29"
  },
  {
    parcelId: "12",
    id: "12",
    address: "Talangaï, Brazzaville",
    currentOwner: "12",
    owner: "12",
    surface: 200,
    area: 200,
    usage: "Résidentiel",
    usage_type: "Résidentiel",
    hash: "0x6b51d431df5d7f141cbececcf79edf3dd861c3b4",
    lat: -4.2400,
    lng: 15.3100,
    coords: [[-4.2390, 15.3090], [-4.2390, 15.3110], [-4.2410, 15.3110], [-4.2410, 15.3090]],
    status: "DRAFT",
    workflowStep: 1,
    land_type: "Cadastre",
    neighborhood: "Talangaï",
    city: "Brazzaville",
    createdAt: "2026-05-01 14:31:03"
  },
  {
    parcelId: "15",
    id: "15",
    address: "Djiri, Brazzaville",
    currentOwner: "12",
    owner: "12",
    surface: 1500,
    area: 1500,
    usage: "Réserve État",
    usage_type: "Réserve État",
    hash: "0xe629fa6598d732768f7c726b4b621285f9c3b853",
    lat: -0.0500,
    lng: 15.0000,
    coords: [[-0.0490, 14.9990], [-0.0490, 15.0010], [-0.0510, 15.0010], [-0.0510, 14.9990]],
    status: "DRAFT",
    workflowStep: 1,
    land_type: "Réserve État",
    neighborhood: "Djiri",
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
app.post('/api/v1/auth/login/', (req: Request, res: Response) => {
  const { username } = req.body;
  // Map specific usernames to roles for demo purposes
  let role = "OWNER";
  let signature = "SIG-OFFICER-7788";
  let unique_id = "FC-12345678";
  
  if (username === "notaire") { role = "NOTAIRE"; signature = "SIG-NOTAIRE-BZA-2026"; }
  if (username === "chef") { role = "NEIGHBORHOOD_CHIEF"; signature = "SIG-CHIEF-MOUNG-01"; }
  if (username === "geometre") { role = "SURVEYOR"; signature = "SIG-SURV-BR-2026"; }
  if (username === "ministre") { role = "MINISTRY_OF_LAND_AFFAIRS"; signature = "SIG-MIN-FONCIER-CG"; }
  if (username === "cadastre") { role = "HEAD_OF_CADASTRAL_OFFICE"; signature = "SIG-CAD-BZA"; }
  if (username === "admin") { role = "ADMIN"; signature = "SIG-SYS-ADMIN"; }
  if (username === "geometre_controle") { role = "LAND_CONTROL_OFFICIER"; signature = "SIG-CTRL-GEOM"; }

  res.json({ 
    status: "SUCCESS",
    token: "auth_token_" + Math.random().toString(36).substring(7),
    user: { 
      id: 101, 
      username: username, 
      role: role,
      unique_id: unique_id,
      signature: signature,
      kyc_status: "APPROVED"
    }
  });
});

app.post('/api/v1/register/owner/', (req: Request, res: Response) => {
  const { username, email, phone, role, first_name, last_name, birth_date, gender, id_type, id_number } = req.body;
  res.status(201).json({
    status: "SUCCESS",
    message: "Compte propriétaire créé, en attente de validation KYC.",
    unique_id: "FC-PENDING-" + Math.random().toString(36).substring(2, 6).toUpperCase()
  });
});

app.post('/api/v1/register/official/', (req: Request, res: Response) => {
  const { username, role, organization } = req.body;
  res.status(201).json({
    status: "SUCCESS",
    user_id: Math.floor(Math.random() * 1000),
    role: role
  });
});

app.post('/api/v1/register/heir/', (req: Request, res: Response) => {
  const { username, first_name, last_name } = req.body;
  res.status(201).json({
    status: "SUCCESS",
    message: "Compte héritier créé."
  });
});

app.post('/api/v1/kyc/submit/', (req: Request, res: Response) => {
  const { id_recto, id_verso, id_number } = req.body;
  res.status(200).json({
    status: "SUCCESS", 
    message: "Documents soumis pour vérification."
  });
});

app.post('/api/v1/kyc/review/', (req: Request, res: Response) => {
  const { action, username, reason } = req.body;
  res.json({
    status: "SUCCESS",
    new_status: action,
    unique_id: "FC-" + Math.random().toString(36).substring(2, 8).toUpperCase(),
    signature: "SIG-KYC-REV-" + Math.random().toString(10).substring(2, 6),
    reason: action === 'REJECT' ? reason : undefined
  });
});

// --- Land & Fraud ---
app.post('/api/v1/land/signal-fraud/', (req: Request, res: Response) => {
  const { land_id } = req.body;
  const p = parcels.find(x => x.parcelId === land_id);
  if (p) {
    p.status = "LITIGE";
    return res.json({ status: "SUCCESS", message: "Alerte fraude enregistrée. Parcelle gelée." });
  }
  res.status(404).json({ error: "Parcelle non trouvée." });
});

app.post('/api/v1/land/draft/', (req: Request, res: Response) => {
  const { parcelId } = req.body;
  if (parcels.find(p => p.parcelId === parcelId)) {
    return res.status(409).json({ status: "FAILED", message: "Double attribution rejetée." });
  }
  const newParcel = { ...req.body, status: "PENDING_CONTROL" };
  parcels.push(newParcel);
  res.status(201).json({ status: "SUCCESS", parcel_id: parcelId });
});

app.post('/api/v1/land/verify-survey/', (req: Request, res: Response) => {
  const { land_id, action } = req.body;
  const p = parcels.find(x => x.parcelId === land_id);
  if (p) {
    p.status = action === 'APPROVE' ? "DRAFT" : "LITIGE";
    return res.json({ status: "SUCCESS", message: "Levé géométrique approuvé." });
  }
  res.status(404).json({ error: "Parcelle non trouvée." });
});

app.post('/api/v1/land/local-advice/', (req: Request, res: Response) => {
  const { land_id } = req.body;
  const p = parcels.find(x => x.parcelId === land_id);
  if (p) {
    p.status = "COMMUNITY_VALIDATED";
    return res.json({ status: "SUCCESS", message: "Avis local et signature enregistrés." });
  }
  res.status(404).json({ error: "Parcelle non trouvée." });
});

app.post('/api/v1/land/notary-validate/', (req: Request, res: Response) => {
  const { land_id } = req.body;
  const p = parcels.find(x => x.parcelId === land_id);
  if (p) {
    p.status = "NOTARY_VALIDATED";
    return res.json({ status: "SUCCESS", message: "Validation Notaire effectuée." });
  }
  res.status(404).json({ error: "Parcelle non trouvée." });
});

app.post('/api/v1/land/ministry-approve/', (req: Request, res: Response) => {
  const { land_id } = req.body;
  const p = parcels.find(x => x.parcelId === land_id);
  if (p) {
    p.status = "FINALIZED";
    return res.json({ status: "SUCCESS", message: "Titre foncier numérique approuvé et NFT généré.", nft_id: land_id });
  }
  res.status(404).json({ error: "Parcelle non trouvée." });
});

app.post('/api/v1/land/list-sale/', (req: Request, res: Response) => {
  const { land_id } = req.body;
  const p = parcels.find(x => x.parcelId === land_id);
  if (p && p.status === 'FINALIZED') {
    p.status = "ON_SALE";
    return res.json({ status: "SUCCESS", message: "Parcelle mise en vente." });
  }
  res.status(400).json({ error: "Vente impossible (Vérifiez le statut FINALIZED)." });
});

app.post('/api/v1/land/execute-sale/', (req: Request, res: Response) => {
  const { land_id } = req.body;
  const p = parcels.find(x => x.parcelId === land_id);
  if (p) {
    p.status = "SALE_PENDING";
    return res.json({ status: "SUCCESS", message: "Procédure de vente engagée. Attente Notaire." });
  }
  res.status(404).json({ error: "Parcelle non trouvée." });
});

app.post('/api/v1/land/heritage-setup/', (req: Request, res: Response) => {
  const { land_id } = req.body;
  const p = parcels.find(x => x.parcelId === land_id);
  if (p) {
    p.status = "HERITAGE";
    return res.json({ status: "SUCCESS", message: "Succession anticipée enregistrée." });
  }
  res.status(404).json({ error: "Parcelle non trouvée." });
});

app.get('/api/v1/geo/congo', (req: Request, res: Response) => {
  res.json({
    cities: [
      { 
        name: "Brazzaville", 
        neighborhoods: ["Makélékélé", "Bacongo", "Poto-Poto", "Moungali", "Ouenzé", "Talangaï", "Mfilou", "Madibou", "Djiri"]
      },
      {
        name: "Pointe-Noire",
        neighborhoods: ["Lumumba", "Mvoumvou", "Tié-Tié", "Loandjili", "Mongo-Mpoucou", "Ngoyo"]
      }
    ],
    departments: ["Bouenza", "Cuvette", "Kouilou", "Lékoumou", "Likouala", "Niari", "Plateaux", "Pool", "Sangha"]
  });
});

app.get('/api/v1/land/validate-geometry', (req: Request, res: Response) => {
  res.json({ valid: true, computed_area_m2: 250.5, overlaps: [] });
});

app.get('/api/v1/reports', (req: Request, res: Response) => {
  res.json({
    districts: ["Brazzaville", "Pointe-Noire"],
    audit_logs: [
      { id: "LOG-001", action: "Review KYC", user: "admin", date: new Date().toISOString() },
      { id: "LOG-002", action: "Signal Fraud", user: "chef_quartier", date: new Date().toISOString() }
    ],
    alerts: [
      { id: "ALT-001", type: "Fraud", parcelId: "34", reporter: "Comité Local", date: "2026-05-05", reason: "Occultation de titre" },
      { id: "ALT-002", type: "Dispute", parcelId: "12", reporter: "Propriétaire Voisin", date: "2026-05-06", reason: "Double attribution suspectée" }
    ]
  });
});

app.patch('/api/v1/support/tickets/:ticket_id', (req: Request, res: Response) => {
  const { status } = req.body;
  res.json({ status: "SUCCESS", ticket_id: req.params.ticket_id, new_status: status });
});

// --- Statistics ---
app.get('/api/v1/stats', (req: Request, res: Response) => {
  res.json({
    total_parcels: parcels.length + 14829,
    finalized_parcels: 9241,
    validated_parcels: 4500,
    draft_parcels: 1091,
    notary_pending: 231,
    heritage_blocked: 45,
    litige_active: 89,
    total_area: 12450000.5,
    reliability: 100,
    land_usage: [
      { usage_type: "Résidentiel", count: 1000 },
      { usage_type: "Commercial", count: 500 },
      { usage_type: "Agricole", count: 300 }
    ]
  });
});

// --- Registry & Search ---
app.get('/api/v1/registry/public', (req: Request, res: Response) => {
  res.json({
    parcels: parcels.filter(p => p.status === "FINALIZED"),
    blockchain_ledger: ledger,
    metrics: { total_titles: 14832, transfers_24h: 42, active_blocks: "842k+" }
  });
});

app.get('/api/v1/citizen/verify', (req: Request, res: Response) => {
  const query = (req.query.land_id as string || '').toLowerCase();
  const results = parcels.filter(p => p.parcelId.toLowerCase().includes(query) || p.cadastralId?.toLowerCase().includes(query));
  
  if (results.length === 0) {
    return res.status(404).json({ error: "Parcelle non trouvée" });
  }
  
  const p = results[0];
  const maskedOwner = (p.owner || "Inconnu").length > 2 
      ? p.owner![0] + "*".repeat(p.owner!.length - 2) + p.owner![p.owner!.length - 1]
      : p.owner;
      
  res.json({
    parcel_id: p.parcelId,
    status: p.status,
    owner: maskedOwner,
    city: p.city,
    neighborhood: p.neighborhood,
    area: p.area,
    cadastralId: p.cadastralId
  });
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
    land_type: (p as any).land_type || "Cadastre",
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

