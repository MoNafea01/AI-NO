# AI-NO — Development Roadmap

## Current State

- **44 node types**: 24 sklearn models, 12 preprocessors, 9 NN layers, 7 action nodes, 4 data/IO, 2 custom
- **Local-only execution**: Celery + RabbitMQ + Redis, no cloud support
- **No limits**: unlimited projects, workflows, snapshots, caches per user
- **No billing**: zero payment infrastructure
- **No marketplace**: no schema selling or sharing
- **GenAI config exists** (Groq/Cohere/OpenAI/Qdrant) but zero GenAI nodes implemented
- **Docker Compose**: 8 services (FastAPI, Celery, Postgres, Qdrant, RabbitMQ, Redis, Nginx, Flower)

---

## Phase 1 — Free Tier Limits (Self-Hosted Baseline)

### User Model Changes
- [ ] Add `tier` enum column to User (`free`, `pro`, `enterprise`)
- [ ] Add `max_projects` (default 30), `max_workflows_per_project` (default 1), `max_snapshots_per_workflow` (default 5), `max_cache_per_workflow` (default 100)
- [ ] Create Alembic migration for new columns

### Quota Enforcement
- [ ] Create `app/core/quota.py` — `check_quota(user_id, resource)` helper
- [ ] Add project count check before `POST /projects/` (max 30 for free tier)
- [ ] Add workflow count check before `POST /projects/{id}/workflows/` (max 1 per project for free tier)
- [ ] Update snapshot `create_snapshot()` limit from hardcoded 10 → configurable via user tier (5 for free)
- [ ] Update cache eviction from hardcoded 10 → configurable per workflow (100 for free, evict oldest 30)
- [ ] Add `QuotaExceeded` exception + API error response

### Quota Response Headers
- [ ] Add `X-Quota-Limit`, `X-Quota-Remaining`, `X-Quota-Reset` headers to relevant endpoints

---

## Phase 2 — GenAI Nodes

### LLM Client Abstraction
- [ ] Create `app/engine/genai/llm_client.py` — unified client wrapping Groq/OpenAI/Cohere
- [ ] Backend selection via `GENERATION_BACKEND` config (already exists in `core/config.py`)
- [ ] Token counting and cost estimation per call
- [ ] Streaming support (SSE for token-by-token output)

### GenAI Engine Nodes
- [ ] `text_generator` — prompt → text completion (Groq/OpenAI)
- [ ] `chat_completion` — multi-turn conversation with system prompt
- [ ] `text_embedder` — text → vector embeddings (Cohere/OpenAI)
- [ ] `vector_store_upsert` — store embeddings in Qdrant
- [ ] `vector_store_retrieve` — semantic search against Qdrant
- [ ] `rag_chain` — retriever + generator pipeline
- [ ] `prompt_template` — templated prompts with `{variable}` interpolation
- [ ] `text_splitter` — chunk text for embedding (recursive character splitter)
- [ ] `summarizer` — text summarization node
- [ ] `classifier_llm` — zero-shot text classification

### GenAI Registry + Validation
- [ ] Add all GenAI nodes to `NODE_REGISTRY` in `registry.py`
- [ ] Add validation rules to `validation.py`
- [ ] Create `app/engine/genai/` module with engine classes
- [ ] Add GenAI defaults to `defaults.py`

### GenAI Token Tracking
- [ ] Create `UsageEvent` model (user_id, node_type, tokens_in, tokens_out, cost_usd, timestamp)
- [ ] Track token usage per execution in `_execute_node()`
- [ ] Aggregate usage for billing

---

## Phase 3 — Cloud Execution (Pay-as-You-Go)

### Worker Infrastructure
- [ ] Create `Worker` model (id, user_id, name, type [cpu/gpu], specs JSON, status, last_heartbeat)
- [ ] Worker registration endpoint (`POST /workers/register`)
- [ ] Worker heartbeat endpoint (`PUT /workers/heartbeat`)
- [ ] Worker discovery — scheduler matches jobs to available workers

### Remote Execution
- [ ] Create `CloudExecutionQueue` — route jobs to remote workers via Redis Streams or NATS
- [ ] Remote worker authentication (token-based)
- [ ] File transfer for remote workers (shared S3-compatible storage or .pkl upload)
- [ ] Result streaming via WebSocket or SSE (replace polling for cloud runs)
- [ ] Worker health monitoring + auto-failover

### Compute Billing
- [ ] Track compute seconds per execution (start_time → end_time in WorkflowRun)
- [ ] Map worker type (cpu/gpu) to per-second pricing
- [ ] Create `ComputeInvoice` model (user_id, run_id, compute_seconds, rate, total_usd)
- [ ] Usage dashboard endpoint (`GET /billing/usage`)

### Execution Mode Toggle
- [ ] Add `execution_mode` field to WorkflowRun (`local` | `cloud`)
- [ ] API endpoint to choose execution mode at run time
- [ ] Fallback: if no cloud workers available, queue locally

---

## Phase 4 — Payment & Billing (Stripe Integration)

### DB Models
- [ ] `Plan` — name, price, max_projects, max_workflows, max_executions, features JSON
- [ ] `Subscription` — user_id, plan_id, status, stripe_subscription_id, current_period_end
- [ ] `PaymentMethod` — user_id, stripe_payment_method_id, is_default
- [ ] `Invoice` — user_id, amount, status, stripe_invoice_id, line_items JSON

### Stripe Integration
- [ ] Stripe SDK setup in `app/core/billing.py`
- [ ] Checkout session creation (`POST /billing/checkout`)
- [ ] Webhook endpoint (`POST /billing/webhooks/stripe`) handling:
  - `checkout.session.completed`
  - `invoice.paid`
  - `customer.subscription.updated`
  - `customer.subscription.deleted`
- [ ] Subscription lifecycle management (create, upgrade, downgrade, cancel)

### API Endpoints
- [ ] `GET /billing/plans` — list available plans
- [ ] `POST /billing/subscribe` — create subscription
- [ ] `GET /billing/subscription` — current subscription status
- [ ] `POST /billing/cancel` — cancel subscription
- [ ] `GET /billing/invoices` — invoice history
- [ ] `GET /billing/usage` — usage breakdown

### Free Tier vs Paid
- [ ] Free tier: 30 projects, 1 workflow/project, 5 snapshots, 100 caches/workflow, local execution only
- [ ] Pro tier: unlimited projects/workflows, 50 snapshots, 1000 caches, cloud execution included
- [ ] Enterprise: custom limits, priority support, on-premise deployment

---

## Phase 5 — Marketplace (Schema Selling)

### DB Models
- [ ] `MarketplaceItem` — seller_id, name, description, price, category, snapshot JSON, preview_image, download_count, rating, status
- [ ] `MarketplacePurchase` — buyer_id, item_id, price_paid, purchased_at
- [ ] `MarketplaceReview` — user_id, item_id, rating, text
- [ ] `SellerProfile` — user_id, display_name, total_earnings, stripe_connect_account_id

### Workflow Export/Import
- [ ] `POST /workflows/{id}/export` — serialize workflow as portable JSON (nodes, connections, params, component refs)
- [ ] `POST /workflows/{id}/import` — import from exported JSON, remap IDs
- [ ] Export format versioning for backward compatibility

### Marketplace API
- [ ] `POST /marketplace/items` — publish a schema
- [ ] `GET /marketplace/items` — browse/search with filters (category, price, rating)
- [ ] `GET /marketplace/items/{id}` — item detail + reviews
- [ ] `POST /marketplace/items/{id}/purchase` — buy a schema
- [ ] `POST /marketplace/items/{id}/import` — import purchased schema into project
- [ ] `GET /marketplace/sales` — seller dashboard (earnings, download stats)
- [ ] `POST /marketplace/items/{id}/review` — leave a review

### Payment Splitting (Stripe Connect)
- [ ] Seller onboarding via Stripe Connect
- [ ] Platform commission (e.g., 20%) on each sale
- [ ] Automatic payout to sellers on schedule
- [ ] Refund handling

### Content Moderation
- [ ] Published schemas require admin approval
- [ ] Review queue endpoint (`GET /admin/marketplace/pending`)
- [ ] Approve/reject workflow

---

## Phase 6 — Additional ML/DL Modules

### Sklearn Additions
- [ ] Feature selection: `SelectKBest`, `mutual_info`, `chi2`
- [ ] Dimensionality reduction: `PCA`, `TSNE`, `UMAP`
- [ ] Clustering: `KMeans`, `DBSCAN`, `AgglomerativeClustering`
- [ ] Model selection: `GridSearchCV`, `RandomizedSearchCV`, `cross_val_score`
- [ ] Pipeline: `Pipeline`, `ColumnTransformer`
- [ ] Metrics: add `confusion_matrix`, `classification_report`, `roc_auc`

### Deep Learning Extensions
- [ ] Recurrent layers: `LSTM`, `GRU`, `SimpleRNN`
- [ ] Attention: `MultiHeadAttention`, `TransformerBlock`
- [ ] Batch normalization: `BatchNormalization`, `LayerNormalization`
- [ ] Optimizers: expose more Keras optimizers (SGD, RMSprop, Adagrad)
- [ ] Loss functions: expose more Keras losses
- [ ] Callbacks: EarlyStopping, ModelCheckpoint, TensorBoard
- [ ] Transfer learning: pretrained model loader (ResNet, BERT)

### Data Processing
- [ ] Feature engineering: `PolynomialFeatures`, `InteractionOnlyFeatures`
- [ ] Text preprocessing: `TfidfVectorizer`, `CountVectorizer`, `HashingVectorizer`
- [ ] Time series: `TimeSeriesSplit`, lag features, rolling stats
- [ ] Image loading: `image_dataset_from_directory`, data augmentation layers

---

## Phase 7 — Platform Hardening

### Security
- [ ] API key management for LLM providers (encrypted storage)
- [ ] Prompt injection protection for GenAI nodes
- [ ] Input sanitization on all user-provided params
- [ ] CORS configuration for production
- [ ] Rate limiting applied to all endpoints (currently defined but unused)
- [ ] Audit logging for sensitive operations

### Observability
- [ ] Structured logging with correlation IDs
- [ ] Prometheus metrics endpoint
- [ ] OpenTelemetry tracing for execution flows
- [ ] Alerting for failed executions, quota breaches

### Deployment
- [ ] TLS termination in Nginx
- [ ] Horizontal auto-scaling for Celery workers
- [ ] Database connection pooling tuning
- [ ] S3-compatible object storage for .pkl files (instead of local volume)
- [ ] Health check endpoints for all services
- [ ] Backup strategy for PostgreSQL

### Developer Experience
- [ ] Swagger/OpenAPI docs auto-generation (FastAPI built-in, enable in production)
- [ ] Pre-commit hooks for ruff (already have `.pre-commit-config.yaml`)
- [ ] Integration test suite for GenAI nodes
- [ ] Load testing script for execution pipeline
