# Investigation Methodology

This project follows investigation frameworks established by major fire investigations, adapted for independent community-driven research.

## Reference Investigations

### NIST World Trade Center Investigation (2002-2008)

The National Institute of Standards and Technology (NIST) conducted a comprehensive investigation of the WTC building failures following the 9/11 attacks. Key methodological elements:

- **Multi-disciplinary approach**: Structural engineering, fire dynamics, materials science
- **Computational modeling**: Fire simulations, structural analysis
- **Evidence collection**: Physical evidence, photos/videos, witness interviews
- **Peer review**: External expert review of findings
- **Public documentation**: All reports publicly available

Reports: [NIST NCSTAR 1 Series](https://www.nist.gov/publications/federal-building-and-fire-safety-investigation-world-trade-center-disaster-final-report)

### Grenfell Tower Inquiry (2017-present)

The UK public inquiry into the Grenfell Tower fire established rigorous standards for fire investigation:

- **Phase 1**: Factual account of events on the night
- **Phase 2**: How the fire started and spread; building regulations; response
- **Evidence gathering**: Documents, witness testimony, expert reports
- **Independence**: Inquiry independent of government
- **Transparency**: Public hearings, published evidence

Reports: [Grenfell Tower Inquiry](https://www.grenfelltowerinquiry.org.uk/)

## Our Methodology

### Phase 1: Evidence Collection

**Objective**: Gather and preserve all available evidence before it becomes unavailable.

1. **News and Media**
   - Compile all published reports
   - Archive using web.archive.org
   - Extract and verify key facts
   - Track evolving narratives

2. **Official Documents**
   - Government statements
   - Investigation announcements
   - Regulatory documents
   - Court filings

3. **First-hand Accounts**
   - Witness statements
   - Survivor accounts
   - First responder perspectives
   - Resident testimonies

4. **Physical Evidence**
   - Photos/videos of incident
   - Building documentation
   - Material specifications

### Phase 2: Timeline Reconstruction

**Objective**: Establish a verified timeline of events.

| Time | Event | Source | Confidence |
|------|-------|--------|------------|
| HH:MM | Event description | [source] | High/Medium/Low |

**Timeline elements**:
- Fire ignition and discovery
- Fire spread progression
- Alarm activation (or failure)
- Evacuation activities
- Emergency response
- Building collapse/failure points

### Phase 3: Technical Analysis

**Objective**: Understand the physical mechanisms of the fire.

#### Building Analysis
- Construction type and date
- Modifications and renovations
- Fire protection systems
- Means of egress

#### Fire Dynamics
- Ignition source and fuel load
- Fire spread pathways
- Chimney effect in scaffolding cavity
- External fire spread mechanisms

#### Materials Analysis
- Scaffolding materials (bamboo vs steel)
- Safety net composition and fire rating
- Facade materials
- Insulation

#### Computational Modeling
- FDS fire dynamics simulation
- Validation against observed behavior
- Sensitivity analysis
- Scenario comparisons

### Phase 4: Regulatory Analysis

**Objective**: Identify regulatory failures or gaps.

1. **Applicable Regulations**
   - Building codes at time of construction
   - Fire safety regulations
   - Scaffolding/renovation requirements
   - Material fire rating standards

2. **Compliance Assessment**
   - Were regulations followed?
   - Were inspections conducted?
   - Were violations identified?

3. **Regulatory Gaps**
   - Did existing regulations address the hazard?
   - Were regulations adequate?
   - International comparisons

### Phase 5: Root Cause Analysis

**Objective**: Identify systemic causes, not just proximate causes.

Using the "5 Whys" and fault tree analysis:

```
Event: Rapid fire spread
├── Why? Combustible scaffolding materials
│   ├── Why? Non-fire-rated safety nets used
│   │   ├── Why? Not required by regulation / Not enforced
│   │   └── Why? Cost considerations
│   └── Why? Bamboo scaffolding (traditional practice)
├── Why? Chimney effect in scaffold cavity
│   └── Why? Gap between scaffold and building
└── Why? Fire protection systems failed
    └── Why? [Investigation needed]
```

### Phase 6: Recommendations

**Objective**: Propose changes to prevent future incidents.

Categories:
1. **Immediate actions**: What should change now
2. **Regulatory changes**: New or modified regulations
3. **Enforcement**: Improved inspection/compliance
4. **Technology**: Detection, suppression, materials
5. **Education**: Training for contractors, residents, responders

## Quality Standards

### Source Verification

- **Primary sources** preferred (official documents, direct witnesses)
- **Secondary sources** require corroboration
- **Unverified claims** clearly labeled
- **Conflicting information** documented

### Peer Review

- Technical analysis reviewed by qualified experts
- Simulation parameters documented and reproducible
- Methodology open to critique

### Transparency

- All evidence publicly accessible
- Analysis methods documented
- Limitations acknowledged
- Version control for all documents

## Analysis Outputs

### Deliverables

1. **Evidence Database**: Organized, searchable collection
2. **Timeline**: Verified sequence of events
3. **Technical Report**: Fire dynamics analysis
4. **Regulatory Review**: Compliance and gaps assessment
5. **Simulation Results**: FDS modeling outputs
6. **Recommendations**: Actionable proposals

### Format

- Markdown for text documents (version controlled)
- CSV/JSON for structured data
- Standard formats for simulation files
- High-resolution media with metadata

## Contributing to Analysis

See [CONTRIBUTING.md](../CONTRIBUTING.md) for how to contribute.

**Analysis contributions welcome**:
- Expert review of technical sections
- Regulatory expertise (HK building codes)
- Fire engineering analysis
- Translation (Chinese ↔ English)
- Data visualization

---

*The goal is truth and prevention, not blame. Rigorous methodology protects the integrity of findings.*
