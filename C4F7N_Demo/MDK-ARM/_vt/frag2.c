#define DEVTEST_OFF 1   /* [v62e] 已关闭: 该入口上电 3 秒后会自动下发 15ppm 两条指令,
 *                                   会污染验证且每次上电重发。改回 0 可复现自动测试。 */

#if !DEVTEST_OFF
static volatile uint8_t s_devtest = 0;   /* 0=未开始 1=等首帧 2=已发指令1 3=已发指令2 4=完成 */
static uint32_t s_devtest_t0 = 0;
static void devtest_ppm(const char *tag)
{
int main(void){return 0;}
