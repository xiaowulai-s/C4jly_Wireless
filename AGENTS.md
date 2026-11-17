# AGENTS.md — 本项目硬约束（C4F7N 检漏仪）

> 违反任一条都可能造成**不可逆损伤**。动手前必读。

## 1. 源码编码（最高优先级）

- **含中文的 C 源文件必须 GBK(ANSI 936)**。armcc(AC5) 按系统代码页解析，UTF-8 中文 → `#53 expected a ":"` / `#8 missing closing quote`。
- **禁止**用 Write/Edit 等输出 UTF-8 的工具直接改写含中文源文件。正确做法：写 UTF-8 临时文件 → 以 UTF-8 读入 → **以 GBK 写出**。
- PowerShell 读写必须 `[System.Text.Encoding]::GetEncoding(936)`。**PS 5.1 的 `-Encoding gbk` 无效**。
- **改写前先判定单文件真实编码**（本项目历史上是混合态，不可统一假设）。
- **乱码扫描必须双线索**：`EF BF BD` 字节数 **和** `U+FFFD` 数。`EF BF BD` 在 GBK 下是合法汉字（`锟斤拷`），只查 U+FFFD 会漏检。
- 编码二次毒化**不可逆**，原文丢失后只能语义重建。
- GBK 第二字节可能是 `0x5C`（反斜杠）：`//` 注释行尾若为中文可能吞掉下一行。

## 2. 编译 / 工具链

- 官方 MDK 装在 **`D:\KEIL`（MDK Plus 5.43）**，同时提供 **AC5 (armcc 5.06u1)** 与 **AC6 (ARMCLANG 6.24)**。C4F7N 工程实际用 **AC6 V6.24**（`.uvprojx` 中 `pArmCC=6240000::V6.24::ARMCLANG`、`uAC6=1`）。**必须用 `D:\KEIL\UV4\UV4.exe` 批处理编译**（`UV4 -j0 -b`）。
- `C:\Keil_v5` 只装了 AC5，无 ARMCLANG，别用它的 UV4 编译本工程（会报 `ARM-Compiler not available` 中止）。
- 编译/解码前先确认注册表 `HKLM\SOFTWARE\WOW6432Node\Keil\Products\MDK` 的 `Path`，勿凭记忆假设工具链位置。⚠️ 该 `Path` 指向 `D:\KEIL\ARM`（工具链子目录），UV4.exe 实际在 `D:\KEIL\UV4\UV4.exe`。
- PowerShell `&` 调 UV4 **不会等待**（GUI 子系统）：用 `Start-Process -Wait` 或轮询 `Get-Process UV4` + 检查产物落盘时间。**UV4 可能在编译完成后收尾挂起但产物已完整落盘**，结果以 `-o` 日志 / `build_log.htm` 为准；挂起进程 taskkill 可能拒绝（Access denied），需任务管理器结束。
- ★ **UV4 必须经 shell(cmd) 启动**（2026-09-22 实测结论）：Node 用 `spawnSync('"D:/KEIL/UV4/UV4.exe" -j0 -b "<proj>" -o "<log>"', {shell:true})` **可行**；而 `execFileSync(UV4, args)` / `spawnSync(UV4, args)` 直接 CreateProcess 会 **立即 `EACCES` 失败（约 52ms，无日志产出）**。该失败**与 Keil GUI 是否运行无关**（GUI 关闭后依然复现）—— 早期"必须关 Keil GUI"的归因**是错的**。
  - 参考脚本：`tjc-hmi-toolkit/C4F7N/_uv4_build.js`（`--mode=d` 增量 `-b` / `--mode=e` 全量重建 `-r` / `--mode=f` 清产物后重编）。
  - 验证编译真的发生：日志须含 `Rebuild target` + 逐文件 `compiling xxx.c...`，而不是只有 `Build Time Elapsed: 00:00:00`（那是"已是最新、未编译"）。
- ★★★ **但 UV4.exe 在部分环境（本机 2026-10-12）被系统直接禁止执行**（`Permission denied`，Node/Bash/PS/沙箱内外全失败）。
  **此时改用 `armclang.exe` 做单文件语法/编译校验 —— 它可以正常直接调用：**
  ```bash
  cd C4F7N_Demo/MDK-ARM
  "D:/KEIL/ARM/ARMCLANG/Bin/armclang.exe" --target=arm-arm-none-eabi -mcpu=cortex-m3 -c \
    -D__MICROLIB -DUSE_HAL_DRIVER -DSTM32F103xE \
    -I../Core/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy \
    -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include \
    -I../Middleware/Inc -I../Middleware/Src -I../BSP/Inc -I../BSP/Src -I./C4F7N_Demo \
    -o /tmp/t.o ../BSP/Src/sensor.c
  ```
  封装脚本：**`node _ac_check.js [文件...]`**（需 `dangerouslyDisableSandbox:true`），默认查 9 个常用改动文件。
  ⇒ **改完固件先本地校验，不要直接让用户 Rebuild**；只有需要出 hex/axf/Code 尺寸时才需要 Keil。
- ★★ **AC6 报 `source file is not valid UTF-8` 时，先查报错行附近的块注释有没有 `*/` 提前闭合**
  （2026-10-12 踩过）：注释中段出现 `*/` ⇒ 后续行落到注释外被当代码 ⇒ 报
  `invalid-source-encoding` + `type specifier missing` + `unexpected character <U+036C>`，
  **三个报错是同一根因**。★ **给 GBK 源文件写注释优先用 ASCII**，可完全规避这类编码纠缠。
  （AC6 本身能正常编译 GBK 文件里的中文注释 —— 基线 `sensor.c` 有大量中文注释一直编得过。）
- ★ **Node 脚本里不要 spawn `git`**（2026-09-24 实测）：`spawnSync('git',[...])` 与 `spawnSync('git ...',{shell:true})` **都返回 `status=null, error.code='EBUSY'`**（同类问题：跨目录直接 CreateProcess 被拦）。
  后果示例：用 `git ls-files --error-unmatch` 判断"文件是否入库"会**全部误判为未跟踪** → 移动文件时会用 `fs.renameSync` 而非 `git mv`，
  git 便显示"删除 + 新目录未跟踪"（补救：`git add -A` 后可被识别为 rename，历史不丢，但状态一度混乱）。
  → **涉及 git 的操作在 Bash 里直接用 `git mv` / `git ls-files`**，不要在 Node 里 spawn git。
- 固件 hex 归档惯例：`tjc-hmi-toolkit/C4F7N/C4F7N_v*_firmware.hex`（v4~v19），**不是项目根目录**。编译日志一并归档为 `C4F7N_v*_build.log`。
- `main.c` 的 EOL 是 **LF**（非 CRLF）：GBK 补丁脚本必须动态检测 EOL（参考 `tjc-hmi-toolkit/_fw18_patch.js`：iconv-lite 读写 + 锚点必须唯一命中否则中止）。
- 改 `.uvprojx` / `.ioc` / `builder.params` 前必须先说明并确认。
- 屏串口是**手工配置**的 **USART3(PB10/PB11)**（已补登 `.ioc`）；USART1 为预留。
  ★ **波特率实际是 115200**（v25 起固件改 115200，屏端 `Program.s` 已配 `baud=115200`）。
  ⚠️ **本行历史上长期误记为 9600**（`.ioc` 手工配置未同步），并导致源码注释里的传输耗时估算
  放大了 **12 倍**（如 `refill_table` 1749B「≈1.82s」实为 **≈152ms**），
  据此误判「顶栏延迟是串口发送耗时」，白做 v67/v68 两版无效改动。
  ⇒ **引用任何耗时前先读 `usart.c` 当前 `huart3.Init.BaudRate`，注释里的数字一律不可信。**

## 3. 屏端 TJC（tjc-hmi-toolkit）

- 脚本**单行 ≤15 字节(GBK)** —— 准确说：**≥16 字节的是我们自己的解析工具会误判**（`lib/page.js` 的 `L>=16 ⇒ attr` 启发式），TJC 原厂键盘模板本身就有 20~93 字节的脚本行，并非"引擎崩溃"。**仍建议写短行**（`page.set`/`setCodes` 等改脚本工具都依赖该启发式）。识别信号：`codesXX-N` 声明行数 ≠ 实读行数 → 用 `_script_dump_bycount.js` 读。
- ★ **脚本行还有「字符数」上限（实测 >255 字符 → 该行语句失效）**：改 `.pa`/`Program.s` 时，**补白/长注释必须落在注释行，绝不能落在语句行**（2026-09-22 事故：为保持 `Program.s` 块尺寸 878B，把 302 个空格补在了 `page 6` 那一行 → 358 字符 → `page 6` 失效 → 上电进不了初始化页）。改完必须**断言每行字符数 < 200**。
- ★ **TJC 页面 ID = 编辑器页面列表的顺序（0 起），不是 `.pa` 文件名里的数字**（文件名只是资源槽号，删页后不重排）。⚠️ **该顺序会随"用户增删改页 / 编辑器重存"而变化** → 每次改屏后**必须重新确认**。当前实测（2026-09-23，fix13 改版后）：
  | 页面 ID | `.pa` 文件 | 页名 |
  |---|---|---|
  | 0 | `4.pa` | 主页 |
  | 1 | `0.pa` | 历史曲线 |
  | 2 | `5.pa` | 设置 |
  | 3 | `6.pa` | 初始化 |
  | 4 | `1.pa` | keybdB（数字键盘） |
  → `page N` / `tjc_page(N)` 用左列（2026-09-23 起上电为 `page 3` 进初始化页）。**历史事故**：曾用 `page 6` / `tjc_page(6)` 指向不存在的页 → 上电进不了初始化页。
  ★ **`h.key` 的 N 不是页 ID**，而是**「键盘风格」选择项**（官方 QA19：在控件 key 属性里选所需键盘风格，编辑器据此自动建键盘页）；**编辑器保存时恒把它写回 `2`** → **不要手改**；绑定是否有效只能**真机点一下**确认（曾按"页 ID"改成 3/4，是误判）。
  ★ **固件侧另有一套页号**（`hmi_on_page_enter(p)`）：**p=0 主页 / p=1 设置 / p=2 历史**（由 `0x40/0x41/0x42` 偏移而来）→ 与 TJC 页 ID **在"历史/设置"上恰好互换**，改导航码时别按页 ID 对齐。
- ★★★ **切页通知（`printh 4N`）只写在按钮的 `up` 事件里，任何新增切页途径都会漏掉它。**
  当前屏包 `C4F7N_v12.HMI` 的做法是：**各页 `load` 事件首行也发一条 `printh 4N`**，
  因为滑动翻页会走目标页 `load` ⇒ 按钮 / 滑动 / 固件主动三条途径全覆盖。
  ⚠️ **滑动翻页（划动翻页）** 由页对象的 **`left`/`down`/`right`/`up`** 属性控制
  （官方 QA65：`255` = 不翻页，填页号 = 滑到该页），**由屏端引擎直接切页、不执行任何控件事件**
  ⇒ 按钮 `up` 里的 `printh 4N` 根本不会发 ⇒ 固件收不到入屏信号 ⇒
  `g_page_now` 不更新、`g_full_dirty` 不置、`g_page_wait` 不置 ⇒ **页面内容不刷新**。
  ⚠️ **此时调 `HMI_PAGE_SETTLE_MS`（进页屏障）必然无效** —— 屏障只管"已收到通知之后"的补发时序，
  管不了"收不到通知"。
  ★ **分诊纪律**：症状「切页后内容不更新」有两层根因，**必须先分层**：
  (A) 收不到通知 ⇒ 只能屏端补发；(B) 收到通知但补发太早 ⇒ 固件加屏障。
  **动手前先确认「对方收到事件了吗」**，否则就是改错层次。
  排查工具：`tjc-hmi-toolkit/_probe_slide.js <HMI>`（列页对象 `up/down/left/right` + `effect/time`）、
  `_scan_page_switch.js`（切页点与通知配对，★须带 `fwOf()` 页号换算）。
  ★ 只看 `effect`/`time` 会**漏判滑动翻页**（2026-10-14 据此误判两次）⇒ **查页对象属性要全量看**。
- `obj.txt=` 文本必须 **GBK**。
- TJC **不支持 `else`**；`btn.val` **不能存业务状态**（改用 `Program.s` 全局变量）。
- **`page` 指令之后的代码不执行** → `printh` 必须写在 `page` **之前**。
- ★ **音频（按键音 / 报警音）**：屏为 **TJC1060X570_011R_I_G8** —— **无蜂鸣器、有喇叭**（接插件 PH1.25×2，≤2W），故 **`beep` 指令不可用**（官方：仅带蜂鸣器的型号支持），音频必须走 `play ch,audio,loop`（**仅 X3/X5 系列**）：`ch` = 通道 0/1、`audio` = **音频 ID = `main.HMI` 资源表内 wav 的顺序 = 文件名数字**（已实证）、`loop` = 0 单次 / 1 循环。通道控制用系统变量 `audio0`/`audio1`（**0=停 / 1=播 / 2=暂停**；停止态不能直接置 1，须用 `play` 重启）。**通道分配约定**：通道 0 = 固件报警音（`play 0,3,1` 循环），**通道 1 = 按键音**（`play 1,<ID>,0`）—— 分道后两路可混音共存、互不打断。⚠️ 官方警告：`play` 后屏黑屏/重启 = **供电不足**。
- **屏端唯一真源 = `.HMI` 本身**（09-18 教训：`config_c4f7n.json` 并非 v4 工程的源，对象集不一致；`gen_hmi2` 全量重建会破坏 GUI 手工保存页）。改法：`extract-pas` 提取 → 增量改 `.pa` → 用**当前在用的 `.HMI` 作模板**回打包（`hmipack-tjc.exe`）；**不要手改二进制 `.HMI` 字节**。
- **打包模板必须用当前在用的 `.HMI`**（现为 `C4F7N_v12.HMI`，6 页，md5 `2cd86542`，含厂家页手动补偿控件）：用旧基线打包会丢页；`base.HMI` 是 4 页空白容器，严禁使用。**只把要改的资源放进工作目录**，其余会被逐字节保留；`Program.s` **也可放进工作目录并改变长度**（实测输出 `replaced Program.s`）。
- **`.tft` 无法程序化生成**：必须在 USART HMI Editor GUI 打开 `.HMI` 后另存导出。⚠️ 导出前**先关掉编辑器占用**（`.HMI` 被打开时会 EBUSY 锁住，脚本读不了）。
- ★ **改屏后必做自检（T-28，2026-09-24 定为必要步骤）**：任何改 `.HMI` 的动作（新增/删除/改名控件、编辑器增删字库、改 `Program.s`）之后，**必须**跑
  `node tjc-hmi-toolkit/C4F7N/_font_v7b_audit.js <新.HMI>`，四项全过才算完：
  ① 无控件指向不存在的 `font` id（§4 须为空）② `font=` 与资源表一一对应 ③ 零引用字库仅限有意保留（`9.zi`/`10.zi` 是键盘页自带）④ 无新增重复字库。
  再配合 `tools/verify_all_pages.exe <新.HMI>` → 期望 `pages ok=N bad=0`。
  **为什么必须**：`font=` 按 `main.HMI` **资源表序号**引用，编辑器增删字库会**重编号** —— 序号一移就**全屏错字**，而**编辑器与引擎都不报错**。
- ★★ **HMI 归档策略（2026-09-30 用户裁定：一律不入库）**：`.gitignore` 含 `*.HMI`，**任何 `.HMI` 都不得进入仓库**（单版约 51 MB，且编辑器重存会改写字节 → 入库必然持续膨胀；GitHub 对 >50 MB 文件还会返回 `GH001` 告警）。**禁止用 `git add -f` 把 `.HMI` 加回仓库**。
  屏包基线改由**本地保存 / 交付包分发** → ⚠️ **仓库不再是屏包的备份源，`.HMI` 必须另行备份**（网盘等）。
  历史遗留：仓库仍跟踪 37 个 2026-09-30 之前的旧 `.HMI`（v1~v7、`_A_ctrl`、`base.HMI` 等），本次未清理；注意 **`git rm --cached` 不回收已入库体积**，真瘦身须 `git filter-repo`（会重写全部 SHA，破坏性操作，需用户决定）。

## 4. 改动纪律

- 改任何源文件**先备份**；批量替换前先全量扫描并列出待改清单。
- ★ **备份必须在改动之前拍，且拍完立刻记 md5**；回滚时先核 md5 再用。
  （曾把改后文件当备份，回滚时 md5 对不上，绕了一大圈。）
- 批量替换按**多维度**扫描（外设名 + 引脚名 + 波特率 + 变量名），单维度必漏。
- 声称"改完"前必须给出可复核证据（编译结果 / 字节级比对 / 工具校验）。
- ★ **本地编译只看 error 会漏 warning** —— 验收标准是**零 warning 且要看 warning 的内容**，
  内容里往往藏着真 bug（v83 的屏显乱码就藏在 `-Winvalid-source-encoding` 里）。
- 生产环境（106.54.229.143）操作须先确认，默认只在本地环境验证。

## 4.5 ★★ 屏固通信与并发（v79~v92 用 8 版换来的硬约束）

改 `hmi_*` / `tjc_*` / `main.c` 轮询函数前**必读**，五条都是踩过的坑：

1. **`g_get_busy` 是 get 通道唯一所有权，回包不带身份** ⇒ 路由判据必须是
   「谁**确实发出过 get 且还没收到回包**」（`g_thr_wait` / `g_mank_wait`），
   **不是**「谁有请求在等」（`g_thr_hi_req` / `g_manb_req`）。
   单通道时两者等价，双通道并存时完全分不清 ⇒ **间歇性错值**。

2. **UART 的 TX 只允许来自一个上下文（主循环）**。`HAL_UART_Transmit` 阻塞但**可被中断抢占**
   ⇒ ISR 里发串口会与主循环报文**在线上交织** ⇒ 屏端解析器错位并吞掉后续字节
   （含用户下一次按键的三字节握手）⇒ 表现为「**要点好几次才生效**」。
   ★ 雪上加霜：握手层对**裸命令码是"绝不执行"**（`hmi_callback.c:86-92`）
   ⇒ **丢一个字节 = 丢一次操作**，链路层零容错。

3. **多通道轮询函数里，「本通道的收尾（超时清旗标）」与「对外可见的上报」必须排在所有
   「让出给别的通道」的 `early-return` 之前**。放错 ⇒ **死锁 + 静默**
   （不是报错，是什么都不发生），且症状常退化成「比修之前更没反应」。

4. **新增走 `D5 5A NN` 三字节握手的命令码，必须同时改三处**：
   ① 协议头 `hmi_cmd_t` 枚举 ② `hmi_on_rx_byte()` 的 `switch` case
   ③ ★**`s_guard_list[]` 白名单**。
   漏第 ③ 处 ⇒ 握手层直接 `return`，`switch` 走不到，症状「点了完全没反应」且**无任何日志**。

5. **「点几次才生效」类症状 ⇒ 先怀疑链路层丢消息，别急着改业务判据。**
   若**同一操作在不同分支下都要多次**，问题不在分支逻辑里。
   排查顺序固定：① 命令有没有到达（加计数/诊断）→ ② 回包有没有回来 → ③ 分支判据对不对。
   ★ 跳过 ① 直接改 ③ 会**连续多版原地打转**（v84~v90 连续 7 版都栽在 ③ 上）。

> 两条通用纪律：**多症状先找共同上游**（别一个症状一个补丁）；
> **抄既有实现当骨架时，状态初始化那一半也要抄**
> （漏了「计时基准在请求处赋值」就让 get **从未发出过**，功能 100% 失效且不报错）。
> **交互参数（时间/阈值/步长）先问用户，别自己拍** —— 时间窗口是反模式，
> 能用「数据是否变化」表达的确认就不要用「时间」表达。

## 5. 参考

- 编码治理方法与证据：`docs/编码治理/C4F7N_中文注释乱码修复报告.md`
- 现状与待办：`开发进度表.md`、`HANDOVER.md`、`C4F7N_Demo/待确认项清单.md`
- ★ **屏固通信与并发的完整踩坑记录**：`.workbuddy/memory/2026-10-15.md`（v79~v92 根因链）
- ★ **屏包备份位置（`.HMI` 不在 Git 里）**：云盘 `D:\移动云盘同步盘\C4F7N检漏仪\`
  / 本地 `D:\Demo\C4jly\屏包备份\`；说明见 `README.md` §屏包与固件归档
