# BankEncore
[![CI](https://github.com/BankEncore/bankencore_2510/actions/workflows/ci.yml/badge.svg)](https://github.com/BankEncore/bankencore_2510/actions/workflows/ci.yml)

BankEncore is a modular core-banking platform built with **Ruby on Rails 8**, **PostgreSQL 16**, and **Tailwind CSS 4**.  
It is designed for clarity, auditability, and extensibility—each business domain (Parties, Products, Ledger, Compliance, etc.) lives in its own namespace.

---

## ⚙️ Tech Stack

| Component | Version | Purpose |
|------------|----------|----------|
| Ubuntu | 24.04 LTS | Host environment |
| Ruby | 3.4.7 | Language runtime |
| Rails | 8.0.3 | Web framework |
| PostgreSQL | 16.10 | Primary database |
| Tailwind CSS | 4.1.3 | Utility-first styling |
| DaisyUI | 4 | Component library for Tailwind |
| Vite Rails | latest | JavaScript and asset bundler |

---

## 🏗️ Setup (Developer VM)

```bash
# Clone and enter the project
git clone git@github.com:BankEncore/bankencore_2510.git
cd bankencore_2510

# Ruby / Gem setup
rbenv install 3.4.7
rbenv local 3.4.7
bundle install

# Node / npm setup
nvm install --lts
npm install

# Database
sudo -u postgres createuser -s $USER
createdb bankencore_development
bundle exec rails db:prepare

# Start dev services
npm run tailwind:build &
bin/rails server -b 0.0.0.0 -p 3000
````

Visit: **[http://192.168.1.43:3000](http://192.168.1.43:3000)**

---

## 🔐 Environment Variables

Create a `.env` file (never commit it):

```dotenv
RAILS_ENV=development
PGUSER=bankencore
PGPASSWORD=devpass
PGHOST=127.0.0.1
PGPORT=5432
PGDATABASE=bankencore_development
SECRET_KEY_BASE=<output of `bin/rails secret`>
```

---

## 🔒 Security Model

* **Authentication:** planned via [Rodauth-Rails](https://github.com/janko/rodauth-rails) or Devise.
* **Authorization:** [Pundit](https://github.com/varvet/pundit), default-deny policies.
* **Encryption:** [Active Record Encryption](https://guides.rubyonrails.org/active_record_encryption.html) for sensitive data.
* **Rate-Limiting:** [Rack-Attack](https://github.com/rack/rack-attack).
* **Versioning:** [PaperTrail](https://github.com/paper-trail-gem/paper_trail).
* **Money:** [Money-Rails](https://github.com/RubyMoney/money-rails).

---

## 🧩 Modules (planned)

| Domain              | Description                                      |
| ------------------- | ------------------------------------------------ |
| **CIF / Party**     | Customer, organization, and relationship records |
| **Products**        | Account and loan product catalog                 |
| **Core & Ledger**   | Transactions, postings, holds, balances          |
| **Deposits**        | DDA/NOW/Savings/CD rules                         |
| **Loans & Credit**  | Origination, booking, schedules                  |
| **Branch & Teller** | Cash handling, vault moves, EOD close            |
| **Back Office**     | File imports, exceptions, adjustments            |
| **Compliance**      | KYC, screening, beneficial ownership             |

---

## 🧪 Testing

```bash
bundle exec rspec     # or rails test if using minitest
```

---

## 📦 Project Utilities

| Script                   | Purpose                                     |
| ------------------------ | ------------------------------------------- |
| `scripts/cat_project.sh` | Concatenate project source files for review |
| `scripts/cat_paths.sh`   | Concatenate specific paths or globs         |
| `bin/dev`                | Start Rails + Vite + Tailwind watchers      |

---

## 📜 License

Copyright © 2025 BankEncore.
All rights reserved. Proprietary software; not for redistribution.

---

## 🧭 Contributing

1. Create a feature branch from `dev`.
2. Follow the [Rails style guide](https://github.com/rails/rails-contributors).
3. Submit a pull request; all changes require one review and green tests.

---

## 🧰 Admin Checklist (initial deploy)

* [ ] Secure `.env` and master key outside Git.
* [ ] Run `bin/rails db:encryption:init`.
* [ ] Create first ops_admin user.
* [ ] Enable firewall: allow 22, 3000 (LAN only).
* [ ] Push to GitHub via SSH.

---

**BankEncore — Modular Banking Infrastructure in Ruby on Rails**
