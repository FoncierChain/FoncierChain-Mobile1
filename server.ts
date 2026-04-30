import express, { Request, Response } from 'express';
import cors from 'cors';
import path from 'path';

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// --- Mock Database ---
let parcels = [
  { id: "bz-101", owner: "Jean Mokoko", city: "Brazzaville", neighborhood: "Poto-Poto", area: 450, status: "FINALIZED", usage: "Residentiel", lat: -4.26, lng: 15.28 },
  { id: "bz-102", owner: "Marie Samba", city: "Brazzaville", neighborhood: "Moungali", area: 600, status: "VALIDATED", usage: "Commercial", lat: -4.27, lng: 15.29 },
  { id: "bz-103", owner: "Pierre Okombi", city: "Brazzaville", neighborhood: "Bacongo", area: 300, status: "DRAFT", usage: "Residentiel", lat: -4.28, lng: 15.27 },
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
  res.json({ token: "9944b09199c62bcf9418ad846dd0e4bbdfc6ee4b" });
});

// --- Land Workflow ---
app.post('/api/v1/land/draft/', (req: Request, res: Response) => {
  const newId = `bz-${Math.floor(Math.random() * 1000)}`;
  const newParcel = { ...req.body, id: newId, status: "DRAFT" };
  parcels.push(newParcel);
  res.status(201).json({ status: "SUCCESS", txId: "0x" + Math.random().toString(16).slice(2), id: newId });
});

app.patch('/api/v1/land/validate/', (req: Request, res: Response) => {
  const { land_id } = req.body;
  const p = parcels.find(x => x.id === land_id);
  if (p) p.status = "VALIDATED";
  res.json({ status: "SUCCESS", message: "Validated successfully" });
});

app.patch('/api/v1/land/finalize/', (req: Request, res: Response) => {
  const { land_id } = req.body;
  const p = parcels.find(x => x.id === land_id);
  if (p) p.status = "FINALIZED";
  res.json({ status: "SUCCESS", message: "Land permanently anchored" });
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

// --- Registry ---
app.get('/api/v1/registry/public/', (req: Request, res: Response) => {
  res.json({
    parcels: parcels.filter(p => p.status === "FINALIZED"),
    blockchain_ledger: ledger,
    metrics: { total_titles: 14832, transfers_24h: 42, active_blocks: "842k+" }
  });
});

// --- GIS Map ---
app.get('/api/v1/map/', (req: Request, res: Response) => {
  res.json(parcels);
});

// Fallback to index.html for SPA routing
app.get('*', (req: Request, res: Response) => {
  res.sendFile(path.join(webBuildPath, 'index.html'));
});

// --- Start Server ---
app.listen(port, '0.0.0.0', () => {
  console.log(`FancierChain Unified Server running at http://localhost:${port}`);
});

