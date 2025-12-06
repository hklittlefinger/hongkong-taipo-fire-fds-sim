# Evidence Collection

This directory contains documented evidence related to the Wang Fuk Court fire.

## Directory Structure

```
evidence/
├── news/                 # News reports and media coverage
│   ├── sources.md        # Master list of sources with archive links
│   └── YYYY-MM-DD_source/ # Individual articles with metadata
├── firsthand/            # First-person accounts
│   ├── submissions/      # Anonymized submissions
│   └── verified/         # Verified accounts
├── media/                # Photos and videos
│   └── README.md         # Submission guidelines
└── official/             # Government and official documents
```

## Evidence Categories

### News Reports (`news/`)

Media coverage from various outlets. Each article should include:
- Original URL
- Archive.org/archive.today backup URL
- Publication date
- Brief summary
- Key facts reported

**Archiving News**:
```bash
# Archive a URL
curl -s "https://web.archive.org/save/[URL]"

# Or use archive.today
# Visit: https://archive.today/?run=1&url=[URL]
```

### First-hand Accounts (`firsthand/`)

Witness statements, survivor accounts, and testimonies.

**Submission format**:
```markdown
## Account ID: [auto-generated]
Date submitted: YYYY-MM-DD
Relation to incident: [witness/survivor/resident/responder/other]
Verified: [yes/no/pending]

### Account
[narrative]

### Key details
- Time observations:
- Location observations:
- Other witnesses mentioned:

### Submitted materials
- [list of any photos/videos/documents]
```

### Media (`media/`)

Photos and videos of the incident, building, or relevant materials.

**Requirements**:
- Strip all metadata before submission (see ANONYMOUS-CONTRIBUTIONS.md)
- Provide context (date, time, location, what it shows)
- Note source (personal, news outlet, social media)

**Storage**: Large files should use Git LFS or external hosting (IPFS preferred)

### Official Documents (`official/`)

Government statements, investigation reports, regulations, permits.

- Court documents
- Government press releases
- Building Department records
- Fire Services Department statements
- Legislative Council discussions

## Evidence Handling Principles

### Chain of Custody

1. **Document source**: Where did this evidence come from?
2. **Preserve original**: Keep unmodified copies when possible
3. **Record modifications**: Note any redactions, format conversions
4. **Timestamp**: When was it obtained/submitted?

### Verification

Evidence is categorized as:
- **Verified**: Independently confirmed from multiple sources
- **Unverified**: Single source, awaiting confirmation
- **Disputed**: Conflicting information exists

### Integrity

Each piece of evidence should have:
- SHA-256 checksum of original file
- Submission date
- Source attribution (or "anonymous")

Generate checksums:
```bash
sha256sum filename > filename.sha256
```

### Privacy

- Redact personal information of uninvolved private individuals
- Blur faces in crowd photos unless relevant
- Remove contact details unless person is a public figure or consents

## Submitting Evidence

### Via GitHub

1. Fork this repository
2. Add evidence to appropriate directory
3. Include metadata file
4. Submit pull request

### Via Secure Channels

See [ANONYMOUS-CONTRIBUTIONS.md](../ANONYMOUS-CONTRIBUTIONS.md) for secure submission methods.

## Evidence Wishlist

Priority items we're seeking:

### High Priority
- [ ] Building floor plans
- [ ] Scaffolding installation permits
- [ ] Safety net material specifications
- [ ] Fire alarm system inspection records
- [ ] Renovation contractor details
- [ ] Timeline of events with source citations

### Medium Priority
- [ ] Historical photos of building/scaffolding
- [ ] Previous fire safety inspection reports
- [ ] Resident communications about renovation
- [ ] Insurance documents

### Ongoing
- [ ] News coverage (especially local Chinese-language media)
- [ ] First-hand accounts
- [ ] Social media posts (with archive links)

## Legal Notice

This evidence collection is for documentary and fire safety research purposes. Contributors should:
- Only submit materials they have legal right to share
- Respect copyright (link to articles, don't copy full text)
- Not submit materials obtained through illegal means
- Understand that submissions may be used in analysis and publications

---

*Evidence preservation is critical. Information may become unavailable. Archive everything.*
