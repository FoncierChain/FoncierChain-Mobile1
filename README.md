# FancierChain - Decentralized Land Governance & Property Rights

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Flutter](https://img.shields.io/badge/Platform-Flutter-blue.svg)](https://flutter.dev)
[![Backend: Django](https://img.shields.io/badge/Backend-Django-green.svg)](https://www.djangoproject.com/)
[![Blockchain: Hyperledger Fabric](https://img.shields.io/badge/Blockchain-Hyperledger%20Fabric-orange.svg)](https://www.hyperledger.org/projects/fabric)

FancierChain is a next-generation land governance platform designed to solve the "Oracle Problem" in property registration, specifically tailored for the urban landscape of **Brazzaville**. By combining **Self-Sovereign Identity (SSI)**, **Hyperledger Fabric Blockchain**, and a mandatory **3-step validation protocol**, FancierChain ensures that land titles are transparent, immutable, and locally verified.

---

## 🚀 Key Features

- **Triple Validation Protocol:** Mandatory sequential signing by a Certified Surveyor (`GEOMETRE`), Community Leader (`COMMUNITY`), and State Land Agent (`AGENT`).
- **Blockchain Provenance:** Full chain of custody for every plot of land stored on a distributed ledger.
- **Sovereign Identity (SSI):** X.509 certificate-based authentication for institutional actors.
- **Real-time GIS & Analytics:** Interactive map and district-level reporting for urban planning.
- **On-Chain Auctions:** Secure land auctions with automated ownership transfer.

---

## 🏗️ Architecture

- **Frontend:** Flutter (Mobile & Web) for a seamless cross-platform experience.
- **Backend:** Django REST Framework (Python) handling business logic and API routing.
- **Blockchain:** Hyperledger Fabric for the immutable ledger and smart contracts (Chaincode in Go).
- **Database:** MySQL for caching, user management, and high-performance querying.

---

## 🛠️ Installation & Setup

### 1. Blockchain Network (Local)

FancierChain interfaces with a Hyperledger Fabric test network.

```bash
# Clone the network samples
curl -sSL https://bit.ly/2ysbOFE | bash -s

# Startup the network and channel
cd fabric-samples/test-network
./network.sh up createChannel -c fancierchannel

# Deploy the Smart Contract
./network.sh deployCC -ccn land -ccp ../../../chaincode/land -ccl go
```

### 2. Backend & Database (Docker)

The fastest way to launch the full stack is via Docker Compose.

```bash
# Clone the repository
git clone https://github.com/your-username/fancierchain.git
cd fancierchain

# Configure environment
cp .env.example .env

# Launch services
docker-compose up --build -d

# Apply migrations
docker-compose exec web python manage.py migrate
```

### 3. Frontend Development

```bash
# Install dependencies
flutter pub get

# Run the application (Internal Server)
flutter run -d chrome
```

---

## 📚 API Documentation

Detailed documentation is available within the application in the **Help Center > API & Integration** section.

**Base URL:** `http://localhost:3000/api/v1/`

| Endpoint | Method | Description |
| :--- | :--- | :--- |
| `/land/draft/` | `POST` | Initiate land registration (Surveyor) |
| `/land/validate/` | `PATCH` | Community field verification |
| `/land/finalize/` | `PATCH` | State finalization and NFT minting |
| `/stats/` | `GET` | Dashboard metrics and land usage |

---

## 🛡️ Security & Role-Based Access Control

Institutional roles are enforced via **ABAC (Attribute-Based Access Control)** in the Hyperledger Fabric chaincode.

- **GEOMETRE:** Can only initiate `DRAFT` records.
- **COMMUNITY:** Can only transition records from `DRAFT` to `VALIDATED`.
- **AGENT:** Can finalize records and execute ownership transfers (Mutations).

---

## 🤝 Contribution

We welcome contributions from the open-source community. Please read our [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Developed for the modernization of Land Governance in the Republic of Congo.** 🇨🇬
