/*
 * c4f7n_hmi_protocol.h - C4F7N 检漏仪 屏幕(USART HMI TJC X5) <-> MCU(STM32F103RCT6)
 *
 * 版本: v40         配套屏幕工程: C4F7N_v8.HMI (新命名轨; 旧 C4F7N_HMI_v*.HMI 已废弃)
 * 串口: USART3 PB10(TX)/PB11(RX) @ 115200 8N1, 无流控 (USART1 PA9/PA10 为预留)
 *
 * --- 屏幕 -> MCU (用户交互, 脉冲单字节) ---
 *   屏幕用 TJC 脚本 `printh NN` 发 1 字节命令码; MCU 收到即触发动作, 无需帧尾。
 *   (背景: TJC 不支持 Nextion 的 print; 脚本行必须 <=15B)
 *
 * --- MCU -> 屏幕 (Nextion 文本指令) ---
 *   obj.attr=value 指令后跟 0xFF 0xFF 0xFF 帧尾; 文本指令格式
 */
#ifndef C4F7N_HMI_PROTOCOL_H
#define C4F7N_HMI_PROTOCOL_H

/* ===================================================================== 
 * 1. 屏幕 -> MCU 命令码 (printh 单字节)
 * ===================================================================== */
typedef enum {
  HMI_CMD_NONE         = 0x00,
  HMI_CMD_BUZZER_MUTE  = 0x06,    /* 主页静音按钮: 临时静音, 停止当前报警一次 */
  HMI_CMD_INIT_SKIP    = 0x07,    /* 跳过初始化: 从独立初始化页直接进入主页 */
  HMI_CMD_HIST_CLEAR   = 0x01,    /* 清空历史记录(历史页按钮, 屏端两段确认) */
  HMI_CMD_THR_HI_INC   = 0x02,    /* 高阈值+50 */
  HMI_CMD_THR_HI_DEC   = 0x03,    /* 高阈值-50 */
  HMI_CMD_THR_HI_SET   = 0x11,    /* 屏幕键盘改完高报阈值 -> 请 MCU 回读 h.val */
  HMI_CMD_CAL_ZERO     = 0x15,    /* 零点标定 */
  HMI_CMD_CAL_SPAN     = 0x16,    /* 量程标定 */
  HMI_CMD_CAL_FAC      = 0x17,    /* 恢复出厂 */
   /* 0x18: 原"泵/测试启停"命令。2026-09-30 接口审计确认: 屏端全工程**无任何 printh 18**, 
   *       屏上"泵/测试"按钮实际发 0x24(TEST_TOGGLE, 泵随测试启停)。故该命令连同
   *       hmi_on_pump_toggle() 一并删除; 命令位空出, 勿复用(留作扩展)。
   * 0x19: 预留(方案 B 手动零点补偿输入)。 */
   /* 0x21..: v2 移除单位切换/曲线视图, 复用为数据表翻页 */
  HMI_CMD_TBL_NEXT     = 0x23,    /* 表下一页 */
   /* 0x24: CSV 导出本阶段移除, 命令位已复用为"开始测试/停止测试"切换(按钮 ptg) */
  HMI_CMD_TEST_TOGGLE  = 0x24,    /* 测试 启停切换 */
  HMI_CMD_TBL_PREV     = 0x25,    /* 表上一页 */
   /* 页码通知 (导航按钮 printh 4N) */
  HMI_CMD_PAGE0_ENTER  = 0x40,
  HMI_CMD_PAGE1_ENTER  = 0x41,
  HMI_CMD_PAGE2_ENTER  = 0x42,
  HMI_CMD_PAGE3_ENTER  = 0x43,
   /* 硬件零点校准 与 15ppm 下限(两者屏端均为短按, 防护全在固件两步确认) 
   *   两者都向 UART4 下发厂商指令, 固件侧再叠加两步确认(复用 v49 骨架)。 */
  HMI_CMD_SENSOR_ZERO_HW = 0x1A,
  HMI_CMD_SENSOR_LO15   = 0x1B,
   /* 厂家设置页(页ID 5): 该页无底部导航, 页号由页对象 load 发 printh 45 通知 */
  HMI_CMD_PAGE5_ENTER  = 0x45,
    /* [v79] 厂家页手动改标定补偿: 屏端键盘输入完成 -> 请 MCU 回读 cb.val / ck.val */
    HMI_CMD_CAL_B_SET   = 0x21,
    HMI_CMD_CAL_K_SET   = 0x22,
} hmi_cmd_t;

/* ===== 双脉冲确认窗口 ===== 
 * USART3 接收是【逐字节无过滤匹配命令码】: hmi_get_feed 只过滤 0x70/0x71 起始的
 * get 应答帧, 其余字节一律交给 hmi_on_rx_byte 当命令分发。因此屏口线上的
 * 【任何噪声字节】只要等于某个命令码就会执行 —— 加了 0x1A/0x1B 后表现为
 * 「硬件零点按钮自行在 待确认/已下发 之间无限切换」(用户没按也变)。
 * 修法: 这两个【危险且非高频】的命令要求 200~2000ms 内连续两次才认账。
 * 噪声极难在 0.2~2 秒内连续命中同一个码。
 * 屏端协议不变(仍是单字节 printh 1A/1B), 用户真实双击天然满足该窗口。 */
#define HMI_DBL_LO_MS   200u     /* 双脉冲下限: 太快(<200ms)判为噪声 */

/* ===== 危险命令总闸(临时) ===== 
 * 0x1A(硬件零点) 与 0x1B(15ppm 下限) 会向传感器下发【不可逆】指令。
 * 实测屏口存在周期性干扰(计数持续涨, dt 集中在 200ms 附近, 开机即出现),
 * 而本工程 USART3 接收是【逐字节无过滤】匹配命令码 —— 任何噪声字节等于
 * 命令码即执行。因此在干扰根因查清前, 用总闸把这两个命令整体关掉。
 *   = 1 : 启用(走双脉冲门控)
 *   = 0 : 禁用(收到即忽略并计数)  ← v62j~v63 期间用
 * 握手已验证生效, 2026-10-12 已改回 1 恢复功能。 */
#define HMI_DANGER_ENABLE  1

/* ===== 危险命令双字节握手 ===== 
 * 屏口噪声未查明(实测 0x1A 计数持续涨、开机即出现、dt≈255ms 规整),
 * 而 USART3 接收是逐字节无过滤匹配 —— 裸命令码等于噪声字节即执行。
 * 协议层加前缀: 屏端先发 0xD5, 固件收到 0xD5 后的下一个字节才当命令。
 * 噪声无法组成 D5 NN 组合, 误触发概率降至约 1/65536。
 * 需握手的命令: 01清历史 07跳初始化 15零点补偿 16量程 17恢复出厂 1A硬件零点 1B下限 */
#define HMI_GUARD_PREFIX   0xD5u
#define HMI_GUARD_PREFIX2  0x5Au

/* ===== 屏口收包诊断开关(定位噪声时开, 交付时关) ===== 
 * 开: main.c 每秒把 0x1A 计数/字节分类推到厂家页 crs_f 行(会占用该行)。
 * 关: 整段编译掉, crs_f 恢复显示标定结果。
 * 必须定义在【协议头】而非 main.c —— hmi_callback.c 也调用 hmi_diag_note,
   只在 main.c 定义会导致关闭诊断后链接失败(undefined symbol)。 */
#define HMI_DIAG  1
#define HMI_DBL_HI_MS  2000u     /* 双脉冲上限: 太慢(>2s)视为两次独立噪声 */

/* 诊断: 统计收到的总字节数与 0x1A 次数, 由 main.c 的 hmi_diag_any/note 写入 */
#define HMI_DBG_ANY_MAX  99999u

/* ===================================================================== 
 * 2. MCU -> 屏幕 对象名 (短名 = 工程内真实对象名)
 * ===================================================================== */
#define OBJ_CONC        "cc"      /* 浓度大字 vvs=2 -> val=42 显示 0.42 */
/* 顶栏报警色条"基名": 拼 dvr / dvr_s1 / dvr_s2 / dvr_i (见 main.c hmi_update_status_chips) 
 * ⚠️ dvr 是「文本控件 + txt=" "(空格) + h=2」, 可见色靠 **bco(背景色)** 填充 —— 必须用 tjc_set_bco;
 *    推 pco(文字前景色) 对空格无效(v42 前的 bug, 真机确认"颜色不变")。 */
#define OBJ_STRIP       "dvr"
#define OBJ_CONC_MAX    "cma"     /* 浓度最大值 txt */
#define OBJ_CONC_MIN    "cmn"     /* 浓度最小值 txt */
#define OBJ_THR_HI_VAL  "h"       /* 高报值 vvs=0 整数; 可由屏幕键盘输入 */
#define SCREEN_VAR_THR  "thr"     /* 屏端阈值副本(Program.s 全局 int); 设置页 load/tm0 用它刷新 h.val */
/* ---- 顶栏状态副本: 固件只写变量, 屏端各页 load 事件再刷控件 ---- 
 * 起因: 切页瞬间屏端正在重建整页对象, 固件直写控件的指令被排队到建完之后才执行
 *   => 肉眼可见「先默认、后真实」。变量赋值不依赖控件是否已建好, 故竞态从根上消失。
 * 屏端 Program.s 必须已声明这 4 个 int(用户在编辑器里加, 见 docs/方案B 操作清单)。 */
#define SCREEN_VAR_PROBE "vp0"    /* 探头 1=已连接 0=未连接 -> 屏端 if 刷 pc0d*.pic / pc0*.txt */
#define SCREEN_VAR_PUMP  "vp1"    /* 泵 1=已启动 0=未启动 -> 屏端 if 刷 pc1d*.pic / pc1*.txt */
#define SCREEN_VAR_BPIC  "vp2"    /* 电量圆点图片ID(5绿/3橙/6红) -> 屏端直接 pc2d*.pic=vp2 */
#define SCREEN_VAR_STRIP "vp3"    /* 顶栏色条背景色(12777/62689/59944) -> 屏端直接 dvr*.bco=vp3 */
#define SCREEN_VAR_BPCT  "vp4"    /* 电量百分比 0~100 —— 电量【文字】用。 
 *   ⚠️ 绝不能拿 vp2 去 cov 出文字: vp2 是【圆点图片ID】(5/3/6), cov 出来是 "3" 这种
 *      无意义数字(实测症状: 电量文字闪一下显示 3)。百分比必须单独占一个变量。 */
#define OBJ_CAL0_BTN    "c0"      /* 零点标定按钮 txt 复位="执行" */
#define OBJ_CAL1_BTN    "c1"      /* 量程标定按钮 txt 复位="执行" */
#define OBJ_CAL_FAC_BTN "cf"      /* 恢复出厂按钮 */
/* 厂家页新增的两个按钮 */
#define OBJ_ZW_BTN      "cwh"     /* 硬件零点校准按钮 */
#define OBJ_CAL_B_VAL   "cb"      /* [v79] 零点补偿 cal_b 输入框(数值控件, 屏端键盘输入, MCU 经 get 回读) */
#define OBJ_CAL_K_VAL   "ck"      /* [v79] 增益补偿 cal_k 输入框(数值控件, 屏端键盘输入, MCU 经 get 回读) */
#define OBJ_LO15_BTN    "cl15"    /* 15ppm 下限按钮 */
/* OBJ_CAL_ST / OBJ_CAL_RS 已废弃: v9 起标定区搬到厂家设置页, 
 *   设置页的 cst_s1 / crs_s1 已删除, 这两个宏是死引用。标定两行只在厂家页上报。 */
#define OBJ_CAL_ST      "cst_s1"  /* [废弃] 原设置页标定状态行 */
#define OBJ_CAL_RS      "crs_s1"  /* 设置页右栏: 标定结果/详细原因行 */
#define OBJ_CAL_ST_F    "cst_f"   /* 厂家页右栏: 标定状态行 */
#define OBJ_CAL_RS_F    "crs_f"   /* 厂家页右栏: 标定结果/详细原因行 */
#define OBJ_STAT_MAX    "mx"      /* 历史统计 txt */
#define OBJ_STAT_AVG    "av"
#define OBJ_STAT_MIN    "mn"
#define OBJ_STAT_DUR    "du"
#define OBJ_STAT_CNT    "ct"
/* 电量显示 (MCU->屏幕 入站更新): 用 tjc_set_bat(pct) / HMI_CMD_SET_BAT 刷新 */
#define OBJ_BAT_CHIP    "pc2"     /* 主页顶栏电量 chip */
#define OBJ_BAT_CHIP_P1 "pc2_s1"  /* 设置页顶栏电量 chip */
#define OBJ_BAT_CHIP_P2 "pc2_s2"  /* 历史曲线页顶栏电量 chip */

/* 主页顶栏状态 chip (胶囊底 + 状态圆点 + 文字标签) 
 * 命名规则: 下面 "pc0/pc1/pc2" 系**基名**, 实际对象名由 sfx 拼出, 共 5 份:
 *     无后缀=主页 · _s1=设置 · _s2=历史 · _i=初始化 · _f=厂家
 *   ⚠️ 改屏端对象名必须同时改拼接处的格式串 —— 按宏名去改是无效的。
 *   (2026-09-30: 删除 11 个"完整对象名快照"宏 pc0d_s1/pc0d_s2/.../pc2d_i —— 它们 0 引用,
 *    真名由 snprintf 拼接产生, 留着只会让人误以为可按名改。)
 * 实测校正: 上面的"共 4 份"曾经是错的。厂家页(后加的)
 *    pc* 系列都有 _f 后缀, **唯独色条漏了后缀**: 厂家页色条就叫 `dvr`, 不存在 `dvr_f`。
 *    而固件曾用 snprintf("dvr%s", sfx) 在厂家页拼出 dvr_f ⇒ 该页报警色条一直静默失效。
 *    已改为厂家页特例不拼后缀。
 * 这些对象名固件侧【已不再使用】—— 顶栏改为「只写 SCREEN_VAR_PROBE/PUMP/BPIC/STRIP
 *    四个屏端全局变量, 由各页 load 事件自行刷控件」(见本文件上方说明)。对象名仅供屏端脚本参考。 */
#define OBJ_PROBE_CHIP      "pc0"   /* 基名: 探头 chip 文字标签(动态文案) */
#define OBJ_PUMP_CHIP       "pc1"   /* 基名: 泵 chip 文字标签(动态文案) */
#define OBJ_DOT_PROBE       "pc0d"  /* 基名: 探头 chip 圆点 picture */
#define OBJ_DOT_PUMP        "pc1d"  /* 基名: 泵 chip 圆点 picture */
#define OBJ_DOT_BAT         "pc2d"  /* 基名: 电量 chip 圆点 picture */
/* 初始化页(页6) chip = 同一套基名 + "_i"(跨页全局唯一), 无需单独宏 */
#define OBJ_BAT_CHIP_F    "pc2_f"     /* 厂家设置页(页5) 电量 chip: 由 tjc_set_bat 按页选名 */
#define OBJ_BAT_CHIP_I     "pc2_i"   /* 初始化页电量 chip (独立命名, 由 tjc_set_bat 第 4 项无条件覆盖) */
#define OBJ_INIT_CNT   "pt0_i"    /* 初始化页(页6) 预热倒计时文本 */
#define OBJ_SELFTEST_I     "pst_i"   /* 初始化页 自检结果行(T-15): 仅失败时固件推红色文案, 全过保持空 */
#define OBJ_LOWBATT        "lb"      /* 低电提示文字(T-09)【基名】: 主页。实际按页下发 lb/lb_s1/lb_s2/lb_i 
                                           * 见 main.c low_batt_poll(): snprintf(n,size,"lb%s",sfx)
                                           * ⚠️ 屏端必须 4 页各有一个对应对象, 否则该页收不到(静默忽略) */
/* 设备信息行 (设置页右侧; 屏端原为写死的静态文本, v40 起由固件推送真实值) */
#define OBJ_FW_VER      "fw"      /* 固件版本行: 文案 "固件版本 <FW_VERSION_STR>" */
#define OBJ_SN_STR      "sn"      /* 设置页"产品编号"整行文本 ⚠️ 与 OBJ_TBL_SN_BASE 同值但用途不同 (SN 见 device_id.c) */
/* 固件版本串 FW_VERSION_STR / 产品编号 SN 的来源见 Core/Inc/product_info.h (量产配置区) */
/* 状态圆点图片 ID (对应 GUI 图片号) */
#define PIC_DOT_GREEN       5       /* 已连接/运行/高电量 */
#define PIC_DOT_GRAY        4       /* 未连接/停止 */
#define PIC_DOT_AMBER       3       /* 中电量 */
#define PIC_DOT_RED         6       /* 低电量 */
/* 电池圆点颜色阈值(%) */
#define BAT_DOT_WARN_PCT    50      /* pct>=此值 绿; >=LOW 橙; 其它红 */
#define BAT_DOT_LOW_PCT     20

/* 历史数据页 (v2: 双列 24 行) 
 * 屏端静态对象(MCU 从不更新, 故不设宏): p2L/p2R(左右面板) · ht(时间表头) · hc(浓度表头) · hsnL/hsnR(序号表头)
 *   ⚠️ 旧宏 OBJ_TBL_PANEL "p2D" 指向的对象在屏端并不存在, 已于 2026-09-30 删除。 */
#define OBJ_TBL_TIME_BASE "tt"    /* 基名: 拼 tt0..tt23 (居中 text) */
#define OBJ_TBL_PPM_BASE  "np"    /* 基名: 拼 np0..np23 (居中 text) */
#define OBJ_TBL_SN_BASE   "sn"    /* 基名: 拼 sn0..sn23 (居中 text) ⚠️ 与 OBJ_SN_STR 同值但用途不同 */
#define OBJ_TBL_PAGE    "pg"      /* 页指示 第x/y页 */

/* ===================================================================== 
 * 3. 指令拼装宏 (须自行追加帧尾 0xFF 0xFF 0xFF)
 * ===================================================================== */
#define HMI_CMD_SET_VAL(obj, v)        sprintf(cmd, "%s.val=%d",    (obj), (int)(v))
#define HMI_CMD_SET_VAR(n, v)          sprintf(cmd, "%s=%d",       (n), (int)(v))    /* 写屏端全局变量 */
#define HMI_CMD_SET_TXT(obj, t)        sprintf(cmd, "%s.txt=\"%s\"",(obj), (t))
#define HMI_CMD_SET_PCO(obj, c)        sprintf(cmd, "%s.pco=%d",    (obj), (int)(c))
#define HMI_CMD_SET_BCO(obj, c)        sprintf(cmd, "%s.bco=%d",    (obj), (int)(c))    /* 控件"背景色": 文本控件 txt 为空格时只有 bco 能整块填充(见 tjc_set_bco) */
#define HMI_CMD_SET_PIC(obj, id)       sprintf(cmd, "%s.pic=%d",    (obj), (int)(id))
#define HMI_CMD_SET_VIS(obj, v)        sprintf(cmd, "vis %s,%d",    (obj), (int)(v))
#define HMI_CMD_SET_BAT(obj, pct)      sprintf(cmd, "%s.txt=\"\xB5\xE7\xC1\xBF %d%%\"", (obj), (int)(pct)) /* pct:0~100 */
#define HMI_CMD_PAGE(n)                sprintf(cmd, "page %d",      (int)(n))
#define HMI_CMD_DIM(v)                 sprintf(cmd, "dim=%d",       (int)(v))
#define HMI_AUDIO_ID      3   /* 报警音 wav 编号 (6 声节奏, 1858ms); 与屏端资源表对齐 */
#define HMI_AUDIO_LOWBATT 5   /* 低电提示音 (2026-09-28 用户导入, 862ms 单声); 走通道1 避开报警音通道0 */
/* OBJ_PREWARM 已移除: 预热提示改由独立初始化页(页6)承载 
 * (2026-09-30: 删除重复宏 OBJ_HOME_PROBE/OBJ_HOME_PUMP —— 与上方 OBJ_PROBE_CHIP/OBJ_PUMP_CHIP 同值) */
#define OBJ_MUTE_BTN    "bm"      /* 主页 临时静音按钮 (printh 06); 历史页"重置峰值"按钮已改名为 prst, bm 仅主页静音按钮所属 */
#define OBJ_TEST_BTN    "ptg"     /* 主页"开始测试/停止测试"按钮 (printh 0x24); 
                                  * ⚠️ 屏端 txt_maxl = 8 字节, 恰好容纳 4 个汉字("开始测试"); 改文案须同步改屏端 maxl */
#define HMI_CMD_ALARM_ON()     sprintf(cmd, "play 0,%d,1",    (int)(HMI_AUDIO_ID))
#define HMI_CMD_LOWBATT_PLAY()  sprintf(cmd, "play 1,%d,0", (int)(HMI_AUDIO_LOWBATT))  /* 通道1 单次 */
#define HMI_CMD_ALARM_OFF()    sprintf(cmd, "audio0=%d",      (int)(0))
#define HMI_CMD_GET(obj,prop)          sprintf(cmd, "get %s.%s",    (obj), (prop))

/* 颜色 (RGB565 十进制) */
#define C_STRIP_GREEN   9771
#define C_STRIP_ORANGE  62689
#define C_STRIP_RED     59944
/* "正常态"配色 —— 保持屏端编辑器原色(不再用绿色表示正常): 
 *   C_STRIP_IDLE = 屏工程 4 页 dvr 的 bco 初值(≈深灰蓝); 用于顶栏色带
 *   C_CONC_IDLE  = 屏工程主页 cc 的 pco 初值(≈浅灰白); 用于浓度大字
 * ⚠️ 这两个数值取自屏工程编辑器的控件初值。若在编辑器里改了 dvr 的 bco / cc 的 pco，
 *    必须同步修改这里，否则"报警解除回落正常"时会跳成旧颜色。 */
#define C_STRIP_IDLE    12777
#define C_CONC_IDLE     57149

#endif  /* C4F7N_HMI_PROTOCOL_H */