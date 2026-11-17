	.text
	.syntax unified
	.eabi_attribute	67, "2.09"	@ Tag_conformance
	.cpu	cortex-m3
	.eabi_attribute	6, 10	@ Tag_CPU_arch
	.eabi_attribute	7, 77	@ Tag_CPU_arch_profile
	.eabi_attribute	8, 0	@ Tag_ARM_ISA_use
	.eabi_attribute	9, 2	@ Tag_THUMB_ISA_use
	.eabi_attribute	34, 1	@ Tag_CPU_unaligned_access
	.eabi_attribute	17, 1	@ Tag_ABI_PCS_GOT_use
	.eabi_attribute	20, 2	@ Tag_ABI_FP_denormal
	.eabi_attribute	21, 0	@ Tag_ABI_FP_exceptions
	.eabi_attribute	23, 1	@ Tag_ABI_FP_number_model
	.eabi_attribute	24, 1	@ Tag_ABI_align_needed
	.eabi_attribute	25, 1	@ Tag_ABI_align_preserved
	.eabi_attribute	38, 1	@ Tag_ABI_FP_16bit_format
	.eabi_attribute	18, 4	@ Tag_ABI_PCS_wchar_t
	.eabi_attribute	26, 2	@ Tag_ABI_enum_size
	.eabi_attribute	14, 0	@ Tag_ABI_PCS_R9_use
	.file	"main.c"
	.section	.text.HAL_UART_RxCpltCallback,"ax",%progbits
	.hidden	HAL_UART_RxCpltCallback         @ -- Begin function HAL_UART_RxCpltCallback
	.globl	HAL_UART_RxCpltCallback
	.p2align	2
	.type	HAL_UART_RxCpltCallback,%function
	.code	16                              @ @HAL_UART_RxCpltCallback
	.thumb_func
HAL_UART_RxCpltCallback:
	.fnstart
	.cfi_sections .debug_frame
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#8
	sub	sp, #8
	.cfi_def_cfa_offset 16
	str	r0, [sp, #4]
	ldr	r0, [sp, #4]
	cbz	r0, .LBB0_3
	b	.LBB0_1
.LBB0_1:
	ldr	r0, [sp, #4]
	ldr	r0, [r0]
	movw	r1, #18432
	movt	r1, #16384
	cmp	r0, r1
	beq	.LBB0_3
	b	.LBB0_2
.LBB0_2:
	b	.LBB0_9
.LBB0_3:
	movw	r0, :lower16:rx_byte
	movt	r0, :upper16:rx_byte
	ldrb	r0, [r0]
	bl	hmi_get_feed
	str	r0, [sp]
	ldr	r0, [sp]
	cmp	r0, #1
	blt	.LBB0_5
	b	.LBB0_4
.LBB0_4:
	bl	hmi_get_response
	b	.LBB0_8
.LBB0_5:
	ldr	r0, [sp]
	cbnz	r0, .LBB0_7
	b	.LBB0_6
.LBB0_6:
	movw	r0, :lower16:rx_byte
	movt	r0, :upper16:rx_byte
	ldrb	r0, [r0]
	bl	hmi_on_rx_byte
	b	.LBB0_7
.LBB0_7:
	b	.LBB0_8
.LBB0_8:
	ldr	r0, [sp, #4]
	movw	r1, :lower16:rx_byte
	movt	r1, :upper16:rx_byte
	movs	r2, #1
	bl	HAL_UART_Receive_IT
	b	.LBB0_9
.LBB0_9:
	add	sp, #8
	pop	{r7, pc}
.Lfunc_end0:
	.size	HAL_UART_RxCpltCallback, .Lfunc_end0-HAL_UART_RxCpltCallback
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_get_response,"ax",%progbits
	.p2align	2                               @ -- Begin function hmi_get_response
	.type	hmi_get_response,%function
	.code	16                              @ @hmi_get_response
	.thumb_func
hmi_get_response:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r4, lr}
	push	{r4, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r4, -8
	.pad	#24
	sub	sp, #24
	.cfi_def_cfa_offset 32
	bl	hmi_get_value
	str	r0, [sp, #20]
	movw	r0, :lower16:g_get_busy
	movt	r0, :upper16:g_get_busy
	ldrb	r0, [r0]
	cbz	r0, .LBB1_2
	b	.LBB1_1
.LBB1_1:
	movw	r1, :lower16:g_get_busy
	movt	r1, :upper16:g_get_busy
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_thr_wait
	movt	r1, :upper16:g_thr_wait
	strb	r0, [r1]
	movw	r1, :lower16:g_thr_hi_req
	movt	r1, :upper16:g_thr_hi_req
	strb	r0, [r1]
	movw	r1, :lower16:g_thr_try
	movt	r1, :upper16:g_thr_try
	strb	r0, [r1]
	ldr	r0, [sp, #20]
	bl	thr_apply_hi_val
	b	.LBB1_23
.LBB1_2:
	movw	r0, :lower16:g_sync_st
	movt	r0, :upper16:g_sync_st
	ldrb	r0, [r0]
	cmp	r0, #1
	bhi	.LBB1_4
	b	.LBB1_3
.LBB1_3:
	movw	r0, :lower16:g_rtc_wait
	movt	r0, :upper16:g_rtc_wait
	ldrb	r0, [r0]
	cbnz	r0, .LBB1_5
	b	.LBB1_4
.LBB1_4:
	b	.LBB1_23
.LBB1_5:
	movw	r0, :lower16:g_sync_st
	movt	r0, :upper16:g_sync_st
	ldrb	r0, [r0]
	cmp	r0, #0
	bne	.LBB1_13
	b	.LBB1_6
.LBB1_6:
	movw	r1, :lower16:g_rtc_wait
	movt	r1, :upper16:g_rtc_wait
	movs	r0, #0
	strb	r0, [r1]
	movw	r0, :lower16:g_time_sync_idx
	movt	r0, :upper16:g_time_sync_idx
	ldrb	r0, [r0]
	cbnz	r0, .LBB1_8
	b	.LBB1_7
.LBB1_7:
	ldr	r0, [sp, #20]
	movw	r1, :lower16:g_sync_sec0
	movt	r1, :upper16:g_sync_sec0
	str	r0, [r1]
	movw	r1, :lower16:g_time_sync_idx
	movt	r1, :upper16:g_time_sync_idx
	movs	r0, #1
	strb	r0, [r1]
	bl	HAL_GetTick
	movw	r1, :lower16:g_sync_t0
	movt	r1, :upper16:g_sync_t0
	str	r0, [r1]
	b	.LBB1_12
.LBB1_8:
	ldr	r0, [sp, #20]
	movw	r1, :lower16:g_sync_sec0
	movt	r1, :upper16:g_sync_sec0
	ldr	r1, [r1]
	cmp	r0, r1
	beq	.LBB1_10
	b	.LBB1_9
.LBB1_9:
	movw	r1, :lower16:g_sync_st
	movt	r1, :upper16:g_sync_st
	movs	r0, #1
	strb	r0, [r1]
	movw	r1, :lower16:g_time_sync_idx
	movt	r1, :upper16:g_time_sync_idx
	movs	r0, #0
	strb	r0, [r1]
	b	.LBB1_11
.LBB1_10:
	ldr	r0, [sp, #20]
	movw	r1, :lower16:g_sync_sec0
	movt	r1, :upper16:g_sync_sec0
	str	r0, [r1]
	bl	HAL_GetTick
	movw	r1, :lower16:g_sync_t0
	movt	r1, :upper16:g_sync_t0
	str	r0, [r1]
	b	.LBB1_11
.LBB1_11:
	b	.LBB1_12
.LBB1_12:
	b	.LBB1_23
.LBB1_13:
	ldr	r0, [sp, #20]
	movw	r2, :lower16:g_time_sync_idx
	movt	r2, :upper16:g_time_sync_idx
	ldrb	r3, [r2]
	movw	r1, :lower16:g_sync_rtc
	movt	r1, :upper16:g_sync_rtc
	str.w	r0, [r1, r3, lsl #2]
	movw	r1, :lower16:g_rtc_wait
	movt	r1, :upper16:g_rtc_wait
	movs	r0, #0
	strb	r0, [r1]
	ldrb	r0, [r2]
	adds	r1, r0, #1
	uxtb	r0, r1
	strb	r1, [r2]
	cmp	r0, #6
	blo	.LBB1_23
	b	.LBB1_14
.LBB1_14:
	movw	r0, :lower16:g_sync_rtc
	movt	r0, :upper16:g_sync_rtc
	ldr	r1, [r0]
	str	r1, [sp, #16]
	ldr	r1, [r0, #4]
	str	r1, [sp, #12]
	ldr	r0, [r0, #8]
	str	r0, [sp, #8]
	ldr	r0, [sp, #16]
	movw	r1, #2020
	cmp	r0, r1
	blo	.LBB1_21
	b	.LBB1_15
.LBB1_15:
	ldr	r0, [sp, #16]
	movw	r1, #2099
	cmp	r0, r1
	bhi	.LBB1_21
	b	.LBB1_16
.LBB1_16:
	ldr	r0, [sp, #12]
	cbz	r0, .LBB1_21
	b	.LBB1_17
.LBB1_17:
	ldr	r0, [sp, #12]
	cmp	r0, #12
	bhi	.LBB1_21
	b	.LBB1_18
.LBB1_18:
	ldr	r0, [sp, #8]
	cbz	r0, .LBB1_21
	b	.LBB1_19
.LBB1_19:
	ldr	r0, [sp, #8]
	cmp	r0, #31
	bhi	.LBB1_21
	b	.LBB1_20
.LBB1_20:
	ldr	r0, [sp, #16]
	ldr	r1, [sp, #12]
	ldr	r2, [sp, #8]
	movw	lr, :lower16:g_sync_rtc
	movt	lr, :upper16:g_sync_rtc
	ldr.w	r3, [lr, #12]
	ldr.w	r12, [lr, #16]
	ldr.w	r4, [lr, #20]
	mov	lr, sp
	str.w	r4, [lr, #4]
	str.w	r12, [lr]
	bl	rtc_to_epoch
	movw	r1, :lower16:g_wall_epoch
	movt	r1, :upper16:g_wall_epoch
	str	r0, [r1]
	bl	HAL_GetTick
	movw	r1, :lower16:g_wall_tick
	movt	r1, :upper16:g_wall_tick
	str	r0, [r1]
	movw	r1, :lower16:g_sync_st
	movt	r1, :upper16:g_sync_st
	movs	r0, #2
	strb	r0, [r1]
	b	.LBB1_22
.LBB1_21:
	movw	r1, :lower16:g_sync_st
	movt	r1, :upper16:g_sync_st
	movs	r0, #1
	strb	r0, [r1]
	movw	r1, :lower16:g_time_sync_idx
	movt	r1, :upper16:g_time_sync_idx
	movs	r0, #0
	strb	r0, [r1]
	b	.LBB1_22
.LBB1_22:
	b	.LBB1_23
.LBB1_23:
	add	sp, #24
	pop	{r4, pc}
.Lfunc_end1:
	.size	hmi_get_response, .Lfunc_end1-hmi_get_response
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.HAL_UART_ErrorCallback,"ax",%progbits
	.hidden	HAL_UART_ErrorCallback          @ -- Begin function HAL_UART_ErrorCallback
	.globl	HAL_UART_ErrorCallback
	.p2align	2
	.type	HAL_UART_ErrorCallback,%function
	.code	16                              @ @HAL_UART_ErrorCallback
	.thumb_func
HAL_UART_ErrorCallback:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#8
	sub	sp, #8
	.cfi_def_cfa_offset 16
	str	r0, [sp, #4]
	ldr	r0, [sp, #4]
	cbz	r0, .LBB2_2
	b	.LBB2_1
.LBB2_1:
	ldr	r0, [sp, #4]
	ldr	r0, [r0]
	movw	r1, #18432
	movt	r1, #16384
	cmp	r0, r1
	beq	.LBB2_3
	b	.LBB2_2
.LBB2_2:
	b	.LBB2_7
.LBB2_3:
	b	.LBB2_4
.LBB2_4:
	movs	r0, #0
	str	r0, [sp]
	ldr	r0, [sp, #4]
	ldr	r0, [r0]
	ldr	r0, [r0]
	str	r0, [sp]
	ldr	r0, [sp, #4]
	ldr	r0, [r0]
	ldr	r0, [r0, #4]
	str	r0, [sp]
	ldr	r0, [sp]
	b	.LBB2_5
.LBB2_5:
	bl	hmi_get_reset
	ldr	r0, [sp, #4]
	movw	r1, :lower16:rx_byte
	movt	r1, :upper16:rx_byte
	movs	r2, #1
	bl	HAL_UART_Receive_IT
	cbz	r0, .LBB2_7
	b	.LBB2_6
.LBB2_6:
	movw	r1, :lower16:g_rx_reattach_fail
	movt	r1, :upper16:g_rx_reattach_fail
	movs	r0, #1
	strb	r0, [r1]
	b	.LBB2_7
.LBB2_7:
	add	sp, #8
	pop	{r7, pc}
.Lfunc_end2:
	.size	HAL_UART_ErrorCallback, .Lfunc_end2-HAL_UART_ErrorCallback
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.rtc_wall_seconds,"ax",%progbits
	.hidden	rtc_wall_seconds                @ -- Begin function rtc_wall_seconds
	.globl	rtc_wall_seconds
	.p2align	2
	.type	rtc_wall_seconds,%function
	.code	16                              @ @rtc_wall_seconds
	.thumb_func
rtc_wall_seconds:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#8
	sub	sp, #8
	.cfi_def_cfa_offset 16
	movw	r0, :lower16:g_wall_epoch
	movt	r0, :upper16:g_wall_epoch
	ldr	r0, [r0]
	str	r0, [sp, #4]                    @ 4-byte Spill
	bl	HAL_GetTick
	mov	r1, r0
	ldr	r0, [sp, #4]                    @ 4-byte Reload
	movw	r2, :lower16:g_wall_tick
	movt	r2, :upper16:g_wall_tick
	ldr	r2, [r2]
	subs	r1, r1, r2
	movw	r2, #19923
	movt	r2, #4194
	umull	r2, r1, r1, r2
	add.w	r0, r0, r1, lsr #6
	add	sp, #8
	pop	{r7, pc}
.Lfunc_end3:
	.size	rtc_wall_seconds, .Lfunc_end3-rtc_wall_seconds
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.main,"ax",%progbits
	.hidden	main                            @ -- Begin function main
	.globl	main
	.p2align	2
	.type	main,%function
	.code	16                              @ @main
	.thumb_func
main:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#16
	sub	sp, #16
	.cfi_def_cfa_offset 24
	movs	r0, #0
	str	r0, [sp, #12]
	bl	HAL_Init
	bl	SystemClock_Config
	bl	MX_GPIO_Init
	bl	MX_USART1_UART_Init
	bl	MX_USART3_UART_Init
	bl	MX_SPI1_Init
	bl	MX_ADC1_Init
	bl	sensor_init
	bl	HAL_GetTick
	movw	r1, :lower16:s_devtest_t0
	movt	r1, :upper16:s_devtest_t0
	str	r0, [r1]
	bl	battery_init
	bl	battery_poll
	bl	pump_init
	bl	w25q16_init
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	str	r0, [sp]                        @ 4-byte Spill
	bl	param_init
	bl	history_init
	bl	device_id_init
	ldr	r1, [sp]                        @ 4-byte Reload
	ldrh	r0, [r1, #28]
	movw	r2, :lower16:g_thr_hi
	movt	r2, :upper16:g_thr_hi
	str	r0, [r2]
	ldrh	r0, [r1, #30]
	movw	r2, :lower16:g_thr_lo
	movt	r2, :upper16:g_thr_lo
	str	r0, [r2]
	ldr	r0, [r1, #8]
	ldr	r1, [r1, #12]
	bl	sensor_set_cal
	movw	r0, :lower16:g_selftest
	movt	r0, :upper16:g_selftest
	bl	selftest_run
	movw	r0, :lower16:huart3
	movt	r0, :upper16:huart3
	movw	r1, :lower16:rx_byte
	movt	r1, :upper16:rx_byte
	movs	r2, #1
	bl	HAL_UART_Receive_IT
	movs	r0, #3
	str	r0, [sp, #4]                    @ 4-byte Spill
	bl	tjc_page
	movw	r0, #1500
	bl	HAL_Delay
	ldr	r0, [sp, #4]                    @ 4-byte Reload
	bl	tjc_page
	mov.w	r0, #1000
	bl	HAL_Delay
	ldr	r0, [sp, #4]                    @ 4-byte Reload
	bl	tjc_page
	bl	app_apply_threshold
	bl	rtc_time_start_sync
	bl	HAL_GetTick
	movw	r1, :lower16:g_boot_ms
	movt	r1, :upper16:g_boot_ms
	str	r0, [r1]
	bl	iwdg_hw_start
	bl	iwdg_enable
	bl	iwdg_feed
	b	.LBB4_1
.LBB4_1:                                @ =>This Inner Loop Header: Depth=1
	movw	r0, :lower16:s_devtest
	movt	r0, :upper16:s_devtest
	ldrb	r0, [r0]
	cmp	r0, #3
	bhi.w	.LBB4_20
	b	.LBB4_2
.LBB4_2:                                @   in Loop: Header=BB4_1 Depth=1
	bl	HAL_GetTick
	movw	r1, :lower16:s_devtest_t0
	movt	r1, :upper16:s_devtest_t0
	ldr	r1, [r1]
	subs	r0, r0, r1
	str	r0, [sp, #8]
	movw	r0, :lower16:s_devtest
	movt	r0, :upper16:s_devtest
	ldrb	r0, [r0]
	cbnz	r0, .LBB4_6
	b	.LBB4_3
.LBB4_3:                                @   in Loop: Header=BB4_1 Depth=1
	ldr	r0, [sp, #8]
	movw	r1, #3001
	cmp	r0, r1
	blo	.LBB4_5
	b	.LBB4_4
.LBB4_4:                                @   in Loop: Header=BB4_1 Depth=1
	movw	r1, :lower16:s_devtest
	movt	r1, :upper16:s_devtest
	movs	r0, #1
	strb	r0, [r1]
	bl	HAL_GetTick
	movw	r1, :lower16:s_devtest_t0
	movt	r1, :upper16:s_devtest_t0
	str	r0, [r1]
	b	.LBB4_5
.LBB4_5:                                @   in Loop: Header=BB4_1 Depth=1
	b	.LBB4_19
.LBB4_6:                                @   in Loop: Header=BB4_1 Depth=1
	movw	r0, :lower16:s_devtest
	movt	r0, :upper16:s_devtest
	ldrb	r0, [r0]
	cmp	r0, #1
	bne	.LBB4_8
	b	.LBB4_7
.LBB4_7:                                @   in Loop: Header=BB4_1 Depth=1
	movw	r0, :lower16:.L.str
	movt	r0, :upper16:.L.str
	bl	devtest_ppm
	movw	r0, :lower16:SENSOR_CMD_LO15_A
	movt	r0, :upper16:SENSOR_CMD_LO15_A
	movs	r1, #11
	bl	sensor_send_cmd
	movw	r1, :lower16:s_devtest
	movt	r1, :upper16:s_devtest
	movs	r0, #2
	strb	r0, [r1]
	bl	HAL_GetTick
	movw	r1, :lower16:s_devtest_t0
	movt	r1, :upper16:s_devtest_t0
	str	r0, [r1]
	b	.LBB4_18
.LBB4_8:                                @   in Loop: Header=BB4_1 Depth=1
	movw	r0, :lower16:s_devtest
	movt	r0, :upper16:s_devtest
	ldrb	r0, [r0]
	cmp	r0, #2
	bne	.LBB4_12
	b	.LBB4_9
.LBB4_9:                                @   in Loop: Header=BB4_1 Depth=1
	ldr	r0, [sp, #8]
	cmp.w	r0, #500
	bls	.LBB4_11
	b	.LBB4_10
.LBB4_10:                               @   in Loop: Header=BB4_1 Depth=1
	movw	r0, :lower16:.L.str.1
	movt	r0, :upper16:.L.str.1
	bl	devtest_ppm
	movw	r1, :lower16:s_devtest
	movt	r1, :upper16:s_devtest
	movs	r0, #3
	strb	r0, [r1]
	bl	HAL_GetTick
	movw	r1, :lower16:s_devtest_t0
	movt	r1, :upper16:s_devtest_t0
	str	r0, [r1]
	b	.LBB4_11
.LBB4_11:                               @   in Loop: Header=BB4_1 Depth=1
	b	.LBB4_17
.LBB4_12:                               @   in Loop: Header=BB4_1 Depth=1
	movw	r0, :lower16:s_devtest
	movt	r0, :upper16:s_devtest
	ldrb	r0, [r0]
	cmp	r0, #3
	bne	.LBB4_16
	b	.LBB4_13
.LBB4_13:                               @   in Loop: Header=BB4_1 Depth=1
	ldr	r0, [sp, #8]
	cmp.w	r0, #500
	bls	.LBB4_15
	b	.LBB4_14
.LBB4_14:                               @   in Loop: Header=BB4_1 Depth=1
	movw	r0, :lower16:SENSOR_CMD_LO15_B
	movt	r0, :upper16:SENSOR_CMD_LO15_B
	movs	r1, #11
	bl	sensor_send_cmd
	movw	r1, :lower16:s_devtest
	movt	r1, :upper16:s_devtest
	movs	r0, #4
	strb	r0, [r1]
	bl	HAL_GetTick
	movw	r1, :lower16:s_devtest_t0
	movt	r1, :upper16:s_devtest_t0
	str	r0, [r1]
	movw	r0, :lower16:.L.str.2
	movt	r0, :upper16:.L.str.2
	bl	devtest_ppm
	b	.LBB4_15
.LBB4_15:                               @   in Loop: Header=BB4_1 Depth=1
	b	.LBB4_16
.LBB4_16:                               @   in Loop: Header=BB4_1 Depth=1
	b	.LBB4_17
.LBB4_17:                               @   in Loop: Header=BB4_1 Depth=1
	b	.LBB4_18
.LBB4_18:                               @   in Loop: Header=BB4_1 Depth=1
	b	.LBB4_19
.LBB4_19:                               @   in Loop: Header=BB4_1 Depth=1
	b	.LBB4_20
.LBB4_20:                               @   in Loop: Header=BB4_1 Depth=1
	bl	iwdg_feed
	movw	r0, :lower16:g_thr_dirty
	movt	r0, :upper16:g_thr_dirty
	ldrb	r0, [r0]
	cbnz	r0, .LBB4_22
	b	.LBB4_21
.LBB4_21:                               @   in Loop: Header=BB4_1 Depth=1
	movw	r0, :lower16:g_thr_push
	movt	r0, :upper16:g_thr_push
	ldrb	r0, [r0]
	cbz	r0, .LBB4_23
	b	.LBB4_22
.LBB4_22:                               @   in Loop: Header=BB4_1 Depth=1
	movw	r1, :lower16:g_thr_dirty
	movt	r1, :upper16:g_thr_dirty
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_thr_push
	movt	r1, :upper16:g_thr_push
	strb	r0, [r1]
	bl	app_apply_threshold
	b	.LBB4_23
.LBB4_23:                               @   in Loop: Header=BB4_1 Depth=1
	movw	r0, :lower16:g_save_pending
	movt	r0, :upper16:g_save_pending
	ldrb	r0, [r0]
	cbz	r0, .LBB4_26
	b	.LBB4_24
.LBB4_24:                               @   in Loop: Header=BB4_1 Depth=1
	bl	HAL_GetTick
	movw	r1, :lower16:g_thr_dirty_t
	movt	r1, :upper16:g_thr_dirty_t
	ldr	r1, [r1]
	subs	r0, r0, r1
	cmp	r0, #200
	blo	.LBB4_26
	b	.LBB4_25
.LBB4_25:                               @   in Loop: Header=BB4_1 Depth=1
	movw	r1, :lower16:g_save_pending
	movt	r1, :upper16:g_save_pending
	movs	r0, #0
	strb	r0, [r1]
	bl	param_save_safe
	b	.LBB4_26
.LBB4_26:                               @   in Loop: Header=BB4_1 Depth=1
	bl	cal_poll
	bl	hist_clear_poll
	bl	hmi_update_init_countdown
	bl	hmi_update_selftest
	bl	low_batt_poll
	bl	app_refresh
	movs	r0, #250
	bl	HAL_Delay
	b	.LBB4_1
.Lfunc_end4:
	.size	main, .Lfunc_end4-main
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.SystemClock_Config,"ax",%progbits
	.hidden	SystemClock_Config              @ -- Begin function SystemClock_Config
	.globl	SystemClock_Config
	.p2align	2
	.type	SystemClock_Config,%function
	.code	16                              @ @SystemClock_Config
	.thumb_func
SystemClock_Config:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#64
	sub	sp, #64
	.cfi_def_cfa_offset 72
	add	r0, sp, #24
	str	r0, [sp]                        @ 4-byte Spill
	movs	r1, #40
	bl	__aeabi_memclr4
	ldr	r0, [sp]                        @ 4-byte Reload
	movs	r3, #0
	str	r3, [sp, #20]
	str	r3, [sp, #16]
	str	r3, [sp, #12]
	str	r3, [sp, #8]
	str	r3, [sp, #4]
	movs	r2, #1
	str	r2, [sp, #24]
	mov.w	r1, #65536
	str	r1, [sp, #28]
	str	r3, [sp, #32]
	str	r2, [sp, #40]
	movs	r2, #2
	str	r2, [sp, #52]
	str	r1, [sp, #56]
	mov.w	r1, #1835008
	str	r1, [sp, #60]
	bl	HAL_RCC_OscConfig
	cbz	r0, .LBB5_2
	b	.LBB5_1
.LBB5_1:
	bl	Error_Handler
	b	.LBB5_2
.LBB5_2:
	movs	r0, #15
	str	r0, [sp, #4]
	movs	r1, #2
	str	r1, [sp, #8]
	movs	r0, #0
	str	r0, [sp, #12]
	mov.w	r2, #1024
	str	r2, [sp, #16]
	str	r0, [sp, #20]
	add	r0, sp, #4
	bl	HAL_RCC_ClockConfig
	cbz	r0, .LBB5_4
	b	.LBB5_3
.LBB5_3:
	bl	Error_Handler
	b	.LBB5_4
.LBB5_4:
	add	sp, #64
	pop	{r7, pc}
.Lfunc_end5:
	.size	SystemClock_Config, .Lfunc_end5-SystemClock_Config
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.app_apply_threshold,"ax",%progbits
	.p2align	2                               @ -- Begin function app_apply_threshold
	.type	app_apply_threshold,%function
	.code	16                              @ @app_apply_threshold
	.thumb_func
app_apply_threshold:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#8
	sub	sp, #8
	.cfi_def_cfa_offset 16
	movw	r1, :lower16:g_param
	movt	r1, :upper16:g_param
	ldrh	r2, [r1, #28]
	movw	r0, :lower16:g_thr_hi
	movt	r0, :upper16:g_thr_hi
	str	r0, [sp, #4]                    @ 4-byte Spill
	str	r2, [r0]
	ldrh	r1, [r1, #30]
	movw	r2, :lower16:g_thr_lo
	movt	r2, :upper16:g_thr_lo
	str	r1, [r2]
	ldr	r1, [r0]
	movw	r0, :lower16:.L.str.3
	movt	r0, :upper16:.L.str.3
	bl	tjc_set_val
	ldr	r0, [sp, #4]                    @ 4-byte Reload
	ldr	r1, [r0]
	movw	r0, :lower16:.L.str.4
	movt	r0, :upper16:.L.str.4
	bl	tjc_set_var
	add	sp, #8
	pop	{r7, pc}
.Lfunc_end6:
	.size	app_apply_threshold, .Lfunc_end6-app_apply_threshold
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.rtc_time_start_sync,"ax",%progbits
	.p2align	2                               @ -- Begin function rtc_time_start_sync
	.type	rtc_time_start_sync,%function
	.code	16                              @ @rtc_time_start_sync
	.thumb_func
rtc_time_start_sync:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	movw	r1, :lower16:g_sync_st
	movt	r1, :upper16:g_sync_st
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_time_sync_idx
	movt	r1, :upper16:g_time_sync_idx
	strb	r0, [r1]
	movw	r1, :lower16:g_rtc_wait
	movt	r1, :upper16:g_rtc_wait
	strb	r0, [r1]
	movw	r1, :lower16:g_sync_sec0
	movt	r1, :upper16:g_sync_sec0
	mov.w	r0, #-1
	str	r0, [r1]
	bl	HAL_GetTick
	movw	r1, :lower16:g_sync_t0
	movt	r1, :upper16:g_sync_t0
	str	r0, [r1]
	pop	{r7, pc}
.Lfunc_end7:
	.size	rtc_time_start_sync, .Lfunc_end7-rtc_time_start_sync
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.iwdg_hw_start,"ax",%progbits
	.p2align	2                               @ -- Begin function iwdg_hw_start
	.type	iwdg_hw_start,%function
	.code	16                              @ @iwdg_hw_start
	.thumb_func
iwdg_hw_start:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#48
	sub	sp, #48
	.cfi_def_cfa_offset 56
	add	r0, sp, #8
	str	r0, [sp, #4]                    @ 4-byte Spill
	movs	r1, #40
	bl	__aeabi_memclr4
	ldr	r0, [sp, #4]                    @ 4-byte Reload
	movs	r1, #8
	str	r1, [sp, #8]
	movs	r1, #1
	str	r1, [sp, #32]
	movs	r1, #0
	str	r1, [sp, #36]
	bl	HAL_RCC_OscConfig
	movw	r0, :lower16:hiwdg
	movt	r0, :upper16:hiwdg
	movw	r1, #12288
	movt	r1, #16384
	str	r1, [r0]
	movs	r1, #32
	str	r1, [r0, #4]
	mov.w	r1, #4000
	str	r1, [r0, #8]
	bl	HAL_IWDG_Init
	add	sp, #48
	pop	{r7, pc}
.Lfunc_end8:
	.size	iwdg_hw_start, .Lfunc_end8-iwdg_hw_start
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.iwdg_enable,"ax",%progbits
	.p2align	2                               @ -- Begin function iwdg_enable
	.type	iwdg_enable,%function
	.code	16                              @ @iwdg_enable
	.thumb_func
iwdg_enable:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	movw	r1, :lower16:g_iwdg_on
	movt	r1, :upper16:g_iwdg_on
	movs	r0, #1
	strb	r0, [r1]
	bl	HAL_GetTick
	movw	r1, :lower16:g_iwdg_t
	movt	r1, :upper16:g_iwdg_t
	str	r0, [r1]
	pop	{r7, pc}
.Lfunc_end9:
	.size	iwdg_enable, .Lfunc_end9-iwdg_enable
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.iwdg_feed,"ax",%progbits
	.p2align	2                               @ -- Begin function iwdg_feed
	.type	iwdg_feed,%function
	.code	16                              @ @iwdg_feed
	.thumb_func
iwdg_feed:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	movw	r0, :lower16:g_iwdg_on
	movt	r0, :upper16:g_iwdg_on
	ldrb	r0, [r0]
	cbz	r0, .LBB10_3
	b	.LBB10_1
.LBB10_1:
	bl	HAL_GetTick
	movw	r1, :lower16:g_iwdg_t
	movt	r1, :upper16:g_iwdg_t
	ldr	r1, [r1]
	subs	r0, r0, r1
	cmp.w	r0, #4000
	bls	.LBB10_3
	b	.LBB10_2
.LBB10_2:
	bl	__NVIC_SystemReset
.LBB10_3:
	bl	HAL_GetTick
	movw	r1, :lower16:g_iwdg_t
	movt	r1, :upper16:g_iwdg_t
	str	r0, [r1]
	movw	r0, :lower16:hiwdg
	movt	r0, :upper16:hiwdg
	bl	HAL_IWDG_Refresh
	pop	{r7, pc}
.Lfunc_end10:
	.size	iwdg_feed, .Lfunc_end10-iwdg_feed
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.devtest_ppm,"ax",%progbits
	.p2align	2                               @ -- Begin function devtest_ppm
	.type	devtest_ppm,%function
	.code	16                              @ @devtest_ppm
	.thumb_func
devtest_ppm:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#72
	sub	sp, #72
	.cfi_def_cfa_offset 80
	str	r0, [sp, #68]
	bl	sensor_read_raw
	mov.w	r1, #1056964608
	bl	__aeabi_fadd
	bl	__aeabi_f2iz
	str	r0, [sp, #16]
	movs	r0, #0
	str	r0, [sp, #12]
	ldr	r0, [sp, #68]
	str	r0, [sp, #8]
	b	.LBB11_1
.LBB11_1:                               @ =>This Inner Loop Header: Depth=1
	ldr	r0, [sp, #8]
	ldrb	r1, [r0]
	movs	r0, #0
	str	r0, [sp, #4]                    @ 4-byte Spill
	cbz	r1, .LBB11_3
	b	.LBB11_2
.LBB11_2:                               @   in Loop: Header=BB11_1 Depth=1
	ldr	r1, [sp, #12]
	movs	r0, #0
	cmp	r1, #20
	it	lt
	movlt	r0, #1
	str	r0, [sp, #4]                    @ 4-byte Spill
	b	.LBB11_3
.LBB11_3:                               @   in Loop: Header=BB11_1 Depth=1
	ldr	r0, [sp, #4]                    @ 4-byte Reload
	lsls	r0, r0, #31
	cbz	r0, .LBB11_5
	b	.LBB11_4
.LBB11_4:                               @   in Loop: Header=BB11_1 Depth=1
	ldr	r0, [sp, #8]
	adds	r1, r0, #1
	str	r1, [sp, #8]
	ldrb	r0, [r0]
	ldr	r2, [sp, #12]
	adds	r1, r2, #1
	str	r1, [sp, #12]
	add	r1, sp, #20
	strb	r0, [r1, r2]
	b	.LBB11_1
.LBB11_5:
	ldr	r0, [sp, #16]
	movw	r1, #34079
	movt	r1, #20971
	smull	r0, r1, r0, r1
	lsrs	r0, r1, #5
	add.w	r0, r0, r1, lsr #31
	adds	r0, #48
	ldr	r2, [sp, #12]
	adds	r1, r2, #1
	str	r1, [sp, #12]
	add	r1, sp, #20
	strb	r0, [r1, r2]
	ldr	r0, [sp, #16]
	movw	r2, #26215
	movt	r2, #26214
	smull	r0, r3, r0, r2
	asrs	r0, r3, #2
	add.w	r0, r0, r3, lsr #31
	smull	r3, r12, r0, r2
	asr.w	r3, r12, #2
	add.w	r3, r3, r12, lsr #31
	add.w	r3, r3, r3, lsl #2
	sub.w	r0, r0, r3, lsl #1
	adds	r0, #48
	ldr	r3, [sp, #12]
	add.w	r12, r3, #1
	str.w	r12, [sp, #12]
	strb	r0, [r1, r3]
	ldr	r0, [sp, #16]
	smull	r2, r3, r0, r2
	asrs	r2, r3, #2
	add.w	r2, r2, r3, lsr #31
	add.w	r2, r2, r2, lsl #2
	sub.w	r0, r0, r2, lsl #1
	adds	r0, #48
	ldr	r2, [sp, #12]
	adds	r3, r2, #1
	str	r3, [sp, #12]
	strb	r0, [r1, r2]
	ldr	r2, [sp, #12]
	adds	r0, r2, #1
	str	r0, [sp, #12]
	movs	r0, #13
	strb	r0, [r1, r2]
	ldr	r2, [sp, #12]
	adds	r0, r2, #1
	str	r0, [sp, #12]
	movs	r0, #10
	strb	r0, [r1, r2]
	ldr	r2, [sp, #12]
	movs	r0, #0
	strb	r0, [r1, r2]
	ldrh.w	r2, [sp, #12]
	movw	r0, :lower16:huart1
	movt	r0, :upper16:huart1
	movs	r3, #50
	bl	HAL_UART_Transmit
	add	sp, #72
	pop	{r7, pc}
.Lfunc_end11:
	.size	devtest_ppm, .Lfunc_end11-devtest_ppm
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.param_save_safe,"ax",%progbits
	.p2align	2                               @ -- Begin function param_save_safe
	.type	param_save_safe,%function
	.code	16                              @ @param_save_safe
	.thumb_func
param_save_safe:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	movw	r0, :lower16:g_selftest
	movt	r0, :upper16:g_selftest
	ldrb	r0, [r0]
	cbnz	r0, .LBB12_2
	b	.LBB12_1
.LBB12_1:
	b	.LBB12_3
.LBB12_2:
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	bl	param_save
	b	.LBB12_3
.LBB12_3:
	pop	{r7, pc}
.Lfunc_end12:
	.size	param_save_safe, .Lfunc_end12-param_save_safe
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.cal_poll,"ax",%progbits
	.p2align	2                               @ -- Begin function cal_poll
	.type	cal_poll,%function
	.code	16                              @ @cal_poll
	.thumb_func
cal_poll:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#8
	sub	sp, #8
	.cfi_def_cfa_offset 16
	movw	r0, :lower16:g_cal_req
	movt	r0, :upper16:g_cal_req
	ldrb	r0, [r0]
	strb.w	r0, [sp, #7]
	movw	r0, :lower16:g_cal_st_dirty
	movt	r0, :upper16:g_cal_st_dirty
	ldrb	r0, [r0]
	cbz	r0, .LBB13_2
	b	.LBB13_1
.LBB13_1:
	movw	r1, :lower16:g_cal_st_dirty
	movt	r1, :upper16:g_cal_st_dirty
	movs	r0, #0
	strb	r0, [r1]
	bl	cal_upload_status
	b	.LBB13_2
.LBB13_2:
	ldrb.w	r0, [sp, #7]
	cbnz	r0, .LBB13_4
	b	.LBB13_3
.LBB13_3:
	b	.LBB13_18
.LBB13_4:
	movw	r1, :lower16:g_cal_req
	movt	r1, :upper16:g_cal_req
	movs	r0, #0
	strb	r0, [r1]
	ldrb.w	r0, [sp, #7]
	cmp	r0, #1
	bne	.LBB13_6
	b	.LBB13_5
.LBB13_5:
	bl	cal_do_zero
	b	.LBB13_18
.LBB13_6:
	ldrb.w	r0, [sp, #7]
	cmp	r0, #2
	bne	.LBB13_8
	b	.LBB13_7
.LBB13_7:
	bl	cal_do_span
	b	.LBB13_17
.LBB13_8:
	ldrb.w	r0, [sp, #7]
	cmp	r0, #3
	bne	.LBB13_10
	b	.LBB13_9
.LBB13_9:
	bl	cal_do_factory
	b	.LBB13_16
.LBB13_10:
	ldrb.w	r0, [sp, #7]
	cmp	r0, #4
	bne	.LBB13_12
	b	.LBB13_11
.LBB13_11:
	bl	cal_do_zero_hw
	b	.LBB13_15
.LBB13_12:
	ldrb.w	r0, [sp, #7]
	cmp	r0, #5
	bne	.LBB13_14
	b	.LBB13_13
.LBB13_13:
	bl	cal_do_lo15
	b	.LBB13_14
.LBB13_14:
	b	.LBB13_15
.LBB13_15:
	b	.LBB13_16
.LBB13_16:
	b	.LBB13_17
.LBB13_17:
	b	.LBB13_18
.LBB13_18:
	add	sp, #8
	pop	{r7, pc}
.Lfunc_end13:
	.size	cal_poll, .Lfunc_end13-cal_poll
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hist_clear_poll,"ax",%progbits
	.p2align	2                               @ -- Begin function hist_clear_poll
	.type	hist_clear_poll,%function
	.code	16                              @ @hist_clear_poll
	.thumb_func
hist_clear_poll:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	movw	r0, :lower16:g_hist_clear_req
	movt	r0, :upper16:g_hist_clear_req
	ldrb	r0, [r0]
	cbnz	r0, .LBB14_2
	b	.LBB14_1
.LBB14_1:
	b	.LBB14_6
.LBB14_2:
	movw	r1, :lower16:g_hist_clear_req
	movt	r1, :upper16:g_hist_clear_req
	movs	r0, #0
	strb	r0, [r1]
	movw	r0, :lower16:g_selftest
	movt	r0, :upper16:g_selftest
	ldrb	r0, [r0]
	cbz	r0, .LBB14_4
	b	.LBB14_3
.LBB14_3:
	bl	history_clear
	bl	history_get_base
	movw	r1, :lower16:g_param
	movt	r1, :upper16:g_param
	str	r0, [r1, #24]
	b	.LBB14_4
.LBB14_4:
	movw	r0, :lower16:g_page_init
	movt	r0, :upper16:g_page_init
	ldrb	r0, [r0]
	cbnz	r0, .LBB14_6
	b	.LBB14_5
.LBB14_5:
	movw	r1, :lower16:g_tbl_page
	movt	r1, :upper16:g_tbl_page
	movs	r0, #1
	strh	r0, [r1]
	bl	refill_table
	b	.LBB14_6
.LBB14_6:
	pop	{r7, pc}
.Lfunc_end14:
	.size	hist_clear_poll, .Lfunc_end14-hist_clear_poll
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_update_init_countdown,"ax",%progbits
	.p2align	2                               @ -- Begin function hmi_update_init_countdown
	.type	hmi_update_init_countdown,%function
	.code	16                              @ @hmi_update_init_countdown
	.thumb_func
hmi_update_init_countdown:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#40
	sub	sp, #40
	.cfi_def_cfa_offset 48
	movw	r0, :lower16:g_page_init
	movt	r0, :upper16:g_page_init
	ldrb	r0, [r0]
	cbnz	r0, .LBB15_2
	b	.LBB15_1
.LBB15_1:
	movw	r1, :lower16:hmi_update_init_countdown.last_left
	movt	r1, :upper16:hmi_update_init_countdown.last_left
	mov.w	r0, #-1
	str	r0, [r1]
	b	.LBB15_8
.LBB15_2:
	bl	HAL_GetTick
	movw	r1, :lower16:g_boot_ms
	movt	r1, :upper16:g_boot_ms
	ldr	r1, [r1]
	subs	r0, r0, r1
	str	r0, [sp, #36]
	ldr	r0, [sp, #36]
	movw	r1, #60000
	cmp	r0, r1
	blo	.LBB15_4
	b	.LBB15_3
.LBB15_3:
	movs	r0, #0
	str	r0, [sp, #4]                    @ 4-byte Spill
	b	.LBB15_5
.LBB15_4:
	ldr	r1, [sp, #36]
	movw	r0, #60000
	subs	r0, r0, r1
	movw	r1, #19923
	movt	r1, #4194
	umull	r1, r0, r0, r1
	lsrs	r0, r0, #6
	str	r0, [sp, #4]                    @ 4-byte Spill
	b	.LBB15_5
.LBB15_5:
	ldr	r0, [sp, #4]                    @ 4-byte Reload
	str	r0, [sp, #32]
	ldr	r0, [sp, #32]
	movw	r1, :lower16:hmi_update_init_countdown.last_left
	movt	r1, :upper16:hmi_update_init_countdown.last_left
	ldr	r1, [r1]
	cmp	r0, r1
	bne	.LBB15_7
	b	.LBB15_6
.LBB15_6:
	b	.LBB15_8
.LBB15_7:
	ldr	r0, [sp, #32]
	movw	r1, :lower16:hmi_update_init_countdown.last_left
	movt	r1, :upper16:hmi_update_init_countdown.last_left
	str	r0, [r1]
	ldr	r3, [sp, #32]
	movw	r2, :lower16:.L.str.5
	movt	r2, :upper16:.L.str.5
	add	r0, sp, #8
	str	r0, [sp]                        @ 4-byte Spill
	movs	r1, #24
	bl	snprintf
	ldr	r1, [sp]                        @ 4-byte Reload
	movw	r0, :lower16:.L.str.6
	movt	r0, :upper16:.L.str.6
	bl	tjc_set_txt
	b	.LBB15_8
.LBB15_8:
	add	sp, #40
	pop	{r7, pc}
.Lfunc_end15:
	.size	hmi_update_init_countdown, .Lfunc_end15-hmi_update_init_countdown
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_update_selftest,"ax",%progbits
	.p2align	2                               @ -- Begin function hmi_update_selftest
	.type	hmi_update_selftest,%function
	.code	16                              @ @hmi_update_selftest
	.thumb_func
hmi_update_selftest:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#56
	sub	sp, #56
	.cfi_def_cfa_offset 64
	movw	r0, :lower16:g_selftest
	movt	r0, :upper16:g_selftest
	ldrb	r2, [r0]
	ldrb	r0, [r0, #2]
	clz	r0, r0
	lsrs	r1, r0, #5
	lsls	r0, r1, #1
	adds	r0, #1
	cmp	r2, #0
	it	ne
	lslne	r0, r1, #1
	strb.w	r0, [sp, #55]
	bl	param_reset_flag
	strb.w	r0, [sp, #54]
	movw	r0, :lower16:g_page_init
	movt	r0, :upper16:g_page_init
	ldrb	r0, [r0]
	cbnz	r0, .LBB16_2
	b	.LBB16_1
.LBB16_1:
	movw	r1, :lower16:hmi_update_selftest.s_fail
	movt	r1, :upper16:hmi_update_selftest.s_fail
	movs	r0, #255
	strb	r0, [r1]
	b	.LBB16_22
.LBB16_2:
	ldrb.w	r0, [sp, #55]
	movw	r1, :lower16:hmi_update_selftest.s_fail
	movt	r1, :upper16:hmi_update_selftest.s_fail
	ldrb	r1, [r1]
	cmp	r0, r1
	bne	.LBB16_5
	b	.LBB16_3
.LBB16_3:
	ldrb.w	r0, [sp, #54]
	movw	r1, :lower16:hmi_update_selftest.s_rst
	movt	r1, :upper16:hmi_update_selftest.s_rst
	ldrb	r1, [r1]
	cmp	r0, r1
	bne	.LBB16_5
	b	.LBB16_4
.LBB16_4:
	b	.LBB16_22
.LBB16_5:
	ldrb.w	r0, [sp, #55]
	movw	r1, :lower16:hmi_update_selftest.s_fail
	movt	r1, :upper16:hmi_update_selftest.s_fail
	strb	r0, [r1]
	ldrb.w	r0, [sp, #54]
	movw	r1, :lower16:hmi_update_selftest.s_rst
	movt	r1, :upper16:hmi_update_selftest.s_rst
	strb	r0, [r1]
	ldrb.w	r0, [sp, #55]
	cbnz	r0, .LBB16_8
	b	.LBB16_6
.LBB16_6:
	ldrb.w	r0, [sp, #54]
	cbz	r0, .LBB16_8
	b	.LBB16_7
.LBB16_7:
	movw	r2, :lower16:.L.str.7
	movt	r2, :upper16:.L.str.7
	add.w	r0, sp, #6
	movs	r1, #48
	bl	snprintf
	b	.LBB16_18
.LBB16_8:
	ldrb.w	r0, [sp, #55]
	cbnz	r0, .LBB16_10
	b	.LBB16_9
.LBB16_9:
	movw	r2, :lower16:.L.str.8
	movt	r2, :upper16:.L.str.8
	add.w	r0, sp, #6
	movs	r1, #48
	bl	snprintf
	b	.LBB16_17
.LBB16_10:
	ldrb.w	r0, [sp, #55]
	cmp	r0, #1
	bne	.LBB16_12
	b	.LBB16_11
.LBB16_11:
	movw	r2, :lower16:.L.str.9
	movt	r2, :upper16:.L.str.9
	add.w	r0, sp, #6
	movs	r1, #48
	bl	snprintf
	b	.LBB16_16
.LBB16_12:
	ldrb.w	r0, [sp, #55]
	cmp	r0, #2
	bne	.LBB16_14
	b	.LBB16_13
.LBB16_13:
	movw	r2, :lower16:.L.str.10
	movt	r2, :upper16:.L.str.10
	add.w	r0, sp, #6
	movs	r1, #48
	bl	snprintf
	b	.LBB16_15
.LBB16_14:
	movw	r2, :lower16:.L.str.11
	movt	r2, :upper16:.L.str.11
	add.w	r0, sp, #6
	movs	r1, #48
	bl	snprintf
	b	.LBB16_15
.LBB16_15:
	b	.LBB16_16
.LBB16_16:
	b	.LBB16_17
.LBB16_17:
	b	.LBB16_18
.LBB16_18:
	movw	r0, :lower16:.L.str.12
	movt	r0, :upper16:.L.str.12
	add.w	r1, sp, #6
	bl	tjc_set_txt
	ldrb.w	r0, [sp, #55]
	cbz	r0, .LBB16_20
	b	.LBB16_19
.LBB16_19:
	movw	r0, #59944
	str	r0, [sp]                        @ 4-byte Spill
	b	.LBB16_21
.LBB16_20:
	ldrb.w	r1, [sp, #54]
	movw	r0, #9771
	cmp	r1, #0
	it	ne
	movwne	r0, #62689
	str	r0, [sp]                        @ 4-byte Spill
	b	.LBB16_21
.LBB16_21:
	ldr	r1, [sp]                        @ 4-byte Reload
	movw	r0, :lower16:.L.str.12
	movt	r0, :upper16:.L.str.12
	bl	tjc_set_pco
	b	.LBB16_22
.LBB16_22:
	add	sp, #56
	pop	{r7, pc}
.Lfunc_end16:
	.size	hmi_update_selftest, .Lfunc_end16-hmi_update_selftest
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.low_batt_poll,"ax",%progbits
	.p2align	2                               @ -- Begin function low_batt_poll
	.type	low_batt_poll,%function
	.code	16                              @ @low_batt_poll
	.thumb_func
low_batt_poll:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#72
	sub	sp, #72
	.cfi_def_cfa_offset 80
	bl	battery_get_level
	strb.w	r0, [sp, #71]
	ldrb.w	r0, [sp, #71]
	movw	r1, :lower16:low_batt_poll.s_pend
	movt	r1, :upper16:low_batt_poll.s_pend
	ldrb	r1, [r1]
	cmp	r0, r1
	beq	.LBB17_2
	b	.LBB17_1
.LBB17_1:
	ldrb.w	r0, [sp, #71]
	movw	r1, :lower16:low_batt_poll.s_pend
	movt	r1, :upper16:low_batt_poll.s_pend
	strb	r0, [r1]
	bl	HAL_GetTick
	movw	r1, :lower16:low_batt_poll.s_pend_t
	movt	r1, :upper16:low_batt_poll.s_pend_t
	str	r0, [r1]
	b	.LBB17_34
.LBB17_2:
	bl	HAL_GetTick
	movw	r1, :lower16:low_batt_poll.s_pend_t
	movt	r1, :upper16:low_batt_poll.s_pend_t
	ldr	r1, [r1]
	subs	r0, r0, r1
	lsrs	r0, r0, #3
	cmp	r0, #124
	bhi	.LBB17_4
	b	.LBB17_3
.LBB17_3:
	b	.LBB17_34
.LBB17_4:
	movw	r0, :lower16:g_full_dirty
	movt	r0, :upper16:g_full_dirty
	ldrb	r0, [r0]
	cmp	r0, #0
	it	ne
	movne	r0, #1
	strb.w	r0, [sp, #15]
	ldrb.w	r0, [sp, #71]
	movw	r1, :lower16:low_batt_poll.s_lv
	movt	r1, :upper16:low_batt_poll.s_lv
	ldrb	r1, [r1]
	cmp	r0, r1
	bne	.LBB17_12
	b	.LBB17_5
.LBB17_5:
	ldrb.w	r0, [sp, #15]
	cbnz	r0, .LBB17_12
	b	.LBB17_6
.LBB17_6:
	ldrb.w	r0, [sp, #71]
	cmp	r0, #2
	bne	.LBB17_8
	b	.LBB17_7
.LBB17_7:
	bl	HAL_GetTick
	movw	r1, :lower16:low_batt_poll.s_last_play
	movt	r1, :upper16:low_batt_poll.s_last_play
	ldr	r1, [r1]
	subs	r0, r0, r1
	movw	r1, #29999
	cmp	r0, r1
	bhi	.LBB17_10
	b	.LBB17_8
.LBB17_8:
	ldrb.w	r0, [sp, #71]
	cmp	r0, #3
	bne	.LBB17_11
	b	.LBB17_9
.LBB17_9:
	bl	HAL_GetTick
	movw	r1, :lower16:low_batt_poll.s_last_play
	movt	r1, :upper16:low_batt_poll.s_last_play
	ldr	r1, [r1]
	subs	r0, r0, r1
	movw	r1, #10000
	cmp	r0, r1
	blo	.LBB17_11
	b	.LBB17_10
.LBB17_10:
	bl	HAL_GetTick
	movw	r1, :lower16:low_batt_poll.s_last_play
	movt	r1, :upper16:low_batt_poll.s_last_play
	str	r0, [r1]
	bl	tjc_lowbatt_play
	b	.LBB17_11
.LBB17_11:
	b	.LBB17_34
.LBB17_12:
	bl	HAL_GetTick
	movw	r1, :lower16:low_batt_poll.s_last_play
	movt	r1, :upper16:low_batt_poll.s_last_play
	str	r0, [r1]
	ldrb.w	r0, [sp, #71]
	movw	r1, :lower16:low_batt_poll.s_lv
	movt	r1, :upper16:low_batt_poll.s_lv
	strb	r0, [r1]
	movw	r0, :lower16:.L.str.13
	movt	r0, :upper16:.L.str.13
	str	r0, [sp, #16]
	movw	r0, :lower16:g_page_init
	movt	r0, :upper16:g_page_init
	ldrb	r0, [r0]
	cbz	r0, .LBB17_14
	b	.LBB17_13
.LBB17_13:
	movw	r0, :lower16:.L.str.14
	movt	r0, :upper16:.L.str.14
	str	r0, [sp, #16]
	b	.LBB17_23
.LBB17_14:
	movw	r0, :lower16:g_page_now
	movt	r0, :upper16:g_page_now
	ldrb	r0, [r0]
	cbnz	r0, .LBB17_16
	b	.LBB17_15
.LBB17_15:
	movw	r0, :lower16:.L.str.15
	movt	r0, :upper16:.L.str.15
	str	r0, [sp, #16]
	b	.LBB17_22
.LBB17_16:
	movw	r0, :lower16:g_page_now
	movt	r0, :upper16:g_page_now
	ldrb	r0, [r0]
	cmp	r0, #2
	bne	.LBB17_18
	b	.LBB17_17
.LBB17_17:
	movw	r0, :lower16:.L.str.16
	movt	r0, :upper16:.L.str.16
	str	r0, [sp, #16]
	b	.LBB17_21
.LBB17_18:
	movw	r0, :lower16:g_page_now
	movt	r0, :upper16:g_page_now
	ldrb	r0, [r0]
	cmp	r0, #5
	bne	.LBB17_20
	b	.LBB17_19
.LBB17_19:
	movw	r0, :lower16:.L.str.17
	movt	r0, :upper16:.L.str.17
	str	r0, [sp, #16]
	b	.LBB17_20
.LBB17_20:
	b	.LBB17_21
.LBB17_21:
	b	.LBB17_22
.LBB17_22:
	b	.LBB17_23
.LBB17_23:
	ldr	r3, [sp, #16]
	movw	r2, :lower16:.L.str.18
	movt	r2, :upper16:.L.str.18
	add.w	r0, sp, #55
	movs	r1, #16
	bl	snprintf
	ldrb.w	r0, [sp, #71]
	cbnz	r0, .LBB17_25
	b	.LBB17_24
.LBB17_24:
	movw	r1, :lower16:.L.str.15
	movt	r1, :upper16:.L.str.15
	add.w	r0, sp, #55
	str	r0, [sp, #8]                    @ 4-byte Spill
	bl	tjc_set_txt
	ldr	r0, [sp, #8]                    @ 4-byte Reload
	movw	r1, #57149
	bl	tjc_set_pco
	b	.LBB17_34
.LBB17_25:
	ldrb.w	r0, [sp, #71]
	cmp	r0, #1
	bne	.LBB17_27
	b	.LBB17_26
.LBB17_26:
	movw	r2, :lower16:.L.str.19
	movt	r2, :upper16:.L.str.19
	add.w	r0, sp, #23
	movs	r1, #32
	bl	snprintf
	b	.LBB17_31
.LBB17_27:
	ldrb.w	r0, [sp, #71]
	cmp	r0, #2
	bne	.LBB17_29
	b	.LBB17_28
.LBB17_28:
	movw	r2, :lower16:.L.str.20
	movt	r2, :upper16:.L.str.20
	add.w	r0, sp, #23
	movs	r1, #32
	bl	snprintf
	b	.LBB17_30
.LBB17_29:
	movw	r2, :lower16:.L.str.21
	movt	r2, :upper16:.L.str.21
	add.w	r0, sp, #23
	movs	r1, #32
	bl	snprintf
	b	.LBB17_30
.LBB17_30:
	b	.LBB17_31
.LBB17_31:
	ldrb.w	r0, [sp, #71]
	movw	r1, #59944
	cmp	r0, #1
	it	eq
	movweq	r1, #62689
	add.w	r0, sp, #55
	str	r0, [sp, #4]                    @ 4-byte Spill
	bl	tjc_set_pco
	ldr	r0, [sp, #4]                    @ 4-byte Reload
	add.w	r1, sp, #23
	bl	tjc_set_txt
	ldrb.w	r0, [sp, #15]
	cbnz	r0, .LBB17_33
	b	.LBB17_32
.LBB17_32:
	bl	tjc_lowbatt_play
	b	.LBB17_33
.LBB17_33:
	b	.LBB17_34
.LBB17_34:
	add	sp, #72
	pop	{r7, pc}
.Lfunc_end17:
	.size	low_batt_poll, .Lfunc_end17-low_batt_poll
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.app_refresh,"ax",%progbits
	.p2align	2                               @ -- Begin function app_refresh
	.type	app_refresh,%function
	.code	16                              @ @app_refresh
	.thumb_func
app_refresh:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#120
	sub	sp, #120
	.cfi_def_cfa_offset 128
	movw	r0, :lower16:g_rx_reattach_fail
	movt	r0, :upper16:g_rx_reattach_fail
	ldrb	r0, [r0]
	cbz	r0, .LBB18_6
	b	.LBB18_1
.LBB18_1:
	b	.LBB18_2
.LBB18_2:
	movs	r0, #0
	str	r0, [sp, #116]
	movw	r0, :lower16:huart3
	movt	r0, :upper16:huart3
	ldr	r1, [r0]
	ldr	r1, [r1]
	str	r1, [sp, #116]
	ldr	r0, [r0]
	ldr	r0, [r0, #4]
	str	r0, [sp, #116]
	ldr	r0, [sp, #116]
	b	.LBB18_3
.LBB18_3:
	bl	hmi_get_reset
	movw	r0, :lower16:huart3
	movt	r0, :upper16:huart3
	movw	r1, :lower16:rx_byte
	movt	r1, :upper16:rx_byte
	movs	r2, #1
	bl	HAL_UART_Receive_IT
	cbnz	r0, .LBB18_5
	b	.LBB18_4
.LBB18_4:
	movw	r1, :lower16:g_rx_reattach_fail
	movt	r1, :upper16:g_rx_reattach_fail
	movs	r0, #0
	strb	r0, [r1]
	b	.LBB18_5
.LBB18_5:
	b	.LBB18_6
.LBB18_6:
	movw	r0, :lower16:g_full_dirty
	movt	r0, :upper16:g_full_dirty
	ldrb	r0, [r0]
	strb.w	r0, [sp, #115]
	ldrb.w	r0, [sp, #115]
	cbz	r0, .LBB18_8
	b	.LBB18_7
.LBB18_7:
	movw	r1, :lower16:g_full_dirty
	movt	r1, :upper16:g_full_dirty
	movs	r0, #0
	strb	r0, [r1]
	bl	hmi_push_device_info
	b	.LBB18_8
.LBB18_8:
	bl	rtc_time_sync_poll
	bl	thr_hi_readback_poll
	bl	battery_poll
	bl	sensor_read_ppm
	movw	r1, :lower16:g_ppm
	movt	r1, :upper16:g_ppm
	str	r0, [r1]
	bl	HAL_GetTick
	movw	r1, :lower16:g_boot_ms
	movt	r1, :upper16:g_boot_ms
	ldr	r1, [r1]
	subs	r0, r0, r1
	movw	r2, #60000
	movs	r1, #0
	cmp	r0, r2
	it	lo
	movlo	r1, #1
	movw	r0, :lower16:g_warm
	movt	r0, :upper16:g_warm
	str	r1, [r0]
	ldr	r0, [r0]
	cbz	r0, .LBB18_10
	b	.LBB18_9
.LBB18_9:
	movw	r1, :lower16:g_ppm
	movt	r1, :upper16:g_ppm
	movs	r0, #0
	str	r0, [r1]
	movw	r1, :lower16:g_alarm
	movt	r1, :upper16:g_alarm
	str	r0, [r1]
	b	.LBB18_10
.LBB18_10:
	movw	r0, :lower16:g_page_init
	movt	r0, :upper16:g_page_init
	ldrb	r0, [r0]
	cbz	r0, .LBB18_14
	b	.LBB18_11
.LBB18_11:
	movw	r0, :lower16:g_skip
	movt	r0, :upper16:g_skip
	ldrb	r0, [r0]
	cbnz	r0, .LBB18_13
	b	.LBB18_12
.LBB18_12:
	movw	r0, :lower16:g_warm
	movt	r0, :upper16:g_warm
	ldr	r0, [r0]
	cbnz	r0, .LBB18_14
	b	.LBB18_13
.LBB18_13:
	movw	r1, :lower16:g_page_init
	movt	r1, :upper16:g_page_init
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_skip
	movt	r1, :upper16:g_skip
	strb	r0, [r1]
	movw	r1, :lower16:g_page_now
	movt	r1, :upper16:g_page_now
	strb	r0, [r1]
	movw	r2, :lower16:g_full_dirty
	movt	r2, :upper16:g_full_dirty
	movs	r1, #1
	strb	r1, [r2]
	bl	tjc_page
	b	.LBB18_14
.LBB18_14:
	movw	r0, :lower16:g_ppm
	movt	r0, :upper16:g_ppm
	ldr	r0, [r0]
	movw	r1, :lower16:g_peak
	movt	r1, :upper16:g_peak
	ldr	r1, [r1]
	bl	__aeabi_fcmple
	cbnz	r0, .LBB18_16
	b	.LBB18_15
.LBB18_15:
	movw	r0, :lower16:g_ppm
	movt	r0, :upper16:g_ppm
	ldr	r0, [r0]
	movw	r1, :lower16:g_peak
	movt	r1, :upper16:g_peak
	str	r0, [r1]
	b	.LBB18_16
.LBB18_16:
	movw	r0, :lower16:g_ppm
	movt	r0, :upper16:g_ppm
	ldr	r0, [r0]
	movw	r1, :lower16:g_min
	movt	r1, :upper16:g_min
	ldr	r1, [r1]
	bl	__aeabi_fcmpge
	cbnz	r0, .LBB18_18
	b	.LBB18_17
.LBB18_17:
	movw	r0, :lower16:g_ppm
	movt	r0, :upper16:g_ppm
	ldr	r0, [r0]
	movw	r1, :lower16:g_min
	movt	r1, :upper16:g_min
	str	r0, [r1]
	b	.LBB18_18
.LBB18_18:
	movw	r0, :lower16:g_test
	movt	r0, :upper16:g_test
	ldrb	r0, [r0]
	cbz	r0, .LBB18_24
	b	.LBB18_19
.LBB18_19:
	movw	r0, :lower16:g_ppm
	movt	r0, :upper16:g_ppm
	ldr	r0, [r0]
	bl	__aeabi_f2uiz
	str	r0, [sp, #76]
	ldr	r3, [sp, #76]
	movw	r2, :lower16:g_sess_sum
	movt	r2, :upper16:g_sess_sum
	ldrd	r0, r1, [r2]
	adds	r0, r0, r3
	adc	r1, r1, #0
	strd	r0, r1, [r2]
	movw	r1, :lower16:g_sess_cnt
	movt	r1, :upper16:g_sess_cnt
	ldr	r0, [r1]
	adds	r0, #1
	str	r0, [r1]
	ldr	r0, [sp, #76]
	movw	r1, :lower16:g_sess_max
	movt	r1, :upper16:g_sess_max
	ldrh	r1, [r1]
	cmp	r0, r1
	bls	.LBB18_21
	b	.LBB18_20
.LBB18_20:
	ldr	r0, [sp, #76]
	movw	r1, :lower16:g_sess_max
	movt	r1, :upper16:g_sess_max
	strh	r0, [r1]
	b	.LBB18_21
.LBB18_21:
	ldr	r0, [sp, #76]
	movw	r1, :lower16:g_sess_min
	movt	r1, :upper16:g_sess_min
	ldrh	r1, [r1]
	cmp	r0, r1
	bhs	.LBB18_23
	b	.LBB18_22
.LBB18_22:
	ldr	r0, [sp, #76]
	movw	r1, :lower16:g_sess_min
	movt	r1, :upper16:g_sess_min
	strh	r0, [r1]
	b	.LBB18_23
.LBB18_23:
	b	.LBB18_24
.LBB18_24:
	movw	r0, :lower16:g_avg_n
	movt	r0, :upper16:g_avg_n
	ldrh	r0, [r0]
	cmp	r0, #60
	bne	.LBB18_26
	b	.LBB18_25
.LBB18_25:
	movw	r0, :lower16:g_avg_i
	movt	r0, :upper16:g_avg_i
	ldrh	r1, [r0]
	movw	r0, :lower16:g_avg_buf
	movt	r0, :upper16:g_avg_buf
	ldr.w	r1, [r0, r1, lsl #2]
	movw	r0, :lower16:app_refresh.s_ring
	movt	r0, :upper16:app_refresh.s_ring
	str	r0, [sp, #44]                   @ 4-byte Spill
	ldr	r0, [r0]
	bl	__aeabi_fsub
	ldr	r1, [sp, #44]                   @ 4-byte Reload
	str	r0, [r1]
	b	.LBB18_26
.LBB18_26:
	movw	r0, :lower16:g_ppm
	movt	r0, :upper16:g_ppm
	ldr	r0, [r0]
	movw	r1, :lower16:g_avg_i
	movt	r1, :upper16:g_avg_i
	ldrh	r3, [r1]
	movw	r2, :lower16:g_avg_buf
	movt	r2, :upper16:g_avg_buf
	str.w	r0, [r2, r3, lsl #2]
	ldrh	r0, [r1]
	adds	r0, #1
	movw	r2, #17477
	movt	r2, #1092
	umull	r3, r2, r0, r2
	rsb	r2, r2, r2, lsl #4
	sub.w	r0, r0, r2, lsl #2
	strh	r0, [r1]
	movw	r0, :lower16:g_avg_n
	movt	r0, :upper16:g_avg_n
	ldrh	r0, [r0]
	cmp	r0, #59
	bhi	.LBB18_28
	b	.LBB18_27
.LBB18_27:
	movw	r1, :lower16:g_avg_n
	movt	r1, :upper16:g_avg_n
	ldrh	r0, [r1]
	adds	r0, #1
	strh	r0, [r1]
	b	.LBB18_28
.LBB18_28:
	movw	r0, :lower16:g_ppm
	movt	r0, :upper16:g_ppm
	str	r0, [sp, #40]                   @ 4-byte Spill
	ldr	r1, [r0]
	movw	r0, :lower16:app_refresh.s_ring
	movt	r0, :upper16:app_refresh.s_ring
	str	r0, [sp, #28]                   @ 4-byte Spill
	ldr	r0, [r0]
	bl	__aeabi_fadd
	mov	r1, r0
	ldr	r0, [sp, #28]                   @ 4-byte Reload
	str	r1, [r0]
	ldr	r0, [r0]
	bl	__aeabi_f2d
	str	r0, [sp, #32]                   @ 4-byte Spill
	str	r1, [sp, #36]                   @ 4-byte Spill
	movw	r0, :lower16:g_avg_n
	movt	r0, :upper16:g_avg_n
	ldrh	r0, [r0]
	bl	__aeabi_ui2d
	mov	r2, r0
	ldr	r0, [sp, #32]                   @ 4-byte Reload
	mov	r3, r1
	ldr	r1, [sp, #36]                   @ 4-byte Reload
	bl	__aeabi_ddiv
	bl	__aeabi_d2f
	mov	r1, r0
	ldr	r0, [sp, #40]                   @ 4-byte Reload
	movw	r2, :lower16:g_avg_run
	movt	r2, :upper16:g_avg_run
	str	r1, [r2]
	ldr	r0, [r0]
	movw	r1, #32768
	movt	r1, #17595
	bl	__aeabi_fcmple
	cbnz	r0, .LBB18_30
	b	.LBB18_29
.LBB18_29:
	movw	r1, :lower16:g_alarm
	movt	r1, :upper16:g_alarm
	movs	r0, #3
	str	r0, [r1]
	b	.LBB18_39
.LBB18_30:
	movw	r0, :lower16:g_thr_hi
	movt	r0, :upper16:g_thr_hi
	ldr	r0, [r0]
	cmp	r0, #1
	blt	.LBB18_33
	b	.LBB18_31
.LBB18_31:
	movw	r0, :lower16:g_ppm
	movt	r0, :upper16:g_ppm
	ldr	r0, [r0]
	str	r0, [sp, #24]                   @ 4-byte Spill
	movw	r0, :lower16:g_thr_hi
	movt	r0, :upper16:g_thr_hi
	ldr	r0, [r0]
	bl	__aeabi_i2f
	mov	r1, r0
	ldr	r0, [sp, #24]                   @ 4-byte Reload
	bl	__aeabi_fcmplt
	cbnz	r0, .LBB18_33
	b	.LBB18_32
.LBB18_32:
	movw	r1, :lower16:g_alarm
	movt	r1, :upper16:g_alarm
	movs	r0, #2
	str	r0, [r1]
	b	.LBB18_38
.LBB18_33:
	movw	r0, :lower16:g_thr_lo
	movt	r0, :upper16:g_thr_lo
	ldr	r0, [r0]
	cmp	r0, #1
	blt	.LBB18_36
	b	.LBB18_34
.LBB18_34:
	movw	r0, :lower16:g_ppm
	movt	r0, :upper16:g_ppm
	ldr	r0, [r0]
	str	r0, [sp, #20]                   @ 4-byte Spill
	movw	r0, :lower16:g_thr_lo
	movt	r0, :upper16:g_thr_lo
	ldr	r0, [r0]
	bl	__aeabi_i2f
	mov	r1, r0
	ldr	r0, [sp, #20]                   @ 4-byte Reload
	bl	__aeabi_fcmplt
	cbnz	r0, .LBB18_36
	b	.LBB18_35
.LBB18_35:
	movw	r1, :lower16:g_alarm
	movt	r1, :upper16:g_alarm
	movs	r0, #1
	str	r0, [r1]
	b	.LBB18_37
.LBB18_36:
	movw	r1, :lower16:g_alarm
	movt	r1, :upper16:g_alarm
	movs	r0, #0
	str	r0, [r1]
	b	.LBB18_37
.LBB18_37:
	b	.LBB18_38
.LBB18_38:
	b	.LBB18_39
.LBB18_39:
	movw	r0, :lower16:g_alarm
	movt	r0, :upper16:g_alarm
	ldr	r0, [r0]
	cmp	r0, #2
	blt	.LBB18_49
	b	.LBB18_40
.LBB18_40:
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	ldrb.w	r0, [r0, #32]
	cbz	r0, .LBB18_49
	b	.LBB18_41
.LBB18_41:
	bl	HAL_GetTick
	str	r0, [sp, #72]
	movw	r0, :lower16:g_mute
	movt	r0, :upper16:g_mute
	ldrb	r0, [r0]
	cbz	r0, .LBB18_43
	b	.LBB18_42
.LBB18_42:
	bl	tjc_alarm_off
	b	.LBB18_48
.LBB18_43:
	movw	r0, :lower16:g_alarm
	movt	r0, :upper16:g_alarm
	ldr	r0, [r0]
	movw	r1, :lower16:app_refresh.prev
	movt	r1, :upper16:app_refresh.prev
	ldr	r1, [r1]
	cmp	r0, r1
	bne	.LBB18_46
	b	.LBB18_44
.LBB18_44:
	ldr	r0, [sp, #72]
	movw	r1, :lower16:app_refresh.tlast
	movt	r1, :upper16:app_refresh.tlast
	ldr	r1, [r1]
	subs	r0, r0, r1
	lsrs	r0, r0, #4
	cmp	r0, #124
	bhi	.LBB18_46
	b	.LBB18_45
.LBB18_45:
	movw	r0, :lower16:g_mute
	movt	r0, :upper16:g_mute
	ldrb	r0, [r0]
	movw	r1, :lower16:app_refresh.s_mute_prev
	movt	r1, :upper16:app_refresh.s_mute_prev
	ldrb	r1, [r1]
	cmp	r0, r1
	beq	.LBB18_47
	b	.LBB18_46
.LBB18_46:
	bl	tjc_alarm_on
	ldr	r0, [sp, #72]
	movw	r1, :lower16:app_refresh.tlast
	movt	r1, :upper16:app_refresh.tlast
	str	r0, [r1]
	b	.LBB18_47
.LBB18_47:
	b	.LBB18_48
.LBB18_48:
	b	.LBB18_55
.LBB18_49:
	movw	r0, :lower16:app_refresh.prev
	movt	r0, :upper16:app_refresh.prev
	ldr	r0, [r0]
	cmp	r0, #2
	blt	.LBB18_51
	b	.LBB18_50
.LBB18_50:
	bl	tjc_alarm_off
	b	.LBB18_51
.LBB18_51:
	movw	r0, :lower16:app_refresh.prev
	movt	r0, :upper16:app_refresh.prev
	ldr	r0, [r0]
	cmp	r0, #2
	blt	.LBB18_54
	b	.LBB18_52
.LBB18_52:
	movw	r0, :lower16:g_alarm
	movt	r0, :upper16:g_alarm
	ldr	r0, [r0]
	cbnz	r0, .LBB18_54
	b	.LBB18_53
.LBB18_53:
	movw	r1, :lower16:g_mute
	movt	r1, :upper16:g_mute
	movs	r0, #0
	strb	r0, [r1]
	b	.LBB18_54
.LBB18_54:
	b	.LBB18_55
.LBB18_55:
	movw	r0, :lower16:g_alarm
	movt	r0, :upper16:g_alarm
	ldr	r0, [r0]
	movw	r1, :lower16:app_refresh.prev
	movt	r1, :upper16:app_refresh.prev
	str	r0, [r1]
	movw	r0, :lower16:g_mute
	movt	r0, :upper16:g_mute
	ldrb	r1, [r0]
	movw	r2, :lower16:app_refresh.s_mute_prev
	movt	r2, :upper16:app_refresh.s_mute_prev
	strb	r1, [r2]
	ldrb	r0, [r0]
	cmp	r0, #0
	it	ne
	movne	r0, #1
	strb.w	r0, [sp, #71]
	ldrb.w	r0, [sp, #115]
	cbnz	r0, .LBB18_57
	b	.LBB18_56
.LBB18_56:
	ldrb.w	r0, [sp, #71]
	movw	r1, :lower16:app_refresh.s_mute
	movt	r1, :upper16:app_refresh.s_mute
	ldrb	r1, [r1]
	cmp	r0, r1
	beq	.LBB18_58
	b	.LBB18_57
.LBB18_57:
	ldrb.w	r0, [sp, #71]
	movw	r1, :lower16:app_refresh.s_mute
	movt	r1, :upper16:app_refresh.s_mute
	strb	r0, [r1]
	ldrb.w	r2, [sp, #71]
	movw	r0, :lower16:.L.str.23
	movt	r0, :upper16:.L.str.23
	movw	r1, :lower16:.L.str.24
	movt	r1, :upper16:.L.str.24
	cmp	r2, #0
	it	ne
	movne	r1, r0
	movw	r0, :lower16:.L.str.22
	movt	r0, :upper16:.L.str.22
	bl	tjc_set_txt
	b	.LBB18_58
.LBB18_58:
	movw	r0, :lower16:g_test
	movt	r0, :upper16:g_test
	ldrb	r0, [r0]
	cmp	r0, #0
	it	ne
	movne	r0, #1
	strb.w	r0, [sp, #70]
	ldrb.w	r0, [sp, #115]
	cbnz	r0, .LBB18_60
	b	.LBB18_59
.LBB18_59:
	ldrb.w	r0, [sp, #70]
	movw	r1, :lower16:app_refresh.s_test
	movt	r1, :upper16:app_refresh.s_test
	ldrb	r1, [r1]
	cmp	r0, r1
	beq	.LBB18_61
	b	.LBB18_60
.LBB18_60:
	ldrb.w	r0, [sp, #70]
	movw	r1, :lower16:app_refresh.s_test
	movt	r1, :upper16:app_refresh.s_test
	strb	r0, [r1]
	ldrb.w	r2, [sp, #70]
	movw	r0, :lower16:.L.str.26
	movt	r0, :upper16:.L.str.26
	movw	r1, :lower16:.L.str.27
	movt	r1, :upper16:.L.str.27
	cmp	r2, #0
	it	ne
	movne	r1, r0
	movw	r0, :lower16:.L.str.25
	movt	r0, :upper16:.L.str.25
	bl	tjc_set_txt
	b	.LBB18_61
.LBB18_61:
	bl	HAL_GetTick
	str	r0, [sp, #64]
	movw	r0, :lower16:g_test
	movt	r0, :upper16:g_test
	ldrb	r0, [r0]
	cbz	r0, .LBB18_66
	b	.LBB18_62
.LBB18_62:
	movw	r0, :lower16:g_warm
	movt	r0, :upper16:g_warm
	ldr	r0, [r0]
	cbnz	r0, .LBB18_66
	b	.LBB18_63
.LBB18_63:
	movw	r0, :lower16:g_selftest
	movt	r0, :upper16:g_selftest
	ldrb	r0, [r0]
	cbz	r0, .LBB18_66
	b	.LBB18_64
.LBB18_64:
	ldr	r0, [sp, #64]
	movw	r1, :lower16:app_refresh.hist_last
	movt	r1, :upper16:app_refresh.hist_last
	ldr	r1, [r1]
	subs	r0, r0, r1
	cmp.w	r0, #1000
	blo	.LBB18_66
	b	.LBB18_65
.LBB18_65:
	ldr	r0, [sp, #64]
	movw	r1, :lower16:app_refresh.hist_last
	movt	r1, :upper16:app_refresh.hist_last
	str	r0, [r1]
	movw	r0, :lower16:g_ppm
	movt	r0, :upper16:g_ppm
	ldr	r0, [r0]
	bl	__aeabi_f2iz
	bl	history_log
	b	.LBB18_66
.LBB18_66:
	bl	history_total
	str	r0, [sp, #60]
	movw	r0, :lower16:g_refill_req
	movt	r0, :upper16:g_refill_req
	ldrb	r0, [r0]
	cbz	r0, .LBB18_68
	b	.LBB18_67
.LBB18_67:
	movw	r1, :lower16:g_refill_req
	movt	r1, :upper16:g_refill_req
	movs	r0, #0
	strb	r0, [r1]
	ldr	r0, [sp, #64]
	movw	r1, :lower16:app_refresh.rlast
	movt	r1, :upper16:app_refresh.rlast
	str	r0, [r1]
	bl	refill_table
	ldr	r0, [sp, #60]
	movw	r1, :lower16:app_refresh.s_total
	movt	r1, :upper16:app_refresh.s_total
	str	r0, [r1]
	movw	r0, :lower16:g_tbl_page
	movt	r0, :upper16:g_tbl_page
	ldrh	r0, [r0]
	movw	r1, :lower16:app_refresh.s_pg
	movt	r1, :upper16:app_refresh.s_pg
	strh	r0, [r1]
	b	.LBB18_77
.LBB18_68:
	movw	r0, :lower16:g_page_now
	movt	r0, :upper16:g_page_now
	ldrb	r0, [r0]
	cmp	r0, #2
	bne	.LBB18_72
	b	.LBB18_69
.LBB18_69:
	ldr	r0, [sp, #60]
	movw	r1, :lower16:app_refresh.s_total
	movt	r1, :upper16:app_refresh.s_total
	ldr	r1, [r1]
	cmp	r0, r1
	bne	.LBB18_71
	b	.LBB18_70
.LBB18_70:
	movw	r0, :lower16:g_tbl_page
	movt	r0, :upper16:g_tbl_page
	ldrh	r0, [r0]
	movw	r1, :lower16:app_refresh.s_pg
	movt	r1, :upper16:app_refresh.s_pg
	ldrh	r1, [r1]
	cmp	r0, r1
	beq	.LBB18_72
	b	.LBB18_71
.LBB18_71:
	ldr	r0, [sp, #64]
	movw	r1, :lower16:app_refresh.rlast
	movt	r1, :upper16:app_refresh.rlast
	str	r0, [r1]
	ldr	r0, [sp, #60]
	movw	r1, :lower16:app_refresh.s_total
	movt	r1, :upper16:app_refresh.s_total
	str	r0, [r1]
	movw	r0, :lower16:g_tbl_page
	movt	r0, :upper16:g_tbl_page
	ldrh	r0, [r0]
	movw	r1, :lower16:app_refresh.s_pg
	movt	r1, :upper16:app_refresh.s_pg
	strh	r0, [r1]
	bl	refill_table
	b	.LBB18_76
.LBB18_72:
	movw	r0, :lower16:g_page_now
	movt	r0, :upper16:g_page_now
	ldrb	r0, [r0]
	cmp	r0, #2
	bne	.LBB18_75
	b	.LBB18_73
.LBB18_73:
	ldr	r0, [sp, #64]
	movw	r1, :lower16:app_refresh.rlast
	movt	r1, :upper16:app_refresh.rlast
	ldr	r1, [r1]
	subs	r0, r0, r1
	movw	r1, #5000
	cmp	r0, r1
	blo	.LBB18_75
	b	.LBB18_74
.LBB18_74:
	ldr	r0, [sp, #64]
	movw	r1, :lower16:app_refresh.rlast
	movt	r1, :upper16:app_refresh.rlast
	str	r0, [r1]
	ldr	r0, [sp, #60]
	movw	r1, :lower16:app_refresh.s_total
	movt	r1, :upper16:app_refresh.s_total
	str	r0, [r1]
	movw	r0, :lower16:g_tbl_page
	movt	r0, :upper16:g_tbl_page
	ldrh	r0, [r0]
	movw	r1, :lower16:app_refresh.s_pg
	movt	r1, :upper16:app_refresh.s_pg
	strh	r0, [r1]
	bl	refill_table
	b	.LBB18_75
.LBB18_75:
	b	.LBB18_76
.LBB18_76:
	b	.LBB18_77
.LBB18_77:
	movw	r0, :lower16:g_ppm
	movt	r0, :upper16:g_ppm
	ldr	r0, [r0]
	bl	__aeabi_f2iz
	mov	r1, r0
	movw	r0, :lower16:.L.str.28
	movt	r0, :upper16:.L.str.28
	bl	tjc_set_val
	movw	r0, :lower16:g_avg_run
	movt	r0, :upper16:g_avg_run
	ldr	r0, [r0]
	bl	__aeabi_f2d
	mov	r2, r1
	mov	r1, sp
	str	r2, [r1, #4]
	str	r0, [r1]
	movw	r0, :lower16:g_avg_str
	movt	r0, :upper16:g_avg_str
	movw	r2, :lower16:.L.str.29
	movt	r2, :upper16:.L.str.29
	movs	r1, #16
	bl	snprintf
	movw	r0, :lower16:g_peak
	movt	r0, :upper16:g_peak
	ldr	r0, [r0]
	bl	__aeabi_f2iz
	str	r0, [sp, #56]
	movw	r0, :lower16:g_min
	movt	r0, :upper16:g_min
	ldr	r0, [r0]
	movw	r1, #9216
	movt	r1, #18804
	bl	__aeabi_fcmple
	cbnz	r0, .LBB18_79
	b	.LBB18_78
.LBB18_78:
	movs	r0, #0
	str	r0, [sp, #16]                   @ 4-byte Spill
	b	.LBB18_80
.LBB18_79:
	movw	r0, :lower16:g_min
	movt	r0, :upper16:g_min
	ldr	r0, [r0]
	bl	__aeabi_f2iz
	str	r0, [sp, #16]                   @ 4-byte Spill
	b	.LBB18_80
.LBB18_80:
	ldr	r0, [sp, #16]                   @ 4-byte Reload
	str	r0, [sp, #52]
	ldrb.w	r0, [sp, #115]
	cbnz	r0, .LBB18_83
	b	.LBB18_81
.LBB18_81:
	ldr	r0, [sp, #56]
	movw	r1, :lower16:app_refresh.s_mx
	movt	r1, :upper16:app_refresh.s_mx
	ldr	r1, [r1]
	cmp	r0, r1
	bne	.LBB18_83
	b	.LBB18_82
.LBB18_82:
	ldr	r0, [sp, #52]
	movw	r1, :lower16:app_refresh.s_mn
	movt	r1, :upper16:app_refresh.s_mn
	ldr	r1, [r1]
	cmp	r0, r1
	beq	.LBB18_84
	b	.LBB18_83
.LBB18_83:
	ldr	r0, [sp, #56]
	movw	r1, :lower16:app_refresh.s_mx
	movt	r1, :upper16:app_refresh.s_mx
	str	r0, [r1]
	ldr	r0, [sp, #52]
	movw	r1, :lower16:app_refresh.s_mn
	movt	r1, :upper16:app_refresh.s_mn
	str	r0, [r1]
	ldr	r0, [sp, #56]
	bl	__aeabi_i2d
	mov	r2, r1
	mov	r1, sp
	str	r2, [r1, #4]
	str	r0, [r1]
	movw	r2, :lower16:.L.str.30
	movt	r2, :upper16:.L.str.30
	add.w	r0, sp, #83
	str	r0, [sp, #12]                   @ 4-byte Spill
	movs	r1, #32
	str	r1, [sp, #8]                    @ 4-byte Spill
	bl	snprintf
	ldr	r1, [sp, #12]                   @ 4-byte Reload
	movw	r0, :lower16:.L.str.31
	movt	r0, :upper16:.L.str.31
	bl	tjc_set_txt
	ldr	r0, [sp, #52]
	bl	__aeabi_i2d
	mov	r2, r0
	ldr	r0, [sp, #12]                   @ 4-byte Reload
	mov	r12, r1
	ldr	r1, [sp, #8]                    @ 4-byte Reload
	mov	r3, sp
	str.w	r12, [r3, #4]
	str	r2, [r3]
	movw	r2, :lower16:.L.str.32
	movt	r2, :upper16:.L.str.32
	bl	snprintf
	ldr	r1, [sp, #12]                   @ 4-byte Reload
	movw	r0, :lower16:.L.str.33
	movt	r0, :upper16:.L.str.33
	bl	tjc_set_txt
	b	.LBB18_84
.LBB18_84:
	movw	r0, :lower16:g_alarm
	movt	r0, :upper16:g_alarm
	ldr	r1, [r0]
	movw	r0, :lower16:CONC_COLOR
	movt	r0, :upper16:CONC_COLOR
	ldr.w	r0, [r0, r1, lsl #2]
	str	r0, [sp, #48]
	ldrb.w	r0, [sp, #115]
	cbnz	r0, .LBB18_86
	b	.LBB18_85
.LBB18_85:
	ldr	r0, [sp, #48]
	movw	r1, :lower16:app_refresh.s_ccc
	movt	r1, :upper16:app_refresh.s_ccc
	ldr	r1, [r1]
	cmp	r0, r1
	beq	.LBB18_87
	b	.LBB18_86
.LBB18_86:
	ldr	r0, [sp, #48]
	movw	r1, :lower16:app_refresh.s_ccc
	movt	r1, :upper16:app_refresh.s_ccc
	str	r0, [r1]
	ldr	r1, [sp, #48]
	movw	r0, :lower16:.L.str.28
	movt	r0, :upper16:.L.str.28
	bl	tjc_set_pco
	b	.LBB18_87
.LBB18_87:
	ldrb.w	r0, [sp, #115]
	bl	hmi_update_status_chips
	add	sp, #120
	pop	{r7, pc}
.Lfunc_end18:
	.size	app_refresh, .Lfunc_end18-app_refresh
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.Error_Handler,"ax",%progbits
	.hidden	Error_Handler                   @ -- Begin function Error_Handler
	.globl	Error_Handler
	.p2align	2
	.type	Error_Handler,%function
	.code	16                              @ @Error_Handler
	.thumb_func
Error_Handler:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.pad	#4
	sub	sp, #4
	.cfi_def_cfa_offset 4
	@APP
	mrs	r0, primask
	cpsid i

	@NO_APP
	str	r0, [sp]
	b	.LBB19_1
.LBB19_1:                               @ =>This Inner Loop Header: Depth=1
	b	.LBB19_1
.Lfunc_end19:
	.size	Error_Handler, .Lfunc_end19-Error_Handler
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_on_init_skip,"ax",%progbits
	.hidden	hmi_on_init_skip                @ -- Begin function hmi_on_init_skip
	.globl	hmi_on_init_skip
	.p2align	2
	.type	hmi_on_init_skip,%function
	.code	16                              @ @hmi_on_init_skip
	.thumb_func
hmi_on_init_skip:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	bl	HAL_GetTick
	movw	r1, #4999
	cmp	r0, r1
	bhi	.LBB20_2
	b	.LBB20_1
.LBB20_1:
	b	.LBB20_3
.LBB20_2:
	movw	r1, :lower16:g_skip
	movt	r1, :upper16:g_skip
	movs	r0, #1
	strb	r0, [r1]
	b	.LBB20_3
.LBB20_3:
	pop	{r7, pc}
.Lfunc_end20:
	.size	hmi_on_init_skip, .Lfunc_end20-hmi_on_init_skip
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_on_thr_hi_inc,"ax",%progbits
	.hidden	hmi_on_thr_hi_inc               @ -- Begin function hmi_on_thr_hi_inc
	.globl	hmi_on_thr_hi_inc
	.p2align	2
	.type	hmi_on_thr_hi_inc,%function
	.code	16                              @ @hmi_on_thr_hi_inc
	.thumb_func
hmi_on_thr_hi_inc:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#8
	sub	sp, #8
	.cfi_def_cfa_offset 16
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	ldrh	r0, [r0, #28]
	adds	r0, #50
	str	r0, [sp, #4]
	ldr	r0, [sp, #4]
	movw	r1, #1501
	cmp	r0, r1
	blt	.LBB21_2
	b	.LBB21_1
.LBB21_1:
	movw	r0, #1500
	str	r0, [sp, #4]
	b	.LBB21_2
.LBB21_2:
	ldr	r0, [sp, #4]
	movw	r1, :lower16:g_param
	movt	r1, :upper16:g_param
	strh	r0, [r1, #28]
	bl	thr_commit
	add	sp, #8
	pop	{r7, pc}
.Lfunc_end21:
	.size	hmi_on_thr_hi_inc, .Lfunc_end21-hmi_on_thr_hi_inc
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.thr_commit,"ax",%progbits
	.p2align	2                               @ -- Begin function thr_commit
	.type	thr_commit,%function
	.code	16                              @ @thr_commit
	.thumb_func
thr_commit:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	ldrh	r1, [r0, #28]
	movw	r2, :lower16:g_thr_hi
	movt	r2, :upper16:g_thr_hi
	str	r1, [r2]
	ldrh	r0, [r0, #30]
	movw	r1, :lower16:g_thr_lo
	movt	r1, :upper16:g_thr_lo
	str	r0, [r1]
	movw	r1, :lower16:g_thr_dirty
	movt	r1, :upper16:g_thr_dirty
	movs	r0, #1
	strb	r0, [r1]
	movw	r1, :lower16:g_save_pending
	movt	r1, :upper16:g_save_pending
	strb	r0, [r1]
	bl	HAL_GetTick
	movw	r1, :lower16:g_thr_dirty_t
	movt	r1, :upper16:g_thr_dirty_t
	str	r0, [r1]
	pop	{r7, pc}
.Lfunc_end22:
	.size	thr_commit, .Lfunc_end22-thr_commit
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_on_thr_hi_dec,"ax",%progbits
	.hidden	hmi_on_thr_hi_dec               @ -- Begin function hmi_on_thr_hi_dec
	.globl	hmi_on_thr_hi_dec
	.p2align	2
	.type	hmi_on_thr_hi_dec,%function
	.code	16                              @ @hmi_on_thr_hi_dec
	.thumb_func
hmi_on_thr_hi_dec:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#8
	sub	sp, #8
	.cfi_def_cfa_offset 16
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	ldrh	r0, [r0, #28]
	subs	r0, #50
	str	r0, [sp, #4]
	ldr	r0, [sp, #4]
	cmp	r0, #99
	bgt	.LBB23_2
	b	.LBB23_1
.LBB23_1:
	movs	r0, #100
	str	r0, [sp, #4]
	b	.LBB23_2
.LBB23_2:
	ldr	r0, [sp, #4]
	movw	r1, :lower16:g_param
	movt	r1, :upper16:g_param
	ldrh	r1, [r1, #30]
	cmp	r0, r1
	bge	.LBB23_4
	b	.LBB23_3
.LBB23_3:
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	ldrh	r0, [r0, #30]
	str	r0, [sp, #4]
	b	.LBB23_4
.LBB23_4:
	ldr	r0, [sp, #4]
	movw	r1, :lower16:g_param
	movt	r1, :upper16:g_param
	strh	r0, [r1, #28]
	bl	thr_commit
	add	sp, #8
	pop	{r7, pc}
.Lfunc_end23:
	.size	hmi_on_thr_hi_dec, .Lfunc_end23-hmi_on_thr_hi_dec
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_on_thr_hi_set,"ax",%progbits
	.hidden	hmi_on_thr_hi_set               @ -- Begin function hmi_on_thr_hi_set
	.globl	hmi_on_thr_hi_set
	.p2align	2
	.type	hmi_on_thr_hi_set,%function
	.code	16                              @ @hmi_on_thr_hi_set
	.thumb_func
hmi_on_thr_hi_set:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	movw	r1, :lower16:g_thr_hi_req
	movt	r1, :upper16:g_thr_hi_req
	movs	r0, #1
	strb	r0, [r1]
	movw	r1, :lower16:g_thr_try
	movt	r1, :upper16:g_thr_try
	movs	r0, #0
	strb	r0, [r1]
	bl	HAL_GetTick
	movw	r1, :lower16:g_thr_t0
	movt	r1, :upper16:g_thr_t0
	str	r0, [r1]
	pop	{r7, pc}
.Lfunc_end24:
	.size	hmi_on_thr_hi_set, .Lfunc_end24-hmi_on_thr_hi_set
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_on_buz_mute,"ax",%progbits
	.hidden	hmi_on_buz_mute                 @ -- Begin function hmi_on_buz_mute
	.globl	hmi_on_buz_mute
	.p2align	2
	.type	hmi_on_buz_mute,%function
	.code	16                              @ @hmi_on_buz_mute
	.thumb_func
hmi_on_buz_mute:
	.fnstart
	.cfi_startproc
@ %bb.0:
	movw	r1, :lower16:g_mute
	movt	r1, :upper16:g_mute
	ldrb	r0, [r1]
	clz	r0, r0
	lsrs	r0, r0, #5
	strb	r0, [r1]
	bx	lr
.Lfunc_end25:
	.size	hmi_on_buz_mute, .Lfunc_end25-hmi_on_buz_mute
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_on_cal_zero,"ax",%progbits
	.hidden	hmi_on_cal_zero                 @ -- Begin function hmi_on_cal_zero
	.globl	hmi_on_cal_zero
	.p2align	2
	.type	hmi_on_cal_zero,%function
	.code	16                              @ @hmi_on_cal_zero
	.thumb_func
hmi_on_cal_zero:
	.fnstart
	.cfi_startproc
@ %bb.0:
	movw	r1, :lower16:g_cal_req
	movt	r1, :upper16:g_cal_req
	movs	r0, #1
	strb	r0, [r1]
	bx	lr
.Lfunc_end26:
	.size	hmi_on_cal_zero, .Lfunc_end26-hmi_on_cal_zero
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_on_sensor_zero_hw,"ax",%progbits
	.hidden	hmi_on_sensor_zero_hw           @ -- Begin function hmi_on_sensor_zero_hw
	.globl	hmi_on_sensor_zero_hw
	.p2align	2
	.type	hmi_on_sensor_zero_hw,%function
	.code	16                              @ @hmi_on_sensor_zero_hw
	.thumb_func
hmi_on_sensor_zero_hw:
	.fnstart
	.cfi_startproc
@ %bb.0:
	movw	r1, :lower16:g_cal_req
	movt	r1, :upper16:g_cal_req
	movs	r0, #4
	strb	r0, [r1]
	bx	lr
.Lfunc_end27:
	.size	hmi_on_sensor_zero_hw, .Lfunc_end27-hmi_on_sensor_zero_hw
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_on_sensor_lo15,"ax",%progbits
	.hidden	hmi_on_sensor_lo15              @ -- Begin function hmi_on_sensor_lo15
	.globl	hmi_on_sensor_lo15
	.p2align	2
	.type	hmi_on_sensor_lo15,%function
	.code	16                              @ @hmi_on_sensor_lo15
	.thumb_func
hmi_on_sensor_lo15:
	.fnstart
	.cfi_startproc
@ %bb.0:
	movw	r1, :lower16:g_cal_req
	movt	r1, :upper16:g_cal_req
	movs	r0, #5
	strb	r0, [r1]
	bx	lr
.Lfunc_end28:
	.size	hmi_on_sensor_lo15, .Lfunc_end28-hmi_on_sensor_lo15
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_on_cal_span,"ax",%progbits
	.hidden	hmi_on_cal_span                 @ -- Begin function hmi_on_cal_span
	.globl	hmi_on_cal_span
	.p2align	2
	.type	hmi_on_cal_span,%function
	.code	16                              @ @hmi_on_cal_span
	.thumb_func
hmi_on_cal_span:
	.fnstart
	.cfi_startproc
@ %bb.0:
	movw	r1, :lower16:g_cal_req
	movt	r1, :upper16:g_cal_req
	movs	r0, #2
	strb	r0, [r1]
	bx	lr
.Lfunc_end29:
	.size	hmi_on_cal_span, .Lfunc_end29-hmi_on_cal_span
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_on_cal_factory,"ax",%progbits
	.hidden	hmi_on_cal_factory              @ -- Begin function hmi_on_cal_factory
	.globl	hmi_on_cal_factory
	.p2align	2
	.type	hmi_on_cal_factory,%function
	.code	16                              @ @hmi_on_cal_factory
	.thumb_func
hmi_on_cal_factory:
	.fnstart
	.cfi_startproc
@ %bb.0:
	movw	r1, :lower16:g_cal_req
	movt	r1, :upper16:g_cal_req
	movs	r0, #3
	strb	r0, [r1]
	bx	lr
.Lfunc_end30:
	.size	hmi_on_cal_factory, .Lfunc_end30-hmi_on_cal_factory
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_on_hist_clear,"ax",%progbits
	.hidden	hmi_on_hist_clear               @ -- Begin function hmi_on_hist_clear
	.globl	hmi_on_hist_clear
	.p2align	2
	.type	hmi_on_hist_clear,%function
	.code	16                              @ @hmi_on_hist_clear
	.thumb_func
hmi_on_hist_clear:
	.fnstart
	.cfi_startproc
@ %bb.0:
	movw	r1, :lower16:g_hist_clear_req
	movt	r1, :upper16:g_hist_clear_req
	movs	r0, #1
	strb	r0, [r1]
	bx	lr
.Lfunc_end31:
	.size	hmi_on_hist_clear, .Lfunc_end31-hmi_on_hist_clear
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_on_tbl_page,"ax",%progbits
	.hidden	hmi_on_tbl_page                 @ -- Begin function hmi_on_tbl_page
	.globl	hmi_on_tbl_page
	.p2align	2
	.type	hmi_on_tbl_page,%function
	.code	16                              @ @hmi_on_tbl_page
	.thumb_func
hmi_on_tbl_page:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#16
	sub	sp, #16
	.cfi_def_cfa_offset 24
	str	r0, [sp, #12]
	movs	r0, #24
	bl	history_page_count
	strh.w	r0, [sp, #10]
	movw	r0, :lower16:g_tbl_page
	movt	r0, :upper16:g_tbl_page
	ldrh	r0, [r0]
	ldr	r1, [sp, #12]
	add	r0, r1
	str	r0, [sp, #4]
	ldr	r0, [sp, #4]
	cmp	r0, #0
	bgt	.LBB32_2
	b	.LBB32_1
.LBB32_1:
	movs	r0, #1
	str	r0, [sp, #4]
	b	.LBB32_2
.LBB32_2:
	ldrh.w	r0, [sp, #4]
	ldrh.w	r1, [sp, #10]
	cmp	r0, r1
	ble	.LBB32_4
	b	.LBB32_3
.LBB32_3:
	ldrh.w	r0, [sp, #10]
	str	r0, [sp, #4]
	b	.LBB32_4
.LBB32_4:
	ldr	r0, [sp, #4]
	movw	r1, :lower16:g_tbl_page
	movt	r1, :upper16:g_tbl_page
	strh	r0, [r1]
	movw	r1, :lower16:g_refill_req
	movt	r1, :upper16:g_refill_req
	movs	r0, #1
	strb	r0, [r1]
	add	sp, #16
	pop	{r7, pc}
.Lfunc_end32:
	.size	hmi_on_tbl_page, .Lfunc_end32-hmi_on_tbl_page
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_get_page,"ax",%progbits
	.hidden	hmi_get_page                    @ -- Begin function hmi_get_page
	.globl	hmi_get_page
	.p2align	2
	.type	hmi_get_page,%function
	.code	16                              @ @hmi_get_page
	.thumb_func
hmi_get_page:
	.fnstart
	.cfi_startproc
@ %bb.0:
	movw	r0, :lower16:g_page_now
	movt	r0, :upper16:g_page_now
	ldrb	r0, [r0]
	bx	lr
.Lfunc_end33:
	.size	hmi_get_page, .Lfunc_end33-hmi_get_page
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_on_page_enter,"ax",%progbits
	.hidden	hmi_on_page_enter               @ -- Begin function hmi_on_page_enter
	.globl	hmi_on_page_enter
	.p2align	2
	.type	hmi_on_page_enter,%function
	.code	16                              @ @hmi_on_page_enter
	.thumb_func
hmi_on_page_enter:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.pad	#4
	sub	sp, #4
	.cfi_def_cfa_offset 4
	str	r0, [sp]
	ldr	r0, [sp]
	movw	r1, :lower16:g_page_now
	movt	r1, :upper16:g_page_now
	strb	r0, [r1]
	movw	r1, :lower16:g_full_dirty
	movt	r1, :upper16:g_full_dirty
	movs	r0, #1
	strb	r0, [r1]
	ldr	r0, [sp]
	cmp	r0, #1
	bne	.LBB34_2
	b	.LBB34_1
.LBB34_1:
	movw	r1, :lower16:g_cal_st_dirty
	movt	r1, :upper16:g_cal_st_dirty
	movs	r0, #1
	strb	r0, [r1]
	movw	r1, :lower16:g_thr_push
	movt	r1, :upper16:g_thr_push
	strb	r0, [r1]
	b	.LBB34_2
.LBB34_2:
	ldr	r0, [sp]
	cmp	r0, #5
	bne	.LBB34_4
	b	.LBB34_3
.LBB34_3:
	movw	r1, :lower16:g_cal_st_dirty
	movt	r1, :upper16:g_cal_st_dirty
	movs	r0, #1
	strb	r0, [r1]
	b	.LBB34_4
.LBB34_4:
	ldr	r0, [sp]
	cmp	r0, #2
	bne	.LBB34_6
	b	.LBB34_5
.LBB34_5:
	movw	r1, :lower16:g_tbl_page
	movt	r1, :upper16:g_tbl_page
	movs	r0, #1
	strh	r0, [r1]
	movw	r1, :lower16:g_refill_req
	movt	r1, :upper16:g_refill_req
	strb	r0, [r1]
	b	.LBB34_6
.LBB34_6:
	add	sp, #4
	bx	lr
.Lfunc_end34:
	.size	hmi_on_page_enter, .Lfunc_end34-hmi_on_page_enter
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_on_test_toggle,"ax",%progbits
	.hidden	hmi_on_test_toggle              @ -- Begin function hmi_on_test_toggle
	.globl	hmi_on_test_toggle
	.p2align	2
	.type	hmi_on_test_toggle,%function
	.code	16                              @ @hmi_on_test_toggle
	.thumb_func
hmi_on_test_toggle:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	movw	r0, :lower16:g_test
	movt	r0, :upper16:g_test
	ldrb	r1, [r0]
	clz	r1, r1
	lsrs	r1, r1, #5
	strb	r1, [r0]
	ldrb	r0, [r0]
	cbz	r0, .LBB35_2
	b	.LBB35_1
.LBB35_1:
	bl	HAL_GetTick
	movw	r1, :lower16:g_test_t0
	movt	r1, :upper16:g_test_t0
	str	r0, [r1]
	movw	r1, :lower16:g_sess_sum
	movt	r1, :upper16:g_sess_sum
	movs	r0, #0
	strd	r0, r0, [r1]
	movw	r1, :lower16:g_sess_cnt
	movt	r1, :upper16:g_sess_cnt
	str	r0, [r1]
	movw	r1, :lower16:g_sess_max
	movt	r1, :upper16:g_sess_max
	strh	r0, [r1]
	movw	r2, :lower16:g_sess_min
	movt	r2, :upper16:g_sess_min
	movw	r1, #65535
	strh	r1, [r2]
	movw	r1, :lower16:g_peak
	movt	r1, :upper16:g_peak
	str	r0, [r1]
	movw	r1, :lower16:g_min
	movt	r1, :upper16:g_min
	movw	r0, #4718
	movt	r0, #19075
	str	r0, [r1]
	b	.LBB35_2
.LBB35_2:
	movw	r0, :lower16:g_test
	movt	r0, :upper16:g_test
	ldrb	r0, [r0]
	bl	pump_set
	movw	r1, :lower16:g_full_dirty
	movt	r1, :upper16:g_full_dirty
	movs	r0, #1
	strb	r0, [r1]
	pop	{r7, pc}
.Lfunc_end35:
	.size	hmi_on_test_toggle, .Lfunc_end35-hmi_on_test_toggle
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.thr_apply_hi_val,"ax",%progbits
	.p2align	2                               @ -- Begin function thr_apply_hi_val
	.type	thr_apply_hi_val,%function
	.code	16                              @ @thr_apply_hi_val
	.thumb_func
thr_apply_hi_val:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#8
	sub	sp, #8
	.cfi_def_cfa_offset 16
	str	r0, [sp, #4]
	ldr	r0, [sp, #4]
	cmp	r0, #99
	bhi	.LBB36_2
	b	.LBB36_1
.LBB36_1:
	movs	r0, #100
	str	r0, [sp, #4]
	b	.LBB36_2
.LBB36_2:
	ldr	r0, [sp, #4]
	movw	r1, #1501
	cmp	r0, r1
	blo	.LBB36_4
	b	.LBB36_3
.LBB36_3:
	movw	r0, #1500
	str	r0, [sp, #4]
	b	.LBB36_4
.LBB36_4:
	ldr	r0, [sp, #4]
	movw	r1, :lower16:g_param
	movt	r1, :upper16:g_param
	ldrh	r1, [r1, #30]
	cmp	r0, r1
	bhs	.LBB36_6
	b	.LBB36_5
.LBB36_5:
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	ldrh	r0, [r0, #30]
	str	r0, [sp, #4]
	b	.LBB36_6
.LBB36_6:
	ldrh.w	r0, [sp, #4]
	movw	r1, :lower16:g_param
	movt	r1, :upper16:g_param
	ldrh	r1, [r1, #28]
	cmp	r0, r1
	bne	.LBB36_8
	b	.LBB36_7
.LBB36_7:
	b	.LBB36_9
.LBB36_8:
	ldr	r0, [sp, #4]
	movw	r1, :lower16:g_param
	movt	r1, :upper16:g_param
	strh	r0, [r1, #28]
	bl	thr_commit
	b	.LBB36_9
.LBB36_9:
	add	sp, #8
	pop	{r7, pc}
.Lfunc_end36:
	.size	thr_apply_hi_val, .Lfunc_end36-thr_apply_hi_val
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.rtc_to_epoch,"ax",%progbits
	.p2align	2                               @ -- Begin function rtc_to_epoch
	.type	rtc_to_epoch,%function
	.code	16                              @ @rtc_to_epoch
	.thumb_func
rtc_to_epoch:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.pad	#52
	sub	sp, #52
	.cfi_def_cfa_offset 52
	ldr.w	r12, [sp, #56]
	ldr.w	r12, [sp, #52]
	str	r0, [sp, #48]
	str	r1, [sp, #44]
	str	r2, [sp, #40]
	str	r3, [sp, #36]
	ldr	r0, [sp, #48]
	str	r0, [sp, #32]
	ldr	r0, [sp, #44]
	str	r0, [sp, #28]
	ldr	r2, [sp, #28]
	ldr	r0, [sp, #32]
	subs	r1, r0, #1
	cmp	r2, #3
	it	lt
	movlt	r0, r1
	str	r0, [sp, #32]
	ldr	r0, [sp, #32]
	cmp	r0, #0
	bmi	.LBB37_2
	b	.LBB37_1
.LBB37_1:
	ldr	r0, [sp, #32]
	str	r0, [sp]                        @ 4-byte Spill
	b	.LBB37_3
.LBB37_2:
	ldr	r0, [sp, #32]
	subw	r0, r0, #399
	str	r0, [sp]                        @ 4-byte Spill
	b	.LBB37_3
.LBB37_3:
	ldr	r0, [sp]                        @ 4-byte Reload
	movw	r2, #34079
	movt	r2, #20971
	smull	r0, r1, r0, r2
	asrs	r0, r1, #7
	add.w	r0, r0, r1, lsr #31
	str	r0, [sp, #24]
	ldr	r3, [sp, #32]
	ldr	r0, [sp, #24]
	mov.w	r1, #400
	mls	r0, r0, r1, r3
	str	r0, [sp, #20]
	ldr	r0, [sp, #28]
	movs	r1, #9
	cmp	r0, #2
	it	gt
	mvngt	r1, #2
	add	r0, r1
	str	r0, [sp, #16]
	ldr	r0, [sp, #16]
	movs	r1, #153
	muls	r0, r1, r0
	adds	r0, #2
	movw	r1, #52429
	movt	r1, #52428
	umull	r0, r1, r0, r1
	ldr	r0, [sp, #40]
	add.w	r0, r0, r1, lsr #2
	subs	r0, #1
	str	r0, [sp, #12]
	ldr	r1, [sp, #20]
	movw	r0, #365
	muls	r0, r1, r0
	add.w	r0, r0, r1, lsr #2
	umull	r2, r1, r1, r2
	sub.w	r0, r0, r1, lsr #5
	ldr	r1, [sp, #12]
	add	r0, r1
	str	r0, [sp, #8]
	ldr	r0, [sp, #24]
	ldr	r2, [sp, #8]
	movw	r1, #15025
	movt	r1, #2
	mla	r0, r0, r1, r2
	movw	r1, #1428
	movt	r1, #65525
	add	r0, r1
	str	r0, [sp, #4]
	ldr	r0, [sp, #4]
	movw	r1, #675
	muls	r1, r0, r1
	ldr	r0, [sp, #36]
	mov.w	r2, #3600
	muls	r0, r2, r0
	add.w	r0, r0, r1, lsl #7
	ldr	r1, [sp, #52]
	rsb	r1, r1, r1, lsl #4
	add.w	r0, r0, r1, lsl #2
	ldr	r1, [sp, #56]
	add	r0, r1
	add	sp, #52
	bx	lr
.Lfunc_end37:
	.size	rtc_to_epoch, .Lfunc_end37-rtc_to_epoch
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.__NVIC_SystemReset,"ax",%progbits
	.p2align	2                               @ -- Begin function __NVIC_SystemReset
	.type	__NVIC_SystemReset,%function
	.code	16                              @ @__NVIC_SystemReset
	.thumb_func
__NVIC_SystemReset:
	.fnstart
	.cfi_startproc
@ %bb.0:
	dsb	sy
	movw	r1, #60684
	movt	r1, #57344
	ldr	r0, [r1]
	and	r0, r0, #1792
	movs	r2, #4
	movt	r2, #1530
	orrs	r0, r2
	str	r0, [r1]
	dsb	sy
	b	.LBB38_1
.LBB38_1:                               @ =>This Inner Loop Header: Depth=1
	nop
	b	.LBB38_1
.Lfunc_end38:
	.size	__NVIC_SystemReset, .Lfunc_end38-__NVIC_SystemReset
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_push_device_info,"ax",%progbits
	.p2align	2                               @ -- Begin function hmi_push_device_info
	.type	hmi_push_device_info,%function
	.code	16                              @ @hmi_push_device_info
	.thumb_func
hmi_push_device_info:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#56
	sub	sp, #56
	.cfi_def_cfa_offset 64
	movw	r2, :lower16:.L.str.34
	movt	r2, :upper16:.L.str.34
	movw	r3, :lower16:.L.str.35
	movt	r3, :upper16:.L.str.35
	add	r0, sp, #8
	str	r0, [sp, #4]                    @ 4-byte Spill
	movs	r1, #48
	str	r1, [sp]                        @ 4-byte Spill
	bl	snprintf
	ldr	r1, [sp, #4]                    @ 4-byte Reload
	movw	r0, :lower16:.L.str.36
	movt	r0, :upper16:.L.str.36
	bl	tjc_set_txt
	bl	device_id_get
	ldr	r1, [sp]                        @ 4-byte Reload
	mov	r3, r0
	ldr	r0, [sp, #4]                    @ 4-byte Reload
	movw	r2, :lower16:.L.str.37
	movt	r2, :upper16:.L.str.37
	bl	snprintf
	ldr	r1, [sp, #4]                    @ 4-byte Reload
	movw	r0, :lower16:.L.str.38
	movt	r0, :upper16:.L.str.38
	bl	tjc_set_txt
	add	sp, #56
	pop	{r7, pc}
.Lfunc_end39:
	.size	hmi_push_device_info, .Lfunc_end39-hmi_push_device_info
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.rtc_time_sync_poll,"ax",%progbits
	.p2align	2                               @ -- Begin function rtc_time_sync_poll
	.type	rtc_time_sync_poll,%function
	.code	16                              @ @rtc_time_sync_poll
	.thumb_func
rtc_time_sync_poll:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#8
	sub	sp, #8
	.cfi_def_cfa_offset 16
	bl	HAL_GetTick
	str	r0, [sp, #4]
	movw	r0, :lower16:g_sync_st
	movt	r0, :upper16:g_sync_st
	ldrb	r0, [r0]
	cmp	r0, #2
	blo	.LBB40_2
	b	.LBB40_1
.LBB40_1:
	b	.LBB40_17
.LBB40_2:
	movw	r0, :lower16:g_sync_st
	movt	r0, :upper16:g_sync_st
	ldrb	r0, [r0]
	cbnz	r0, .LBB40_7
	b	.LBB40_3
.LBB40_3:
	movw	r0, :lower16:g_time_sync_idx
	movt	r0, :upper16:g_time_sync_idx
	ldrb	r0, [r0]
	cbz	r0, .LBB40_7
	b	.LBB40_4
.LBB40_4:
	ldr	r0, [sp, #4]
	movw	r1, :lower16:g_sync_t0
	movt	r1, :upper16:g_sync_t0
	ldr	r1, [r1]
	subs	r0, r0, r1
	lsrs	r0, r0, #4
	cmp	r0, #74
	bhi	.LBB40_6
	b	.LBB40_5
.LBB40_5:
	b	.LBB40_17
.LBB40_6:
	b	.LBB40_7
.LBB40_7:
	movw	r0, :lower16:g_rtc_wait
	movt	r0, :upper16:g_rtc_wait
	ldrb	r0, [r0]
	cbz	r0, .LBB40_11
	b	.LBB40_8
.LBB40_8:
	ldr	r0, [sp, #4]
	movw	r1, :lower16:g_sync_deadline
	movt	r1, :upper16:g_sync_deadline
	ldr	r1, [r1]
	cmp	r0, r1
	bls	.LBB40_10
	b	.LBB40_9
.LBB40_9:
	movw	r1, :lower16:g_rtc_wait
	movt	r1, :upper16:g_rtc_wait
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_time_sync_idx
	movt	r1, :upper16:g_time_sync_idx
	strb	r0, [r1]
	b	.LBB40_10
.LBB40_10:
	b	.LBB40_17
.LBB40_11:
	movw	r0, :lower16:g_get_busy
	movt	r0, :upper16:g_get_busy
	ldrb	r0, [r0]
	cbz	r0, .LBB40_13
	b	.LBB40_12
.LBB40_12:
	b	.LBB40_17
.LBB40_13:
	movw	r1, :lower16:g_rtc_wait
	movt	r1, :upper16:g_rtc_wait
	movs	r0, #1
	strb	r0, [r1]
	ldr	r0, [sp, #4]
	add.w	r0, r0, #500
	movw	r1, :lower16:g_sync_deadline
	movt	r1, :upper16:g_sync_deadline
	str	r0, [r1]
	movw	r0, :lower16:g_sync_st
	movt	r0, :upper16:g_sync_st
	ldrb	r0, [r0]
	cbnz	r0, .LBB40_15
	b	.LBB40_14
.LBB40_14:
	movw	r0, :lower16:.L.str.39
	movt	r0, :upper16:.L.str.39
	str	r0, [sp]                        @ 4-byte Spill
	b	.LBB40_16
.LBB40_15:
	movw	r0, :lower16:g_time_sync_idx
	movt	r0, :upper16:g_time_sync_idx
	ldrb	r1, [r0]
	movw	r0, :lower16:RTC_MIRROR
	movt	r0, :upper16:RTC_MIRROR
	ldr.w	r0, [r0, r1, lsl #2]
	str	r0, [sp]                        @ 4-byte Spill
	b	.LBB40_16
.LBB40_16:
	ldr	r0, [sp]                        @ 4-byte Reload
	movw	r1, :lower16:.L.str.40
	movt	r1, :upper16:.L.str.40
	bl	tjc_get
	b	.LBB40_17
.LBB40_17:
	add	sp, #8
	pop	{r7, pc}
.Lfunc_end40:
	.size	rtc_time_sync_poll, .Lfunc_end40-rtc_time_sync_poll
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.thr_hi_readback_poll,"ax",%progbits
	.p2align	2                               @ -- Begin function thr_hi_readback_poll
	.type	thr_hi_readback_poll,%function
	.code	16                              @ @thr_hi_readback_poll
	.thumb_func
thr_hi_readback_poll:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#8
	sub	sp, #8
	.cfi_def_cfa_offset 16
	bl	HAL_GetTick
	str	r0, [sp, #4]
	movw	r0, :lower16:g_thr_hi_req
	movt	r0, :upper16:g_thr_hi_req
	ldrb	r0, [r0]
	cbnz	r0, .LBB41_2
	b	.LBB41_1
.LBB41_1:
	b	.LBB41_12
.LBB41_2:
	movw	r0, :lower16:g_thr_wait
	movt	r0, :upper16:g_thr_wait
	ldrb	r0, [r0]
	cbz	r0, .LBB41_7
	b	.LBB41_3
.LBB41_3:
	ldr	r0, [sp, #4]
	movw	r1, :lower16:g_thr_deadline
	movt	r1, :upper16:g_thr_deadline
	ldr	r1, [r1]
	cmp	r0, r1
	bls	.LBB41_5
	b	.LBB41_4
.LBB41_4:
	movw	r1, :lower16:g_thr_wait
	movt	r1, :upper16:g_thr_wait
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_get_busy
	movt	r1, :upper16:g_get_busy
	strb	r0, [r1]
	b	.LBB41_6
.LBB41_5:
	b	.LBB41_12
.LBB41_6:
	b	.LBB41_7
.LBB41_7:
	movw	r0, :lower16:g_rtc_wait
	movt	r0, :upper16:g_rtc_wait
	ldrb	r0, [r0]
	cbz	r0, .LBB41_9
	b	.LBB41_8
.LBB41_8:
	b	.LBB41_12
.LBB41_9:
	ldr	r0, [sp, #4]
	movw	r1, :lower16:g_thr_t0
	movt	r1, :upper16:g_thr_t0
	ldr	r1, [r1]
	subs	r0, r0, r1
	cmp.w	r0, #8000
	blo	.LBB41_11
	b	.LBB41_10
.LBB41_10:
	movw	r1, :lower16:g_thr_hi_req
	movt	r1, :upper16:g_thr_hi_req
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_thr_try
	movt	r1, :upper16:g_thr_try
	strb	r0, [r1]
	movw	r1, :lower16:g_get_busy
	movt	r1, :upper16:g_get_busy
	strb	r0, [r1]
	movw	r1, :lower16:g_thr_wait
	movt	r1, :upper16:g_thr_wait
	strb	r0, [r1]
	b	.LBB41_12
.LBB41_11:
	movw	r1, :lower16:g_thr_try
	movt	r1, :upper16:g_thr_try
	ldrb	r0, [r1]
	adds	r0, #1
	strb	r0, [r1]
	movw	r1, :lower16:g_thr_wait
	movt	r1, :upper16:g_thr_wait
	movs	r0, #1
	strb	r0, [r1]
	movw	r1, :lower16:g_get_busy
	movt	r1, :upper16:g_get_busy
	strb	r0, [r1]
	ldr	r0, [sp, #4]
	add.w	r0, r0, #500
	movw	r1, :lower16:g_thr_deadline
	movt	r1, :upper16:g_thr_deadline
	str	r0, [r1]
	movw	r0, :lower16:.L.str.3
	movt	r0, :upper16:.L.str.3
	movw	r1, :lower16:.L.str.40
	movt	r1, :upper16:.L.str.40
	bl	tjc_get
	b	.LBB41_12
.LBB41_12:
	add	sp, #8
	pop	{r7, pc}
.Lfunc_end41:
	.size	thr_hi_readback_poll, .Lfunc_end41-thr_hi_readback_poll
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.refill_table,"ax",%progbits
	.p2align	2                               @ -- Begin function refill_table
	.type	refill_table,%function
	.code	16                              @ @refill_table
	.thumb_func
refill_table:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r4, lr}
	push	{r4, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r4, -8
	.pad	#416
	sub	sp, #416
	.cfi_def_cfa_offset 424
	movw	r0, :lower16:g_tbl_page
	movt	r0, :upper16:g_tbl_page
	ldrh	r0, [r0]
	strh.w	r0, [sp, #216]
	bl	history_total
	str	r0, [sp, #212]
	movs	r0, #24
	bl	history_page_count
	strh.w	r0, [sp, #218]
	ldrh.w	r0, [sp, #216]
	cmp	r0, #0
	bgt	.LBB42_2
	b	.LBB42_1
.LBB42_1:
	movs	r0, #1
	strh.w	r0, [sp, #216]
	b	.LBB42_2
.LBB42_2:
	ldrh.w	r0, [sp, #216]
	ldrh.w	r1, [sp, #218]
	cmp	r0, r1
	ble	.LBB42_4
	b	.LBB42_3
.LBB42_3:
	ldrh.w	r0, [sp, #218]
	strh.w	r0, [sp, #216]
	b	.LBB42_4
.LBB42_4:
	ldrh.w	r0, [sp, #216]
	movw	r1, :lower16:g_tbl_page
	movt	r1, :upper16:g_tbl_page
	strh	r0, [r1]
	ldrh.w	r0, [sp, #216]
	add	r1, sp, #224
	movs	r2, #24
	bl	history_read_page
	strh.w	r0, [sp, #222]
	movs	r0, #0
	strh.w	r0, [sp, #220]
	b	.LBB42_5
.LBB42_5:                               @ =>This Inner Loop Header: Depth=1
	ldrh.w	r0, [sp, #220]
	cmp	r0, #23
	bhi.w	.LBB42_16
	b	.LBB42_6
.LBB42_6:                               @   in Loop: Header=BB42_5 Depth=1
	ldrb.w	r0, [sp, #220]
	lsls	r0, r0, #31
	cbnz	r0, .LBB42_8
	b	.LBB42_7
.LBB42_7:                               @   in Loop: Header=BB42_5 Depth=1
	bl	iwdg_feed
	b	.LBB42_8
.LBB42_8:                               @   in Loop: Header=BB42_5 Depth=1
	ldrh.w	r0, [sp, #220]
	ldrh.w	r1, [sp, #222]
	cmp	r0, r1
	bge	.LBB42_10
	b	.LBB42_9
.LBB42_9:                               @   in Loop: Header=BB42_5 Depth=1
	ldrh.w	r1, [sp, #220]
	add	r0, sp, #224
	str	r0, [sp, #56]                   @ 4-byte Spill
	ldr.w	r0, [r0, r1, lsl #3]
	mov	r2, sp
	add	r1, sp, #76
	str	r1, [r2, #8]
	add	r1, sp, #80
	str	r1, [r2, #4]
	add	r1, sp, #84
	str	r1, [r2]
	add	r1, sp, #96
	add	r2, sp, #92
	add	r3, sp, #88
	bl	epoch_to_civil
	ldr	r3, [sp, #96]
	ldr	r0, [sp, #92]
	ldr	r2, [sp, #88]
	ldr.w	r12, [sp, #84]
	ldr.w	lr, [sp, #80]
	ldr	r4, [sp, #76]
	mov	r1, sp
	str	r4, [r1, #16]
	str.w	lr, [r1, #12]
	str.w	r12, [r1, #8]
	str	r2, [r1, #4]
	str	r0, [r1]
	movw	r2, :lower16:.L.str.46
	movt	r2, :upper16:.L.str.46
	add.w	r0, sp, #118
	movs	r1, #30
	bl	snprintf
                                        @ kill: def $r1 killed $r0
	ldr	r0, [sp, #56]                   @ 4-byte Reload
	ldrh.w	r1, [sp, #220]
	add.w	r0, r0, r1, lsl #3
	ldrh	r3, [r0, #4]
	movw	r2, :lower16:.L.str.47
	movt	r2, :upper16:.L.str.47
	add.w	r0, sp, #106
	movs	r1, #12
	bl	snprintf
	ldrh.w	r0, [sp, #216]
	add.w	r1, r0, r0, lsl #1
	ldrh.w	r0, [sp, #220]
	add.w	r0, r0, r1, lsl #3
	subs	r0, #24
	str	r0, [sp, #72]
	ldr	r0, [sp, #212]
	ldr	r1, [sp, #72]
	subs	r0, r0, r1
	str	r0, [sp, #68]
	ldr	r0, [sp, #68]
	subs	r2, r0, #1
	movw	r0, #58287
	movt	r0, #1677
	umull	r1, r0, r2, r0
	lsrs	r0, r0, #8
	movw	r1, #9999
	mls	r0, r0, r1, r2
	adds	r0, #1
	str	r0, [sp, #64]
	ldr	r3, [sp, #64]
	movw	r2, :lower16:.L.str.48
	movt	r2, :upper16:.L.str.48
	add	r0, sp, #100
	movs	r1, #6
	bl	snprintf
	b	.LBB42_11
.LBB42_10:                              @   in Loop: Header=BB42_5 Depth=1
	movw	r2, :lower16:.L.str.49
	movt	r2, :upper16:.L.str.49
	str	r2, [sp, #52]                   @ 4-byte Spill
	add.w	r0, sp, #118
	movs	r1, #30
	bl	snprintf
	ldr	r2, [sp, #52]                   @ 4-byte Reload
	add.w	r0, sp, #106
	movs	r1, #12
	bl	snprintf
	ldr	r2, [sp, #52]                   @ 4-byte Reload
	add	r0, sp, #100
	movs	r1, #6
	bl	snprintf
	b	.LBB42_11
.LBB42_11:                              @   in Loop: Header=BB42_5 Depth=1
	ldrh.w	r0, [sp, #220]
	cmp	r0, #11
	bhi	.LBB42_13
	b	.LBB42_12
.LBB42_12:                              @   in Loop: Header=BB42_5 Depth=1
	ldrh.w	r0, [sp, #220]
	lsls	r0, r0, #1
	uxth	r0, r0
	str	r0, [sp, #48]                   @ 4-byte Spill
	b	.LBB42_14
.LBB42_13:                              @   in Loop: Header=BB42_5 Depth=1
	ldrh.w	r1, [sp, #220]
	mvn	r0, #22
	add.w	r0, r0, r1, lsl #1
	uxth	r0, r0
	str	r0, [sp, #48]                   @ 4-byte Spill
	b	.LBB42_14
.LBB42_14:                              @   in Loop: Header=BB42_5 Depth=1
	ldr	r0, [sp, #48]                   @ 4-byte Reload
	strh.w	r0, [sp, #62]
	ldrh.w	r0, [sp, #62]
	mov	r1, sp
	str	r0, [r1]
	movw	r2, :lower16:.L.str.50
	movt	r2, :upper16:.L.str.50
	str	r2, [sp, #40]                   @ 4-byte Spill
	movw	r3, :lower16:.L.str.51
	movt	r3, :upper16:.L.str.51
	add	r0, sp, #164
	str	r0, [sp, #28]                   @ 4-byte Spill
	movs	r1, #8
	str	r1, [sp, #36]                   @ 4-byte Spill
	bl	snprintf
                                        @ kill: def $r1 killed $r0
	ldr	r0, [sp, #28]                   @ 4-byte Reload
	add.w	r1, sp, #118
	bl	tjc_set_txt
	ldr	r1, [sp, #36]                   @ 4-byte Reload
	ldr	r2, [sp, #40]                   @ 4-byte Reload
	ldrh.w	r0, [sp, #62]
	mov	r3, sp
	str	r0, [r3]
	movw	r3, :lower16:.L.str.52
	movt	r3, :upper16:.L.str.52
	add	r0, sp, #156
	str	r0, [sp, #32]                   @ 4-byte Spill
	bl	snprintf
                                        @ kill: def $r1 killed $r0
	ldr	r0, [sp, #32]                   @ 4-byte Reload
	add.w	r1, sp, #106
	bl	tjc_set_txt
	ldr	r1, [sp, #36]                   @ 4-byte Reload
	ldr	r2, [sp, #40]                   @ 4-byte Reload
	ldrh.w	r0, [sp, #62]
	mov	r3, sp
	str	r0, [r3]
	movw	r3, :lower16:.L.str.38
	movt	r3, :upper16:.L.str.38
	add	r0, sp, #148
	str	r0, [sp, #44]                   @ 4-byte Spill
	bl	snprintf
                                        @ kill: def $r1 killed $r0
	ldr	r0, [sp, #44]                   @ 4-byte Reload
	add	r1, sp, #100
	bl	tjc_set_txt
	b	.LBB42_15
.LBB42_15:                              @   in Loop: Header=BB42_5 Depth=1
	ldrh.w	r0, [sp, #220]
	adds	r0, #1
	strh.w	r0, [sp, #220]
	b	.LBB42_5
.LBB42_16:
	ldrh.w	r3, [sp, #216]
	ldrh.w	r0, [sp, #218]
	mov	r1, sp
	str	r0, [r1]
	movw	r2, :lower16:.L.str.53
	movt	r2, :upper16:.L.str.53
	add	r0, sp, #172
	str	r0, [sp, #24]                   @ 4-byte Spill
	movs	r1, #40
	bl	snprintf
	ldr	r1, [sp, #24]                   @ 4-byte Reload
	movw	r0, :lower16:.L.str.54
	movt	r0, :upper16:.L.str.54
	bl	tjc_set_txt
	bl	send_hist_stats
	add	sp, #416
	pop	{r4, pc}
.Lfunc_end42:
	.size	refill_table, .Lfunc_end42-refill_table
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.hmi_update_status_chips,"ax",%progbits
	.p2align	2                               @ -- Begin function hmi_update_status_chips
	.type	hmi_update_status_chips,%function
	.code	16                              @ @hmi_update_status_chips
	.thumb_func
hmi_update_status_chips:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#64
	sub	sp, #64
	.cfi_def_cfa_offset 72
                                        @ kill: def $r1 killed $r0
	strb.w	r0, [sp, #63]
	bl	sensor_online
	str	r0, [sp, #44]
	bl	battery_get_pct
	str	r0, [sp, #40]
	movw	r0, :lower16:g_selftest
	movt	r0, :upper16:g_selftest
	ldrb	r0, [r0]
	str	r0, [sp, #36]
	ldr	r1, [sp, #44]
	movs	r0, #0
	str	r0, [sp, #20]                   @ 4-byte Spill
	cbz	r1, .LBB43_2
	b	.LBB43_1
.LBB43_1:
	ldr	r0, [sp, #36]
	cmp	r0, #0
	it	ne
	movne	r0, #1
	str	r0, [sp, #20]                   @ 4-byte Spill
	b	.LBB43_2
.LBB43_2:
	ldr	r0, [sp, #20]                   @ 4-byte Reload
	and	r0, r0, #1
	strb.w	r0, [sp, #35]
	bl	pump_get
	cmp	r0, #0
	it	ne
	movne	r0, #1
	strb.w	r0, [sp, #34]
	ldr	r0, [sp, #40]
	cmp	r0, #50
	blt	.LBB43_4
	b	.LBB43_3
.LBB43_3:
	movs	r0, #5
	str	r0, [sp, #16]                   @ 4-byte Spill
	b	.LBB43_5
.LBB43_4:
	ldr	r1, [sp, #40]
	movs	r0, #6
	cmp	r1, #19
	it	gt
	movgt	r0, #3
	str	r0, [sp, #16]                   @ 4-byte Spill
	b	.LBB43_5
.LBB43_5:
	ldr	r0, [sp, #16]                   @ 4-byte Reload
	strb.w	r0, [sp, #33]
	movw	r0, :lower16:g_alarm
	movt	r0, :upper16:g_alarm
	ldr	r0, [r0]
	cmp	r0, #2
	blt	.LBB43_7
	b	.LBB43_6
.LBB43_6:
	movw	r0, #59944
	str	r0, [sp, #12]                   @ 4-byte Spill
	b	.LBB43_8
.LBB43_7:
	movw	r0, :lower16:g_alarm
	movt	r0, :upper16:g_alarm
	ldr	r1, [r0]
	movw	r0, #12777
	cmp	r1, #1
	it	eq
	movweq	r0, #62689
	str	r0, [sp, #12]                   @ 4-byte Spill
	b	.LBB43_8
.LBB43_8:
	ldr	r0, [sp, #12]                   @ 4-byte Reload
	str	r0, [sp, #28]
	movw	r0, :lower16:g_full_dirty
	movt	r0, :upper16:g_full_dirty
	ldrb	r0, [r0]
	cbnz	r0, .LBB43_15
	b	.LBB43_9
.LBB43_9:
	ldrb.w	r0, [sp, #63]
	cbnz	r0, .LBB43_15
	b	.LBB43_10
.LBB43_10:
	ldrb.w	r0, [sp, #35]
	movw	r1, :lower16:hmi_update_status_chips.s_dot
	movt	r1, :upper16:hmi_update_status_chips.s_dot
	ldrb	r1, [r1]
	cmp	r0, r1
	bne	.LBB43_15
	b	.LBB43_11
.LBB43_11:
	ldrb.w	r0, [sp, #34]
	movw	r1, :lower16:hmi_update_status_chips.s_pump
	movt	r1, :upper16:hmi_update_status_chips.s_pump
	ldrb	r1, [r1]
	cmp	r0, r1
	bne	.LBB43_15
	b	.LBB43_12
.LBB43_12:
	ldrb.w	r0, [sp, #33]
	movw	r1, :lower16:hmi_update_status_chips.s_bat
	movt	r1, :upper16:hmi_update_status_chips.s_bat
	ldrb	r1, [r1]
	cmp	r0, r1
	bne	.LBB43_15
	b	.LBB43_13
.LBB43_13:
	ldr	r0, [sp, #28]
	movw	r1, :lower16:hmi_update_status_chips.s_strip
	movt	r1, :upper16:hmi_update_status_chips.s_strip
	ldr	r1, [r1]
	cmp	r0, r1
	bne	.LBB43_15
	b	.LBB43_14
.LBB43_14:
	b	.LBB43_27
.LBB43_15:
	ldrb.w	r0, [sp, #35]
	movw	r1, :lower16:hmi_update_status_chips.s_dot
	movt	r1, :upper16:hmi_update_status_chips.s_dot
	strb	r0, [r1]
	ldrb.w	r0, [sp, #34]
	movw	r1, :lower16:hmi_update_status_chips.s_pump
	movt	r1, :upper16:hmi_update_status_chips.s_pump
	strb	r0, [r1]
	ldrb.w	r0, [sp, #33]
	movw	r1, :lower16:hmi_update_status_chips.s_bat
	movt	r1, :upper16:hmi_update_status_chips.s_bat
	strb	r0, [r1]
	ldr	r0, [sp, #28]
	movw	r1, :lower16:hmi_update_status_chips.s_strip
	movt	r1, :upper16:hmi_update_status_chips.s_strip
	str	r0, [r1]
	movw	r0, :lower16:.L.str.13
	movt	r0, :upper16:.L.str.13
	str	r0, [sp, #24]
	movw	r0, :lower16:g_page_init
	movt	r0, :upper16:g_page_init
	ldrb	r0, [r0]
	cbz	r0, .LBB43_17
	b	.LBB43_16
.LBB43_16:
	movw	r0, :lower16:.L.str.14
	movt	r0, :upper16:.L.str.14
	str	r0, [sp, #24]
	b	.LBB43_26
.LBB43_17:
	movw	r0, :lower16:g_page_now
	movt	r0, :upper16:g_page_now
	ldrb	r0, [r0]
	cbnz	r0, .LBB43_19
	b	.LBB43_18
.LBB43_18:
	movw	r0, :lower16:.L.str.15
	movt	r0, :upper16:.L.str.15
	str	r0, [sp, #24]
	b	.LBB43_25
.LBB43_19:
	movw	r0, :lower16:g_page_now
	movt	r0, :upper16:g_page_now
	ldrb	r0, [r0]
	cmp	r0, #2
	bne	.LBB43_21
	b	.LBB43_20
.LBB43_20:
	movw	r0, :lower16:.L.str.16
	movt	r0, :upper16:.L.str.16
	str	r0, [sp, #24]
	b	.LBB43_24
.LBB43_21:
	movw	r0, :lower16:g_page_now
	movt	r0, :upper16:g_page_now
	ldrb	r0, [r0]
	cmp	r0, #5
	bne	.LBB43_23
	b	.LBB43_22
.LBB43_22:
	movw	r0, :lower16:.L.str.17
	movt	r0, :upper16:.L.str.17
	str	r0, [sp, #24]
	b	.LBB43_23
.LBB43_23:
	b	.LBB43_24
.LBB43_24:
	b	.LBB43_25
.LBB43_25:
	b	.LBB43_26
.LBB43_26:
	ldr	r3, [sp, #24]
	movw	r2, :lower16:.L.str.62
	movt	r2, :upper16:.L.str.62
	add.w	r0, sp, #51
	str	r0, [sp, #8]                    @ 4-byte Spill
	movs	r1, #12
	str	r1, [sp, #4]                    @ 4-byte Spill
	bl	snprintf
                                        @ kill: def $r1 killed $r0
	ldr	r0, [sp, #8]                    @ 4-byte Reload
	ldrb.w	r2, [sp, #35]
	movs	r1, #4
	str	r1, [sp]                        @ 4-byte Spill
	cmp	r2, #0
	it	ne
	movne	r1, #5
	bl	tjc_pic
	ldr	r1, [sp, #4]                    @ 4-byte Reload
	ldr	r0, [sp, #8]                    @ 4-byte Reload
	ldr	r3, [sp, #24]
	movw	r2, :lower16:.L.str.63
	movt	r2, :upper16:.L.str.63
	bl	snprintf
	ldr	r1, [sp]                        @ 4-byte Reload
                                        @ kill: def $r2 killed $r0
	ldr	r0, [sp, #8]                    @ 4-byte Reload
	ldrb.w	r2, [sp, #34]
	cmp	r2, #0
	it	ne
	movne	r1, #5
	bl	tjc_pic
	ldr	r1, [sp, #4]                    @ 4-byte Reload
	ldr	r0, [sp, #8]                    @ 4-byte Reload
	ldr	r3, [sp, #24]
	movw	r2, :lower16:.L.str.64
	movt	r2, :upper16:.L.str.64
	bl	snprintf
                                        @ kill: def $r1 killed $r0
	ldr	r0, [sp, #8]                    @ 4-byte Reload
	ldrb.w	r1, [sp, #33]
	bl	tjc_pic
	ldr	r1, [sp, #4]                    @ 4-byte Reload
	ldr	r0, [sp, #8]                    @ 4-byte Reload
	ldr	r3, [sp, #24]
	movw	r2, :lower16:.L.str.65
	movt	r2, :upper16:.L.str.65
	bl	snprintf
                                        @ kill: def $r1 killed $r0
	ldr	r0, [sp, #8]                    @ 4-byte Reload
	ldr	r1, [sp, #28]
	bl	tjc_set_bco
	ldr	r1, [sp, #4]                    @ 4-byte Reload
	ldr	r0, [sp, #8]                    @ 4-byte Reload
	ldr	r3, [sp, #24]
	movw	r2, :lower16:.L.str.66
	movt	r2, :upper16:.L.str.66
	bl	snprintf
                                        @ kill: def $r1 killed $r0
	ldr	r0, [sp, #8]                    @ 4-byte Reload
	ldr	r3, [sp, #44]
	movw	r2, :lower16:.L.str.67
	movt	r2, :upper16:.L.str.67
	movw	r1, :lower16:.L.str.68
	movt	r1, :upper16:.L.str.68
	cmp	r3, #0
	it	ne
	movne	r1, r2
	bl	tjc_set_txt
	ldr	r1, [sp, #4]                    @ 4-byte Reload
	ldr	r0, [sp, #8]                    @ 4-byte Reload
	ldr	r3, [sp, #24]
	movw	r2, :lower16:.L.str.69
	movt	r2, :upper16:.L.str.69
	bl	snprintf
                                        @ kill: def $r1 killed $r0
	ldr	r0, [sp, #8]                    @ 4-byte Reload
	ldrb.w	r3, [sp, #34]
	movw	r2, :lower16:.L.str.70
	movt	r2, :upper16:.L.str.70
	movw	r1, :lower16:.L.str.71
	movt	r1, :upper16:.L.str.71
	cmp	r3, #0
	it	ne
	movne	r1, r2
	bl	tjc_set_txt
	b	.LBB43_27
.LBB43_27:
	add	sp, #64
	pop	{r7, pc}
.Lfunc_end43:
	.size	hmi_update_status_chips, .Lfunc_end43-hmi_update_status_chips
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.epoch_to_civil,"ax",%progbits
	.p2align	2                               @ -- Begin function epoch_to_civil
	.type	epoch_to_civil,%function
	.code	16                              @ @epoch_to_civil
	.thumb_func
epoch_to_civil:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r4, lr}
	push	{r4, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r4, -8
	.pad	#128
	sub	sp, #128
	.cfi_def_cfa_offset 136
	ldr.w	r12, [sp, #144]
	ldr.w	r12, [sp, #140]
	ldr.w	r12, [sp, #136]
	str	r0, [sp, #124]
	str	r1, [sp, #120]
	str	r2, [sp, #116]
	str	r3, [sp, #112]
	ldr	r0, [sp, #124]
	movw	r1, #17671
	movt	r1, #49710
	umull	r2, r0, r0, r1
	lsrs	r0, r0, #16
	str	r0, [sp, #108]
	ldr	r0, [sp, #124]
	umull	r2, r1, r0, r1
	lsrs	r1, r1, #16
	movw	r2, #675
	muls	r1, r2, r1
	sub.w	r0, r0, r1, lsl #7
	str	r0, [sp, #104]
	ldr	r1, [sp, #104]
	movw	r0, #46021
	movt	r0, #37282
	umull	r2, r1, r1, r0
	lsrs	r1, r1, #11
	str	r1, [sp, #100]
	ldr	r2, [sp, #104]
	umull	r1, r0, r2, r0
	lsrs	r0, r0, #11
	mov.w	r1, #3600
	mls	r0, r0, r1, r2
	movw	r1, #17477
	movt	r1, #1092
	umull	r1, r0, r0, r1
	str	r0, [sp, #96]
	ldr	r0, [sp, #104]
	movw	r1, #34953
	movt	r1, #34952
	umull	r1, r2, r0, r1
	lsrs	r1, r2, #5
	lsls	r1, r1, #4
	sub.w	r1, r1, r2, lsr #5
	sub.w	r0, r0, r1, lsl #2
	str	r0, [sp, #92]
	ldr	r0, [sp, #108]
	movw	r1, #64108
	movt	r1, #10
	adds	r1, r1, r0
	mov.w	r3, #0
	str	r3, [sp, #24]                   @ 4-byte Spill
	adc	r0, r3, #0
	str	r1, [sp, #80]
	str	r0, [sp, #84]
	ldr	r0, [sp, #80]
	ldr	r1, [sp, #84]
	movw	r2, #15025
	movt	r2, #2
	str	r2, [sp, #4]                    @ 4-byte Spill
	bl	__aeabi_uldivmod
	ldr	r3, [sp, #24]                   @ 4-byte Reload
	ldr.w	lr, [sp, #4]                    @ 4-byte Reload
	str	r1, [sp, #76]
	str	r0, [sp, #72]
	ldr	r1, [sp, #80]
	ldr	r0, [sp, #84]
	ldr.w	r12, [sp, #72]
	ldr	r2, [sp, #76]
	umull	r12, r4, r12, lr
	mla	r2, r2, lr, r4
	subs.w	r1, r1, r12
	sbcs	r0, r2
	str	r1, [sp, #64]
	str	r0, [sp, #68]
	ldr	r0, [sp, #64]
	str	r0, [sp, #16]                   @ 4-byte Spill
	ldr	r1, [sp, #68]
	str	r1, [sp, #20]                   @ 4-byte Spill
	movw	r2, #1460
	bl	__aeabi_uldivmod
	ldr	r3, [sp, #24]                   @ 4-byte Reload
	mov	r12, r0
	ldr	r0, [sp, #16]                   @ 4-byte Reload
	mov	r2, r1
	ldr	r1, [sp, #20]                   @ 4-byte Reload
	subs.w	r12, r0, r12
	str.w	r12, [sp, #12]                  @ 4-byte Spill
	sbc.w	r2, r1, r2
	str	r2, [sp, #8]                    @ 4-byte Spill
	movw	r2, #36524
	bl	__aeabi_uldivmod
	ldr	r2, [sp, #8]                    @ 4-byte Reload
	ldr	r3, [sp, #24]                   @ 4-byte Reload
	ldr.w	lr, [sp, #12]                   @ 4-byte Reload
	mov	r4, r0
	ldr	r0, [sp, #16]                   @ 4-byte Reload
	mov	r12, r1
	ldr	r1, [sp, #20]                   @ 4-byte Reload
	adds.w	lr, lr, r4
	str.w	lr, [sp, #28]                   @ 4-byte Spill
	adc.w	r2, r2, r12
	str	r2, [sp, #32]                   @ 4-byte Spill
	movw	r2, #15024
	movt	r2, #2
	bl	__aeabi_uldivmod
	ldr	r3, [sp, #24]                   @ 4-byte Reload
	mov	r12, r0
	ldr	r0, [sp, #28]                   @ 4-byte Reload
	mov	r2, r1
	ldr	r1, [sp, #32]                   @ 4-byte Reload
	subs.w	r0, r0, r12
	sbcs	r1, r2
	movw	r2, #365
	str	r2, [sp, #36]                   @ 4-byte Spill
	bl	__aeabi_uldivmod
	ldr	r1, [sp, #36]                   @ 4-byte Reload
	str	r0, [sp, #60]
	ldr	r3, [sp, #60]
	ldr	r0, [sp, #72]
	mov.w	r2, #400
	mla	r0, r0, r2, r3
	str	r0, [sp, #56]
	ldr	r0, [sp, #64]
	ldr	r2, [sp, #60]
	muls	r1, r2, r1
	add.w	r1, r1, r2, lsr #2
	movw	r3, #34079
	movt	r3, #20971
	umull	r3, r2, r2, r3
	rsb	r1, r1, r2, lsr #5
	add	r0, r1
	str	r0, [sp, #52]
	ldr	r0, [sp, #52]
	add.w	r0, r0, r0, lsl #2
	adds	r0, #2
	movw	r1, #32983
	movt	r1, #54827
	umull	r1, r0, r0, r1
	lsrs	r0, r0, #7
	str	r0, [sp, #48]
	ldr	r0, [sp, #52]
	ldr	r1, [sp, #48]
	movs	r2, #153
	muls	r1, r2, r1
	adds	r1, #2
	movw	r2, #52429
	movt	r2, #52428
	umull	r2, r1, r1, r2
	sub.w	r0, r0, r1, lsr #2
	adds	r0, #1
	str	r0, [sp, #44]
	ldr	r0, [sp, #48]
	cmp	r0, #9
	bhi	.LBB44_2
	b	.LBB44_1
.LBB44_1:
	ldr	r0, [sp, #48]
	adds	r0, #3
	str	r0, [sp]                        @ 4-byte Spill
	b	.LBB44_3
.LBB44_2:
	ldr	r0, [sp, #48]
	subs	r0, #9
	str	r0, [sp]                        @ 4-byte Spill
	b	.LBB44_3
.LBB44_3:
	ldr	r0, [sp]                        @ 4-byte Reload
	str	r0, [sp, #40]
	ldr	r2, [sp, #40]
	ldr	r0, [sp, #56]
	adds	r1, r0, #1
	cmp	r2, #3
	it	lo
	movlo	r0, r1
	str	r0, [sp, #56]
	ldr	r0, [sp, #120]
	cbz	r0, .LBB44_5
	b	.LBB44_4
.LBB44_4:
	ldr	r0, [sp, #56]
	ldr	r1, [sp, #120]
	str	r0, [r1]
	b	.LBB44_5
.LBB44_5:
	ldr	r0, [sp, #116]
	cbz	r0, .LBB44_7
	b	.LBB44_6
.LBB44_6:
	ldr	r0, [sp, #40]
	ldr	r1, [sp, #116]
	str	r0, [r1]
	b	.LBB44_7
.LBB44_7:
	ldr	r0, [sp, #112]
	cbz	r0, .LBB44_9
	b	.LBB44_8
.LBB44_8:
	ldr	r0, [sp, #44]
	ldr	r1, [sp, #112]
	str	r0, [r1]
	b	.LBB44_9
.LBB44_9:
	ldr	r0, [sp, #136]
	cbz	r0, .LBB44_11
	b	.LBB44_10
.LBB44_10:
	ldr	r0, [sp, #100]
	ldr	r1, [sp, #136]
	str	r0, [r1]
	b	.LBB44_11
.LBB44_11:
	ldr	r0, [sp, #140]
	cbz	r0, .LBB44_13
	b	.LBB44_12
.LBB44_12:
	ldr	r0, [sp, #96]
	ldr	r1, [sp, #140]
	str	r0, [r1]
	b	.LBB44_13
.LBB44_13:
	ldr	r0, [sp, #144]
	cbz	r0, .LBB44_15
	b	.LBB44_14
.LBB44_14:
	ldr	r0, [sp, #92]
	ldr	r1, [sp, #144]
	str	r0, [r1]
	b	.LBB44_15
.LBB44_15:
	add	sp, #128
	pop	{r4, pc}
.Lfunc_end44:
	.size	epoch_to_civil, .Lfunc_end44-epoch_to_civil
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.send_hist_stats,"ax",%progbits
	.p2align	2                               @ -- Begin function send_hist_stats
	.type	send_hist_stats,%function
	.code	16                              @ @send_hist_stats
	.thumb_func
send_hist_stats:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#72
	sub	sp, #72
	.cfi_def_cfa_offset 80
	movw	r0, :lower16:g_sess_cnt
	movt	r0, :upper16:g_sess_cnt
	ldr	r0, [r0]
	cmp	r0, #0
	bne	.LBB45_2
	b	.LBB45_1
.LBB45_1:
	movw	r2, :lower16:.L.str.55
	movt	r2, :upper16:.L.str.55
	str	r2, [sp, #40]                   @ 4-byte Spill
	add	r0, sp, #48
	str	r0, [sp, #44]                   @ 4-byte Spill
	movs	r1, #24
	str	r1, [sp, #36]                   @ 4-byte Spill
	bl	snprintf
	ldr	r1, [sp, #44]                   @ 4-byte Reload
	movw	r0, :lower16:.L.str.56
	movt	r0, :upper16:.L.str.56
	bl	tjc_set_txt
	ldr	r1, [sp, #36]                   @ 4-byte Reload
	ldr	r2, [sp, #40]                   @ 4-byte Reload
	ldr	r0, [sp, #44]                   @ 4-byte Reload
	bl	snprintf
	ldr	r1, [sp, #44]                   @ 4-byte Reload
	movw	r0, :lower16:.L.str.57
	movt	r0, :upper16:.L.str.57
	bl	tjc_set_txt
	ldr	r1, [sp, #36]                   @ 4-byte Reload
	ldr	r2, [sp, #40]                   @ 4-byte Reload
	ldr	r0, [sp, #44]                   @ 4-byte Reload
	bl	snprintf
	ldr	r1, [sp, #44]                   @ 4-byte Reload
	movw	r0, :lower16:.L.str.58
	movt	r0, :upper16:.L.str.58
	bl	tjc_set_txt
	ldr	r1, [sp, #36]                   @ 4-byte Reload
	ldr	r2, [sp, #40]                   @ 4-byte Reload
	ldr	r0, [sp, #44]                   @ 4-byte Reload
	bl	snprintf
	ldr	r1, [sp, #44]                   @ 4-byte Reload
	movw	r0, :lower16:.L.str.59
	movt	r0, :upper16:.L.str.59
	bl	tjc_set_txt
	ldr	r1, [sp, #36]                   @ 4-byte Reload
	ldr	r2, [sp, #40]                   @ 4-byte Reload
	ldr	r0, [sp, #44]                   @ 4-byte Reload
	bl	snprintf
	ldr	r1, [sp, #44]                   @ 4-byte Reload
	movw	r0, :lower16:.L.str.60
	movt	r0, :upper16:.L.str.60
	bl	tjc_set_txt
	b	.LBB45_3
.LBB45_2:
	movw	r0, :lower16:g_sess_max
	movt	r0, :upper16:g_sess_max
	ldrh	r3, [r0]
	movw	r2, :lower16:.L.str.47
	movt	r2, :upper16:.L.str.47
	str	r2, [sp, #28]                   @ 4-byte Spill
	add	r0, sp, #48
	str	r0, [sp, #32]                   @ 4-byte Spill
	movs	r1, #24
	str	r1, [sp, #24]                   @ 4-byte Spill
	bl	snprintf
	ldr	r1, [sp, #32]                   @ 4-byte Reload
	movw	r0, :lower16:.L.str.56
	movt	r0, :upper16:.L.str.56
	bl	tjc_set_txt
	movw	r0, :lower16:g_sess_sum
	movt	r0, :upper16:g_sess_sum
	ldrd	r0, r1, [r0]
	bl	__aeabi_ul2d
	str	r0, [sp, #12]                   @ 4-byte Spill
	str	r1, [sp, #16]                   @ 4-byte Spill
	movw	r0, :lower16:g_sess_cnt
	movt	r0, :upper16:g_sess_cnt
	str	r0, [sp, #20]                   @ 4-byte Spill
	ldr	r0, [r0]
	bl	__aeabi_ui2d
	mov	r2, r0
	ldr	r0, [sp, #12]                   @ 4-byte Reload
	mov	r3, r1
	ldr	r1, [sp, #16]                   @ 4-byte Reload
	bl	__aeabi_ddiv
	bl	__aeabi_d2f
	bl	__aeabi_f2d
	mov	r2, r0
	ldr	r0, [sp, #32]                   @ 4-byte Reload
	mov	r12, r1
	ldr	r1, [sp, #24]                   @ 4-byte Reload
	mov	r3, sp
	str.w	r12, [r3, #4]
	str	r2, [r3]
	movw	r2, :lower16:.L.str.61
	movt	r2, :upper16:.L.str.61
	bl	snprintf
	ldr	r1, [sp, #32]                   @ 4-byte Reload
	movw	r0, :lower16:.L.str.57
	movt	r0, :upper16:.L.str.57
	bl	tjc_set_txt
	ldr	r1, [sp, #24]                   @ 4-byte Reload
	ldr	r2, [sp, #28]                   @ 4-byte Reload
	ldr	r0, [sp, #32]                   @ 4-byte Reload
	movw	r3, :lower16:g_sess_min
	movt	r3, :upper16:g_sess_min
	ldrh	r3, [r3]
	bl	snprintf
	ldr	r1, [sp, #32]                   @ 4-byte Reload
	movw	r0, :lower16:.L.str.58
	movt	r0, :upper16:.L.str.58
	bl	tjc_set_txt
	bl	HAL_GetTick
	ldr	r1, [sp, #24]                   @ 4-byte Reload
	ldr	r2, [sp, #28]                   @ 4-byte Reload
	mov	r3, r0
	ldr	r0, [sp, #32]                   @ 4-byte Reload
	movw	r12, :lower16:g_test_t0
	movt	r12, :upper16:g_test_t0
	ldr.w	r12, [r12]
	sub.w	r3, r3, r12
	movw	r12, #19923
	movt	r12, #4194
	umull	r12, r3, r3, r12
	lsrs	r3, r3, #6
	bl	snprintf
	ldr	r1, [sp, #32]                   @ 4-byte Reload
	movw	r0, :lower16:.L.str.59
	movt	r0, :upper16:.L.str.59
	bl	tjc_set_txt
	ldr	r3, [sp, #20]                   @ 4-byte Reload
	ldr	r1, [sp, #24]                   @ 4-byte Reload
	ldr	r2, [sp, #28]                   @ 4-byte Reload
	ldr	r0, [sp, #32]                   @ 4-byte Reload
	ldr	r3, [r3]
	bl	snprintf
	ldr	r1, [sp, #32]                   @ 4-byte Reload
	movw	r0, :lower16:.L.str.60
	movt	r0, :upper16:.L.str.60
	bl	tjc_set_txt
	b	.LBB45_3
.LBB45_3:
	add	sp, #72
	pop	{r7, pc}
.Lfunc_end45:
	.size	send_hist_stats, .Lfunc_end45-send_hist_stats
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.cal_upload_status,"ax",%progbits
	.p2align	2                               @ -- Begin function cal_upload_status
	.type	cal_upload_status,%function
	.code	16                              @ @cal_upload_status
	.thumb_func
cal_upload_status:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#104
	sub	sp, #104
	.cfi_def_cfa_offset 112
	movw	r0, :lower16:g_page_now
	movt	r0, :upper16:g_page_now
	ldrb	r0, [r0]
	cmp	r0, #5
	beq	.LBB46_2
	b	.LBB46_1
.LBB46_1:
	b	.LBB46_12
.LBB46_2:
	movw	r0, :lower16:.L.str.72
	movt	r0, :upper16:.L.str.72
	str	r0, [sp, #100]
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	ldrb.w	r0, [r0, #33]
	cbz	r0, .LBB46_4
	b	.LBB46_3
.LBB46_3:
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	ldr	r0, [r0, #20]
	cbnz	r0, .LBB46_5
	b	.LBB46_4
.LBB46_4:
	ldr	r0, [sp, #100]
	movw	r1, :lower16:.L.str.73
	movt	r1, :upper16:.L.str.73
	bl	tjc_set_txt
	ldr	r0, [sp, #100]
	movw	r1, #57149
	bl	tjc_set_pco
	b	.LBB46_12
.LBB46_5:
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	str	r0, [sp, #20]                   @ 4-byte Spill
	ldr	r0, [r0, #20]
	add	r1, sp, #32
	add	r2, sp, #28
	add	r3, sp, #24
	bl	epoch_to_ymd
	bl	rtc_wall_seconds
	ldr	r1, [sp, #20]                   @ 4-byte Reload
	str	r0, [sp, #40]
	ldr	r0, [sp, #40]
	ldr	r1, [r1, #20]
	cmp	r0, r1
	bls	.LBB46_7
	b	.LBB46_6
.LBB46_6:
	ldr	r0, [sp, #40]
	movw	r1, :lower16:g_param
	movt	r1, :upper16:g_param
	ldr	r1, [r1, #20]
	subs	r0, r0, r1
	str	r0, [sp, #16]                   @ 4-byte Spill
	b	.LBB46_8
.LBB46_7:
	movs	r0, #0
	str	r0, [sp, #16]                   @ 4-byte Spill
	b	.LBB46_8
.LBB46_8:
	ldr	r0, [sp, #16]                   @ 4-byte Reload
	str	r0, [sp, #36]
	ldr	r0, [sp, #36]
	movw	r1, #19969
	movt	r1, #237
	cmp	r0, r1
	blo	.LBB46_10
	b	.LBB46_9
.LBB46_9:
	ldr	r3, [sp, #32]
	ldr	r0, [sp, #28]
	ldr	r2, [sp, #24]
	movw	r1, :lower16:g_param
	movt	r1, :upper16:g_param
	ldr.w	r12, [r1, #12]
	mov	r1, sp
	str.w	r12, [r1, #8]
	str	r2, [r1, #4]
	str	r0, [r1]
	movw	r2, :lower16:.L.str.74
	movt	r2, :upper16:.L.str.74
	add	r0, sp, #44
	movs	r1, #56
	bl	snprintf
	ldr	r0, [sp, #100]
	movw	r1, #62689
	bl	tjc_set_pco
	b	.LBB46_11
.LBB46_10:
	ldr	r3, [sp, #32]
	ldr	r0, [sp, #28]
	ldr	r2, [sp, #24]
	movw	r1, :lower16:g_param
	movt	r1, :upper16:g_param
	ldr.w	r12, [r1, #12]
	mov	r1, sp
	str.w	r12, [r1, #8]
	str	r2, [r1, #4]
	str	r0, [r1]
	movw	r2, :lower16:.L.str.75
	movt	r2, :upper16:.L.str.75
	add	r0, sp, #44
	movs	r1, #56
	bl	snprintf
	ldr	r0, [sp, #100]
	movw	r1, #57149
	bl	tjc_set_pco
	b	.LBB46_11
.LBB46_11:
	ldr	r0, [sp, #100]
	add	r1, sp, #44
	bl	tjc_set_txt
	b	.LBB46_12
.LBB46_12:
	add	sp, #104
	pop	{r7, pc}
.Lfunc_end46:
	.size	cal_upload_status, .Lfunc_end46-cal_upload_status
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.cal_do_zero,"ax",%progbits
	.p2align	2                               @ -- Begin function cal_do_zero
	.type	cal_do_zero,%function
	.code	16                              @ @cal_do_zero
	.thumb_func
cal_do_zero:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#32
	sub	sp, #32
	.cfi_def_cfa_offset 40
	bl	cal_precheck
	strb.w	r0, [sp, #31]
	ldrb.w	r0, [sp, #31]
	cbz	r0, .LBB47_2
	b	.LBB47_1
.LBB47_1:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_cal0_owner
	movt	r1, :upper16:g_cal0_owner
	strb	r0, [r1]
	ldrb.w	r1, [sp, #31]
	movs	r0, #1
	bl	cal_report
	b	.LBB47_18
.LBB47_2:
	bl	sensor_read_ppm
	str	r0, [sp, #24]
	ldr	r0, [sp, #24]
	movs	r1, #0
	movt	r1, #16968
	bl	__aeabi_fcmplt
	cbnz	r0, .LBB47_4
	b	.LBB47_3
.LBB47_3:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_cal0_owner
	movt	r1, :upper16:g_cal0_owner
	strb	r0, [r1]
	movs	r0, #1
	movs	r1, #3
	bl	cal_report
	b	.LBB47_18
.LBB47_4:
	movw	r0, :lower16:g_cal0_armed
	movt	r0, :upper16:g_cal0_armed
	ldrb	r0, [r0]
	cmp	r0, #0
	beq	.LBB47_12
	b	.LBB47_5
.LBB47_5:
	movw	r0, :lower16:g_cal0_owner
	movt	r0, :upper16:g_cal0_owner
	ldrb	r0, [r0]
	cmp	r0, #1
	bne	.LBB47_12
	b	.LBB47_6
.LBB47_6:
	bl	HAL_GetTick
	movw	r1, :lower16:g_cal0_t0
	movt	r1, :upper16:g_cal0_t0
	ldr	r1, [r1]
	subs	r0, r0, r1
	movw	r1, #3000
	cmp	r0, r1
	bhi	.LBB47_12
	b	.LBB47_7
.LBB47_7:
	ldr	r0, [sp, #24]
	movw	r1, :lower16:g_cal0_ppm0
	movt	r1, :upper16:g_cal0_ppm0
	ldr	r1, [r1]
	bl	__aeabi_fsub
	str	r0, [sp, #16]
	ldr	r0, [sp, #16]
	movs	r1, #0
	bl	__aeabi_fcmpge
	cbnz	r0, .LBB47_9
	b	.LBB47_8
.LBB47_8:
	ldr	r0, [sp, #16]
	eor	r0, r0, #-2147483648
	str	r0, [sp, #16]
	b	.LBB47_9
.LBB47_9:
	ldr	r0, [sp, #16]
	movs	r1, #0
	movt	r1, #16448
	bl	__aeabi_fcmple
	cbnz	r0, .LBB47_11
	b	.LBB47_10
.LBB47_10:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_cal0_owner
	movt	r1, :upper16:g_cal0_owner
	strb	r0, [r1]
	movs	r0, #1
	movs	r1, #11
	bl	cal_report
	b	.LBB47_18
.LBB47_11:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	b	.LBB47_15
.LBB47_12:
	movw	r0, :lower16:g_cal0_armed
	movt	r0, :upper16:g_cal0_armed
	ldrb	r0, [r0]
	cbz	r0, .LBB47_14
	b	.LBB47_13
.LBB47_13:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	b	.LBB47_14
.LBB47_14:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #1
	str	r0, [sp, #12]                   @ 4-byte Spill
	strb	r0, [r1]
	movw	r1, :lower16:g_cal0_owner
	movt	r1, :upper16:g_cal0_owner
	strb	r0, [r1]
	bl	HAL_GetTick
	mov	r1, r0
	ldr	r0, [sp, #12]                   @ 4-byte Reload
	movw	r2, :lower16:g_cal0_t0
	movt	r2, :upper16:g_cal0_t0
	str	r1, [r2]
	ldr	r1, [sp, #24]
	movw	r2, :lower16:g_cal0_ppm0
	movt	r2, :upper16:g_cal0_ppm0
	str	r1, [r2]
	movs	r1, #10
	bl	cal_report
	b	.LBB47_18
.LBB47_15:
	bl	sensor_read_raw
	str	r0, [sp, #20]
	ldr	r0, [sp, #20]
	movs	r1, #0
	bl	__aeabi_fcmpge
	cbnz	r0, .LBB47_17
	b	.LBB47_16
.LBB47_16:
	movs	r0, #1
	movs	r1, #5
	bl	cal_report
	b	.LBB47_18
.LBB47_17:
	ldr	r0, [sp, #20]
	bl	__aeabi_f2iz
	mov	r1, r0
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	str	r0, [sp, #4]                    @ 4-byte Spill
	str	r1, [r0, #16]
	ldr	r1, [sp, #20]
	str	r1, [sp]                        @ 4-byte Spill
	ldr	r0, [r0, #8]
	bl	__aeabi_i2f
	mov	r1, r0
	ldr	r0, [sp]                        @ 4-byte Reload
	bl	__aeabi_fmul
	movs	r1, #0
	movt	r1, #17530
	bl	__aeabi_fdiv
	bl	__aeabi_f2iz
	ldr	r1, [sp, #4]                    @ 4-byte Reload
	rsbs	r0, r0, #0
	str	r0, [r1, #12]
	bl	rtc_wall_seconds
	ldr	r1, [sp, #4]                    @ 4-byte Reload
	str	r0, [r1, #20]
	movs	r0, #1
	str	r0, [sp, #8]                    @ 4-byte Spill
	strb.w	r0, [r1, #33]
	bl	param_save_safe
	ldr	r1, [sp, #4]                    @ 4-byte Reload
	ldr	r0, [r1, #8]
	ldr	r1, [r1, #12]
	bl	sensor_set_cal
	ldr	r0, [sp, #8]                    @ 4-byte Reload
	movs	r1, #0
	bl	cal_report
	b	.LBB47_18
.LBB47_18:
	add	sp, #32
	pop	{r7, pc}
.Lfunc_end47:
	.size	cal_do_zero, .Lfunc_end47-cal_do_zero
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.cal_do_span,"ax",%progbits
	.p2align	2                               @ -- Begin function cal_do_span
	.type	cal_do_span,%function
	.code	16                              @ @cal_do_span
	.thumb_func
cal_do_span:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r4, lr}
	push	{r4, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r4, -8
	.pad	#56
	sub	sp, #56
	.cfi_def_cfa_offset 64
	bl	cal_precheck
	strb.w	r0, [sp, #55]
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_cal0_owner
	movt	r1, :upper16:g_cal0_owner
	strb	r0, [r1]
	ldrb.w	r0, [sp, #55]
	cbz	r0, .LBB48_2
	b	.LBB48_1
.LBB48_1:
	ldrb.w	r1, [sp, #55]
	movs	r0, #2
	bl	cal_report
	b	.LBB48_16
.LBB48_2:
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	ldr	r0, [r0, #16]
	str	r0, [sp, #48]
	ldr	r0, [sp, #48]
	mvn	r1, #-2147483648
	cmp	r0, r1
	bne	.LBB48_4
	b	.LBB48_3
.LBB48_3:
	movs	r0, #2
	movs	r1, #6
	bl	cal_report
	b	.LBB48_16
.LBB48_4:
	bl	sensor_read_ppm
	str	r0, [sp, #44]
	movs	r0, #0
	movt	r0, #17505
	str	r0, [sp, #36]
	movw	r0, #32768
	movt	r0, #17545
	str	r0, [sp, #32]
	ldr	r0, [sp, #44]
	ldr	r1, [sp, #36]
	bl	__aeabi_fcmplt
	cbnz	r0, .LBB48_6
	b	.LBB48_5
.LBB48_5:
	ldr	r0, [sp, #44]
	ldr	r1, [sp, #32]
	bl	__aeabi_fcmple
	cbnz	r0, .LBB48_7
	b	.LBB48_6
.LBB48_6:
	movs	r0, #2
	movs	r1, #4
	bl	cal_report
	b	.LBB48_16
.LBB48_7:
	bl	sensor_read_raw
	str	r0, [sp, #40]
	ldr	r0, [sp, #40]
	movs	r1, #0
	bl	__aeabi_fcmpgt
	cbnz	r0, .LBB48_9
	b	.LBB48_8
.LBB48_8:
	movs	r0, #2
	movs	r1, #5
	bl	cal_report
	b	.LBB48_16
.LBB48_9:
	ldr	r0, [sp, #40]
	bl	__aeabi_f2iz
	ldr	r1, [sp, #48]
	subs	r0, r0, r1
	cmp	r0, #49
	bgt	.LBB48_11
	b	.LBB48_10
.LBB48_10:
	movs	r0, #2
	movs	r1, #7
	bl	cal_report
	b	.LBB48_16
.LBB48_11:
	ldr	r0, [sp, #40]
	bl	__aeabi_f2lz
	mov	r2, r0
	ldr	r0, [sp, #48]
	subs	r2, r2, r0
	sbc.w	r3, r1, r0, asr #31
	movw	r0, #16960
	movt	r0, #15
	movs	r1, #0
	str	r1, [sp, #8]                    @ 4-byte Spill
	bl	__aeabi_ldivmod
	ldr	r3, [sp, #8]                    @ 4-byte Reload
	str	r1, [sp, #28]
	str	r0, [sp, #24]
	ldr.w	r12, [sp, #48]
	asr.w	r1, r12, #31
	ldr	r2, [sp, #24]
	ldr.w	lr, [sp, #28]
	umull	r0, r4, r12, r2
	mla	r12, r12, lr, r4
	mla	r1, r1, r2, r12
	rsbs	r0, r0, #0
	sbc.w	r1, r3, r1
	mov.w	r2, #1000
	bl	__aeabi_ldivmod
	mov	r2, r0
	ldr	r0, [sp, #8]                    @ 4-byte Reload
	str	r2, [sp, #12]                   @ 4-byte Spill
	mov	r2, r1
	ldr	r1, [sp, #12]                   @ 4-byte Reload
	str	r2, [sp, #20]
	str	r1, [sp, #16]
	strb.w	r0, [sp, #55]
	ldr	r2, [sp, #24]
	ldr	r1, [sp, #28]
	rsbs.w	r2, r2, #99
	sbcs	r0, r1
	blt	.LBB48_13
	b	.LBB48_12
.LBB48_12:
	movs	r0, #0
	str	r0, [sp, #28]
	movs	r0, #100
	str	r0, [sp, #24]
	movs	r0, #8
	strb.w	r0, [sp, #55]
	b	.LBB48_13
.LBB48_13:
	ldr	r1, [sp, #24]
	ldr	r0, [sp, #28]
	movw	r2, #10001
	subs	r1, r1, r2
	sbcs	r0, r0, #0
	blt	.LBB48_15
	b	.LBB48_14
.LBB48_14:
	movs	r0, #0
	str	r0, [sp, #28]
	movw	r0, #10000
	str	r0, [sp, #24]
	movs	r0, #8
	strb.w	r0, [sp, #55]
	b	.LBB48_15
.LBB48_15:
	ldr	r0, [sp, #24]
	movw	r1, :lower16:g_param
	movt	r1, :upper16:g_param
	str	r1, [sp, #4]                    @ 4-byte Spill
	str	r0, [r1, #8]
	ldr	r0, [sp, #16]
	str	r0, [r1, #12]
	bl	rtc_wall_seconds
	ldr	r1, [sp, #4]                    @ 4-byte Reload
	str	r0, [r1, #20]
	movs	r0, #1
	strb.w	r0, [r1, #33]
	bl	param_save_safe
	ldr	r1, [sp, #4]                    @ 4-byte Reload
	ldr	r0, [r1, #8]
	ldr	r1, [r1, #12]
	bl	sensor_set_cal
	ldrb.w	r1, [sp, #55]
	movs	r0, #2
	bl	cal_report
	b	.LBB48_16
.LBB48_16:
	add	sp, #56
	pop	{r4, pc}
.Lfunc_end48:
	.size	cal_do_span, .Lfunc_end48-cal_do_span
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.cal_do_factory,"ax",%progbits
	.p2align	2                               @ -- Begin function cal_do_factory
	.type	cal_do_factory,%function
	.code	16                              @ @cal_do_factory
	.thumb_func
cal_do_factory:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#8
	sub	sp, #8
	.cfi_def_cfa_offset 16
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_cal0_owner
	movt	r1, :upper16:g_cal0_owner
	strb	r0, [r1]
	movw	r0, :lower16:g_selftest
	movt	r0, :upper16:g_selftest
	ldrb	r0, [r0]
	cbnz	r0, .LBB49_2
	b	.LBB49_1
.LBB49_1:
	movs	r0, #3
	movs	r1, #9
	bl	cal_report
	add	sp, #8
	pop	{r7, pc}
.LBB49_2:
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	str	r0, [sp, #4]                    @ 4-byte Spill
	movs	r1, #1
	bl	param_factory
	ldr	r1, [sp, #4]                    @ 4-byte Reload
	ldrh	r0, [r1, #28]
	movw	r2, :lower16:g_thr_hi
	movt	r2, :upper16:g_thr_hi
	str	r0, [r2]
	ldrh	r0, [r1, #30]
	movw	r2, :lower16:g_thr_lo
	movt	r2, :upper16:g_thr_lo
	str	r0, [r2]
	ldr	r0, [r1, #8]
	ldr	r1, [r1, #12]
	bl	sensor_set_cal
	bl	app_apply_threshold
	movs	r0, #3
	movs	r1, #0
	bl	cal_report
	movs	r0, #200
	bl	HAL_Delay
	bl	__NVIC_SystemReset
.Lfunc_end49:
	.size	cal_do_factory, .Lfunc_end49-cal_do_factory
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.cal_do_zero_hw,"ax",%progbits
	.p2align	2                               @ -- Begin function cal_do_zero_hw
	.type	cal_do_zero_hw,%function
	.code	16                              @ @cal_do_zero_hw
	.thumb_func
cal_do_zero_hw:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#16
	sub	sp, #16
	.cfi_def_cfa_offset 24
	bl	cal_precheck
	strb.w	r0, [sp, #15]
	ldrb.w	r0, [sp, #15]
	cbz	r0, .LBB50_2
	b	.LBB50_1
.LBB50_1:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_cal0_owner
	movt	r1, :upper16:g_cal0_owner
	strb	r0, [r1]
	ldrb.w	r1, [sp, #15]
	movs	r0, #4
	bl	cal_report
	b	.LBB50_16
.LBB50_2:
	bl	sensor_read_ppm
	str	r0, [sp, #8]
	ldr	r0, [sp, #8]
	movs	r1, #0
	movt	r1, #16968
	bl	__aeabi_fcmplt
	cbnz	r0, .LBB50_4
	b	.LBB50_3
.LBB50_3:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_cal0_owner
	movt	r1, :upper16:g_cal0_owner
	strb	r0, [r1]
	movs	r0, #4
	movs	r1, #3
	bl	cal_report
	b	.LBB50_16
.LBB50_4:
	movw	r0, :lower16:g_cal0_armed
	movt	r0, :upper16:g_cal0_armed
	ldrb	r0, [r0]
	cmp	r0, #0
	beq	.LBB50_12
	b	.LBB50_5
.LBB50_5:
	movw	r0, :lower16:g_cal0_owner
	movt	r0, :upper16:g_cal0_owner
	ldrb	r0, [r0]
	cmp	r0, #4
	bne	.LBB50_12
	b	.LBB50_6
.LBB50_6:
	bl	HAL_GetTick
	movw	r1, :lower16:g_cal0_t0
	movt	r1, :upper16:g_cal0_t0
	ldr	r1, [r1]
	subs	r0, r0, r1
	movw	r1, #3000
	cmp	r0, r1
	bhi	.LBB50_12
	b	.LBB50_7
.LBB50_7:
	ldr	r0, [sp, #8]
	movw	r1, :lower16:g_cal0_ppm0
	movt	r1, :upper16:g_cal0_ppm0
	ldr	r1, [r1]
	bl	__aeabi_fsub
	str	r0, [sp, #4]
	ldr	r0, [sp, #4]
	movs	r1, #0
	bl	__aeabi_fcmpge
	cbnz	r0, .LBB50_9
	b	.LBB50_8
.LBB50_8:
	ldr	r0, [sp, #4]
	eor	r0, r0, #-2147483648
	str	r0, [sp, #4]
	b	.LBB50_9
.LBB50_9:
	ldr	r0, [sp, #4]
	movs	r1, #0
	movt	r1, #16448
	bl	__aeabi_fcmple
	cbnz	r0, .LBB50_11
	b	.LBB50_10
.LBB50_10:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_cal0_owner
	movt	r1, :upper16:g_cal0_owner
	strb	r0, [r1]
	movs	r0, #4
	movs	r1, #11
	bl	cal_report
	b	.LBB50_16
.LBB50_11:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	b	.LBB50_15
.LBB50_12:
	movw	r0, :lower16:g_cal0_armed
	movt	r0, :upper16:g_cal0_armed
	ldrb	r0, [r0]
	cbz	r0, .LBB50_14
	b	.LBB50_13
.LBB50_13:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	b	.LBB50_14
.LBB50_14:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #1
	strb	r0, [r1]
	movw	r1, :lower16:g_cal0_owner
	movt	r1, :upper16:g_cal0_owner
	movs	r0, #4
	str	r0, [sp]                        @ 4-byte Spill
	strb	r0, [r1]
	bl	HAL_GetTick
	mov	r1, r0
	ldr	r0, [sp]                        @ 4-byte Reload
	movw	r2, :lower16:g_cal0_t0
	movt	r2, :upper16:g_cal0_t0
	str	r1, [r2]
	ldr	r1, [sp, #8]
	movw	r2, :lower16:g_cal0_ppm0
	movt	r2, :upper16:g_cal0_ppm0
	str	r1, [r2]
	movs	r1, #10
	bl	cal_report
	b	.LBB50_16
.LBB50_15:
	movw	r0, :lower16:SENSOR_CMD_ZERO_HW
	movt	r0, :upper16:SENSOR_CMD_ZERO_HW
	movs	r1, #6
	bl	sensor_send_cmd
	movs	r0, #4
	movs	r1, #12
	bl	cal_report
	b	.LBB50_16
.LBB50_16:
	add	sp, #16
	pop	{r7, pc}
.Lfunc_end50:
	.size	cal_do_zero_hw, .Lfunc_end50-cal_do_zero_hw
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.cal_do_lo15,"ax",%progbits
	.p2align	2                               @ -- Begin function cal_do_lo15
	.type	cal_do_lo15,%function
	.code	16                              @ @cal_do_lo15
	.thumb_func
cal_do_lo15:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#24
	sub	sp, #24
	.cfi_def_cfa_offset 32
	bl	cal_precheck
	strb.w	r0, [sp, #23]
	ldrb.w	r0, [sp, #23]
	cbz	r0, .LBB51_2
	b	.LBB51_1
.LBB51_1:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_cal0_owner
	movt	r1, :upper16:g_cal0_owner
	strb	r0, [r1]
	ldrb.w	r1, [sp, #23]
	movs	r0, #5
	bl	cal_report
	b	.LBB51_14
.LBB51_2:
	bl	sensor_read_ppm
	str	r0, [sp, #16]
	movw	r0, :lower16:g_cal0_armed
	movt	r0, :upper16:g_cal0_armed
	ldrb	r0, [r0]
	cmp	r0, #0
	beq	.LBB51_10
	b	.LBB51_3
.LBB51_3:
	movw	r0, :lower16:g_cal0_owner
	movt	r0, :upper16:g_cal0_owner
	ldrb	r0, [r0]
	cmp	r0, #5
	bne	.LBB51_10
	b	.LBB51_4
.LBB51_4:
	bl	HAL_GetTick
	movw	r1, :lower16:g_cal0_t0
	movt	r1, :upper16:g_cal0_t0
	ldr	r1, [r1]
	subs	r0, r0, r1
	movw	r1, #3000
	cmp	r0, r1
	bhi	.LBB51_10
	b	.LBB51_5
.LBB51_5:
	ldr	r0, [sp, #16]
	movw	r1, :lower16:g_cal0_ppm0
	movt	r1, :upper16:g_cal0_ppm0
	ldr	r1, [r1]
	bl	__aeabi_fsub
	str	r0, [sp, #12]
	ldr	r0, [sp, #12]
	movs	r1, #0
	bl	__aeabi_fcmpge
	cbnz	r0, .LBB51_7
	b	.LBB51_6
.LBB51_6:
	ldr	r0, [sp, #12]
	eor	r0, r0, #-2147483648
	str	r0, [sp, #12]
	b	.LBB51_7
.LBB51_7:
	ldr	r0, [sp, #12]
	movs	r1, #0
	movt	r1, #16448
	bl	__aeabi_fcmple
	cbnz	r0, .LBB51_9
	b	.LBB51_8
.LBB51_8:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	movw	r1, :lower16:g_cal0_owner
	movt	r1, :upper16:g_cal0_owner
	strb	r0, [r1]
	movs	r0, #5
	movs	r1, #11
	bl	cal_report
	b	.LBB51_14
.LBB51_9:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	b	.LBB51_13
.LBB51_10:
	movw	r0, :lower16:g_cal0_armed
	movt	r0, :upper16:g_cal0_armed
	ldrb	r0, [r0]
	cbz	r0, .LBB51_12
	b	.LBB51_11
.LBB51_11:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #0
	strb	r0, [r1]
	b	.LBB51_12
.LBB51_12:
	movw	r1, :lower16:g_cal0_armed
	movt	r1, :upper16:g_cal0_armed
	movs	r0, #1
	strb	r0, [r1]
	movw	r1, :lower16:g_cal0_owner
	movt	r1, :upper16:g_cal0_owner
	movs	r0, #5
	str	r0, [sp, #8]                    @ 4-byte Spill
	strb	r0, [r1]
	bl	HAL_GetTick
	mov	r1, r0
	ldr	r0, [sp, #8]                    @ 4-byte Reload
	movw	r2, :lower16:g_cal0_t0
	movt	r2, :upper16:g_cal0_t0
	str	r1, [r2]
	ldr	r1, [sp, #16]
	movw	r2, :lower16:g_cal0_ppm0
	movt	r2, :upper16:g_cal0_ppm0
	str	r1, [r2]
	movs	r1, #10
	bl	cal_report
	b	.LBB51_14
.LBB51_13:
	movw	r0, :lower16:SENSOR_CMD_LO15_A
	movt	r0, :upper16:SENSOR_CMD_LO15_A
	movs	r1, #11
	str	r1, [sp, #4]                    @ 4-byte Spill
	bl	sensor_send_cmd
	movs	r0, #50
	bl	HAL_Delay
	ldr	r1, [sp, #4]                    @ 4-byte Reload
	movw	r0, :lower16:SENSOR_CMD_LO15_B
	movt	r0, :upper16:SENSOR_CMD_LO15_B
	bl	sensor_send_cmd
	movs	r0, #5
	movs	r1, #12
	bl	cal_report
	b	.LBB51_14
.LBB51_14:
	add	sp, #24
	pop	{r7, pc}
.Lfunc_end51:
	.size	cal_do_lo15, .Lfunc_end51-cal_do_lo15
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.epoch_to_ymd,"ax",%progbits
	.p2align	2                               @ -- Begin function epoch_to_ymd
	.type	epoch_to_ymd,%function
	.code	16                              @ @epoch_to_ymd
	.thumb_func
epoch_to_ymd:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.pad	#56
	sub	sp, #56
	.cfi_def_cfa_offset 56
	str	r0, [sp, #52]
	str	r1, [sp, #48]
	str	r2, [sp, #44]
	str	r3, [sp, #40]
	ldr	r0, [sp, #52]
	movw	r1, #17671
	movt	r1, #49710
	umull	r0, r1, r0, r1
	movw	r0, #64108
	movt	r0, #10
	add.w	r0, r0, r1, lsr #16
	str	r0, [sp, #36]
	ldr	r0, [sp, #36]
	cmp	r0, #0
	bmi	.LBB52_2
	b	.LBB52_1
.LBB52_1:
	ldr	r0, [sp, #36]
	str	r0, [sp, #4]                    @ 4-byte Spill
	b	.LBB52_3
.LBB52_2:
	ldr	r0, [sp, #36]
	movw	r1, #50512
	movt	r1, #65533
	add	r0, r1
	str	r0, [sp, #4]                    @ 4-byte Spill
	b	.LBB52_3
.LBB52_3:
	ldr	r0, [sp, #4]                    @ 4-byte Reload
	movw	r1, #1725
	movt	r1, #14699
	smull	r0, r1, r0, r1
	asrs	r0, r1, #15
	add.w	r0, r0, r1, lsr #31
	str	r0, [sp, #32]
	ldr	r2, [sp, #36]
	ldr	r0, [sp, #32]
	movw	r1, #15025
	movt	r1, #2
	mls	r0, r0, r1, r2
	str	r0, [sp, #28]
	ldr	r1, [sp, #28]
	lsrs	r2, r1, #2
	movw	r0, #31961
	movt	r0, #22982
	umull	r3, r0, r2, r0
	sub.w	r0, r1, r0, lsr #7
	movw	r3, #8319
	movt	r3, #14699
	umull	r3, r2, r2, r3
	add.w	r0, r0, r2, lsr #11
	lsrs	r1, r1, #4
	movw	r2, #54849
	movt	r2, #114
	umull	r2, r1, r1, r2
	sub.w	r1, r0, r1, lsr #4
	movw	r0, #62305
	movt	r0, #26393
	umull	r2, r0, r1, r0
	subs	r1, r1, r0
	add.w	r0, r0, r1, lsr #1
	lsrs	r0, r0, #8
	str	r0, [sp, #24]
	ldr	r0, [sp, #28]
	ldr	r2, [sp, #24]
	movw	r1, #365
	muls	r1, r2, r1
	add.w	r1, r1, r2, lsr #2
	movw	r3, #34079
	movt	r3, #20971
	umull	r3, r2, r2, r3
	rsb	r1, r1, r2, lsr #5
	add	r0, r1
	str	r0, [sp, #20]
	ldr	r0, [sp, #20]
	add.w	r0, r0, r0, lsl #2
	adds	r0, #2
	movw	r1, #32983
	movt	r1, #54827
	umull	r1, r0, r0, r1
	lsrs	r0, r0, #7
	str	r0, [sp, #16]
	ldr	r0, [sp, #20]
	ldr	r1, [sp, #16]
	movs	r2, #153
	muls	r1, r2, r1
	adds	r1, #2
	movw	r2, #52429
	movt	r2, #52428
	umull	r2, r1, r1, r2
	sub.w	r0, r0, r1, lsr #2
	adds	r0, #1
	str	r0, [sp, #12]
	ldr	r0, [sp, #16]
	cmp	r0, #9
	bhi	.LBB52_5
	b	.LBB52_4
.LBB52_4:
	ldr	r0, [sp, #16]
	adds	r0, #3
	str	r0, [sp]                        @ 4-byte Spill
	b	.LBB52_6
.LBB52_5:
	ldr	r0, [sp, #16]
	subs	r0, #9
	str	r0, [sp]                        @ 4-byte Spill
	b	.LBB52_6
.LBB52_6:
	ldr	r0, [sp]                        @ 4-byte Reload
	str	r0, [sp, #8]
	ldr	r2, [sp, #24]
	ldr	r0, [sp, #32]
	mov.w	r1, #400
	mla	r0, r0, r1, r2
	ldr	r2, [sp, #8]
	adds	r1, r0, #1
	cmp	r2, #3
	it	lo
	movlo	r0, r1
	ldr	r1, [sp, #48]
	str	r0, [r1]
	ldr	r0, [sp, #8]
	ldr	r1, [sp, #44]
	str	r0, [r1]
	ldr	r0, [sp, #12]
	ldr	r1, [sp, #40]
	str	r0, [r1]
	add	sp, #56
	bx	lr
.Lfunc_end52:
	.size	epoch_to_ymd, .Lfunc_end52-epoch_to_ymd
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.cal_precheck,"ax",%progbits
	.p2align	2                               @ -- Begin function cal_precheck
	.type	cal_precheck,%function
	.code	16                              @ @cal_precheck
	.thumb_func
cal_precheck:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#8
	sub	sp, #8
	.cfi_def_cfa_offset 16
	bl	sensor_online
	cbnz	r0, .LBB53_2
	b	.LBB53_1
.LBB53_1:
	movs	r0, #1
	strb.w	r0, [sp, #7]
	b	.LBB53_5
.LBB53_2:
	bl	HAL_GetTick
	movw	r1, :lower16:g_boot_ms
	movt	r1, :upper16:g_boot_ms
	ldr	r1, [r1]
	subs	r0, r0, r1
	movw	r1, #54463
	movt	r1, #1
	cmp	r0, r1
	bhi	.LBB53_4
	b	.LBB53_3
.LBB53_3:
	movs	r0, #2
	strb.w	r0, [sp, #7]
	b	.LBB53_5
.LBB53_4:
	movs	r0, #0
	strb.w	r0, [sp, #7]
	b	.LBB53_5
.LBB53_5:
	ldrb.w	r0, [sp, #7]
	add	sp, #8
	pop	{r7, pc}
.Lfunc_end53:
	.size	cal_precheck, .Lfunc_end53-cal_precheck
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.section	.text.cal_report,"ax",%progbits
	.p2align	2                               @ -- Begin function cal_report
	.type	cal_report,%function
	.code	16                              @ @cal_report
	.thumb_func
cal_report:
	.fnstart
	.cfi_startproc
@ %bb.0:
	.save	{r7, lr}
	push	{r7, lr}
	.cfi_def_cfa_offset 8
	.cfi_offset lr, -4
	.cfi_offset r7, -8
	.pad	#112
	sub	sp, #112
	.cfi_def_cfa_offset 120
                                        @ kill: def $r2 killed $r1
                                        @ kill: def $r2 killed $r0
	strb.w	r0, [sp, #111]
	strb.w	r1, [sp, #110]
	ldrb.w	r0, [sp, #111]
	cmp	r0, #1
	bne	.LBB54_2
	b	.LBB54_1
.LBB54_1:
	movw	r0, :lower16:.L.str.76
	movt	r0, :upper16:.L.str.76
	str	r0, [sp, #20]                   @ 4-byte Spill
	b	.LBB54_9
.LBB54_2:
	ldrb.w	r0, [sp, #111]
	cmp	r0, #2
	bne	.LBB54_4
	b	.LBB54_3
.LBB54_3:
	movw	r0, :lower16:.L.str.77
	movt	r0, :upper16:.L.str.77
	str	r0, [sp, #16]                   @ 4-byte Spill
	b	.LBB54_8
.LBB54_4:
	ldrb.w	r0, [sp, #111]
	cmp	r0, #4
	bne	.LBB54_6
	b	.LBB54_5
.LBB54_5:
	movw	r0, :lower16:.L.str.78
	movt	r0, :upper16:.L.str.78
	str	r0, [sp, #12]                   @ 4-byte Spill
	b	.LBB54_7
.LBB54_6:
	ldrb.w	r2, [sp, #111]
	movw	r1, :lower16:.L.str.79
	movt	r1, :upper16:.L.str.79
	movw	r0, :lower16:.L.str.80
	movt	r0, :upper16:.L.str.80
	cmp	r2, #5
	it	eq
	moveq	r0, r1
	str	r0, [sp, #12]                   @ 4-byte Spill
	b	.LBB54_7
.LBB54_7:
	ldr	r0, [sp, #12]                   @ 4-byte Reload
	str	r0, [sp, #16]                   @ 4-byte Spill
	b	.LBB54_8
.LBB54_8:
	ldr	r0, [sp, #16]                   @ 4-byte Reload
	str	r0, [sp, #20]                   @ 4-byte Spill
	b	.LBB54_9
.LBB54_9:
	ldr	r0, [sp, #20]                   @ 4-byte Reload
	str	r0, [sp, #40]
	movw	r0, :lower16:g_page_now
	movt	r0, :upper16:g_page_now
	ldrb	r3, [r0]
	movw	r2, :lower16:.L.str.81
	movt	r2, :upper16:.L.str.81
	movw	r1, :lower16:.L.str.82
	movt	r1, :upper16:.L.str.82
	cmp	r3, #5
	it	eq
	moveq	r1, r2
	str	r1, [sp, #36]
	ldrb	r0, [r0]
	subs	r0, #5
	clz	r0, r0
	lsrs	r0, r0, #5
	str	r0, [sp, #32]
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	ldr	r0, [r0, #8]
	adds	r0, #5
	movw	r1, #26215
	movt	r1, #26214
	smull	r0, r1, r0, r1
	asrs	r0, r1, #2
	add.w	r0, r0, r1, lsr #31
	str	r0, [sp, #24]
	ldrb.w	r0, [sp, #110]
	mov	r1, r0
	str	r1, [sp, #8]                    @ 4-byte Spill
	cmp	r0, #12
	bhi.w	.LBB54_43
@ %bb.10:
	ldr	r1, [sp, #8]                    @ 4-byte Reload
.LCPI54_0:
	tbh	[pc, r1, lsl #1]
@ %bb.11:
.LJTI54_0:
	.short	(.LBB54_12-(.LCPI54_0+4))/2
	.short	(.LBB54_26-(.LCPI54_0+4))/2
	.short	(.LBB54_27-(.LCPI54_0+4))/2
	.short	(.LBB54_28-(.LCPI54_0+4))/2
	.short	(.LBB54_29-(.LCPI54_0+4))/2
	.short	(.LBB54_30-(.LCPI54_0+4))/2
	.short	(.LBB54_31-(.LCPI54_0+4))/2
	.short	(.LBB54_32-(.LCPI54_0+4))/2
	.short	(.LBB54_33-(.LCPI54_0+4))/2
	.short	(.LBB54_34-(.LCPI54_0+4))/2
	.short	(.LBB54_35-(.LCPI54_0+4))/2
	.short	(.LBB54_42-(.LCPI54_0+4))/2
	.short	(.LBB54_25-(.LCPI54_0+4))/2
	.p2align	1
.LBB54_12:
	movw	r0, :lower16:.L.str.83
	movt	r0, :upper16:.L.str.83
	str	r0, [sp, #28]
	ldrb.w	r0, [sp, #111]
	cmp	r0, #1
	bne	.LBB54_14
	b	.LBB54_13
.LBB54_13:
	movw	r0, :lower16:g_param
	movt	r0, :upper16:g_param
	ldr	r3, [r0, #12]
	movw	r2, :lower16:.L.str.84
	movt	r2, :upper16:.L.str.84
	add.w	r0, sp, #46
	movs	r1, #64
	bl	snprintf
	b	.LBB54_24
.LBB54_14:
	ldrb.w	r0, [sp, #111]
	cmp	r0, #2
	bne	.LBB54_16
	b	.LBB54_15
.LBB54_15:
	ldr	r1, [sp, #24]
	movw	r0, #34079
	movt	r0, #20971
	smull	r0, r2, r1, r0
	asrs	r0, r2, #5
	add.w	r3, r0, r2, lsr #31
	movs	r0, #100
	mls	r0, r3, r0, r1
	mov	r1, sp
	str	r0, [r1]
	movw	r2, :lower16:.L.str.85
	movt	r2, :upper16:.L.str.85
	add.w	r0, sp, #46
	movs	r1, #64
	bl	snprintf
	b	.LBB54_23
.LBB54_16:
	ldrb.w	r0, [sp, #111]
	cmp	r0, #4
	bne	.LBB54_18
	b	.LBB54_17
.LBB54_17:
	movw	r2, :lower16:.L.str.86
	movt	r2, :upper16:.L.str.86
	add.w	r0, sp, #46
	movs	r1, #64
	bl	snprintf
	b	.LBB54_22
.LBB54_18:
	ldrb.w	r0, [sp, #111]
	cmp	r0, #5
	bne	.LBB54_20
	b	.LBB54_19
.LBB54_19:
	movw	r2, :lower16:.L.str.87
	movt	r2, :upper16:.L.str.87
	add.w	r0, sp, #46
	movs	r1, #64
	bl	snprintf
	b	.LBB54_21
.LBB54_20:
	movw	r2, :lower16:.L.str.88
	movt	r2, :upper16:.L.str.88
	add.w	r0, sp, #46
	movs	r1, #64
	bl	snprintf
	b	.LBB54_21
.LBB54_21:
	b	.LBB54_22
.LBB54_22:
	b	.LBB54_23
.LBB54_23:
	b	.LBB54_24
.LBB54_24:
	b	.LBB54_44
.LBB54_25:
	movw	r0, :lower16:.L.str.89
	movt	r0, :upper16:.L.str.89
	str	r0, [sp, #28]
	b	.LBB54_44
.LBB54_26:
	movw	r0, :lower16:.L.str.90
	movt	r0, :upper16:.L.str.90
	str	r0, [sp, #28]
	movw	r2, :lower16:.L.str.91
	movt	r2, :upper16:.L.str.91
	add.w	r0, sp, #46
	movs	r1, #64
	bl	snprintf
	b	.LBB54_44
.LBB54_27:
	movw	r0, :lower16:.L.str.92
	movt	r0, :upper16:.L.str.92
	str	r0, [sp, #28]
	movw	r2, :lower16:.L.str.93
	movt	r2, :upper16:.L.str.93
	add.w	r0, sp, #46
	movs	r1, #64
	movs	r3, #120
	bl	snprintf
	b	.LBB54_44
.LBB54_28:
	movw	r0, :lower16:.L.str.94
	movt	r0, :upper16:.L.str.94
	str	r0, [sp, #28]
	movw	r2, :lower16:.L.str.95
	movt	r2, :upper16:.L.str.95
	add.w	r0, sp, #46
	movs	r1, #64
	movs	r3, #50
	bl	snprintf
	b	.LBB54_44
.LBB54_29:
	movw	r0, :lower16:.L.str.96
	movt	r0, :upper16:.L.str.96
	str	r0, [sp, #28]
	mov	r1, sp
	movw	r0, #1100
	str	r0, [r1]
	movw	r2, :lower16:.L.str.97
	movt	r2, :upper16:.L.str.97
	add.w	r0, sp, #46
	movs	r1, #64
	mov.w	r3, #900
	bl	snprintf
	b	.LBB54_44
.LBB54_30:
	movw	r0, :lower16:.L.str.98
	movt	r0, :upper16:.L.str.98
	str	r0, [sp, #28]
	movw	r2, :lower16:.L.str.99
	movt	r2, :upper16:.L.str.99
	add.w	r0, sp, #46
	movs	r1, #64
	bl	snprintf
	b	.LBB54_44
.LBB54_31:
	movw	r0, :lower16:.L.str.100
	movt	r0, :upper16:.L.str.100
	str	r0, [sp, #28]
	movw	r2, :lower16:.L.str.101
	movt	r2, :upper16:.L.str.101
	add.w	r0, sp, #46
	movs	r1, #64
	bl	snprintf
	b	.LBB54_44
.LBB54_32:
	movw	r0, :lower16:.L.str.102
	movt	r0, :upper16:.L.str.102
	str	r0, [sp, #28]
	movw	r2, :lower16:.L.str.103
	movt	r2, :upper16:.L.str.103
	add.w	r0, sp, #46
	movs	r1, #64
	movs	r3, #50
	bl	snprintf
	b	.LBB54_44
.LBB54_33:
	movw	r0, :lower16:.L.str.104
	movt	r0, :upper16:.L.str.104
	str	r0, [sp, #28]
	movw	r2, :lower16:.L.str.105
	movt	r2, :upper16:.L.str.105
	add.w	r0, sp, #46
	movs	r1, #64
	bl	snprintf
	b	.LBB54_44
.LBB54_34:
	movw	r0, :lower16:.L.str.106
	movt	r0, :upper16:.L.str.106
	str	r0, [sp, #28]
	movw	r2, :lower16:.L.str.107
	movt	r2, :upper16:.L.str.107
	add.w	r0, sp, #46
	movs	r1, #64
	bl	snprintf
	b	.LBB54_44
.LBB54_35:
	movw	r0, :lower16:.L.str.108
	movt	r0, :upper16:.L.str.108
	str	r0, [sp, #28]
	ldrb.w	r0, [sp, #111]
	cmp	r0, #4
	bne	.LBB54_37
	b	.LBB54_36
.LBB54_36:
	movw	r0, :lower16:g_cal0_ppm0
	movt	r0, :upper16:g_cal0_ppm0
	ldr	r0, [r0]
	bl	__aeabi_f2iz
	mov	r3, r0
	movw	r2, :lower16:.L.str.109
	movt	r2, :upper16:.L.str.109
	add.w	r0, sp, #46
	movs	r1, #64
	bl	snprintf
	b	.LBB54_41
.LBB54_37:
	ldrb.w	r0, [sp, #111]
	cmp	r0, #5
	bne	.LBB54_39
	b	.LBB54_38
.LBB54_38:
	movw	r2, :lower16:.L.str.110
	movt	r2, :upper16:.L.str.110
	add.w	r0, sp, #46
	movs	r1, #64
	bl	snprintf
	b	.LBB54_40
.LBB54_39:
	movw	r0, :lower16:g_cal0_ppm0
	movt	r0, :upper16:g_cal0_ppm0
	ldr	r0, [r0]
	bl	__aeabi_f2iz
	mov	r3, r0
	movw	r2, :lower16:.L.str.109
	movt	r2, :upper16:.L.str.109
	add.w	r0, sp, #46
	movs	r1, #64
	bl	snprintf
	b	.LBB54_40
.LBB54_40:
	b	.LBB54_41
.LBB54_41:
	b	.LBB54_44
.LBB54_42:
	movw	r0, :lower16:.L.str.111
	movt	r0, :upper16:.L.str.111
	str	r0, [sp, #28]
	movw	r2, :lower16:.L.str.112
	movt	r2, :upper16:.L.str.112
	add.w	r0, sp, #46
	movs	r1, #64
	bl	snprintf
	b	.LBB54_44
.LBB54_43:
	movw	r0, :lower16:.L.str.113
	movt	r0, :upper16:.L.str.113
	str	r0, [sp, #28]
	movw	r2, :lower16:.L.str.114
	movt	r2, :upper16:.L.str.114
	add.w	r0, sp, #46
	movs	r1, #64
	bl	snprintf
	b	.LBB54_44
.LBB54_44:
	ldr	r0, [sp, #40]
	ldr	r1, [sp, #28]
	bl	tjc_set_txt
	ldr	r0, [sp, #32]
	cbz	r0, .LBB54_46
	b	.LBB54_45
.LBB54_45:
	ldr	r0, [sp, #36]
	add.w	r1, sp, #46
	bl	tjc_set_txt
	b	.LBB54_46
.LBB54_46:
	add	sp, #112
	pop	{r7, pc}
.Lfunc_end54:
	.size	cal_report, .Lfunc_end54-cal_report
	.cfi_endproc
	.cantunwind
	.fnend
                                        @ -- End function
	.hidden	rx_byte                         @ @rx_byte
	.type	rx_byte,%object
	.section	.bss.rx_byte,"aw",%nobits
	.globl	rx_byte
rx_byte:
	.byte	0                               @ 0x0
	.size	rx_byte, 1

	.type	g_rx_reattach_fail,%object      @ @g_rx_reattach_fail
	.section	.bss.g_rx_reattach_fail,"aw",%nobits
g_rx_reattach_fail:
	.byte	0                               @ 0x0
	.size	g_rx_reattach_fail, 1

	.type	g_wall_epoch,%object            @ @g_wall_epoch
	.section	.bss.g_wall_epoch,"aw",%nobits
	.p2align	2, 0x0
g_wall_epoch:
	.long	0                               @ 0x0
	.size	g_wall_epoch, 4

	.type	g_wall_tick,%object             @ @g_wall_tick
	.section	.bss.g_wall_tick,"aw",%nobits
	.p2align	2, 0x0
g_wall_tick:
	.long	0                               @ 0x0
	.size	g_wall_tick, 4

	.type	s_devtest_t0,%object            @ @s_devtest_t0
	.section	.bss.s_devtest_t0,"aw",%nobits
	.p2align	2, 0x0
s_devtest_t0:
	.long	0                               @ 0x0
	.size	s_devtest_t0, 4

	.hidden	g_param                         @ @g_param
	.type	g_param,%object
	.section	.bss.g_param,"aw",%nobits
	.globl	g_param
	.p2align	2, 0x0
g_param:
	.zero	40
	.size	g_param, 40

	.type	g_thr_hi,%object                @ @g_thr_hi
	.section	.data.g_thr_hi,"aw",%progbits
	.p2align	2, 0x0
g_thr_hi:
	.long	500                             @ 0x1f4
	.size	g_thr_hi, 4

	.type	g_thr_lo,%object                @ @g_thr_lo
	.section	.data.g_thr_lo,"aw",%progbits
	.p2align	2, 0x0
g_thr_lo:
	.long	100                             @ 0x64
	.size	g_thr_lo, 4

	.type	g_selftest,%object              @ @g_selftest
	.section	.bss.g_selftest,"aw",%nobits
g_selftest:
	.zero	3
	.size	g_selftest, 3

	.type	g_boot_ms,%object               @ @g_boot_ms
	.section	.bss.g_boot_ms,"aw",%nobits
	.p2align	2, 0x0
g_boot_ms:
	.long	0                               @ 0x0
	.size	g_boot_ms, 4

	.type	s_devtest,%object               @ @s_devtest
	.section	.bss.s_devtest,"aw",%nobits
s_devtest:
	.byte	0                               @ 0x0
	.size	s_devtest, 1

	.type	.L.str,%object                  @ @.str
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str:
	.asciz	"[P1]"
	.size	.L.str, 5

	.type	.L.str.1,%object                @ @.str.1
.L.str.1:
	.asciz	"[P2]"
	.size	.L.str.1, 5

	.type	.L.str.2,%object                @ @.str.2
.L.str.2:
	.asciz	"[P3]"
	.size	.L.str.2, 5

	.type	g_thr_dirty,%object             @ @g_thr_dirty
	.section	.bss.g_thr_dirty,"aw",%nobits
g_thr_dirty:
	.byte	0                               @ 0x0
	.size	g_thr_dirty, 1

	.type	g_thr_push,%object              @ @g_thr_push
	.section	.bss.g_thr_push,"aw",%nobits
g_thr_push:
	.byte	0                               @ 0x0
	.size	g_thr_push, 1

	.type	g_save_pending,%object          @ @g_save_pending
	.section	.bss.g_save_pending,"aw",%nobits
g_save_pending:
	.byte	0                               @ 0x0
	.size	g_save_pending, 1

	.type	g_thr_dirty_t,%object           @ @g_thr_dirty_t
	.section	.bss.g_thr_dirty_t,"aw",%nobits
	.p2align	2, 0x0
g_thr_dirty_t:
	.long	0                               @ 0x0
	.size	g_thr_dirty_t, 4

	.type	g_skip,%object                  @ @g_skip
	.section	.bss.g_skip,"aw",%nobits
g_skip:
	.byte	0                               @ 0x0
	.size	g_skip, 1

	.type	g_thr_hi_req,%object            @ @g_thr_hi_req
	.section	.bss.g_thr_hi_req,"aw",%nobits
g_thr_hi_req:
	.byte	0                               @ 0x0
	.size	g_thr_hi_req, 1

	.type	g_thr_try,%object               @ @g_thr_try
	.section	.bss.g_thr_try,"aw",%nobits
g_thr_try:
	.byte	0                               @ 0x0
	.size	g_thr_try, 1

	.type	g_thr_t0,%object                @ @g_thr_t0
	.section	.bss.g_thr_t0,"aw",%nobits
	.p2align	2, 0x0
g_thr_t0:
	.long	0                               @ 0x0
	.size	g_thr_t0, 4

	.type	g_mute,%object                  @ @g_mute
	.section	.bss.g_mute,"aw",%nobits
g_mute:
	.byte	0                               @ 0x0
	.size	g_mute, 1

	.type	g_cal_req,%object               @ @g_cal_req
	.section	.bss.g_cal_req,"aw",%nobits
g_cal_req:
	.byte	0                               @ 0x0
	.size	g_cal_req, 1

	.type	g_hist_clear_req,%object        @ @g_hist_clear_req
	.section	.bss.g_hist_clear_req,"aw",%nobits
g_hist_clear_req:
	.byte	0                               @ 0x0
	.size	g_hist_clear_req, 1

	.type	g_tbl_page,%object              @ @g_tbl_page
	.section	.data.g_tbl_page,"aw",%progbits
	.p2align	1, 0x0
g_tbl_page:
	.short	1                               @ 0x1
	.size	g_tbl_page, 2

	.type	g_refill_req,%object            @ @g_refill_req
	.section	.bss.g_refill_req,"aw",%nobits
g_refill_req:
	.byte	0                               @ 0x0
	.size	g_refill_req, 1

	.type	g_page_now,%object              @ @g_page_now
	.section	.data.g_page_now,"aw",%progbits
g_page_now:
	.byte	255                             @ 0xff
	.size	g_page_now, 1

	.type	g_full_dirty,%object            @ @g_full_dirty
	.section	.data.g_full_dirty,"aw",%progbits
g_full_dirty:
	.byte	1                               @ 0x1
	.size	g_full_dirty, 1

	.type	g_cal_st_dirty,%object          @ @g_cal_st_dirty
	.section	.bss.g_cal_st_dirty,"aw",%nobits
g_cal_st_dirty:
	.byte	0                               @ 0x0
	.size	g_cal_st_dirty, 1

	.type	g_test,%object                  @ @g_test
	.section	.bss.g_test,"aw",%nobits
g_test:
	.byte	0                               @ 0x0
	.size	g_test, 1

	.type	g_test_t0,%object               @ @g_test_t0
	.section	.bss.g_test_t0,"aw",%nobits
	.p2align	2, 0x0
g_test_t0:
	.long	0                               @ 0x0
	.size	g_test_t0, 4

	.type	g_sess_sum,%object              @ @g_sess_sum
	.section	.bss.g_sess_sum,"aw",%nobits
	.p2align	3, 0x0
g_sess_sum:
	.long	0                               @ 0x0
	.long	0
	.size	g_sess_sum, 8

	.type	g_sess_cnt,%object              @ @g_sess_cnt
	.section	.bss.g_sess_cnt,"aw",%nobits
	.p2align	2, 0x0
g_sess_cnt:
	.long	0                               @ 0x0
	.size	g_sess_cnt, 4

	.type	g_sess_max,%object              @ @g_sess_max
	.section	.bss.g_sess_max,"aw",%nobits
	.p2align	1, 0x0
g_sess_max:
	.short	0                               @ 0x0
	.size	g_sess_max, 2

	.type	g_sess_min,%object              @ @g_sess_min
	.section	.data.g_sess_min,"aw",%progbits
	.p2align	1, 0x0
g_sess_min:
	.short	65535                           @ 0xffff
	.size	g_sess_min, 2

	.type	g_peak,%object                  @ @g_peak
	.section	.bss.g_peak,"aw",%nobits
	.p2align	2, 0x0
g_peak:
	.long	0x00000000                      @ float 0
	.size	g_peak, 4

	.type	g_min,%object                   @ @g_min
	.section	.data.g_min,"aw",%progbits
	.p2align	2, 0x0
g_min:
	.long	0x4a83126e                      @ float 4294967
	.size	g_min, 4

	.type	g_get_busy,%object              @ @g_get_busy
	.section	.bss.g_get_busy,"aw",%nobits
g_get_busy:
	.byte	0                               @ 0x0
	.size	g_get_busy, 1

	.type	g_thr_wait,%object              @ @g_thr_wait
	.section	.bss.g_thr_wait,"aw",%nobits
g_thr_wait:
	.byte	0                               @ 0x0
	.size	g_thr_wait, 1

	.type	g_sync_st,%object               @ @g_sync_st
	.section	.bss.g_sync_st,"aw",%nobits
g_sync_st:
	.byte	0                               @ 0x0
	.size	g_sync_st, 1

	.type	g_rtc_wait,%object              @ @g_rtc_wait
	.section	.bss.g_rtc_wait,"aw",%nobits
g_rtc_wait:
	.byte	0                               @ 0x0
	.size	g_rtc_wait, 1

	.type	g_time_sync_idx,%object         @ @g_time_sync_idx
	.section	.bss.g_time_sync_idx,"aw",%nobits
g_time_sync_idx:
	.byte	0                               @ 0x0
	.size	g_time_sync_idx, 1

	.type	g_sync_sec0,%object             @ @g_sync_sec0
	.section	.data.g_sync_sec0,"aw",%progbits
	.p2align	2, 0x0
g_sync_sec0:
	.long	4294967295                      @ 0xffffffff
	.size	g_sync_sec0, 4

	.type	g_sync_t0,%object               @ @g_sync_t0
	.section	.bss.g_sync_t0,"aw",%nobits
	.p2align	2, 0x0
g_sync_t0:
	.long	0                               @ 0x0
	.size	g_sync_t0, 4

	.type	g_sync_rtc,%object              @ @g_sync_rtc
	.section	.bss.g_sync_rtc,"aw",%nobits
	.p2align	2, 0x0
g_sync_rtc:
	.zero	24
	.size	g_sync_rtc, 24

	.type	.L.str.3,%object                @ @.str.3
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str.3:
	.asciz	"h"
	.size	.L.str.3, 2

	.type	.L.str.4,%object                @ @.str.4
.L.str.4:
	.asciz	"thr"
	.size	.L.str.4, 4

	.type	hiwdg,%object                   @ @hiwdg
	.section	.bss.hiwdg,"aw",%nobits
	.p2align	2, 0x0
hiwdg:
	.zero	12
	.size	hiwdg, 12

	.type	g_iwdg_on,%object               @ @g_iwdg_on
	.section	.bss.g_iwdg_on,"aw",%nobits
g_iwdg_on:
	.byte	0                               @ 0x0
	.size	g_iwdg_on, 1

	.type	g_iwdg_t,%object                @ @g_iwdg_t
	.section	.bss.g_iwdg_t,"aw",%nobits
	.p2align	2, 0x0
g_iwdg_t:
	.long	0                               @ 0x0
	.size	g_iwdg_t, 4

	.type	hmi_update_init_countdown.last_left,%object @ @hmi_update_init_countdown.last_left
	.section	.data.hmi_update_init_countdown.last_left,"aw",%progbits
	.p2align	2, 0x0
hmi_update_init_countdown.last_left:
	.long	4294967295                      @ 0xffffffff
	.size	hmi_update_init_countdown.last_left, 4

	.type	g_page_init,%object             @ @g_page_init
	.section	.data.g_page_init,"aw",%progbits
g_page_init:
	.byte	1                               @ 0x1
	.size	g_page_init, 1

	.type	.L.str.5,%object                @ @.str.5
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str.5:
	.asciz	"\312\243\323\340 %d \303\353"
	.size	.L.str.5, 11

	.type	.L.str.6,%object                @ @.str.6
.L.str.6:
	.asciz	"pt0_i"
	.size	.L.str.6, 6

	.type	hmi_update_selftest.s_fail,%object @ @hmi_update_selftest.s_fail
	.section	.data.hmi_update_selftest.s_fail,"aw",%progbits
hmi_update_selftest.s_fail:
	.byte	255                             @ 0xff
	.size	hmi_update_selftest.s_fail, 1

	.type	hmi_update_selftest.s_rst,%object @ @hmi_update_selftest.s_rst
	.section	.data.hmi_update_selftest.s_rst,"aw",%progbits
hmi_update_selftest.s_rst:
	.byte	255                             @ 0xff
	.size	hmi_update_selftest.s_rst, 1

	.type	.L.str.7,%object                @ @.str.7
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str.7:
	.asciz	"\262\316\312\375\322\321\326\330\326\303\243\254\307\353\326\330\320\302\311\350\326\303\343\320\326\265"
	.size	.L.str.7, 27

	.type	.L.str.8,%object                @ @.str.8
.L.str.8:
	.asciz	"\327\324\274\354\315\250\271\375"
	.size	.L.str.8, 9

	.type	.L.str.9,%object                @ @.str.9
.L.str.9:
	.asciz	"\264\346\264\242\306\367\271\312\325\317"
	.size	.L.str.9, 11

	.type	.L.str.10,%object               @ @.str.10
.L.str.10:
	.asciz	"\265\347\263\330\262\311\321\371\322\354\263\243"
	.size	.L.str.10, 13

	.type	.L.str.11,%object               @ @.str.11
.L.str.11:
	.asciz	"\264\346\264\242\306\367/\265\347\263\330\271\312\325\317"
	.size	.L.str.11, 16

	.type	.L.str.12,%object               @ @.str.12
.L.str.12:
	.asciz	"pst_i"
	.size	.L.str.12, 6

	.type	low_batt_poll.s_lv,%object      @ @low_batt_poll.s_lv
	.section	.data.low_batt_poll.s_lv,"aw",%progbits
low_batt_poll.s_lv:
	.byte	255                             @ 0xff
	.size	low_batt_poll.s_lv, 1

	.type	low_batt_poll.s_pend,%object    @ @low_batt_poll.s_pend
	.section	.data.low_batt_poll.s_pend,"aw",%progbits
low_batt_poll.s_pend:
	.byte	255                             @ 0xff
	.size	low_batt_poll.s_pend, 1

	.type	low_batt_poll.s_pend_t,%object  @ @low_batt_poll.s_pend_t
	.section	.bss.low_batt_poll.s_pend_t,"aw",%nobits
	.p2align	2, 0x0
low_batt_poll.s_pend_t:
	.long	0                               @ 0x0
	.size	low_batt_poll.s_pend_t, 4

	.type	low_batt_poll.s_last_play,%object @ @low_batt_poll.s_last_play
	.section	.bss.low_batt_poll.s_last_play,"aw",%nobits
	.p2align	2, 0x0
low_batt_poll.s_last_play:
	.long	0                               @ 0x0
	.size	low_batt_poll.s_last_play, 4

	.type	.L.str.13,%object               @ @.str.13
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str.13:
	.asciz	"_s1"
	.size	.L.str.13, 4

	.type	.L.str.14,%object               @ @.str.14
.L.str.14:
	.asciz	"_i"
	.size	.L.str.14, 3

	.type	.L.str.15,%object               @ @.str.15
.L.str.15:
	.zero	1
	.size	.L.str.15, 1

	.type	.L.str.16,%object               @ @.str.16
.L.str.16:
	.asciz	"_s2"
	.size	.L.str.16, 4

	.type	.L.str.17,%object               @ @.str.17
.L.str.17:
	.asciz	"_f"
	.size	.L.str.17, 3

	.type	.L.str.18,%object               @ @.str.18
.L.str.18:
	.asciz	"lb%s"
	.size	.L.str.18, 5

	.type	.L.str.19,%object               @ @.str.19
.L.str.19:
	.asciz	"\265\347\301\277\265\315\243\254\307\353\263\344\265\347"
	.size	.L.str.19, 15

	.type	.L.str.20,%object               @ @.str.20
.L.str.20:
	.asciz	"\265\347\301\277\274\264\275\253\272\304\276\241"
	.size	.L.str.20, 13

	.type	.L.str.21,%object               @ @.str.21
.L.str.21:
	.asciz	"\265\347\301\277\275\253\272\304\276\241\307\353\301\242\274\264\263\344\265\347"
	.size	.L.str.21, 21

	.type	g_ppm,%object                   @ @g_ppm
	.section	.bss.g_ppm,"aw",%nobits
	.p2align	2, 0x0
g_ppm:
	.long	0x00000000                      @ float 0
	.size	g_ppm, 4

	.type	g_warm,%object                  @ @g_warm
	.section	.bss.g_warm,"aw",%nobits
	.p2align	2, 0x0
g_warm:
	.long	0                               @ 0x0
	.size	g_warm, 4

	.type	g_alarm,%object                 @ @g_alarm
	.section	.bss.g_alarm,"aw",%nobits
	.p2align	2, 0x0
g_alarm:
	.long	0                               @ 0x0
	.size	g_alarm, 4

	.type	app_refresh.s_ring,%object      @ @app_refresh.s_ring
	.section	.bss.app_refresh.s_ring,"aw",%nobits
	.p2align	2, 0x0
app_refresh.s_ring:
	.long	0x00000000                      @ float 0
	.size	app_refresh.s_ring, 4

	.type	g_avg_n,%object                 @ @g_avg_n
	.section	.bss.g_avg_n,"aw",%nobits
	.p2align	1, 0x0
g_avg_n:
	.short	0                               @ 0x0
	.size	g_avg_n, 2

	.type	g_avg_buf,%object               @ @g_avg_buf
	.section	.bss.g_avg_buf,"aw",%nobits
	.p2align	2, 0x0
g_avg_buf:
	.zero	240
	.size	g_avg_buf, 240

	.type	g_avg_i,%object                 @ @g_avg_i
	.section	.bss.g_avg_i,"aw",%nobits
	.p2align	1, 0x0
g_avg_i:
	.short	0                               @ 0x0
	.size	g_avg_i, 2

	.type	g_avg_run,%object               @ @g_avg_run
	.section	.bss.g_avg_run,"aw",%nobits
	.p2align	2, 0x0
g_avg_run:
	.long	0x00000000                      @ float 0
	.size	g_avg_run, 4

	.type	app_refresh.prev,%object        @ @app_refresh.prev
	.section	.data.app_refresh.prev,"aw",%progbits
	.p2align	2, 0x0
app_refresh.prev:
	.long	4294967295                      @ 0xffffffff
	.size	app_refresh.prev, 4

	.type	app_refresh.tlast,%object       @ @app_refresh.tlast
	.section	.bss.app_refresh.tlast,"aw",%nobits
	.p2align	2, 0x0
app_refresh.tlast:
	.long	0                               @ 0x0
	.size	app_refresh.tlast, 4

	.type	app_refresh.s_mute_prev,%object @ @app_refresh.s_mute_prev
	.section	.bss.app_refresh.s_mute_prev,"aw",%nobits
app_refresh.s_mute_prev:
	.byte	0                               @ 0x0
	.size	app_refresh.s_mute_prev, 1

	.type	app_refresh.s_mute,%object      @ @app_refresh.s_mute
	.section	.data.app_refresh.s_mute,"aw",%progbits
app_refresh.s_mute:
	.byte	255                             @ 0xff
	.size	app_refresh.s_mute, 1

	.type	.L.str.22,%object               @ @.str.22
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str.22:
	.asciz	"bm"
	.size	.L.str.22, 3

	.type	.L.str.23,%object               @ @.str.23
.L.str.23:
	.asciz	"\322\321\276\262\322\364"
	.size	.L.str.23, 7

	.type	.L.str.24,%object               @ @.str.24
.L.str.24:
	.asciz	"\276\262\322\364"
	.size	.L.str.24, 5

	.type	app_refresh.s_test,%object      @ @app_refresh.s_test
	.section	.data.app_refresh.s_test,"aw",%progbits
app_refresh.s_test:
	.byte	255                             @ 0xff
	.size	app_refresh.s_test, 1

	.type	.L.str.25,%object               @ @.str.25
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str.25:
	.asciz	"ptg"
	.size	.L.str.25, 4

	.type	.L.str.26,%object               @ @.str.26
.L.str.26:
	.asciz	"\262\342\312\324\326\320"
	.size	.L.str.26, 7

	.type	.L.str.27,%object               @ @.str.27
.L.str.27:
	.asciz	"\277\252\312\274\262\342\312\324"
	.size	.L.str.27, 9

	.type	app_refresh.hist_last,%object   @ @app_refresh.hist_last
	.section	.bss.app_refresh.hist_last,"aw",%nobits
	.p2align	2, 0x0
app_refresh.hist_last:
	.long	0                               @ 0x0
	.size	app_refresh.hist_last, 4

	.type	app_refresh.rlast,%object       @ @app_refresh.rlast
	.section	.bss.app_refresh.rlast,"aw",%nobits
	.p2align	2, 0x0
app_refresh.rlast:
	.long	0                               @ 0x0
	.size	app_refresh.rlast, 4

	.type	app_refresh.s_total,%object     @ @app_refresh.s_total
	.section	.data.app_refresh.s_total,"aw",%progbits
	.p2align	2, 0x0
app_refresh.s_total:
	.long	4294967295                      @ 0xffffffff
	.size	app_refresh.s_total, 4

	.type	app_refresh.s_pg,%object        @ @app_refresh.s_pg
	.section	.bss.app_refresh.s_pg,"aw",%nobits
	.p2align	1, 0x0
app_refresh.s_pg:
	.short	0                               @ 0x0
	.size	app_refresh.s_pg, 2

	.type	.L.str.28,%object               @ @.str.28
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str.28:
	.asciz	"cc"
	.size	.L.str.28, 3

	.type	g_avg_str,%object               @ @g_avg_str
	.section	.bss.g_avg_str,"aw",%nobits
g_avg_str:
	.zero	16
	.size	g_avg_str, 16

	.type	.L.str.29,%object               @ @.str.29
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str.29:
	.asciz	"%.2f"
	.size	.L.str.29, 5

	.type	app_refresh.s_mx,%object        @ @app_refresh.s_mx
	.section	.data.app_refresh.s_mx,"aw",%progbits
	.p2align	2, 0x0
app_refresh.s_mx:
	.long	4294967295                      @ 0xffffffff
	.size	app_refresh.s_mx, 4

	.type	app_refresh.s_mn,%object        @ @app_refresh.s_mn
	.section	.data.app_refresh.s_mn,"aw",%progbits
	.p2align	2, 0x0
app_refresh.s_mn:
	.long	4294967295                      @ 0xffffffff
	.size	app_refresh.s_mn, 4

	.type	.L.str.30,%object               @ @.str.30
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str.30:
	.asciz	"\327\356\264\363\326\265: %.0f"
	.size	.L.str.30, 13

	.type	.L.str.31,%object               @ @.str.31
.L.str.31:
	.asciz	"cma"
	.size	.L.str.31, 4

	.type	.L.str.32,%object               @ @.str.32
.L.str.32:
	.asciz	"\327\356\320\241\326\265: %.0f"
	.size	.L.str.32, 13

	.type	.L.str.33,%object               @ @.str.33
.L.str.33:
	.asciz	"cmn"
	.size	.L.str.33, 4

	.type	CONC_COLOR,%object              @ @CONC_COLOR
	.section	.rodata.CONC_COLOR,"a",%progbits
	.p2align	2, 0x0
CONC_COLOR:
	.long	57149                           @ 0xdf3d
	.long	62689                           @ 0xf4e1
	.long	59944                           @ 0xea28
	.long	59944                           @ 0xea28
	.size	CONC_COLOR, 16

	.type	app_refresh.s_ccc,%object       @ @app_refresh.s_ccc
	.section	.data.app_refresh.s_ccc,"aw",%progbits
	.p2align	2, 0x0
app_refresh.s_ccc:
	.long	4294967295                      @ 0xffffffff
	.size	app_refresh.s_ccc, 4

	.type	.L.str.34,%object               @ @.str.34
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str.34:
	.asciz	"\271\314\274\376\260\346\261\276: %s"
	.size	.L.str.34, 13

	.type	.L.str.35,%object               @ @.str.35
.L.str.35:
	.asciz	"V1.0-b62"
	.size	.L.str.35, 9

	.type	.L.str.36,%object               @ @.str.36
.L.str.36:
	.asciz	"fw"
	.size	.L.str.36, 3

	.type	.L.str.37,%object               @ @.str.37
.L.str.37:
	.asciz	"\262\372\306\267\261\340\272\305: %s"
	.size	.L.str.37, 13

	.type	.L.str.38,%object               @ @.str.38
.L.str.38:
	.asciz	"sn"
	.size	.L.str.38, 3

	.type	g_sync_deadline,%object         @ @g_sync_deadline
	.section	.bss.g_sync_deadline,"aw",%nobits
	.p2align	2, 0x0
g_sync_deadline:
	.long	0                               @ 0x0
	.size	g_sync_deadline, 4

	.type	.L.str.39,%object               @ @.str.39
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str.39:
	.asciz	"rsec_i"
	.size	.L.str.39, 7

	.type	RTC_MIRROR,%object              @ @RTC_MIRROR
	.section	.rodata.RTC_MIRROR,"a",%progbits
	.p2align	2, 0x0
RTC_MIRROR:
	.long	.L.str.41
	.long	.L.str.42
	.long	.L.str.43
	.long	.L.str.44
	.long	.L.str.45
	.long	.L.str.39
	.size	RTC_MIRROR, 24

	.type	.L.str.40,%object               @ @.str.40
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str.40:
	.asciz	"val"
	.size	.L.str.40, 4

	.type	.L.str.41,%object               @ @.str.41
.L.str.41:
	.asciz	"rY_i"
	.size	.L.str.41, 5

	.type	.L.str.42,%object               @ @.str.42
.L.str.42:
	.asciz	"rM_i"
	.size	.L.str.42, 5

	.type	.L.str.43,%object               @ @.str.43
.L.str.43:
	.asciz	"rD_i"
	.size	.L.str.43, 5

	.type	.L.str.44,%object               @ @.str.44
.L.str.44:
	.asciz	"rH_i"
	.size	.L.str.44, 5

	.type	.L.str.45,%object               @ @.str.45
.L.str.45:
	.asciz	"rMi_i"
	.size	.L.str.45, 6

	.type	g_thr_deadline,%object          @ @g_thr_deadline
	.section	.bss.g_thr_deadline,"aw",%nobits
	.p2align	2, 0x0
g_thr_deadline:
	.long	0                               @ 0x0
	.size	g_thr_deadline, 4

	.type	.L.str.46,%object               @ @.str.46
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str.46:
	.asciz	"%04d-%02d-%02d %02d:%02d:%02d"
	.size	.L.str.46, 30

	.type	.L.str.47,%object               @ @.str.47
.L.str.47:
	.asciz	"%u"
	.size	.L.str.47, 3

	.type	.L.str.48,%object               @ @.str.48
.L.str.48:
	.asciz	"%04lu"
	.size	.L.str.48, 6

	.type	.L.str.49,%object               @ @.str.49
.L.str.49:
	.asciz	" "
	.size	.L.str.49, 2

	.type	.L.str.50,%object               @ @.str.50
.L.str.50:
	.asciz	"%s%u"
	.size	.L.str.50, 5

	.type	.L.str.51,%object               @ @.str.51
.L.str.51:
	.asciz	"tt"
	.size	.L.str.51, 3

	.type	.L.str.52,%object               @ @.str.52
.L.str.52:
	.asciz	"np"
	.size	.L.str.52, 3

	.type	.L.str.53,%object               @ @.str.53
.L.str.53:
	.asciz	"%u/%u"
	.size	.L.str.53, 6

	.type	.L.str.54,%object               @ @.str.54
.L.str.54:
	.asciz	"pg"
	.size	.L.str.54, 3

	.type	.L.str.55,%object               @ @.str.55
.L.str.55:
	.asciz	"0"
	.size	.L.str.55, 2

	.type	.L.str.56,%object               @ @.str.56
.L.str.56:
	.asciz	"mx"
	.size	.L.str.56, 3

	.type	.L.str.57,%object               @ @.str.57
.L.str.57:
	.asciz	"av"
	.size	.L.str.57, 3

	.type	.L.str.58,%object               @ @.str.58
.L.str.58:
	.asciz	"mn"
	.size	.L.str.58, 3

	.type	.L.str.59,%object               @ @.str.59
.L.str.59:
	.asciz	"du"
	.size	.L.str.59, 3

	.type	.L.str.60,%object               @ @.str.60
.L.str.60:
	.asciz	"ct"
	.size	.L.str.60, 3

	.type	.L.str.61,%object               @ @.str.61
.L.str.61:
	.asciz	"%.1f"
	.size	.L.str.61, 5

	.type	hmi_update_status_chips.s_dot,%object @ @hmi_update_status_chips.s_dot
	.section	.data.hmi_update_status_chips.s_dot,"aw",%progbits
hmi_update_status_chips.s_dot:
	.byte	255                             @ 0xff
	.size	hmi_update_status_chips.s_dot, 1

	.type	hmi_update_status_chips.s_pump,%object @ @hmi_update_status_chips.s_pump
	.section	.data.hmi_update_status_chips.s_pump,"aw",%progbits
hmi_update_status_chips.s_pump:
	.byte	255                             @ 0xff
	.size	hmi_update_status_chips.s_pump, 1

	.type	hmi_update_status_chips.s_bat,%object @ @hmi_update_status_chips.s_bat
	.section	.data.hmi_update_status_chips.s_bat,"aw",%progbits
hmi_update_status_chips.s_bat:
	.byte	255                             @ 0xff
	.size	hmi_update_status_chips.s_bat, 1

	.type	hmi_update_status_chips.s_strip,%object @ @hmi_update_status_chips.s_strip
	.section	.data.hmi_update_status_chips.s_strip,"aw",%progbits
	.p2align	2, 0x0
hmi_update_status_chips.s_strip:
	.long	4294967295                      @ 0xffffffff
	.size	hmi_update_status_chips.s_strip, 4

	.type	.L.str.62,%object               @ @.str.62
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str.62:
	.asciz	"pc0d%s"
	.size	.L.str.62, 7

	.type	.L.str.63,%object               @ @.str.63
.L.str.63:
	.asciz	"pc1d%s"
	.size	.L.str.63, 7

	.type	.L.str.64,%object               @ @.str.64
.L.str.64:
	.asciz	"pc2d%s"
	.size	.L.str.64, 7

	.type	.L.str.65,%object               @ @.str.65
.L.str.65:
	.asciz	"dvr%s"
	.size	.L.str.65, 6

	.type	.L.str.66,%object               @ @.str.66
.L.str.66:
	.asciz	"pc0%s"
	.size	.L.str.66, 6

	.type	.L.str.67,%object               @ @.str.67
.L.str.67:
	.asciz	"\314\275\315\267 \322\321\301\254\275\323"
	.size	.L.str.67, 12

	.type	.L.str.68,%object               @ @.str.68
.L.str.68:
	.asciz	"\314\275\315\267 \316\264\301\254\275\323"
	.size	.L.str.68, 12

	.type	.L.str.69,%object               @ @.str.69
.L.str.69:
	.asciz	"pc1%s"
	.size	.L.str.69, 6

	.type	.L.str.70,%object               @ @.str.70
.L.str.70:
	.asciz	"\261\303 \322\321\306\364\266\257"
	.size	.L.str.70, 10

	.type	.L.str.71,%object               @ @.str.71
.L.str.71:
	.asciz	"\261\303 \316\264\306\364\266\257"
	.size	.L.str.71, 10

	.type	.L.str.72,%object               @ @.str.72
.L.str.72:
	.asciz	"cst_f"
	.size	.L.str.72, 6

	.type	.L.str.73,%object               @ @.str.73
.L.str.73:
	.asciz	"\261\352\266\250\243\272\316\264\261\352\266\250"
	.size	.L.str.73, 13

	.type	.L.str.74,%object               @ @.str.74
.L.str.74:
	.asciz	"\261\352\266\250\243\272%04d-%02d-%02d \322\321\263\254\306\332 \262\271\263\245%dppm"
	.size	.L.str.74, 38

	.type	.L.str.75,%object               @ @.str.75
.L.str.75:
	.asciz	"\261\352\266\250\243\272%04d-%02d-%02d \262\271\263\245%dppm"
	.size	.L.str.75, 31

	.type	g_cal0_armed,%object            @ @g_cal0_armed
	.section	.bss.g_cal0_armed,"aw",%nobits
g_cal0_armed:
	.byte	0                               @ 0x0
	.size	g_cal0_armed, 1

	.type	g_cal0_owner,%object            @ @g_cal0_owner
	.section	.bss.g_cal0_owner,"aw",%nobits
g_cal0_owner:
	.byte	0                               @ 0x0
	.size	g_cal0_owner, 1

	.type	g_cal0_t0,%object               @ @g_cal0_t0
	.section	.bss.g_cal0_t0,"aw",%nobits
	.p2align	2, 0x0
g_cal0_t0:
	.long	0                               @ 0x0
	.size	g_cal0_t0, 4

	.type	g_cal0_ppm0,%object             @ @g_cal0_ppm0
	.section	.bss.g_cal0_ppm0,"aw",%nobits
	.p2align	2, 0x0
g_cal0_ppm0:
	.long	0x00000000                      @ float 0
	.size	g_cal0_ppm0, 4

	.type	.L.str.76,%object               @ @.str.76
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str.76:
	.asciz	"c0"
	.size	.L.str.76, 3

	.type	.L.str.77,%object               @ @.str.77
.L.str.77:
	.asciz	"c1"
	.size	.L.str.77, 3

	.type	.L.str.78,%object               @ @.str.78
.L.str.78:
	.asciz	"cwh"
	.size	.L.str.78, 4

	.type	.L.str.79,%object               @ @.str.79
.L.str.79:
	.asciz	"cl15"
	.size	.L.str.79, 5

	.type	.L.str.80,%object               @ @.str.80
.L.str.80:
	.asciz	"cf"
	.size	.L.str.80, 3

	.type	.L.str.81,%object               @ @.str.81
.L.str.81:
	.asciz	"crs_f"
	.size	.L.str.81, 6

	.type	.L.str.82,%object               @ @.str.82
.L.str.82:
	.asciz	"crs_s1"
	.size	.L.str.82, 7

	.type	.L.str.83,%object               @ @.str.83
.L.str.83:
	.asciz	"\326\264\320\320"
	.size	.L.str.83, 5

	.type	.L.str.84,%object               @ @.str.84
.L.str.84:
	.asciz	"\301\343\265\343\261\352\266\250\315\352\263\311 \262\271\263\245%dppm\243\254\307\353\310\267\310\317\273\267\276\263\275\340\276\273"
	.size	.L.str.84, 39

	.type	.L.str.85,%object               @ @.str.85
.L.str.85:
	.asciz	"\301\277\263\314\261\352\266\250\315\352\263\311 \301\351\303\364\266\310 %d.%02d"
	.size	.L.str.85, 28

	.type	.L.str.86,%object               @ @.str.86
.L.str.86:
	.asciz	"\323\262\274\376\301\343\265\343\326\270\301\356\322\321\317\302\267\242\243\254\307\353\310\267\310\317\266\301\312\375\312\307\267\361\271\351\301\343"
	.size	.L.str.86, 39

	.type	.L.str.87,%object               @ @.str.87
.L.str.87:
	.asciz	"15ppm \317\302\317\336\326\270\301\356\322\321\317\302\267\242\243\25415 \322\324\304\332\323\246\317\324\312\276 0"
	.size	.L.str.87, 38

	.type	.L.str.88,%object               @ @.str.88
.L.str.88:
	.asciz	"\322\321\273\326\270\264\263\366\263\247\311\350\326\303\243\254\311\350\261\270\326\330\306\364\326\320"
	.size	.L.str.88, 27

	.type	.L.str.89,%object               @ @.str.89
.L.str.89:
	.asciz	"\322\321\317\302\267\242"
	.size	.L.str.89, 7

	.type	.L.str.90,%object               @ @.str.90
.L.str.90:
	.asciz	"\316\264\275\323\315\250"
	.size	.L.str.90, 7

	.type	.L.str.91,%object               @ @.str.91
.L.str.91:
	.asciz	"\261\352\266\250\312\247\260\334\243\272\314\275\315\267\316\264\301\254\275\323"
	.size	.L.str.91, 21

	.type	.L.str.92,%object               @ @.str.92
.L.str.92:
	.asciz	"\324\244\310\310\326\320"
	.size	.L.str.92, 7

	.type	.L.str.93,%object               @ @.str.93
.L.str.93:
	.asciz	"\261\352\266\250\312\247\260\334\243\272\320\350\277\252\273\372 %u \303\353\272\363\243\250\312\276\312\375\316\310\266\250\243\251"
	.size	.L.str.93, 37

	.type	.L.str.94,%object               @ @.str.94
.L.str.94:
	.asciz	"\305\250\266\310\270\337"
	.size	.L.str.94, 7

	.type	.L.str.95,%object               @ @.str.95
.L.str.95:
	.asciz	"\301\343\265\343\312\247\260\334\243\272\265\261\307\260\263\254 %d ppm\243\254\320\350\275\340\276\273\277\325\306\370"
	.size	.L.str.95, 36

	.type	.L.str.96,%object               @ @.str.96
.L.str.96:
	.asciz	"\263\254\264\260\277\332"
	.size	.L.str.96, 7

	.type	.L.str.97,%object               @ @.str.97
.L.str.97:
	.asciz	"\301\277\263\314\312\247\260\334\243\272\312\276\312\375\320\350\324\332 %d~%d ppm"
	.size	.L.str.97, 29

	.type	.L.str.98,%object               @ @.str.98
.L.str.98:
	.asciz	"\267\307\267\250\326\265"
	.size	.L.str.98, 7

	.type	.L.str.99,%object               @ @.str.99
.L.str.99:
	.asciz	"\261\352\266\250\312\247\260\334\243\272\324\255\312\274\266\301\312\375\316\252 0\243\254\274\354\262\351\314\275\315\267"
	.size	.L.str.99, 33

	.type	.L.str.100,%object              @ @.str.100
.L.str.100:
	.asciz	"\316\336\301\343\265\343"
	.size	.L.str.100, 7

	.type	.L.str.101,%object              @ @.str.101
.L.str.101:
	.asciz	"\301\277\263\314\312\247\260\334\243\272\307\353\317\310\327\366\301\343\265\343\261\352\266\250"
	.size	.L.str.101, 25

	.type	.L.str.102,%object              @ @.str.102
.L.str.102:
	.asciz	"\265\343\314\253\275\374"
	.size	.L.str.102, 7

	.type	.L.str.103,%object              @ @.str.103
.L.str.103:
	.asciz	"\301\277\263\314\312\247\260\334\243\272\323\353\301\343\265\343\266\301\312\375\262\356\262\273\327\343 %d"
	.size	.L.str.103, 30

	.type	.L.str.104,%object              @ @.str.104
.L.str.104:
	.asciz	"\322\321\317\336\267\371"
	.size	.L.str.104, 7

	.type	.L.str.105,%object              @ @.str.105
.L.str.105:
	.asciz	"\301\277\263\314\261\352\266\250\243\272\320\261\302\312\263\254\267\266\316\247\322\321\317\336\267\371"
	.size	.L.str.105, 27

	.type	.L.str.106,%object              @ @.str.106
.L.str.106:
	.asciz	"\264\346\264\242\273\265"
	.size	.L.str.106, 7

	.type	.L.str.107,%object              @ @.str.107
.L.str.107:
	.asciz	"\312\247\260\334\243\272\264\346\264\242\306\367\271\312\325\317\243\254\316\336\267\250\261\243\264\346"
	.size	.L.str.107, 27

	.type	.L.str.108,%object              @ @.str.108
.L.str.108:
	.asciz	"\264\375\310\267\310\317"
	.size	.L.str.108, 7

	.type	.L.str.109,%object              @ @.str.109
.L.str.109:
	.asciz	"\265\261\307\260 %dppm\243\254\320\353\275\340\276\273\277\325\306\370\243\2543\303\353\304\332\324\331\260\264\310\267\310\317"
	.size	.L.str.109, 38

	.type	.L.str.110,%object              @ @.str.110
.L.str.110:
	.asciz	"\275\253\317\302\267\242 15ppm \317\302\317\336\326\270\301\356\243\250\262\273\277\311\263\267\317\372\243\251\243\2543\303\353\304\332\324\331\260\264\310\267\310\317"
	.size	.L.str.110, 49

	.type	.L.str.111,%object              @ @.str.111
.L.str.111:
	.asciz	"\322\321\327\367\267\317"
	.size	.L.str.111, 7

	.type	.L.str.112,%object              @ @.str.112
.L.str.112:
	.asciz	"\305\250\266\310\322\321\261\344\273\257\243\254\307\353\326\330\320\302\265\343\273\367\301\343\265\343\261\352\266\250"
	.size	.L.str.112, 31

	.type	.L.str.113,%object              @ @.str.113
.L.str.113:
	.asciz	"\312\247\260\334"
	.size	.L.str.113, 5

	.type	.L.str.114,%object              @ @.str.114
.L.str.114:
	.asciz	"\261\352\266\250\312\247\260\334"
	.size	.L.str.114, 9

	.type	__ARM_use_no_argv,%object       @ @__ARM_use_no_argv
	.section	.ARM.use_no_argv,"awR",%progbits,unique,1
	.globl	__ARM_use_no_argv
	.p2align	2, 0x0
__ARM_use_no_argv:
	.long	1                               @ 0x1
	.size	__ARM_use_no_argv, 4

	.ident	"Component: Arm Compiler for Embedded 6.24 Tool: armclang [5f371800]"
	.section	".note.GNU-stack","",%progbits
	.eabi_attribute	30, 6	@ Tag_ABI_optimization_goals
	.ARM_attribute	16, 1	@ Tag_AV_eba
