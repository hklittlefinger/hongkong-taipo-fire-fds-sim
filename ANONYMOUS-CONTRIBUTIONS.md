# Contributing Anonymously

This guide addresses anonymous contribution in the context of Hong Kong's current regulatory environment. Read the threat model carefully before deciding how to contribute.

## Threat Model: Hong Kong 2024

### Legal Environment

Since March 2024, Hong Kong operates under both the **National Security Law (2020)** and the **Safeguarding National Security Ordinance (Article 23)**. Key provisions relevant to contributors:

- **State secrets** now includes information about "economic and social development" and "major policy decisions" - potentially covering building safety failures
- **"Unauthorized acts related to computer systems"** can carry life imprisonment
- **Sedition** is broadly defined and actively prosecuted
- **External interference** offenses target coordination with overseas entities

The National Security Department (NSD) has powers to:
- Conduct covert surveillance
- Search properties and freeze assets
- Deny arrested persons access to their lawyer of choice
- Request data from service providers with limited judicial oversight

Sources: [TIME](https://time.com/6958258/hong-kong-national-security-law-2024-explainer/), [Hong Kong Free Press](https://hongkongfp.com/article23-security-law/), [NPR](https://www.npr.org/2024/03/19/1239403058/hong-kong-new-article-23-national-security-legislation)

### Surveillance Infrastructure

- **2,000+ CCTV cameras** installed throughout HK in 2024
- **Facial recognition** not ruled out by Police Commissioner
- **Public WiFi** often requires phone number or ID registration
- **ISPs** log connection metadata and comply with government requests
- **Mobile data** tied to registered SIM cards

Source: [JSIS](https://jsis.washington.edu/news/internet-censorship-and-digital-surveillance-under-hong-kongs-national-security-law/)

### VPN Status

VPNs are not illegal but:
- Government has warned VPN use to bypass surveillance "may be considered a national security threat"
- Some providers (IPVanish, Private Internet Access) have shut down HK servers
- VPN traffic patterns are detectable by ISPs even if content is encrypted

Source: [Business & Human Rights Resource Centre](https://www.business-humanrights.org/en/latest-news/hong-kong-some-vpn-providers-shut-down-servers-in-hong-kong-over-security-law-concerns/)

## Risk Assessment by Contribution Type

| Contribution Type | Risk Level | Notes |
|-------------------|------------|-------|
| Publicly available news links | Low | Already public information |
| Personal photos/videos of fire | Low-Medium | May identify you as witness |
| Technical analysis/commentary | Low | Academic discussion |
| Documents showing regulatory failures | Medium-High | Could implicate government |
| Documents identifying contractor negligence | Medium-High | Could implicate connected parties |
| Internal government communications | Very High | Likely classified as state secrets |
| Organizing/coordinating investigation | Very High | Could be characterized as subversion |

**Key question**: Does your contribution potentially embarrass the government or politically connected entities? If yes, treat it as high risk.

## Recommendations by Risk Level

### Low Risk Contributions (news links, public information)

Standard precautions sufficient:
- Use a pseudonymous account
- Don't include identifying details in commit messages
- Consider using a VPN (understanding the caveats above)

### Medium Risk Contributions (personal evidence, analysis)

**If you are outside Hong Kong:**
- Contribute normally but use a pseudonymous account
- Don't plan to return to HK after contributing sensitive material

**If you are in Hong Kong:**
- Seriously consider whether the contribution is worth the risk
- If proceeding, see "High Risk" recommendations below
- Consider passing materials to someone outside HK instead

### High Risk Contributions (documents implicating authorities)

**Strong recommendation: Do not contribute high-risk materials from within Hong Kong.**

If you possess such materials and are in HK:
1. **Do not discuss with anyone** - informants are rewarded
2. **Do not store on devices** that cross the border or could be seized
3. **Consider leaving HK first** before contributing
4. **Understand exit restrictions** - persons of interest may be prevented from leaving

If you are outside Hong Kong with high-risk materials:
- Use Tor Browser from a location not associated with you
- Create accounts via Tor that have no connection to your identity
- Do not access these accounts from any network tied to you
- Consider using Tails OS on a dedicated device
- Use OnionShare for file transfers

## Technical Measures (for those proceeding)

### Network Anonymity

1. **Tor Browser** is the minimum for any sensitive activity
   - Download from [torproject.org](https://www.torproject.org)
   - Understand that Tor use itself may be logged by ISPs

2. **Network location matters**
   - Avoid networks requiring ID registration
   - Your regular ISP logs that you used Tor, even if they can't see what you did
   - Consider the correlation: unusual network activity + contribution timing

3. **VPNs are NOT sufficient alone**
   - VPN providers can be compelled to provide logs
   - VPN over Tor or Tor over VPN each have tradeoffs
   - A VPN mainly hides Tor usage from your ISP, not from a determined adversary

### Device Security

1. **Separate devices** - Don't use your daily phone/computer
2. **Tails OS** - Amnesic operating system that leaves no traces
3. **Never cross borders** with devices containing sensitive materials
4. **Phone location** - Your phone tracks you; leave it elsewhere during sensitive activities

### Account Separation

1. **Email**: Create via Tor using ProtonMail or Tutanota
   - Never access from non-Tor connections
   - Never link to real identity

2. **GitHub**: Create via Tor
   - Configure git to use pseudonymous identity
   ```bash
   git config user.name "Anonymous"
   git config user.email "anonymous@example.com"
   git config commit.gpgsign false
   ```

### File Sanitization

**Exception for simulation validation evidence**: Photos/videos with EXIF timestamps are valuable. If submitting these, understand you're trading some anonymity for evidence quality.

For other files:
```bash
# Strip image metadata
exiftool -all= photo.jpg

# Strip PDF metadata
exiftool -all= document.pdf

# Re-encode video to strip metadata
ffmpeg -i input.mp4 -map_metadata -1 -c:v copy -c:a copy output.mp4
```

### Behavioral Security

- **Timing correlation**: Don't contribute immediately after witnessing/obtaining something
- **Writing style**: Your prose patterns can be analyzed; consider having someone else write
- **Don't discuss**: Not with friends, family, or online communities
- **Pattern of life**: Sudden changes in behavior (using Tor, visiting specific locations) can be noticed

## What This Project Does NOT Need

To be clear about scope and reduce unnecessary risk:

- We are documenting a **fire safety incident** for public interest
- We are NOT organizing political opposition
- We are NOT seeking to embarrass individuals
- We are seeking **technical truth** about fire behavior and building safety
- Contributors of public information (news, technical analysis) face minimal risk

Most contributions to this project are **low risk**. Don't let this guide discourage you from sharing publicly available information or technical analysis.

## For Those Outside Hong Kong

If you are a Hong Kong resident now living abroad:
- Understand that contributing controversial materials may affect your ability to return
- Understand that family members in HK could potentially face pressure
- Make informed decisions based on your specific situation

If you have no connection to Hong Kong:
- You face minimal risk contributing to this project
- Consider offering to be an intermediary for those who cannot contribute directly

## Resources

- [EFF Surveillance Self-Defense](https://ssd.eff.org) - Security guides
- [Security in a Box](https://securityinabox.org) - Digital security tools
- [Tor Project](https://www.torproject.org) - Anonymous browsing
- [Tails](https://tails.boum.org) - Amnesic operating system

## Disclaimer

This guide provides information for those who have already decided to contribute. It is not legal advice. The authors cannot guarantee safety. Each person must assess their own risk tolerance and situation.

The most secure option is always: **don't contribute if you're not comfortable with the risk.**

---

*Fire safety research serves the public interest. But your safety comes first. Make informed decisions.*
