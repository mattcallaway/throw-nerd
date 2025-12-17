# League Sync Feature - Manual Test Checklist

## 1. Setup & Auth
- [ ] Install app.
- [ ] Install app.
- [ ] Connect Google Drive:
    - [ ] Go to Home -> Settings -> Connected Accounts.
    - [ ] Click "Connect" on Google Drive.
    - [ ] Verify "DartLeagues" folder created in Drive (after creating a league).
- [ ] Connect Dropbox:
    - [ ] Create League -> Select Dropbox.
    - [ ] Verify auth flow (mock/http) works if token provided or check error handling.

## 2. League Management
- [ ] **Create League**:
    - [ ] Click "+" in My Leagues.
    - [ ] Enter Name "Test League A".
    - [ ] Select Provider: Google Drive.
    - [ ] Verify "Test League A" appears in list.
    - [ ] Verify local DB creation (SQL inspect or logs).
    - [ ] Verify remote folder `DartLeagues/Test League A/league.json` exists.

- [ ] **Join League**:
    - [ ] On Device B (or clear data), click "Join League".
    - [ ] Enter Drive Folder ID (from previous step).
    - [ ] Verify "Test League A" appears.
    - [ ] Verify metadata matches.

## 3. Match Sync
- [ ] **Play Match**:
    - [ ] Select League "Test League A".
    - [ ] Start Match (X01).
    - [ ] Play to finish.
    - [ ] Verify "Winner" screen.
    - [ ] Check Logs for "Uploading match...".
    
- [ ] **Verify Upload**:
    - [ ] Check Drive: `DartLeagues/Test League A/matches/<timestamp_id>.json`.
    - [ ] Open JSON, verify players, scores, winnerId.

- [ ] **Verify Download (List)**:
    - [ ] On Device B (joined league).
    - [ ] Go to League Dashboard (Needs Refresh).
    - [ ] Verify SyncService downloads the new match.
    - [ ] Verify Match appears in League History.

## 4. Resilience
- [ ] Offline Mode:
    - [ ] Turn off WiFi. Play Match.
    - [ ] Verify local stats updated.
    - [ ] Turn on WiFi. Trigger Sync. Verify upload.
    - [ ] (Note: Offline queueing requires background task or app resume hook, currently `uploadMatchForLeague` calls immediately. Failures should be retried manually or Next Launch).
