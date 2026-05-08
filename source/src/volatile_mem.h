/* Bonsai GBA PSP volatile memory support
 *
 * Exposes the extra 4 MB of RAM in the PSP volatile memory partition
 * (partition 5). Based on the implementation from DaedalusX64; brought
 * across from FrogGBA into Bonsai GBA.
 */

#ifndef VOLATILE_MEM_H
#define VOLATILE_MEM_H

#include <pspkernel.h>
#include <pspsysmem.h>
#include <psppower.h>
#include <pspsuspend.h>

#ifdef __cplusplus
extern "C" {
#endif

// Initialize volatile memory system
// Returns 1 on success, 0 on failure
int volatile_mem_init(void);

// Shutdown volatile memory system
void volatile_mem_shutdown(void);

// Allocate memory from volatile partition
// Falls back to regular malloc if volatile memory unavailable
void* volatile_mem_alloc(size_t size);

// Free volatile memory
void volatile_mem_free(void* ptr);

// Check if pointer is in volatile memory range
int is_volatile_mem(void* ptr);

// Get available volatile memory size
size_t volatile_mem_available(void);

// Check if volatile memory is currently active
int volatile_mem_is_active(void);

#ifdef __cplusplus
}
#endif

#endif // VOLATILE_MEM_H