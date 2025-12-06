# 匿名貢獻

本指南喺香港目前嘅法規環境下討論匿名貢獻。喺決定點樣貢獻之前，請仔細閱讀威脅模型。

## 威脅模型：2024年香港

### 法律環境

自2024年3月起，香港同時受**《國家安全法》（2020年）**及**《維護國家安全條例》（第23條）**規管。與貢獻者相關嘅主要條款：

- **國家機密**現包括「經濟及社會發展」同「重大政策決定」嘅資訊——可能涵蓋建築安全失誤
- **「與電腦系統相關嘅未經授權行為」**最高可判終身監禁
- **煽動罪**定義廣泛且被積極檢控
- **境外干預**罪針對與海外實體嘅協調

國家安全處（國安處）有權：
- 進行秘密監視
- 搜查物業及凍結資產
- 拒絕被捕人士選擇自己律師嘅權利
- 在有限司法監督下向服務供應商索取數據

來源：[TIME](https://time.com/6958258/hong-kong-national-security-law-2024-explainer/)、[香港自由新聞](https://hongkongfp.com/article23-security-law/)、[NPR](https://www.npr.org/2024/03/19/1239403058/hong-kong-new-article-23-national-security-legislation)

### 監控基礎設施

- **2000+閉路電視攝影機**於2024年在全港安裝
- **面部識別**警務處處長未有排除使用
- **公共WiFi**通常需要電話號碼或身份證登記
- **互聯網服務供應商**記錄連接元數據並配合政府要求
- **流動數據**與已登記SIM卡掛鉤

來源：[JSIS](https://jsis.washington.edu/news/internet-censorship-and-digital-surveillance-under-hong-kongs-national-security-law/)

### VPN狀況

VPN並非違法，但：
- 政府警告使用VPN繞過監控「可能被視為國家安全威脅」
- 部分供應商（IPVanish、Private Internet Access）已關閉香港伺服器
- VPN流量模式可被互聯網服務供應商偵測，即使內容已加密

來源：[Business & Human Rights Resource Centre](https://www.business-humanrights.org/en/latest-news/hong-kong-some-vpn-providers-shut-down-servers-in-hong-kong-over-security-law-concerns/)

## 按貢獻類型嘅風險評估

| 貢獻類型 | 風險等級 | 備註 |
|---------|---------|------|
| 公開可得嘅新聞連結 | 低 | 已公開嘅資訊 |
| 火災個人相片/影片 | 低至中 | 可能表明你係目擊者 |
| 技術分析/評論 | 低 | 學術討論 |
| 顯示監管失誤嘅文件 | 中至高 | 可能牽連政府 |
| 識別承建商疏忽嘅文件 | 中至高 | 可能牽連有關連人士 |
| 政府內部通訊 | 極高 | 可能被列為國家機密 |
| 組織/協調調查 | 極高 | 可能被定性為顛覆 |

**關鍵問題**：你嘅貢獻可能令政府或有政治關連嘅實體尷尬嗎？如果係，視為高風險。

## 按風險等級嘅建議

### 低風險貢獻（新聞連結、公開資訊）

標準預防措施已足夠：
- 使用匿名帳戶
- commit訊息中唔好包含可識別詳情
- 考慮使用VPN（了解上述注意事項）

### 中等風險貢獻（個人證據、分析）

**如果你喺香港以外：**
- 正常貢獻但使用匿名帳戶
- 貢獻敏感材料後唔好計劃返香港

**如果你喺香港：**
- 認真考慮貢獻係咪值得冒險
- 如果繼續，請參閱下面「高風險」建議
- 考慮將材料傳遞給香港以外嘅人

### 高風險貢獻（牽連當局嘅文件）

**強烈建議：唔好喺香港境內貢獻高風險材料。**

如果你擁有呢類材料並喺香港：
1. **唔好同任何人討論** — 線人會獲獎勵
2. **唔好儲存喺**會過境或可能被搜獲嘅設備上
3. **考慮先離開香港**再貢獻
4. **了解出境限制** — 關注人士可能被禁止離境

如果你喺香港以外並擁有高風險材料：
- 喺唔與你有關連嘅地點使用Tor瀏覽器
- 透過Tor建立與你身份無關嘅帳戶
- 唔好喺任何與你有關嘅網絡存取呢啲帳戶
- 考慮喺專用設備上使用Tails OS
- 使用OnionShare進行檔案傳輸

## 技術措施（適用於繼續嘅人士）

### 網絡匿名

1. **Tor瀏覽器**係任何敏感活動嘅最低要求
   - 從[torproject.org](https://www.torproject.org)下載
   - 了解使用Tor本身可能被互聯網服務供應商記錄

2. **網絡位置重要**
   - 避免需要身份證登記嘅網絡
   - 你嘅日常互聯網服務供應商會記錄你使用咗Tor，即使佢哋睇唔到你做咗乜
   - 考慮相關性：不尋常嘅網絡活動 + 貢獻時間

3. **單獨VPN並不足夠**
   - VPN供應商可能被強制提供日誌
   - VPN over Tor或Tor over VPN各有取捨
   - VPN主要向你嘅互聯網服務供應商隱藏Tor使用，而非對抗堅定嘅對手

### 設備安全

1. **獨立設備** — 唔好用日常手機/電腦
2. **Tails OS** — 不留痕跡嘅健忘操作系統
3. **絕對唔好帶**含敏感材料嘅設備過境
4. **手機位置** — 你嘅手機會追蹤你；進行敏感活動時將佢留喺其他地方

### 帳戶分離

1. **電郵**：透過Tor使用ProtonMail或Tutanota建立
   - 絕對唔好從非Tor連接存取
   - 絕對唔好連結到真實身份

2. **GitHub**：透過Tor建立
   - 配置git使用匿名身份
   ```bash
   git config user.name "Anonymous"
   git config user.email "anonymous@example.com"
   git config commit.gpgsign false
   ```

### 檔案清理

**模擬驗證證據例外**：帶EXIF時間戳嘅相片/影片係有價值嘅。如果提交呢啲，了解你係以某些匿名性換取證據質量。

其他檔案：
```bash
# 移除圖像元數據
exiftool -all= photo.jpg

# 移除PDF元數據
exiftool -all= document.pdf

# 重新編碼影片以移除元數據
ffmpeg -i input.mp4 -map_metadata -1 -c:v copy -c:a copy output.mp4
```

### 行為安全

- **時間相關性**：唔好喺目擊/獲得資料後立即貢獻
- **寫作風格**：你嘅文風可被分析；考慮搵其他人寫
- **唔好討論**：唔好同朋友、家人或網上社群討論
- **生活模式**：行為突然改變（使用Tor、去特定地點）可能被注意到

## 本項目唔需要乜嘢

明確說明範圍並減少不必要嘅風險：

- 我哋紀錄嘅係**消防安全事件**，為咗公眾利益
- 我哋唔係組織政治反對派
- 我哋唔係想令個人尷尬
- 我哋追求嘅係關於火災行為及建築安全嘅**技術真相**
- 公開資訊（新聞、技術分析）嘅貢獻者面臨最低風險

大多數對本項目嘅貢獻係**低風險**。唔好讓本指南阻止你分享公開可得嘅資訊或技術分析。

## 香港以外嘅人士

如果你係現居海外嘅香港居民：
- 了解貢獻有爭議嘅材料可能影響你返港嘅能力
- 了解喺香港嘅家人可能面臨壓力
- 根據你嘅具體情況做出知情決定

如果你與香港無關連：
- 你為本項目貢獻面臨最低風險
- 考慮為無法直接貢獻嘅人充當中介

## 資源

- [EFF監控自衛](https://ssd.eff.org) — 安全指南
- [Security in a Box](https://securityinabox.org) — 數碼安全工具
- [Tor Project](https://www.torproject.org) — 匿名瀏覽
- [Tails](https://tails.boum.org) — 健忘操作系統

## 免責聲明

本指南為已決定貢獻嘅人士提供資訊。呢唔係法律建議。作者無法保證安全。每個人必須評估自己嘅風險承受能力同情況。

最安全嘅選項始終係：**如果你唔舒服承擔風險，就唔好貢獻。**

---

*消防安全研究服務於公眾利益。但你嘅安全係第一位。做出知情決定。*

---

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
