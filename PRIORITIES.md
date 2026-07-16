# AI-NO Refactoring — Priority Checklist

> Track progress here. Check off items as they're completed.

---

## P0 — Critical (Must complete first)

### Phase 1: Foundation
- [ ] 1.1 Create `engine/exceptions.py` with error hierarchy
- [ ] 1.2 Create `engine/result.py` helper
- [ ] 1.3 Fix `BaseNode` — extract `component_id`, remove inline DB query, remove silent error swallowing
- [ ] 1.4 Make DataLoader, Splitter, FitTransform inherit BaseNode
- [ ] 1.5 Delete dead code (`Payload`, `FolderHandler`, `base_service.py`)

### Phase 2: DRY
- [ ] 2.1 Merge 4 PayloadBuilder classes into 1
- [ ] 2.2 Extract shared ActionMixin for load-dispatch pattern
- [ ] 2.3 Rewrite template system to use components.json + DB (remove schema.xlsx)
- [ ] 2.4 Remove `schema.xlsx` references from `const_.py`

---

## P1 — High (Complete after P0)

### Phase 3: API Surface
- [ ] 3.1 Delete `NodeCompatibilityMapper`
- [ ] 3.2 Rewrite `NodeResponse` with clean field names
- [ ] 3.3 Update `NodeCreate`/`NodeUpdate` request schemas
- [ ] 3.4 Update `_helpers.py` — async session, remove mapper
- [ ] 3.5 Fix endpoint inconsistencies (workflow response_model, ImportProjectRequest, etc.)

### Phase 4: Security
- [ ] 4.1 Add JWT auth (`core/auth.py`)
- [ ] 4.2 Wire auth to all protected endpoints
- [ ] 4.3 Fix path traversal in `io.py` and `components.py`
- [ ] 4.4 Replace `subprocess.run()` with async version
- [ ] 4.5 Add logging to silent except blocks

---

## P2 — Medium (Deferred)

### Phase 5: Engine Architecture
- [ ] 5.1 Add `execute()` method to BaseNode (move out of `__init__`)
- [ ] 5.2 Unify NodeService as single entry point
- [ ] 5.3 Make engine repositories async

---

## P3 — Low (Cleanup)

### Phase 6: Cleanup
- [ ] 6.1 Move TF env var to `main.py` startup
- [ ] 6.2 Add test suite (`tests/`)
- [ ] 6.3 Update AGENTS.md
- [ ] 6.4 Remove duplicate `alembic.ini`

---

## Notes

- Template system (save/load) is kept — only persistence mechanism changes from Excel to DB
- `website/backend/` stays — it's for documentation/viewing, separate from main app
- Constructor-as-executor refactoring deferred to Phase 5
- Flutter frontend will be updated separately to consume new field names
