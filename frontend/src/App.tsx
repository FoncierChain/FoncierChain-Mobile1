import React, { useState, useEffect } from 'react';
import { 
  ShieldCheck, 
  Map as MapIcon, 
  BarChart3, 
  AlertTriangle, 
  Clock, 
  Lock, 
  CheckCircle2, 
  User, 
  ChevronRight,
  RefreshCw,
  Search,
  Layers,
  ArrowRightLeft
} from 'lucide-react';
import { 
  LineChart, 
  Line, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell
} from 'recharts';
import { motion, AnimatePresence } from 'framer-motion';

// --- Mock Data ---
const performanceData = [
  { name: 'Lun', responseTime: 4.5 },
  { name: 'Mar', responseTime: 4.2 },
  { name: 'Mer', responseTime: 5.1 },
  { name: 'Jeu', responseTime: 3.8 },
  { name: 'Ven', responseTime: 4.0 },
  { name: 'Sam', responseTime: 3.5 },
  { name: 'Dim', responseTime: 3.2 },
];

const landUsageData = [
  { name: 'Résidentiel', value: 55, color: '#00963F' },
  { name: 'Commercial', value: 25, color: '#3b82f6' },
  { name: 'Agricole', value: 20, color: '#eab308' },
];

const App = () => {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [parcels, setParcels] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/v1/map/')
      .then(res => res.json())
      .then(data => {
        setParcels(data);
        setLoading(false);
      });
  }, []);

  return (
    <div className="min-h-screen bg-[#0B0E14] text-white font-inter selection:bg-[#00963F]/30">
      {/* Navigation */}
      <nav className="fixed top-0 left-0 right-0 z-50 bg-[#0B0E14]/80 backdrop-blur-md border-b border-white/5 px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-[#00963F] rounded-xl flex items-center justify-center shadow-[0_0_20px_rgba(0,150,63,0.3)]">
            <ShieldCheck className="text-white w-6 h-6" />
          </div>
          <div>
            <h1 className="text-lg font-black tracking-tighter leading-none">FONCIERCHAIN</h1>
            <p className="text-[10px] text-white/40 font-medium tracking-[0.2em] uppercase">Digital Trust Protocol 2026</p>
          </div>
        </div>

        <div className="hidden md:flex items-center gap-8 text-[11px] font-bold uppercase tracking-widest text-white/50">
          <button 
            onClick={() => setActiveTab('dashboard')}
            className={`hover:text-white transition-colors ${activeTab === 'dashboard' ? 'text-[#00963F]' : ''}`}
          >
            Dashboard
          </button>
          <button 
            onClick={() => setActiveTab('explorer')}
            className={`hover:text-white transition-colors ${activeTab === 'explorer' ? 'text-[#00963F]' : ''}`}
          >
            Explorateur SIG
          </button>
          <button 
            onClick={() => setActiveTab('audit')}
            className={`hover:text-white transition-colors ${activeTab === 'audit' ? 'text-[#00963F]' : ''}`}
          >
            Audit Gouvernance
          </button>
        </div>

        <div className="flex items-center gap-4">
          <div className="hidden sm:flex flex-col items-end mr-2">
            <span className="text-[10px] font-bold text-white/50 uppercase">Connecté en tant que</span>
            <span className="text-xs font-black text-[#00963F]">MINISTRE DU FONCIER</span>
          </div>
          <div className="w-10 h-10 rounded-full bg-white/5 border border-white/10 flex items-center justify-center">
            <User className="w-5 h-5 text-white/60" />
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main className="pt-24 pb-12 px-6 max-w-7xl mx-auto">
        <AnimatePresence mode="wait">
          {activeTab === 'dashboard' && (
            <motion.div 
              key="dashboard"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="space-y-8"
            >
              <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
                <StatCard label="Titres NFT Émis" value="14,832" delta="+12%" icon={<Lock className="text-green-500" />} />
                <StatCard label="Taxes Trésor (YTD)" value="2.4B FCFA" delta="+8.4%" icon={<RefreshCw className="text-blue-500" />} />
                <StatCard label="Séquestres Actifs" value="142" delta="En cours" icon={<Clock className="text-yellow-500" />} />
                <StatCard label="Score National" value="94.5%" delta="Optimal" icon={<ShieldCheck className="text-[#00963F]" />} />
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Performance Chart */}
                <div className="lg:col-span-2 bg-[#161B22] rounded-3xl border border-white/5 p-8">
                  <div className="flex items-center justify-between mb-8">
                    <div>
                      <h2 className="text-lg font-black tracking-tight">EFFICACITÉ ADMINISTRATIVE</h2>
                      <p className="text-xs text-white/40">Délai moyen de réponse des services de l'État</p>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="w-3 h-3 bg-[#00963F] rounded-full"></span>
                      <span className="text-[10px] font-bold uppercase text-white/40">Objectif: 3.0j</span>
                    </div>
                  </div>
                  <div className="h-[300px] w-full">
                    <ResponsiveContainer width="100%" height="100%">
                      <LineChart data={performanceData}>
                        <CartesianGrid strokeDasharray="3 3" stroke="#2a2f3a" vertical={false} />
                        <XAxis 
                          dataKey="name" 
                          stroke="#4b5563" 
                          fontSize={10} 
                          tickLine={false} 
                          axisLine={false} 
                        />
                        <YAxis 
                          stroke="#4b5563" 
                          fontSize={10} 
                          tickLine={false} 
                          axisLine={false}
                          tickFormatter={(val) => `${val}j`}
                        />
                        <Tooltip 
                          contentStyle={{ backgroundColor: '#1f2937', border: 'none', borderRadius: '12px', fontSize: '12px' }}
                          itemStyle={{ color: '#00963F' }}
                        />
                        <Line 
                          type="monotone" 
                          dataKey="responseTime" 
                          stroke="#00963F" 
                          strokeWidth={4} 
                          dot={{ r: 6, fill: '#00963F', strokeWidth: 2, stroke: '#0B0E14' }}
                          activeDot={{ r: 8, strokeWidth: 0 }}
                        />
                      </LineChart>
                    </ResponsiveContainer>
                  </div>
                </div>

                {/* Workflow Tracking */}
                <div className="bg-[#161B22] rounded-3xl border border-white/5 p-8 flex flex-col">
                  <h2 className="text-lg font-black tracking-tight mb-6">WORKFLOW IBOVI</h2>
                  <div className="space-y-6 flex-1">
                    <WorkflowStep 
                      index={1} 
                      title="Provision & Séquestre" 
                      status="COMPLETED" 
                      desc="Prix + Taxes bloqués par Smart Contract" 
                    />
                    <WorkflowStep 
                      index={2} 
                      title="Enquêtes Locales" 
                      status="ACTIVE" 
                      desc="Chef de Quartier & Mairie (SLA 10j)" 
                    />
                    <WorkflowStep 
                      index={3} 
                      title="Vacance Numérique" 
                      status="PENDING" 
                      desc="30 jours d'opposition publique blockchain" 
                    />
                    <WorkflowStep 
                      index={4} 
                      title="Expertise SIG & Notariat" 
                      status="PENDING" 
                      desc="Oracle ArcGIS & Certification Juridique" 
                    />
                    <WorkflowStep 
                      index={5} 
                      title="Clôture Atomique" 
                      status="PENDING" 
                      desc="Transfert NFT & Paiement simultané" 
                    />
                  </div>
                </div>
              </div>

              {/* Alerts & Bottlenecks */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <BottleneckList />
                <RecentTransactions parcels={parcels} />
              </div>
            </motion.div>
          )}

          {activeTab === 'explorer' && (
            <motion.div 
              key="explorer"
              initial={{ opacity: 0, scale: 0.98 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.98 }}
              className="h-[calc(100vh-12rem)]"
            >
              <div className="bg-[#161B22] rounded-3xl border border-white/5 h-full overflow-hidden relative">
                {/* ArcGIS Integration Placeholder */}
                <div className="absolute inset-0 bg-white/5 flex items-center justify-center flex-col p-12 text-center">
                  <div className="w-20 h-20 rounded-full bg-blue-500/20 flex items-center justify-center mb-6 animate-pulse">
                    <Layers className="text-blue-400 w-10 h-10" />
                  </div>
                  <h3 className="text-2xl font-black mb-2 uppercase tracking-tight">ORACLE ARCgis CONNECTÉ</h3>
                  <p className="text-white/40 max-w-md mx-auto text-sm leading-relaxed">
                    Vérification topologique en temps réel. Le système garantit qu'aucune parcelle ne chevauche le domaine public ou privé existant.
                  </p>
                  <div className="mt-8 grid grid-cols-3 gap-6 w-full max-w-xl">
                    <div className="p-4 bg-white/5 rounded-2xl border border-white/5">
                      <p className="text-[10px] text-white/30 font-bold uppercase mb-1">Précision SIG</p>
                      <p className="text-xl font-black text-blue-400">0.005m</p>
                    </div>
                    <div className="p-4 bg-white/5 rounded-2xl border border-white/5">
                      <p className="text-[10px] text-white/30 font-bold uppercase mb-1">Superpositions</p>
                      <p className="text-xl font-black text-green-400">ZERO</p>
                    </div>
                    <div className="p-4 bg-white/5 rounded-2xl border border-white/5">
                      <p className="text-[10px] text-white/30 font-bold uppercase mb-1">Satellites</p>
                      <p className="text-xl font-black text-yellow-400">14 Active</p>
                    </div>
                  </div>
                </div>

                {/* Overaly Controls */}
                <div className="absolute top-8 left-8 flex flex-col gap-3">
                  <SearchButton icon={<Search />} label="Rechercher Titre" />
                  <SearchButton icon={<Layers />} label="Couches Cadastrales" />
                  <SearchButton icon={<AlertTriangle />} label="Signaler Litige" />
                </div>
              </div>
            </motion.div>
          )}

          {activeTab === 'audit' && (
            <motion.div 
               key="audit"
               initial={{ opacity: 0, x: -20 }}
               animate={{ opacity: 1, x: 0 }}
               exit={{ opacity: 0, x: 20 }}
               className="grid grid-cols-1 lg:grid-cols-3 gap-8"
            >
              <div className="lg:col-span-2 space-y-8">
                 <div className="bg-[#161B22] rounded-3xl border border-white/5 p-8">
                    <div className="flex items-center gap-4 mb-8">
                      <div className="w-12 h-12 bg-blue-500/20 rounded-2xl flex items-center justify-center">
                        <RefreshCw className="text-blue-400" />
                      </div>
                      <div>
                        <h2 className="text-lg font-black uppercase tracking-tight">RÉGISTRE DES OPPOSITIONS PUBLIC</h2>
                        <p className="text-xs text-white/40">Vacance numérique active - Journal Officiel Blockchain</p>
                      </div>
                    </div>
                    <div className="space-y-4">
                      {parcels.filter(p => (p as any).status === 'PENDING_OPPOSITION' || p.status === 'FROZEN_OPPOSITION').map(p => (
                        <div key={p.id} className="p-5 rounded-2xl bg-white/5 border border-white/5 flex items-center justify-between hover:bg-white/[0.07] transition-all group">
                          <div className="flex items-center gap-4">
                            <div className={`w-2 h-12 rounded-full ${p.status === 'FROZEN_OPPOSITION' ? 'bg-red-500' : 'bg-yellow-500'}`}></div>
                            <div>
                              <p className="text-xs font-black text-white/80 tracking-tight">TITRE: {p.id} ({p.neighborhood})</p>
                              <p className="text-[10px] text-white/40 font-bold uppercase mt-1">
                                {p.status === 'FROZEN_OPPOSITION' ? '⚠️ TRANSACTION GELÉE - LITIGE EN COURS' : '⏳ EN ATTENTE D\'OPPOSITION (22j Restants)'}
                              </p>
                            </div>
                          </div>
                          <button className="px-4 py-2 bg-white/5 rounded-xl text-[10px] font-black group-hover:bg-[#00963F] group-hover:text-white transition-all">
                            DÉTAILS DOSSIER
                          </button>
                        </div>
                      ))}
                    </div>
                 </div>

                 <div className="bg-[#161B22] rounded-3xl border border-white/5 p-8">
                    <h2 className="text-lg font-black uppercase tracking-tight mb-8">HIÉRARCHIE D'ACCÈS MSP (HYPERLEDGER)</h2>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                      <AccessRole org="Ministère du Foncier" role="ADMIN_SUPREME" desc="Signature finale & Émission Titre" />
                      <AccessRole org="Direction Cadastre" role="VALIDATEUR_SIG" desc="Validation topologique arcgis" />
                      <AccessRole org="Ordre des Notaires" role="OFFICIER_CONF" desc="Vérification Identité & Fonds" />
                      <AccessRole org="Réseau Géomètres" role="DATA_PROPOSER" desc="Injection coordonnées GPS certifiées" />
                    </div>
                 </div>
              </div>

              <div className="space-y-8">
                 <div className="bg-[#3b82f6]/10 rounded-3xl border border-[#3b82f6]/20 p-8">
                    <div className="flex items-center gap-3 mb-6">
                      <Lock className="text-blue-500 w-5 h-5" />
                      <h3 className="font-black text-blue-500 uppercase text-sm tracking-widest">SÉCURITÉ ATOMIQUE</h3>
                    </div>
                    <p className="text-xs text-blue-500/80 leading-relaxed mb-6">
                      Le "FoncierChain Settlement" garantit que le transfert du NFT n'a lieu QUE si le Trésor Public, le Notaire et le Géomètre sont payés simultanément avec le Vendeur.
                    </p>
                    <div className="p-4 bg-blue-500/20 rounded-2xl flex items-center justify-between">
                      <span className="text-[10px] font-bold text-blue-500 uppercase">Status des Oracles</span>
                      <span className="px-3 py-1 bg-green-500/20 text-green-500 rounded-full text-[9px] font-black">OPÉRATIONNEL</span>
                    </div>
                 </div>
                 
                 <div className="bg-[#161B22] rounded-3xl border border-white/5 p-8">
                   <h3 className="font-black uppercase text-xs mb-6 text-white/50 tracking-widest leading-none">Répartition Usage Sol</h3>
                   <div className="h-[200px]">
                      <ResponsiveContainer width="100%" height="100%">
                        <PieChart>
                          <Pie 
                            data={landUsageData} 
                            innerRadius={60} 
                            outerRadius={80} 
                            paddingAngle={5} 
                            dataKey="value"
                          >
                            {landUsageData.map((entry, index) => (
                              <Cell key={`cell-${index}`} fill={entry.color} />
                            ))}
                          </Pie>
                        </PieChart>
                      </ResponsiveContainer>
                   </div>
                   <div className="space-y-3 mt-4">
                      {landUsageData.map(item => (
                        <div key={item.name} className="flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            <span className="w-2 h-2 rounded-full" style={{ backgroundColor: item.color }}></span>
                            <span className="text-[10px] font-bold text-white/60 uppercase">{item.name}</span>
                          </div>
                          <span className="text-xs font-black">{item.value}%</span>
                        </div>
                      ))}
                   </div>
                 </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </main>
    </div>
  );
};

const StatCard = ({ label, value, delta, icon }) => (
  <div className="bg-[#161B22] rounded-3xl border border-white/5 p-6 hover:border-[#00963F]/30 transition-all group">
    <div className="flex items-center justify-between mb-4">
      <div className="w-10 h-10 rounded-2xl bg-white/5 flex items-center justify-center group-hover:scale-110 transition-transform">
        {icon}
      </div>
      <span className={`text-[10px] font-black uppercase px-2 py-1 rounded-md ${delta.includes('+') ? 'bg-green-500/10 text-green-500' : 'bg-white/10 text-white/40'}`}>
        {delta}
      </span>
    </div>
    <p className="text-[10px] font-bold text-white/40 uppercase tracking-widest mb-1">{label}</p>
    <h3 className="text-xl font-black tracking-tight">{value}</h3>
  </div>
);

const WorkflowStep = ({ index, title, status, desc }) => {
  const isCompleted = status === 'COMPLETED';
  const isActive = status === 'ACTIVE';
  
  return (
    <div className={`flex gap-4 relative ${!isActive && 'opacity-60'}`}>
      <div className="flex flex-col items-center">
        <div className={`w-8 h-8 rounded-full flex items-center justify-center text-[10px] font-black ${isCompleted ? 'bg-[#00963F] text-white' : (isActive ? 'bg-blue-500 text-white shadow-[0_0_15px_rgba(59,130,246,0.5)]' : 'bg-white/10 text-white/30')}`}>
          {isCompleted ? <CheckCircle2 className="w-4 h-4" /> : index}
        </div>
        {index < 5 && <div className={`w-[2px] flex-1 my-1 ${isCompleted ? 'bg-[#00963F]' : 'bg-white/10'}`}></div>}
      </div>
      <div className="pb-4">
        <h4 className={`text-xs font-black uppercase tracking-tight ${isActive ? 'text-blue-400' : 'text-white'}`}>{title}</h4>
        <p className="text-[10px] text-white/40 mt-1 leading-relaxed">{desc}</p>
      </div>
    </div>
  );
};

const BottleneckList = () => (
  <div className="bg-[#161B22] rounded-3xl border border-white/5 p-8">
    <div className="flex items-center gap-3 mb-8">
      <AlertTriangle className="text-red-500 w-5 h-5" />
      <h2 className="text-lg font-black uppercase tracking-tight">ALERTE CONGO-GOUV (ANTI-CORRUPTION)</h2>
    </div>
    <div className="space-y-4">
      <div className="p-4 rounded-2xl bg-red-500/10 border border-red-500/20 flex items-center justify-between">
        <div>
          <p className="text-xs font-black text-red-500 uppercase">Mairie de Talangaï</p>
          <p className="text-[10px] text-red-400/60 font-medium">Temps Mort détecté: +5.2j de moyenne</p>
        </div>
        <div className="text-right">
          <p className="text-xs font-black text-red-500 uppercase tracking-widest">URGENT</p>
        </div>
      </div>
      <div className="p-4 rounded-2xl bg-yellow-500/10 border border-yellow-500/20 flex items-center justify-between">
        <div>
          <p className="text-xs font-black text-yellow-500 uppercase">Cadastre Pointe-Noire Zone B</p>
          <p className="text-[10px] text-yellow-400/60 font-medium">Audit SIG en cours (ArcGIS Portal Sync)</p>
        </div>
        <div className="text-right">
          <p className="text-xs font-black text-yellow-500 uppercase tracking-widest">AUDIT</p>
        </div>
      </div>
    </div>
  </div>
);

const RecentTransactions = ({ parcels }) => (
  <div className="bg-[#161B22] rounded-3xl border border-white/5 p-8">
    <div className="flex items-center justify-between mb-8">
      <h2 className="text-lg font-black uppercase tracking-tight">LEDGER TEMPS RÉEL</h2>
      <button className="text-[10px] font-black text-[#00963F] border border-[#00963F]/30 px-3 py-1 rounded-lg">VOIR BLOCKS</button>
    </div>
    <div className="space-y-4">
      {parcels.slice(0, 4).map(p => (
        <div key={p.id} className="flex items-center justify-between p-3 hover:bg-white/5 rounded-xl transition-all">
          <div className="flex items-center gap-3">
             <div className="w-8 h-8 rounded-lg bg-green-500/10 flex items-center justify-center">
                <ArrowRightLeft className="w-4 h-4 text-green-500" />
             </div>
             <div>
               <p className="text-xs font-bold leading-none">Mut: 0x{p.hash.slice(2, 10).toUpperCase()}</p>
               <p className="text-[10px] text-white/40 mt-1 uppercase font-bold">{p.neighborhood}</p>
             </div>
          </div>
          <div className="text-right">
            <p className="text-xs font-black">{p.area}m²</p>
            <p className="text-[9px] text-[#00963F] font-bold uppercase">Validé</p>
          </div>
        </div>
      ))}
    </div>
  </div>
);

const SearchButton = ({ icon, label }) => (
  <button className="bg-[#161B22]/90 backdrop-blur-md border border-white/10 p-4 rounded-2xl hover:bg-[#00963F] hover:text-white transition-all shadow-xl group flex items-center gap-4">
    <div className="w-8 h-8 rounded-lg bg-white/5 flex items-center justify-center group-hover:bg-white/20">
      {React.cloneElement(icon as React.ReactElement, { className: 'w-4 h-4' })}
    </div>
    <span className="text-[10px] font-black uppercase tracking-widest text-white">{label}</span>
  </button>
);

const AccessRole = ({ org, role, desc }) => (
  <div className="p-5 rounded-2xl bg-white/5 border border-white/5 hover:border-blue-500/30 transition-all group">
    <div className="flex items-center justify-between mb-4">
      <div className="w-10 h-10 rounded-xl bg-blue-500/10 flex items-center justify-center">
        <ShieldCheck className="text-blue-500 w-5 h-5" />
      </div>
      <div className="px-2 py-1 bg-blue-500/20 rounded text-[8px] font-black text-blue-400">MSP: APPROVED</div>
    </div>
    <h4 className="text-xs font-black uppercase tracking-tight group-hover:text-blue-400 transition-colors">{org}</h4>
    <p className="text-[10px] text-blue-500 font-bold uppercase mt-1 mb-2 tracking-widest">{role}</p>
    <p className="text-[10px] text-white/30 leading-relaxed">{desc}</p>
  </div>
);

export default App;
