import express, { Request, Response } from 'express';
import cors from 'cors';
import path from 'path';

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// --- Mock Database ---
let parcels = [
  { parcelId: "34", cadastralId: "CAD-34", owner: "1122SDE", city: "Brazzaville", neighborhood: "AAZZ", surface: 12222, price: 5000000, status: "COMMUNITY_VALIDATED", usage: "Résidentiel", lat: -4.2634, lng: 15.2832, hash: "0x86e...a79", createdAt: "2026-05-01 12:08:18" },
  { parcelId: "30", cadastralId: "CAD-30", owner: "SHDH", city: "Brazzaville", neighborhood: "POTO-POTO", surface: 233, price: 12000000, status: "FINALIZED", usage: "Résidentiel", lat: -4.2640, lng: 15.2840, hash: "0x624...ea4", createdAt: "2026-05-01 12:11:53" },
  { parcelId: "55", cadastralId: "CAD-55", owner: "244", city: "Brazzaville", neighborhood: "POTO-POTO", surface: 25, price: 3500000, status: "DRAFT", usage: "Résidentiel", lat: -4.2628, lng: 15.2825, hash: "0x02d...43a", createdAt: "2026-05-01 12:18:51" },
  { parcelId: "1", cadastralId: "CAD-1", owner: "12", city: "Brazzaville", neighborhood: "POTO_POTO", surface: 12, price: 1500000, status: "FINALIZED", usage: "Résidentiel", lat: -4.2650, lng: 15.2810, hash: "0x6b8...4ea", createdAt: "2026-05-01 12:24:29" },
];

const ledger = [
  { block_number: 18429, action: "CREATE", tx_id: "0x7a2...f41", proof: "ecdsa-sig-...", timestamp: new Date().toISOString() },
  { block_number: 18428, action: "VALIDATE", tx_id: "0x9b1...e22", proof: "ecdsa-sig-...", timestamp: new Date().toISOString() },
  { block_number: 18427, action: "FINALIZE", tx_id: "0x1c3...a88", proof: "ecdsa-sig-...", timestamp: new Date().toISOString() },
];

// --- Serve Flutter Web Build ---
const webBuildPath = path.join(__dirname, 'build', 'web');
app.use(express.static(webBuildPath));

// --- Auth Endpoints ---
app.post('/api/v1/register/', (req: Request, res: Response) => {
  res.status(201).json({
    user_id: 1,
    username: req.body.username || "user",
    role: req.body.role || "AGENT",
    token: "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b"
  });
});

app.post('/api/v1/auth/', (req: Request, res: Response) => {
  res.json({ 
    token: "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b",
    user: { id: 1, username: req.body.username, role: "AGENT" }
  });
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
  res.json(results);
});

// --- Map Data ---
app.get('/api/v1/map/', (req: Request, res: Response) => {
  res.json(parcels.map(p => ({
    ...p,
    address: `${p.neighborhood}, ${p.city}`,
    currentOwner: p.owner,
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

