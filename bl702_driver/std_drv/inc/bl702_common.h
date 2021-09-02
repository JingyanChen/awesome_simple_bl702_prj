#ifndef __BL702_COMMON_H__
#define __BL702_COMMON_H__

#include "bl702.h"

/** @addtogroup  BL606_Peripheral_Driver
 *  @{
 */

/** @addtogroup  COMMON
 *  @{
 */

/** @defgroup  COMMON_Public_Types
 *  @{
 */

/*@} end of group COMMON_Public_Types */

/** @defgroup  COMMON_Public_Constants
 *  @{
 */

/** @defgroup DRIVER_INT_PERIPH
 *  @{
 */
#define IS_INT_PERIPH(INT_PERIPH) ((INT_PERIPH) < IRQn_LAST)

/*@} end of group DRIVER_INT_PERIPH */

/** @defgroup DRIVER_INT_MASK
 *  @{
 */
#define IS_BL_MASK_TYPE(type) (((type) == MASK) || ((type) == UNMASK))

/*@} end of group COMMON_Public_Constants */

/** @defgroup  COMMON_Public_Macros
 *  @{
 */

/*@} end of group DRIVER_Public_Macro */

/** @defgroup DRIVER_Public_FunctionDeclaration
 *  @brief DRIVER functions declaration
 *  @{
 */

/**
 * @brief Error type definition
 */
typedef enum {
    SUCCESS = 0,
    ERROR = 1,
    TIMEOUT = 2,
    INVALID = 3, /* invalid arguments */
    NORESC = 4   /* no resource or resource temperary unavailable */
} BL_Err_Type;

/**
 * @brief Functional type definition
 */
typedef enum {
    DISABLE = 0,
    ENABLE = 1,
} BL_Fun_Type;

/**
 * @brief Status type definition
 */
typedef enum {
    RESET = 0,
    SET = 1,
} BL_Sts_Type;

/**
 * @brief Mask type definition
 */
typedef enum {
    UNMASK = 0,
    MASK = 1
} BL_Mask_Type;

/**
 * @brief Logical status Type definition
 */
typedef enum {
    LOGIC_LO = 0,
    LOGIC_HI = !LOGIC_LO
} LogicalStatus;

/**
 * @brief Active status Type definition
 */
typedef enum {
    DEACTIVE = 0,
    ACTIVE = !DEACTIVE
} ActiveStatus;

/**
 *  @brief Interrupt callback function type
 */
typedef void(intCallback_Type)(void);
typedef void (*pFunc)(void);

#define ARCH_Delay_US BL702_Delay_US
#define ARCH_Delay_MS BL702_Delay_MS
#define arch_delay_us BL702_Delay_US
#define arch_delay_ms BL702_Delay_MS

void Interrupt_Handler_Register(IRQn_Type irq, pFunc interruptFun);
void ASM_Delay_Us(uint32_t core, uint32_t cnt);
void BL702_Delay_US(uint32_t cnt);
void BL702_Delay_MS(uint32_t cnt);
/*@} end of group DRIVER_COMMON  */

#endif /* __BL702_COMMON_H__ */
