# Contributing Anonymously

This guide explains how to contribute to this project while protecting your identity. Your safety is paramount.

## Why Anonymity Matters

Documenting incidents that may involve regulatory failures or institutional negligence can carry risks. This guide helps you contribute safely if you have concerns about:
- Retaliation from employers or authorities
- Legal exposure
- Personal safety
- Privacy

## Quick Reference

| Method | Anonymity Level | Technical Skill | Best For |
|--------|-----------------|-----------------|----------|
| Tor + ProtonMail | High | Low | Text, small files |
| OnionShare | Very High | Medium | Large files, media |
| Anonymous GitHub | High | Medium | Code, documentation |
| Physical mail | Very High | Low | Documents, USB drives |

## Before You Start

### Basic Precautions

1. **Don't use work/school networks** - Use public WiFi (cafe, library) or mobile data
2. **Use a separate device if possible** - Or at minimum, a separate browser profile
3. **Don't discuss your contributions** - With anyone who doesn't need to know
4. **Consider timing** - Don't submit immediately after obtaining information

### Threat Model

Consider what you're protecting against:
- **Casual observation**: Basic precautions sufficient
- **Determined adversary**: Use Tor, air-gapped devices, physical mail
- **State-level surveillance**: Consult security professionals, consider risks carefully

## Method 1: Tor Browser + Encrypted Email

**Best for**: Text submissions, links, small documents

### Setup

1. Download Tor Browser from [torproject.org](https://www.torproject.org)
2. Create a ProtonMail account via Tor at [proton.me](https://proton.me)
   - Use a pseudonym, not your real name
   - Don't link to any existing accounts
   - Access only via Tor

### Submitting

1. Open Tor Browser
2. Log into your anonymous ProtonMail
3. Send your contribution to: `[PROJECT_EMAIL_TBD]@protonmail.com`
4. Include:
   - What you're submitting
   - Context (date, source, how obtained)
   - Any verification details
   - How you'd like to be credited (or "anonymous")

## Method 2: OnionShare for Large Files

**Best for**: Photos, videos, large document collections

### Setup

1. Download Tor Browser
2. Download OnionShare from [onionshare.org](https://onionshare.org)

### Submitting

1. Open OnionShare
2. Select files to share
3. Click "Start sharing" - generates a .onion address
4. Send the .onion address via encrypted email (Method 1)
5. Keep OnionShare open until files are downloaded

## Method 3: Anonymous GitHub Account

**Best for**: Code contributions, documentation improvements, ongoing collaboration

### Setup (via Tor)

1. Open Tor Browser
2. Create a new email at ProtonMail (via Tor)
3. Go to github.com
4. Create account using:
   - Pseudonymous username (not linked to real identity)
   - Your anonymous ProtonMail address
   - Don't enable 2FA with phone number

### Contributing

1. Fork the repository
2. Make changes
3. Submit pull request
4. All Git operations should be done via Tor or VPN

### Git Configuration

```bash
# Use pseudonymous identity
git config user.name "Anonymous Contributor"
git config user.email "anon@example.com"

# Disable GPG signing (links to identity)
git config commit.gpgsign false
```

## Method 4: Physical Mail

**Best for**: Highly sensitive documents, when digital methods feel too risky

Send physical documents or USB drives to a trusted intermediary. Contact via Method 1 first to arrange.

## Stripping Metadata from Files

### Why This Matters

Photos and documents often contain hidden metadata revealing:
- Device information (phone model, serial numbers)
- Location (GPS coordinates)
- Timestamps
- Software used
- Author names

### For Images

**Using ExifTool (command line)**:
```bash
# View metadata
exiftool photo.jpg

# Remove all metadata
exiftool -all= photo.jpg

# Verify removal
exiftool photo.jpg
```

**Using MAT2 (GUI available)**:
```bash
mat2 photo.jpg
```

**Online (less secure)**:
- Use via Tor only
- verexif.com or similar

### For Documents

**PDFs**:
```bash
# Using ExifTool
exiftool -all= document.pdf

# Using MAT2
mat2 document.pdf
```

**Word/Office documents**:
- Save as PDF, then strip PDF metadata
- Or use MAT2 directly on .docx files

### For Videos

```bash
# Using FFmpeg - re-encode to strip metadata
ffmpeg -i input.mp4 -map_metadata -1 -c:v copy -c:a copy output.mp4
```

## Verifying Your Anonymity

### Before Submitting

1. **Check your IP**: Visit [check.torproject.org](https://check.torproject.org) via Tor
2. **Check file metadata**: Run ExifTool on files you're submitting
3. **Review content**: Ensure text doesn't contain identifying details
4. **Check links**: Don't include URLs with session tokens or personal identifiers

### Common Mistakes

- Using personal email, even once
- Accessing from identifiable IP addresses
- Leaving metadata in files
- Including identifiable details in text ("I work at..." "My neighbor...")
- Using accounts linked to real identity
- Timing correlation (submitting right after an event you witnessed)

## Secure Communication Channels

### For Initial Contact

- **ProtonMail** (via Tor): Create anonymous account, message project maintainers
- **Signal**: If you need real-time communication, discuss via ProtonMail first

### For Ongoing Communication

Once initial contact established, maintainers can provide:
- Dedicated secure channels
- Public keys for encrypted communication
- Alternative submission methods

## Legal Considerations

This guide is for legitimate whistleblowing and documentation purposes. Consider:

- **Leaked documents**: Understand the legal implications in your jurisdiction
- **Copyright**: News articles should be linked/archived, not copied wholesale
- **Privacy**: Redact personal information of uninvolved private individuals
- **Defamation**: Stick to documented facts, label speculation clearly

## If You're Unsure

If you have information but aren't sure how to proceed safely:

1. Don't rush - take time to plan
2. Contact us via Method 1 to discuss options
3. Consider consulting a lawyer if legal exposure is a concern
4. It's okay to wait until you feel safe

## Resources

- [Tor Project](https://www.torproject.org) - Anonymous browsing
- [ProtonMail](https://proton.me) - Encrypted email
- [OnionShare](https://onionshare.org) - Anonymous file sharing
- [MAT2](https://0xacab.org/jvoisin/mat2) - Metadata removal
- [EFF Surveillance Self-Defense](https://ssd.eff.org) - Security guides
- [Security in a Box](https://securityinabox.org) - Digital security tools

---

*Your contributions help preserve the truth. Your safety matters. Take precautions appropriate to your situation.*
