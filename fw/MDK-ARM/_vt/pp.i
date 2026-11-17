# 1 "../Core/Src/main.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 404 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "../Core/Src/main.c" 2
# 10 "../Core/Src/main.c"
# 1 "../Core/Inc\\main.h" 1
# 30 "../Core/Inc\\main.h"
# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal.h" 1
# 29 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal.h"
# 1 "../Core/Inc\\stm32f1xx_hal_conf.h" 1
# 238 "../Core/Inc\\stm32f1xx_hal_conf.h"
# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_rcc.h" 1
# 27 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_rcc.h"
# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_def.h" 1
# 29 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_def.h"
# 1 "../Drivers/CMSIS/Device/ST/STM32F1xx/Include\\stm32f1xx.h" 1
# 132 "../Drivers/CMSIS/Device/ST/STM32F1xx/Include\\stm32f1xx.h"
# 1 "../Drivers/CMSIS/Device/ST/STM32F1xx/Include\\stm32f103xe.h" 1
# 68 "../Drivers/CMSIS/Device/ST/STM32F1xx/Include\\stm32f103xe.h"
typedef enum
{

  NonMaskableInt_IRQn = -14,
  HardFault_IRQn = -13,
  MemoryManagement_IRQn = -12,
  BusFault_IRQn = -11,
  UsageFault_IRQn = -10,
  SVCall_IRQn = -5,
  DebugMonitor_IRQn = -4,
  PendSV_IRQn = -2,
  SysTick_IRQn = -1,


  WWDG_IRQn = 0,
  PVD_IRQn = 1,
  TAMPER_IRQn = 2,
  RTC_IRQn = 3,
  FLASH_IRQn = 4,
  RCC_IRQn = 5,
  EXTI0_IRQn = 6,
  EXTI1_IRQn = 7,
  EXTI2_IRQn = 8,
  EXTI3_IRQn = 9,
  EXTI4_IRQn = 10,
  DMA1_Channel1_IRQn = 11,
  DMA1_Channel2_IRQn = 12,
  DMA1_Channel3_IRQn = 13,
  DMA1_Channel4_IRQn = 14,
  DMA1_Channel5_IRQn = 15,
  DMA1_Channel6_IRQn = 16,
  DMA1_Channel7_IRQn = 17,
  ADC1_2_IRQn = 18,
  USB_HP_CAN1_TX_IRQn = 19,
  USB_LP_CAN1_RX0_IRQn = 20,
  CAN1_RX1_IRQn = 21,
  CAN1_SCE_IRQn = 22,
  EXTI9_5_IRQn = 23,
  TIM1_BRK_IRQn = 24,
  TIM1_UP_IRQn = 25,
  TIM1_TRG_COM_IRQn = 26,
  TIM1_CC_IRQn = 27,
  TIM2_IRQn = 28,
  TIM3_IRQn = 29,
  TIM4_IRQn = 30,
  I2C1_EV_IRQn = 31,
  I2C1_ER_IRQn = 32,
  I2C2_EV_IRQn = 33,
  I2C2_ER_IRQn = 34,
  SPI1_IRQn = 35,
  SPI2_IRQn = 36,
  USART1_IRQn = 37,
  USART2_IRQn = 38,
  USART3_IRQn = 39,
  EXTI15_10_IRQn = 40,
  RTC_Alarm_IRQn = 41,
  USBWakeUp_IRQn = 42,
  TIM8_BRK_IRQn = 43,
  TIM8_UP_IRQn = 44,
  TIM8_TRG_COM_IRQn = 45,
  TIM8_CC_IRQn = 46,
  ADC3_IRQn = 47,
  FSMC_IRQn = 48,
  SDIO_IRQn = 49,
  TIM5_IRQn = 50,
  SPI3_IRQn = 51,
  UART4_IRQn = 52,
  UART5_IRQn = 53,
  TIM6_IRQn = 54,
  TIM7_IRQn = 55,
  DMA2_Channel1_IRQn = 56,
  DMA2_Channel2_IRQn = 57,
  DMA2_Channel3_IRQn = 58,
  DMA2_Channel4_5_IRQn = 59,
} IRQn_Type;





# 1 "../Drivers/CMSIS/Include\\core_cm3.h" 1
# 29 "../Drivers/CMSIS/Include\\core_cm3.h" 3





# 1 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdint.h" 1 3
# 56 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdint.h" 3
typedef signed char int8_t;
typedef signed short int int16_t;
typedef signed int int32_t;
typedef signed long long int int64_t;


typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long int uint64_t;





typedef signed char int_least8_t;
typedef signed short int int_least16_t;
typedef signed int int_least32_t;
typedef signed long long int int_least64_t;


typedef unsigned char uint_least8_t;
typedef unsigned short int uint_least16_t;
typedef unsigned int uint_least32_t;
typedef unsigned long long int uint_least64_t;




typedef signed int int_fast8_t;
typedef signed int int_fast16_t;
typedef signed int int_fast32_t;
typedef signed long long int int_fast64_t;


typedef unsigned int uint_fast8_t;
typedef unsigned int uint_fast16_t;
typedef unsigned int uint_fast32_t;
typedef unsigned long long int uint_fast64_t;






typedef signed int intptr_t;
typedef unsigned int uintptr_t;



typedef signed long long intmax_t;
typedef unsigned long long uintmax_t;
# 35 "../Drivers/CMSIS/Include\\core_cm3.h" 2 3
# 63 "../Drivers/CMSIS/Include\\core_cm3.h" 3
# 1 "../Drivers/CMSIS/Include\\cmsis_version.h" 1 3
# 29 "../Drivers/CMSIS/Include\\cmsis_version.h" 3
# 64 "../Drivers/CMSIS/Include\\core_cm3.h" 2 3
# 115 "../Drivers/CMSIS/Include\\core_cm3.h" 3
# 1 "../Drivers/CMSIS/Include\\cmsis_compiler.h" 1 3
# 41 "../Drivers/CMSIS/Include\\cmsis_compiler.h" 3
# 1 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 1 3
# 31 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3


# 1 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\arm_compat.h" 1 3






# 1 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\arm_acle.h" 1 3
# 45 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\arm_acle.h" 3
static __inline__ void __attribute__((__always_inline__, __nodebug__)) __wfi(void) {
  __builtin_arm_wfi();
}



static __inline__ void __attribute__((__always_inline__, __nodebug__)) __wfe(void) {
  __builtin_arm_wfe();
}



static __inline__ void __attribute__((__always_inline__, __nodebug__)) __sev(void) {
  __builtin_arm_sev();
}



static __inline__ void __attribute__((__always_inline__, __nodebug__)) __sevl(void) {
  __builtin_arm_sevl();
}



static __inline__ void __attribute__((__always_inline__, __nodebug__)) __yield(void) {
  __builtin_arm_yield();
}
# 87 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\arm_acle.h" 3
static __inline__ uint32_t __attribute__((__always_inline__, __nodebug__))
__swp(uint32_t __x, volatile uint32_t *__p) {
  uint32_t v;
  do
    v = __builtin_arm_ldrex(__p);
  while (__builtin_arm_strex(__x, __p));
  return v;
}
# 121 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\arm_acle.h" 3
static __inline__ void __attribute__((__always_inline__, __nodebug__)) __nop(void) {
  __builtin_arm_nop();
}





static __inline__ uint32_t __attribute__((__always_inline__, __nodebug__))
__ror(uint32_t __x, uint32_t __y) {
  __y %= 32;
  if (__y == 0)
    return __x;
  return (__x >> __y) | (__x << (32 - __y));
}

static __inline__ uint64_t __attribute__((__always_inline__, __nodebug__))
__rorll(uint64_t __x, uint32_t __y) {
  __y %= 64;
  if (__y == 0)
    return __x;
  return (__x >> __y) | (__x << (64 - __y));
}

static __inline__ unsigned long __attribute__((__always_inline__, __nodebug__))
__rorl(unsigned long __x, uint32_t __y) {

  return __ror(__x, __y);



}



static __inline__ unsigned int __attribute__((__always_inline__, __nodebug__))
__clz(uint32_t __t) {
  return __builtin_arm_clz(__t);
}

static __inline__ unsigned int __attribute__((__always_inline__, __nodebug__))
__clzl(unsigned long __t) {

  return __builtin_arm_clz(__t);



}

static __inline__ unsigned int __attribute__((__always_inline__, __nodebug__))
__clzll(uint64_t __t) {
  return __builtin_arm_clz64(__t);
}


static __inline__ unsigned int __attribute__((__always_inline__, __nodebug__))
__cls(uint32_t __t) {
  return __builtin_arm_cls(__t);
}

static __inline__ unsigned int __attribute__((__always_inline__, __nodebug__))
__clsl(unsigned long __t) {

  return __builtin_arm_cls(__t);



}

static __inline__ unsigned int __attribute__((__always_inline__, __nodebug__))
__clsll(uint64_t __t) {
  return __builtin_arm_cls64(__t);
}


static __inline__ uint32_t __attribute__((__always_inline__, __nodebug__))
__rev(uint32_t __t) {
  return __builtin_bswap32(__t);
}

static __inline__ unsigned long __attribute__((__always_inline__, __nodebug__))
__revl(unsigned long __t) {

  return __builtin_bswap32(__t);



}

static __inline__ uint64_t __attribute__((__always_inline__, __nodebug__))
__revll(uint64_t __t) {
  return __builtin_bswap64(__t);
}


static __inline__ uint32_t __attribute__((__always_inline__, __nodebug__))
__rev16(uint32_t __t) {
  return __ror(__rev(__t), 16);
}

static __inline__ uint64_t __attribute__((__always_inline__, __nodebug__))
__rev16ll(uint64_t __t) {
  return (((uint64_t)__rev16(__t >> 32)) << 32) | (uint64_t)__rev16((uint32_t)__t);
}

static __inline__ unsigned long __attribute__((__always_inline__, __nodebug__))
__rev16l(unsigned long __t) {

    return __rev16(__t);



}


static __inline__ int16_t __attribute__((__always_inline__, __nodebug__))
__revsh(int16_t __t) {
  return (int16_t)__builtin_bswap16((uint16_t)__t);
}


static __inline__ uint32_t __attribute__((__always_inline__, __nodebug__))
__rbit(uint32_t __t) {
  return __builtin_arm_rbit(__t);
}

static __inline__ uint64_t __attribute__((__always_inline__, __nodebug__))
__rbitll(uint64_t __t) {

  return (((uint64_t)__builtin_arm_rbit(__t)) << 32) |
         __builtin_arm_rbit(__t >> 32);



}

static __inline__ unsigned long __attribute__((__always_inline__, __nodebug__))
__rbitl(unsigned long __t) {

  return __rbit(__t);



}
# 8 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\arm_compat.h" 2 3
# 40 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\arm_compat.h" 3
static __inline__ unsigned int __attribute__((__always_inline__, __nodebug__))
__disable_fiq(void) {
  unsigned int cpsr;

  __asm__ __volatile__("mrs %[cpsr], faultmask\n"
                       "cpsid f\n"
                       : [cpsr] "=r"(cpsr));
  return cpsr & 0x1;
# 62 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\arm_compat.h" 3
}


static __inline__ unsigned int __attribute__((__always_inline__, __nodebug__))
__disable_irq(void) {
  unsigned int cpsr;


  __asm__ __volatile__("mrs %[cpsr], primask\n"
                       "cpsid i\n"
                       : [cpsr] "=r"(cpsr));
  return cpsr & 0x1;
# 89 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\arm_compat.h" 3
}







static __inline__ void __attribute__((__always_inline__, __nodebug__))
__enable_fiq(void) {

  __asm__ __volatile__("cpsie f");
# 109 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\arm_compat.h" 3
}


static __inline__ void __attribute__((__always_inline__, __nodebug__))
__enable_irq(void) {

  __asm__ __volatile__("cpsie i");
# 124 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\arm_compat.h" 3
}

static __inline__ void __attribute__((__always_inline__, __nodebug__)) __force_stores(void) {
    __asm__ __volatile__ ("" : : : "memory", "cc");
}

static void __attribute__((__always_inline__, __nodebug__)) __memory_changed(void) {
    __asm__ __volatile__ ("" : : : "memory", "cc");
}

static void __attribute__((__always_inline__, __nodebug__)) __schedule_barrier(void) {
    __asm__ __volatile__ ("" : : : "memory", "cc");
}

static __inline__ int __attribute__((__always_inline__, __nodebug__))
__semihost(int val, const void *ptr) {
  register int v __asm__("r0") = val;
  register const void *p __asm__("r1") = ptr;
  __asm__ __volatile__(


      "bkpt 0xab"
# 160 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\arm_compat.h" 3
      : "+r"(v), "+r"(p)
      :
      : "memory", "cc");
  return v;
}
# 181 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\arm_compat.h" 3
static __inline__ unsigned int __attribute__((
    unavailable("intrinsic not supported for targets without floating point")))
__vfp_status(unsigned int mask, unsigned int flags);
# 34 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 2 3
# 68 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpacked"

  struct __attribute__((packed)) T_UINT32 { uint32_t v; };
#pragma clang diagnostic pop



#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpacked"

  struct __attribute__((packed, aligned(1))) T_UINT16_WRITE { uint16_t v; };
#pragma clang diagnostic pop



#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpacked"

  struct __attribute__((packed, aligned(1))) T_UINT16_READ { uint16_t v; };
#pragma clang diagnostic pop



#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpacked"

  struct __attribute__((packed, aligned(1))) T_UINT32_WRITE { uint32_t v; };
#pragma clang diagnostic pop



#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpacked"

  struct __attribute__((packed, aligned(1))) T_UINT32_READ { uint32_t v; };
#pragma clang diagnostic pop
# 142 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline uint32_t __get_CONTROL(void)
{
  uint32_t result;

  __asm volatile ("MRS %0, control" : "=r" (result) );
  return(result);
}
# 172 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline void __set_CONTROL(uint32_t control)
{
  __asm volatile ("MSR control, %0" : : "r" (control) : "memory");
}
# 196 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline uint32_t __get_IPSR(void)
{
  uint32_t result;

  __asm volatile ("MRS %0, ipsr" : "=r" (result) );
  return(result);
}







__attribute__((always_inline)) static __inline uint32_t __get_APSR(void)
{
  uint32_t result;

  __asm volatile ("MRS %0, apsr" : "=r" (result) );
  return(result);
}







__attribute__((always_inline)) static __inline uint32_t __get_xPSR(void)
{
  uint32_t result;

  __asm volatile ("MRS %0, xpsr" : "=r" (result) );
  return(result);
}







__attribute__((always_inline)) static __inline uint32_t __get_PSP(void)
{
  uint32_t result;

  __asm volatile ("MRS %0, psp" : "=r" (result) );
  return(result);
}
# 268 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline void __set_PSP(uint32_t topOfProcStack)
{
  __asm volatile ("MSR psp, %0" : : "r" (topOfProcStack) : );
}
# 292 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline uint32_t __get_MSP(void)
{
  uint32_t result;

  __asm volatile ("MRS %0, msp" : "=r" (result) );
  return(result);
}
# 322 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline void __set_MSP(uint32_t topOfMainStack)
{
  __asm volatile ("MSR msp, %0" : : "r" (topOfMainStack) : );
}
# 373 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline uint32_t __get_PRIMASK(void)
{
  uint32_t result;

  __asm volatile ("MRS %0, primask" : "=r" (result) );
  return(result);
}
# 403 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline void __set_PRIMASK(uint32_t priMask)
{
  __asm volatile ("MSR primask, %0" : : "r" (priMask) : "memory");
}
# 446 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline uint32_t __get_BASEPRI(void)
{
  uint32_t result;

  __asm volatile ("MRS %0, basepri" : "=r" (result) );
  return(result);
}
# 476 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline void __set_BASEPRI(uint32_t basePri)
{
  __asm volatile ("MSR basepri, %0" : : "r" (basePri) : "memory");
}
# 501 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline void __set_BASEPRI_MAX(uint32_t basePri)
{
  __asm volatile ("MSR basepri_max, %0" : : "r" (basePri) : "memory");
}







__attribute__((always_inline)) static __inline uint32_t __get_FAULTMASK(void)
{
  uint32_t result;

  __asm volatile ("MRS %0, faultmask" : "=r" (result) );
  return(result);
}
# 542 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline void __set_FAULTMASK(uint32_t faultMask)
{
  __asm volatile ("MSR faultmask, %0" : : "r" (faultMask) : "memory");
}
# 876 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline uint32_t __ROR(uint32_t op1, uint32_t op2)
{
  op2 %= 32U;
  if (op2 == 0U)
  {
    return op1;
  }
  return (op1 >> op2) | (op1 << (32U - op2));
}
# 1021 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline uint32_t __RRX(uint32_t value)
{
  uint32_t result;

  __asm volatile ("rrx %0, %1" : "=r" (result) : "r" (value) );
  return(result);
}
# 1036 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline uint8_t __LDRBT(volatile uint8_t *ptr)
{
  uint32_t result;

  __asm volatile ("ldrbt %0, %1" : "=r" (result) : "Q" (*ptr) );
  return ((uint8_t) result);
}
# 1051 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline uint16_t __LDRHT(volatile uint16_t *ptr)
{
  uint32_t result;

  __asm volatile ("ldrht %0, %1" : "=r" (result) : "Q" (*ptr) );
  return ((uint16_t) result);
}
# 1066 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline uint32_t __LDRT(volatile uint32_t *ptr)
{
  uint32_t result;

  __asm volatile ("ldrt %0, %1" : "=r" (result) : "Q" (*ptr) );
  return(result);
}
# 1081 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline void __STRBT(uint8_t value, volatile uint8_t *ptr)
{
  __asm volatile ("strbt %1, %0" : "=Q" (*ptr) : "r" ((uint32_t)value) );
}
# 1093 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline void __STRHT(uint16_t value, volatile uint16_t *ptr)
{
  __asm volatile ("strht %1, %0" : "=Q" (*ptr) : "r" ((uint32_t)value) );
}
# 1105 "../Drivers/CMSIS/Include\\cmsis_armclang.h" 3
__attribute__((always_inline)) static __inline void __STRT(uint32_t value, volatile uint32_t *ptr)
{
  __asm volatile ("strt %1, %0" : "=Q" (*ptr) : "r" (value) );
}
# 42 "../Drivers/CMSIS/Include\\cmsis_compiler.h" 2 3
# 116 "../Drivers/CMSIS/Include\\core_cm3.h" 2 3
# 206 "../Drivers/CMSIS/Include\\core_cm3.h" 3
typedef union
{
  struct
  {
    uint32_t _reserved0:27;
    uint32_t Q:1;
    uint32_t V:1;
    uint32_t C:1;
    uint32_t Z:1;
    uint32_t N:1;
  } b;
  uint32_t w;
} APSR_Type;
# 240 "../Drivers/CMSIS/Include\\core_cm3.h" 3
typedef union
{
  struct
  {
    uint32_t ISR:9;
    uint32_t _reserved0:23;
  } b;
  uint32_t w;
} IPSR_Type;
# 258 "../Drivers/CMSIS/Include\\core_cm3.h" 3
typedef union
{
  struct
  {
    uint32_t ISR:9;
    uint32_t _reserved0:1;
    uint32_t ICI_IT_1:6;
    uint32_t _reserved1:8;
    uint32_t T:1;
    uint32_t ICI_IT_2:2;
    uint32_t Q:1;
    uint32_t V:1;
    uint32_t C:1;
    uint32_t Z:1;
    uint32_t N:1;
  } b;
  uint32_t w;
} xPSR_Type;
# 309 "../Drivers/CMSIS/Include\\core_cm3.h" 3
typedef union
{
  struct
  {
    uint32_t nPRIV:1;
    uint32_t SPSEL:1;
    uint32_t _reserved1:30;
  } b;
  uint32_t w;
} CONTROL_Type;
# 340 "../Drivers/CMSIS/Include\\core_cm3.h" 3
typedef struct
{
  volatile uint32_t ISER[8U];
        uint32_t RESERVED0[24U];
  volatile uint32_t ICER[8U];
        uint32_t RSERVED1[24U];
  volatile uint32_t ISPR[8U];
        uint32_t RESERVED2[24U];
  volatile uint32_t ICPR[8U];
        uint32_t RESERVED3[24U];
  volatile uint32_t IABR[8U];
        uint32_t RESERVED4[56U];
  volatile uint8_t IP[240U];
        uint32_t RESERVED5[644U];
  volatile uint32_t STIR;
} NVIC_Type;
# 374 "../Drivers/CMSIS/Include\\core_cm3.h" 3
typedef struct
{
  volatile const uint32_t CPUID;
  volatile uint32_t ICSR;
  volatile uint32_t VTOR;
  volatile uint32_t AIRCR;
  volatile uint32_t SCR;
  volatile uint32_t CCR;
  volatile uint8_t SHP[12U];
  volatile uint32_t SHCSR;
  volatile uint32_t CFSR;
  volatile uint32_t HFSR;
  volatile uint32_t DFSR;
  volatile uint32_t MMFAR;
  volatile uint32_t BFAR;
  volatile uint32_t AFSR;
  volatile const uint32_t PFR[2U];
  volatile const uint32_t DFR;
  volatile const uint32_t ADR;
  volatile const uint32_t MMFR[4U];
  volatile const uint32_t ISAR[5U];
        uint32_t RESERVED0[5U];
  volatile uint32_t CPACR;
} SCB_Type;
# 655 "../Drivers/CMSIS/Include\\core_cm3.h" 3
typedef struct
{
        uint32_t RESERVED0[1U];
  volatile const uint32_t ICTR;

  volatile uint32_t ACTLR;



} SCnSCB_Type;
# 694 "../Drivers/CMSIS/Include\\core_cm3.h" 3
typedef struct
{
  volatile uint32_t CTRL;
  volatile uint32_t LOAD;
  volatile uint32_t VAL;
  volatile const uint32_t CALIB;
} SysTick_Type;
# 746 "../Drivers/CMSIS/Include\\core_cm3.h" 3
typedef struct
{
  volatile union
  {
    volatile uint8_t u8;
    volatile uint16_t u16;
    volatile uint32_t u32;
  } PORT [32U];
        uint32_t RESERVED0[864U];
  volatile uint32_t TER;
        uint32_t RESERVED1[15U];
  volatile uint32_t TPR;
        uint32_t RESERVED2[15U];
  volatile uint32_t TCR;
        uint32_t RESERVED3[29U];
  volatile uint32_t IWR;
  volatile const uint32_t IRR;
  volatile uint32_t IMCR;
        uint32_t RESERVED4[43U];
  volatile uint32_t LAR;
  volatile const uint32_t LSR;
        uint32_t RESERVED5[6U];
  volatile const uint32_t PID4;
  volatile const uint32_t PID5;
  volatile const uint32_t PID6;
  volatile const uint32_t PID7;
  volatile const uint32_t PID0;
  volatile const uint32_t PID1;
  volatile const uint32_t PID2;
  volatile const uint32_t PID3;
  volatile const uint32_t CID0;
  volatile const uint32_t CID1;
  volatile const uint32_t CID2;
  volatile const uint32_t CID3;
} ITM_Type;
# 849 "../Drivers/CMSIS/Include\\core_cm3.h" 3
typedef struct
{
  volatile uint32_t CTRL;
  volatile uint32_t CYCCNT;
  volatile uint32_t CPICNT;
  volatile uint32_t EXCCNT;
  volatile uint32_t SLEEPCNT;
  volatile uint32_t LSUCNT;
  volatile uint32_t FOLDCNT;
  volatile const uint32_t PCSR;
  volatile uint32_t COMP0;
  volatile uint32_t MASK0;
  volatile uint32_t FUNCTION0;
        uint32_t RESERVED0[1U];
  volatile uint32_t COMP1;
  volatile uint32_t MASK1;
  volatile uint32_t FUNCTION1;
        uint32_t RESERVED1[1U];
  volatile uint32_t COMP2;
  volatile uint32_t MASK2;
  volatile uint32_t FUNCTION2;
        uint32_t RESERVED2[1U];
  volatile uint32_t COMP3;
  volatile uint32_t MASK3;
  volatile uint32_t FUNCTION3;
} DWT_Type;
# 996 "../Drivers/CMSIS/Include\\core_cm3.h" 3
typedef struct
{
  volatile const uint32_t SSPSR;
  volatile uint32_t CSPSR;
        uint32_t RESERVED0[2U];
  volatile uint32_t ACPR;
        uint32_t RESERVED1[55U];
  volatile uint32_t SPPR;
        uint32_t RESERVED2[131U];
  volatile const uint32_t FFSR;
  volatile uint32_t FFCR;
  volatile const uint32_t FSCR;
        uint32_t RESERVED3[759U];
  volatile const uint32_t TRIGGER;
  volatile const uint32_t FIFO0;
  volatile const uint32_t ITATBCTR2;
        uint32_t RESERVED4[1U];
  volatile const uint32_t ITATBCTR0;
  volatile const uint32_t FIFO1;
  volatile uint32_t ITCTRL;
        uint32_t RESERVED5[39U];
  volatile uint32_t CLAIMSET;
  volatile uint32_t CLAIMCLR;
        uint32_t RESERVED7[8U];
  volatile const uint32_t DEVID;
  volatile const uint32_t DEVTYPE;
} TPI_Type;
# 1254 "../Drivers/CMSIS/Include\\core_cm3.h" 3
typedef struct
{
  volatile uint32_t DHCSR;
  volatile uint32_t DCRSR;
  volatile uint32_t DCRDR;
  volatile uint32_t DEMCR;
} CoreDebug_Type;
# 1480 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline void __NVIC_SetPriorityGrouping(uint32_t PriorityGroup)
{
  uint32_t reg_value;
  uint32_t PriorityGroupTmp = (PriorityGroup & (uint32_t)0x07UL);

  reg_value = ((SCB_Type *) ((0xE000E000UL) + 0x0D00UL) )->AIRCR;
  reg_value &= ~((uint32_t)((0xFFFFUL << 16U) | (7UL << 8U)));
  reg_value = (reg_value |
                ((uint32_t)0x5FAUL << 16U) |
                (PriorityGroupTmp << 8U) );
  ((SCB_Type *) ((0xE000E000UL) + 0x0D00UL) )->AIRCR = reg_value;
}







static __inline uint32_t __NVIC_GetPriorityGrouping(void)
{
  return ((uint32_t)((((SCB_Type *) ((0xE000E000UL) + 0x0D00UL) )->AIRCR & (7UL << 8U)) >> 8U));
}
# 1511 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline void __NVIC_EnableIRQ(IRQn_Type IRQn)
{
  if ((int32_t)(IRQn) >= 0)
  {
    ((NVIC_Type *) ((0xE000E000UL) + 0x0100UL) )->ISER[(((uint32_t)IRQn) >> 5UL)] = (uint32_t)(1UL << (((uint32_t)IRQn) & 0x1FUL));
  }
}
# 1528 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline uint32_t __NVIC_GetEnableIRQ(IRQn_Type IRQn)
{
  if ((int32_t)(IRQn) >= 0)
  {
    return((uint32_t)(((((NVIC_Type *) ((0xE000E000UL) + 0x0100UL) )->ISER[(((uint32_t)IRQn) >> 5UL)] & (1UL << (((uint32_t)IRQn) & 0x1FUL))) != 0UL) ? 1UL : 0UL));
  }
  else
  {
    return(0U);
  }
}
# 1547 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline void __NVIC_DisableIRQ(IRQn_Type IRQn)
{
  if ((int32_t)(IRQn) >= 0)
  {
    ((NVIC_Type *) ((0xE000E000UL) + 0x0100UL) )->ICER[(((uint32_t)IRQn) >> 5UL)] = (uint32_t)(1UL << (((uint32_t)IRQn) & 0x1FUL));
    __builtin_arm_dsb(0xF);;
    __builtin_arm_isb(0xF);;
  }
}
# 1566 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline uint32_t __NVIC_GetPendingIRQ(IRQn_Type IRQn)
{
  if ((int32_t)(IRQn) >= 0)
  {
    return((uint32_t)(((((NVIC_Type *) ((0xE000E000UL) + 0x0100UL) )->ISPR[(((uint32_t)IRQn) >> 5UL)] & (1UL << (((uint32_t)IRQn) & 0x1FUL))) != 0UL) ? 1UL : 0UL));
  }
  else
  {
    return(0U);
  }
}
# 1585 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline void __NVIC_SetPendingIRQ(IRQn_Type IRQn)
{
  if ((int32_t)(IRQn) >= 0)
  {
    ((NVIC_Type *) ((0xE000E000UL) + 0x0100UL) )->ISPR[(((uint32_t)IRQn) >> 5UL)] = (uint32_t)(1UL << (((uint32_t)IRQn) & 0x1FUL));
  }
}
# 1600 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline void __NVIC_ClearPendingIRQ(IRQn_Type IRQn)
{
  if ((int32_t)(IRQn) >= 0)
  {
    ((NVIC_Type *) ((0xE000E000UL) + 0x0100UL) )->ICPR[(((uint32_t)IRQn) >> 5UL)] = (uint32_t)(1UL << (((uint32_t)IRQn) & 0x1FUL));
  }
}
# 1617 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline uint32_t __NVIC_GetActive(IRQn_Type IRQn)
{
  if ((int32_t)(IRQn) >= 0)
  {
    return((uint32_t)(((((NVIC_Type *) ((0xE000E000UL) + 0x0100UL) )->IABR[(((uint32_t)IRQn) >> 5UL)] & (1UL << (((uint32_t)IRQn) & 0x1FUL))) != 0UL) ? 1UL : 0UL));
  }
  else
  {
    return(0U);
  }
}
# 1639 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline void __NVIC_SetPriority(IRQn_Type IRQn, uint32_t priority)
{
  if ((int32_t)(IRQn) >= 0)
  {
    ((NVIC_Type *) ((0xE000E000UL) + 0x0100UL) )->IP[((uint32_t)IRQn)] = (uint8_t)((priority << (8U - 4U)) & (uint32_t)0xFFUL);
  }
  else
  {
    ((SCB_Type *) ((0xE000E000UL) + 0x0D00UL) )->SHP[(((uint32_t)IRQn) & 0xFUL)-4UL] = (uint8_t)((priority << (8U - 4U)) & (uint32_t)0xFFUL);
  }
}
# 1661 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline uint32_t __NVIC_GetPriority(IRQn_Type IRQn)
{

  if ((int32_t)(IRQn) >= 0)
  {
    return(((uint32_t)((NVIC_Type *) ((0xE000E000UL) + 0x0100UL) )->IP[((uint32_t)IRQn)] >> (8U - 4U)));
  }
  else
  {
    return(((uint32_t)((SCB_Type *) ((0xE000E000UL) + 0x0D00UL) )->SHP[(((uint32_t)IRQn) & 0xFUL)-4UL] >> (8U - 4U)));
  }
}
# 1686 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline uint32_t NVIC_EncodePriority (uint32_t PriorityGroup, uint32_t PreemptPriority, uint32_t SubPriority)
{
  uint32_t PriorityGroupTmp = (PriorityGroup & (uint32_t)0x07UL);
  uint32_t PreemptPriorityBits;
  uint32_t SubPriorityBits;

  PreemptPriorityBits = ((7UL - PriorityGroupTmp) > (uint32_t)(4U)) ? (uint32_t)(4U) : (uint32_t)(7UL - PriorityGroupTmp);
  SubPriorityBits = ((PriorityGroupTmp + (uint32_t)(4U)) < (uint32_t)7UL) ? (uint32_t)0UL : (uint32_t)((PriorityGroupTmp - 7UL) + (uint32_t)(4U));

  return (
           ((PreemptPriority & (uint32_t)((1UL << (PreemptPriorityBits)) - 1UL)) << SubPriorityBits) |
           ((SubPriority & (uint32_t)((1UL << (SubPriorityBits )) - 1UL)))
         );
}
# 1713 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline void NVIC_DecodePriority (uint32_t Priority, uint32_t PriorityGroup, uint32_t* const pPreemptPriority, uint32_t* const pSubPriority)
{
  uint32_t PriorityGroupTmp = (PriorityGroup & (uint32_t)0x07UL);
  uint32_t PreemptPriorityBits;
  uint32_t SubPriorityBits;

  PreemptPriorityBits = ((7UL - PriorityGroupTmp) > (uint32_t)(4U)) ? (uint32_t)(4U) : (uint32_t)(7UL - PriorityGroupTmp);
  SubPriorityBits = ((PriorityGroupTmp + (uint32_t)(4U)) < (uint32_t)7UL) ? (uint32_t)0UL : (uint32_t)((PriorityGroupTmp - 7UL) + (uint32_t)(4U));

  *pPreemptPriority = (Priority >> SubPriorityBits) & (uint32_t)((1UL << (PreemptPriorityBits)) - 1UL);
  *pSubPriority = (Priority ) & (uint32_t)((1UL << (SubPriorityBits )) - 1UL);
}
# 1736 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline void __NVIC_SetVector(IRQn_Type IRQn, uint32_t vector)
{
  uint32_t *vectors = (uint32_t *)((SCB_Type *) ((0xE000E000UL) + 0x0D00UL) )->VTOR;
  vectors[(int32_t)IRQn + 16] = vector;
}
# 1751 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline uint32_t __NVIC_GetVector(IRQn_Type IRQn)
{
  uint32_t *vectors = (uint32_t *)((SCB_Type *) ((0xE000E000UL) + 0x0D00UL) )->VTOR;
  return vectors[(int32_t)IRQn + 16];
}






__attribute__((__noreturn__)) static __inline void __NVIC_SystemReset(void)
{
  __builtin_arm_dsb(0xF);;

  ((SCB_Type *) ((0xE000E000UL) + 0x0D00UL) )->AIRCR = (uint32_t)((0x5FAUL << 16U) |
                           (((SCB_Type *) ((0xE000E000UL) + 0x0D00UL) )->AIRCR & (7UL << 8U)) |
                            (1UL << 2U) );
  __builtin_arm_dsb(0xF);;

  for(;;)
  {
    __builtin_arm_nop();
  }
}
# 1803 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline uint32_t SCB_GetFPUType(void)
{
    return 0U;
}
# 1834 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline uint32_t SysTick_Config(uint32_t ticks)
{
  if ((ticks - 1UL) > (0xFFFFFFUL ))
  {
    return (1UL);
  }

  ((SysTick_Type *) ((0xE000E000UL) + 0x0010UL) )->LOAD = (uint32_t)(ticks - 1UL);
  __NVIC_SetPriority (SysTick_IRQn, (1UL << 4U) - 1UL);
  ((SysTick_Type *) ((0xE000E000UL) + 0x0010UL) )->VAL = 0UL;
  ((SysTick_Type *) ((0xE000E000UL) + 0x0010UL) )->CTRL = (1UL << 2U) |
                   (1UL << 1U) |
                   (1UL );
  return (0UL);
}
# 1864 "../Drivers/CMSIS/Include\\core_cm3.h" 3
extern volatile int32_t ITM_RxBuffer;
# 1876 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline uint32_t ITM_SendChar (uint32_t ch)
{
  if (((((ITM_Type *) (0xE0000000UL) )->TCR & (1UL )) != 0UL) &&
      ((((ITM_Type *) (0xE0000000UL) )->TER & 1UL ) != 0UL) )
  {
    while (((ITM_Type *) (0xE0000000UL) )->PORT[0U].u32 == 0UL)
    {
      __builtin_arm_nop();
    }
    ((ITM_Type *) (0xE0000000UL) )->PORT[0U].u8 = (uint8_t)ch;
  }
  return (ch);
}
# 1897 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline int32_t ITM_ReceiveChar (void)
{
  int32_t ch = -1;

  if (ITM_RxBuffer != ((int32_t)0x5AA55AA5U))
  {
    ch = ITM_RxBuffer;
    ITM_RxBuffer = ((int32_t)0x5AA55AA5U);
  }

  return (ch);
}
# 1917 "../Drivers/CMSIS/Include\\core_cm3.h" 3
static __inline int32_t ITM_CheckChar (void)
{

  if (ITM_RxBuffer == ((int32_t)0x5AA55AA5U))
  {
    return (0);
  }
  else
  {
    return (1);
  }
}
# 149 "../Drivers/CMSIS/Device/ST/STM32F1xx/Include\\stm32f103xe.h" 2
# 1 "../Drivers/CMSIS/Device/ST/STM32F1xx/Include\\system_stm32f1xx.h" 1
# 50 "../Drivers/CMSIS/Device/ST/STM32F1xx/Include\\system_stm32f1xx.h"
extern uint32_t SystemCoreClock;
extern const uint8_t AHBPrescTable[16U];
extern const uint8_t APBPrescTable[8U];
# 78 "../Drivers/CMSIS/Device/ST/STM32F1xx/Include\\system_stm32f1xx.h"
extern void SystemInit(void);
extern void SystemCoreClockUpdate(void);
# 150 "../Drivers/CMSIS/Device/ST/STM32F1xx/Include\\stm32f103xe.h" 2
# 160 "../Drivers/CMSIS/Device/ST/STM32F1xx/Include\\stm32f103xe.h"
typedef struct
{
  volatile uint32_t SR;
  volatile uint32_t CR1;
  volatile uint32_t CR2;
  volatile uint32_t SMPR1;
  volatile uint32_t SMPR2;
  volatile uint32_t JOFR1;
  volatile uint32_t JOFR2;
  volatile uint32_t JOFR3;
  volatile uint32_t JOFR4;
  volatile uint32_t HTR;
  volatile uint32_t LTR;
  volatile uint32_t SQR1;
  volatile uint32_t SQR2;
  volatile uint32_t SQR3;
  volatile uint32_t JSQR;
  volatile uint32_t JDR1;
  volatile uint32_t JDR2;
  volatile uint32_t JDR3;
  volatile uint32_t JDR4;
  volatile uint32_t DR;
} ADC_TypeDef;

typedef struct
{
  volatile uint32_t SR;
  volatile uint32_t CR1;
  volatile uint32_t CR2;
  uint32_t RESERVED[16];
  volatile uint32_t DR;
} ADC_Common_TypeDef;





typedef struct
{
  uint32_t RESERVED0;
  volatile uint32_t DR1;
  volatile uint32_t DR2;
  volatile uint32_t DR3;
  volatile uint32_t DR4;
  volatile uint32_t DR5;
  volatile uint32_t DR6;
  volatile uint32_t DR7;
  volatile uint32_t DR8;
  volatile uint32_t DR9;
  volatile uint32_t DR10;
  volatile uint32_t RTCCR;
  volatile uint32_t CR;
  volatile uint32_t CSR;
  uint32_t RESERVED13[2];
  volatile uint32_t DR11;
  volatile uint32_t DR12;
  volatile uint32_t DR13;
  volatile uint32_t DR14;
  volatile uint32_t DR15;
  volatile uint32_t DR16;
  volatile uint32_t DR17;
  volatile uint32_t DR18;
  volatile uint32_t DR19;
  volatile uint32_t DR20;
  volatile uint32_t DR21;
  volatile uint32_t DR22;
  volatile uint32_t DR23;
  volatile uint32_t DR24;
  volatile uint32_t DR25;
  volatile uint32_t DR26;
  volatile uint32_t DR27;
  volatile uint32_t DR28;
  volatile uint32_t DR29;
  volatile uint32_t DR30;
  volatile uint32_t DR31;
  volatile uint32_t DR32;
  volatile uint32_t DR33;
  volatile uint32_t DR34;
  volatile uint32_t DR35;
  volatile uint32_t DR36;
  volatile uint32_t DR37;
  volatile uint32_t DR38;
  volatile uint32_t DR39;
  volatile uint32_t DR40;
  volatile uint32_t DR41;
  volatile uint32_t DR42;
} BKP_TypeDef;





typedef struct
{
  volatile uint32_t TIR;
  volatile uint32_t TDTR;
  volatile uint32_t TDLR;
  volatile uint32_t TDHR;
} CAN_TxMailBox_TypeDef;





typedef struct
{
  volatile uint32_t RIR;
  volatile uint32_t RDTR;
  volatile uint32_t RDLR;
  volatile uint32_t RDHR;
} CAN_FIFOMailBox_TypeDef;





typedef struct
{
  volatile uint32_t FR1;
  volatile uint32_t FR2;
} CAN_FilterRegister_TypeDef;





typedef struct
{
  volatile uint32_t MCR;
  volatile uint32_t MSR;
  volatile uint32_t TSR;
  volatile uint32_t RF0R;
  volatile uint32_t RF1R;
  volatile uint32_t IER;
  volatile uint32_t ESR;
  volatile uint32_t BTR;
  uint32_t RESERVED0[88];
  CAN_TxMailBox_TypeDef sTxMailBox[3];
  CAN_FIFOMailBox_TypeDef sFIFOMailBox[2];
  uint32_t RESERVED1[12];
  volatile uint32_t FMR;
  volatile uint32_t FM1R;
  uint32_t RESERVED2;
  volatile uint32_t FS1R;
  uint32_t RESERVED3;
  volatile uint32_t FFA1R;
  uint32_t RESERVED4;
  volatile uint32_t FA1R;
  uint32_t RESERVED5[8];
  CAN_FilterRegister_TypeDef sFilterRegister[14];
} CAN_TypeDef;





typedef struct
{
  volatile uint32_t DR;
  volatile uint8_t IDR;
  uint8_t RESERVED0;
  uint16_t RESERVED1;
  volatile uint32_t CR;
} CRC_TypeDef;





typedef struct
{
  volatile uint32_t CR;
  volatile uint32_t SWTRIGR;
  volatile uint32_t DHR12R1;
  volatile uint32_t DHR12L1;
  volatile uint32_t DHR8R1;
  volatile uint32_t DHR12R2;
  volatile uint32_t DHR12L2;
  volatile uint32_t DHR8R2;
  volatile uint32_t DHR12RD;
  volatile uint32_t DHR12LD;
  volatile uint32_t DHR8RD;
  volatile uint32_t DOR1;
  volatile uint32_t DOR2;
} DAC_TypeDef;





typedef struct
{
  volatile uint32_t IDCODE;
  volatile uint32_t CR;
}DBGMCU_TypeDef;





typedef struct
{
  volatile uint32_t CCR;
  volatile uint32_t CNDTR;
  volatile uint32_t CPAR;
  volatile uint32_t CMAR;
} DMA_Channel_TypeDef;

typedef struct
{
  volatile uint32_t ISR;
  volatile uint32_t IFCR;
} DMA_TypeDef;







typedef struct
{
  volatile uint32_t IMR;
  volatile uint32_t EMR;
  volatile uint32_t RTSR;
  volatile uint32_t FTSR;
  volatile uint32_t SWIER;
  volatile uint32_t PR;
} EXTI_TypeDef;





typedef struct
{
  volatile uint32_t ACR;
  volatile uint32_t KEYR;
  volatile uint32_t OPTKEYR;
  volatile uint32_t SR;
  volatile uint32_t CR;
  volatile uint32_t AR;
  volatile uint32_t RESERVED;
  volatile uint32_t OBR;
  volatile uint32_t WRPR;
} FLASH_TypeDef;





typedef struct
{
  volatile uint16_t RDP;
  volatile uint16_t USER;
  volatile uint16_t Data0;
  volatile uint16_t Data1;
  volatile uint16_t WRP0;
  volatile uint16_t WRP1;
  volatile uint16_t WRP2;
  volatile uint16_t WRP3;
} OB_TypeDef;





typedef struct
{
  volatile uint32_t BTCR[8];
} FSMC_Bank1_TypeDef;





typedef struct
{
  volatile uint32_t BWTR[7];
} FSMC_Bank1E_TypeDef;





typedef struct
{
  volatile uint32_t PCR2;
  volatile uint32_t SR2;
  volatile uint32_t PMEM2;
  volatile uint32_t PATT2;
  uint32_t RESERVED0;
  volatile uint32_t ECCR2;
  uint32_t RESERVED1;
  uint32_t RESERVED2;
  volatile uint32_t PCR3;
  volatile uint32_t SR3;
  volatile uint32_t PMEM3;
  volatile uint32_t PATT3;
  uint32_t RESERVED3;
  volatile uint32_t ECCR3;
} FSMC_Bank2_3_TypeDef;





typedef struct
{
  volatile uint32_t PCR4;
  volatile uint32_t SR4;
  volatile uint32_t PMEM4;
  volatile uint32_t PATT4;
  volatile uint32_t PIO4;
} FSMC_Bank4_TypeDef;





typedef struct
{
  volatile uint32_t CRL;
  volatile uint32_t CRH;
  volatile uint32_t IDR;
  volatile uint32_t ODR;
  volatile uint32_t BSRR;
  volatile uint32_t BRR;
  volatile uint32_t LCKR;
} GPIO_TypeDef;





typedef struct
{
  volatile uint32_t EVCR;
  volatile uint32_t MAPR;
  volatile uint32_t EXTICR[4];
  uint32_t RESERVED0;
  volatile uint32_t MAPR2;
} AFIO_TypeDef;




typedef struct
{
  volatile uint32_t CR1;
  volatile uint32_t CR2;
  volatile uint32_t OAR1;
  volatile uint32_t OAR2;
  volatile uint32_t DR;
  volatile uint32_t SR1;
  volatile uint32_t SR2;
  volatile uint32_t CCR;
  volatile uint32_t TRISE;
} I2C_TypeDef;





typedef struct
{
  volatile uint32_t KR;
  volatile uint32_t PR;
  volatile uint32_t RLR;
  volatile uint32_t SR;
} IWDG_TypeDef;





typedef struct
{
  volatile uint32_t CR;
  volatile uint32_t CSR;
} PWR_TypeDef;





typedef struct
{
  volatile uint32_t CR;
  volatile uint32_t CFGR;
  volatile uint32_t CIR;
  volatile uint32_t APB2RSTR;
  volatile uint32_t APB1RSTR;
  volatile uint32_t AHBENR;
  volatile uint32_t APB2ENR;
  volatile uint32_t APB1ENR;
  volatile uint32_t BDCR;
  volatile uint32_t CSR;


} RCC_TypeDef;





typedef struct
{
  volatile uint32_t CRH;
  volatile uint32_t CRL;
  volatile uint32_t PRLH;
  volatile uint32_t PRLL;
  volatile uint32_t DIVH;
  volatile uint32_t DIVL;
  volatile uint32_t CNTH;
  volatile uint32_t CNTL;
  volatile uint32_t ALRH;
  volatile uint32_t ALRL;
} RTC_TypeDef;





typedef struct
{
  volatile uint32_t POWER;
  volatile uint32_t CLKCR;
  volatile uint32_t ARG;
  volatile uint32_t CMD;
  volatile const uint32_t RESPCMD;
  volatile const uint32_t RESP1;
  volatile const uint32_t RESP2;
  volatile const uint32_t RESP3;
  volatile const uint32_t RESP4;
  volatile uint32_t DTIMER;
  volatile uint32_t DLEN;
  volatile uint32_t DCTRL;
  volatile const uint32_t DCOUNT;
  volatile const uint32_t STA;
  volatile uint32_t ICR;
  volatile uint32_t MASK;
  uint32_t RESERVED0[2];
  volatile const uint32_t FIFOCNT;
  uint32_t RESERVED1[13];
  volatile uint32_t FIFO;
} SDIO_TypeDef;





typedef struct
{
  volatile uint32_t CR1;
  volatile uint32_t CR2;
  volatile uint32_t SR;
  volatile uint32_t DR;
  volatile uint32_t CRCPR;
  volatile uint32_t RXCRCR;
  volatile uint32_t TXCRCR;
  volatile uint32_t I2SCFGR;
  volatile uint32_t I2SPR;
} SPI_TypeDef;




typedef struct
{
  volatile uint32_t CR1;
  volatile uint32_t CR2;
  volatile uint32_t SMCR;
  volatile uint32_t DIER;
  volatile uint32_t SR;
  volatile uint32_t EGR;
  volatile uint32_t CCMR1;
  volatile uint32_t CCMR2;
  volatile uint32_t CCER;
  volatile uint32_t CNT;
  volatile uint32_t PSC;
  volatile uint32_t ARR;
  volatile uint32_t RCR;
  volatile uint32_t CCR1;
  volatile uint32_t CCR2;
  volatile uint32_t CCR3;
  volatile uint32_t CCR4;
  volatile uint32_t BDTR;
  volatile uint32_t DCR;
  volatile uint32_t DMAR;
  volatile uint32_t OR;
}TIM_TypeDef;






typedef struct
{
  volatile uint32_t SR;
  volatile uint32_t DR;
  volatile uint32_t BRR;
  volatile uint32_t CR1;
  volatile uint32_t CR2;
  volatile uint32_t CR3;
  volatile uint32_t GTPR;
} USART_TypeDef;





typedef struct
{
  volatile uint16_t EP0R;
  volatile uint16_t RESERVED0;
  volatile uint16_t EP1R;
  volatile uint16_t RESERVED1;
  volatile uint16_t EP2R;
  volatile uint16_t RESERVED2;
  volatile uint16_t EP3R;
  volatile uint16_t RESERVED3;
  volatile uint16_t EP4R;
  volatile uint16_t RESERVED4;
  volatile uint16_t EP5R;
  volatile uint16_t RESERVED5;
  volatile uint16_t EP6R;
  volatile uint16_t RESERVED6;
  volatile uint16_t EP7R;
  volatile uint16_t RESERVED7[17];
  volatile uint16_t CNTR;
  volatile uint16_t RESERVED8;
  volatile uint16_t ISTR;
  volatile uint16_t RESERVED9;
  volatile uint16_t FNR;
  volatile uint16_t RESERVEDA;
  volatile uint16_t DADDR;
  volatile uint16_t RESERVEDB;
  volatile uint16_t BTABLE;
  volatile uint16_t RESERVEDC;
} USB_TypeDef;






typedef struct
{
  volatile uint32_t CR;
  volatile uint32_t CFR;
  volatile uint32_t SR;
} WWDG_TypeDef;
# 133 "../Drivers/CMSIS/Device/ST/STM32F1xx/Include\\stm32f1xx.h" 2
# 150 "../Drivers/CMSIS/Device/ST/STM32F1xx/Include\\stm32f1xx.h"
typedef enum
{
  RESET = 0,
  SET = !RESET
} FlagStatus, ITStatus;

typedef enum
{
  DISABLE = 0,
  ENABLE = !DISABLE
} FunctionalState;


typedef enum
{
  SUCCESS = 0U,
  ERROR = !SUCCESS
} ErrorStatus;
# 254 "../Drivers/CMSIS/Device/ST/STM32F1xx/Include\\stm32f1xx.h"
# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal.h" 1
# 255 "../Drivers/CMSIS/Device/ST/STM32F1xx/Include\\stm32f1xx.h" 2
# 30 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_def.h" 2
# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\Legacy/stm32_hal_legacy.h" 1
# 31 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_def.h" 2
# 1 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stddef.h" 1 3
# 38 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stddef.h" 3
  typedef signed int ptrdiff_t;







    typedef unsigned int size_t;
# 62 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stddef.h" 3
      typedef unsigned int wchar_t;
# 95 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stddef.h" 3
  typedef long double max_align_t;
# 32 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_def.h" 2






typedef enum
{
  HAL_OK = 0x00U,
  HAL_ERROR = 0x01U,
  HAL_BUSY = 0x02U,
  HAL_TIMEOUT = 0x03U
} HAL_StatusTypeDef;




typedef enum
{
  HAL_UNLOCKED = 0x00U,
  HAL_LOCKED = 0x01U
} HAL_LockTypeDef;
# 28 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_rcc.h" 2
# 47 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_rcc.h"
typedef struct
{
  uint32_t PLLState;


  uint32_t PLLSource;


  uint32_t PLLMUL;

} RCC_PLLInitTypeDef;




typedef struct
{
  uint32_t ClockType;


  uint32_t SYSCLKSource;


  uint32_t AHBCLKDivider;


  uint32_t APB1CLKDivider;


  uint32_t APB2CLKDivider;

} RCC_ClkInitTypeDef;
# 1142 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_rcc.h"
# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_rcc_ex.h" 1
# 226 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_rcc_ex.h"
typedef struct
{
  uint32_t OscillatorType;







  uint32_t HSEState;


  uint32_t HSEPredivValue;


  uint32_t LSEState;


  uint32_t HSIState;


  uint32_t HSICalibrationValue;


  uint32_t LSIState;


  RCC_PLLInitTypeDef PLL;




} RCC_OscInitTypeDef;
# 281 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_rcc_ex.h"
typedef struct
{
  uint32_t PeriphClockSelection;


  uint32_t RTCClockSelection;


  uint32_t AdcClockSelection;




  uint32_t I2s2ClockSelection;


  uint32_t I2s3ClockSelection;
# 310 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_rcc_ex.h"
  uint32_t UsbClockSelection;



} RCC_PeriphCLKInitTypeDef;
# 1857 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_rcc_ex.h"
HAL_StatusTypeDef HAL_RCCEx_PeriphCLKConfig(RCC_PeriphCLKInitTypeDef *PeriphClkInit);
void HAL_RCCEx_GetPeriphCLKConfig(RCC_PeriphCLKInitTypeDef *PeriphClkInit);
uint32_t HAL_RCCEx_GetPeriphCLKFreq(uint32_t PeriphClk);
# 1143 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_rcc.h" 2
# 1154 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_rcc.h"
HAL_StatusTypeDef HAL_RCC_DeInit(void);
HAL_StatusTypeDef HAL_RCC_OscConfig(RCC_OscInitTypeDef *RCC_OscInitStruct);
HAL_StatusTypeDef HAL_RCC_ClockConfig(RCC_ClkInitTypeDef *RCC_ClkInitStruct, uint32_t FLatency);
# 1167 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_rcc.h"
void HAL_RCC_MCOConfig(uint32_t RCC_MCOx, uint32_t RCC_MCOSource, uint32_t RCC_MCODiv);
void HAL_RCC_EnableCSS(void);
void HAL_RCC_DisableCSS(void);
uint32_t HAL_RCC_GetSysClockFreq(void);
uint32_t HAL_RCC_GetHCLKFreq(void);
uint32_t HAL_RCC_GetPCLK1Freq(void);
uint32_t HAL_RCC_GetPCLK2Freq(void);
void HAL_RCC_GetOscConfig(RCC_OscInitTypeDef *RCC_OscInitStruct);
void HAL_RCC_GetClockConfig(RCC_ClkInitTypeDef *RCC_ClkInitStruct, uint32_t *pFLatency);


void HAL_RCC_NMI_IRQHandler(void);


void HAL_RCC_CSSCallback(void);
# 239 "../Core/Inc\\stm32f1xx_hal_conf.h" 2



# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_gpio.h" 1
# 46 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_gpio.h"
typedef struct
{
  uint32_t Pin;


  uint32_t Mode;


  uint32_t Pull;


  uint32_t Speed;

} GPIO_InitTypeDef;




typedef enum
{
  GPIO_PIN_RESET = 0u,
  GPIO_PIN_SET
} GPIO_PinState;
# 212 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_gpio.h"
# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_gpio_ex.h" 1
# 867 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_gpio_ex.h"
void HAL_GPIOEx_ConfigEventout(uint32_t GPIO_PortSource, uint32_t GPIO_PinSource);
void HAL_GPIOEx_EnableEventout(void);
void HAL_GPIOEx_DisableEventout(void);
# 213 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_gpio.h" 2
# 223 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_gpio.h"
void HAL_GPIO_Init(GPIO_TypeDef *GPIOx, GPIO_InitTypeDef *GPIO_Init);
void HAL_GPIO_DeInit(GPIO_TypeDef *GPIOx, uint32_t GPIO_Pin);
# 233 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_gpio.h"
GPIO_PinState HAL_GPIO_ReadPin(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
void HAL_GPIO_WritePin(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin, GPIO_PinState PinState);
void HAL_GPIO_TogglePin(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
HAL_StatusTypeDef HAL_GPIO_LockPin(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
void HAL_GPIO_EXTI_IRQHandler(uint16_t GPIO_Pin);
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin);
# 243 "../Core/Inc\\stm32f1xx_hal_conf.h" 2



# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_exti.h" 1
# 48 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_exti.h"
typedef enum
{
  HAL_EXTI_COMMON_CB_ID = 0x00U
} EXTI_CallbackIDTypeDef;




typedef struct
{
  uint32_t Line;
  void (* PendingCallback)(void);
} EXTI_HandleTypeDef;




typedef struct
{
  uint32_t Line;

  uint32_t Mode;

  uint32_t Trigger;

  uint32_t GPIOSel;


} EXTI_ConfigTypeDef;
# 278 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_exti.h"
HAL_StatusTypeDef HAL_EXTI_SetConfigLine(EXTI_HandleTypeDef *hexti, EXTI_ConfigTypeDef *pExtiConfig);
HAL_StatusTypeDef HAL_EXTI_GetConfigLine(EXTI_HandleTypeDef *hexti, EXTI_ConfigTypeDef *pExtiConfig);
HAL_StatusTypeDef HAL_EXTI_ClearConfigLine(EXTI_HandleTypeDef *hexti);
HAL_StatusTypeDef HAL_EXTI_RegisterCallback(EXTI_HandleTypeDef *hexti, EXTI_CallbackIDTypeDef CallbackID, void (*pPendingCbfn)(void));
HAL_StatusTypeDef HAL_EXTI_GetHandle(EXTI_HandleTypeDef *hexti, uint32_t ExtiLine);
# 292 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_exti.h"
void HAL_EXTI_IRQHandler(EXTI_HandleTypeDef *hexti);
uint32_t HAL_EXTI_GetPending(EXTI_HandleTypeDef *hexti, uint32_t Edge);
void HAL_EXTI_ClearPending(EXTI_HandleTypeDef *hexti, uint32_t Edge);
void HAL_EXTI_GenerateSWI(EXTI_HandleTypeDef *hexti);
# 247 "../Core/Inc\\stm32f1xx_hal_conf.h" 2



# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_dma.h" 1
# 47 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_dma.h"
typedef struct
{
  uint32_t Direction;



  uint32_t PeriphInc;


  uint32_t MemInc;


  uint32_t PeriphDataAlignment;


  uint32_t MemDataAlignment;


  uint32_t Mode;




  uint32_t Priority;

} DMA_InitTypeDef;




typedef enum
{
  HAL_DMA_STATE_RESET = 0x00U,
  HAL_DMA_STATE_READY = 0x01U,
  HAL_DMA_STATE_BUSY = 0x02U,
  HAL_DMA_STATE_TIMEOUT = 0x03U
}HAL_DMA_StateTypeDef;




typedef enum
{
  HAL_DMA_FULL_TRANSFER = 0x00U,
  HAL_DMA_HALF_TRANSFER = 0x01U
}HAL_DMA_LevelCompleteTypeDef;




typedef enum
{
  HAL_DMA_XFER_CPLT_CB_ID = 0x00U,
  HAL_DMA_XFER_HALFCPLT_CB_ID = 0x01U,
  HAL_DMA_XFER_ERROR_CB_ID = 0x02U,
  HAL_DMA_XFER_ABORT_CB_ID = 0x03U,
  HAL_DMA_XFER_ALL_CB_ID = 0x04U

}HAL_DMA_CallbackIDTypeDef;




typedef struct __DMA_HandleTypeDef
{
  DMA_Channel_TypeDef *Instance;

  DMA_InitTypeDef Init;

  HAL_LockTypeDef Lock;

  volatile HAL_DMA_StateTypeDef State;

  void *Parent;

  void (* XferCpltCallback)( struct __DMA_HandleTypeDef * hdma);

  void (* XferHalfCpltCallback)( struct __DMA_HandleTypeDef * hdma);

  void (* XferErrorCallback)( struct __DMA_HandleTypeDef * hdma);

  void (* XferAbortCallback)( struct __DMA_HandleTypeDef * hdma);

  volatile uint32_t ErrorCode;

  DMA_TypeDef *DmaBaseAddress;

  uint32_t ChannelIndex;

} DMA_HandleTypeDef;
# 355 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_dma.h"
# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_dma_ex.h" 1
# 356 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_dma.h" 2
# 366 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_dma.h"
HAL_StatusTypeDef HAL_DMA_Init(DMA_HandleTypeDef *hdma);
HAL_StatusTypeDef HAL_DMA_DeInit (DMA_HandleTypeDef *hdma);
# 376 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_dma.h"
HAL_StatusTypeDef HAL_DMA_Start (DMA_HandleTypeDef *hdma, uint32_t SrcAddress, uint32_t DstAddress, uint32_t DataLength);
HAL_StatusTypeDef HAL_DMA_Start_IT(DMA_HandleTypeDef *hdma, uint32_t SrcAddress, uint32_t DstAddress, uint32_t DataLength);
HAL_StatusTypeDef HAL_DMA_Abort(DMA_HandleTypeDef *hdma);
HAL_StatusTypeDef HAL_DMA_Abort_IT(DMA_HandleTypeDef *hdma);
HAL_StatusTypeDef HAL_DMA_PollForTransfer(DMA_HandleTypeDef *hdma, uint32_t CompleteLevel, uint32_t Timeout);
void HAL_DMA_IRQHandler(DMA_HandleTypeDef *hdma);
HAL_StatusTypeDef HAL_DMA_RegisterCallback(DMA_HandleTypeDef *hdma, HAL_DMA_CallbackIDTypeDef CallbackID, void (* pCallback)( DMA_HandleTypeDef * _hdma));
HAL_StatusTypeDef HAL_DMA_UnRegisterCallback(DMA_HandleTypeDef *hdma, HAL_DMA_CallbackIDTypeDef CallbackID);
# 393 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_dma.h"
HAL_DMA_StateTypeDef HAL_DMA_GetState(DMA_HandleTypeDef *hdma);
uint32_t HAL_DMA_GetError(DMA_HandleTypeDef *hdma);
# 251 "../Core/Inc\\stm32f1xx_hal_conf.h" 2
# 270 "../Core/Inc\\stm32f1xx_hal_conf.h"
# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_cortex.h" 1
# 261 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_cortex.h"
void HAL_NVIC_SetPriorityGrouping(uint32_t PriorityGroup);
void HAL_NVIC_SetPriority(IRQn_Type IRQn, uint32_t PreemptPriority, uint32_t SubPriority);
void HAL_NVIC_EnableIRQ(IRQn_Type IRQn);
void HAL_NVIC_DisableIRQ(IRQn_Type IRQn);
void HAL_NVIC_SystemReset(void);
uint32_t HAL_SYSTICK_Config(uint32_t TicksNumb);
# 275 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_cortex.h"
uint32_t HAL_NVIC_GetPriorityGrouping(void);
void HAL_NVIC_GetPriority(IRQn_Type IRQn, uint32_t PriorityGroup, uint32_t* pPreemptPriority, uint32_t* pSubPriority);
uint32_t HAL_NVIC_GetPendingIRQ(IRQn_Type IRQn);
void HAL_NVIC_SetPendingIRQ(IRQn_Type IRQn);
void HAL_NVIC_ClearPendingIRQ(IRQn_Type IRQn);
uint32_t HAL_NVIC_GetActive(IRQn_Type IRQn);
void HAL_SYSTICK_CLKSourceConfig(uint32_t CLKSource);
void HAL_SYSTICK_IRQHandler(void);
void HAL_SYSTICK_Callback(void);
# 271 "../Core/Inc\\stm32f1xx_hal_conf.h" 2



# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc.h" 1
# 51 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc.h"
typedef struct
{
  uint32_t DataAlign;


  uint32_t ScanConvMode;
# 67 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc.h"
  FunctionalState ContinuousConvMode;


  uint32_t NbrOfConversion;


  FunctionalState DiscontinuousConvMode;



  uint32_t NbrOfDiscConversion;


  uint32_t ExternalTrigConv;



}ADC_InitTypeDef;






typedef struct
{
  uint32_t Channel;






  uint32_t Rank;


  uint32_t SamplingTime;
# 112 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc.h"
}ADC_ChannelConfTypeDef;






typedef struct
{
  uint32_t WatchdogMode;

  uint32_t Channel;


  FunctionalState ITMode;

  uint32_t HighThreshold;

  uint32_t LowThreshold;

  uint32_t WatchdogNumber;
}ADC_AnalogWDGConfTypeDef;
# 174 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc.h"
typedef struct __ADC_HandleTypeDef
{
  ADC_TypeDef *Instance;

  ADC_InitTypeDef Init;

  DMA_HandleTypeDef *DMA_Handle;

  HAL_LockTypeDef Lock;

  volatile uint32_t State;

  volatile uint32_t ErrorCode;
# 197 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc.h"
}ADC_HandleTypeDef;
# 882 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc.h"
# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc_ex.h" 1
# 54 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc_ex.h"
typedef struct
{
  uint32_t InjectedChannel;






  uint32_t InjectedRank;


  uint32_t InjectedSamplingTime;
# 75 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc_ex.h"
  uint32_t InjectedOffset;



  uint32_t InjectedNbrOfConversion;




  FunctionalState InjectedDiscontinuousConvMode;






  FunctionalState AutoInjectedConv;







  uint32_t ExternalTrigInjecConv;







}ADC_InjectionConfTypeDef;







typedef struct
{
  uint32_t Mode;
# 128 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc_ex.h"
}ADC_MultiModeTypeDef;
# 646 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc_ex.h"
HAL_StatusTypeDef HAL_ADCEx_Calibration_Start(ADC_HandleTypeDef* hadc);


HAL_StatusTypeDef HAL_ADCEx_InjectedStart(ADC_HandleTypeDef* hadc);
HAL_StatusTypeDef HAL_ADCEx_InjectedStop(ADC_HandleTypeDef* hadc);
HAL_StatusTypeDef HAL_ADCEx_InjectedPollForConversion(ADC_HandleTypeDef* hadc, uint32_t Timeout);


HAL_StatusTypeDef HAL_ADCEx_InjectedStart_IT(ADC_HandleTypeDef* hadc);
HAL_StatusTypeDef HAL_ADCEx_InjectedStop_IT(ADC_HandleTypeDef* hadc);



HAL_StatusTypeDef HAL_ADCEx_MultiModeStart_DMA(ADC_HandleTypeDef *hadc, uint32_t *pData, uint32_t Length);
HAL_StatusTypeDef HAL_ADCEx_MultiModeStop_DMA(ADC_HandleTypeDef *hadc);



uint32_t HAL_ADCEx_InjectedGetValue(ADC_HandleTypeDef* hadc, uint32_t InjectedRank);

uint32_t HAL_ADCEx_MultiModeGetValue(ADC_HandleTypeDef *hadc);



void HAL_ADCEx_InjectedConvCpltCallback(ADC_HandleTypeDef* hadc);
# 680 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc_ex.h"
HAL_StatusTypeDef HAL_ADCEx_InjectedConfigChannel(ADC_HandleTypeDef* hadc,ADC_InjectionConfTypeDef* sConfigInjected);

HAL_StatusTypeDef HAL_ADCEx_MultiModeConfigChannel(ADC_HandleTypeDef *hadc, ADC_MultiModeTypeDef *multimode);
# 883 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc.h" 2
# 895 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc.h"
HAL_StatusTypeDef HAL_ADC_Init(ADC_HandleTypeDef* hadc);
HAL_StatusTypeDef HAL_ADC_DeInit(ADC_HandleTypeDef *hadc);
void HAL_ADC_MspInit(ADC_HandleTypeDef* hadc);
void HAL_ADC_MspDeInit(ADC_HandleTypeDef* hadc);
# 918 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc.h"
HAL_StatusTypeDef HAL_ADC_Start(ADC_HandleTypeDef* hadc);
HAL_StatusTypeDef HAL_ADC_Stop(ADC_HandleTypeDef* hadc);
HAL_StatusTypeDef HAL_ADC_PollForConversion(ADC_HandleTypeDef* hadc, uint32_t Timeout);
HAL_StatusTypeDef HAL_ADC_PollForEvent(ADC_HandleTypeDef* hadc, uint32_t EventType, uint32_t Timeout);


HAL_StatusTypeDef HAL_ADC_Start_IT(ADC_HandleTypeDef* hadc);
HAL_StatusTypeDef HAL_ADC_Stop_IT(ADC_HandleTypeDef* hadc);


HAL_StatusTypeDef HAL_ADC_Start_DMA(ADC_HandleTypeDef* hadc, uint32_t* pData, uint32_t Length);
HAL_StatusTypeDef HAL_ADC_Stop_DMA(ADC_HandleTypeDef* hadc);


uint32_t HAL_ADC_GetValue(ADC_HandleTypeDef* hadc);


void HAL_ADC_IRQHandler(ADC_HandleTypeDef* hadc);
void HAL_ADC_ConvCpltCallback(ADC_HandleTypeDef* hadc);
void HAL_ADC_ConvHalfCpltCallback(ADC_HandleTypeDef* hadc);
void HAL_ADC_LevelOutOfWindowCallback(ADC_HandleTypeDef* hadc);
void HAL_ADC_ErrorCallback(ADC_HandleTypeDef *hadc);
# 949 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc.h"
HAL_StatusTypeDef HAL_ADC_ConfigChannel(ADC_HandleTypeDef* hadc, ADC_ChannelConfTypeDef* sConfig);
HAL_StatusTypeDef HAL_ADC_AnalogWDGConfig(ADC_HandleTypeDef* hadc, ADC_AnalogWDGConfTypeDef* AnalogWDGConfig);
# 960 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc.h"
uint32_t HAL_ADC_GetState(ADC_HandleTypeDef* hadc);
uint32_t HAL_ADC_GetError(ADC_HandleTypeDef *hadc);
# 976 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_adc.h"
HAL_StatusTypeDef ADC_Enable(ADC_HandleTypeDef* hadc);
HAL_StatusTypeDef ADC_ConversionStop_Disable(ADC_HandleTypeDef* hadc);
void ADC_StabilizationTime(uint32_t DelayUs);
void ADC_DMAConvCplt(DMA_HandleTypeDef *hdma);
void ADC_DMAHalfConvCplt(DMA_HandleTypeDef *hdma);
void ADC_DMAError(DMA_HandleTypeDef *hdma);
# 275 "../Core/Inc\\stm32f1xx_hal_conf.h" 2
# 286 "../Core/Inc\\stm32f1xx_hal_conf.h"
# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_flash.h" 1
# 73 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_flash.h"
typedef enum
{
  FLASH_PROC_NONE = 0U,
  FLASH_PROC_PAGEERASE = 1U,
  FLASH_PROC_MASSERASE = 2U,
  FLASH_PROC_PROGRAMHALFWORD = 3U,
  FLASH_PROC_PROGRAMWORD = 4U,
  FLASH_PROC_PROGRAMDOUBLEWORD = 5U
} FLASH_ProcedureTypeDef;




typedef struct
{
  volatile FLASH_ProcedureTypeDef ProcedureOnGoing;

  volatile uint32_t DataRemaining;

  volatile uint32_t Address;

  volatile uint64_t Data;

  HAL_LockTypeDef Lock;

  volatile uint32_t ErrorCode;

} FLASH_ProcessTypeDef;
# 246 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_flash.h"
# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_flash_ex.h" 1
# 168 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_flash_ex.h"
typedef struct
{
  uint32_t TypeErase;


  uint32_t Banks;


  uint32_t PageAddress;



  uint32_t NbPages;


} FLASH_EraseInitTypeDef;




typedef struct
{
  uint32_t OptionType;


  uint32_t WRPState;


  uint32_t WRPPage;


  uint32_t Banks;


  uint8_t RDPLevel;
# 211 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_flash_ex.h"
  uint8_t USERConfig;





  uint32_t DATAAddress;


  uint8_t DATAData;

} FLASH_OBProgramInitTypeDef;
# 748 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_flash_ex.h"
HAL_StatusTypeDef HAL_FLASHEx_Erase(FLASH_EraseInitTypeDef *pEraseInit, uint32_t *PageError);
HAL_StatusTypeDef HAL_FLASHEx_Erase_IT(FLASH_EraseInitTypeDef *pEraseInit);
# 759 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_flash_ex.h"
HAL_StatusTypeDef HAL_FLASHEx_OBErase(void);
HAL_StatusTypeDef HAL_FLASHEx_OBProgram(FLASH_OBProgramInitTypeDef *pOBInit);
void HAL_FLASHEx_OBGetConfig(FLASH_OBProgramInitTypeDef *pOBInit);
uint32_t HAL_FLASHEx_OBGetUserData(uint32_t DATAAdress);
# 247 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_flash.h" 2
# 257 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_flash.h"
HAL_StatusTypeDef HAL_FLASH_Program(uint32_t TypeProgram, uint32_t Address, uint64_t Data);
HAL_StatusTypeDef HAL_FLASH_Program_IT(uint32_t TypeProgram, uint32_t Address, uint64_t Data);


void HAL_FLASH_IRQHandler(void);

void HAL_FLASH_EndOfOperationCallback(uint32_t ReturnValue);
void HAL_FLASH_OperationErrorCallback(uint32_t ReturnValue);
# 274 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_flash.h"
HAL_StatusTypeDef HAL_FLASH_Unlock(void);
HAL_StatusTypeDef HAL_FLASH_Lock(void);
HAL_StatusTypeDef HAL_FLASH_OB_Unlock(void);
HAL_StatusTypeDef HAL_FLASH_OB_Lock(void);
void HAL_FLASH_OB_Launch(void);
# 288 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_flash.h"
uint32_t HAL_FLASH_GetError(void);
# 302 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_flash.h"
HAL_StatusTypeDef FLASH_WaitForLastOperation(uint32_t Timeout);
# 287 "../Core/Inc\\stm32f1xx_hal_conf.h" 2
# 306 "../Core/Inc\\stm32f1xx_hal_conf.h"
# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_iwdg.h" 1
# 46 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_iwdg.h"
typedef struct
{
  uint32_t Prescaler;


  uint32_t Reload;


} IWDG_InitTypeDef;




typedef struct
{
  IWDG_TypeDef *Instance;

  IWDG_InitTypeDef Init;
} IWDG_HandleTypeDef;
# 127 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_iwdg.h"
HAL_StatusTypeDef HAL_IWDG_Init(IWDG_HandleTypeDef *hiwdg);
# 136 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_iwdg.h"
HAL_StatusTypeDef HAL_IWDG_Refresh(IWDG_HandleTypeDef *hiwdg);
# 307 "../Core/Inc\\stm32f1xx_hal_conf.h" 2



# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_pwr.h" 1
# 47 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_pwr.h"
typedef struct
{
  uint32_t PVDLevel;


  uint32_t Mode;

}PWR_PVDTypeDef;
# 328 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_pwr.h"
void HAL_PWR_DeInit(void);
void HAL_PWR_EnableBkUpAccess(void);
void HAL_PWR_DisableBkUpAccess(void);
# 341 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_pwr.h"
void HAL_PWR_ConfigPVD(PWR_PVDTypeDef *sConfigPVD);

void HAL_PWR_EnablePVD(void);
void HAL_PWR_DisablePVD(void);


void HAL_PWR_EnableWakeUpPin(uint32_t WakeUpPinx);
void HAL_PWR_DisableWakeUpPin(uint32_t WakeUpPinx);


void HAL_PWR_EnterSTOPMode(uint32_t Regulator, uint8_t STOPEntry);
void HAL_PWR_EnterSLEEPMode(uint32_t Regulator, uint8_t SLEEPEntry);
void HAL_PWR_EnterSTANDBYMode(void);

void HAL_PWR_EnableSleepOnExit(void);
void HAL_PWR_DisableSleepOnExit(void);
void HAL_PWR_EnableSEVOnPend(void);
void HAL_PWR_DisableSEVOnPend(void);



void HAL_PWR_PVD_IRQHandler(void);
void HAL_PWR_PVDCallback(void);
# 311 "../Core/Inc\\stm32f1xx_hal_conf.h" 2
# 330 "../Core/Inc\\stm32f1xx_hal_conf.h"
# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_spi.h" 1
# 46 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_spi.h"
typedef struct
{
  uint32_t Mode;


  uint32_t Direction;


  uint32_t DataSize;


  uint32_t CLKPolarity;


  uint32_t CLKPhase;


  uint32_t NSS;



  uint32_t BaudRatePrescaler;





  uint32_t FirstBit;


  uint32_t TIMode;


  uint32_t CRCCalculation;


  uint32_t CRCPolynomial;

} SPI_InitTypeDef;




typedef enum
{
  HAL_SPI_STATE_RESET = 0x00U,
  HAL_SPI_STATE_READY = 0x01U,
  HAL_SPI_STATE_BUSY = 0x02U,
  HAL_SPI_STATE_BUSY_TX = 0x03U,
  HAL_SPI_STATE_BUSY_RX = 0x04U,
  HAL_SPI_STATE_BUSY_TX_RX = 0x05U,
  HAL_SPI_STATE_ERROR = 0x06U,
  HAL_SPI_STATE_ABORT = 0x07U
} HAL_SPI_StateTypeDef;




typedef struct __SPI_HandleTypeDef
{
  SPI_TypeDef *Instance;

  SPI_InitTypeDef Init;

  const uint8_t *pTxBuffPtr;

  uint16_t TxXferSize;

  volatile uint16_t TxXferCount;

  uint8_t *pRxBuffPtr;

  uint16_t RxXferSize;

  volatile uint16_t RxXferCount;

  void (*RxISR)(struct __SPI_HandleTypeDef *hspi);

  void (*TxISR)(struct __SPI_HandleTypeDef *hspi);

  DMA_HandleTypeDef *hdmatx;

  DMA_HandleTypeDef *hdmarx;

  HAL_LockTypeDef Lock;

  volatile HAL_SPI_StateTypeDef State;

  volatile uint32_t ErrorCode;
# 149 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_spi.h"
} SPI_HandleTypeDef;
# 642 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_spi.h"
uint8_t SPI_ISCRCErrorValid(SPI_HandleTypeDef *hspi);
# 656 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_spi.h"
HAL_StatusTypeDef HAL_SPI_Init(SPI_HandleTypeDef *hspi);
HAL_StatusTypeDef HAL_SPI_DeInit(SPI_HandleTypeDef *hspi);
void HAL_SPI_MspInit(SPI_HandleTypeDef *hspi);
void HAL_SPI_MspDeInit(SPI_HandleTypeDef *hspi);
# 675 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_spi.h"
HAL_StatusTypeDef HAL_SPI_Transmit(SPI_HandleTypeDef *hspi, const uint8_t *pData, uint16_t Size, uint32_t Timeout);
HAL_StatusTypeDef HAL_SPI_Receive(SPI_HandleTypeDef *hspi, uint8_t *pData, uint16_t Size, uint32_t Timeout);
HAL_StatusTypeDef HAL_SPI_TransmitReceive(SPI_HandleTypeDef *hspi, const uint8_t *pTxData, uint8_t *pRxData,
                                          uint16_t Size, uint32_t Timeout);
HAL_StatusTypeDef HAL_SPI_Transmit_IT(SPI_HandleTypeDef *hspi, const uint8_t *pData, uint16_t Size);
HAL_StatusTypeDef HAL_SPI_Receive_IT(SPI_HandleTypeDef *hspi, uint8_t *pData, uint16_t Size);
HAL_StatusTypeDef HAL_SPI_TransmitReceive_IT(SPI_HandleTypeDef *hspi, const uint8_t *pTxData, uint8_t *pRxData,
                                             uint16_t Size);
HAL_StatusTypeDef HAL_SPI_Transmit_DMA(SPI_HandleTypeDef *hspi, const uint8_t *pData, uint16_t Size);
HAL_StatusTypeDef HAL_SPI_Receive_DMA(SPI_HandleTypeDef *hspi, uint8_t *pData, uint16_t Size);
HAL_StatusTypeDef HAL_SPI_TransmitReceive_DMA(SPI_HandleTypeDef *hspi, const uint8_t *pTxData, uint8_t *pRxData,
                                              uint16_t Size);
HAL_StatusTypeDef HAL_SPI_DMAPause(SPI_HandleTypeDef *hspi);
HAL_StatusTypeDef HAL_SPI_DMAResume(SPI_HandleTypeDef *hspi);
HAL_StatusTypeDef HAL_SPI_DMAStop(SPI_HandleTypeDef *hspi);

HAL_StatusTypeDef HAL_SPI_Abort(SPI_HandleTypeDef *hspi);
HAL_StatusTypeDef HAL_SPI_Abort_IT(SPI_HandleTypeDef *hspi);

void HAL_SPI_IRQHandler(SPI_HandleTypeDef *hspi);
void HAL_SPI_TxCpltCallback(SPI_HandleTypeDef *hspi);
void HAL_SPI_RxCpltCallback(SPI_HandleTypeDef *hspi);
void HAL_SPI_TxRxCpltCallback(SPI_HandleTypeDef *hspi);
void HAL_SPI_TxHalfCpltCallback(SPI_HandleTypeDef *hspi);
void HAL_SPI_RxHalfCpltCallback(SPI_HandleTypeDef *hspi);
void HAL_SPI_TxRxHalfCpltCallback(SPI_HandleTypeDef *hspi);
void HAL_SPI_ErrorCallback(SPI_HandleTypeDef *hspi);
void HAL_SPI_AbortCpltCallback(SPI_HandleTypeDef *hspi);
# 711 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_spi.h"
HAL_SPI_StateTypeDef HAL_SPI_GetState(const SPI_HandleTypeDef *hspi);
uint32_t HAL_SPI_GetError(const SPI_HandleTypeDef *hspi);
# 331 "../Core/Inc\\stm32f1xx_hal_conf.h" 2



# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h" 1
# 46 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h"
typedef struct
{
  uint32_t Prescaler;


  uint32_t CounterMode;


  uint32_t Period;



  uint32_t ClockDivision;


  uint32_t RepetitionCounter;
# 72 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h"
  uint32_t AutoReloadPreload;

} TIM_Base_InitTypeDef;




typedef struct
{
  uint32_t OCMode;


  uint32_t Pulse;


  uint32_t OCPolarity;


  uint32_t OCNPolarity;



  uint32_t OCFastMode;




  uint32_t OCIdleState;



  uint32_t OCNIdleState;


} TIM_OC_InitTypeDef;




typedef struct
{
  uint32_t OCMode;


  uint32_t Pulse;


  uint32_t OCPolarity;


  uint32_t OCNPolarity;



  uint32_t OCIdleState;



  uint32_t OCNIdleState;



  uint32_t ICPolarity;


  uint32_t ICSelection;


  uint32_t ICFilter;

} TIM_OnePulse_InitTypeDef;




typedef struct
{
  uint32_t ICPolarity;


  uint32_t ICSelection;


  uint32_t ICPrescaler;


  uint32_t ICFilter;

} TIM_IC_InitTypeDef;




typedef struct
{
  uint32_t EncoderMode;


  uint32_t IC1Polarity;


  uint32_t IC1Selection;


  uint32_t IC1Prescaler;


  uint32_t IC1Filter;


  uint32_t IC2Polarity;


  uint32_t IC2Selection;


  uint32_t IC2Prescaler;


  uint32_t IC2Filter;

} TIM_Encoder_InitTypeDef;




typedef struct
{
  uint32_t ClockSource;

  uint32_t ClockPolarity;

  uint32_t ClockPrescaler;

  uint32_t ClockFilter;

} TIM_ClockConfigTypeDef;




typedef struct
{
  uint32_t ClearInputState;

  uint32_t ClearInputSource;

  uint32_t ClearInputPolarity;

  uint32_t ClearInputPrescaler;


  uint32_t ClearInputFilter;

} TIM_ClearInputConfigTypeDef;




typedef struct
{
  uint32_t MasterOutputTrigger;

  uint32_t MasterSlaveMode;






} TIM_MasterConfigTypeDef;




typedef struct
{
  uint32_t SlaveMode;

  uint32_t InputTrigger;

  uint32_t TriggerPolarity;

  uint32_t TriggerPrescaler;

  uint32_t TriggerFilter;


} TIM_SlaveConfigTypeDef;






typedef struct
{
  uint32_t OffStateRunMode;

  uint32_t OffStateIDLEMode;

  uint32_t LockLevel;

  uint32_t DeadTime;

  uint32_t BreakState;

  uint32_t BreakPolarity;

  uint32_t BreakFilter;

  uint32_t AutomaticOutput;

} TIM_BreakDeadTimeConfigTypeDef;




typedef enum
{
  HAL_TIM_STATE_RESET = 0x00U,
  HAL_TIM_STATE_READY = 0x01U,
  HAL_TIM_STATE_BUSY = 0x02U,
  HAL_TIM_STATE_TIMEOUT = 0x03U,
  HAL_TIM_STATE_ERROR = 0x04U
} HAL_TIM_StateTypeDef;




typedef enum
{
  HAL_TIM_CHANNEL_STATE_RESET = 0x00U,
  HAL_TIM_CHANNEL_STATE_READY = 0x01U,
  HAL_TIM_CHANNEL_STATE_BUSY = 0x02U,
} HAL_TIM_ChannelStateTypeDef;




typedef enum
{
  HAL_DMA_BURST_STATE_RESET = 0x00U,
  HAL_DMA_BURST_STATE_READY = 0x01U,
  HAL_DMA_BURST_STATE_BUSY = 0x02U,
} HAL_TIM_DMABurstStateTypeDef;




typedef enum
{
  HAL_TIM_ACTIVE_CHANNEL_1 = 0x01U,
  HAL_TIM_ACTIVE_CHANNEL_2 = 0x02U,
  HAL_TIM_ACTIVE_CHANNEL_3 = 0x04U,
  HAL_TIM_ACTIVE_CHANNEL_4 = 0x08U,
  HAL_TIM_ACTIVE_CHANNEL_CLEARED = 0x00U
} HAL_TIM_ActiveChannel;







typedef struct

{
  TIM_TypeDef *Instance;
  TIM_Base_InitTypeDef Init;
  HAL_TIM_ActiveChannel Channel;
  DMA_HandleTypeDef *hdma[7];

  HAL_LockTypeDef Lock;
  volatile HAL_TIM_StateTypeDef State;
  volatile HAL_TIM_ChannelStateTypeDef ChannelState[4];
  volatile HAL_TIM_ChannelStateTypeDef ChannelNState[4];
  volatile HAL_TIM_DMABurstStateTypeDef DMABurstState;
# 380 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h"
} TIM_HandleTypeDef;
# 1876 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h"
# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim_ex.h" 1
# 47 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim_ex.h"
typedef struct
{
  uint32_t IC1Polarity;


  uint32_t IC1Prescaler;


  uint32_t IC1Filter;


  uint32_t Commutation_Delay;

} TIM_HallSensor_InitTypeDef;
# 113 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim_ex.h"
HAL_StatusTypeDef HAL_TIMEx_HallSensor_Init(TIM_HandleTypeDef *htim, const TIM_HallSensor_InitTypeDef *sConfig);
HAL_StatusTypeDef HAL_TIMEx_HallSensor_DeInit(TIM_HandleTypeDef *htim);

void HAL_TIMEx_HallSensor_MspInit(TIM_HandleTypeDef *htim);
void HAL_TIMEx_HallSensor_MspDeInit(TIM_HandleTypeDef *htim);


HAL_StatusTypeDef HAL_TIMEx_HallSensor_Start(TIM_HandleTypeDef *htim);
HAL_StatusTypeDef HAL_TIMEx_HallSensor_Stop(TIM_HandleTypeDef *htim);

HAL_StatusTypeDef HAL_TIMEx_HallSensor_Start_IT(TIM_HandleTypeDef *htim);
HAL_StatusTypeDef HAL_TIMEx_HallSensor_Stop_IT(TIM_HandleTypeDef *htim);

HAL_StatusTypeDef HAL_TIMEx_HallSensor_Start_DMA(TIM_HandleTypeDef *htim, uint32_t *pData, uint16_t Length);
HAL_StatusTypeDef HAL_TIMEx_HallSensor_Stop_DMA(TIM_HandleTypeDef *htim);
# 138 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim_ex.h"
HAL_StatusTypeDef HAL_TIMEx_OCN_Start(TIM_HandleTypeDef *htim, uint32_t Channel);
HAL_StatusTypeDef HAL_TIMEx_OCN_Stop(TIM_HandleTypeDef *htim, uint32_t Channel);


HAL_StatusTypeDef HAL_TIMEx_OCN_Start_IT(TIM_HandleTypeDef *htim, uint32_t Channel);
HAL_StatusTypeDef HAL_TIMEx_OCN_Stop_IT(TIM_HandleTypeDef *htim, uint32_t Channel);


HAL_StatusTypeDef HAL_TIMEx_OCN_Start_DMA(TIM_HandleTypeDef *htim, uint32_t Channel, const uint32_t *pData,
                                          uint16_t Length);
HAL_StatusTypeDef HAL_TIMEx_OCN_Stop_DMA(TIM_HandleTypeDef *htim, uint32_t Channel);
# 159 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim_ex.h"
HAL_StatusTypeDef HAL_TIMEx_PWMN_Start(TIM_HandleTypeDef *htim, uint32_t Channel);
HAL_StatusTypeDef HAL_TIMEx_PWMN_Stop(TIM_HandleTypeDef *htim, uint32_t Channel);


HAL_StatusTypeDef HAL_TIMEx_PWMN_Start_IT(TIM_HandleTypeDef *htim, uint32_t Channel);
HAL_StatusTypeDef HAL_TIMEx_PWMN_Stop_IT(TIM_HandleTypeDef *htim, uint32_t Channel);

HAL_StatusTypeDef HAL_TIMEx_PWMN_Start_DMA(TIM_HandleTypeDef *htim, uint32_t Channel, const uint32_t *pData,
                                           uint16_t Length);
HAL_StatusTypeDef HAL_TIMEx_PWMN_Stop_DMA(TIM_HandleTypeDef *htim, uint32_t Channel);
# 179 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim_ex.h"
HAL_StatusTypeDef HAL_TIMEx_OnePulseN_Start(TIM_HandleTypeDef *htim, uint32_t OutputChannel);
HAL_StatusTypeDef HAL_TIMEx_OnePulseN_Stop(TIM_HandleTypeDef *htim, uint32_t OutputChannel);


HAL_StatusTypeDef HAL_TIMEx_OnePulseN_Start_IT(TIM_HandleTypeDef *htim, uint32_t OutputChannel);
HAL_StatusTypeDef HAL_TIMEx_OnePulseN_Stop_IT(TIM_HandleTypeDef *htim, uint32_t OutputChannel);
# 194 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim_ex.h"
HAL_StatusTypeDef HAL_TIMEx_ConfigCommutEvent(TIM_HandleTypeDef *htim, uint32_t InputTrigger,
                                              uint32_t CommutationSource);
HAL_StatusTypeDef HAL_TIMEx_ConfigCommutEvent_IT(TIM_HandleTypeDef *htim, uint32_t InputTrigger,
                                                 uint32_t CommutationSource);
HAL_StatusTypeDef HAL_TIMEx_ConfigCommutEvent_DMA(TIM_HandleTypeDef *htim, uint32_t InputTrigger,
                                                  uint32_t CommutationSource);
HAL_StatusTypeDef HAL_TIMEx_MasterConfigSynchronization(TIM_HandleTypeDef *htim,
                                                        const TIM_MasterConfigTypeDef *sMasterConfig);
HAL_StatusTypeDef HAL_TIMEx_ConfigBreakDeadTime(TIM_HandleTypeDef *htim,
                                                const TIM_BreakDeadTimeConfigTypeDef *sBreakDeadTimeConfig);
HAL_StatusTypeDef HAL_TIMEx_RemapConfig(TIM_HandleTypeDef *htim, uint32_t Remap);
# 214 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim_ex.h"
void HAL_TIMEx_CommutCallback(TIM_HandleTypeDef *htim);
void HAL_TIMEx_CommutHalfCpltCallback(TIM_HandleTypeDef *htim);
void HAL_TIMEx_BreakCallback(TIM_HandleTypeDef *htim);
# 226 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim_ex.h"
HAL_TIM_StateTypeDef HAL_TIMEx_HallSensor_GetState(const TIM_HandleTypeDef *htim);
HAL_TIM_ChannelStateTypeDef HAL_TIMEx_GetChannelNState(const TIM_HandleTypeDef *htim, uint32_t ChannelN);
# 241 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim_ex.h"
void TIMEx_DMACommutationCplt(DMA_HandleTypeDef *hdma);
void TIMEx_DMACommutationHalfCplt(DMA_HandleTypeDef *hdma);
# 1877 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h" 2
# 1888 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h"
HAL_StatusTypeDef HAL_TIM_Base_Init(TIM_HandleTypeDef *htim);
HAL_StatusTypeDef HAL_TIM_Base_DeInit(TIM_HandleTypeDef *htim);
void HAL_TIM_Base_MspInit(TIM_HandleTypeDef *htim);
void HAL_TIM_Base_MspDeInit(TIM_HandleTypeDef *htim);

HAL_StatusTypeDef HAL_TIM_Base_Start(TIM_HandleTypeDef *htim);
HAL_StatusTypeDef HAL_TIM_Base_Stop(TIM_HandleTypeDef *htim);

HAL_StatusTypeDef HAL_TIM_Base_Start_IT(TIM_HandleTypeDef *htim);
HAL_StatusTypeDef HAL_TIM_Base_Stop_IT(TIM_HandleTypeDef *htim);

HAL_StatusTypeDef HAL_TIM_Base_Start_DMA(TIM_HandleTypeDef *htim, const uint32_t *pData, uint16_t Length);
HAL_StatusTypeDef HAL_TIM_Base_Stop_DMA(TIM_HandleTypeDef *htim);
# 1910 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h"
HAL_StatusTypeDef HAL_TIM_OC_Init(TIM_HandleTypeDef *htim);
HAL_StatusTypeDef HAL_TIM_OC_DeInit(TIM_HandleTypeDef *htim);
void HAL_TIM_OC_MspInit(TIM_HandleTypeDef *htim);
void HAL_TIM_OC_MspDeInit(TIM_HandleTypeDef *htim);

HAL_StatusTypeDef HAL_TIM_OC_Start(TIM_HandleTypeDef *htim, uint32_t Channel);
HAL_StatusTypeDef HAL_TIM_OC_Stop(TIM_HandleTypeDef *htim, uint32_t Channel);

HAL_StatusTypeDef HAL_TIM_OC_Start_IT(TIM_HandleTypeDef *htim, uint32_t Channel);
HAL_StatusTypeDef HAL_TIM_OC_Stop_IT(TIM_HandleTypeDef *htim, uint32_t Channel);

HAL_StatusTypeDef HAL_TIM_OC_Start_DMA(TIM_HandleTypeDef *htim, uint32_t Channel, const uint32_t *pData,
                                       uint16_t Length);
HAL_StatusTypeDef HAL_TIM_OC_Stop_DMA(TIM_HandleTypeDef *htim, uint32_t Channel);
# 1933 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h"
HAL_StatusTypeDef HAL_TIM_PWM_Init(TIM_HandleTypeDef *htim);
HAL_StatusTypeDef HAL_TIM_PWM_DeInit(TIM_HandleTypeDef *htim);
void HAL_TIM_PWM_MspInit(TIM_HandleTypeDef *htim);
void HAL_TIM_PWM_MspDeInit(TIM_HandleTypeDef *htim);

HAL_StatusTypeDef HAL_TIM_PWM_Start(TIM_HandleTypeDef *htim, uint32_t Channel);
HAL_StatusTypeDef HAL_TIM_PWM_Stop(TIM_HandleTypeDef *htim, uint32_t Channel);

HAL_StatusTypeDef HAL_TIM_PWM_Start_IT(TIM_HandleTypeDef *htim, uint32_t Channel);
HAL_StatusTypeDef HAL_TIM_PWM_Stop_IT(TIM_HandleTypeDef *htim, uint32_t Channel);

HAL_StatusTypeDef HAL_TIM_PWM_Start_DMA(TIM_HandleTypeDef *htim, uint32_t Channel, const uint32_t *pData,
                                        uint16_t Length);
HAL_StatusTypeDef HAL_TIM_PWM_Stop_DMA(TIM_HandleTypeDef *htim, uint32_t Channel);
# 1956 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h"
HAL_StatusTypeDef HAL_TIM_IC_Init(TIM_HandleTypeDef *htim);
HAL_StatusTypeDef HAL_TIM_IC_DeInit(TIM_HandleTypeDef *htim);
void HAL_TIM_IC_MspInit(TIM_HandleTypeDef *htim);
void HAL_TIM_IC_MspDeInit(TIM_HandleTypeDef *htim);

HAL_StatusTypeDef HAL_TIM_IC_Start(TIM_HandleTypeDef *htim, uint32_t Channel);
HAL_StatusTypeDef HAL_TIM_IC_Stop(TIM_HandleTypeDef *htim, uint32_t Channel);

HAL_StatusTypeDef HAL_TIM_IC_Start_IT(TIM_HandleTypeDef *htim, uint32_t Channel);
HAL_StatusTypeDef HAL_TIM_IC_Stop_IT(TIM_HandleTypeDef *htim, uint32_t Channel);

HAL_StatusTypeDef HAL_TIM_IC_Start_DMA(TIM_HandleTypeDef *htim, uint32_t Channel, uint32_t *pData, uint16_t Length);
HAL_StatusTypeDef HAL_TIM_IC_Stop_DMA(TIM_HandleTypeDef *htim, uint32_t Channel);
# 1978 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h"
HAL_StatusTypeDef HAL_TIM_OnePulse_Init(TIM_HandleTypeDef *htim, uint32_t OnePulseMode);
HAL_StatusTypeDef HAL_TIM_OnePulse_DeInit(TIM_HandleTypeDef *htim);
void HAL_TIM_OnePulse_MspInit(TIM_HandleTypeDef *htim);
void HAL_TIM_OnePulse_MspDeInit(TIM_HandleTypeDef *htim);

HAL_StatusTypeDef HAL_TIM_OnePulse_Start(TIM_HandleTypeDef *htim, uint32_t OutputChannel);
HAL_StatusTypeDef HAL_TIM_OnePulse_Stop(TIM_HandleTypeDef *htim, uint32_t OutputChannel);

HAL_StatusTypeDef HAL_TIM_OnePulse_Start_IT(TIM_HandleTypeDef *htim, uint32_t OutputChannel);
HAL_StatusTypeDef HAL_TIM_OnePulse_Stop_IT(TIM_HandleTypeDef *htim, uint32_t OutputChannel);
# 1997 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h"
HAL_StatusTypeDef HAL_TIM_Encoder_Init(TIM_HandleTypeDef *htim, const TIM_Encoder_InitTypeDef *sConfig);
HAL_StatusTypeDef HAL_TIM_Encoder_DeInit(TIM_HandleTypeDef *htim);
void HAL_TIM_Encoder_MspInit(TIM_HandleTypeDef *htim);
void HAL_TIM_Encoder_MspDeInit(TIM_HandleTypeDef *htim);

HAL_StatusTypeDef HAL_TIM_Encoder_Start(TIM_HandleTypeDef *htim, uint32_t Channel);
HAL_StatusTypeDef HAL_TIM_Encoder_Stop(TIM_HandleTypeDef *htim, uint32_t Channel);

HAL_StatusTypeDef HAL_TIM_Encoder_Start_IT(TIM_HandleTypeDef *htim, uint32_t Channel);
HAL_StatusTypeDef HAL_TIM_Encoder_Stop_IT(TIM_HandleTypeDef *htim, uint32_t Channel);

HAL_StatusTypeDef HAL_TIM_Encoder_Start_DMA(TIM_HandleTypeDef *htim, uint32_t Channel, uint32_t *pData1,
                                            uint32_t *pData2, uint16_t Length);
HAL_StatusTypeDef HAL_TIM_Encoder_Stop_DMA(TIM_HandleTypeDef *htim, uint32_t Channel);
# 2020 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h"
void HAL_TIM_IRQHandler(TIM_HandleTypeDef *htim);
# 2030 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h"
HAL_StatusTypeDef HAL_TIM_OC_ConfigChannel(TIM_HandleTypeDef *htim, const TIM_OC_InitTypeDef *sConfig,
                                           uint32_t Channel);
HAL_StatusTypeDef HAL_TIM_PWM_ConfigChannel(TIM_HandleTypeDef *htim, const TIM_OC_InitTypeDef *sConfig,
                                            uint32_t Channel);
HAL_StatusTypeDef HAL_TIM_IC_ConfigChannel(TIM_HandleTypeDef *htim, const TIM_IC_InitTypeDef *sConfig,
                                           uint32_t Channel);
HAL_StatusTypeDef HAL_TIM_OnePulse_ConfigChannel(TIM_HandleTypeDef *htim, TIM_OnePulse_InitTypeDef *sConfig,
                                                 uint32_t OutputChannel, uint32_t InputChannel);
HAL_StatusTypeDef HAL_TIM_ConfigOCrefClear(TIM_HandleTypeDef *htim,
                                           const TIM_ClearInputConfigTypeDef *sClearInputConfig,
                                           uint32_t Channel);
HAL_StatusTypeDef HAL_TIM_ConfigClockSource(TIM_HandleTypeDef *htim, const TIM_ClockConfigTypeDef *sClockSourceConfig);
HAL_StatusTypeDef HAL_TIM_ConfigTI1Input(TIM_HandleTypeDef *htim, uint32_t TI1_Selection);
HAL_StatusTypeDef HAL_TIM_SlaveConfigSynchro(TIM_HandleTypeDef *htim, const TIM_SlaveConfigTypeDef *sSlaveConfig);
HAL_StatusTypeDef HAL_TIM_SlaveConfigSynchro_IT(TIM_HandleTypeDef *htim, const TIM_SlaveConfigTypeDef *sSlaveConfig);
HAL_StatusTypeDef HAL_TIM_DMABurst_WriteStart(TIM_HandleTypeDef *htim, uint32_t BurstBaseAddress,
                                              uint32_t BurstRequestSrc, const uint32_t *BurstBuffer,
                                              uint32_t BurstLength);
HAL_StatusTypeDef HAL_TIM_DMABurst_MultiWriteStart(TIM_HandleTypeDef *htim, uint32_t BurstBaseAddress,
                                                   uint32_t BurstRequestSrc, const uint32_t *BurstBuffer,
                                                   uint32_t BurstLength, uint32_t DataLength);
HAL_StatusTypeDef HAL_TIM_DMABurst_WriteStop(TIM_HandleTypeDef *htim, uint32_t BurstRequestSrc);
HAL_StatusTypeDef HAL_TIM_DMABurst_ReadStart(TIM_HandleTypeDef *htim, uint32_t BurstBaseAddress,
                                             uint32_t BurstRequestSrc, uint32_t *BurstBuffer, uint32_t BurstLength);
HAL_StatusTypeDef HAL_TIM_DMABurst_MultiReadStart(TIM_HandleTypeDef *htim, uint32_t BurstBaseAddress,
                                                  uint32_t BurstRequestSrc, uint32_t *BurstBuffer,
                                                  uint32_t BurstLength, uint32_t DataLength);
HAL_StatusTypeDef HAL_TIM_DMABurst_ReadStop(TIM_HandleTypeDef *htim, uint32_t BurstRequestSrc);
HAL_StatusTypeDef HAL_TIM_GenerateEvent(TIM_HandleTypeDef *htim, uint32_t EventSource);
uint32_t HAL_TIM_ReadCapturedValue(const TIM_HandleTypeDef *htim, uint32_t Channel);
# 2069 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h"
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim);
void HAL_TIM_PeriodElapsedHalfCpltCallback(TIM_HandleTypeDef *htim);
void HAL_TIM_OC_DelayElapsedCallback(TIM_HandleTypeDef *htim);
void HAL_TIM_IC_CaptureCallback(TIM_HandleTypeDef *htim);
void HAL_TIM_IC_CaptureHalfCpltCallback(TIM_HandleTypeDef *htim);
void HAL_TIM_PWM_PulseFinishedCallback(TIM_HandleTypeDef *htim);
void HAL_TIM_PWM_PulseFinishedHalfCpltCallback(TIM_HandleTypeDef *htim);
void HAL_TIM_TriggerCallback(TIM_HandleTypeDef *htim);
void HAL_TIM_TriggerHalfCpltCallback(TIM_HandleTypeDef *htim);
void HAL_TIM_ErrorCallback(TIM_HandleTypeDef *htim);
# 2096 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h"
HAL_TIM_StateTypeDef HAL_TIM_Base_GetState(const TIM_HandleTypeDef *htim);
HAL_TIM_StateTypeDef HAL_TIM_OC_GetState(const TIM_HandleTypeDef *htim);
HAL_TIM_StateTypeDef HAL_TIM_PWM_GetState(const TIM_HandleTypeDef *htim);
HAL_TIM_StateTypeDef HAL_TIM_IC_GetState(const TIM_HandleTypeDef *htim);
HAL_TIM_StateTypeDef HAL_TIM_OnePulse_GetState(const TIM_HandleTypeDef *htim);
HAL_TIM_StateTypeDef HAL_TIM_Encoder_GetState(const TIM_HandleTypeDef *htim);


HAL_TIM_ActiveChannel HAL_TIM_GetActiveChannel(const TIM_HandleTypeDef *htim);
HAL_TIM_ChannelStateTypeDef HAL_TIM_GetChannelState(const TIM_HandleTypeDef *htim, uint32_t Channel);
HAL_TIM_DMABurstStateTypeDef HAL_TIM_DMABurstState(const TIM_HandleTypeDef *htim);
# 2120 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_tim.h"
void TIM_Base_SetConfig(TIM_TypeDef *TIMx, const TIM_Base_InitTypeDef *Structure);
void TIM_TI1_SetConfig(TIM_TypeDef *TIMx, uint32_t TIM_ICPolarity, uint32_t TIM_ICSelection, uint32_t TIM_ICFilter);
void TIM_OC2_SetConfig(TIM_TypeDef *TIMx, const TIM_OC_InitTypeDef *OC_Config);
void TIM_ETR_SetConfig(TIM_TypeDef *TIMx, uint32_t TIM_ExtTRGPrescaler,
                       uint32_t TIM_ExtTRGPolarity, uint32_t ExtTRGFilter);

void TIM_DMADelayPulseHalfCplt(DMA_HandleTypeDef *hdma);
void TIM_DMAError(DMA_HandleTypeDef *hdma);
void TIM_DMACaptureCplt(DMA_HandleTypeDef *hdma);
void TIM_DMACaptureHalfCplt(DMA_HandleTypeDef *hdma);
void TIM_CCxChannelCmd(TIM_TypeDef *TIMx, uint32_t Channel, uint32_t ChannelState);
# 335 "../Core/Inc\\stm32f1xx_hal_conf.h" 2



# 1 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_uart.h" 1
# 46 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_uart.h"
typedef struct
{
  uint32_t BaudRate;




  uint32_t WordLength;


  uint32_t StopBits;


  uint32_t Parity;






  uint32_t Mode;


  uint32_t HwFlowCtl;


  uint32_t OverSampling;


} UART_InitTypeDef;
# 116 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_uart.h"
typedef enum
{
  HAL_UART_STATE_RESET = 0x00U,

  HAL_UART_STATE_READY = 0x20U,

  HAL_UART_STATE_BUSY = 0x24U,

  HAL_UART_STATE_BUSY_TX = 0x21U,

  HAL_UART_STATE_BUSY_RX = 0x22U,

  HAL_UART_STATE_BUSY_TX_RX = 0x23U,


  HAL_UART_STATE_TIMEOUT = 0xA0U,

  HAL_UART_STATE_ERROR = 0xE0U

} HAL_UART_StateTypeDef;
# 144 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_uart.h"
typedef uint32_t HAL_UART_RxTypeTypeDef;
# 155 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_uart.h"
typedef uint32_t HAL_UART_RxEventTypeTypeDef;




typedef struct __UART_HandleTypeDef
{
  USART_TypeDef *Instance;

  UART_InitTypeDef Init;

  const uint8_t *pTxBuffPtr;

  uint16_t TxXferSize;

  volatile uint16_t TxXferCount;

  uint8_t *pRxBuffPtr;

  uint16_t RxXferSize;

  volatile uint16_t RxXferCount;

  volatile HAL_UART_RxTypeTypeDef ReceptionType;

  volatile HAL_UART_RxEventTypeTypeDef RxEventType;

  DMA_HandleTypeDef *hdmatx;

  DMA_HandleTypeDef *hdmarx;

  HAL_LockTypeDef Lock;

  volatile HAL_UART_StateTypeDef gState;



  volatile HAL_UART_StateTypeDef RxState;


  volatile uint32_t ErrorCode;
# 213 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_uart.h"
} UART_HandleTypeDef;
# 722 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_uart.h"
HAL_StatusTypeDef HAL_UART_Init(UART_HandleTypeDef *huart);
HAL_StatusTypeDef HAL_HalfDuplex_Init(UART_HandleTypeDef *huart);
HAL_StatusTypeDef HAL_LIN_Init(UART_HandleTypeDef *huart, uint32_t BreakDetectLength);
HAL_StatusTypeDef HAL_MultiProcessor_Init(UART_HandleTypeDef *huart, uint8_t Address, uint32_t WakeUpMethod);
HAL_StatusTypeDef HAL_UART_DeInit(UART_HandleTypeDef *huart);
void HAL_UART_MspInit(UART_HandleTypeDef *huart);
void HAL_UART_MspDeInit(UART_HandleTypeDef *huart);
# 749 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_uart.h"
HAL_StatusTypeDef HAL_UART_Transmit(UART_HandleTypeDef *huart, const uint8_t *pData, uint16_t Size, uint32_t Timeout);
HAL_StatusTypeDef HAL_UART_Receive(UART_HandleTypeDef *huart, uint8_t *pData, uint16_t Size, uint32_t Timeout);
HAL_StatusTypeDef HAL_UART_Transmit_IT(UART_HandleTypeDef *huart, const uint8_t *pData, uint16_t Size);
HAL_StatusTypeDef HAL_UART_Receive_IT(UART_HandleTypeDef *huart, uint8_t *pData, uint16_t Size);
HAL_StatusTypeDef HAL_UART_Transmit_DMA(UART_HandleTypeDef *huart, const uint8_t *pData, uint16_t Size);
HAL_StatusTypeDef HAL_UART_Receive_DMA(UART_HandleTypeDef *huart, uint8_t *pData, uint16_t Size);
HAL_StatusTypeDef HAL_UART_DMAPause(UART_HandleTypeDef *huart);
HAL_StatusTypeDef HAL_UART_DMAResume(UART_HandleTypeDef *huart);
HAL_StatusTypeDef HAL_UART_DMAStop(UART_HandleTypeDef *huart);

HAL_StatusTypeDef HAL_UARTEx_ReceiveToIdle(UART_HandleTypeDef *huart, uint8_t *pData, uint16_t Size, uint16_t *RxLen,
                                           uint32_t Timeout);
HAL_StatusTypeDef HAL_UARTEx_ReceiveToIdle_IT(UART_HandleTypeDef *huart, uint8_t *pData, uint16_t Size);
HAL_StatusTypeDef HAL_UARTEx_ReceiveToIdle_DMA(UART_HandleTypeDef *huart, uint8_t *pData, uint16_t Size);

HAL_UART_RxEventTypeTypeDef HAL_UARTEx_GetRxEventType(UART_HandleTypeDef *huart);


HAL_StatusTypeDef HAL_UART_Abort(UART_HandleTypeDef *huart);
HAL_StatusTypeDef HAL_UART_AbortTransmit(UART_HandleTypeDef *huart);
HAL_StatusTypeDef HAL_UART_AbortReceive(UART_HandleTypeDef *huart);
HAL_StatusTypeDef HAL_UART_Abort_IT(UART_HandleTypeDef *huart);
HAL_StatusTypeDef HAL_UART_AbortTransmit_IT(UART_HandleTypeDef *huart);
HAL_StatusTypeDef HAL_UART_AbortReceive_IT(UART_HandleTypeDef *huart);

void HAL_UART_IRQHandler(UART_HandleTypeDef *huart);
void HAL_UART_TxCpltCallback(UART_HandleTypeDef *huart);
void HAL_UART_TxHalfCpltCallback(UART_HandleTypeDef *huart);
void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart);
void HAL_UART_RxHalfCpltCallback(UART_HandleTypeDef *huart);
void HAL_UART_ErrorCallback(UART_HandleTypeDef *huart);
void HAL_UART_AbortCpltCallback(UART_HandleTypeDef *huart);
void HAL_UART_AbortTransmitCpltCallback(UART_HandleTypeDef *huart);
void HAL_UART_AbortReceiveCpltCallback(UART_HandleTypeDef *huart);

void HAL_UARTEx_RxEventCallback(UART_HandleTypeDef *huart, uint16_t Size);
# 794 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_uart.h"
HAL_StatusTypeDef HAL_LIN_SendBreak(UART_HandleTypeDef *huart);
HAL_StatusTypeDef HAL_MultiProcessor_EnterMuteMode(UART_HandleTypeDef *huart);
HAL_StatusTypeDef HAL_MultiProcessor_ExitMuteMode(UART_HandleTypeDef *huart);
HAL_StatusTypeDef HAL_HalfDuplex_EnableTransmitter(UART_HandleTypeDef *huart);
HAL_StatusTypeDef HAL_HalfDuplex_EnableReceiver(UART_HandleTypeDef *huart);
# 807 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_uart.h"
HAL_UART_StateTypeDef HAL_UART_GetState(const UART_HandleTypeDef *huart);
uint32_t HAL_UART_GetError(const UART_HandleTypeDef *huart);
# 895 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal_uart.h"
HAL_StatusTypeDef UART_Start_Receive_IT(UART_HandleTypeDef *huart, uint8_t *pData, uint16_t Size);
HAL_StatusTypeDef UART_Start_Receive_DMA(UART_HandleTypeDef *huart, uint8_t *pData, uint16_t Size);
# 339 "../Core/Inc\\stm32f1xx_hal_conf.h" 2
# 30 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal.h" 2
# 48 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal.h"
typedef enum
{
  HAL_TICK_FREQ_10HZ = 100U,
  HAL_TICK_FREQ_100HZ = 10U,
  HAL_TICK_FREQ_1KHZ = 1U,
  HAL_TICK_FREQ_DEFAULT = HAL_TICK_FREQ_1KHZ
} HAL_TickFreqTypeDef;




extern volatile uint32_t uwTick;
extern uint32_t uwTickPrio;
extern HAL_TickFreqTypeDef uwTickFreq;
# 282 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal.h"
HAL_StatusTypeDef HAL_Init(void);
HAL_StatusTypeDef HAL_DeInit(void);
void HAL_MspInit(void);
void HAL_MspDeInit(void);
HAL_StatusTypeDef HAL_InitTick(uint32_t TickPriority);
# 295 "../Drivers/STM32F1xx_HAL_Driver/Inc\\stm32f1xx_hal.h"
void HAL_IncTick(void);
void HAL_Delay(uint32_t Delay);
uint32_t HAL_GetTick(void);
uint32_t HAL_GetTickPrio(void);
HAL_StatusTypeDef HAL_SetTickFreq(HAL_TickFreqTypeDef Freq);
HAL_TickFreqTypeDef HAL_GetTickFreq(void);
void HAL_SuspendTick(void);
void HAL_ResumeTick(void);
uint32_t HAL_GetHalVersion(void);
uint32_t HAL_GetREVID(void);
uint32_t HAL_GetDEVID(void);
uint32_t HAL_GetUIDw0(void);
uint32_t HAL_GetUIDw1(void);
uint32_t HAL_GetUIDw2(void);
void HAL_DBGMCU_EnableDBGSleepMode(void);
void HAL_DBGMCU_DisableDBGSleepMode(void);
void HAL_DBGMCU_EnableDBGStopMode(void);
void HAL_DBGMCU_DisableDBGStopMode(void);
void HAL_DBGMCU_EnableDBGStandbyMode(void);
void HAL_DBGMCU_DisableDBGStandbyMode(void);
# 31 "../Core/Inc\\main.h" 2
# 53 "../Core/Inc\\main.h"
void Error_Handler(void);
# 11 "../Core/Src/main.c" 2
# 1 "../Core/Inc\\spi.h" 1
# 24 "../Core/Inc\\spi.h"
extern SPI_HandleTypeDef hspi1;





void MX_SPI1_Init(void);
# 12 "../Core/Src/main.c" 2
# 1 "../Core/Inc\\usart.h" 1
# 35 "../Core/Inc\\usart.h"
extern UART_HandleTypeDef huart1;
extern UART_HandleTypeDef huart3;





void MX_USART1_UART_Init(void);
void MX_USART3_UART_Init(void);
# 13 "../Core/Src/main.c" 2
# 1 "../Core/Inc\\gpio.h" 1
# 39 "../Core/Inc\\gpio.h"
void MX_GPIO_Init(void);
# 14 "../Core/Src/main.c" 2



# 1 "../Core/Inc\\adc.h" 1
# 22 "../Core/Inc\\adc.h"
extern ADC_HandleTypeDef hadc1;





void MX_ADC1_Init(void);
# 18 "../Core/Src/main.c" 2

# 1 "../Middleware/Inc\\tjc_cmd.h" 1
# 10 "../Middleware/Inc\\tjc_cmd.h"
void tjc_send_raw(const char *cmd);
void tjc_set_val(const char *obj, int val);
void tjc_set_var(const char *name, int v);
void tjc_set_txt(const char *obj, const char *txt);
void tjc_set_bat(int pct, int page);
void tjc_set_pco(const char *obj, uint32_t color);
void tjc_set_bco(const char *obj, uint32_t color);
void tjc_pic(const char *obj, uint16_t picid);
void tjc_vis(const char *obj, uint8_t vis);
void tjc_page(uint8_t n);
void tjc_dim(uint8_t v);
void tjc_alarm_on(void);
void tjc_alarm_off(void);
void tjc_lowbatt_play(void);
void tjc_get(const char *obj, const char *prop);
# 20 "../Core/Src/main.c" 2
# 1 "../Middleware/Inc\\hmi_callback.h" 1
# 11 "../Middleware/Inc\\hmi_callback.h"
void hmi_on_rx_byte(uint8_t b);


void hmi_on_hist_clear(void);
void hmi_on_thr_hi_inc(void);
void hmi_on_thr_hi_dec(void);
void hmi_on_thr_hi_set(void);
void hmi_on_buz_mute(void);
void hmi_on_cal_zero(void);

void hmi_on_sensor_zero_hw(void);
void hmi_on_sensor_lo15(void);
void hmi_on_cal_span(void);
void hmi_on_cal_factory(void);
void hmi_on_tbl_page(int delta);
void hmi_on_page_enter(int p);


uint8_t hmi_get_page(void);
void hmi_on_test_toggle(void);
void hmi_on_init_skip(void);
# 21 "../Core/Src/main.c" 2
# 1 "../Middleware/Inc\\hmi_get.h" 1








void hmi_get_reset(void);
int hmi_get_feed(uint8_t b);
uint32_t hmi_get_value(void);
uint8_t hmi_get_is_string(void);
# 22 "../Core/Src/main.c" 2
# 1 "../Middleware/Inc\\c4f7n_hmi_protocol.h" 1
# 20 "../Middleware/Inc\\c4f7n_hmi_protocol.h"
typedef enum {
  HMI_CMD_NONE = 0x00,
  HMI_CMD_BUZZER_MUTE = 0x06,
  HMI_CMD_INIT_SKIP = 0x07,
  HMI_CMD_HIST_CLEAR = 0x01,
  HMI_CMD_THR_HI_INC = 0x02,
  HMI_CMD_THR_HI_DEC = 0x03,
  HMI_CMD_THR_HI_SET = 0x11,
  HMI_CMD_CAL_ZERO = 0x15,
  HMI_CMD_CAL_SPAN = 0x16,
  HMI_CMD_CAL_FAC = 0x17,





  HMI_CMD_TBL_NEXT = 0x23,

  HMI_CMD_TEST_TOGGLE = 0x24,
  HMI_CMD_TBL_PREV = 0x25,

  HMI_CMD_PAGE0_ENTER = 0x40,
  HMI_CMD_PAGE1_ENTER = 0x41,
  HMI_CMD_PAGE2_ENTER = 0x42,
  HMI_CMD_PAGE3_ENTER = 0x43,


  HMI_CMD_SENSOR_ZERO_HW = 0x1A,
  HMI_CMD_SENSOR_LO15 = 0x1B,

  HMI_CMD_PAGE5_ENTER = 0x45
} hmi_cmd_t;
# 23 "../Core/Src/main.c" 2
# 1 "../BSP/Inc\\sensor.h" 1
# 42 "../BSP/Inc\\sensor.h"
void sensor_init(void);


int sensor_warmup(void);


float sensor_read_ppm(void);


float sensor_read_raw(void);


float sensor_read_voltage(void);





void sensor_set_cal(int32_t k, int32_t b);
void sensor_get_cal(int32_t *k, int32_t *b);


int sensor_has_new(void);


int sensor_online(void);
# 79 "../BSP/Inc\\sensor.h"
extern const uint8_t SENSOR_CMD_ZERO_HW[6];
extern const uint8_t SENSOR_CMD_LO15_A[11];
extern const uint8_t SENSOR_CMD_LO15_B[11];


void sensor_send_cmd(const uint8_t *buf, uint8_t len);
# 96 "../BSP/Inc\\sensor.h"
extern const uint8_t SENSOR_CMD_ZERO_HW[6];
extern const uint8_t SENSOR_CMD_LO15_A[11];
extern const uint8_t SENSOR_CMD_LO15_B[11];


void sensor_send_cmd(const uint8_t *buf, uint8_t len);


void sensor_uart4_irq_handler(void);
# 24 "../Core/Src/main.c" 2
# 1 "../BSP/Inc\\battery.h" 1
# 16 "../BSP/Inc\\battery.h"
void battery_init(void);


void battery_poll(void);


int battery_get_pct(void);


uint8_t battery_valid(void);

uint8_t battery_get_level(void);
# 25 "../Core/Src/main.c" 2
# 1 "../BSP/Inc\\pump.h" 1
# 20 "../BSP/Inc\\pump.h"
void pump_init(void);


void pump_set(int on);


void pump_toggle(void);


int pump_get(void);


void pump_set_duty(uint8_t duty_percent);


int pump_get_rpm_ff(void);


void pump_feedback_isr(void);
# 26 "../Core/Src/main.c" 2
# 1 "../BSP/Inc\\w25q16.h" 1
# 36 "../BSP/Inc\\w25q16.h"
void w25q16_init(void);


uint32_t w25q16_read_id(void);


void w25q16_read(uint32_t addr, uint8_t *buf, uint32_t len);


void w25q16_erase_sector(uint32_t addr);


void w25q16_page_program(uint32_t addr, const uint8_t *buf, uint32_t len);


void w25q16_write(uint32_t addr, const uint8_t *buf, uint32_t len);
# 27 "../Core/Src/main.c" 2
# 1 "../BSP/Inc\\history.h" 1
# 37 "../BSP/Inc\\history.h"
typedef struct {
  uint32_t ts;
  uint16_t ppm;
} hist_rec_t;


void history_init(void);
void history_log(uint16_t ppm);
void history_clear(void);
uint32_t history_get_base(void);
uint32_t history_available(void);
uint32_t history_total(void);
int history_read_one(uint32_t idx, hist_rec_t *r);
uint16_t history_read_window(uint32_t seconds, hist_rec_t *out, uint16_t max_n);
uint16_t history_read_recent(uint32_t seconds, hist_rec_t *out, uint16_t max_n);
uint16_t history_page_count(uint16_t per);
uint16_t history_read_page(uint32_t page, hist_rec_t *out, uint16_t per);
uint32_t wall_time_seconds(void);
void history_export_window(uint32_t seconds);
# 28 "../Core/Src/main.c" 2
# 1 "../BSP/Inc\\param_store.h" 1
# 25 "../BSP/Inc\\param_store.h"
typedef struct {
  uint32_t magic;
  uint32_t version;



  int32_t cal_k;
  int32_t cal_b;
  int32_t cal_raw0;
  uint32_t cal_ts;


  uint32_t hist_base;


  uint16_t thr_hi;
  uint16_t thr_lo;
  uint8_t buzzer_en;
  uint8_t cal_valid;
  uint16_t _rsv;

  uint32_t crc;
} param_t;




void param_load_defaults(param_t *p);
void param_init(param_t *p);


void param_save(const param_t *p);


void param_factory(param_t *p, int save_now);


uint32_t param_get_hist_base(void);
void param_set_hist_base(uint32_t base);
# 92 "../BSP/Inc\\param_store.h"
uint8_t param_reset_flag(void);
# 29 "../Core/Src/main.c" 2
# 1 "../BSP/Inc\\selftest.h" 1
# 12 "../BSP/Inc\\selftest.h"
typedef struct {
  uint8_t flash_ok;
  uint8_t sensor_ok;
  uint8_t batt_ok;
} selftest_t;


void selftest_run(selftest_t *r);
# 30 "../Core/Src/main.c" 2
# 1 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 1 3
# 53 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
    typedef unsigned int size_t;
# 68 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
    typedef __builtin_va_list __va_list;
# 87 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
typedef struct __fpos_t_struct {
    unsigned long long int __pos;





    struct {
        unsigned int __state1, __state2;
    } __mbstate;
} fpos_t;
# 108 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
typedef struct __FILE FILE;
# 138 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern FILE __stdin, __stdout, __stderr;
extern FILE *__aeabi_stdin, *__aeabi_stdout, *__aeabi_stderr;
# 224 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) int remove(const char * ) __attribute__((__nonnull__(1)));







extern __attribute__((__nothrow__)) int rename(const char * , const char * ) __attribute__((__nonnull__(1,2)));
# 243 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) FILE *tmpfile(void);






extern __attribute__((__nothrow__)) char *tmpnam(char * );
# 265 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) int fclose(FILE * ) __attribute__((__nonnull__(1)));
# 275 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) int fflush(FILE * );
# 285 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) FILE *fopen(const char * __restrict ,
                           const char * __restrict ) __attribute__((__nonnull__(1,2)));
# 329 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) FILE *freopen(const char * __restrict ,
                    const char * __restrict ,
                    FILE * __restrict ) __attribute__((__nonnull__(2,3)));
# 342 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) void setbuf(FILE * __restrict ,
                    char * __restrict ) __attribute__((__nonnull__(1)));






extern __attribute__((__nothrow__)) int setvbuf(FILE * __restrict ,
                   char * __restrict ,
                   int , size_t ) __attribute__((__nonnull__(1)));
# 370 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
#pragma __printf_args
extern __attribute__((__nothrow__)) int fprintf(FILE * __restrict ,
                    const char * __restrict , ...) __attribute__((__nonnull__(1,2)));
# 393 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
#pragma __printf_args
extern __attribute__((__nothrow__)) int _fprintf(FILE * __restrict ,
                     const char * __restrict , ...) __attribute__((__nonnull__(1,2)));





#pragma __printf_args
extern __attribute__((__nothrow__)) int printf(const char * __restrict , ...) __attribute__((__nonnull__(1)));






#pragma __printf_args
extern __attribute__((__nothrow__)) int _printf(const char * __restrict , ...) __attribute__((__nonnull__(1)));





#pragma __printf_args
extern __attribute__((__nothrow__)) int sprintf(char * __restrict , const char * __restrict , ...) __attribute__((__nonnull__(1,2)));








#pragma __printf_args
extern __attribute__((__nothrow__)) int _sprintf(char * __restrict , const char * __restrict , ...) __attribute__((__nonnull__(1,2)));






#pragma __printf_args
extern __attribute__((__nothrow__)) int __ARM_snprintf(char * __restrict , size_t ,
                     const char * __restrict , ...) __attribute__((__nonnull__(3)));


#pragma __printf_args
extern __attribute__((__nothrow__)) int snprintf(char * __restrict , size_t ,
                     const char * __restrict , ...) __attribute__((__nonnull__(3)));
# 460 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
#pragma __printf_args
extern __attribute__((__nothrow__)) int _snprintf(char * __restrict , size_t ,
                      const char * __restrict , ...) __attribute__((__nonnull__(3)));





#pragma __scanf_args
extern __attribute__((__nothrow__)) int fscanf(FILE * __restrict ,
                    const char * __restrict , ...) __attribute__((__nonnull__(1,2)));
# 503 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
#pragma __scanf_args
extern __attribute__((__nothrow__)) int _fscanf(FILE * __restrict ,
                     const char * __restrict , ...) __attribute__((__nonnull__(1,2)));





#pragma __scanf_args
extern __attribute__((__nothrow__)) int scanf(const char * __restrict , ...) __attribute__((__nonnull__(1)));








#pragma __scanf_args
extern __attribute__((__nothrow__)) int _scanf(const char * __restrict , ...) __attribute__((__nonnull__(1)));





#pragma __scanf_args
extern __attribute__((__nothrow__)) int sscanf(const char * __restrict ,
                    const char * __restrict , ...) __attribute__((__nonnull__(1,2)));
# 541 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
#pragma __scanf_args
extern __attribute__((__nothrow__)) int _sscanf(const char * __restrict ,
                     const char * __restrict , ...) __attribute__((__nonnull__(1,2)));







extern __attribute__((__nothrow__)) int vfscanf(FILE * __restrict , const char * __restrict , __va_list) __attribute__((__nonnull__(1,2)));
extern __attribute__((__nothrow__)) int vscanf(const char * __restrict , __va_list) __attribute__((__nonnull__(1)));
extern __attribute__((__nothrow__)) int vsscanf(const char * __restrict , const char * __restrict , __va_list) __attribute__((__nonnull__(1,2)));

extern __attribute__((__nothrow__)) int _vfscanf(FILE * __restrict , const char * __restrict , __va_list) __attribute__((__nonnull__(1,2)));
extern __attribute__((__nothrow__)) int _vscanf(const char * __restrict , __va_list) __attribute__((__nonnull__(1)));
extern __attribute__((__nothrow__)) int _vsscanf(const char * __restrict , const char * __restrict , __va_list) __attribute__((__nonnull__(1,2)));
extern __attribute__((__nothrow__)) int __ARM_vsscanf(const char * __restrict , const char * __restrict , __va_list) __attribute__((__nonnull__(1,2)));

extern __attribute__((__nothrow__)) int vprintf(const char * __restrict , __va_list ) __attribute__((__nonnull__(1)));







extern __attribute__((__nothrow__)) int _vprintf(const char * __restrict , __va_list ) __attribute__((__nonnull__(1)));





extern __attribute__((__nothrow__)) int vfprintf(FILE * __restrict ,
                    const char * __restrict , __va_list ) __attribute__((__nonnull__(1,2)));
# 584 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) int vsprintf(char * __restrict ,
                     const char * __restrict , __va_list ) __attribute__((__nonnull__(1,2)));
# 594 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) int __ARM_vsnprintf(char * __restrict , size_t ,
                     const char * __restrict , __va_list ) __attribute__((__nonnull__(3)));

extern __attribute__((__nothrow__)) int vsnprintf(char * __restrict , size_t ,
                     const char * __restrict , __va_list ) __attribute__((__nonnull__(3)));
# 609 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) int _vsprintf(char * __restrict ,
                      const char * __restrict , __va_list ) __attribute__((__nonnull__(1,2)));





extern __attribute__((__nothrow__)) int _vfprintf(FILE * __restrict ,
                     const char * __restrict , __va_list ) __attribute__((__nonnull__(1,2)));





extern __attribute__((__nothrow__)) int _vsnprintf(char * __restrict , size_t ,
                      const char * __restrict , __va_list ) __attribute__((__nonnull__(3)));






#pragma __printf_args
extern __attribute__((__nothrow__)) int asprintf(char ** , const char * __restrict , ...) __attribute__((__nonnull__(2)));
extern __attribute__((__nothrow__)) int vasprintf(char ** , const char * __restrict , __va_list ) __attribute__((__nonnull__(2)));

#pragma __printf_args
extern __attribute__((__nothrow__)) int __ARM_asprintf(char ** , const char * __restrict , ...) __attribute__((__nonnull__(2)));
extern __attribute__((__nothrow__)) int __ARM_vasprintf(char ** , const char * __restrict , __va_list ) __attribute__((__nonnull__(2)));
# 649 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) int fgetc(FILE * ) __attribute__((__nonnull__(1)));
# 659 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) char *fgets(char * __restrict , int ,
                    FILE * __restrict ) __attribute__((__nonnull__(1,3)));
# 673 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) int fputc(int , FILE * ) __attribute__((__nonnull__(2)));
# 683 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) int fputs(const char * __restrict , FILE * __restrict ) __attribute__((__nonnull__(1,2)));






extern __attribute__((__nothrow__)) int getc(FILE * ) __attribute__((__nonnull__(1)));
# 704 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
    extern __attribute__((__nothrow__)) int (getchar)(void);
# 713 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) char *gets(char * ) __attribute__((__nonnull__(1)));
# 725 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) int putc(int , FILE * ) __attribute__((__nonnull__(2)));
# 737 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
    extern __attribute__((__nothrow__)) int (putchar)(int );






extern __attribute__((__nothrow__)) int puts(const char * ) __attribute__((__nonnull__(1)));







extern __attribute__((__nothrow__)) int ungetc(int , FILE * ) __attribute__((__nonnull__(2)));
# 778 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) size_t fread(void * __restrict ,
                    size_t , size_t , FILE * __restrict ) __attribute__((__nonnull__(1,4)));
# 794 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) size_t __fread_bytes_avail(void * __restrict ,
                    size_t , FILE * __restrict ) __attribute__((__nonnull__(1,3)));
# 810 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) size_t fwrite(const void * __restrict ,
                    size_t , size_t , FILE * __restrict ) __attribute__((__nonnull__(1,4)));
# 822 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) int fgetpos(FILE * __restrict , fpos_t * __restrict ) __attribute__((__nonnull__(1,2)));
# 833 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) int fseek(FILE * , long int , int ) __attribute__((__nonnull__(1)));
# 850 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) int fsetpos(FILE * __restrict , const fpos_t * __restrict ) __attribute__((__nonnull__(1,2)));
# 863 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) long int ftell(FILE * ) __attribute__((__nonnull__(1)));
# 877 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) void rewind(FILE * ) __attribute__((__nonnull__(1)));
# 886 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) void clearerr(FILE * ) __attribute__((__nonnull__(1)));







extern __attribute__((__nothrow__)) int feof(FILE * ) __attribute__((__nonnull__(1)));




extern __attribute__((__nothrow__)) int ferror(FILE * ) __attribute__((__nonnull__(1)));




extern __attribute__((__nothrow__)) void perror(const char * );
# 917 "D:\\KEIL\\ARM\\ARMCLANG\\bin\\..\\include\\stdio.h" 3
extern __attribute__((__nothrow__)) int _fisatty(FILE * ) __attribute__((__nonnull__(1)));



extern __attribute__((__nothrow__)) void __use_no_semihosting_swi(void);
extern __attribute__((__nothrow__)) void __use_no_semihosting(void);
# 31 "../Core/Src/main.c" 2
# 1 "../BSP/Inc\\device_id.h" 1
# 16 "../BSP/Inc\\device_id.h"
# 1 "../Core/Inc\\product_info.h" 1
# 17 "../BSP/Inc\\device_id.h" 2





void device_id_init(void);


const char *device_id_get(void);
# 32 "../Core/Src/main.c" 2
# 55 "../Core/Src/main.c"
static float g_ppm = 0.0f;
static volatile float g_peak = 0.0f;
static volatile float g_min = 4294967.0f;
static int g_thr_hi = 500;
static int g_thr_lo = 100;
static int g_alarm = 0;
static selftest_t g_selftest;
static volatile uint8_t g_mute = 0;
static int g_warm = 0;
static volatile uint8_t g_page_init = 1;
static volatile uint8_t g_skip = 0;
static uint32_t g_boot_ms = 0;
# 77 "../Core/Src/main.c"
enum { CAL_REQ_NONE = 0, CAL_REQ_ZERO, CAL_REQ_SPAN, CAL_REQ_FAC,
       CAL_REQ_ZW, CAL_REQ_LO15 };
# 89 "../Core/Src/main.c"
static volatile uint8_t s_devtest = 0;
static uint32_t s_devtest_t0 = 0;
static void devtest_ppm(const char *tag)
{
  char b[48];


  int r = (int)(sensor_read_raw() + 0.5f);
  int i = 0;
  const char *p = tag;


  while (*p && i < 20) b[i++] = *p++;
  b[i++] = (char)((r / 100) + 0x30);
  b[i++] = (char)(((r / 10) % 10) + 0x30);
  b[i++] = (char)((r % 10) + 0x30);
  b[i++] = 0x0D; b[i++] = 0x0A; b[i] = 0;
  HAL_UART_Transmit(&huart1, (uint8_t *)b, (uint16_t)i, 50);
}

static volatile uint8_t g_cal_req = CAL_REQ_NONE;
static volatile uint8_t g_hist_clear_req = 0;
static volatile uint8_t g_cal_st_dirty = 0;
# 123 "../Core/Src/main.c"
static uint8_t g_cal0_armed = 0;
static uint32_t g_cal0_t0 = 0;
static float g_cal0_ppm0 = 0.0f;



static uint8_t g_cal0_owner = CAL_REQ_NONE;

static char g_avg_str[16];
static volatile uint16_t g_tbl_page = 1;

static volatile uint8_t g_test = 0;
static volatile uint32_t g_test_t0 = 0;
static volatile uint64_t g_sess_sum = 0;
static volatile uint32_t g_sess_cnt = 0;
static volatile uint16_t g_sess_max = 0;
static volatile uint16_t g_sess_min = 0xFFFF;





static float g_avg_run = 0.0f;
static float g_avg_buf[60u];
static uint16_t g_avg_i = 0, g_avg_n = 0;


param_t g_param;

static volatile uint8_t g_thr_dirty = 0;
static volatile uint32_t g_thr_dirty_t = 0;
static volatile uint8_t g_save_pending = 0;

static void hmi_get_response(void);

uint8_t rx_byte;
static volatile uint8_t g_rx_reattach_fail;
# 169 "../Core/Src/main.c"
void SystemClock_Config(void);

static void app_refresh(void);
static void app_apply_threshold(void);
static void refill_table(void);
static void hmi_update_init_countdown(void);
static void cal_poll(void);
static void hist_clear_poll(void);
static void cal_upload_status(void);
static void epoch_to_ymd(uint32_t e, int *py, int *pmo, int *pd);
static void hmi_update_selftest(void);
static void low_batt_poll(void);
static void param_save_safe(void);







static volatile uint8_t g_sync_st = 0;
static volatile uint8_t g_time_sync_idx = 0;
static volatile uint8_t g_rtc_wait = 0;
static volatile uint32_t g_sync_deadline = 0;
static volatile uint32_t g_sync_t0 = 0;
static volatile uint32_t g_sync_sec0 = 0xFFFFFFFFu;
static volatile uint32_t g_sync_rtc[6];
static volatile uint32_t g_wall_epoch = 0;
static volatile uint32_t g_wall_tick = 0;
static uint32_t rtc_to_epoch(uint32_t y, uint32_t mo, uint32_t d, uint32_t h, uint32_t mi, uint32_t s);
static void rtc_time_start_sync(void);
static void rtc_time_finalize(void);
static void rtc_time_sync_poll(void);
uint32_t rtc_wall_seconds(void);



static const uint32_t CONC_COLOR[4] = { 57149, 62689, 59944, 59944 };





static volatile uint8_t g_page_now = 0xFFu;
static volatile uint8_t g_full_dirty = 1;
static volatile uint8_t g_refill_req = 0;



static volatile uint8_t g_thr_hi_req = 0;
static volatile uint8_t g_thr_push = 0;
static volatile uint8_t g_thr_wait = 0;



static volatile uint8_t g_get_busy = 0;
static volatile uint8_t g_thr_try = 0;
static volatile uint32_t g_thr_t0 = 0;
# 236 "../Core/Src/main.c"
static volatile uint32_t g_thr_deadline = 0;
static void thr_apply_hi_val(uint32_t v);
static void thr_hi_readback_poll(void);
static void hmi_push_device_info(void);


static void iwdg_enable(void); static void iwdg_feed(void);
# 254 "../Core/Src/main.c"
static IWDG_HandleTypeDef hiwdg;
static void iwdg_hw_start(void);





void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart) {
  if (huart != 0 && huart->Instance != ((USART_TypeDef *)(0x40000000UL + 0x00004800UL))) return;
  {
    int gr = hmi_get_feed(rx_byte);
    if (gr > 0) {

      hmi_get_response();
    } else if (gr == 0) {

      hmi_on_rx_byte(rx_byte);
    }


  }

  (void)HAL_UART_Receive_IT(huart, &rx_byte, 1);
}
# 290 "../Core/Src/main.c"
void HAL_UART_ErrorCallback(UART_HandleTypeDef *huart) {
  if (huart == 0 || huart->Instance != ((USART_TypeDef *)(0x40000000UL + 0x00004800UL))) return;
  do{ volatile uint32_t tmpreg = 0x00U; tmpreg = (huart)->Instance->SR; tmpreg = (huart)->Instance->DR; (void)tmpreg; } while(0U);
  hmi_get_reset();
  if (HAL_UART_Receive_IT(huart, &rx_byte, 1) != HAL_OK) {
    g_rx_reattach_fail = 1;
  }
}


void hmi_get_response(void) {
  uint32_t v = hmi_get_value();



  if (g_get_busy) {
    g_get_busy = 0; g_thr_wait = 0; g_thr_hi_req = 0; g_thr_try = 0;
    thr_apply_hi_val(v);
    return;
  }

  if (g_sync_st >= 2u || !g_rtc_wait) return;

  if (g_sync_st == 0u) {
    g_rtc_wait = 0;
    if (g_time_sync_idx == 0u) { g_sync_sec0 = v; g_time_sync_idx = 1u; g_sync_t0 = HAL_GetTick(); }
    else if (v != g_sync_sec0) { g_sync_st = 1u; g_time_sync_idx = 0; }
    else { g_sync_sec0 = v; g_sync_t0 = HAL_GetTick(); }
    return;
  }

  g_sync_rtc[g_time_sync_idx] = v;
  g_rtc_wait = 0;
  if (++g_time_sync_idx >= 6u) {
    uint32_t y = g_sync_rtc[0], mo = g_sync_rtc[1], d = g_sync_rtc[2];
    if (y >= 2020u && y <= 2099u && mo >= 1u && mo <= 12u && d >= 1u && d <= 31u) {
      g_wall_epoch = rtc_to_epoch(y, mo, d, g_sync_rtc[3], g_sync_rtc[4], g_sync_rtc[5]);
      g_wall_tick = HAL_GetTick();
      g_sync_st = 2u;
    } else {
      g_sync_st = 1u; g_time_sync_idx = 0;
    }
  }
}





static void app_apply_threshold(void) {
  g_thr_hi = g_param.thr_hi; g_thr_lo = g_param.thr_lo;
  tjc_set_val("h", g_thr_hi);



  tjc_set_var("thr", g_thr_hi);
}


static uint32_t g_iwdg_t = 0;
static uint8_t g_iwdg_on = 0;
static void iwdg_enable(void) { g_iwdg_on = 1; g_iwdg_t = HAL_GetTick(); }
static void iwdg_feed(void) {
  if (g_iwdg_on && (HAL_GetTick() - g_iwdg_t) > 4000u) __NVIC_SystemReset();
  g_iwdg_t = HAL_GetTick();
  HAL_IWDG_Refresh(&hiwdg);
}



static void iwdg_hw_start(void) {
  RCC_OscInitTypeDef osc = {0};
  osc.OscillatorType = 0x00000008U;
  osc.LSIState = (0x1UL << (0U));
  osc.PLL.PLLState = 0x00000000U;
  (void)HAL_RCC_OscConfig(&osc);
  hiwdg.Instance = ((IWDG_TypeDef *)(0x40000000UL + 0x00003000UL));
  hiwdg.Init.Prescaler = 32u;
  hiwdg.Init.Reload = 4000u;
  (void)HAL_IWDG_Init(&hiwdg);
}


uint32_t rtc_wall_seconds(void) {
  return g_wall_epoch + (uint32_t)((HAL_GetTick() - g_wall_tick) / 1000u);
}

static uint32_t rtc_to_epoch(uint32_t y, uint32_t mo, uint32_t d, uint32_t h, uint32_t mi, uint32_t s) {
  int yy = (int)y, mm = (int)mo;
  yy -= (mm <= 2);
  int era = (yy >= 0 ? yy : yy - 399) / 400;
  unsigned yoe = (unsigned)(yy - era * 400);
  unsigned month = (unsigned)(mm + (mm > 2 ? -3 : 9));
  unsigned doy = (153u * month + 2u) / 5u + (unsigned)d - 1u;
  unsigned doe = yoe * 365u + yoe / 4u - yoe / 100u + doy;
  uint32_t days = (uint32_t)(era * 146097) + doe - 719468u;
  return days * 86400u + h * 3600u + mi * 60u + s;
}

static void rtc_time_start_sync(void) {
  g_sync_st = 0; g_time_sync_idx = 0; g_rtc_wait = 0; g_sync_sec0 = 0xFFFFFFFFu;
  g_sync_t0 = HAL_GetTick();
}
static void rtc_time_finalize(void) {
  g_sync_st = 2;
}




static const char *const RTC_MIRROR[6] = { "rY_i","rM_i","rD_i","rH_i","rMi_i","rsec_i" };

static void rtc_time_sync_poll(void) {
  uint32_t now = HAL_GetTick();
  if (g_sync_st >= 2u) return;
  if (g_sync_st == 0u && g_time_sync_idx >= 1u) {
    if ((uint32_t)(now - g_sync_t0) < 1200u) return;
  }
  if (g_rtc_wait) {
    if (now > g_sync_deadline) { g_rtc_wait = 0; g_time_sync_idx = 0; }
    return;
  }
  if (g_get_busy) return;
  g_rtc_wait = 1; g_sync_deadline = now + 500u;
  tjc_get((g_sync_st == 0u) ? "rsec_i" : RTC_MIRROR[g_time_sync_idx], "val");
}






int main(void)
{
# 432 "../Core/Src/main.c"
  HAL_Init();






  SystemClock_Config();






  MX_GPIO_Init();
  MX_USART1_UART_Init();
  MX_USART3_UART_Init();
  MX_SPI1_Init();
  MX_ADC1_Init();




  sensor_init();

  s_devtest_t0 = HAL_GetTick();



  battery_init();
  battery_poll();

  pump_init();


  w25q16_init();
  param_init(&g_param);
  history_init();
  device_id_init();

  g_thr_hi = g_param.thr_hi;
  g_thr_lo = g_param.thr_lo;
  sensor_set_cal(g_param.cal_k, g_param.cal_b);


  selftest_run(&g_selftest);


  HAL_UART_Receive_IT(&huart3, &rx_byte, 1);


  tjc_page(3);

  HAL_Delay(1500);
  tjc_page(3);
  HAL_Delay(1000);
  tjc_page(3);
  app_apply_threshold();
  rtc_time_start_sync();


  g_boot_ms = HAL_GetTick();



  iwdg_hw_start();

  iwdg_enable();
  iwdg_feed();





  while (1)
  {





    if (s_devtest < 4u) {
      uint32_t el = HAL_GetTick() - s_devtest_t0;
      if (s_devtest == 0u) { if (el > 3000u) { s_devtest = 1u; s_devtest_t0 = HAL_GetTick(); } }
      else if (s_devtest == 1u) { devtest_ppm("[P1]"); sensor_send_cmd(SENSOR_CMD_LO15_A, 11); s_devtest = 2u; s_devtest_t0 = HAL_GetTick(); }
      else if (s_devtest == 2u) { if (el > 500u) { devtest_ppm("[P2]"); s_devtest = 3u; s_devtest_t0 = HAL_GetTick(); } }
      else if (s_devtest == 3u) { if (el > 500u) { sensor_send_cmd(SENSOR_CMD_LO15_B, 11); s_devtest = 4u; s_devtest_t0 = HAL_GetTick(); devtest_ppm("[P3]"); } }
    }

    iwdg_feed();
    if (g_thr_dirty || g_thr_push) { g_thr_dirty = 0; g_thr_push = 0; app_apply_threshold(); }
    if (g_save_pending && (HAL_GetTick() - g_thr_dirty_t) >= 200u) { g_save_pending = 0; param_save_safe(); }
    cal_poll();
    hist_clear_poll();
    hmi_update_init_countdown();
    hmi_update_selftest();
    low_batt_poll();
    app_refresh();
    HAL_Delay(250);
  }

}





void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};




  RCC_OscInitStruct.OscillatorType = 0x00000001U;
  RCC_OscInitStruct.HSEState = (0x1UL << (16U));
  RCC_OscInitStruct.HSEPredivValue = 0x00000000U;
  RCC_OscInitStruct.HSIState = (0x1UL << (0U));
  RCC_OscInitStruct.PLL.PLLState = 0x00000002U;
  RCC_OscInitStruct.PLL.PLLSource = (0x1UL << (16U));
  RCC_OscInitStruct.PLL.PLLMUL = (0x7UL << (18U));
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }



  RCC_ClkInitStruct.ClockType = 0x00000002U|0x00000001U
                              |0x00000004U|0x00000008U;
  RCC_ClkInitStruct.SYSCLKSource = 0x00000002U;
  RCC_ClkInitStruct.AHBCLKDivider = 0x00000000U;
  RCC_ClkInitStruct.APB1CLKDivider = 0x00000400U;
  RCC_ClkInitStruct.APB2CLKDivider = 0x00000000U;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, (0x2UL << (0U))) != HAL_OK)
  {
    Error_Handler();
  }
}
# 585 "../Core/Src/main.c"
static void hmi_update_status_chips(uint8_t full) {
  static uint8_t s_dot = 0xFFu, s_pump = 0xFFu, s_bat = 0xFFu;
  static uint32_t s_strip = 0xFFFFFFFFu;
  char n[12];
  int probe = sensor_online();
  int pct = battery_get_pct();
  int st_ok = g_selftest.flash_ok;
  uint8_t dot = (probe && st_ok) ? 1u : 0u;
  uint8_t pump = pump_get() ? 1u : 0u;
  uint8_t bpic = (pct >= 50) ? (uint8_t)5
               : (pct >= 20) ? (uint8_t)3 : (uint8_t)6;

  uint32_t stc = (g_alarm >= 2) ? (uint32_t)59944
               : (g_alarm == 1) ? (uint32_t)62689 : (uint32_t)12777;
  if (!g_full_dirty && !full && dot == s_dot && pump == s_pump && bpic == s_bat && stc == s_strip) return;
  s_dot = dot; s_pump = pump; s_bat = bpic; s_strip = stc;
  const char *sfx = "_s1";
  if (g_page_init) sfx = "_i";
  else if (g_page_now == 0u) sfx = "";
  else if (g_page_now == 2u) sfx = "_s2";
  else if (g_page_now == 5u) sfx = "_f";

  snprintf(n, sizeof(n), "pc0d%s", sfx); tjc_pic(n, dot ? 5 : 4);
  snprintf(n, sizeof(n), "pc1d%s", sfx); tjc_pic(n, pump ? 5 : 4);
  snprintf(n, sizeof(n), "pc2d%s", sfx); tjc_pic(n, bpic);
  snprintf(n, sizeof(n), "dvr%s", sfx); tjc_set_bco(n, stc);

  snprintf(n, sizeof(n), "pc0%s", sfx);
  tjc_set_txt(n, probe ? "\xCC\xBD\xCD\xB7 \xD2\xD1\xC1\xAC\xBD\xD3" : "\xCC\xBD\xCD\xB7 \xCE\xB4\xC1\xAC\xBD\xD3");
  snprintf(n, sizeof(n), "pc1%s", sfx);
  tjc_set_txt(n, pump ? "\xB1\xC3 \xD2\xD1\xC6\xF4\xB6\xAF" : "\xB1\xC3 \xCE\xB4\xC6\xF4\xB6\xAF");
}







static void hmi_update_init_countdown(void) {
  static int last_left = -1;
  uint32_t el;
  int left;
  char cb[24];
  if (!g_page_init) { last_left = -1; return; }
  el = HAL_GetTick() - g_boot_ms;
  left = (el >= 60000u) ? 0 : (int)((60000u - el) / 1000u);
  if (left == last_left) return;
  last_left = left;
  snprintf(cb, sizeof(cb), "\xCA\xA3\xD3\xE0 %d \xC3\xEB", left);
  tjc_set_txt("pt0_i", cb);
}


static void param_save_safe(void) {
  if (!g_selftest.flash_ok) return;
  param_save(&g_param);
}
# 651 "../Core/Src/main.c"
static void hmi_update_selftest(void) {
  static uint8_t s_fail = 0xFF, s_rst = 0xFF;
  uint8_t fail = (!g_selftest.flash_ok ? 1u : 0u) | (!g_selftest.batt_ok ? 2u : 0u);




  uint8_t rst = param_reset_flag();
  char cb[48];
  if (!g_page_init) { s_fail = 0xFF; return; }
  if (fail == s_fail && rst == s_rst) return;
  s_fail = fail; s_rst = rst;
  if (fail == 0 && rst) snprintf(cb, sizeof(cb), "\xB2\xCE\xCA\xFD\xD2\xD1\xD6\xD8\xD6\xC3\xA3\xAC\xC7\xEB\xD6\xD8\xD0\xC2\xC9\xE8\xD6\xC3\xE3\xD0\xD6\xB5");
  else if (fail == 0) snprintf(cb, sizeof(cb), "\xD7\xD4\xBC\xEC\xCD\xA8\xB9\xFD");
  else if (fail == 1) snprintf(cb, sizeof(cb), "\xB4\xE6\xB4\xA2\xC6\xF7\xB9\xCA\xD5\xCF");
  else if (fail == 2) snprintf(cb, sizeof(cb), "\xB5\xE7\xB3\xD8\xB2\xC9\xD1\xF9\xD2\xEC\xB3\xA3");
  else snprintf(cb, sizeof(cb), "\xB4\xE6\xB4\xA2\xC6\xF7/\xB5\xE7\xB3\xD8\xB9\xCA\xD5\xCF");
  tjc_set_txt("pst_i", cb);

  tjc_set_pco("pst_i", fail ? 59944 : (rst ? 62689 : 9771));
}
# 683 "../Core/Src/main.c"
static void low_batt_poll(void) {
  static uint8_t s_lv = 0xFF, s_pend = 0xFF;
  static uint32_t s_pend_t = 0, s_last_play = 0;
  uint8_t lv = battery_get_level();
  char n[16];
  char cb[32];
  const char *sfx;
  uint8_t page_full;

  if (lv != s_pend) { s_pend = lv; s_pend_t = HAL_GetTick(); return; }
  if (HAL_GetTick() - s_pend_t < 1000u) return;


  page_full = g_full_dirty ? 1u : 0u;

  if ((lv == s_lv) && !page_full) {
    if ((lv == 2 && HAL_GetTick() - s_last_play >= 30000u) ||
        (lv == 3 && HAL_GetTick() - s_last_play >= 10000u)) {
      s_last_play = HAL_GetTick();
      tjc_lowbatt_play();
    }
    return;
  }
  s_last_play = HAL_GetTick();
  s_lv = lv;


  sfx = "_s1";
  if (g_page_init) sfx = "_i";
  else if (g_page_now == 0u) sfx = "";
  else if (g_page_now == 2u) sfx = "_s2";
  else if (g_page_now == 5u) sfx = "_f";
  snprintf(n, sizeof(n), "lb%s", sfx);

  if (lv == 0) {
    tjc_set_txt(n, "");
    tjc_set_pco(n, 57149u);
  } else {

    if (lv == 1) snprintf(cb, sizeof(cb), "\xB5\xE7\xC1\xBF\xB5\xCD\xA3\xAC\xC7\xEB\xB3\xE4\xB5\xE7");
    else if (lv == 2) snprintf(cb, sizeof(cb), "\xB5\xE7\xC1\xBF\xBC\xB4\xBD\xAB\xBA\xC4\xBE\xA1");
    else snprintf(cb, sizeof(cb), "\xB5\xE7\xC1\xBF\xBD\xAB\xBA\xC4\xBE\xA1\xC7\xEB\xC1\xA2\xBC\xB4\xB3\xE4\xB5\xE7");
    tjc_set_pco(n, (lv == 1) ? 62689u : 59944u);
    tjc_set_txt(n, cb);
    if (!page_full) tjc_lowbatt_play();
  }
}






static void hmi_push_device_info(void) {
  char b[48];
  snprintf(b, sizeof(b), "\xB9\xCC\xBC\xFE\xB0\xE6\xB1\xBE: %s", "V1.0-b62");
  tjc_set_txt("fw", b);
  snprintf(b, sizeof(b), "\xB2\xFA\xC6\xB7\xB1\xE0\xBA\xC5: %s", device_id_get());
  tjc_set_txt("sn", b);
}


static void app_refresh(void) {
# 754 "../Core/Src/main.c"
  if (g_rx_reattach_fail) {
    do{ volatile uint32_t tmpreg = 0x00U; tmpreg = (&huart3)->Instance->SR; tmpreg = (&huart3)->Instance->DR; (void)tmpreg; } while(0U);
    hmi_get_reset();
    if (HAL_UART_Receive_IT(&huart3, &rx_byte, 1) == HAL_OK) g_rx_reattach_fail = 0;
  }

  uint8_t full = g_full_dirty;
  if (full) { g_full_dirty = 0; hmi_push_device_info(); }
  rtc_time_sync_poll();
  thr_hi_readback_poll();
  char buf[32];


  battery_poll();




  g_ppm = sensor_read_ppm();

  g_warm = ((HAL_GetTick() - g_boot_ms) < 60000u) ? 1 : 0;
  if (g_warm) { g_ppm = 0.0f; g_alarm = 0; }

  if (g_page_init && (g_skip || !g_warm)) {
    g_page_init = 0; g_skip = 0;
    g_page_now = 0;
    g_full_dirty = 1;
    tjc_page(0);
  }
  if (g_ppm > g_peak) g_peak = g_ppm;
  if (g_ppm < g_min) g_min = g_ppm;


  if (g_test) {
    unsigned p = (unsigned)g_ppm;
    g_sess_sum += p; g_sess_cnt++;
    if (p > g_sess_max) g_sess_max = (uint16_t)p;
    if (p < g_sess_min) g_sess_min = (uint16_t)p;
  }


  { static float s_ring = 0.0f;
    if (g_avg_n == 60u) s_ring -= g_avg_buf[g_avg_i];
    g_avg_buf[g_avg_i] = g_ppm;
    g_avg_i = (uint16_t)((g_avg_i + 1) % 60u);
    if (g_avg_n < 60u) g_avg_n++;
    s_ring += g_ppm;
    g_avg_run = (float)(s_ring / (double)g_avg_n);
  }


  if (g_ppm > 1500.0f) g_alarm = 3;
  else if (g_thr_hi > 0 && g_ppm >= g_thr_hi) g_alarm = 2;
  else if (g_thr_lo > 0 && g_ppm >= g_thr_lo) g_alarm = 1;
  else g_alarm = 0;


  { static int prev = -1;
    static uint32_t tlast = 0;
    static uint8_t s_mute_prev = 0;
    if (g_alarm >= 2 && g_param.buzzer_en) {
      uint32_t t = HAL_GetTick();
      if (g_mute) {
        tjc_alarm_off();
      } else if (g_alarm != prev || (t - tlast) >= 2000u || g_mute != s_mute_prev) {




        tjc_alarm_on(); tlast = t;
      }
    } else {
      if (prev >= 2) tjc_alarm_off();
      if (prev >= 2 && g_alarm == 0) g_mute = 0;
    }
    prev = g_alarm;
    s_mute_prev = g_mute;
  }




  { static uint8_t s_mute = 0xFFu;
    uint8_t m = g_mute ? 1u : 0u;
    if (full || m != s_mute) { s_mute = m;
      tjc_set_txt("bm", m ? "\xD2\xD1\xBE\xB2\xD2\xF4" : "\xBE\xB2\xD2\xF4"); } }



  { static uint8_t s_test = 0xFFu;
    uint8_t t = g_test ? 1u : 0u;
    if (full || t != s_test) { s_test = t;
      tjc_set_txt("ptg", t ? "\xB2\xE2\xCA\xD4\xD6\xD0" : "\xBF\xAA\xCA\xBC\xB2\xE2\xCA\xD4"); } }


  { static uint32_t hist_last = 0;
    uint32_t hn = HAL_GetTick();
    if (g_test && !g_warm && g_selftest.flash_ok && (hn - hist_last >= 1000u)) { hist_last = hn; history_log((uint16_t)g_ppm); }
# 866 "../Core/Src/main.c"
    { static uint32_t rlast = 0;
      static uint32_t s_total = 0xFFFFFFFFu;
      static uint16_t s_pg = 0u;
      uint32_t tot = history_total();
      if (g_refill_req) { g_refill_req = 0; rlast = hn; refill_table(); s_total = tot; s_pg = g_tbl_page; }
      else if (g_page_now == 2u && (tot != s_total || g_tbl_page != s_pg)) { rlast = hn; s_total = tot; s_pg = g_tbl_page; refill_table(); }
      else if (g_page_now == 2u && (hn - rlast >= 5000u)) { rlast = hn; s_total = tot; s_pg = g_tbl_page; refill_table(); } }
  }


  {




    tjc_set_val("cc", (int)(g_ppm));
    snprintf(g_avg_str, sizeof(g_avg_str), "%.2f", (double)g_avg_run);






    { int mxi = (int)g_peak;
      int mni = (g_min > 1e6f) ? 0 : (int)g_min;
      static int s_mx = -1, s_mn = -1;
      if (full || mxi != s_mx || mni != s_mn) {
        s_mx = mxi; s_mn = mni;
        snprintf(buf, sizeof(buf), "\xD7\xEE\xB4\xF3\xD6\xB5: %.0f", (double)mxi); tjc_set_txt("cma", buf);
        snprintf(buf, sizeof(buf), "\xD7\xEE\xD0\xA1\xD6\xB5: %.0f", (double)mni); tjc_set_txt("cmn", buf); } }




    { uint32_t ccc = CONC_COLOR[g_alarm];
      static uint32_t s_ccc = 0xFFFFFFFFu;
      if (full || ccc != s_ccc) { s_ccc = ccc; tjc_set_pco("cc", ccc); } }

    hmi_update_status_chips(full);
  }
}




static void send_hist_stats(void) {
  char sbuf[24];
  if (g_sess_cnt == 0) {
    snprintf(sbuf, sizeof(sbuf), "0"); tjc_set_txt("mx", sbuf);
    snprintf(sbuf, sizeof(sbuf), "0"); tjc_set_txt("av", sbuf);
    snprintf(sbuf, sizeof(sbuf), "0"); tjc_set_txt("mn", sbuf);
    snprintf(sbuf, sizeof(sbuf), "0"); tjc_set_txt("du", sbuf);
    snprintf(sbuf, sizeof(sbuf), "0"); tjc_set_txt("ct", sbuf);
    return;
  }
  snprintf(sbuf, sizeof(sbuf), "%u", (unsigned)g_sess_max);
  tjc_set_txt("mx", sbuf);
  snprintf(sbuf, sizeof(sbuf), "%.1f", (double)((float)((double)g_sess_sum / (double)g_sess_cnt)));
  tjc_set_txt("av", sbuf);
  snprintf(sbuf, sizeof(sbuf), "%u", (unsigned)g_sess_min);
  tjc_set_txt("mn", sbuf);
  snprintf(sbuf, sizeof(sbuf), "%u", (unsigned)((HAL_GetTick() - g_test_t0) / 1000u));
  tjc_set_txt("du", sbuf);
  snprintf(sbuf, sizeof(sbuf), "%u", (unsigned)g_sess_cnt);
  tjc_set_txt("ct", sbuf);
}


static void epoch_to_civil(uint32_t t, int *yp, int *mp, int *dp, int *hp, int *mip, int *sp) {
  uint32_t days = t / 86400u, sod = t % 86400u;
  int h = (int)(sod / 3600u), mi = (int)((sod % 3600u) / 60u), s = (int)(sod % 60u);
  uint64_t z = (uint64_t)days + 719468u;

  uint64_t era = z / 146097ul;
  uint64_t doe = z - era * 146097ul;
  unsigned yoe = (unsigned)((doe - doe/1460u + doe/36524u - doe/146096u) / 365u);
  int y = (int)yoe + (int)(unsigned)era * 400;
  unsigned doy = (unsigned)(doe - (365u*yoe + yoe/4u - yoe/100u));
  unsigned mp0 = (5u*doy + 2u)/153u;
  unsigned d = (unsigned)(doy - (153u*mp0 + 2u)/5u + 1u);
  unsigned m = (mp0<10u)?(mp0+3u):(mp0-9u);
  y += (m<=2)?1:0;
  if (yp) *yp = y; if (mp) *mp = (int)m; if (dp) *dp = (int)d;
  if (hp) *hp = h; if (mip) *mip = mi; if (sp) *sp = s;
}


static void refill_table(void) {
  hist_rec_t r[24u];
  uint16_t n, i;
  uint16_t pc, page = g_tbl_page;
  uint32_t total = history_total();
  char s[40];

  pc = history_page_count(24u);
  if (page < 1) page = 1;
  if (page > pc) page = pc;
  g_tbl_page = page;
  n = history_read_page(page, r, 24u);





  for (i = 0; i < 24u; i++) {
    char tObj[8], pObj[8], sObj[8];
    char tbuf[30], vbuf[12], sbuf[6];
    if ((i % 2u) == 0u) iwdg_feed();
    if (i < n) {
      int y, mo, d, hh, mm, ss;

      epoch_to_civil(r[i].ts, &y, &mo, &d, &hh, &mm, &ss);
      snprintf(tbuf, sizeof(tbuf), "%04d-%02d-%02d %02d:%02d:%02d", y, mo, d, hh, mm, ss);

      snprintf(vbuf, sizeof(vbuf), "%u", (unsigned)r[i].ppm);
# 991 "../Core/Src/main.c"
      { uint32_t gi = (uint32_t)(page - 1u) * 24u + (uint32_t)i;
        uint32_t recnum = total - gi;
        uint32_t ser = ((recnum - 1u) % 9999u) + 1u;
        snprintf(sbuf, sizeof(sbuf), "%04lu", (unsigned long)ser); }
    } else {
      snprintf(tbuf, sizeof(tbuf), " ");
      snprintf(vbuf, sizeof(vbuf), " ");
      snprintf(sbuf, sizeof(sbuf), " ");
    }



    { uint16_t oi = (i < (24u / 2u)) ? (uint16_t)(2u * i)
                                               : (uint16_t)(2u * (i - 24u / 2u) + 1u);
      snprintf(tObj, sizeof(tObj), "%s%u", "tt", oi);
      tjc_set_txt(tObj, tbuf);
      snprintf(pObj, sizeof(pObj), "%s%u", "np", oi);
      tjc_set_txt(pObj, vbuf);
      snprintf(sObj, sizeof(sObj), "%s%u", "sn", oi);
      tjc_set_txt(sObj, sbuf);
    }
  }
      snprintf(s, sizeof(s), "%u/%u", (unsigned)page, (unsigned)pc);


  tjc_set_txt("pg", s);
  send_hist_stats();
}





void hmi_on_init_skip(void) {
  if (HAL_GetTick() < 5000u) return;
  g_skip = 1;
}





static void thr_commit(void){ g_thr_hi=g_param.thr_hi; g_thr_lo=g_param.thr_lo; g_thr_dirty=1; g_save_pending=1; g_thr_dirty_t=HAL_GetTick(); }
void hmi_on_thr_hi_inc(void){ int v=(int)g_param.thr_hi+50; if(v>1500)v=1500; g_param.thr_hi=(uint16_t)v; thr_commit(); }
void hmi_on_thr_hi_dec(void){ int v=(int)g_param.thr_hi-50; if(v<100)v=100; if(v<g_param.thr_lo)v=g_param.thr_lo; g_param.thr_hi=(uint16_t)v; thr_commit(); }


void hmi_on_thr_hi_set(void) { g_thr_hi_req = 1; g_thr_try = 0; g_thr_t0 = HAL_GetTick(); }


static void thr_apply_hi_val(uint32_t v) {
  if (v < 100) v = 100;
  if (v > 1500) v = 1500;
  if (v < g_param.thr_lo) v = g_param.thr_lo;
  if ((uint16_t)v == g_param.thr_hi) return;
  g_param.thr_hi = (uint16_t)v;
  thr_commit();
}


static void thr_hi_readback_poll(void) {
  uint32_t now = HAL_GetTick();
  if (!g_thr_hi_req) return;
  if (g_thr_wait) { if (now > g_thr_deadline) { g_thr_wait = 0; g_get_busy = 0; } else return; }
  if (g_rtc_wait) return;


  if ((uint32_t)(now - g_thr_t0) >= 8000u) {
    g_thr_hi_req = 0; g_thr_try = 0; g_get_busy = 0; g_thr_wait = 0; return;
  }
  g_thr_try++;
  g_thr_wait = 1; g_get_busy = 1; g_thr_deadline = now + 500u;
  tjc_get("h", "val");
}


void hmi_on_buz_mute(void) { g_mute = !g_mute; }
# 1081 "../Core/Src/main.c"
enum {
  CAL_E_OK = 0, CAL_E_OFFLINE, CAL_E_WARMUP, CAL_E_DIRTY,
  CAL_E_WINDOW, CAL_E_BADRAW, CAL_E_NOZERO, CAL_E_TOOCLOSE, CAL_E_KCLAMP,
  CAL_E_FLASH, CAL_E_CONFIRM, CAL_E_CHANGED,
  CAL_E_SENT
};


static uint8_t cal_precheck(void)
{
  if (!sensor_online()) return CAL_E_OFFLINE;
  if ((HAL_GetTick() - g_boot_ms) < 120000u) return CAL_E_WARMUP;
  return CAL_E_OK;
}


static void epoch_to_ymd(uint32_t e, int *py, int *pmo, int *pd)
{
  int z = (int)(e / 86400u) + 719468;
  int era = (z >= 0 ? z : z - 146096) / 146097;
  unsigned doe = (unsigned)(z - era * 146097);
  unsigned yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
  unsigned doy = doe - (365u * yoe + yoe / 4u - yoe / 100u);
  unsigned mp = (5u * doy + 2u) / 153u;
  unsigned dd = doy - (153u * mp + 2u) / 5u + 1u;
  unsigned mm = (mp < 10u) ? (mp + 3u) : (mp - 9u);
  *py = (int)yoe + era * 400 + (mm <= 2u);
  *pmo = (int)mm;
  *pd = (int)dd;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-source-encoding"


static void cal_report(uint8_t which, uint8_t reason)
{
  char rs[64];
  const char *btn = (which == CAL_REQ_ZERO) ? "c0"
                  : (which == CAL_REQ_SPAN) ? "c1"
                  : (which == CAL_REQ_ZW) ? "cwh"
                  : (which == CAL_REQ_LO15) ? "cl15" : "cf";

  const char *rs_obj = (g_page_now == 5u) ? "crs_f" : "crs_s1";
  int push_rs = (g_page_now == 5u);
  const char *word;
  int k100 = (int)((g_param.cal_k + 5) / 10);

  switch (reason) {
    case CAL_E_OK:
      word = "执行";
      if (which == CAL_REQ_ZERO) snprintf(rs, sizeof(rs), "零点标定完成 补偿%dppm，请确认环境洁净", (int)g_param.cal_b);
      else if (which == CAL_REQ_SPAN) snprintf(rs, sizeof(rs), "量程标定完成 灵敏度 %d.%02d", k100 / 100, k100 % 100);
      else if (which == CAL_REQ_ZW) snprintf(rs, sizeof(rs), "硬件零点指令已下发，请确认读数是否归零");
      else if (which == CAL_REQ_LO15) snprintf(rs, sizeof(rs), "15ppm 下限指令已下发，15 以内应显示 0");
      else snprintf(rs, sizeof(rs), "已恢复出厂设置，设备重启中");
      break;

    case CAL_E_SENT:
      word = (which == CAL_REQ_ZW) ? "已下发" : "已下发";
      break;
    case CAL_E_OFFLINE: word = "未接通"; snprintf(rs, sizeof(rs), "标定失败：探头未连接"); break;
    case CAL_E_WARMUP: word = "预热中"; snprintf(rs, sizeof(rs), "标定失败：需开机 %u 秒后（示数稳定）", (unsigned)(120000u / 1000u)); break;
    case CAL_E_DIRTY: word = "浓度高"; snprintf(rs, sizeof(rs), "零点失败：当前超 %d ppm，需洁净空气", 50); break;
    case CAL_E_WINDOW: word = "超窗口"; snprintf(rs, sizeof(rs), "量程失败：示数需在 %d~%d ppm",
                                                (int)(1000.0f * (1.0f - 0.10f)),
                                                (int)(1000.0f * (1.0f + 0.10f))); break;
    case CAL_E_BADRAW: word = "非法值"; snprintf(rs, sizeof(rs), "标定失败：原始读数为 0，检查探头"); break;
    case CAL_E_NOZERO: word = "无零点"; snprintf(rs, sizeof(rs), "量程失败：请先做零点标定"); break;
    case CAL_E_TOOCLOSE: word = "点太近"; snprintf(rs, sizeof(rs), "量程失败：与零点读数差不足 %d", 50); break;
    case CAL_E_KCLAMP: word = "已限幅"; snprintf(rs, sizeof(rs), "量程标定：斜率超范围已限幅"); break;
case CAL_E_FLASH: word = "存储坏"; snprintf(rs, sizeof(rs), "失败：存储器故障，无法保存"); break;
    case CAL_E_CONFIRM:
      word = "待确认";
      if (which == CAL_REQ_ZW) snprintf(rs, sizeof(rs), "当前 %dppm，须洁净空气，3秒内再按确认", (int)g_cal0_ppm0);
      else if (which == CAL_REQ_LO15) snprintf(rs, sizeof(rs), "将下发 15ppm 下限指令（不可撤销），3秒内再按确认");
      else snprintf(rs, sizeof(rs), "当前 %dppm，须洁净空气，3秒内再按确认", (int)g_cal0_ppm0);
      break;
    case CAL_E_CHANGED: word = "已作废"; snprintf(rs, sizeof(rs), "浓度已变化，请重新点击零点标定"); break;
    default: word = "失败"; snprintf(rs, sizeof(rs), "标定失败"); break;
  }
  tjc_set_txt(btn, word);
  if (push_rs) tjc_set_txt(rs_obj, rs);
}


static void cal_upload_status(void)
{


  const char *obj_st;
  char s[56];
  uint32_t now, age;
  int yy, mo, dd;

  if (g_page_now != 5u) return;
  obj_st = "cst_f";

  if (!g_param.cal_valid || g_param.cal_ts == 0u) {
    tjc_set_txt(obj_st, "标定：未标定");
    tjc_set_pco(obj_st, (uint32_t)57149);
    return;
  }
  epoch_to_ymd(g_param.cal_ts, &yy, &mo, &dd);
  now = rtc_wall_seconds();
  age = (now > g_param.cal_ts) ? (now - g_param.cal_ts) : 0u;
  if (age > 180u * 86400u) {
    snprintf(s, sizeof(s), "标定：%04d-%02d-%02d 已超期 补偿%dppm", yy, mo, dd, (int)g_param.cal_b);
    tjc_set_pco(obj_st, (uint32_t)62689);
  } else {
    snprintf(s, sizeof(s), "标定：%04d-%02d-%02d 补偿%dppm", yy, mo, dd, (int)g_param.cal_b);
    tjc_set_pco(obj_st, (uint32_t)57149);
  }
  tjc_set_txt(obj_st, s);
}

#pragma clang diagnostic pop


static void cal_do_zero(void)
{
  uint8_t e = cal_precheck();
  float ppm, raw, dt;

  if (e) { g_cal0_armed = 0; g_cal0_owner = CAL_REQ_NONE; cal_report(CAL_REQ_ZERO, e); return; }
  ppm = sensor_read_ppm();
  if (ppm >= (float)50) { g_cal0_armed = 0; g_cal0_owner = CAL_REQ_NONE; cal_report(CAL_REQ_ZERO, CAL_E_DIRTY); return; }




  if ((g_cal0_armed && (g_cal0_owner == (CAL_REQ_ZERO))) && (HAL_GetTick() - g_cal0_t0) <= 3000u) {
    dt = ppm - g_cal0_ppm0;
    if (dt < 0.0f) dt = -dt;
    if (dt > 3.0f) { g_cal0_armed = 0; g_cal0_owner = CAL_REQ_NONE; cal_report(CAL_REQ_ZERO, CAL_E_CHANGED); return; }
    g_cal0_armed = 0;
  } else {

    if (g_cal0_armed) g_cal0_armed = 0;
    g_cal0_armed = 1; g_cal0_owner = CAL_REQ_ZERO;
    g_cal0_t0 = HAL_GetTick(); g_cal0_ppm0 = ppm;
    cal_report(CAL_REQ_ZERO, CAL_E_CONFIRM);
    return;
  }







  raw = sensor_read_raw();
  if (raw < 0.0f) { cal_report(CAL_REQ_ZERO, CAL_E_BADRAW); return; }

  g_param.cal_raw0 = (int32_t)raw;
  g_param.cal_b = -(int32_t)((raw * (float)g_param.cal_k) / 1000.0f);
  g_param.cal_ts = rtc_wall_seconds();
  g_param.cal_valid = 1;
  param_save_safe();
  sensor_set_cal(g_param.cal_k, g_param.cal_b);
  cal_report(CAL_REQ_ZERO, CAL_E_OK);
}



static void cal_do_span(void)
{
  uint8_t e = cal_precheck();
  int32_t raw0;
  float ppm, raw1, lo, hi;
  int64_t k, b;

  g_cal0_armed = 0; g_cal0_owner = CAL_REQ_NONE;
  if (e) { cal_report(CAL_REQ_SPAN, e); return; }
  raw0 = g_param.cal_raw0;
  if (raw0 == (int32_t)0x7FFFFFFF) { cal_report(CAL_REQ_SPAN, CAL_E_NOZERO); return; }

  ppm = sensor_read_ppm();
  lo = 1000.0f * (1.0f - 0.10f);
  hi = 1000.0f * (1.0f + 0.10f);
  if (ppm < lo || ppm > hi) { cal_report(CAL_REQ_SPAN, CAL_E_WINDOW); return; }

  raw1 = sensor_read_raw();

  if (raw1 <= 0.0f) { cal_report(CAL_REQ_SPAN, CAL_E_BADRAW); return; }
  if (((int32_t)raw1 - raw0) < 50) { cal_report(CAL_REQ_SPAN, CAL_E_TOOCLOSE); return; }

  k = ((int64_t)1000.0f * 1000) / ((int64_t)raw1 - (int64_t)raw0);
  b = -((int64_t)raw0 * k) / 1000;
  e = CAL_E_OK;
  if (k < 100) { k = 100; e = CAL_E_KCLAMP; }
  if (k > 10000) { k = 10000; e = CAL_E_KCLAMP; }

  g_param.cal_k = (int32_t)k;
  g_param.cal_b = (int32_t)b;
  g_param.cal_ts = rtc_wall_seconds();
  g_param.cal_valid = 1;
  param_save_safe();
  sensor_set_cal(g_param.cal_k, g_param.cal_b);
  cal_report(CAL_REQ_SPAN, e);
}





static void cal_do_zero_hw(void)
{
  uint8_t e = cal_precheck();
  float ppm, dt;

  if (e) { g_cal0_armed = 0; g_cal0_owner = CAL_REQ_NONE; cal_report(CAL_REQ_ZW, e); return; }
  ppm = sensor_read_ppm();
  if (ppm >= (float)50) { g_cal0_armed = 0; g_cal0_owner = CAL_REQ_NONE; cal_report(CAL_REQ_ZW, CAL_E_DIRTY); return; }


  if ((g_cal0_armed && (g_cal0_owner == (CAL_REQ_ZW))) && (HAL_GetTick() - g_cal0_t0) <= 3000u) {
    dt = ppm - g_cal0_ppm0;
    if (dt < 0.0f) dt = -dt;
    if (dt > 3.0f) { g_cal0_armed = 0; g_cal0_owner = CAL_REQ_NONE; cal_report(CAL_REQ_ZW, CAL_E_CHANGED); return; }
    g_cal0_armed = 0;
  } else {

    if (g_cal0_armed) g_cal0_armed = 0;
    g_cal0_armed = 1; g_cal0_owner = CAL_REQ_ZW;
    g_cal0_t0 = HAL_GetTick(); g_cal0_ppm0 = ppm;
    cal_report(CAL_REQ_ZW, CAL_E_CONFIRM);
    return;
  }

  sensor_send_cmd(SENSOR_CMD_ZERO_HW, 6);
  cal_report(CAL_REQ_ZW, CAL_E_SENT);
}



static void cal_do_lo15(void)
{
  uint8_t e = cal_precheck();
  float ppm, dt;

  if (e) { g_cal0_armed = 0; g_cal0_owner = CAL_REQ_NONE; cal_report(CAL_REQ_LO15, e); return; }
  ppm = sensor_read_ppm();

  if ((g_cal0_armed && (g_cal0_owner == (CAL_REQ_LO15))) && (HAL_GetTick() - g_cal0_t0) <= 3000u) {
    dt = ppm - g_cal0_ppm0;
    if (dt < 0.0f) dt = -dt;
    if (dt > 3.0f) { g_cal0_armed = 0; g_cal0_owner = CAL_REQ_NONE; cal_report(CAL_REQ_LO15, CAL_E_CHANGED); return; }
    g_cal0_armed = 0;
  } else {

    if (g_cal0_armed) g_cal0_armed = 0;
    g_cal0_armed = 1; g_cal0_owner = CAL_REQ_LO15;
    g_cal0_t0 = HAL_GetTick(); g_cal0_ppm0 = ppm;
    cal_report(CAL_REQ_LO15, CAL_E_CONFIRM);
    return;
  }

  sensor_send_cmd(SENSOR_CMD_LO15_A, 11);
  HAL_Delay(50);
  sensor_send_cmd(SENSOR_CMD_LO15_B, 11);
  cal_report(CAL_REQ_LO15, CAL_E_SENT);
}


static void cal_do_factory(void)
{
  g_cal0_armed = 0; g_cal0_owner = CAL_REQ_NONE;
  if (!g_selftest.flash_ok) { cal_report(CAL_REQ_FAC, CAL_E_FLASH); return; }
  param_factory(&g_param, 1);
  g_thr_hi = g_param.thr_hi; g_thr_lo = g_param.thr_lo;
  sensor_set_cal(g_param.cal_k, g_param.cal_b);
  app_apply_threshold();
  cal_report(CAL_REQ_FAC, CAL_E_OK);
  HAL_Delay(200);
  __NVIC_SystemReset();
}


static void cal_poll(void)
{
  uint8_t r = g_cal_req;

  if (g_cal_st_dirty) { g_cal_st_dirty = 0; cal_upload_status(); }
  if (!r) return;
  g_cal_req = CAL_REQ_NONE;
  if (r == CAL_REQ_ZERO) cal_do_zero();
  else if (r == CAL_REQ_SPAN) cal_do_span();
  else if (r == CAL_REQ_FAC) cal_do_factory();
  else if (r == CAL_REQ_ZW) cal_do_zero_hw();
  else if (r == CAL_REQ_LO15) cal_do_lo15();
}


static void hist_clear_poll(void)
{
  if (!g_hist_clear_req) return;
  g_hist_clear_req = 0;
  if (g_selftest.flash_ok) {
    history_clear();
# 1396 "../Core/Src/main.c"
    g_param.hist_base = history_get_base();
  }
  if (!g_page_init) { g_tbl_page = 1; refill_table(); }
}


void hmi_on_cal_zero(void) { g_cal_req = CAL_REQ_ZERO; }

void hmi_on_sensor_zero_hw(void) { g_cal_req = CAL_REQ_ZW; }
void hmi_on_sensor_lo15(void) { g_cal_req = CAL_REQ_LO15; }
void hmi_on_cal_span(void) { g_cal_req = CAL_REQ_SPAN; }
void hmi_on_cal_factory(void) { g_cal_req = CAL_REQ_FAC; }
void hmi_on_hist_clear(void) { g_hist_clear_req = 1; }



void hmi_on_tbl_page(int delta) {
  uint16_t pc = history_page_count(24u);
  int np = (int)g_tbl_page + delta;
  if (np < 1) np = 1;
  if ((uint16_t)np > pc) np = (int)pc;
  g_tbl_page = (uint16_t)np;
  g_refill_req = 1;
}



uint8_t hmi_get_page(void) {
  return g_page_now;
}

void hmi_on_page_enter(int p) {
# 1437 "../Core/Src/main.c"
  g_page_now = (uint8_t)p;
  g_full_dirty = 1;
  if (p == 1) {
    g_cal_st_dirty = 1;
    g_thr_push = 1;
  }

  if (p == 5) {
    g_cal_st_dirty = 1;
  }

  if (p == 2) {

    g_tbl_page = 1;
    g_refill_req = 1;
  }
}

void hmi_on_test_toggle(void) {

  g_test = !g_test;
  if (g_test) {
    g_test_t0 = HAL_GetTick();
    g_sess_sum = 0; g_sess_cnt = 0;
    g_sess_max = 0; g_sess_min = 0xFFFF;

    g_peak = 0.0f; g_min = 4294967.0f;
  }
  pump_set(g_test);
  g_full_dirty = 1;
}







void Error_Handler(void)
{

  __disable_irq();
  while (1) { }

}
