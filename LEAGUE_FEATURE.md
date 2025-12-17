# League Feature Documentation

## Overview
The League feature allows users to share matches and leaderboards using a file-based synchronization mechanism on existing Cloud Storage (Dropbox/Google Drive). It supports "Informal" (adhoc) and "Formal" (season-based) leagues.

## Data Structure (Remote)
- **Root Folder**: `/DartLeagues/<LeagueName_or_ID>/`
  - `league.json`: League metadata (name, mode, ownerId, activeSeasonId, bannedMemberIds).
  - `matches/`: Folder containing immutable `match_<timestamp>_<id>.json` files.
  - `seasons/`: (Formal Mode)
    - `season_<id>.json`: Season definition (start/end dates).
    - `schedule_<id>.json`: Schedule for the season (weeks, match-ups).
    - `locations.json`: List of league-approved locations.

## League Modes
1. **Informal**: Default. Ad-hoc matches. Leaderboard is aggregate of all time.
2. **Formal**: Organized play.
   - **Seasons**: Matches belong to a season.
   - **Schedule**: (Optional) Enforces specific match-ups.
   - **Rules**: Can enforce "X01 Only" or specific formats.

## Governance
- **Ownership**: The creator (`ownerId`) has admin rights.
- **Admin Actions**:
  - **Rename League**: Updates `league.json`.
  - **Manage Members**: Owners can "Ban" members. Banned members' future uploads are marked as `ignored` during sync.
  - **Manage Seasons**: Create and activate new seasons.
  - **Rules**: (Planned) define game types.

## Sync Logic
### 1. Metadata Sync
- App downloads `league.json`. Updates local league details (name, mode, bans).
- App downloads `seasons/` content and updates local `Seasons`, `Locations`, `Schedule` tables.

### 2. Match Sync
- App lists `matches/` folder.
- **Import**: Downloads new match files.
  - Checks if `uploadedBy` matches a banned ID -> Marks `complianceStatus = 'ignored'`.
  - Checks if match follows rules (if Formal) -> Marks `complianceStatus`.
- **Upload**: When user finishes a match:
  - If connected to league, uploads `MatchExport` JSON.
  - Checks if match is valid for current Season/Schedule.

## Database Schema (Drift)
- `Leagues`: Stores local copy of league metdata.
- `Matches`: Added `leagueId`, `source`, `complianceStatus`, `seasonId`.
- `Seasons`: Stores season definitions.
- `ScheduleGameDays` / `ScheduleMatches`: Stores the schedule.
- `Locations`: Added `leagueId` for league-specific locations.

## Provider Setup
### Google Drive
- Application specific folder or root folder access.
- `drive.file` scope.
- Uses File IDs for identifying folders/files.

### Dropbox
- App Folder permission recommended.
- Uses Paths for identifying files.

## Troubleshooting
- **Sync Fails**: Check internet and Authentication. Re-connect in Settings > Accounts.
- **Ignored Matches**: Banned players or rule violations result in matches visible but flagged "Ignored".
- **Missing Seasons**: Ensure you are the Owner to create seasons, or sync if they exist remotely.
