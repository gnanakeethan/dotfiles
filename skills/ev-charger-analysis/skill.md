---
name: ev-charger-analysis
description: "Analyze and compare EV charger configurations to select the best option. Evaluates power, connectors, OCPP support, certifications, price, and Sri Lanka grid compatibility. Use when comparing charger specs, evaluating Alibaba/supplier listings, or selecting hardware for Cloud Parallax CSMS deployment."
argument-hint: "[charger specs or 'browse' to analyze open browser tabs]"
allowed-tools: "Bash, Read, Glob, Grep, WebSearch, WebFetch, mcp__claude-in-chrome__tabs_context_mcp, mcp__claude-in-chrome__get_page_text, mcp__claude-in-chrome__read_page, mcp__claude-in-chrome__navigate, mcp__claude-in-chrome__tabs_create_mcp, mcp__claude-in-chrome__javascript_tool, mcp__claude-in-chrome__find"
---

# EV Charger Configuration Analyzer

Analyze and compare EV charger configurations to recommend the best option for Cloud Parallax CSMS deployment in Sri Lanka.

## Context

Cloud Parallax operates an OCPP 1.6J / 2.0.1 dual-stack CSMS targeting EV charging in Sri Lanka. Charger hardware must be compatible with the platform and local grid conditions.

### Sri Lanka Grid & Market Constraints

| Parameter | Value |
|-----------|-------|
| Grid voltage | 230V single-phase / 400V three-phase |
| Grid frequency | 50 Hz |
| Common residential supply | Single-phase 230V, 15A-60A |
| Commercial supply | Three-phase 400V |
| Dominant EV connector (cars) | Type 2 (IEC 62196-2) / CCS2 (Combo 2) |
| Secondary connector | GBT (Chinese-made EVs, growing segment) |
| Legacy connector | Type 1 / CCS1 (rare, older Japanese imports) |
| Climate | Tropical — high humidity, 25-35 degC year-round, monsoon rain |
| Required IP rating | IP65 minimum (outdoor), IP54 (sheltered indoor) |

### OCPP Requirements for Cloud Parallax

The CSMS supports both OCPP 1.6J and OCPP 2.0.1. Chargers MUST support at least OCPP 1.6J over WebSocket (JSON). OCPP 2.0.1 support is a significant advantage for:
- Device management (firmware updates, diagnostics)
- ISO 15118 Plug & Charge readiness
- Smart charging profiles
- Transaction event-based reporting

### Critical Evaluation Criteria (weighted)

| # | Criterion | Weight | What to check |
|---|-----------|--------|---------------|
| 1 | **OCPP support** | 30% | Must have OCPP 1.6J minimum. Check if firmware truly supports OCPP or if it's just marketing. OCPP 2.0.1 is a major plus. |
| 2 | **Connector type** | 20% | Type 2 + CCS2 is ideal for Sri Lanka. GBT is acceptable for Chinese EVs. Type 1/CCS1 has limited local use. |
| 3 | **Power rating** | 15% | 7kW (single-phase home), 11kW (three-phase home/workplace), 22kW (commercial/destination). Match to use case. |
| 4 | **Build quality & IP rating** | 10% | IP65+ for outdoor tropical use. CE/TUV/CB certification indicates safety testing. |
| 5 | **Connectivity** | 10% | WiFi + Ethernet preferred. 4G/SIM is a plus for remote sites. Ethernet is most reliable for OCPP. |
| 6 | **Price / value** | 10% | Total cost including shipping, duties (~12-15% import duty + 18% VAT in Sri Lanka), and any MOQ requirements. |
| 7 | **Smart features** | 5% | RFID, energy meter (MID-certified), load balancing, scheduling, display/LED status. |

## Dispatch on $ARGUMENTS

| Argument | Action |
|----------|--------|
| *(empty)* | Ask the user to provide charger specs or URLs to analyze |
| `browse` | Read current browser tabs to find charger listings and analyze them |
| `<specs>` | Analyze the provided charger specifications text |
| `compare` | Compare all chargers discussed so far in the conversation |

## Analysis Workflow

### Step 1: Gather Specifications

For each charger, extract or research:
- **Model name & manufacturer**
- **Power output**: kW rating, voltage, amperage
- **Connector types**: Type 1, Type 2, GBT, CCS1, CCS2, CHAdeMO
- **OCPP version**: 1.6J, 2.0.1, or none
- **Communication**: WiFi, Ethernet, 4G, Bluetooth
- **Certifications**: CE, TUV, CB, UL, FCC, IP rating
- **Authentication**: RFID, app, plug-and-charge
- **Energy metering**: Built-in meter, MID-certified?
- **Smart charging**: Load balancing, scheduling, power sharing
- **Physical**: Wall-mount, pedestal, portable; cable length
- **Price**: Unit price, MOQ, shipping estimate

If specs are incomplete, use WebSearch to look up the manufacturer's product page or datasheet. Search for `"<model name>" OCPP specifications datasheet` to verify OCPP claims.

### Step 2: Verify OCPP Claims

Many cheap chargers claim "OCPP support" in listings but don't actually implement it. Red flags:
- No mention of OCPP version (1.6 vs 2.0.1)
- No WebSocket endpoint configuration in the charger's admin panel
- No mention of OCPP in the actual product manual/datasheet (only in the listing title)
- Manufacturer has no OCPP certification or test reports

Green flags:
- Specific OCPP version stated (e.g., "OCPP 1.6J" not just "OCPP")
- OCA (Open Charge Alliance) membership or certification
- OCTT test results available
- Firmware update capability over OCPP
- Configurable OCPP backend URL in charger settings

### Step 3: Score & Compare

For each charger, produce a score card:

```
## [Charger Name] — [Manufacturer]
Price: $XXX | Power: XXkW | Connector: Type 2/CCS2

| Criterion          | Score (1-10) | Weight | Weighted |
|--------------------|-------------|--------|----------|
| OCPP support       |      X      |  30%   |   X.X    |
| Connector type     |      X      |  20%   |   X.X    |
| Power rating       |      X      |  15%   |   X.X    |
| Build quality/IP   |      X      |  10%   |   X.X    |
| Connectivity       |      X      |  10%   |   X.X    |
| Price/value        |      X      |  10%   |   X.X    |
| Smart features     |      X      |   5%   |   X.X    |
| **TOTAL**          |             |        | **X.X**  |

Pros:
- ...

Cons:
- ...

OCPP Verdict: [Verified / Likely / Unverified / Dubious]
Sri Lanka Fit: [Excellent / Good / Acceptable / Poor]
```

### Step 4: Recommendation

After scoring all chargers, provide:

1. **Ranked list** from best to worst overall score
2. **Best for each use case**:
   - Best for home charging (single-phase, 7kW)
   - Best for workplace/destination (three-phase, 11-22kW)
   - Best for commercial/public (22kW+, robust OCPP)
3. **Risk assessment**: Highlight any chargers where OCPP support is unverified
4. **Landed cost estimate**: Unit price + ~30% (shipping + Sri Lanka duties + VAT)
5. **Final recommendation** with reasoning

## Scoring Guidelines

### OCPP Support (30%)
- 10: OCPP 2.0.1 + 1.6J, OCA certified, OCTT tested
- 8: OCPP 1.6J verified with configurable backend URL
- 6: OCPP 1.6J claimed, manufacturer seems credible
- 4: "OCPP" mentioned but no version specified
- 2: OCPP mentioned only in listing title, not in specs
- 0: No OCPP support

### Connector Type (20%)
- 10: Type 2 socket + CCS2 (covers all modern EVs in Sri Lanka)
- 8: Type 2 socket only (covers most EVs)
- 6: GBT + Type 2 (dual, covers Chinese + European EVs)
- 4: GBT only (Chinese EVs only)
- 2: Type 1 / CCS1 (limited local compatibility)
- 0: Proprietary or incompatible connector

### Power Rating (15%)
- Score based on match to intended use case
- 10: Perfect match (e.g., 22kW for commercial destination charging)
- 7: Usable but not optimal (e.g., 7kW for commercial)
- 4: Underpowered or overpowered for the use case

### Build Quality & IP Rating (10%)
- 10: IP67+, TUV/CB certified, metal housing, quality brand
- 8: IP65, CE certified, durable construction
- 6: IP54, basic CE, plastic housing but adequate
- 4: Low IP rating, no credible certification
- 0: No IP rating, no certification

### Connectivity (10%)
- 10: WiFi + Ethernet + 4G
- 8: WiFi + Ethernet
- 6: WiFi only
- 4: 4G only
- 2: Bluetooth only
- 0: No connectivity

### Price/Value (10%)
- Score relative to features offered vs. competitors
- 10: Excellent value — low price with strong features
- 5: Fair price for features
- 1: Overpriced for what's offered

### Smart Features (5%)
- 10: RFID + MID meter + load balancing + display + scheduling
- 7: RFID + basic meter + some smart features
- 4: Basic features, no RFID
- 1: Bare minimum, charge-only

## Important Notes

- Always verify OCPP claims — this is the #1 risk with cheap chargers
- Sri Lanka uses BS 546 / BS 1363 power outlets but EV chargers are hardwired
- Import duty on EV chargers in Sri Lanka is approximately 12-15% + 18% VAT
- Tropical humidity and monsoon conditions demand IP65 minimum for outdoor use
- GBT connector is relevant because of growing Chinese EV imports (BYD, MG, etc.)
- For the Cloud Parallax network, OCPP connectivity is non-negotiable — a charger without working OCPP is useless regardless of other features
