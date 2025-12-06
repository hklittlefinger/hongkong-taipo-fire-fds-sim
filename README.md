# 宏福苑火災紀錄

<p align="center">
  <em>「就算要燒毀呢個國家，佢都想做灰燼嘅王」</em>
  <br>
  — 瓦里斯大人
</p>

## 概覽

本項目紀錄及分析2025年11月26日發生於香港大埔宏福苑嘅火災慘劇，事件造成159人以上死亡。我哋嘅目標：

1. **保存證據** — 趁證據消失之前
2. **實現獨立分析** — 透過火災動力學模擬
3. **支持消防安全改進** — 透過嚴謹嘅技術調查

我哋歡迎任何擁有相關資料嘅人士參與貢獻。請參閱 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何幫忙，或者如果你有安全顧慮，請參閱 [ANONYMOUS-CONTRIBUTIONS.md](ANONYMOUS-CONTRIBUTIONS.md)。

## 項目結構

```
├── evidence/              # 證據收集
│   ├── news/              # 新聞報導及媒體報導
│   ├── firsthand/         # 目擊者陳述及倖存者口述
│   ├── media/             # 相片及影片
│   └── official/          # 政府文件
├── analysis/              # 技術分析
│   ├── methodology.md     # 調查框架（參考NIST/格蘭菲爾塔）
│   ├── building/          # 建築物分析
│   └── regulatory/        # 法規合規審查
├── simulation/            # FDS火災動力學模擬
│   ├── *.fds              # FDS輸入檔案
│   └── scripts/           # AWS啟動及監控腳本
└── resources/             # 工具及參考資料
```

## 火災動力學模擬

8個FDS模擬以確定材料對火勢蔓延嘅影響。

### 模擬範圍

本研究**僅模擬棚架外牆**（10米×5.6米×90米）以隔離棚架材料嘅影響。我哋刻意排除：

- **完整建築物內部**：唔模擬內部間隔、住戶或建築結構。我哋嘅重點係棚架材料，唔係疏散或結構倒塌。
- **建築群**：唔模擬相鄰建築物或整個宏福苑。單一外牆嘅火災行為已足以比較材料影響。
- **風力影響**：無模擬盛行風向。風力會影響整體火勢蔓延，但唔會影響每種材料（竹棚vs鋼棚、PP vs FR-HDPE、發泡膠vs無）嘅相對貢獻——呢個先係我哋嘅研究問題。

呢個簡化方法可以：
1. 直接比較材料貢獻，排除干擾變數
2. 喺合理時間內完成模擬（45小時 vs 幾個月）
3. 將計算資源集中喺高解像度材料燃燒

## 模擬矩陣

### 第一層：關鍵驗證（5個模擬）

| # | 檔案 | 棚架 | 安全網 | 發泡膠 | 目的 |
|---|------|------|--------|--------|------|
| 1 | tier1_1_bamboo_PP_styro.fds | 竹 | PP（不合規） | 有 | **實際事件** |
| 2 | tier1_2_steel_PP_styro.fds | **鋼** | PP（不合規） | 有 | 隔離竹嘅影響 |
| 3 | tier1_3_bamboo_FR_styro.fds | 竹 | **FR-HDPE（合規）** | 有 | 隔離網嘅影響 |
| 4 | tier1_4_steel_FR_styro.fds | **鋼** | **FR-HDPE（合規）** | 有 | 完全合規連發泡膠 |
| 5 | tier1_5_bamboo_FR_no_styro.fds | 竹 | **FR-HDPE（合規）** | **無** | FR網下發泡膠影響 |

### 第二層：延伸分析（3個模擬）

| # | 檔案 | 棚架 | 安全網 | 發泡膠 | 目的 |
|---|------|------|--------|--------|------|
| 6 | tier2_1_bamboo_none_styro.fds | 竹 | **無** | 有 | 網嘅總體影響 |
| 7 | tier2_2_bamboo_HDPE_styro.fds | 竹 | **HDPE（廉價）** | 有 | PP vs HDPE |
| 8 | tier2_3_steel_FR_nostyro.fds | 鋼 | FR-HDPE | **無** | 完全合規下發泡膠影響 |

## 火源

**點火**：地面單一點火源（z=0.0-2.0米）
- HRRPUA：2500 kW/m²
- 位置：4.0-6.0米（x）× 4.25-5.0米（y）
- 火勢經可燃棚架材料自然蔓延

**無單位窗口噴火** — 重點係棚架材料貢獻，唔係單位火災。

## 材料特性

### 棚架材料
- **竹**：濕竹（40 kg/m³）→ 乾竹（35 kg/m³）→ 炭（10 kg/m³）+ 木氣
  - 著火點：280°C
  - 燃燒熱：~15 MJ/kg
- **鋼**：惰性、不可燃、高導熱（散熱）

### 安全網材料
- **PP帳篷布**（不合規）：著火點345°C，燃燒熱46 MJ/kg，燃燒速率12.4 mm/min
- **HDPE**（廉價中國標準）：著火點355°C，燃燒熱43 MJ/kg
- **FR-HDPE**（合規）：著火點475°C，燃燒速率0.8 mm/min（慢15.5倍！）
- **無**：無網（基線）

### 窗口密封
- **發泡膠**：聚苯乙烯泡沫，著火點350°C，燃燒熱40 MJ/kg，大量煙霧
- **無發泡膠**：窗戶關閉但無保溫密封

## 喺AWS運行

### 自訂AMI

模擬使用預建AMI，包含：
- **FDS 6.10.1** 配 HYPRE v2.32.0 及 Sundials v6.7.0（靜態鏈接）
- **Intel oneAPI**（MPI、編譯器、數學函式庫）
- FDS執行檔：`/opt/fds/bin/fds`
- 環境設定：`source /opt/intel/oneapi/setvars.sh`

AMI喺多個區域可用（eu-north-1、eu-south-1、eu-south-2、ap-northeast-1、ap-southeast-3）。

### 啟動腳本

```bash
cd simulation

# 基本啟動
./scripts/launch_aws.sh --key-path ~/.ssh/fds-key-pair tier1_*.fds tier2_*.fds

# 全新開始（刪除現有S3輸出）
./scripts/launch_aws.sh --key-path ~/.ssh/fds-key-pair --clean tier1_1.fds

# 大型模擬用更大硬碟
./scripts/launch_aws.sh --key-path ~/.ssh/fds-key-pair --volume-size 200 tier1_1.fds
```

腳本會：
1. 搵最平且有spot容量嘅區域
2. 自動偵測所選區域嘅自訂FDS AMI
3. 建立VPC、安全群組及S3 Gateway端點
4. 啟動EC2 spot實例（c7i.12xlarge，48 vCPU，100GB硬碟）
5. 上載FDS檔案並喺tmux啟動模擬
6. **從檢查點恢復**如果S3有restart檔案（除非用`--clean`）
7. 喺SQLite資料庫追蹤實例資訊（`instances.db`）
8. 同步輸出到S3儲存桶（`fds-output-wang-fuk-fire`）

### 監控狀態

```bash
./scripts/check_status.sh --key-path ~/.ssh/fds-key-pair --watch --interval 60
```

### 手動執行（喺EC2實例）

#### SSH登入實例
```bash
ssh -i ~/.ssh/fds-key-pair ubuntu@<INSTANCE_IP>
```

#### 開始新模擬
```bash
# 載入Intel環境（每個session一次）
source /opt/intel/oneapi/setvars.sh

# 進入工作目錄
cd ~/fds-work/<CHID>

# 計算FDS檔案中嘅mesh數量
NUM_MESHES=$(grep -c '&MESH' <simulation>.fds)

# 喺tmux運行（SSH斷開後繼續）
tmux new-session -d -s fds_run "source /opt/intel/oneapi/setvars.sh && mpiexec -n $NUM_MESHES /opt/fds/bin/fds <simulation>.fds"
```

#### 從restart檔案恢復
```bash
# 編輯FDS檔案啟用restart模式
sed -i 's/^&MISC /&MISC RESTART=.TRUE., /' <simulation>.fds

# 開始模擬（自動讀取最新*.restart檔案）
tmux new-session -d -s fds_run "source /opt/intel/oneapi/setvars.sh && mpiexec -n $NUM_MESHES /opt/fds/bin/fds <simulation>.fds"
```

#### 監控進度
```bash
# 連接運行中嘅tmux session（Ctrl+B, D斷開）
tmux attach -t fds_run

# 檢查模擬進度
tail -f ~/fds-work/<CHID>/<CHID>.out

# 檢查當前模擬時間
grep "Time Step" ~/fds-work/<CHID>/<CHID>.out | tail -5

# 檢查錯誤
grep -i "error\|warning\|instability" ~/fds-work/<CHID>/<CHID>.out
```

## 輸出檔案

每個模擬產生：

### 核心檔案
- `*.out` - 文字輸出日誌（求解器診斷、計時、錯誤）
- `*.smv` - Smokeview可視化元數據
- `*.restart` - 恢復模擬用嘅檢查點檔案（每300秒）

### CSV數據
- `*_hrr.csv` - 熱釋放率時間序列
- `*_steps.csv` - 時間步統計（CFL、壓力迭代）
- `*_devc.csv` - 設備測量（AST溫度、氣體溫度）

### 可視化檔案
- `*.sf` - 切片檔案（溫度、速度、HRRPUV截面）
- `*.bf` - 邊界檔案（壁面溫度、對流/輻射熱通量）
- `*.prt5` - 粒子數據（掉落碎片軌跡）
- `*.s3d` - 3D煙霧可視化數據

## 分析

### 主要指標
1. **峰值HRR**（MW）— 火災強度
2. **到達30樓時間**（秒）— 蔓延速率
3. **總釋放熱量**（GJ）— 燃料貢獻

### 比較方法
```python
bamboo_contribution = (Sim1_HRR - Sim2_HRR) / Sim1_HRR * 100
netting_compliance = (Sim1_time - Sim3_time)  # 額外疏散時間
styrofoam_effect = (Sim3_HRR - Sim5_HRR) / Sim3_HRR * 100
```

## 政策影響

### 問題1：香港應否禁止竹棚？
**分析**：比較模擬1 vs 模擬2

### 問題2：不合規嘅網係咪主要問題？
**分析**：比較模擬1 vs 模擬3

### 問題3：合規可以防止死亡嗎？
**分析**：比較模擬1 vs 模擬4

### 問題4：發泡膠係咪最大元兇？
**分析**：比較模擬3 vs 模擬5，同埋模擬4 vs 模擬8

## 技術背景

### 事件事實

宏福苑火災發生於2025年11月26日約下午2時51分，地點係香港大埔區。新聞報導嘅關鍵因素：

- **建築物**：8座31層大廈（約90米高），1983年落成
- **傷亡**：159人以上死亡
- **天氣**：紅色火災危險警告生效（11月24日發出）；23°C，42%相對濕度，西北風約16公里/小時（[timeanddate.com](https://www.timeanddate.com/weather/hong-kong/hong-kong/historic?month=11&year=2025)）
- **火勢蔓延**：經棚架空隙煙囪效應快速垂直蔓延；4小時內升至五級火
- **調查**：七個棚架網樣本未能通過阻燃測試；火警鐘未能正常運作

來源：[半島電視台](https://www.aljazeera.com/news/2025/11/27/hong-kongs-deadliest-fire-in-63-years-what-we-know-and-how-it-spread)、[南華早報](https://multimedia.scmp.com/infographics/news/hong-kong/article/3334304/taipo_wangfuk_fire/index.html)、[HK01](https://www.hk01.com/%E7%AA%81%E7%99%BC/60297831)、[維基百科](https://en.wikipedia.org/wiki/Wang_Fuk_Court_fire)

### 點解只模擬棚架外牆？

棚架外牆模擬方法將**材料貢獻問題**從干擾變數中隔離。呢個遵循類似[BS 8414](https://www.designingbuildings.co.uk/wiki/BS_8414_Fire_performance_of_external_cladding_systems)外牆火災測試嘅原則：

- **煙囪效應**：棚架同建築物外牆之間嘅空隙形成垂直通道，加速向上火焰蔓延（根據[外牆火災研究](https://www.sciencedirect.com/science/article/abs/pii/S2352710221011153)，比明火快3-6倍）
- **隔離變數**：直接將熱釋放歸因於特定材料（竹vs鋼、PP vs FR-HDPE、發泡膠vs無）

### 多孔棚架幾何

模型實現**3D多孔棚架**方法，包含離散結構元素：

| 層 | Y位置 | 厚度 | 描述 |
|----|-------|------|------|
| 安全網 | 4.05-4.25m | 0.2m | 連續PP帳篷布層 |
| 外排竹 | 4.25-4.45m | 0.2m | 離散垂直竹竿（每10米跨度5支） |
| *空氣腔* | 4.45-4.65m | 0.2m | 主要煙囪通道 |
| 內排竹 | 4.65-4.85m | 0.2m | 離散垂直竹竿 |
| *空氣間隙* | 4.85-5.00m | 0.15m | 次要對流路徑 |
| 發泡膠 | 5.00-5.05m | 0.05m | 窗口密封（僅喺窗口位置） |
| 建築牆 | 5.05-5.25m | 0.2m | 混凝土基底 |

水平橫桿每約3米垂直連接竹排，形成逼真嘅棚架結構。

**呢個幾何點解重要：**
- **煙囪效應**：層間空氣腔容許熱氣向上加速，預熱上方燃料並驅動快速垂直火勢蔓延
- **燃料表面積**：離散竹竿比實心板有更高嘅表面積體積比，實現逼真嘅熱解速率
- **氣流路徑**：竹竿之間嘅間隙容許水平交叉通風，同時維持垂直氣流

### 網格解像度理據

20厘米網格大小基於[特徵火災直徑（D*）](https://fdstutorial.com/fds-mesh-size-calculator/)：

**D*公式：** D* = (Q / (ρ∞ × cp × T∞ × √g))^(2/5)

| 參數 | 數值 |
|------|------|
| HRRPUA | 2500 kW/m²（1.5m²）= 3.75 MW |
| D* | ≈1.5m |
| 網格大小（dx） | 0.2m |
| **D*/dx** | **≈7.5**（中等解像度） |

[FDS用戶指南](https://pages.nist.gov/fds-smv/)建議D*/dx為4（粗糙）、10（中等）或16（精細）。我哋嘅7.5比率提供足夠解像度，同時維持計算可行性。

### 壓力求解器：UGLMAT HYPRE

複雜嘅多孔竹棚幾何需要`SOLVER='UGLMAT HYPRE'`：

- **U（非結構化）**：僅喺氣相求解壓力，消除通過薄障礙物嘅速度洩漏
- **G（全域）**：跨所有mesh全域求解壓力，確保煙囪氣流嘅準確垂直壓力梯度
- **HYPRE**：高效多重網格庫，管理大型問題嘅記憶體

### 竹燃燒模型

竹熱解使用基於[木質纖維素燃燒研究](https://www.sciencedirect.com/science/article/abs/pii/S0379711220301375)嘅兩步反應方案：

1. **乾燥**：濕竹（40 kg/m³，約12%含水量）→ 乾竹（35 kg/m³）+ 水蒸氣
2. **熱解**：乾竹 → 炭（10 kg/m³）+ 可燃氣體（280-400°C）

| 特性 | 數值 | 來源 |
|------|------|------|
| 著火溫度 | 280-386°C | [Pope等](https://www.researchgate.net/profile/Ian-Pope-5/publication/356838161_Fire_safety_design_tools_for_laminated_bamboo_buildings/links/627a1ac32f9ccf58eb3c30e8/Fire-safety-design-tools-for-laminated-bamboo-buildings.pdf) |
| 燃燒熱 | 15-23 MJ/kg | [生物炭研究](https://www.sciencedirect.com/science/article/abs/pii/S036054422404091X) |
| 熱解範圍 | 257-400°C | [TGA研究](https://www.mdpi.com/2227-9717/12/11/2458) |

垂直竹竿方向容許火「毫無阻礙」蔓延（[香港理工大學](https://theconversation.com/why-is-bamboo-used-for-scaffolding-in-hong-kong-a-construction-expert-explains-270780)）。

### 安全網材料

#### 聚丙烯（PP）— 不合規

PP帳篷布係主要火災危險。特性來自[火災危險研究](https://link.springer.com/chapter/10.1007/978-94-011-4421-6_34)：

| 特性 | 數值 |
|------|------|
| 密度 | 900 kg/m³ |
| 比熱容 | 1.9 kJ/kg·K |
| 導熱係數 | 0.22 W/m·K |
| 著火點 | 345°C（130-160°C熔化） |
| 燃燒熱 | 46 MJ/kg |
| 燃燒速率 | 12.4 mm/min |

[熔化滴落行為](https://www.cuspuk.com/fire-safety/plastic-fire-risks/)令火勢不可預測地蔓延，喺底部形成池火。

#### FR-HDPE — 合規

[阻燃HDPE](https://www.globalplasticsheeting.com/our-blog-resource-library/fire-retardant-woven-hdpe-the-ultimate-guide)加入阻燃添加劑：

| 特性 | 數值 |
|------|------|
| 著火點 | ~475°C |
| 燃燒速率 | 0.8 mm/min（**比PP慢15.5倍**） |
| 分類 | 應符合[EN 13501-1](https://measurlabs.com/blog/en-13501-1-fire-classification-performance-classes-and-criteria/) E級 |

### 聚苯乙烯（EPS）窗口密封

EPS泡沫用於密封窗戶。來自[燃燒研究](https://pmc.ncbi.nlm.nih.gov/articles/PMC10884846/)：

| 特性 | 數值 |
|------|------|
| 密度 | 25 kg/m³（98%空氣） |
| 比熱容 | 1.3 kJ/kg·K |
| 導熱係數 | 0.03 W/m·K |
| 著火點 | 346-360°C |
| 峰值HRR | 493.9 kW/m² |
| 燃燒熱 | 40 MJ/kg |

燃燒產物包括CO、苯乙烯單體、溴化氫及芳香族化合物。

### 穩定性控制（條狀模型）

| 參數 | 設定 | 目的 |
|------|------|------|
| CFL_MAX | 1.0 | 對流穩定性（v×Δt/Δx < 1） |
| VN_MAX | 0.5 | 擴散穩定性（α×Δt/Δx² < 0.5） |
| CHECK_VN | .TRUE. | 啟用熱解嘅Von Neumann檢查 |
| 點火斜坡 | 60秒內0→50%→100%，然後180秒時關閉 | 漸進點火防止壓力尖峰 |

### 法規背景

香港棚架法規要求：
- [竹棚架安全工作守則](https://www.labour.gov.hk/eng/public/os/B/Bamboo.pdf)（勞工處）
- [第59I章建築地盤（安全）規例](https://www.elegislation.gov.hk/hk/cap59I)
- 保護網必須具有「適當嘅阻燃特性」

事件後：宏福苑嘅材料「燃燒得更加猛烈，蔓延速度明顯快過符合安全標準嘅材料」（[保安局](https://www.cnn.com/2025/11/27/world/bamboo-scaffolding-scrutiny-hong-kong-fire-intl-hnk)）。

## 模擬參數（條狀模型）

| 參數 | 數值 | 理據 |
|------|------|------|
| FDS版本 | 6.10.1 | [官方版本](https://github.com/firemodels/fds/releases/tag/FDS-6.10.1)（2025年3月） |
| 網格單元 | 225,000 | 20厘米解像度，D*/dx ≈ 7.5 |
| 領域 | 10m × 5.6m × 30m | 單一外牆，1/3高度驗證 |
| 壓力求解器 | UGLMAT HYPRE | 複雜多孔幾何 |
| 湍流 | Deardorff（預設） | 火羽標準LES |
| 輻射 | 40%輻射分數 | 擴散火焰典型值 |
| MPI進程 | 15 | 每個mesh一個 |

## 參考資料

### Fire Dynamics Simulator
- [FDS-SMV官方網站](https://pages.nist.gov/fds-smv/) - NIST
- [FDS GitHub儲存庫](https://github.com/firemodels/fds)
- [FDS網格大小計算器](https://fdstutorial.com/fds-mesh-size-calculator/)
- [FDS網格解像度指南](https://cloudhpc.cloud/2022/10/12/fds-mesh-resolution-how-to-properly-calculate-fds-mesh-size/)

### 竹火災特性
- [竹結構火災增長](https://www.sciencedirect.com/science/article/abs/pii/S0379711220301375) - Fire Safety Journal
- [層壓竹消防安全設計](https://www.researchgate.net/profile/Ian-Pope-5/publication/356838161_Fire_safety_design_tools_for_laminated_bamboo_buildings/links/627a1ac32f9ccf58eb3c30e8/Fire-safety-design-tools-for-laminated-bamboo-buildings.pdf) - Pope等
- [竹熱解動力學](https://www.mdpi.com/2227-9717/12/11/2458) - MDPI Processes

### 聚合物燃燒
- [阻燃聚丙烯](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7464193/) - PMC
- [聚丙烯火災危險](https://link.springer.com/chapter/10.1007/978-94-011-4421-6_34) - Springer
- [FR-HDPE指南](https://www.globalplasticsheeting.com/our-blog-resource-library/fire-retardant-woven-hdpe-the-ultimate-guide)

### 聚苯乙烯火災危險
- [暴露於火嘅EPS保溫](https://pmc.ncbi.nlm.nih.gov/articles/PMC10884846/) - PMC
- [聚苯乙烯外牆保溫燃燒](https://onlinelibrary.wiley.com/doi/10.1002/app.53503) - Wiley

### 外牆火災測試
- [BS 8414消防性能](https://www.designingbuildings.co.uk/wiki/BS_8414_Fire_performance_of_external_cladding_systems) - Designing Buildings
- [EN 13501-1消防分類](https://measurlabs.com/blog/en-13501-1-fire-classification-performance-classes-and-criteria/) - Measurlabs

### 香港法規
- [竹棚架安全守則](https://www.labour.gov.hk/eng/public/os/B/Bamboo.pdf) - 勞工處
- [建築地盤規例第59I章](https://www.elegislation.gov.hk/hk/cap59I) - 香港電子法例
- [建築地盤消防安全](https://www.cic.hk/files/page/52/Fire%20Safety%20-%20Enhance%20Fire%20Safety%20Measures%20at%20Construction%20Sites%20-%20Safety%20Message%20No.%20024-25%20(Oct%202025).pdf) - 建造業議會

### 宏福苑事件
- [半島電視台：竹棚分析](https://www.aljazeera.com/news/2025/11/27/what-is-bamboo-scaffolding-and-how-did-it-worsen-the-hong-kong-fire)
- [The Conversation：專家解釋](https://theconversation.com/why-is-bamboo-used-for-scaffolding-in-hong-kong-a-construction-expert-explains-270780)
- [CNN：火災後審視](https://www.cnn.com/2025/11/27/world/bamboo-scaffolding-scrutiny-hong-kong-fire-intl-hnk)
- [Fire Engineering](https://www.fireengineering.com/fire-safety/hong-kong-fire-raises-questions-about-bamboo-scaffolding/)

---

# Wang Fuk Court Fire Documentation

<p align="center">
  <em>"He would see this country burn if he could be king of the ashes"</em>
  <br>
  — Lord Varys
</p>

## Overview

This project documents and analyzes the Wang Fuk Court fire tragedy (November 26, 2025, Tai Po, Hong Kong) that claimed 159+ lives. Our goals:

1. **Preserve evidence** before it disappears
2. **Enable independent analysis** through fire dynamics simulation
3. **Support fire safety improvements** through rigorous technical investigation

We welcome contributions from anyone with relevant information. See [CONTRIBUTING.md](CONTRIBUTING.md) for how to help, or [ANONYMOUS-CONTRIBUTIONS.md](ANONYMOUS-CONTRIBUTIONS.md) if you have safety concerns.

## Project Structure

```
├── evidence/              # Evidence collection
│   ├── news/              # News reports and media coverage
│   ├── firsthand/         # Witness statements and survivor accounts
│   ├── media/             # Photos and videos
│   └── official/          # Government documents
├── analysis/              # Technical analysis
│   ├── methodology.md     # Investigation framework (NIST/Grenfell-inspired)
│   ├── building/          # Building analysis
│   └── regulatory/        # Regulatory compliance review
├── simulation/            # FDS fire dynamics simulation
│   ├── *.fds              # FDS input files
│   └── scripts/           # AWS launch and monitoring scripts
└── resources/             # Tools and references
```

## Fire Dynamics Simulation

8 FDS simulations to determine material contributions to fire spread.

### Simulation Scope

This study models **only the scaffold facade** (10m × 5.6m × 90m) to isolate scaffold material contributions. We intentionally exclude:

- **Full building interior**: Not modeling internal compartments, occupants, or building structure. Our focus is scaffold materials, not evacuation or structural failure.
- **Building complex**: Not modeling adjacent buildings or the entire Wang Fuk Court site. The fire behavior on a single facade is sufficient to compare material contributions.
- **Wind effects**: No prevailing wind conditions modeled. Wind would affect overall fire spread but not the relative contribution of each material (bamboo vs steel, PP vs FR-HDPE, styrofoam vs none), which is our research question.

This simplified approach allows us to:
1. Directly compare material contributions without confounding variables
2. Complete simulations in reasonable time (45 hours vs months)
3. Focus computational resources on high-resolution material combustion

## Simulation Matrix

### TIER 1: Critical Validation (5 simulations)

| # | File | Scaffolding | Safety Net | Styrofoam | Purpose |
|---|------|-------------|------------|-----------|---------|
| 1 | tier1_1_bamboo_PP_styro.fds | Bamboo | PP (non-compliant) | Yes | **ACTUAL incident** |
| 2 | tier1_2_steel_PP_styro.fds | **Steel** | PP (non-compliant) | Yes | Isolate bamboo |
| 3 | tier1_3_bamboo_FR_styro.fds | Bamboo | **FR-HDPE (compliant)** | Yes | Isolate netting |
| 4 | tier1_4_steel_FR_styro.fds | **Steel** | **FR-HDPE (compliant)** | Yes | Full compliance with styrofoam |
| 5 | tier1_5_bamboo_FR_no_styro.fds | Bamboo | **FR-HDPE (compliant)** | **No** | Styrofoam effect with FR net |

### TIER 2: Extended Analysis (3 simulations)

| # | File | Scaffolding | Safety Net | Styrofoam | Purpose |
|---|------|-------------|------------|-----------|---------|
| 6 | tier2_1_bamboo_none_styro.fds | Bamboo | **None** | Yes | Total net effect |
| 7 | tier2_2_bamboo_HDPE_styro.fds | Bamboo | **HDPE (cheap)** | Yes | PP vs HDPE |
| 8 | tier2_3_steel_FR_nostyro.fds | Steel | FR-HDPE | **No** | Styrofoam effect with full compliance |

## Fire Source

**Ignition**: Single ignition source at ground level (z=0.0-2.0m)
- HRRPUA: 2500 kW/m²
- Location: 4.0-6.0m (x) × 4.25-5.0m (y)
- Fire spreads naturally through combustible scaffold materials

**No apartment window jets** - Focus is on scaffold material contribution, not apartment fires.

## Material Properties

### Scaffolding Materials
- **Bamboo**: Wet bamboo (40 kg/m³) → Dry (35 kg/m³) → Char (10 kg/m³) + Wood vapor
  - Ignition: 280°C
  - HoC: ~15 MJ/kg
- **Steel**: Inert, non-combustible, high conductivity (heat sink)

### Safety Net Materials
- **PP Tarpaulin** (non-compliant): Ignition 345°C, HoC 46 MJ/kg, burns 12.4 mm/min
- **HDPE** (cheap Chinese std): Ignition 355°C, HoC 43 MJ/kg
- **FR-HDPE** (compliant): Ignition 475°C, burns 0.8 mm/min (15.5× slower!)
- **None**: No netting (baseline)

### Window Sealing
- **Styrofoam**: Polystyrene foam, ignition 350°C, HoC 40 MJ/kg, massive soot
- **No Styrofoam**: Windows closed but not sealed with insulation

## Running on AWS

### Custom AMI

Simulations use a pre-built AMI with:
- **FDS 6.10.1** with HYPRE v2.32.0 and Sundials v6.7.0 (statically linked)
- **Intel oneAPI** (MPI, compilers, math libraries)
- FDS binary: `/opt/fds/bin/fds`
- Environment setup: `source /opt/intel/oneapi/setvars.sh`

The AMI is available in multiple regions (eu-north-1, eu-south-1, eu-south-2, ap-northeast-1, ap-southeast-3).

### Launch Script

```bash
cd simulation

# Basic launch
./scripts/launch_aws.sh --key-path ~/.ssh/fds-key-pair tier1_*.fds tier2_*.fds

# Fresh start (delete existing S3 output)
./scripts/launch_aws.sh --key-path ~/.ssh/fds-key-pair --clean tier1_1.fds

# Larger disk for big simulations
./scripts/launch_aws.sh --key-path ~/.ssh/fds-key-pair --volume-size 200 tier1_1.fds
```

The script will:
1. Find cheapest region with available spot capacity
2. Auto-detect custom FDS AMI in the selected region
3. Create VPC, security groups, and S3 Gateway endpoint
4. Launch EC2 spot instance (c7i.12xlarge, 48 vCPUs, 100GB disk)
5. Upload FDS file and start simulation in tmux
6. **Resume from checkpoint** if restart files exist in S3 (unless `--clean`)
7. Track instance info in SQLite database (`instances.db`)
8. Sync outputs to S3 bucket (`fds-output-wang-fuk-fire`)

### Monitor Status

```bash
./scripts/check_status.sh --key-path ~/.ssh/fds-key-pair --watch --interval 60
```

### Manual Execution (on EC2 instance)

#### SSH into the instance
```bash
ssh -i ~/.ssh/fds-key-pair ubuntu@<INSTANCE_IP>
```

#### Start a fresh simulation
```bash
# Load Intel environment (required once per session)
source /opt/intel/oneapi/setvars.sh

# Navigate to work directory
cd ~/fds-work/<CHID>

# Count meshes in FDS file
NUM_MESHES=$(grep -c '&MESH' <simulation>.fds)

# Run in tmux (persists after SSH disconnect)
tmux new-session -d -s fds_run "source /opt/intel/oneapi/setvars.sh && mpiexec -n $NUM_MESHES /opt/fds/bin/fds <simulation>.fds"
```

#### Resume from a restart file
```bash
# Edit FDS file to enable restart mode
sed -i 's/^&MISC /&MISC RESTART=.TRUE., /' <simulation>.fds

# Start simulation (reads the latest *.restart file automatically)
tmux new-session -d -s fds_run "source /opt/intel/oneapi/setvars.sh && mpiexec -n $NUM_MESHES /opt/fds/bin/fds <simulation>.fds"
```

#### Monitor progress
```bash
# Attach to running tmux session (Ctrl+B, D to detach)
tmux attach -t fds_run

# Check simulation progress
tail -f ~/fds-work/<CHID>/<CHID>.out

# Check current simulation time
grep "Time Step" ~/fds-work/<CHID>/<CHID>.out | tail -5

# Check for errors
grep -i "error\|warning\|instability" ~/fds-work/<CHID>/<CHID>.out
```

## Output Files

Each simulation produces:

### Core Files
- `*.out` - Text output log (solver diagnostics, timing, errors)
- `*.smv` - Smokeview visualization metadata
- `*.restart` - Checkpoint files for resuming simulations (every 300s)

### CSV Data
- `*_hrr.csv` - Heat Release Rate time series
- `*_steps.csv` - Time step statistics (CFL, pressure iterations)
- `*_devc.csv` - Device measurements (AST temperatures, gas temperatures)

### Visualization Files
- `*.sf` - Slice files (temperature, velocity, HRRPUV cross-sections)
- `*.bf` - Boundary files (wall temperature, convective/radiative heat flux)
- `*.prt5` - Particle data (falling debris trajectories)
- `*.s3d` - 3D smoke visualization data

## Analysis

### Primary Metrics
1. **Peak HRR** (MW) - Fire intensity
2. **Time to Floor 30** (s) - Spread rate
3. **Total heat released** (GJ) - Fuel contribution

### Comparison Method
```python
bamboo_contribution = (Sim1_HRR - Sim2_HRR) / Sim1_HRR * 100
netting_compliance = (Sim1_time - Sim3_time)  # Extra evacuation time
styrofoam_effect = (Sim3_HRR - Sim5_HRR) / Sim3_HRR * 100
```

## Policy Implications

### Question 1: Should Hong Kong ban bamboo scaffolding?
**Analysis**: Compare Sim 1 vs Sim 2

### Question 2: Was non-compliant netting the main problem?
**Analysis**: Compare Sim 1 vs Sim 3

### Question 3: Could compliance have prevented deaths?
**Analysis**: Compare Sim 1 vs Sim 4

### Question 4: Was styrofoam the biggest culprit?
**Analysis**: Compare Sim 3 vs Sim 5, and Sim 4 vs Sim 8

## Technical Background

### Incident Facts

The Wang Fuk Court fire occurred on November 26, 2025 at ~14:51 HKT in Tai Po District, Hong Kong. Key factors from news reports:

- **Building:** 8 blocks of 31-storey towers (~90m height), opened 1983
- **Casualties:** 159+ deaths
- **Weather:** Red Fire Danger Warning in effect (issued Nov 24); 23°C, 42% RH, NW wind ~16 km/h ([timeanddate.com](https://www.timeanddate.com/weather/hong-kong/hong-kong/historic?month=11&year=2025))
- **Fire spread:** Rapid vertical spread via chimney effect in scaffold cavity; escalated to 5-alarm fire within 4 hours
- **Investigation:** Seven scaffolding net samples failed fire retardant testing; fire alarms failed to operate properly

Sources: [Al Jazeera](https://www.aljazeera.com/news/2025/11/27/hong-kongs-deadliest-fire-in-63-years-what-we-know-and-how-it-spread), [SCMP](https://multimedia.scmp.com/infographics/news/hong-kong/article/3334304/taipo_wangfuk_fire/index.html), [HK01](https://www.hk01.com/%E7%AA%81%E7%99%BC/60297831), [Wikipedia](https://en.wikipedia.org/wiki/Wang_Fuk_Court_fire)

### Why Model Only the Scaffold Facade?

The scaffold facade modeling approach isolates the **material contribution question** from confounding variables. This follows principles similar to [BS 8414](https://www.designingbuildings.co.uk/wiki/BS_8414_Fire_performance_of_external_cladding_systems) facade fire tests:

- **Chimney effect:** The gap between scaffolding and building exterior creates a vertical channel accelerating upward flame spread (3-6× faster than open fires per [facade fire research](https://www.sciencedirect.com/science/article/abs/pii/S2352710221011153))
- **Isolated variables:** Directly attribute heat release to specific materials (bamboo vs steel, PP vs FR-HDPE, styrofoam vs none)

### Porous Scaffolding Geometry

The model implements a **3D porous scaffolding** approach with discrete structural elements:

| Layer | Y-Position | Thickness | Description |
|-------|-----------|-----------|-------------|
| Safety Net | 4.05-4.25m | 0.2m | Continuous PP tarpaulin layer |
| Outer Bamboo Row | 4.25-4.45m | 0.2m | Discrete vertical poles (5 per 10m span) |
| *Air Cavity* | 4.45-4.65m | 0.2m | Primary chimney channel |
| Inner Bamboo Row | 4.65-4.85m | 0.2m | Discrete vertical poles |
| *Air Gap* | 4.85-5.00m | 0.15m | Secondary convection path |
| Styrofoam | 5.00-5.05m | 0.05m | Window sealant (at window locations only) |
| Building Wall | 5.05-5.25m | 0.2m | Concrete substrate |

Horizontal ledgers connect the bamboo rows every ~3m vertically, creating a realistic scaffold structure.

**Why this geometry matters:**
- **Chimney effect:** The air cavities between layers allow hot gases to accelerate upwards, pre-heating fuel above and driving rapid vertical fire spread
- **Fuel surface area:** Discrete bamboo poles have higher surface-area-to-volume ratio than solid sheets, enabling realistic pyrolysis rates
- **Airflow paths:** Gaps between poles permit horizontal cross-ventilation while maintaining vertical draft

### Mesh Resolution Justification

The 20cm cell size is based on the [characteristic fire diameter (D*)](https://fdstutorial.com/fds-mesh-size-calculator/):

**D* formula:** D* = (Q / (ρ∞ × cp × T∞ × √g))^(2/5)

| Parameter | Value |
|-----------|-------|
| HRRPUA | 2500 kW/m² over 1.5m² = 3.75 MW |
| D* | ≈1.5m |
| Cell size (dx) | 0.2m |
| **D*/dx** | **≈7.5** (medium resolution) |

The [FDS User Guide](https://pages.nist.gov/fds-smv/) recommends D*/dx of 4 (coarse), 10 (medium), or 16 (fine). Our 7.5 ratio provides adequate resolution while maintaining computational feasibility.

### Pressure Solver: UGLMAT HYPRE

The complex porous bamboo geometry requires `SOLVER='UGLMAT HYPRE'`:

- **U (Unstructured):** Solves pressure only in gas phase, eliminating velocity leakage through thin obstructions
- **G (Global):** Solves pressure globally across all meshes, ensuring accurate vertical pressure gradients for chimney flow
- **HYPRE:** Efficient multigrid library managing memory for large problems

### Bamboo Combustion Model

Bamboo pyrolysis uses a two-step reaction scheme based on [lignocellulosic combustion research](https://www.sciencedirect.com/science/article/abs/pii/S0379711220301375):

1. **Drying:** Wet bamboo (40 kg/m³, ~12% moisture) → Dry bamboo (35 kg/m³) + Water vapor
2. **Pyrolysis:** Dry bamboo → Char (10 kg/m³) + Combustible gases (280-400°C)

| Property | Value | Source |
|----------|-------|--------|
| Ignition temperature | 280-386°C | [Pope et al.](https://www.researchgate.net/profile/Ian-Pope-5/publication/356838161_Fire_safety_design_tools_for_laminated_bamboo_buildings/links/627a1ac32f9ccf58eb3c30e8/Fire-safety-design-tools-for-laminated-bamboo-buildings.pdf) |
| Heat of combustion | 15-23 MJ/kg | [Bio-char research](https://www.sciencedirect.com/science/article/abs/pii/S036054422404091X) |
| Pyrolysis range | 257-400°C | [TGA studies](https://www.mdpi.com/2227-9717/12/11/2458) |

Vertical bamboo pole orientation allows fire to spread "without any resistance" ([HK PolyU](https://theconversation.com/why-is-bamboo-used-for-scaffolding-in-hong-kong-a-construction-expert-explains-270780)).

### Safety Net Materials

#### Polypropylene (PP) - Non-Compliant

PP tarpaulins are the primary fire hazard. Properties from [fire hazard research](https://link.springer.com/chapter/10.1007/978-94-011-4421-6_34):

| Property | Value |
|----------|-------|
| Density | 900 kg/m³ |
| Specific heat | 1.9 kJ/kg·K |
| Thermal conductivity | 0.22 W/m·K |
| Ignition | 345°C (melts 130-160°C) |
| Heat of combustion | 46 MJ/kg |
| Burn rate | 12.4 mm/min |

[Melting and dripping behavior](https://www.cuspuk.com/fire-safety/plastic-fire-risks/) spreads fire unpredictably, forming pool fires at base.

#### FR-HDPE - Compliant

[Flame retardant HDPE](https://www.globalplasticsheeting.com/our-blog-resource-library/fire-retardant-woven-hdpe-the-ultimate-guide) incorporates fire-retardant additives:

| Property | Value |
|----------|-------|
| Ignition | ~475°C |
| Burn rate | 0.8 mm/min (**15.5× slower than PP**) |
| Classification | Should meet [EN 13501-1](https://measurlabs.com/blog/en-13501-1-fire-classification-performance-classes-and-criteria/) Class E |

### Polystyrene (EPS) Window Sealing

EPS foam used to seal windows. From [combustion research](https://pmc.ncbi.nlm.nih.gov/articles/PMC10884846/):

| Property | Value |
|----------|-------|
| Density | 25 kg/m³ (98% air) |
| Specific heat | 1.3 kJ/kg·K |
| Thermal conductivity | 0.03 W/m·K |
| Ignition | 346-360°C |
| Peak HRR | 493.9 kW/m² |
| Heat of combustion | 40 MJ/kg |

Combustion products include CO, monostyrene, hydrogen bromide, and aromatic compounds.

### Stability Controls (Strip Model)

| Parameter | Setting | Purpose |
|-----------|---------|---------|
| CFL_MAX | 1.0 | Convective stability (v×Δt/Δx < 1) |
| VN_MAX | 0.5 | Diffusive stability (α×Δt/Δx² < 0.5) |
| CHECK_VN | .TRUE. | Enable Von Neumann checking for pyrolysis |
| Ignition ramp | 0→50%→100% over 60s, then off at 180s | Gradual ignition to prevent pressure spikes |

### Regulatory Context

Hong Kong scaffolding regulations require:
- [Code of Practice for Bamboo Scaffolding Safety](https://www.labour.gov.hk/eng/public/os/B/Bamboo.pdf) (Labour Department)
- [Cap. 59I Construction Sites (Safety) Regulations](https://www.elegislation.gov.hk/hk/cap59I)
- Protective nets must have "appropriate fire retardant properties"

Post-incident: Materials at Wang Fuk Court "burned much more intensely and spread significantly faster than materials that meet safety standards" ([Security Bureau](https://www.cnn.com/2025/11/27/world/bamboo-scaffolding-scrutiny-hong-kong-fire-intl-hnk)).

## Simulation Parameters (Strip Model)

| Parameter | Value | Justification |
|-----------|-------|---------------|
| FDS Version | 6.10.1 | [Official release](https://github.com/firemodels/fds/releases/tag/FDS-6.10.1) (March 2025) |
| Grid cells | 225,000 | 20cm resolution, D*/dx ≈ 7.5 |
| Domain | 10m × 5.6m × 30m | Single facade, 1/3 height validation |
| Pressure solver | UGLMAT HYPRE | Complex porous geometry |
| Turbulence | Deardorff (default) | Standard LES for fire plumes |
| Radiation | 40% radiative fraction | Typical for diffusion flames |
| MPI processes | 15 | One per mesh |

## References

### Fire Dynamics Simulator
- [FDS-SMV Official Site](https://pages.nist.gov/fds-smv/) - NIST
- [FDS GitHub Repository](https://github.com/firemodels/fds)
- [FDS Mesh Size Calculator](https://fdstutorial.com/fds-mesh-size-calculator/)
- [FDS Mesh Resolution Guide](https://cloudhpc.cloud/2022/10/12/fds-mesh-resolution-how-to-properly-calculate-fds-mesh-size/)

### Bamboo Fire Properties
- [Fire growth for bamboo structures](https://www.sciencedirect.com/science/article/abs/pii/S0379711220301375) - Fire Safety Journal
- [Fire safety design for laminated bamboo](https://www.researchgate.net/profile/Ian-Pope-5/publication/356838161_Fire_safety_design_tools_for_laminated_bamboo_buildings/links/627a1ac32f9ccf58eb3c30e8/Fire-safety-design-tools-for-laminated-bamboo-buildings.pdf) - Pope et al.
- [Pyrolysis kinetics of bamboo](https://www.mdpi.com/2227-9717/12/11/2458) - MDPI Processes

### Polymer Combustion
- [Flame Retardant Polypropylenes](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7464193/) - PMC
- [Fire hazard with polypropylene](https://link.springer.com/chapter/10.1007/978-94-011-4421-6_34) - Springer
- [FR-HDPE Guide](https://www.globalplasticsheeting.com/our-blog-resource-library/fire-retardant-woven-hdpe-the-ultimate-guide)

### Polystyrene Fire Hazards
- [Fire exposed EPS insulation](https://pmc.ncbi.nlm.nih.gov/articles/PMC10884846/) - PMC
- [Polystyrene exterior wall insulation combustion](https://onlinelibrary.wiley.com/doi/10.1002/app.53503) - Wiley

### Facade Fire Testing
- [BS 8414 Fire performance](https://www.designingbuildings.co.uk/wiki/BS_8414_Fire_performance_of_external_cladding_systems) - Designing Buildings
- [EN 13501-1 Fire Classification](https://measurlabs.com/blog/en-13501-1-fire-classification-performance-classes-and-criteria/) - Measurlabs

### Hong Kong Regulations
- [Bamboo Scaffolding Safety Code](https://www.labour.gov.hk/eng/public/os/B/Bamboo.pdf) - Labour Department
- [Construction Sites Regulations Cap. 59I](https://www.elegislation.gov.hk/hk/cap59I) - HK e-Legislation
- [Fire Safety at Construction Sites](https://www.cic.hk/files/page/52/Fire%20Safety%20-%20Enhance%20Fire%20Safety%20Measures%20at%20Construction%20Sites%20-%20Safety%20Message%20No.%20024-25%20(Oct%202025).pdf) - CIC

### Wang Fuk Court Incident
- [Al Jazeera: Bamboo scaffolding analysis](https://www.aljazeera.com/news/2025/11/27/what-is-bamboo-scaffolding-and-how-did-it-worsen-the-hong-kong-fire)
- [The Conversation: Expert explains](https://theconversation.com/why-is-bamboo-used-for-scaffolding-in-hong-kong-a-construction-expert-explains-270780)
- [CNN: Scrutiny after fire](https://www.cnn.com/2025/11/27/world/bamboo-scaffolding-scrutiny-hong-kong-fire-intl-hnk)
- [Fire Engineering](https://www.fireengineering.com/fire-safety/hong-kong-fire-raises-questions-about-bamboo-scaffolding/)
