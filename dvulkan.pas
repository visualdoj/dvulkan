unit dvulkan;

//
//  # Free Pascal Header for Vulkan API.
//
//  -- Doj, https://github.com/visualdoj/dvulkan
//  -- License: public domain (or MIT, see the end of the file)
//
//
//
//  ## Naming
//
//  Almost all names are consistent with those of the C headers:
//  * Vk*    - types
//  * vk*    - functions
//  * PFN_*  - pointers to functions
//  * VK_*   - constants
//
//  There are several exceptions, though:
//  * When a field or function argument is a Pascal keyword, an underscore
//    prefix is added, e.g. "_type" instead of "type"
//  * When a declaration instoduced which is not part of the Vulkan API,
//    regular pascal conventions are implied (e.g. T prefix for types)
//  * Additionaly, almost each type has corresponding "P*" and "PP*"
//    declarations for a "pointer to X" and a "pointer to pointer to X"
//    types respectively. For example, for VkBuffer there are PVkBuffer
//    and PPVkBuffer types.
//
//
//
//  ## The Loader
//
//  The `dvulkan` unit provides a loader. The loader consists of the following:
//  * Statically loaded function `vkGetInstanceProcAddr` provided by the system
//  * A function `LoadVulkanGeneralFunctions` and a record `TVulkanGeneralFunctions` for loading general function (i.e. non-instance and non-device functions)
//  * A function `LoadVulkanInstanceFunctions` and a record `TVulkanInstanceFunctions` for loading instance functions
//  * A function `LoadVulkanDeviceFunctions` and a record `TVulkanDeviceFunctions` for loading device functions
//
//  You can disable all the loader stuff by commenting the DVULKAN_LOADER
//  define below. It reduces binary size by removing strings for function names.
//
//  Here is an example pseudocode of how to use all of that:
//
//  ```
//    var
//      vkg: TVulkanGeneralFunctions;
//      vki: TVulkanInstanceFunctions;
//      vkd: TVulkanDeviceFunctions;
//      Instance: VkInstance;
//      Device: VkDevice;
//
//    function InitVulkan: Boolean;
//    begin
//      if not LoadVulkanGeneralFunctions(@vkGetInstanceProcAddr, vkg) then
//        Exit(False);
//
//      ...
//      if vkg.vkCreateInstance(@InstanceCreateInfo, nil, @Instance) <> VK_SUCCESS then
//        Exit(False);
//      if not LoadVulkanInstanceFunctions(Instance, vkg.vkGetInstanceProcAddr, vki) then
//        Exit(False);
//
//      ...
//      if vki.vkCreateDevice(PhysicalDevice, @DeviceCreateInfo, nil, @Device) <> VK_SUCCESS then
//        Exit(False);
//      // Notice the vki.vkGetDeviceProcAddr
//      if not LoadVulkanInstanceFunctions(instance, vki.vkGetDeviceProcAddr, vkd) then
//        Exit(False);
//      // Now all the functions loaded to vkg, vki, vkd and can be used
//
//      ...
//      Exit(True);
//    end;
//  ```
//
//
//
//  ##  Issues
//
//  * Tested only on Windows
//  * Declarations for vk_video are incomplete
//

{$MODE FPC}
{$PACKRECORDS C}

//
//  Configuration:
//

{$DEFINE DVULKAN_LOADER}
      // Enables the loader.

{$DEFINE DVULKAN_NAMES}
      // Enables string constants (extension names).
      // Disable it if you don't need them and want to reduce compiled file size.

interface

{$IF Defined(Windows)}
uses
  windows;
{$ENDIF}

const
{$IF Defined(WINDOWS)}
  VulkanLibraryName = 'vulkan-1.dll';
{$ELSEIF Defined(Darwin)}
  VulkanLibraryName = 'libvulkan.dylib';
  // VulkanLibraryName = 'libvulkan.1.dylib';
{$ELSE} // Unix, QNXNTO, Fuchsia
  VulkanLibraryName = 'libvulkan.so';
  // VulkanLibraryName = 'libvulkan.so.1';
{$ENDIF}

type
  PPUInt32 = ^PUInt32;
  HINSTANCE = UInt32;
  TVkHandle = Pointer;
  TVkHandleNonDispatchable = UInt64;

const
  VK_API_VERSION_1_0           = (1 shl 22) or (0 shl 12);
  VK_API_VERSION_1_1           = (1 shl 22) or (1 shl 12);
  VK_API_VERSION_1_2           = (1 shl 22) or (2 shl 12);
  VK_HEADER_VERSION            = 187;
  VK_HEADER_VERSION_COMPLETE   = VK_API_VERSION_1_2 or VK_HEADER_VERSION;

  VK_NULL_HANDLE = TVkHandleNonDispatchable(0);

type
  ANativeWindow   = Pointer;
  PANativeWindow  =  ^ANativeWindow;
  PPANativeWindow = ^PANativeWindow;
  AHardwareBuffer   = Pointer;
  PAHardwareBuffer  =  ^AHardwareBuffer;
  PPAHardwareBuffer = ^PAHardwareBuffer;
  CAMetalLayer   = Pointer;
  PCAMetalLayer  =  ^CAMetalLayer;
  PPCAMetalLayer = ^PCAMetalLayer;
  VkSampleMask   = UInt32;
  PVkSampleMask  =  ^VkSampleMask;
  PPVkSampleMask = ^PVkSampleMask;
  VkBool32   = UInt32;
  PVkBool32  =  ^VkBool32;
  PPVkBool32 = ^PVkBool32;
  VkFlags   = UInt32;
  PVkFlags  =  ^VkFlags;
  PPVkFlags = ^PVkFlags;
  VkFlags64   = UInt64;
  PVkFlags64  =  ^VkFlags64;
  PPVkFlags64 = ^PVkFlags64;
  VkDeviceSize   = UInt64;
  PVkDeviceSize  =  ^VkDeviceSize;
  PPVkDeviceSize = ^PVkDeviceSize;
  VkDeviceAddress   = UInt64;
  PVkDeviceAddress  =  ^VkDeviceAddress;
  PPVkDeviceAddress = ^PVkDeviceAddress;
  VkFramebufferCreateFlags   = VkFlags;
  PVkFramebufferCreateFlags  =  ^VkFramebufferCreateFlags;
  PPVkFramebufferCreateFlags = ^PVkFramebufferCreateFlags;
  VkQueryPoolCreateFlags   = VkFlags;
  PVkQueryPoolCreateFlags  =  ^VkQueryPoolCreateFlags;
  PPVkQueryPoolCreateFlags = ^PVkQueryPoolCreateFlags;
  VkRenderPassCreateFlags   = VkFlags;
  PVkRenderPassCreateFlags  =  ^VkRenderPassCreateFlags;
  PPVkRenderPassCreateFlags = ^PVkRenderPassCreateFlags;
  VkSamplerCreateFlags   = VkFlags;
  PVkSamplerCreateFlags  =  ^VkSamplerCreateFlags;
  PPVkSamplerCreateFlags = ^PVkSamplerCreateFlags;
  VkPipelineLayoutCreateFlags   = VkFlags;
  PVkPipelineLayoutCreateFlags  =  ^VkPipelineLayoutCreateFlags;
  PPVkPipelineLayoutCreateFlags = ^PVkPipelineLayoutCreateFlags;
  VkPipelineCacheCreateFlags   = VkFlags;
  PVkPipelineCacheCreateFlags  =  ^VkPipelineCacheCreateFlags;
  PPVkPipelineCacheCreateFlags = ^PVkPipelineCacheCreateFlags;
  VkPipelineDepthStencilStateCreateFlags   = VkFlags;
  PVkPipelineDepthStencilStateCreateFlags  =  ^VkPipelineDepthStencilStateCreateFlags;
  PPVkPipelineDepthStencilStateCreateFlags = ^PVkPipelineDepthStencilStateCreateFlags;
  VkPipelineDynamicStateCreateFlags   = VkFlags;
  PVkPipelineDynamicStateCreateFlags  =  ^VkPipelineDynamicStateCreateFlags;
  PPVkPipelineDynamicStateCreateFlags = ^PVkPipelineDynamicStateCreateFlags;
  VkPipelineColorBlendStateCreateFlags   = VkFlags;
  PVkPipelineColorBlendStateCreateFlags  =  ^VkPipelineColorBlendStateCreateFlags;
  PPVkPipelineColorBlendStateCreateFlags = ^PVkPipelineColorBlendStateCreateFlags;
  VkPipelineMultisampleStateCreateFlags   = VkFlags;
  PVkPipelineMultisampleStateCreateFlags  =  ^VkPipelineMultisampleStateCreateFlags;
  PPVkPipelineMultisampleStateCreateFlags = ^PVkPipelineMultisampleStateCreateFlags;
  VkPipelineRasterizationStateCreateFlags   = VkFlags;
  PVkPipelineRasterizationStateCreateFlags  =  ^VkPipelineRasterizationStateCreateFlags;
  PPVkPipelineRasterizationStateCreateFlags = ^PVkPipelineRasterizationStateCreateFlags;
  VkPipelineViewportStateCreateFlags   = VkFlags;
  PVkPipelineViewportStateCreateFlags  =  ^VkPipelineViewportStateCreateFlags;
  PPVkPipelineViewportStateCreateFlags = ^PVkPipelineViewportStateCreateFlags;
  VkPipelineTessellationStateCreateFlags   = VkFlags;
  PVkPipelineTessellationStateCreateFlags  =  ^VkPipelineTessellationStateCreateFlags;
  PPVkPipelineTessellationStateCreateFlags = ^PVkPipelineTessellationStateCreateFlags;
  VkPipelineInputAssemblyStateCreateFlags   = VkFlags;
  PVkPipelineInputAssemblyStateCreateFlags  =  ^VkPipelineInputAssemblyStateCreateFlags;
  PPVkPipelineInputAssemblyStateCreateFlags = ^PVkPipelineInputAssemblyStateCreateFlags;
  VkPipelineVertexInputStateCreateFlags   = VkFlags;
  PVkPipelineVertexInputStateCreateFlags  =  ^VkPipelineVertexInputStateCreateFlags;
  PPVkPipelineVertexInputStateCreateFlags = ^PVkPipelineVertexInputStateCreateFlags;
  VkPipelineShaderStageCreateFlags   = VkFlags;
  PVkPipelineShaderStageCreateFlags  =  ^VkPipelineShaderStageCreateFlags;
  PPVkPipelineShaderStageCreateFlags = ^PVkPipelineShaderStageCreateFlags;
  VkDescriptorSetLayoutCreateFlags   = VkFlags;
  PVkDescriptorSetLayoutCreateFlags  =  ^VkDescriptorSetLayoutCreateFlags;
  PPVkDescriptorSetLayoutCreateFlags = ^PVkDescriptorSetLayoutCreateFlags;
  VkBufferViewCreateFlags   = VkFlags;
  PVkBufferViewCreateFlags  =  ^VkBufferViewCreateFlags;
  PPVkBufferViewCreateFlags = ^PVkBufferViewCreateFlags;
  VkInstanceCreateFlags   = VkFlags;
  PVkInstanceCreateFlags  =  ^VkInstanceCreateFlags;
  PPVkInstanceCreateFlags = ^PVkInstanceCreateFlags;
  VkDeviceCreateFlags   = VkFlags;
  PVkDeviceCreateFlags  =  ^VkDeviceCreateFlags;
  PPVkDeviceCreateFlags = ^PVkDeviceCreateFlags;
  VkDeviceQueueCreateFlags   = VkFlags;
  PVkDeviceQueueCreateFlags  =  ^VkDeviceQueueCreateFlags;
  PPVkDeviceQueueCreateFlags = ^PVkDeviceQueueCreateFlags;
  VkQueueFlags   = VkFlags;
  PVkQueueFlags  =  ^VkQueueFlags;
  PPVkQueueFlags = ^PVkQueueFlags;
  VkMemoryPropertyFlags   = VkFlags;
  PVkMemoryPropertyFlags  =  ^VkMemoryPropertyFlags;
  PPVkMemoryPropertyFlags = ^PVkMemoryPropertyFlags;
  VkMemoryHeapFlags   = VkFlags;
  PVkMemoryHeapFlags  =  ^VkMemoryHeapFlags;
  PPVkMemoryHeapFlags = ^PVkMemoryHeapFlags;
  VkAccessFlags   = VkFlags;
  PVkAccessFlags  =  ^VkAccessFlags;
  PPVkAccessFlags = ^PVkAccessFlags;
  VkBufferUsageFlags   = VkFlags;
  PVkBufferUsageFlags  =  ^VkBufferUsageFlags;
  PPVkBufferUsageFlags = ^PVkBufferUsageFlags;
  VkBufferCreateFlags   = VkFlags;
  PVkBufferCreateFlags  =  ^VkBufferCreateFlags;
  PPVkBufferCreateFlags = ^PVkBufferCreateFlags;
  VkShaderStageFlags   = VkFlags;
  PVkShaderStageFlags  =  ^VkShaderStageFlags;
  PPVkShaderStageFlags = ^PVkShaderStageFlags;
  VkImageUsageFlags   = VkFlags;
  PVkImageUsageFlags  =  ^VkImageUsageFlags;
  PPVkImageUsageFlags = ^PVkImageUsageFlags;
  VkImageCreateFlags   = VkFlags;
  PVkImageCreateFlags  =  ^VkImageCreateFlags;
  PPVkImageCreateFlags = ^PVkImageCreateFlags;
  VkImageViewCreateFlags   = VkFlags;
  PVkImageViewCreateFlags  =  ^VkImageViewCreateFlags;
  PPVkImageViewCreateFlags = ^PVkImageViewCreateFlags;
  VkPipelineCreateFlags   = VkFlags;
  PVkPipelineCreateFlags  =  ^VkPipelineCreateFlags;
  PPVkPipelineCreateFlags = ^PVkPipelineCreateFlags;
  VkColorComponentFlags   = VkFlags;
  PVkColorComponentFlags  =  ^VkColorComponentFlags;
  PPVkColorComponentFlags = ^PVkColorComponentFlags;
  VkFenceCreateFlags   = VkFlags;
  PVkFenceCreateFlags  =  ^VkFenceCreateFlags;
  PPVkFenceCreateFlags = ^PVkFenceCreateFlags;
  VkSemaphoreCreateFlags   = VkFlags;
  PVkSemaphoreCreateFlags  =  ^VkSemaphoreCreateFlags;
  PPVkSemaphoreCreateFlags = ^PVkSemaphoreCreateFlags;
  VkFormatFeatureFlags   = VkFlags;
  PVkFormatFeatureFlags  =  ^VkFormatFeatureFlags;
  PPVkFormatFeatureFlags = ^PVkFormatFeatureFlags;
  VkQueryControlFlags   = VkFlags;
  PVkQueryControlFlags  =  ^VkQueryControlFlags;
  PPVkQueryControlFlags = ^PVkQueryControlFlags;
  VkQueryResultFlags   = VkFlags;
  PVkQueryResultFlags  =  ^VkQueryResultFlags;
  PPVkQueryResultFlags = ^PVkQueryResultFlags;
  VkShaderModuleCreateFlags   = VkFlags;
  PVkShaderModuleCreateFlags  =  ^VkShaderModuleCreateFlags;
  PPVkShaderModuleCreateFlags = ^PVkShaderModuleCreateFlags;
  VkEventCreateFlags   = VkFlags;
  PVkEventCreateFlags  =  ^VkEventCreateFlags;
  PPVkEventCreateFlags = ^PVkEventCreateFlags;
  VkCommandPoolCreateFlags   = VkFlags;
  PVkCommandPoolCreateFlags  =  ^VkCommandPoolCreateFlags;
  PPVkCommandPoolCreateFlags = ^PVkCommandPoolCreateFlags;
  VkCommandPoolResetFlags   = VkFlags;
  PVkCommandPoolResetFlags  =  ^VkCommandPoolResetFlags;
  PPVkCommandPoolResetFlags = ^PVkCommandPoolResetFlags;
  VkCommandBufferResetFlags   = VkFlags;
  PVkCommandBufferResetFlags  =  ^VkCommandBufferResetFlags;
  PPVkCommandBufferResetFlags = ^PVkCommandBufferResetFlags;
  VkCommandBufferUsageFlags   = VkFlags;
  PVkCommandBufferUsageFlags  =  ^VkCommandBufferUsageFlags;
  PPVkCommandBufferUsageFlags = ^PVkCommandBufferUsageFlags;
  VkQueryPipelineStatisticFlags   = VkFlags;
  PVkQueryPipelineStatisticFlags  =  ^VkQueryPipelineStatisticFlags;
  PPVkQueryPipelineStatisticFlags = ^PVkQueryPipelineStatisticFlags;
  VkMemoryMapFlags   = VkFlags;
  PVkMemoryMapFlags  =  ^VkMemoryMapFlags;
  PPVkMemoryMapFlags = ^PVkMemoryMapFlags;
  VkImageAspectFlags   = VkFlags;
  PVkImageAspectFlags  =  ^VkImageAspectFlags;
  PPVkImageAspectFlags = ^PVkImageAspectFlags;
  VkSparseMemoryBindFlags   = VkFlags;
  PVkSparseMemoryBindFlags  =  ^VkSparseMemoryBindFlags;
  PPVkSparseMemoryBindFlags = ^PVkSparseMemoryBindFlags;
  VkSparseImageFormatFlags   = VkFlags;
  PVkSparseImageFormatFlags  =  ^VkSparseImageFormatFlags;
  PPVkSparseImageFormatFlags = ^PVkSparseImageFormatFlags;
  VkSubpassDescriptionFlags   = VkFlags;
  PVkSubpassDescriptionFlags  =  ^VkSubpassDescriptionFlags;
  PPVkSubpassDescriptionFlags = ^PVkSubpassDescriptionFlags;
  VkPipelineStageFlags   = VkFlags;
  PVkPipelineStageFlags  =  ^VkPipelineStageFlags;
  PPVkPipelineStageFlags = ^PVkPipelineStageFlags;
  VkSampleCountFlags   = VkFlags;
  PVkSampleCountFlags  =  ^VkSampleCountFlags;
  PPVkSampleCountFlags = ^PVkSampleCountFlags;
  VkAttachmentDescriptionFlags   = VkFlags;
  PVkAttachmentDescriptionFlags  =  ^VkAttachmentDescriptionFlags;
  PPVkAttachmentDescriptionFlags = ^PVkAttachmentDescriptionFlags;
  VkStencilFaceFlags   = VkFlags;
  PVkStencilFaceFlags  =  ^VkStencilFaceFlags;
  PPVkStencilFaceFlags = ^PVkStencilFaceFlags;
  VkCullModeFlags   = VkFlags;
  PVkCullModeFlags  =  ^VkCullModeFlags;
  PPVkCullModeFlags = ^PVkCullModeFlags;
  VkDescriptorPoolCreateFlags   = VkFlags;
  PVkDescriptorPoolCreateFlags  =  ^VkDescriptorPoolCreateFlags;
  PPVkDescriptorPoolCreateFlags = ^PVkDescriptorPoolCreateFlags;
  VkDescriptorPoolResetFlags   = VkFlags;
  PVkDescriptorPoolResetFlags  =  ^VkDescriptorPoolResetFlags;
  PPVkDescriptorPoolResetFlags = ^PVkDescriptorPoolResetFlags;
  VkDependencyFlags   = VkFlags;
  PVkDependencyFlags  =  ^VkDependencyFlags;
  PPVkDependencyFlags = ^PVkDependencyFlags;
  VkSubgroupFeatureFlags   = VkFlags;
  PVkSubgroupFeatureFlags  =  ^VkSubgroupFeatureFlags;
  PPVkSubgroupFeatureFlags = ^PVkSubgroupFeatureFlags;
  VkIndirectCommandsLayoutUsageFlagsNV   = VkFlags;
  PVkIndirectCommandsLayoutUsageFlagsNV  =  ^VkIndirectCommandsLayoutUsageFlagsNV;
  PPVkIndirectCommandsLayoutUsageFlagsNV = ^PVkIndirectCommandsLayoutUsageFlagsNV;
  VkIndirectStateFlagsNV   = VkFlags;
  PVkIndirectStateFlagsNV  =  ^VkIndirectStateFlagsNV;
  PPVkIndirectStateFlagsNV = ^PVkIndirectStateFlagsNV;
  VkGeometryFlagsKHR   = VkFlags;
  PVkGeometryFlagsKHR  =  ^VkGeometryFlagsKHR;
  PPVkGeometryFlagsKHR = ^PVkGeometryFlagsKHR;
  VkGeometryFlagsNV   = Pointer;
  PVkGeometryFlagsNV  =  ^VkGeometryFlagsNV;
  PPVkGeometryFlagsNV = ^PVkGeometryFlagsNV;
  VkGeometryInstanceFlagsKHR   = VkFlags;
  PVkGeometryInstanceFlagsKHR  =  ^VkGeometryInstanceFlagsKHR;
  PPVkGeometryInstanceFlagsKHR = ^PVkGeometryInstanceFlagsKHR;
  VkGeometryInstanceFlagsNV   = Pointer;
  PVkGeometryInstanceFlagsNV  =  ^VkGeometryInstanceFlagsNV;
  PPVkGeometryInstanceFlagsNV = ^PVkGeometryInstanceFlagsNV;
  VkBuildAccelerationStructureFlagsKHR   = VkFlags;
  PVkBuildAccelerationStructureFlagsKHR  =  ^VkBuildAccelerationStructureFlagsKHR;
  PPVkBuildAccelerationStructureFlagsKHR = ^PVkBuildAccelerationStructureFlagsKHR;
  VkBuildAccelerationStructureFlagsNV   = Pointer;
  PVkBuildAccelerationStructureFlagsNV  =  ^VkBuildAccelerationStructureFlagsNV;
  PPVkBuildAccelerationStructureFlagsNV = ^PVkBuildAccelerationStructureFlagsNV;
  VkPrivateDataSlotCreateFlagsEXT   = VkFlags;
  PVkPrivateDataSlotCreateFlagsEXT  =  ^VkPrivateDataSlotCreateFlagsEXT;
  PPVkPrivateDataSlotCreateFlagsEXT = ^PVkPrivateDataSlotCreateFlagsEXT;
  VkAccelerationStructureCreateFlagsKHR   = VkFlags;
  PVkAccelerationStructureCreateFlagsKHR  =  ^VkAccelerationStructureCreateFlagsKHR;
  PPVkAccelerationStructureCreateFlagsKHR = ^PVkAccelerationStructureCreateFlagsKHR;
  VkDescriptorUpdateTemplateCreateFlags   = VkFlags;
  PVkDescriptorUpdateTemplateCreateFlags  =  ^VkDescriptorUpdateTemplateCreateFlags;
  PPVkDescriptorUpdateTemplateCreateFlags = ^PVkDescriptorUpdateTemplateCreateFlags;
  VkDescriptorUpdateTemplateCreateFlagsKHR   = Pointer;
  PVkDescriptorUpdateTemplateCreateFlagsKHR  =  ^VkDescriptorUpdateTemplateCreateFlagsKHR;
  PPVkDescriptorUpdateTemplateCreateFlagsKHR = ^PVkDescriptorUpdateTemplateCreateFlagsKHR;
  VkPipelineCreationFeedbackFlagsEXT   = VkFlags;
  PVkPipelineCreationFeedbackFlagsEXT  =  ^VkPipelineCreationFeedbackFlagsEXT;
  PPVkPipelineCreationFeedbackFlagsEXT = ^PVkPipelineCreationFeedbackFlagsEXT;
  VkPerformanceCounterDescriptionFlagsKHR   = VkFlags;
  PVkPerformanceCounterDescriptionFlagsKHR  =  ^VkPerformanceCounterDescriptionFlagsKHR;
  PPVkPerformanceCounterDescriptionFlagsKHR = ^PVkPerformanceCounterDescriptionFlagsKHR;
  VkAcquireProfilingLockFlagsKHR   = VkFlags;
  PVkAcquireProfilingLockFlagsKHR  =  ^VkAcquireProfilingLockFlagsKHR;
  PPVkAcquireProfilingLockFlagsKHR = ^PVkAcquireProfilingLockFlagsKHR;
  VkSemaphoreWaitFlags   = VkFlags;
  PVkSemaphoreWaitFlags  =  ^VkSemaphoreWaitFlags;
  PPVkSemaphoreWaitFlags = ^PVkSemaphoreWaitFlags;
  VkSemaphoreWaitFlagsKHR   = Pointer;
  PVkSemaphoreWaitFlagsKHR  =  ^VkSemaphoreWaitFlagsKHR;
  PPVkSemaphoreWaitFlagsKHR = ^PVkSemaphoreWaitFlagsKHR;
  VkPipelineCompilerControlFlagsAMD   = VkFlags;
  PVkPipelineCompilerControlFlagsAMD  =  ^VkPipelineCompilerControlFlagsAMD;
  PPVkPipelineCompilerControlFlagsAMD = ^PVkPipelineCompilerControlFlagsAMD;
  VkShaderCorePropertiesFlagsAMD   = VkFlags;
  PVkShaderCorePropertiesFlagsAMD  =  ^VkShaderCorePropertiesFlagsAMD;
  PPVkShaderCorePropertiesFlagsAMD = ^PVkShaderCorePropertiesFlagsAMD;
  VkDeviceDiagnosticsConfigFlagsNV   = VkFlags;
  PVkDeviceDiagnosticsConfigFlagsNV  =  ^VkDeviceDiagnosticsConfigFlagsNV;
  PPVkDeviceDiagnosticsConfigFlagsNV = ^PVkDeviceDiagnosticsConfigFlagsNV;
  VkAccessFlags2KHR   = VkFlags64;
  PVkAccessFlags2KHR  =  ^VkAccessFlags2KHR;
  PPVkAccessFlags2KHR = ^PVkAccessFlags2KHR;
  VkPipelineStageFlags2KHR   = VkFlags64;
  PVkPipelineStageFlags2KHR  =  ^VkPipelineStageFlags2KHR;
  PPVkPipelineStageFlags2KHR = ^PVkPipelineStageFlags2KHR;
  VkAccelerationStructureMotionInfoFlagsNV   = VkFlags;
  PVkAccelerationStructureMotionInfoFlagsNV  =  ^VkAccelerationStructureMotionInfoFlagsNV;
  PPVkAccelerationStructureMotionInfoFlagsNV = ^PVkAccelerationStructureMotionInfoFlagsNV;
  VkAccelerationStructureMotionInstanceFlagsNV   = VkFlags;
  PVkAccelerationStructureMotionInstanceFlagsNV  =  ^VkAccelerationStructureMotionInstanceFlagsNV;
  PPVkAccelerationStructureMotionInstanceFlagsNV = ^PVkAccelerationStructureMotionInstanceFlagsNV;
  VkCompositeAlphaFlagsKHR   = VkFlags;
  PVkCompositeAlphaFlagsKHR  =  ^VkCompositeAlphaFlagsKHR;
  PPVkCompositeAlphaFlagsKHR = ^PVkCompositeAlphaFlagsKHR;
  VkDisplayPlaneAlphaFlagsKHR   = VkFlags;
  PVkDisplayPlaneAlphaFlagsKHR  =  ^VkDisplayPlaneAlphaFlagsKHR;
  PPVkDisplayPlaneAlphaFlagsKHR = ^PVkDisplayPlaneAlphaFlagsKHR;
  VkSurfaceTransformFlagsKHR   = VkFlags;
  PVkSurfaceTransformFlagsKHR  =  ^VkSurfaceTransformFlagsKHR;
  PPVkSurfaceTransformFlagsKHR = ^PVkSurfaceTransformFlagsKHR;
  VkSwapchainCreateFlagsKHR   = VkFlags;
  PVkSwapchainCreateFlagsKHR  =  ^VkSwapchainCreateFlagsKHR;
  PPVkSwapchainCreateFlagsKHR = ^PVkSwapchainCreateFlagsKHR;
  VkDisplayModeCreateFlagsKHR   = VkFlags;
  PVkDisplayModeCreateFlagsKHR  =  ^VkDisplayModeCreateFlagsKHR;
  PPVkDisplayModeCreateFlagsKHR = ^PVkDisplayModeCreateFlagsKHR;
  VkDisplaySurfaceCreateFlagsKHR   = VkFlags;
  PVkDisplaySurfaceCreateFlagsKHR  =  ^VkDisplaySurfaceCreateFlagsKHR;
  PPVkDisplaySurfaceCreateFlagsKHR = ^PVkDisplaySurfaceCreateFlagsKHR;
  VkAndroidSurfaceCreateFlagsKHR   = VkFlags;
  PVkAndroidSurfaceCreateFlagsKHR  =  ^VkAndroidSurfaceCreateFlagsKHR;
  PPVkAndroidSurfaceCreateFlagsKHR = ^PVkAndroidSurfaceCreateFlagsKHR;
  VkViSurfaceCreateFlagsNN   = VkFlags;
  PVkViSurfaceCreateFlagsNN  =  ^VkViSurfaceCreateFlagsNN;
  PPVkViSurfaceCreateFlagsNN = ^PVkViSurfaceCreateFlagsNN;
  VkWaylandSurfaceCreateFlagsKHR   = VkFlags;
  PVkWaylandSurfaceCreateFlagsKHR  =  ^VkWaylandSurfaceCreateFlagsKHR;
  PPVkWaylandSurfaceCreateFlagsKHR = ^PVkWaylandSurfaceCreateFlagsKHR;
  VkWin32SurfaceCreateFlagsKHR   = VkFlags;
  PVkWin32SurfaceCreateFlagsKHR  =  ^VkWin32SurfaceCreateFlagsKHR;
  PPVkWin32SurfaceCreateFlagsKHR = ^PVkWin32SurfaceCreateFlagsKHR;
  VkXlibSurfaceCreateFlagsKHR   = VkFlags;
  PVkXlibSurfaceCreateFlagsKHR  =  ^VkXlibSurfaceCreateFlagsKHR;
  PPVkXlibSurfaceCreateFlagsKHR = ^PVkXlibSurfaceCreateFlagsKHR;
  VkXcbSurfaceCreateFlagsKHR   = VkFlags;
  PVkXcbSurfaceCreateFlagsKHR  =  ^VkXcbSurfaceCreateFlagsKHR;
  PPVkXcbSurfaceCreateFlagsKHR = ^PVkXcbSurfaceCreateFlagsKHR;
  VkDirectFBSurfaceCreateFlagsEXT   = VkFlags;
  PVkDirectFBSurfaceCreateFlagsEXT  =  ^VkDirectFBSurfaceCreateFlagsEXT;
  PPVkDirectFBSurfaceCreateFlagsEXT = ^PVkDirectFBSurfaceCreateFlagsEXT;
  VkIOSSurfaceCreateFlagsMVK   = VkFlags;
  PVkIOSSurfaceCreateFlagsMVK  =  ^VkIOSSurfaceCreateFlagsMVK;
  PPVkIOSSurfaceCreateFlagsMVK = ^PVkIOSSurfaceCreateFlagsMVK;
  VkMacOSSurfaceCreateFlagsMVK   = VkFlags;
  PVkMacOSSurfaceCreateFlagsMVK  =  ^VkMacOSSurfaceCreateFlagsMVK;
  PPVkMacOSSurfaceCreateFlagsMVK = ^PVkMacOSSurfaceCreateFlagsMVK;
  VkMetalSurfaceCreateFlagsEXT   = VkFlags;
  PVkMetalSurfaceCreateFlagsEXT  =  ^VkMetalSurfaceCreateFlagsEXT;
  PPVkMetalSurfaceCreateFlagsEXT = ^PVkMetalSurfaceCreateFlagsEXT;
  VkImagePipeSurfaceCreateFlagsFUCHSIA   = VkFlags;
  PVkImagePipeSurfaceCreateFlagsFUCHSIA  =  ^VkImagePipeSurfaceCreateFlagsFUCHSIA;
  PPVkImagePipeSurfaceCreateFlagsFUCHSIA = ^PVkImagePipeSurfaceCreateFlagsFUCHSIA;
  VkStreamDescriptorSurfaceCreateFlagsGGP   = VkFlags;
  PVkStreamDescriptorSurfaceCreateFlagsGGP  =  ^VkStreamDescriptorSurfaceCreateFlagsGGP;
  PPVkStreamDescriptorSurfaceCreateFlagsGGP = ^PVkStreamDescriptorSurfaceCreateFlagsGGP;
  VkHeadlessSurfaceCreateFlagsEXT   = VkFlags;
  PVkHeadlessSurfaceCreateFlagsEXT  =  ^VkHeadlessSurfaceCreateFlagsEXT;
  PPVkHeadlessSurfaceCreateFlagsEXT = ^PVkHeadlessSurfaceCreateFlagsEXT;
  VkScreenSurfaceCreateFlagsQNX   = VkFlags;
  PVkScreenSurfaceCreateFlagsQNX  =  ^VkScreenSurfaceCreateFlagsQNX;
  PPVkScreenSurfaceCreateFlagsQNX = ^PVkScreenSurfaceCreateFlagsQNX;
  VkPeerMemoryFeatureFlags   = VkFlags;
  PVkPeerMemoryFeatureFlags  =  ^VkPeerMemoryFeatureFlags;
  PPVkPeerMemoryFeatureFlags = ^PVkPeerMemoryFeatureFlags;
  VkPeerMemoryFeatureFlagsKHR   = Pointer;
  PVkPeerMemoryFeatureFlagsKHR  =  ^VkPeerMemoryFeatureFlagsKHR;
  PPVkPeerMemoryFeatureFlagsKHR = ^PVkPeerMemoryFeatureFlagsKHR;
  VkMemoryAllocateFlags   = VkFlags;
  PVkMemoryAllocateFlags  =  ^VkMemoryAllocateFlags;
  PPVkMemoryAllocateFlags = ^PVkMemoryAllocateFlags;
  VkMemoryAllocateFlagsKHR   = Pointer;
  PVkMemoryAllocateFlagsKHR  =  ^VkMemoryAllocateFlagsKHR;
  PPVkMemoryAllocateFlagsKHR = ^PVkMemoryAllocateFlagsKHR;
  VkDeviceGroupPresentModeFlagsKHR   = VkFlags;
  PVkDeviceGroupPresentModeFlagsKHR  =  ^VkDeviceGroupPresentModeFlagsKHR;
  PPVkDeviceGroupPresentModeFlagsKHR = ^PVkDeviceGroupPresentModeFlagsKHR;
  VkDebugReportFlagsEXT   = VkFlags;
  PVkDebugReportFlagsEXT  =  ^VkDebugReportFlagsEXT;
  PPVkDebugReportFlagsEXT = ^PVkDebugReportFlagsEXT;
  VkCommandPoolTrimFlags   = VkFlags;
  PVkCommandPoolTrimFlags  =  ^VkCommandPoolTrimFlags;
  PPVkCommandPoolTrimFlags = ^PVkCommandPoolTrimFlags;
  VkCommandPoolTrimFlagsKHR   = Pointer;
  PVkCommandPoolTrimFlagsKHR  =  ^VkCommandPoolTrimFlagsKHR;
  PPVkCommandPoolTrimFlagsKHR = ^PVkCommandPoolTrimFlagsKHR;
  VkExternalMemoryHandleTypeFlagsNV   = VkFlags;
  PVkExternalMemoryHandleTypeFlagsNV  =  ^VkExternalMemoryHandleTypeFlagsNV;
  PPVkExternalMemoryHandleTypeFlagsNV = ^PVkExternalMemoryHandleTypeFlagsNV;
  VkExternalMemoryFeatureFlagsNV   = VkFlags;
  PVkExternalMemoryFeatureFlagsNV  =  ^VkExternalMemoryFeatureFlagsNV;
  PPVkExternalMemoryFeatureFlagsNV = ^PVkExternalMemoryFeatureFlagsNV;
  VkExternalMemoryHandleTypeFlags   = VkFlags;
  PVkExternalMemoryHandleTypeFlags  =  ^VkExternalMemoryHandleTypeFlags;
  PPVkExternalMemoryHandleTypeFlags = ^PVkExternalMemoryHandleTypeFlags;
  VkExternalMemoryHandleTypeFlagsKHR   = Pointer;
  PVkExternalMemoryHandleTypeFlagsKHR  =  ^VkExternalMemoryHandleTypeFlagsKHR;
  PPVkExternalMemoryHandleTypeFlagsKHR = ^PVkExternalMemoryHandleTypeFlagsKHR;
  VkExternalMemoryFeatureFlags   = VkFlags;
  PVkExternalMemoryFeatureFlags  =  ^VkExternalMemoryFeatureFlags;
  PPVkExternalMemoryFeatureFlags = ^PVkExternalMemoryFeatureFlags;
  VkExternalMemoryFeatureFlagsKHR   = Pointer;
  PVkExternalMemoryFeatureFlagsKHR  =  ^VkExternalMemoryFeatureFlagsKHR;
  PPVkExternalMemoryFeatureFlagsKHR = ^PVkExternalMemoryFeatureFlagsKHR;
  VkExternalSemaphoreHandleTypeFlags   = VkFlags;
  PVkExternalSemaphoreHandleTypeFlags  =  ^VkExternalSemaphoreHandleTypeFlags;
  PPVkExternalSemaphoreHandleTypeFlags = ^PVkExternalSemaphoreHandleTypeFlags;
  VkExternalSemaphoreHandleTypeFlagsKHR   = Pointer;
  PVkExternalSemaphoreHandleTypeFlagsKHR  =  ^VkExternalSemaphoreHandleTypeFlagsKHR;
  PPVkExternalSemaphoreHandleTypeFlagsKHR = ^PVkExternalSemaphoreHandleTypeFlagsKHR;
  VkExternalSemaphoreFeatureFlags   = VkFlags;
  PVkExternalSemaphoreFeatureFlags  =  ^VkExternalSemaphoreFeatureFlags;
  PPVkExternalSemaphoreFeatureFlags = ^PVkExternalSemaphoreFeatureFlags;
  VkExternalSemaphoreFeatureFlagsKHR   = Pointer;
  PVkExternalSemaphoreFeatureFlagsKHR  =  ^VkExternalSemaphoreFeatureFlagsKHR;
  PPVkExternalSemaphoreFeatureFlagsKHR = ^PVkExternalSemaphoreFeatureFlagsKHR;
  VkSemaphoreImportFlags   = VkFlags;
  PVkSemaphoreImportFlags  =  ^VkSemaphoreImportFlags;
  PPVkSemaphoreImportFlags = ^PVkSemaphoreImportFlags;
  VkSemaphoreImportFlagsKHR   = Pointer;
  PVkSemaphoreImportFlagsKHR  =  ^VkSemaphoreImportFlagsKHR;
  PPVkSemaphoreImportFlagsKHR = ^PVkSemaphoreImportFlagsKHR;
  VkExternalFenceHandleTypeFlags   = VkFlags;
  PVkExternalFenceHandleTypeFlags  =  ^VkExternalFenceHandleTypeFlags;
  PPVkExternalFenceHandleTypeFlags = ^PVkExternalFenceHandleTypeFlags;
  VkExternalFenceHandleTypeFlagsKHR   = Pointer;
  PVkExternalFenceHandleTypeFlagsKHR  =  ^VkExternalFenceHandleTypeFlagsKHR;
  PPVkExternalFenceHandleTypeFlagsKHR = ^PVkExternalFenceHandleTypeFlagsKHR;
  VkExternalFenceFeatureFlags   = VkFlags;
  PVkExternalFenceFeatureFlags  =  ^VkExternalFenceFeatureFlags;
  PPVkExternalFenceFeatureFlags = ^PVkExternalFenceFeatureFlags;
  VkExternalFenceFeatureFlagsKHR   = Pointer;
  PVkExternalFenceFeatureFlagsKHR  =  ^VkExternalFenceFeatureFlagsKHR;
  PPVkExternalFenceFeatureFlagsKHR = ^PVkExternalFenceFeatureFlagsKHR;
  VkFenceImportFlags   = VkFlags;
  PVkFenceImportFlags  =  ^VkFenceImportFlags;
  PPVkFenceImportFlags = ^PVkFenceImportFlags;
  VkFenceImportFlagsKHR   = Pointer;
  PVkFenceImportFlagsKHR  =  ^VkFenceImportFlagsKHR;
  PPVkFenceImportFlagsKHR = ^PVkFenceImportFlagsKHR;
  VkSurfaceCounterFlagsEXT   = VkFlags;
  PVkSurfaceCounterFlagsEXT  =  ^VkSurfaceCounterFlagsEXT;
  PPVkSurfaceCounterFlagsEXT = ^PVkSurfaceCounterFlagsEXT;
  VkPipelineViewportSwizzleStateCreateFlagsNV   = VkFlags;
  PVkPipelineViewportSwizzleStateCreateFlagsNV  =  ^VkPipelineViewportSwizzleStateCreateFlagsNV;
  PPVkPipelineViewportSwizzleStateCreateFlagsNV = ^PVkPipelineViewportSwizzleStateCreateFlagsNV;
  VkPipelineDiscardRectangleStateCreateFlagsEXT   = VkFlags;
  PVkPipelineDiscardRectangleStateCreateFlagsEXT  =  ^VkPipelineDiscardRectangleStateCreateFlagsEXT;
  PPVkPipelineDiscardRectangleStateCreateFlagsEXT = ^PVkPipelineDiscardRectangleStateCreateFlagsEXT;
  VkPipelineCoverageToColorStateCreateFlagsNV   = VkFlags;
  PVkPipelineCoverageToColorStateCreateFlagsNV  =  ^VkPipelineCoverageToColorStateCreateFlagsNV;
  PPVkPipelineCoverageToColorStateCreateFlagsNV = ^PVkPipelineCoverageToColorStateCreateFlagsNV;
  VkPipelineCoverageModulationStateCreateFlagsNV   = VkFlags;
  PVkPipelineCoverageModulationStateCreateFlagsNV  =  ^VkPipelineCoverageModulationStateCreateFlagsNV;
  PPVkPipelineCoverageModulationStateCreateFlagsNV = ^PVkPipelineCoverageModulationStateCreateFlagsNV;
  VkPipelineCoverageReductionStateCreateFlagsNV   = VkFlags;
  PVkPipelineCoverageReductionStateCreateFlagsNV  =  ^VkPipelineCoverageReductionStateCreateFlagsNV;
  PPVkPipelineCoverageReductionStateCreateFlagsNV = ^PVkPipelineCoverageReductionStateCreateFlagsNV;
  VkValidationCacheCreateFlagsEXT   = VkFlags;
  PVkValidationCacheCreateFlagsEXT  =  ^VkValidationCacheCreateFlagsEXT;
  PPVkValidationCacheCreateFlagsEXT = ^PVkValidationCacheCreateFlagsEXT;
  VkDebugUtilsMessageSeverityFlagsEXT   = VkFlags;
  PVkDebugUtilsMessageSeverityFlagsEXT  =  ^VkDebugUtilsMessageSeverityFlagsEXT;
  PPVkDebugUtilsMessageSeverityFlagsEXT = ^PVkDebugUtilsMessageSeverityFlagsEXT;
  VkDebugUtilsMessageTypeFlagsEXT   = VkFlags;
  PVkDebugUtilsMessageTypeFlagsEXT  =  ^VkDebugUtilsMessageTypeFlagsEXT;
  PPVkDebugUtilsMessageTypeFlagsEXT = ^PVkDebugUtilsMessageTypeFlagsEXT;
  VkDebugUtilsMessengerCreateFlagsEXT   = VkFlags;
  PVkDebugUtilsMessengerCreateFlagsEXT  =  ^VkDebugUtilsMessengerCreateFlagsEXT;
  PPVkDebugUtilsMessengerCreateFlagsEXT = ^PVkDebugUtilsMessengerCreateFlagsEXT;
  VkDebugUtilsMessengerCallbackDataFlagsEXT   = VkFlags;
  PVkDebugUtilsMessengerCallbackDataFlagsEXT  =  ^VkDebugUtilsMessengerCallbackDataFlagsEXT;
  PPVkDebugUtilsMessengerCallbackDataFlagsEXT = ^PVkDebugUtilsMessengerCallbackDataFlagsEXT;
  VkDeviceMemoryReportFlagsEXT   = VkFlags;
  PVkDeviceMemoryReportFlagsEXT  =  ^VkDeviceMemoryReportFlagsEXT;
  PPVkDeviceMemoryReportFlagsEXT = ^PVkDeviceMemoryReportFlagsEXT;
  VkPipelineRasterizationConservativeStateCreateFlagsEXT   = VkFlags;
  PVkPipelineRasterizationConservativeStateCreateFlagsEXT  =  ^VkPipelineRasterizationConservativeStateCreateFlagsEXT;
  PPVkPipelineRasterizationConservativeStateCreateFlagsEXT = ^PVkPipelineRasterizationConservativeStateCreateFlagsEXT;
  VkDescriptorBindingFlags   = VkFlags;
  PVkDescriptorBindingFlags  =  ^VkDescriptorBindingFlags;
  PPVkDescriptorBindingFlags = ^PVkDescriptorBindingFlags;
  VkDescriptorBindingFlagsEXT   = Pointer;
  PVkDescriptorBindingFlagsEXT  =  ^VkDescriptorBindingFlagsEXT;
  PPVkDescriptorBindingFlagsEXT = ^PVkDescriptorBindingFlagsEXT;
  VkConditionalRenderingFlagsEXT   = VkFlags;
  PVkConditionalRenderingFlagsEXT  =  ^VkConditionalRenderingFlagsEXT;
  PPVkConditionalRenderingFlagsEXT = ^PVkConditionalRenderingFlagsEXT;
  VkResolveModeFlags   = VkFlags;
  PVkResolveModeFlags  =  ^VkResolveModeFlags;
  PPVkResolveModeFlags = ^PVkResolveModeFlags;
  VkResolveModeFlagsKHR   = Pointer;
  PVkResolveModeFlagsKHR  =  ^VkResolveModeFlagsKHR;
  PPVkResolveModeFlagsKHR = ^PVkResolveModeFlagsKHR;
  VkPipelineRasterizationStateStreamCreateFlagsEXT   = VkFlags;
  PVkPipelineRasterizationStateStreamCreateFlagsEXT  =  ^VkPipelineRasterizationStateStreamCreateFlagsEXT;
  PPVkPipelineRasterizationStateStreamCreateFlagsEXT = ^PVkPipelineRasterizationStateStreamCreateFlagsEXT;
  VkPipelineRasterizationDepthClipStateCreateFlagsEXT   = VkFlags;
  PVkPipelineRasterizationDepthClipStateCreateFlagsEXT  =  ^VkPipelineRasterizationDepthClipStateCreateFlagsEXT;
  PPVkPipelineRasterizationDepthClipStateCreateFlagsEXT = ^PVkPipelineRasterizationDepthClipStateCreateFlagsEXT;
  VkSwapchainImageUsageFlagsANDROID   = VkFlags;
  PVkSwapchainImageUsageFlagsANDROID  =  ^VkSwapchainImageUsageFlagsANDROID;
  PPVkSwapchainImageUsageFlagsANDROID = ^PVkSwapchainImageUsageFlagsANDROID;
  VkToolPurposeFlagsEXT   = VkFlags;
  PVkToolPurposeFlagsEXT  =  ^VkToolPurposeFlagsEXT;
  PPVkToolPurposeFlagsEXT = ^PVkToolPurposeFlagsEXT;
  VkSubmitFlagsKHR   = VkFlags;
  PVkSubmitFlagsKHR  =  ^VkSubmitFlagsKHR;
  PPVkSubmitFlagsKHR = ^PVkSubmitFlagsKHR;
  VkVideoCodecOperationFlagsKHR   = VkFlags;
  PVkVideoCodecOperationFlagsKHR  =  ^VkVideoCodecOperationFlagsKHR;
  PPVkVideoCodecOperationFlagsKHR = ^PVkVideoCodecOperationFlagsKHR;
  VkVideoCapabilityFlagsKHR   = VkFlags;
  PVkVideoCapabilityFlagsKHR  =  ^VkVideoCapabilityFlagsKHR;
  PPVkVideoCapabilityFlagsKHR = ^PVkVideoCapabilityFlagsKHR;
  VkVideoSessionCreateFlagsKHR   = VkFlags;
  PVkVideoSessionCreateFlagsKHR  =  ^VkVideoSessionCreateFlagsKHR;
  PPVkVideoSessionCreateFlagsKHR = ^PVkVideoSessionCreateFlagsKHR;
  VkVideoBeginCodingFlagsKHR   = VkFlags;
  PVkVideoBeginCodingFlagsKHR  =  ^VkVideoBeginCodingFlagsKHR;
  PPVkVideoBeginCodingFlagsKHR = ^PVkVideoBeginCodingFlagsKHR;
  VkVideoEndCodingFlagsKHR   = VkFlags;
  PVkVideoEndCodingFlagsKHR  =  ^VkVideoEndCodingFlagsKHR;
  PPVkVideoEndCodingFlagsKHR = ^PVkVideoEndCodingFlagsKHR;
  VkVideoCodingQualityPresetFlagsKHR   = VkFlags;
  PVkVideoCodingQualityPresetFlagsKHR  =  ^VkVideoCodingQualityPresetFlagsKHR;
  PPVkVideoCodingQualityPresetFlagsKHR = ^PVkVideoCodingQualityPresetFlagsKHR;
  VkVideoCodingControlFlagsKHR   = VkFlags;
  PVkVideoCodingControlFlagsKHR  =  ^VkVideoCodingControlFlagsKHR;
  PPVkVideoCodingControlFlagsKHR = ^PVkVideoCodingControlFlagsKHR;
  VkVideoDecodeFlagsKHR   = VkFlags;
  PVkVideoDecodeFlagsKHR  =  ^VkVideoDecodeFlagsKHR;
  PPVkVideoDecodeFlagsKHR = ^PVkVideoDecodeFlagsKHR;
  VkVideoDecodeH264PictureLayoutFlagsEXT   = VkFlags;
  PVkVideoDecodeH264PictureLayoutFlagsEXT  =  ^VkVideoDecodeH264PictureLayoutFlagsEXT;
  PPVkVideoDecodeH264PictureLayoutFlagsEXT = ^PVkVideoDecodeH264PictureLayoutFlagsEXT;
  VkVideoDecodeH264CreateFlagsEXT   = VkFlags;
  PVkVideoDecodeH264CreateFlagsEXT  =  ^VkVideoDecodeH264CreateFlagsEXT;
  PPVkVideoDecodeH264CreateFlagsEXT = ^PVkVideoDecodeH264CreateFlagsEXT;
  VkVideoDecodeH265CreateFlagsEXT   = VkFlags;
  PVkVideoDecodeH265CreateFlagsEXT  =  ^VkVideoDecodeH265CreateFlagsEXT;
  PPVkVideoDecodeH265CreateFlagsEXT = ^PVkVideoDecodeH265CreateFlagsEXT;
  VkVideoEncodeFlagsKHR   = VkFlags;
  PVkVideoEncodeFlagsKHR  =  ^VkVideoEncodeFlagsKHR;
  PPVkVideoEncodeFlagsKHR = ^PVkVideoEncodeFlagsKHR;
  VkVideoEncodeRateControlFlagsKHR   = VkFlags;
  PVkVideoEncodeRateControlFlagsKHR  =  ^VkVideoEncodeRateControlFlagsKHR;
  PPVkVideoEncodeRateControlFlagsKHR = ^PVkVideoEncodeRateControlFlagsKHR;
  VkVideoEncodeRateControlModeFlagsKHR   = VkFlags;
  PVkVideoEncodeRateControlModeFlagsKHR  =  ^VkVideoEncodeRateControlModeFlagsKHR;
  PPVkVideoEncodeRateControlModeFlagsKHR = ^PVkVideoEncodeRateControlModeFlagsKHR;
  VkVideoChromaSubsamplingFlagsKHR   = VkFlags;
  PVkVideoChromaSubsamplingFlagsKHR  =  ^VkVideoChromaSubsamplingFlagsKHR;
  PPVkVideoChromaSubsamplingFlagsKHR = ^PVkVideoChromaSubsamplingFlagsKHR;
  VkVideoComponentBitDepthFlagsKHR   = VkFlags;
  PVkVideoComponentBitDepthFlagsKHR  =  ^VkVideoComponentBitDepthFlagsKHR;
  PPVkVideoComponentBitDepthFlagsKHR = ^PVkVideoComponentBitDepthFlagsKHR;
  VkVideoEncodeH264CapabilityFlagsEXT   = VkFlags;
  PVkVideoEncodeH264CapabilityFlagsEXT  =  ^VkVideoEncodeH264CapabilityFlagsEXT;
  PPVkVideoEncodeH264CapabilityFlagsEXT = ^PVkVideoEncodeH264CapabilityFlagsEXT;
  VkVideoEncodeH264InputModeFlagsEXT   = VkFlags;
  PVkVideoEncodeH264InputModeFlagsEXT  =  ^VkVideoEncodeH264InputModeFlagsEXT;
  PPVkVideoEncodeH264InputModeFlagsEXT = ^PVkVideoEncodeH264InputModeFlagsEXT;
  VkVideoEncodeH264OutputModeFlagsEXT   = VkFlags;
  PVkVideoEncodeH264OutputModeFlagsEXT  =  ^VkVideoEncodeH264OutputModeFlagsEXT;
  PPVkVideoEncodeH264OutputModeFlagsEXT = ^PVkVideoEncodeH264OutputModeFlagsEXT;
  VkVideoEncodeH264CreateFlagsEXT   = VkFlags;
  PVkVideoEncodeH264CreateFlagsEXT  =  ^VkVideoEncodeH264CreateFlagsEXT;
  PPVkVideoEncodeH264CreateFlagsEXT = ^PVkVideoEncodeH264CreateFlagsEXT;
  VkInstance   = type TVkHandle;
  PVkInstance  =  ^VkInstance;
  PPVkInstance = ^PVkInstance;
  VkPhysicalDevice   = type TVkHandle;
  PVkPhysicalDevice  =  ^VkPhysicalDevice;
  PPVkPhysicalDevice = ^PVkPhysicalDevice;
  VkDevice   = type TVkHandle;
  PVkDevice  =  ^VkDevice;
  PPVkDevice = ^PVkDevice;
  VkQueue   = type TVkHandle;
  PVkQueue  =  ^VkQueue;
  PPVkQueue = ^PVkQueue;
  VkCommandBuffer   = type TVkHandle;
  PVkCommandBuffer  =  ^VkCommandBuffer;
  PPVkCommandBuffer = ^PVkCommandBuffer;
  VkDeviceMemory   = type TVkHandleNonDispatchable;
  PVkDeviceMemory  =  ^VkDeviceMemory;
  PPVkDeviceMemory = ^PVkDeviceMemory;
  VkCommandPool   = type TVkHandleNonDispatchable;
  PVkCommandPool  =  ^VkCommandPool;
  PPVkCommandPool = ^PVkCommandPool;
  VkBuffer   = type TVkHandleNonDispatchable;
  PVkBuffer  =  ^VkBuffer;
  PPVkBuffer = ^PVkBuffer;
  VkBufferView   = type TVkHandleNonDispatchable;
  PVkBufferView  =  ^VkBufferView;
  PPVkBufferView = ^PVkBufferView;
  VkImage   = type TVkHandleNonDispatchable;
  PVkImage  =  ^VkImage;
  PPVkImage = ^PVkImage;
  VkImageView   = type TVkHandleNonDispatchable;
  PVkImageView  =  ^VkImageView;
  PPVkImageView = ^PVkImageView;
  VkShaderModule   = type TVkHandleNonDispatchable;
  PVkShaderModule  =  ^VkShaderModule;
  PPVkShaderModule = ^PVkShaderModule;
  VkPipeline   = type TVkHandleNonDispatchable;
  PVkPipeline  =  ^VkPipeline;
  PPVkPipeline = ^PVkPipeline;
  VkPipelineLayout   = type TVkHandleNonDispatchable;
  PVkPipelineLayout  =  ^VkPipelineLayout;
  PPVkPipelineLayout = ^PVkPipelineLayout;
  VkSampler   = type TVkHandleNonDispatchable;
  PVkSampler  =  ^VkSampler;
  PPVkSampler = ^PVkSampler;
  VkDescriptorSet   = type TVkHandleNonDispatchable;
  PVkDescriptorSet  =  ^VkDescriptorSet;
  PPVkDescriptorSet = ^PVkDescriptorSet;
  VkDescriptorSetLayout   = type TVkHandleNonDispatchable;
  PVkDescriptorSetLayout  =  ^VkDescriptorSetLayout;
  PPVkDescriptorSetLayout = ^PVkDescriptorSetLayout;
  VkDescriptorPool   = type TVkHandleNonDispatchable;
  PVkDescriptorPool  =  ^VkDescriptorPool;
  PPVkDescriptorPool = ^PVkDescriptorPool;
  VkFence   = type TVkHandleNonDispatchable;
  PVkFence  =  ^VkFence;
  PPVkFence = ^PVkFence;
  VkSemaphore   = type TVkHandleNonDispatchable;
  PVkSemaphore  =  ^VkSemaphore;
  PPVkSemaphore = ^PVkSemaphore;
  VkEvent   = type TVkHandleNonDispatchable;
  PVkEvent  =  ^VkEvent;
  PPVkEvent = ^PVkEvent;
  VkQueryPool   = type TVkHandleNonDispatchable;
  PVkQueryPool  =  ^VkQueryPool;
  PPVkQueryPool = ^PVkQueryPool;
  VkFramebuffer   = type TVkHandleNonDispatchable;
  PVkFramebuffer  =  ^VkFramebuffer;
  PPVkFramebuffer = ^PVkFramebuffer;
  VkRenderPass   = type TVkHandleNonDispatchable;
  PVkRenderPass  =  ^VkRenderPass;
  PPVkRenderPass = ^PVkRenderPass;
  VkPipelineCache   = type TVkHandleNonDispatchable;
  PVkPipelineCache  =  ^VkPipelineCache;
  PPVkPipelineCache = ^PVkPipelineCache;
  VkIndirectCommandsLayoutNV   = type TVkHandleNonDispatchable;
  PVkIndirectCommandsLayoutNV  =  ^VkIndirectCommandsLayoutNV;
  PPVkIndirectCommandsLayoutNV = ^PVkIndirectCommandsLayoutNV;
  VkDescriptorUpdateTemplate   = type TVkHandleNonDispatchable;
  PVkDescriptorUpdateTemplate  =  ^VkDescriptorUpdateTemplate;
  PPVkDescriptorUpdateTemplate = ^PVkDescriptorUpdateTemplate;
  VkDescriptorUpdateTemplateKHR   = Pointer;
  PVkDescriptorUpdateTemplateKHR  =  ^VkDescriptorUpdateTemplateKHR;
  PPVkDescriptorUpdateTemplateKHR = ^PVkDescriptorUpdateTemplateKHR;
  VkSamplerYcbcrConversion   = type TVkHandleNonDispatchable;
  PVkSamplerYcbcrConversion  =  ^VkSamplerYcbcrConversion;
  PPVkSamplerYcbcrConversion = ^PVkSamplerYcbcrConversion;
  VkSamplerYcbcrConversionKHR   = Pointer;
  PVkSamplerYcbcrConversionKHR  =  ^VkSamplerYcbcrConversionKHR;
  PPVkSamplerYcbcrConversionKHR = ^PVkSamplerYcbcrConversionKHR;
  VkValidationCacheEXT   = type TVkHandleNonDispatchable;
  PVkValidationCacheEXT  =  ^VkValidationCacheEXT;
  PPVkValidationCacheEXT = ^PVkValidationCacheEXT;
  VkAccelerationStructureKHR   = type TVkHandleNonDispatchable;
  PVkAccelerationStructureKHR  =  ^VkAccelerationStructureKHR;
  PPVkAccelerationStructureKHR = ^PVkAccelerationStructureKHR;
  VkAccelerationStructureNV   = type TVkHandleNonDispatchable;
  PVkAccelerationStructureNV  =  ^VkAccelerationStructureNV;
  PPVkAccelerationStructureNV = ^PVkAccelerationStructureNV;
  VkPerformanceConfigurationINTEL   = type TVkHandleNonDispatchable;
  PVkPerformanceConfigurationINTEL  =  ^VkPerformanceConfigurationINTEL;
  PPVkPerformanceConfigurationINTEL = ^PVkPerformanceConfigurationINTEL;
  VkDeferredOperationKHR   = type TVkHandleNonDispatchable;
  PVkDeferredOperationKHR  =  ^VkDeferredOperationKHR;
  PPVkDeferredOperationKHR = ^PVkDeferredOperationKHR;
  VkPrivateDataSlotEXT   = type TVkHandleNonDispatchable;
  PVkPrivateDataSlotEXT  =  ^VkPrivateDataSlotEXT;
  PPVkPrivateDataSlotEXT = ^PVkPrivateDataSlotEXT;
  VkCuModuleNVX   = type TVkHandleNonDispatchable;
  PVkCuModuleNVX  =  ^VkCuModuleNVX;
  PPVkCuModuleNVX = ^PVkCuModuleNVX;
  VkCuFunctionNVX   = type TVkHandleNonDispatchable;
  PVkCuFunctionNVX  =  ^VkCuFunctionNVX;
  PPVkCuFunctionNVX = ^PVkCuFunctionNVX;
  VkDisplayKHR   = type TVkHandleNonDispatchable;
  PVkDisplayKHR  =  ^VkDisplayKHR;
  PPVkDisplayKHR = ^PVkDisplayKHR;
  VkDisplayModeKHR   = type TVkHandleNonDispatchable;
  PVkDisplayModeKHR  =  ^VkDisplayModeKHR;
  PPVkDisplayModeKHR = ^PVkDisplayModeKHR;
  VkSurfaceKHR   = type TVkHandleNonDispatchable;
  PVkSurfaceKHR  =  ^VkSurfaceKHR;
  PPVkSurfaceKHR = ^PVkSurfaceKHR;
  VkSwapchainKHR   = type TVkHandleNonDispatchable;
  PVkSwapchainKHR  =  ^VkSwapchainKHR;
  PPVkSwapchainKHR = ^PVkSwapchainKHR;
  VkDebugReportCallbackEXT   = type TVkHandleNonDispatchable;
  PVkDebugReportCallbackEXT  =  ^VkDebugReportCallbackEXT;
  PPVkDebugReportCallbackEXT = ^PVkDebugReportCallbackEXT;
  VkDebugUtilsMessengerEXT   = type TVkHandleNonDispatchable;
  PVkDebugUtilsMessengerEXT  =  ^VkDebugUtilsMessengerEXT;
  PPVkDebugUtilsMessengerEXT = ^PVkDebugUtilsMessengerEXT;
  VkVideoSessionKHR   = type TVkHandleNonDispatchable;
  PVkVideoSessionKHR  =  ^VkVideoSessionKHR;
  PPVkVideoSessionKHR = ^PVkVideoSessionKHR;
  VkVideoSessionParametersKHR   = type TVkHandleNonDispatchable;
  PVkVideoSessionParametersKHR  =  ^VkVideoSessionParametersKHR;
  PPVkVideoSessionParametersKHR = ^PVkVideoSessionParametersKHR;
  VkAttachmentLoadOp   = Int32;
  PVkAttachmentLoadOp  =  ^VkAttachmentLoadOp;
  PPVkAttachmentLoadOp = ^PVkAttachmentLoadOp;
  VkAttachmentStoreOp   = Int32;
  PVkAttachmentStoreOp  =  ^VkAttachmentStoreOp;
  PPVkAttachmentStoreOp = ^PVkAttachmentStoreOp;
  VkBlendFactor   = Int32;
  PVkBlendFactor  =  ^VkBlendFactor;
  PPVkBlendFactor = ^PVkBlendFactor;
  VkBlendOp   = Int32;
  PVkBlendOp  =  ^VkBlendOp;
  PPVkBlendOp = ^PVkBlendOp;
  VkBorderColor   = Int32;
  PVkBorderColor  =  ^VkBorderColor;
  PPVkBorderColor = ^PVkBorderColor;
  VkFramebufferCreateFlagBits   = Int32;
  PVkFramebufferCreateFlagBits  =  ^VkFramebufferCreateFlagBits;
  PPVkFramebufferCreateFlagBits = ^PVkFramebufferCreateFlagBits;
  VkQueryPoolCreateFlagBits   = Int32;
  PVkQueryPoolCreateFlagBits  =  ^VkQueryPoolCreateFlagBits;
  PPVkQueryPoolCreateFlagBits = ^PVkQueryPoolCreateFlagBits;
  VkRenderPassCreateFlagBits   = Int32;
  PVkRenderPassCreateFlagBits  =  ^VkRenderPassCreateFlagBits;
  PPVkRenderPassCreateFlagBits = ^PVkRenderPassCreateFlagBits;
  VkSamplerCreateFlagBits   = Int32;
  PVkSamplerCreateFlagBits  =  ^VkSamplerCreateFlagBits;
  PPVkSamplerCreateFlagBits = ^PVkSamplerCreateFlagBits;
  VkPipelineCacheHeaderVersion   = Int32;
  PVkPipelineCacheHeaderVersion  =  ^VkPipelineCacheHeaderVersion;
  PPVkPipelineCacheHeaderVersion = ^PVkPipelineCacheHeaderVersion;
  VkPipelineCacheCreateFlagBits   = Int32;
  PVkPipelineCacheCreateFlagBits  =  ^VkPipelineCacheCreateFlagBits;
  PPVkPipelineCacheCreateFlagBits = ^PVkPipelineCacheCreateFlagBits;
  VkPipelineShaderStageCreateFlagBits   = Int32;
  PVkPipelineShaderStageCreateFlagBits  =  ^VkPipelineShaderStageCreateFlagBits;
  PPVkPipelineShaderStageCreateFlagBits = ^PVkPipelineShaderStageCreateFlagBits;
  VkDescriptorSetLayoutCreateFlagBits   = Int32;
  PVkDescriptorSetLayoutCreateFlagBits  =  ^VkDescriptorSetLayoutCreateFlagBits;
  PPVkDescriptorSetLayoutCreateFlagBits = ^PVkDescriptorSetLayoutCreateFlagBits;
  VkInstanceCreateFlagBits   = Int32;
  PVkInstanceCreateFlagBits  =  ^VkInstanceCreateFlagBits;
  PPVkInstanceCreateFlagBits = ^PVkInstanceCreateFlagBits;
  VkDeviceQueueCreateFlagBits   = Int32;
  PVkDeviceQueueCreateFlagBits  =  ^VkDeviceQueueCreateFlagBits;
  PPVkDeviceQueueCreateFlagBits = ^PVkDeviceQueueCreateFlagBits;
  VkBufferCreateFlagBits   = Int32;
  PVkBufferCreateFlagBits  =  ^VkBufferCreateFlagBits;
  PPVkBufferCreateFlagBits = ^PVkBufferCreateFlagBits;
  VkBufferUsageFlagBits   = Int32;
  PVkBufferUsageFlagBits  =  ^VkBufferUsageFlagBits;
  PPVkBufferUsageFlagBits = ^PVkBufferUsageFlagBits;
  VkColorComponentFlagBits   = Int32;
  PVkColorComponentFlagBits  =  ^VkColorComponentFlagBits;
  PPVkColorComponentFlagBits = ^PVkColorComponentFlagBits;
  VkComponentSwizzle   = Int32;
  PVkComponentSwizzle  =  ^VkComponentSwizzle;
  PPVkComponentSwizzle = ^PVkComponentSwizzle;
  VkCommandPoolCreateFlagBits   = Int32;
  PVkCommandPoolCreateFlagBits  =  ^VkCommandPoolCreateFlagBits;
  PPVkCommandPoolCreateFlagBits = ^PVkCommandPoolCreateFlagBits;
  VkCommandPoolResetFlagBits   = Int32;
  PVkCommandPoolResetFlagBits  =  ^VkCommandPoolResetFlagBits;
  PPVkCommandPoolResetFlagBits = ^PVkCommandPoolResetFlagBits;
  VkCommandBufferResetFlagBits   = Int32;
  PVkCommandBufferResetFlagBits  =  ^VkCommandBufferResetFlagBits;
  PPVkCommandBufferResetFlagBits = ^PVkCommandBufferResetFlagBits;
  VkCommandBufferLevel   = Int32;
  PVkCommandBufferLevel  =  ^VkCommandBufferLevel;
  PPVkCommandBufferLevel = ^PVkCommandBufferLevel;
  VkCommandBufferUsageFlagBits   = Int32;
  PVkCommandBufferUsageFlagBits  =  ^VkCommandBufferUsageFlagBits;
  PPVkCommandBufferUsageFlagBits = ^PVkCommandBufferUsageFlagBits;
  VkCompareOp   = Int32;
  PVkCompareOp  =  ^VkCompareOp;
  PPVkCompareOp = ^PVkCompareOp;
  VkCullModeFlagBits   = Int32;
  PVkCullModeFlagBits  =  ^VkCullModeFlagBits;
  PPVkCullModeFlagBits = ^PVkCullModeFlagBits;
  VkDescriptorType   = Int32;
  PVkDescriptorType  =  ^VkDescriptorType;
  PPVkDescriptorType = ^PVkDescriptorType;
  VkDeviceCreateFlagBits   = Int32;
  PVkDeviceCreateFlagBits  =  ^VkDeviceCreateFlagBits;
  PPVkDeviceCreateFlagBits = ^PVkDeviceCreateFlagBits;
  VkDynamicState   = Int32;
  PVkDynamicState  =  ^VkDynamicState;
  PPVkDynamicState = ^PVkDynamicState;
  VkFenceCreateFlagBits   = Int32;
  PVkFenceCreateFlagBits  =  ^VkFenceCreateFlagBits;
  PPVkFenceCreateFlagBits = ^PVkFenceCreateFlagBits;
  VkPolygonMode   = Int32;
  PVkPolygonMode  =  ^VkPolygonMode;
  PPVkPolygonMode = ^PVkPolygonMode;
  VkFormat   = Int32;
  PVkFormat  =  ^VkFormat;
  PPVkFormat = ^PVkFormat;
  VkFormatFeatureFlagBits   = Int32;
  PVkFormatFeatureFlagBits  =  ^VkFormatFeatureFlagBits;
  PPVkFormatFeatureFlagBits = ^PVkFormatFeatureFlagBits;
  VkFrontFace   = Int32;
  PVkFrontFace  =  ^VkFrontFace;
  PPVkFrontFace = ^PVkFrontFace;
  VkImageAspectFlagBits   = Int32;
  PVkImageAspectFlagBits  =  ^VkImageAspectFlagBits;
  PPVkImageAspectFlagBits = ^PVkImageAspectFlagBits;
  VkImageCreateFlagBits   = Int32;
  PVkImageCreateFlagBits  =  ^VkImageCreateFlagBits;
  PPVkImageCreateFlagBits = ^PVkImageCreateFlagBits;
  VkImageLayout   = Int32;
  PVkImageLayout  =  ^VkImageLayout;
  PPVkImageLayout = ^PVkImageLayout;
  VkImageTiling   = Int32;
  PVkImageTiling  =  ^VkImageTiling;
  PPVkImageTiling = ^PVkImageTiling;
  VkImageType   = Int32;
  PVkImageType  =  ^VkImageType;
  PPVkImageType = ^PVkImageType;
  VkImageUsageFlagBits   = Int32;
  PVkImageUsageFlagBits  =  ^VkImageUsageFlagBits;
  PPVkImageUsageFlagBits = ^PVkImageUsageFlagBits;
  VkImageViewCreateFlagBits   = Int32;
  PVkImageViewCreateFlagBits  =  ^VkImageViewCreateFlagBits;
  PPVkImageViewCreateFlagBits = ^PVkImageViewCreateFlagBits;
  VkImageViewType   = Int32;
  PVkImageViewType  =  ^VkImageViewType;
  PPVkImageViewType = ^PVkImageViewType;
  VkSharingMode   = Int32;
  PVkSharingMode  =  ^VkSharingMode;
  PPVkSharingMode = ^PVkSharingMode;
  VkIndexType   = Int32;
  PVkIndexType  =  ^VkIndexType;
  PPVkIndexType = ^PVkIndexType;
  VkLogicOp   = Int32;
  PVkLogicOp  =  ^VkLogicOp;
  PPVkLogicOp = ^PVkLogicOp;
  VkMemoryHeapFlagBits   = Int32;
  PVkMemoryHeapFlagBits  =  ^VkMemoryHeapFlagBits;
  PPVkMemoryHeapFlagBits = ^PVkMemoryHeapFlagBits;
  VkAccessFlagBits   = Int32;
  PVkAccessFlagBits  =  ^VkAccessFlagBits;
  PPVkAccessFlagBits = ^PVkAccessFlagBits;
  VkMemoryPropertyFlagBits   = Int32;
  PVkMemoryPropertyFlagBits  =  ^VkMemoryPropertyFlagBits;
  PPVkMemoryPropertyFlagBits = ^PVkMemoryPropertyFlagBits;
  VkPhysicalDeviceType   = Int32;
  PVkPhysicalDeviceType  =  ^VkPhysicalDeviceType;
  PPVkPhysicalDeviceType = ^PVkPhysicalDeviceType;
  VkPipelineBindPoint   = Int32;
  PVkPipelineBindPoint  =  ^VkPipelineBindPoint;
  PPVkPipelineBindPoint = ^PVkPipelineBindPoint;
  VkPipelineCreateFlagBits   = Int32;
  PVkPipelineCreateFlagBits  =  ^VkPipelineCreateFlagBits;
  PPVkPipelineCreateFlagBits = ^PVkPipelineCreateFlagBits;
  VkPrimitiveTopology   = Int32;
  PVkPrimitiveTopology  =  ^VkPrimitiveTopology;
  PPVkPrimitiveTopology = ^PVkPrimitiveTopology;
  VkQueryControlFlagBits   = Int32;
  PVkQueryControlFlagBits  =  ^VkQueryControlFlagBits;
  PPVkQueryControlFlagBits = ^PVkQueryControlFlagBits;
  VkQueryPipelineStatisticFlagBits   = Int32;
  PVkQueryPipelineStatisticFlagBits  =  ^VkQueryPipelineStatisticFlagBits;
  PPVkQueryPipelineStatisticFlagBits = ^PVkQueryPipelineStatisticFlagBits;
  VkQueryResultFlagBits   = Int32;
  PVkQueryResultFlagBits  =  ^VkQueryResultFlagBits;
  PPVkQueryResultFlagBits = ^PVkQueryResultFlagBits;
  VkQueryType   = Int32;
  PVkQueryType  =  ^VkQueryType;
  PPVkQueryType = ^PVkQueryType;
  VkQueueFlagBits   = Int32;
  PVkQueueFlagBits  =  ^VkQueueFlagBits;
  PPVkQueueFlagBits = ^PVkQueueFlagBits;
  VkSubpassContents   = Int32;
  PVkSubpassContents  =  ^VkSubpassContents;
  PPVkSubpassContents = ^PVkSubpassContents;
  VkResult   = Int32;
  PVkResult  =  ^VkResult;
  PPVkResult = ^PVkResult;
  VkShaderStageFlagBits   = Int32;
  PVkShaderStageFlagBits  =  ^VkShaderStageFlagBits;
  PPVkShaderStageFlagBits = ^PVkShaderStageFlagBits;
  VkSparseMemoryBindFlagBits   = Int32;
  PVkSparseMemoryBindFlagBits  =  ^VkSparseMemoryBindFlagBits;
  PPVkSparseMemoryBindFlagBits = ^PVkSparseMemoryBindFlagBits;
  VkStencilFaceFlagBits   = Int32;
  PVkStencilFaceFlagBits  =  ^VkStencilFaceFlagBits;
  PPVkStencilFaceFlagBits = ^PVkStencilFaceFlagBits;
  VkStencilOp   = Int32;
  PVkStencilOp  =  ^VkStencilOp;
  PPVkStencilOp = ^PVkStencilOp;
  VkStructureType   = Int32;
  PVkStructureType  =  ^VkStructureType;
  PPVkStructureType = ^PVkStructureType;
  VkSystemAllocationScope   = Int32;
  PVkSystemAllocationScope  =  ^VkSystemAllocationScope;
  PPVkSystemAllocationScope = ^PVkSystemAllocationScope;
  VkInternalAllocationType   = Int32;
  PVkInternalAllocationType  =  ^VkInternalAllocationType;
  PPVkInternalAllocationType = ^PVkInternalAllocationType;
  VkSamplerAddressMode   = Int32;
  PVkSamplerAddressMode  =  ^VkSamplerAddressMode;
  PPVkSamplerAddressMode = ^PVkSamplerAddressMode;
  VkFilter   = Int32;
  PVkFilter  =  ^VkFilter;
  PPVkFilter = ^PVkFilter;
  VkSamplerMipmapMode   = Int32;
  PVkSamplerMipmapMode  =  ^VkSamplerMipmapMode;
  PPVkSamplerMipmapMode = ^PVkSamplerMipmapMode;
  VkVertexInputRate   = Int32;
  PVkVertexInputRate  =  ^VkVertexInputRate;
  PPVkVertexInputRate = ^PVkVertexInputRate;
  VkPipelineStageFlagBits   = Int32;
  PVkPipelineStageFlagBits  =  ^VkPipelineStageFlagBits;
  PPVkPipelineStageFlagBits = ^PVkPipelineStageFlagBits;
  VkSparseImageFormatFlagBits   = Int32;
  PVkSparseImageFormatFlagBits  =  ^VkSparseImageFormatFlagBits;
  PPVkSparseImageFormatFlagBits = ^PVkSparseImageFormatFlagBits;
  VkSampleCountFlagBits   = Int32;
  PVkSampleCountFlagBits  =  ^VkSampleCountFlagBits;
  PPVkSampleCountFlagBits = ^PVkSampleCountFlagBits;
  VkAttachmentDescriptionFlagBits   = Int32;
  PVkAttachmentDescriptionFlagBits  =  ^VkAttachmentDescriptionFlagBits;
  PPVkAttachmentDescriptionFlagBits = ^PVkAttachmentDescriptionFlagBits;
  VkDescriptorPoolCreateFlagBits   = Int32;
  PVkDescriptorPoolCreateFlagBits  =  ^VkDescriptorPoolCreateFlagBits;
  PPVkDescriptorPoolCreateFlagBits = ^PVkDescriptorPoolCreateFlagBits;
  VkDependencyFlagBits   = Int32;
  PVkDependencyFlagBits  =  ^VkDependencyFlagBits;
  PPVkDependencyFlagBits = ^PVkDependencyFlagBits;
  VkObjectType   = Int32;
  PVkObjectType  =  ^VkObjectType;
  PPVkObjectType = ^PVkObjectType;
  VkEventCreateFlagBits   = Int32;
  PVkEventCreateFlagBits  =  ^VkEventCreateFlagBits;
  PPVkEventCreateFlagBits = ^PVkEventCreateFlagBits;
  VkPipelineLayoutCreateFlagBits   = Int32;
  PVkPipelineLayoutCreateFlagBits  =  ^VkPipelineLayoutCreateFlagBits;
  PPVkPipelineLayoutCreateFlagBits = ^PVkPipelineLayoutCreateFlagBits;
  VkIndirectCommandsLayoutUsageFlagBitsNV   = Int32;
  PVkIndirectCommandsLayoutUsageFlagBitsNV  =  ^VkIndirectCommandsLayoutUsageFlagBitsNV;
  PPVkIndirectCommandsLayoutUsageFlagBitsNV = ^PVkIndirectCommandsLayoutUsageFlagBitsNV;
  VkIndirectCommandsTokenTypeNV   = Int32;
  PVkIndirectCommandsTokenTypeNV  =  ^VkIndirectCommandsTokenTypeNV;
  PPVkIndirectCommandsTokenTypeNV = ^PVkIndirectCommandsTokenTypeNV;
  VkIndirectStateFlagBitsNV   = Int32;
  PVkIndirectStateFlagBitsNV  =  ^VkIndirectStateFlagBitsNV;
  PPVkIndirectStateFlagBitsNV = ^PVkIndirectStateFlagBitsNV;
  VkPrivateDataSlotCreateFlagBitsEXT   = Int32;
  PVkPrivateDataSlotCreateFlagBitsEXT  =  ^VkPrivateDataSlotCreateFlagBitsEXT;
  PPVkPrivateDataSlotCreateFlagBitsEXT = ^PVkPrivateDataSlotCreateFlagBitsEXT;
  VkDescriptorUpdateTemplateType   = Int32;
  PVkDescriptorUpdateTemplateType  =  ^VkDescriptorUpdateTemplateType;
  PPVkDescriptorUpdateTemplateType = ^PVkDescriptorUpdateTemplateType;
  VkDescriptorUpdateTemplateTypeKHR   = Int32;
  PVkDescriptorUpdateTemplateTypeKHR  =  ^VkDescriptorUpdateTemplateTypeKHR;
  PPVkDescriptorUpdateTemplateTypeKHR = ^PVkDescriptorUpdateTemplateTypeKHR;
  VkViewportCoordinateSwizzleNV   = Int32;
  PVkViewportCoordinateSwizzleNV  =  ^VkViewportCoordinateSwizzleNV;
  PPVkViewportCoordinateSwizzleNV = ^PVkViewportCoordinateSwizzleNV;
  VkDiscardRectangleModeEXT   = Int32;
  PVkDiscardRectangleModeEXT  =  ^VkDiscardRectangleModeEXT;
  PPVkDiscardRectangleModeEXT = ^PVkDiscardRectangleModeEXT;
  VkSubpassDescriptionFlagBits   = Int32;
  PVkSubpassDescriptionFlagBits  =  ^VkSubpassDescriptionFlagBits;
  PPVkSubpassDescriptionFlagBits = ^PVkSubpassDescriptionFlagBits;
  VkPointClippingBehavior   = Int32;
  PVkPointClippingBehavior  =  ^VkPointClippingBehavior;
  PPVkPointClippingBehavior = ^PVkPointClippingBehavior;
  VkPointClippingBehaviorKHR   = Int32;
  PVkPointClippingBehaviorKHR  =  ^VkPointClippingBehaviorKHR;
  PPVkPointClippingBehaviorKHR = ^PVkPointClippingBehaviorKHR;
  VkCoverageModulationModeNV   = Int32;
  PVkCoverageModulationModeNV  =  ^VkCoverageModulationModeNV;
  PPVkCoverageModulationModeNV = ^PVkCoverageModulationModeNV;
  VkCoverageReductionModeNV   = Int32;
  PVkCoverageReductionModeNV  =  ^VkCoverageReductionModeNV;
  PPVkCoverageReductionModeNV = ^PVkCoverageReductionModeNV;
  VkValidationCacheHeaderVersionEXT   = Int32;
  PVkValidationCacheHeaderVersionEXT  =  ^VkValidationCacheHeaderVersionEXT;
  PPVkValidationCacheHeaderVersionEXT = ^PVkValidationCacheHeaderVersionEXT;
  VkShaderInfoTypeAMD   = Int32;
  PVkShaderInfoTypeAMD  =  ^VkShaderInfoTypeAMD;
  PPVkShaderInfoTypeAMD = ^PVkShaderInfoTypeAMD;
  VkQueueGlobalPriorityEXT   = Int32;
  PVkQueueGlobalPriorityEXT  =  ^VkQueueGlobalPriorityEXT;
  PPVkQueueGlobalPriorityEXT = ^PVkQueueGlobalPriorityEXT;
  VkTimeDomainEXT   = Int32;
  PVkTimeDomainEXT  =  ^VkTimeDomainEXT;
  PPVkTimeDomainEXT = ^PVkTimeDomainEXT;
  VkConservativeRasterizationModeEXT   = Int32;
  PVkConservativeRasterizationModeEXT  =  ^VkConservativeRasterizationModeEXT;
  PPVkConservativeRasterizationModeEXT = ^PVkConservativeRasterizationModeEXT;
  VkResolveModeFlagBits   = Int32;
  PVkResolveModeFlagBits  =  ^VkResolveModeFlagBits;
  PPVkResolveModeFlagBits = ^PVkResolveModeFlagBits;
  VkResolveModeFlagBitsKHR   = Int32;
  PVkResolveModeFlagBitsKHR  =  ^VkResolveModeFlagBitsKHR;
  PPVkResolveModeFlagBitsKHR = ^PVkResolveModeFlagBitsKHR;
  VkDescriptorBindingFlagBits   = Int32;
  PVkDescriptorBindingFlagBits  =  ^VkDescriptorBindingFlagBits;
  PPVkDescriptorBindingFlagBits = ^PVkDescriptorBindingFlagBits;
  VkDescriptorBindingFlagBitsEXT   = Int32;
  PVkDescriptorBindingFlagBitsEXT  =  ^VkDescriptorBindingFlagBitsEXT;
  PPVkDescriptorBindingFlagBitsEXT = ^PVkDescriptorBindingFlagBitsEXT;
  VkConditionalRenderingFlagBitsEXT   = Int32;
  PVkConditionalRenderingFlagBitsEXT  =  ^VkConditionalRenderingFlagBitsEXT;
  PPVkConditionalRenderingFlagBitsEXT = ^PVkConditionalRenderingFlagBitsEXT;
  VkSemaphoreType   = Int32;
  PVkSemaphoreType  =  ^VkSemaphoreType;
  PPVkSemaphoreType = ^PVkSemaphoreType;
  VkSemaphoreTypeKHR   = Int32;
  PVkSemaphoreTypeKHR  =  ^VkSemaphoreTypeKHR;
  PPVkSemaphoreTypeKHR = ^PVkSemaphoreTypeKHR;
  VkGeometryFlagBitsKHR   = Int32;
  PVkGeometryFlagBitsKHR  =  ^VkGeometryFlagBitsKHR;
  PPVkGeometryFlagBitsKHR = ^PVkGeometryFlagBitsKHR;
  VkGeometryFlagBitsNV   = Int32;
  PVkGeometryFlagBitsNV  =  ^VkGeometryFlagBitsNV;
  PPVkGeometryFlagBitsNV = ^PVkGeometryFlagBitsNV;
  VkGeometryInstanceFlagBitsKHR   = Int32;
  PVkGeometryInstanceFlagBitsKHR  =  ^VkGeometryInstanceFlagBitsKHR;
  PPVkGeometryInstanceFlagBitsKHR = ^PVkGeometryInstanceFlagBitsKHR;
  VkGeometryInstanceFlagBitsNV   = Int32;
  PVkGeometryInstanceFlagBitsNV  =  ^VkGeometryInstanceFlagBitsNV;
  PPVkGeometryInstanceFlagBitsNV = ^PVkGeometryInstanceFlagBitsNV;
  VkBuildAccelerationStructureFlagBitsKHR   = Int32;
  PVkBuildAccelerationStructureFlagBitsKHR  =  ^VkBuildAccelerationStructureFlagBitsKHR;
  PPVkBuildAccelerationStructureFlagBitsKHR = ^PVkBuildAccelerationStructureFlagBitsKHR;
  VkBuildAccelerationStructureFlagBitsNV   = Int32;
  PVkBuildAccelerationStructureFlagBitsNV  =  ^VkBuildAccelerationStructureFlagBitsNV;
  PPVkBuildAccelerationStructureFlagBitsNV = ^PVkBuildAccelerationStructureFlagBitsNV;
  VkAccelerationStructureCreateFlagBitsKHR   = Int32;
  PVkAccelerationStructureCreateFlagBitsKHR  =  ^VkAccelerationStructureCreateFlagBitsKHR;
  PPVkAccelerationStructureCreateFlagBitsKHR = ^PVkAccelerationStructureCreateFlagBitsKHR;
  VkBuildAccelerationStructureModeKHR   = Int32;
  PVkBuildAccelerationStructureModeKHR  =  ^VkBuildAccelerationStructureModeKHR;
  PPVkBuildAccelerationStructureModeKHR = ^PVkBuildAccelerationStructureModeKHR;
  VkCopyAccelerationStructureModeKHR   = Int32;
  PVkCopyAccelerationStructureModeKHR  =  ^VkCopyAccelerationStructureModeKHR;
  PPVkCopyAccelerationStructureModeKHR = ^PVkCopyAccelerationStructureModeKHR;
  VkCopyAccelerationStructureModeNV   = Int32;
  PVkCopyAccelerationStructureModeNV  =  ^VkCopyAccelerationStructureModeNV;
  PPVkCopyAccelerationStructureModeNV = ^PVkCopyAccelerationStructureModeNV;
  VkAccelerationStructureTypeKHR   = Int32;
  PVkAccelerationStructureTypeKHR  =  ^VkAccelerationStructureTypeKHR;
  PPVkAccelerationStructureTypeKHR = ^PVkAccelerationStructureTypeKHR;
  VkAccelerationStructureTypeNV   = Int32;
  PVkAccelerationStructureTypeNV  =  ^VkAccelerationStructureTypeNV;
  PPVkAccelerationStructureTypeNV = ^PVkAccelerationStructureTypeNV;
  VkGeometryTypeKHR   = Int32;
  PVkGeometryTypeKHR  =  ^VkGeometryTypeKHR;
  PPVkGeometryTypeKHR = ^PVkGeometryTypeKHR;
  VkGeometryTypeNV   = Int32;
  PVkGeometryTypeNV  =  ^VkGeometryTypeNV;
  PPVkGeometryTypeNV = ^PVkGeometryTypeNV;
  VkRayTracingShaderGroupTypeKHR   = Int32;
  PVkRayTracingShaderGroupTypeKHR  =  ^VkRayTracingShaderGroupTypeKHR;
  PPVkRayTracingShaderGroupTypeKHR = ^PVkRayTracingShaderGroupTypeKHR;
  VkRayTracingShaderGroupTypeNV   = Int32;
  PVkRayTracingShaderGroupTypeNV  =  ^VkRayTracingShaderGroupTypeNV;
  PPVkRayTracingShaderGroupTypeNV = ^PVkRayTracingShaderGroupTypeNV;
  VkAccelerationStructureMemoryRequirementsTypeNV   = Int32;
  PVkAccelerationStructureMemoryRequirementsTypeNV  =  ^VkAccelerationStructureMemoryRequirementsTypeNV;
  PPVkAccelerationStructureMemoryRequirementsTypeNV = ^PVkAccelerationStructureMemoryRequirementsTypeNV;
  VkAccelerationStructureBuildTypeKHR   = Int32;
  PVkAccelerationStructureBuildTypeKHR  =  ^VkAccelerationStructureBuildTypeKHR;
  PPVkAccelerationStructureBuildTypeKHR = ^PVkAccelerationStructureBuildTypeKHR;
  VkAccelerationStructureCompatibilityKHR   = Int32;
  PVkAccelerationStructureCompatibilityKHR  =  ^VkAccelerationStructureCompatibilityKHR;
  PPVkAccelerationStructureCompatibilityKHR = ^PVkAccelerationStructureCompatibilityKHR;
  VkShaderGroupShaderKHR   = Int32;
  PVkShaderGroupShaderKHR  =  ^VkShaderGroupShaderKHR;
  PPVkShaderGroupShaderKHR = ^PVkShaderGroupShaderKHR;
  VkMemoryOverallocationBehaviorAMD   = Int32;
  PVkMemoryOverallocationBehaviorAMD  =  ^VkMemoryOverallocationBehaviorAMD;
  PPVkMemoryOverallocationBehaviorAMD = ^PVkMemoryOverallocationBehaviorAMD;
  VkScopeNV   = Int32;
  PVkScopeNV  =  ^VkScopeNV;
  PPVkScopeNV = ^PVkScopeNV;
  VkComponentTypeNV   = Int32;
  PVkComponentTypeNV  =  ^VkComponentTypeNV;
  PPVkComponentTypeNV = ^PVkComponentTypeNV;
  VkDeviceDiagnosticsConfigFlagBitsNV   = Int32;
  PVkDeviceDiagnosticsConfigFlagBitsNV  =  ^VkDeviceDiagnosticsConfigFlagBitsNV;
  PPVkDeviceDiagnosticsConfigFlagBitsNV = ^PVkDeviceDiagnosticsConfigFlagBitsNV;
  VkPipelineCreationFeedbackFlagBitsEXT   = Int32;
  PVkPipelineCreationFeedbackFlagBitsEXT  =  ^VkPipelineCreationFeedbackFlagBitsEXT;
  PPVkPipelineCreationFeedbackFlagBitsEXT = ^PVkPipelineCreationFeedbackFlagBitsEXT;
  VkPerformanceCounterScopeKHR   = Int32;
  PVkPerformanceCounterScopeKHR  =  ^VkPerformanceCounterScopeKHR;
  PPVkPerformanceCounterScopeKHR = ^PVkPerformanceCounterScopeKHR;
  VkPerformanceCounterUnitKHR   = Int32;
  PVkPerformanceCounterUnitKHR  =  ^VkPerformanceCounterUnitKHR;
  PPVkPerformanceCounterUnitKHR = ^PVkPerformanceCounterUnitKHR;
  VkPerformanceCounterStorageKHR   = Int32;
  PVkPerformanceCounterStorageKHR  =  ^VkPerformanceCounterStorageKHR;
  PPVkPerformanceCounterStorageKHR = ^PVkPerformanceCounterStorageKHR;
  VkPerformanceCounterDescriptionFlagBitsKHR   = Int32;
  PVkPerformanceCounterDescriptionFlagBitsKHR  =  ^VkPerformanceCounterDescriptionFlagBitsKHR;
  PPVkPerformanceCounterDescriptionFlagBitsKHR = ^PVkPerformanceCounterDescriptionFlagBitsKHR;
  VkAcquireProfilingLockFlagBitsKHR   = Int32;
  PVkAcquireProfilingLockFlagBitsKHR  =  ^VkAcquireProfilingLockFlagBitsKHR;
  PPVkAcquireProfilingLockFlagBitsKHR = ^PVkAcquireProfilingLockFlagBitsKHR;
  VkSemaphoreWaitFlagBits   = Int32;
  PVkSemaphoreWaitFlagBits  =  ^VkSemaphoreWaitFlagBits;
  PPVkSemaphoreWaitFlagBits = ^PVkSemaphoreWaitFlagBits;
  VkSemaphoreWaitFlagBitsKHR   = Int32;
  PVkSemaphoreWaitFlagBitsKHR  =  ^VkSemaphoreWaitFlagBitsKHR;
  PPVkSemaphoreWaitFlagBitsKHR = ^PVkSemaphoreWaitFlagBitsKHR;
  VkPerformanceConfigurationTypeINTEL   = Int32;
  PVkPerformanceConfigurationTypeINTEL  =  ^VkPerformanceConfigurationTypeINTEL;
  PPVkPerformanceConfigurationTypeINTEL = ^PVkPerformanceConfigurationTypeINTEL;
  VkQueryPoolSamplingModeINTEL   = Int32;
  PVkQueryPoolSamplingModeINTEL  =  ^VkQueryPoolSamplingModeINTEL;
  PPVkQueryPoolSamplingModeINTEL = ^PVkQueryPoolSamplingModeINTEL;
  VkPerformanceOverrideTypeINTEL   = Int32;
  PVkPerformanceOverrideTypeINTEL  =  ^VkPerformanceOverrideTypeINTEL;
  PPVkPerformanceOverrideTypeINTEL = ^PVkPerformanceOverrideTypeINTEL;
  VkPerformanceParameterTypeINTEL   = Int32;
  PVkPerformanceParameterTypeINTEL  =  ^VkPerformanceParameterTypeINTEL;
  PPVkPerformanceParameterTypeINTEL = ^PVkPerformanceParameterTypeINTEL;
  VkPerformanceValueTypeINTEL   = Int32;
  PVkPerformanceValueTypeINTEL  =  ^VkPerformanceValueTypeINTEL;
  PPVkPerformanceValueTypeINTEL = ^PVkPerformanceValueTypeINTEL;
  VkLineRasterizationModeEXT   = Int32;
  PVkLineRasterizationModeEXT  =  ^VkLineRasterizationModeEXT;
  PPVkLineRasterizationModeEXT = ^PVkLineRasterizationModeEXT;
  VkShaderModuleCreateFlagBits   = Int32;
  PVkShaderModuleCreateFlagBits  =  ^VkShaderModuleCreateFlagBits;
  PPVkShaderModuleCreateFlagBits = ^PVkShaderModuleCreateFlagBits;
  VkPipelineCompilerControlFlagBitsAMD   = Int32;
  PVkPipelineCompilerControlFlagBitsAMD  =  ^VkPipelineCompilerControlFlagBitsAMD;
  PPVkPipelineCompilerControlFlagBitsAMD = ^PVkPipelineCompilerControlFlagBitsAMD;
  VkShaderCorePropertiesFlagBitsAMD   = Int32;
  PVkShaderCorePropertiesFlagBitsAMD  =  ^VkShaderCorePropertiesFlagBitsAMD;
  PPVkShaderCorePropertiesFlagBitsAMD = ^PVkShaderCorePropertiesFlagBitsAMD;
  VkToolPurposeFlagBitsEXT   = Int32;
  PVkToolPurposeFlagBitsEXT  =  ^VkToolPurposeFlagBitsEXT;
  PPVkToolPurposeFlagBitsEXT = ^PVkToolPurposeFlagBitsEXT;
  VkFragmentShadingRateNV   = Int32;
  PVkFragmentShadingRateNV  =  ^VkFragmentShadingRateNV;
  PPVkFragmentShadingRateNV = ^PVkFragmentShadingRateNV;
  VkFragmentShadingRateTypeNV   = Int32;
  PVkFragmentShadingRateTypeNV  =  ^VkFragmentShadingRateTypeNV;
  PPVkFragmentShadingRateTypeNV = ^PVkFragmentShadingRateTypeNV;
  VkAccessFlagBits2KHR   = Int32;
  PVkAccessFlagBits2KHR  =  ^VkAccessFlagBits2KHR;
  PPVkAccessFlagBits2KHR = ^PVkAccessFlagBits2KHR;
  VkPipelineStageFlagBits2KHR   = Int32;
  PVkPipelineStageFlagBits2KHR  =  ^VkPipelineStageFlagBits2KHR;
  PPVkPipelineStageFlagBits2KHR = ^PVkPipelineStageFlagBits2KHR;
  VkProvokingVertexModeEXT   = Int32;
  PVkProvokingVertexModeEXT  =  ^VkProvokingVertexModeEXT;
  PPVkProvokingVertexModeEXT = ^PVkProvokingVertexModeEXT;
  VkColorSpaceKHR   = Int32;
  PVkColorSpaceKHR  =  ^VkColorSpaceKHR;
  PPVkColorSpaceKHR = ^PVkColorSpaceKHR;
  VkCompositeAlphaFlagBitsKHR   = Int32;
  PVkCompositeAlphaFlagBitsKHR  =  ^VkCompositeAlphaFlagBitsKHR;
  PPVkCompositeAlphaFlagBitsKHR = ^PVkCompositeAlphaFlagBitsKHR;
  VkDisplayPlaneAlphaFlagBitsKHR   = Int32;
  PVkDisplayPlaneAlphaFlagBitsKHR  =  ^VkDisplayPlaneAlphaFlagBitsKHR;
  PPVkDisplayPlaneAlphaFlagBitsKHR = ^PVkDisplayPlaneAlphaFlagBitsKHR;
  VkPresentModeKHR   = Int32;
  PVkPresentModeKHR  =  ^VkPresentModeKHR;
  PPVkPresentModeKHR = ^PVkPresentModeKHR;
  VkSurfaceTransformFlagBitsKHR   = Int32;
  PVkSurfaceTransformFlagBitsKHR  =  ^VkSurfaceTransformFlagBitsKHR;
  PPVkSurfaceTransformFlagBitsKHR = ^PVkSurfaceTransformFlagBitsKHR;
  VkDebugReportFlagBitsEXT   = Int32;
  PVkDebugReportFlagBitsEXT  =  ^VkDebugReportFlagBitsEXT;
  PPVkDebugReportFlagBitsEXT = ^PVkDebugReportFlagBitsEXT;
  VkDebugReportObjectTypeEXT   = Int32;
  PVkDebugReportObjectTypeEXT  =  ^VkDebugReportObjectTypeEXT;
  PPVkDebugReportObjectTypeEXT = ^PVkDebugReportObjectTypeEXT;
  VkDeviceMemoryReportEventTypeEXT   = Int32;
  PVkDeviceMemoryReportEventTypeEXT  =  ^VkDeviceMemoryReportEventTypeEXT;
  PPVkDeviceMemoryReportEventTypeEXT = ^PVkDeviceMemoryReportEventTypeEXT;
  VkRasterizationOrderAMD   = Int32;
  PVkRasterizationOrderAMD  =  ^VkRasterizationOrderAMD;
  PPVkRasterizationOrderAMD = ^PVkRasterizationOrderAMD;
  VkExternalMemoryHandleTypeFlagBitsNV   = Int32;
  PVkExternalMemoryHandleTypeFlagBitsNV  =  ^VkExternalMemoryHandleTypeFlagBitsNV;
  PPVkExternalMemoryHandleTypeFlagBitsNV = ^PVkExternalMemoryHandleTypeFlagBitsNV;
  VkExternalMemoryFeatureFlagBitsNV   = Int32;
  PVkExternalMemoryFeatureFlagBitsNV  =  ^VkExternalMemoryFeatureFlagBitsNV;
  PPVkExternalMemoryFeatureFlagBitsNV = ^PVkExternalMemoryFeatureFlagBitsNV;
  VkValidationCheckEXT   = Int32;
  PVkValidationCheckEXT  =  ^VkValidationCheckEXT;
  PPVkValidationCheckEXT = ^PVkValidationCheckEXT;
  VkValidationFeatureEnableEXT   = Int32;
  PVkValidationFeatureEnableEXT  =  ^VkValidationFeatureEnableEXT;
  PPVkValidationFeatureEnableEXT = ^PVkValidationFeatureEnableEXT;
  VkValidationFeatureDisableEXT   = Int32;
  PVkValidationFeatureDisableEXT  =  ^VkValidationFeatureDisableEXT;
  PPVkValidationFeatureDisableEXT = ^PVkValidationFeatureDisableEXT;
  VkExternalMemoryHandleTypeFlagBits   = Int32;
  PVkExternalMemoryHandleTypeFlagBits  =  ^VkExternalMemoryHandleTypeFlagBits;
  PPVkExternalMemoryHandleTypeFlagBits = ^PVkExternalMemoryHandleTypeFlagBits;
  VkExternalMemoryHandleTypeFlagBitsKHR   = Int32;
  PVkExternalMemoryHandleTypeFlagBitsKHR  =  ^VkExternalMemoryHandleTypeFlagBitsKHR;
  PPVkExternalMemoryHandleTypeFlagBitsKHR = ^PVkExternalMemoryHandleTypeFlagBitsKHR;
  VkExternalMemoryFeatureFlagBits   = Int32;
  PVkExternalMemoryFeatureFlagBits  =  ^VkExternalMemoryFeatureFlagBits;
  PPVkExternalMemoryFeatureFlagBits = ^PVkExternalMemoryFeatureFlagBits;
  VkExternalMemoryFeatureFlagBitsKHR   = Int32;
  PVkExternalMemoryFeatureFlagBitsKHR  =  ^VkExternalMemoryFeatureFlagBitsKHR;
  PPVkExternalMemoryFeatureFlagBitsKHR = ^PVkExternalMemoryFeatureFlagBitsKHR;
  VkExternalSemaphoreHandleTypeFlagBits   = Int32;
  PVkExternalSemaphoreHandleTypeFlagBits  =  ^VkExternalSemaphoreHandleTypeFlagBits;
  PPVkExternalSemaphoreHandleTypeFlagBits = ^PVkExternalSemaphoreHandleTypeFlagBits;
  VkExternalSemaphoreHandleTypeFlagBitsKHR   = Int32;
  PVkExternalSemaphoreHandleTypeFlagBitsKHR  =  ^VkExternalSemaphoreHandleTypeFlagBitsKHR;
  PPVkExternalSemaphoreHandleTypeFlagBitsKHR = ^PVkExternalSemaphoreHandleTypeFlagBitsKHR;
  VkExternalSemaphoreFeatureFlagBits   = Int32;
  PVkExternalSemaphoreFeatureFlagBits  =  ^VkExternalSemaphoreFeatureFlagBits;
  PPVkExternalSemaphoreFeatureFlagBits = ^PVkExternalSemaphoreFeatureFlagBits;
  VkExternalSemaphoreFeatureFlagBitsKHR   = Int32;
  PVkExternalSemaphoreFeatureFlagBitsKHR  =  ^VkExternalSemaphoreFeatureFlagBitsKHR;
  PPVkExternalSemaphoreFeatureFlagBitsKHR = ^PVkExternalSemaphoreFeatureFlagBitsKHR;
  VkSemaphoreImportFlagBits   = Int32;
  PVkSemaphoreImportFlagBits  =  ^VkSemaphoreImportFlagBits;
  PPVkSemaphoreImportFlagBits = ^PVkSemaphoreImportFlagBits;
  VkSemaphoreImportFlagBitsKHR   = Int32;
  PVkSemaphoreImportFlagBitsKHR  =  ^VkSemaphoreImportFlagBitsKHR;
  PPVkSemaphoreImportFlagBitsKHR = ^PVkSemaphoreImportFlagBitsKHR;
  VkExternalFenceHandleTypeFlagBits   = Int32;
  PVkExternalFenceHandleTypeFlagBits  =  ^VkExternalFenceHandleTypeFlagBits;
  PPVkExternalFenceHandleTypeFlagBits = ^PVkExternalFenceHandleTypeFlagBits;
  VkExternalFenceHandleTypeFlagBitsKHR   = Int32;
  PVkExternalFenceHandleTypeFlagBitsKHR  =  ^VkExternalFenceHandleTypeFlagBitsKHR;
  PPVkExternalFenceHandleTypeFlagBitsKHR = ^PVkExternalFenceHandleTypeFlagBitsKHR;
  VkExternalFenceFeatureFlagBits   = Int32;
  PVkExternalFenceFeatureFlagBits  =  ^VkExternalFenceFeatureFlagBits;
  PPVkExternalFenceFeatureFlagBits = ^PVkExternalFenceFeatureFlagBits;
  VkExternalFenceFeatureFlagBitsKHR   = Int32;
  PVkExternalFenceFeatureFlagBitsKHR  =  ^VkExternalFenceFeatureFlagBitsKHR;
  PPVkExternalFenceFeatureFlagBitsKHR = ^PVkExternalFenceFeatureFlagBitsKHR;
  VkFenceImportFlagBits   = Int32;
  PVkFenceImportFlagBits  =  ^VkFenceImportFlagBits;
  PPVkFenceImportFlagBits = ^PVkFenceImportFlagBits;
  VkFenceImportFlagBitsKHR   = Int32;
  PVkFenceImportFlagBitsKHR  =  ^VkFenceImportFlagBitsKHR;
  PPVkFenceImportFlagBitsKHR = ^PVkFenceImportFlagBitsKHR;
  VkSurfaceCounterFlagBitsEXT   = Int32;
  PVkSurfaceCounterFlagBitsEXT  =  ^VkSurfaceCounterFlagBitsEXT;
  PPVkSurfaceCounterFlagBitsEXT = ^PVkSurfaceCounterFlagBitsEXT;
  VkDisplayPowerStateEXT   = Int32;
  PVkDisplayPowerStateEXT  =  ^VkDisplayPowerStateEXT;
  PPVkDisplayPowerStateEXT = ^PVkDisplayPowerStateEXT;
  VkDeviceEventTypeEXT   = Int32;
  PVkDeviceEventTypeEXT  =  ^VkDeviceEventTypeEXT;
  PPVkDeviceEventTypeEXT = ^PVkDeviceEventTypeEXT;
  VkDisplayEventTypeEXT   = Int32;
  PVkDisplayEventTypeEXT  =  ^VkDisplayEventTypeEXT;
  PPVkDisplayEventTypeEXT = ^PVkDisplayEventTypeEXT;
  VkPeerMemoryFeatureFlagBits   = Int32;
  PVkPeerMemoryFeatureFlagBits  =  ^VkPeerMemoryFeatureFlagBits;
  PPVkPeerMemoryFeatureFlagBits = ^PVkPeerMemoryFeatureFlagBits;
  VkPeerMemoryFeatureFlagBitsKHR   = Int32;
  PVkPeerMemoryFeatureFlagBitsKHR  =  ^VkPeerMemoryFeatureFlagBitsKHR;
  PPVkPeerMemoryFeatureFlagBitsKHR = ^PVkPeerMemoryFeatureFlagBitsKHR;
  VkMemoryAllocateFlagBits   = Int32;
  PVkMemoryAllocateFlagBits  =  ^VkMemoryAllocateFlagBits;
  PPVkMemoryAllocateFlagBits = ^PVkMemoryAllocateFlagBits;
  VkMemoryAllocateFlagBitsKHR   = Int32;
  PVkMemoryAllocateFlagBitsKHR  =  ^VkMemoryAllocateFlagBitsKHR;
  PPVkMemoryAllocateFlagBitsKHR = ^PVkMemoryAllocateFlagBitsKHR;
  VkDeviceGroupPresentModeFlagBitsKHR   = Int32;
  PVkDeviceGroupPresentModeFlagBitsKHR  =  ^VkDeviceGroupPresentModeFlagBitsKHR;
  PPVkDeviceGroupPresentModeFlagBitsKHR = ^PVkDeviceGroupPresentModeFlagBitsKHR;
  VkSwapchainCreateFlagBitsKHR   = Int32;
  PVkSwapchainCreateFlagBitsKHR  =  ^VkSwapchainCreateFlagBitsKHR;
  PPVkSwapchainCreateFlagBitsKHR = ^PVkSwapchainCreateFlagBitsKHR;
  VkSubgroupFeatureFlagBits   = Int32;
  PVkSubgroupFeatureFlagBits  =  ^VkSubgroupFeatureFlagBits;
  PPVkSubgroupFeatureFlagBits = ^PVkSubgroupFeatureFlagBits;
  VkTessellationDomainOrigin   = Int32;
  PVkTessellationDomainOrigin  =  ^VkTessellationDomainOrigin;
  PPVkTessellationDomainOrigin = ^PVkTessellationDomainOrigin;
  VkTessellationDomainOriginKHR   = Int32;
  PVkTessellationDomainOriginKHR  =  ^VkTessellationDomainOriginKHR;
  PPVkTessellationDomainOriginKHR = ^PVkTessellationDomainOriginKHR;
  VkSamplerYcbcrModelConversion   = Int32;
  PVkSamplerYcbcrModelConversion  =  ^VkSamplerYcbcrModelConversion;
  PPVkSamplerYcbcrModelConversion = ^PVkSamplerYcbcrModelConversion;
  VkSamplerYcbcrModelConversionKHR   = Int32;
  PVkSamplerYcbcrModelConversionKHR  =  ^VkSamplerYcbcrModelConversionKHR;
  PPVkSamplerYcbcrModelConversionKHR = ^PVkSamplerYcbcrModelConversionKHR;
  VkSamplerYcbcrRange   = Int32;
  PVkSamplerYcbcrRange  =  ^VkSamplerYcbcrRange;
  PPVkSamplerYcbcrRange = ^PVkSamplerYcbcrRange;
  VkSamplerYcbcrRangeKHR   = Int32;
  PVkSamplerYcbcrRangeKHR  =  ^VkSamplerYcbcrRangeKHR;
  PPVkSamplerYcbcrRangeKHR = ^PVkSamplerYcbcrRangeKHR;
  VkChromaLocation   = Int32;
  PVkChromaLocation  =  ^VkChromaLocation;
  PPVkChromaLocation = ^PVkChromaLocation;
  VkChromaLocationKHR   = Int32;
  PVkChromaLocationKHR  =  ^VkChromaLocationKHR;
  PPVkChromaLocationKHR = ^PVkChromaLocationKHR;
  VkSamplerReductionMode   = Int32;
  PVkSamplerReductionMode  =  ^VkSamplerReductionMode;
  PPVkSamplerReductionMode = ^PVkSamplerReductionMode;
  VkSamplerReductionModeEXT   = Int32;
  PVkSamplerReductionModeEXT  =  ^VkSamplerReductionModeEXT;
  PPVkSamplerReductionModeEXT = ^PVkSamplerReductionModeEXT;
  VkBlendOverlapEXT   = Int32;
  PVkBlendOverlapEXT  =  ^VkBlendOverlapEXT;
  PPVkBlendOverlapEXT = ^PVkBlendOverlapEXT;
  VkDebugUtilsMessageSeverityFlagBitsEXT   = Int32;
  PVkDebugUtilsMessageSeverityFlagBitsEXT  =  ^VkDebugUtilsMessageSeverityFlagBitsEXT;
  PPVkDebugUtilsMessageSeverityFlagBitsEXT = ^PVkDebugUtilsMessageSeverityFlagBitsEXT;
  VkDebugUtilsMessageTypeFlagBitsEXT   = Int32;
  PVkDebugUtilsMessageTypeFlagBitsEXT  =  ^VkDebugUtilsMessageTypeFlagBitsEXT;
  PPVkDebugUtilsMessageTypeFlagBitsEXT = ^PVkDebugUtilsMessageTypeFlagBitsEXT;
  VkFullScreenExclusiveEXT   = Int32;
  PVkFullScreenExclusiveEXT  =  ^VkFullScreenExclusiveEXT;
  PPVkFullScreenExclusiveEXT = ^PVkFullScreenExclusiveEXT;
  VkShaderFloatControlsIndependence   = Int32;
  PVkShaderFloatControlsIndependence  =  ^VkShaderFloatControlsIndependence;
  PPVkShaderFloatControlsIndependence = ^PVkShaderFloatControlsIndependence;
  VkShaderFloatControlsIndependenceKHR   = Int32;
  PVkShaderFloatControlsIndependenceKHR  =  ^VkShaderFloatControlsIndependenceKHR;
  PPVkShaderFloatControlsIndependenceKHR = ^PVkShaderFloatControlsIndependenceKHR;
  VkSwapchainImageUsageFlagBitsANDROID   = Int32;
  PVkSwapchainImageUsageFlagBitsANDROID  =  ^VkSwapchainImageUsageFlagBitsANDROID;
  PPVkSwapchainImageUsageFlagBitsANDROID = ^PVkSwapchainImageUsageFlagBitsANDROID;
  VkFragmentShadingRateCombinerOpKHR   = Int32;
  PVkFragmentShadingRateCombinerOpKHR  =  ^VkFragmentShadingRateCombinerOpKHR;
  PPVkFragmentShadingRateCombinerOpKHR = ^PVkFragmentShadingRateCombinerOpKHR;
  VkSubmitFlagBitsKHR   = Int32;
  PVkSubmitFlagBitsKHR  =  ^VkSubmitFlagBitsKHR;
  PPVkSubmitFlagBitsKHR = ^PVkSubmitFlagBitsKHR;
  VkVendorId   = Int32;
  PVkVendorId  =  ^VkVendorId;
  PPVkVendorId = ^PVkVendorId;
  VkDriverId   = Int32;
  PVkDriverId  =  ^VkDriverId;
  PPVkDriverId = ^PVkDriverId;
  VkDriverIdKHR   = Int32;
  PVkDriverIdKHR  =  ^VkDriverIdKHR;
  PPVkDriverIdKHR = ^PVkDriverIdKHR;
  VkShadingRatePaletteEntryNV   = Int32;
  PVkShadingRatePaletteEntryNV  =  ^VkShadingRatePaletteEntryNV;
  PPVkShadingRatePaletteEntryNV = ^PVkShadingRatePaletteEntryNV;
  VkCoarseSampleOrderTypeNV   = Int32;
  PVkCoarseSampleOrderTypeNV  =  ^VkCoarseSampleOrderTypeNV;
  PPVkCoarseSampleOrderTypeNV = ^PVkCoarseSampleOrderTypeNV;
  VkPipelineExecutableStatisticFormatKHR   = Int32;
  PVkPipelineExecutableStatisticFormatKHR  =  ^VkPipelineExecutableStatisticFormatKHR;
  PPVkPipelineExecutableStatisticFormatKHR = ^PVkPipelineExecutableStatisticFormatKHR;
  VkVideoCodecOperationFlagBitsKHR   = Int32;
  PVkVideoCodecOperationFlagBitsKHR  =  ^VkVideoCodecOperationFlagBitsKHR;
  PPVkVideoCodecOperationFlagBitsKHR = ^PVkVideoCodecOperationFlagBitsKHR;
  VkVideoChromaSubsamplingFlagBitsKHR   = Int32;
  PVkVideoChromaSubsamplingFlagBitsKHR  =  ^VkVideoChromaSubsamplingFlagBitsKHR;
  PPVkVideoChromaSubsamplingFlagBitsKHR = ^PVkVideoChromaSubsamplingFlagBitsKHR;
  VkVideoComponentBitDepthFlagBitsKHR   = Int32;
  PVkVideoComponentBitDepthFlagBitsKHR  =  ^VkVideoComponentBitDepthFlagBitsKHR;
  PPVkVideoComponentBitDepthFlagBitsKHR = ^PVkVideoComponentBitDepthFlagBitsKHR;
  VkVideoCapabilityFlagBitsKHR   = Int32;
  PVkVideoCapabilityFlagBitsKHR  =  ^VkVideoCapabilityFlagBitsKHR;
  PPVkVideoCapabilityFlagBitsKHR = ^PVkVideoCapabilityFlagBitsKHR;
  VkVideoSessionCreateFlagBitsKHR   = Int32;
  PVkVideoSessionCreateFlagBitsKHR  =  ^VkVideoSessionCreateFlagBitsKHR;
  PPVkVideoSessionCreateFlagBitsKHR = ^PVkVideoSessionCreateFlagBitsKHR;
  VkVideoCodingQualityPresetFlagBitsKHR   = Int32;
  PVkVideoCodingQualityPresetFlagBitsKHR  =  ^VkVideoCodingQualityPresetFlagBitsKHR;
  PPVkVideoCodingQualityPresetFlagBitsKHR = ^PVkVideoCodingQualityPresetFlagBitsKHR;
  VkVideoCodingControlFlagBitsKHR   = Int32;
  PVkVideoCodingControlFlagBitsKHR  =  ^VkVideoCodingControlFlagBitsKHR;
  PPVkVideoCodingControlFlagBitsKHR = ^PVkVideoCodingControlFlagBitsKHR;
  VkQueryResultStatusKHR   = Int32;
  PVkQueryResultStatusKHR  =  ^VkQueryResultStatusKHR;
  PPVkQueryResultStatusKHR = ^PVkQueryResultStatusKHR;
  VkVideoDecodeFlagBitsKHR   = Int32;
  PVkVideoDecodeFlagBitsKHR  =  ^VkVideoDecodeFlagBitsKHR;
  PPVkVideoDecodeFlagBitsKHR = ^PVkVideoDecodeFlagBitsKHR;
  VkVideoDecodeH264PictureLayoutFlagBitsEXT   = Int32;
  PVkVideoDecodeH264PictureLayoutFlagBitsEXT  =  ^VkVideoDecodeH264PictureLayoutFlagBitsEXT;
  PPVkVideoDecodeH264PictureLayoutFlagBitsEXT = ^PVkVideoDecodeH264PictureLayoutFlagBitsEXT;
  VkVideoEncodeFlagBitsKHR   = Int32;
  PVkVideoEncodeFlagBitsKHR  =  ^VkVideoEncodeFlagBitsKHR;
  PPVkVideoEncodeFlagBitsKHR = ^PVkVideoEncodeFlagBitsKHR;
  VkVideoEncodeRateControlFlagBitsKHR   = Int32;
  PVkVideoEncodeRateControlFlagBitsKHR  =  ^VkVideoEncodeRateControlFlagBitsKHR;
  PPVkVideoEncodeRateControlFlagBitsKHR = ^PVkVideoEncodeRateControlFlagBitsKHR;
  VkVideoEncodeRateControlModeFlagBitsKHR   = Int32;
  PVkVideoEncodeRateControlModeFlagBitsKHR  =  ^VkVideoEncodeRateControlModeFlagBitsKHR;
  PPVkVideoEncodeRateControlModeFlagBitsKHR = ^PVkVideoEncodeRateControlModeFlagBitsKHR;
  VkVideoEncodeH264CapabilityFlagBitsEXT   = Int32;
  PVkVideoEncodeH264CapabilityFlagBitsEXT  =  ^VkVideoEncodeH264CapabilityFlagBitsEXT;
  PPVkVideoEncodeH264CapabilityFlagBitsEXT = ^PVkVideoEncodeH264CapabilityFlagBitsEXT;
  VkVideoEncodeH264InputModeFlagBitsEXT   = Int32;
  PVkVideoEncodeH264InputModeFlagBitsEXT  =  ^VkVideoEncodeH264InputModeFlagBitsEXT;
  PPVkVideoEncodeH264InputModeFlagBitsEXT = ^PVkVideoEncodeH264InputModeFlagBitsEXT;
  VkVideoEncodeH264OutputModeFlagBitsEXT   = Int32;
  PVkVideoEncodeH264OutputModeFlagBitsEXT  =  ^VkVideoEncodeH264OutputModeFlagBitsEXT;
  PPVkVideoEncodeH264OutputModeFlagBitsEXT = ^PVkVideoEncodeH264OutputModeFlagBitsEXT;
  VkVideoEncodeH264CreateFlagBitsEXT   = Int32;
  PVkVideoEncodeH264CreateFlagBitsEXT  =  ^VkVideoEncodeH264CreateFlagBitsEXT;
  PPVkVideoEncodeH264CreateFlagBitsEXT = ^PVkVideoEncodeH264CreateFlagBitsEXT;
  PFN_vkVoidFunction   = Pointer;
  PPFN_vkVoidFunction  =  ^PFN_vkVoidFunction;
  PPPFN_vkVoidFunction = ^PPFN_vkVoidFunction;
  VkAccelerationStructureMotionInstanceTypeNV   = Int32;
  PVkAccelerationStructureMotionInstanceTypeNV  =  ^VkAccelerationStructureMotionInstanceTypeNV;
  PPVkAccelerationStructureMotionInstanceTypeNV = ^PVkAccelerationStructureMotionInstanceTypeNV;
  VkRemoteAddressNV   = Pointer;
  PVkRemoteAddressNV  =  ^VkRemoteAddressNV;
  PPVkRemoteAddressNV = ^PVkRemoteAddressNV;

const
  VK_MAX_PHYSICAL_DEVICE_NAME_SIZE = 256;
  VK_UUID_SIZE = 16;
  VK_LUID_SIZE = 8;
  VK_MAX_EXTENSION_NAME_SIZE = 256;
  VK_MAX_DESCRIPTION_SIZE = 256;
  VK_MAX_MEMORY_TYPES = 32;
  VK_MAX_MEMORY_HEAPS = 16;
  VK_LOD_CLAMP_NONE = 1000.0;
  VK_REMAINING_MIP_LEVELS = High(UInt32);
  VK_REMAINING_ARRAY_LAYERS = High(UInt32);
  VK_WHOLE_SIZE = High(UInt64);
  VK_ATTACHMENT_UNUSED = High(UInt32);
  VK_TRUE = 1;
  VK_FALSE = 0;
  VK_QUEUE_FAMILY_IGNORED = High(UInt32);
  VK_QUEUE_FAMILY_EXTERNAL = not UInt32(1);
  VK_QUEUE_FAMILY_FOREIGN_EXT = not UInt32(2);
  VK_SUBPASS_EXTERNAL = High(UInt32);
  VK_MAX_DEVICE_GROUP_SIZE = 32;
  VK_MAX_DRIVER_NAME_SIZE = 256;
  VK_MAX_DRIVER_INFO_SIZE = 256;
  VK_SHADER_UNUSED_KHR = High(UInt32);
  VK_MAX_GLOBAL_PRIORITY_SIZE_EXT = 16;
  VK_IMAGE_LAYOUT_UNDEFINED = 0;
  VK_IMAGE_LAYOUT_GENERAL = 1;
  VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL = 2;
  VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL = 3;
  VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL = 4;
  VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL = 5;
  VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL = 6;
  VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL = 7;
  VK_IMAGE_LAYOUT_PREINITIALIZED = 8;
  VK_ATTACHMENT_LOAD_OP_LOAD = 0;
  VK_ATTACHMENT_LOAD_OP_CLEAR = 1;
  VK_ATTACHMENT_LOAD_OP_DONT_CARE = 2;
  VK_ATTACHMENT_STORE_OP_STORE = 0;
  VK_ATTACHMENT_STORE_OP_DONT_CARE = 1;
  VK_IMAGE_TYPE_1D = 0;
  VK_IMAGE_TYPE_2D = 1;
  VK_IMAGE_TYPE_3D = 2;
  VK_IMAGE_TILING_OPTIMAL = 0;
  VK_IMAGE_TILING_LINEAR = 1;
  VK_IMAGE_VIEW_TYPE_1D = 0;
  VK_IMAGE_VIEW_TYPE_2D = 1;
  VK_IMAGE_VIEW_TYPE_3D = 2;
  VK_IMAGE_VIEW_TYPE_CUBE = 3;
  VK_IMAGE_VIEW_TYPE_1D_ARRAY = 4;
  VK_IMAGE_VIEW_TYPE_2D_ARRAY = 5;
  VK_IMAGE_VIEW_TYPE_CUBE_ARRAY = 6;
  VK_COMMAND_BUFFER_LEVEL_PRIMARY = 0;
  VK_COMMAND_BUFFER_LEVEL_SECONDARY = 1;
  VK_COMPONENT_SWIZZLE_IDENTITY = 0;
  VK_COMPONENT_SWIZZLE_ZERO = 1;
  VK_COMPONENT_SWIZZLE_ONE = 2;
  VK_COMPONENT_SWIZZLE_R = 3;
  VK_COMPONENT_SWIZZLE_G = 4;
  VK_COMPONENT_SWIZZLE_B = 5;
  VK_COMPONENT_SWIZZLE_A = 6;
  VK_DESCRIPTOR_TYPE_SAMPLER = 0;
  VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER = 1;
  VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE = 2;
  VK_DESCRIPTOR_TYPE_STORAGE_IMAGE = 3;
  VK_DESCRIPTOR_TYPE_UNIFORM_TEXEL_BUFFER = 4;
  VK_DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER = 5;
  VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER = 6;
  VK_DESCRIPTOR_TYPE_STORAGE_BUFFER = 7;
  VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC = 8;
  VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC = 9;
  VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT = 10;
  VK_QUERY_TYPE_OCCLUSION = 0;
  VK_QUERY_TYPE_PIPELINE_STATISTICS = 1;
  VK_QUERY_TYPE_TIMESTAMP = 2;
  VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK = 0;
  VK_BORDER_COLOR_INT_TRANSPARENT_BLACK = 1;
  VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK = 2;
  VK_BORDER_COLOR_INT_OPAQUE_BLACK = 3;
  VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE = 4;
  VK_BORDER_COLOR_INT_OPAQUE_WHITE = 5;
  VK_PIPELINE_BIND_POINT_GRAPHICS = 0;
  VK_PIPELINE_BIND_POINT_COMPUTE = 1;
  VK_PIPELINE_CACHE_HEADER_VERSION_ONE = 1;
  VK_PRIMITIVE_TOPOLOGY_POINT_LIST = 0;
  VK_PRIMITIVE_TOPOLOGY_LINE_LIST = 1;
  VK_PRIMITIVE_TOPOLOGY_LINE_STRIP = 2;
  VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST = 3;
  VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP = 4;
  VK_PRIMITIVE_TOPOLOGY_TRIANGLE_FAN = 5;
  VK_PRIMITIVE_TOPOLOGY_LINE_LIST_WITH_ADJACENCY = 6;
  VK_PRIMITIVE_TOPOLOGY_LINE_STRIP_WITH_ADJACENCY = 7;
  VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST_WITH_ADJACENCY = 8;
  VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP_WITH_ADJACENCY = 9;
  VK_PRIMITIVE_TOPOLOGY_PATCH_LIST = 10;
  VK_SHARING_MODE_EXCLUSIVE = 0;
  VK_SHARING_MODE_CONCURRENT = 1;
  VK_INDEX_TYPE_UINT16 = 0;
  VK_INDEX_TYPE_UINT32 = 1;
  VK_FILTER_NEAREST = 0;
  VK_FILTER_LINEAR = 1;
  VK_SAMPLER_MIPMAP_MODE_NEAREST = 0;
  VK_SAMPLER_MIPMAP_MODE_LINEAR = 1;
  VK_SAMPLER_ADDRESS_MODE_REPEAT = 0;
  VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT = 1;
  VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE = 2;
  VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER = 3;
  VK_COMPARE_OP_NEVER = 0;
  VK_COMPARE_OP_LESS = 1;
  VK_COMPARE_OP_EQUAL = 2;
  VK_COMPARE_OP_LESS_OR_EQUAL = 3;
  VK_COMPARE_OP_GREATER = 4;
  VK_COMPARE_OP_NOT_EQUAL = 5;
  VK_COMPARE_OP_GREATER_OR_EQUAL = 6;
  VK_COMPARE_OP_ALWAYS = 7;
  VK_POLYGON_MODE_FILL = 0;
  VK_POLYGON_MODE_LINE = 1;
  VK_POLYGON_MODE_POINT = 2;
  VK_FRONT_FACE_COUNTER_CLOCKWISE = 0;
  VK_FRONT_FACE_CLOCKWISE = 1;
  VK_BLEND_FACTOR_ZERO = 0;
  VK_BLEND_FACTOR_ONE = 1;
  VK_BLEND_FACTOR_SRC_COLOR = 2;
  VK_BLEND_FACTOR_ONE_MINUS_SRC_COLOR = 3;
  VK_BLEND_FACTOR_DST_COLOR = 4;
  VK_BLEND_FACTOR_ONE_MINUS_DST_COLOR = 5;
  VK_BLEND_FACTOR_SRC_ALPHA = 6;
  VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA = 7;
  VK_BLEND_FACTOR_DST_ALPHA = 8;
  VK_BLEND_FACTOR_ONE_MINUS_DST_ALPHA = 9;
  VK_BLEND_FACTOR_CONSTANT_COLOR = 10;
  VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_COLOR = 11;
  VK_BLEND_FACTOR_CONSTANT_ALPHA = 12;
  VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_ALPHA = 13;
  VK_BLEND_FACTOR_SRC_ALPHA_SATURATE = 14;
  VK_BLEND_FACTOR_SRC1_COLOR = 15;
  VK_BLEND_FACTOR_ONE_MINUS_SRC1_COLOR = 16;
  VK_BLEND_FACTOR_SRC1_ALPHA = 17;
  VK_BLEND_FACTOR_ONE_MINUS_SRC1_ALPHA = 18;
  VK_BLEND_OP_ADD = 0;
  VK_BLEND_OP_SUBTRACT = 1;
  VK_BLEND_OP_REVERSE_SUBTRACT = 2;
  VK_BLEND_OP_MIN = 3;
  VK_BLEND_OP_MAX = 4;
  VK_STENCIL_OP_KEEP = 0;
  VK_STENCIL_OP_ZERO = 1;
  VK_STENCIL_OP_REPLACE = 2;
  VK_STENCIL_OP_INCREMENT_AND_CLAMP = 3;
  VK_STENCIL_OP_DECREMENT_AND_CLAMP = 4;
  VK_STENCIL_OP_INVERT = 5;
  VK_STENCIL_OP_INCREMENT_AND_WRAP = 6;
  VK_STENCIL_OP_DECREMENT_AND_WRAP = 7;
  VK_LOGIC_OP_CLEAR = 0;
  VK_LOGIC_OP_AND = 1;
  VK_LOGIC_OP_AND_REVERSE = 2;
  VK_LOGIC_OP_COPY = 3;
  VK_LOGIC_OP_AND_INVERTED = 4;
  VK_LOGIC_OP_NO_OP = 5;
  VK_LOGIC_OP_XOR = 6;
  VK_LOGIC_OP_OR = 7;
  VK_LOGIC_OP_NOR = 8;
  VK_LOGIC_OP_EQUIVALENT = 9;
  VK_LOGIC_OP_INVERT = 10;
  VK_LOGIC_OP_OR_REVERSE = 11;
  VK_LOGIC_OP_COPY_INVERTED = 12;
  VK_LOGIC_OP_OR_INVERTED = 13;
  VK_LOGIC_OP_NAND = 14;
  VK_LOGIC_OP_SET = 15;
  VK_INTERNAL_ALLOCATION_TYPE_EXECUTABLE = 0;
  VK_SYSTEM_ALLOCATION_SCOPE_COMMAND = 0;
  VK_SYSTEM_ALLOCATION_SCOPE_OBJECT = 1;
  VK_SYSTEM_ALLOCATION_SCOPE_CACHE = 2;
  VK_SYSTEM_ALLOCATION_SCOPE_DEVICE = 3;
  VK_SYSTEM_ALLOCATION_SCOPE_INSTANCE = 4;
  VK_PHYSICAL_DEVICE_TYPE_OTHER = 0;
  VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU = 1;
  VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU = 2;
  VK_PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU = 3;
  VK_PHYSICAL_DEVICE_TYPE_CPU = 4;
  VK_VERTEX_INPUT_RATE_VERTEX = 0;
  VK_VERTEX_INPUT_RATE_INSTANCE = 1;
  VK_FORMAT_UNDEFINED = 0;
  VK_FORMAT_R4G4_UNORM_PACK8 = 1;
  VK_FORMAT_R4G4B4A4_UNORM_PACK16 = 2;
  VK_FORMAT_B4G4R4A4_UNORM_PACK16 = 3;
  VK_FORMAT_R5G6B5_UNORM_PACK16 = 4;
  VK_FORMAT_B5G6R5_UNORM_PACK16 = 5;
  VK_FORMAT_R5G5B5A1_UNORM_PACK16 = 6;
  VK_FORMAT_B5G5R5A1_UNORM_PACK16 = 7;
  VK_FORMAT_A1R5G5B5_UNORM_PACK16 = 8;
  VK_FORMAT_R8_UNORM = 9;
  VK_FORMAT_R8_SNORM = 10;
  VK_FORMAT_R8_USCALED = 11;
  VK_FORMAT_R8_SSCALED = 12;
  VK_FORMAT_R8_UINT = 13;
  VK_FORMAT_R8_SINT = 14;
  VK_FORMAT_R8_SRGB = 15;
  VK_FORMAT_R8G8_UNORM = 16;
  VK_FORMAT_R8G8_SNORM = 17;
  VK_FORMAT_R8G8_USCALED = 18;
  VK_FORMAT_R8G8_SSCALED = 19;
  VK_FORMAT_R8G8_UINT = 20;
  VK_FORMAT_R8G8_SINT = 21;
  VK_FORMAT_R8G8_SRGB = 22;
  VK_FORMAT_R8G8B8_UNORM = 23;
  VK_FORMAT_R8G8B8_SNORM = 24;
  VK_FORMAT_R8G8B8_USCALED = 25;
  VK_FORMAT_R8G8B8_SSCALED = 26;
  VK_FORMAT_R8G8B8_UINT = 27;
  VK_FORMAT_R8G8B8_SINT = 28;
  VK_FORMAT_R8G8B8_SRGB = 29;
  VK_FORMAT_B8G8R8_UNORM = 30;
  VK_FORMAT_B8G8R8_SNORM = 31;
  VK_FORMAT_B8G8R8_USCALED = 32;
  VK_FORMAT_B8G8R8_SSCALED = 33;
  VK_FORMAT_B8G8R8_UINT = 34;
  VK_FORMAT_B8G8R8_SINT = 35;
  VK_FORMAT_B8G8R8_SRGB = 36;
  VK_FORMAT_R8G8B8A8_UNORM = 37;
  VK_FORMAT_R8G8B8A8_SNORM = 38;
  VK_FORMAT_R8G8B8A8_USCALED = 39;
  VK_FORMAT_R8G8B8A8_SSCALED = 40;
  VK_FORMAT_R8G8B8A8_UINT = 41;
  VK_FORMAT_R8G8B8A8_SINT = 42;
  VK_FORMAT_R8G8B8A8_SRGB = 43;
  VK_FORMAT_B8G8R8A8_UNORM = 44;
  VK_FORMAT_B8G8R8A8_SNORM = 45;
  VK_FORMAT_B8G8R8A8_USCALED = 46;
  VK_FORMAT_B8G8R8A8_SSCALED = 47;
  VK_FORMAT_B8G8R8A8_UINT = 48;
  VK_FORMAT_B8G8R8A8_SINT = 49;
  VK_FORMAT_B8G8R8A8_SRGB = 50;
  VK_FORMAT_A8B8G8R8_UNORM_PACK32 = 51;
  VK_FORMAT_A8B8G8R8_SNORM_PACK32 = 52;
  VK_FORMAT_A8B8G8R8_USCALED_PACK32 = 53;
  VK_FORMAT_A8B8G8R8_SSCALED_PACK32 = 54;
  VK_FORMAT_A8B8G8R8_UINT_PACK32 = 55;
  VK_FORMAT_A8B8G8R8_SINT_PACK32 = 56;
  VK_FORMAT_A8B8G8R8_SRGB_PACK32 = 57;
  VK_FORMAT_A2R10G10B10_UNORM_PACK32 = 58;
  VK_FORMAT_A2R10G10B10_SNORM_PACK32 = 59;
  VK_FORMAT_A2R10G10B10_USCALED_PACK32 = 60;
  VK_FORMAT_A2R10G10B10_SSCALED_PACK32 = 61;
  VK_FORMAT_A2R10G10B10_UINT_PACK32 = 62;
  VK_FORMAT_A2R10G10B10_SINT_PACK32 = 63;
  VK_FORMAT_A2B10G10R10_UNORM_PACK32 = 64;
  VK_FORMAT_A2B10G10R10_SNORM_PACK32 = 65;
  VK_FORMAT_A2B10G10R10_USCALED_PACK32 = 66;
  VK_FORMAT_A2B10G10R10_SSCALED_PACK32 = 67;
  VK_FORMAT_A2B10G10R10_UINT_PACK32 = 68;
  VK_FORMAT_A2B10G10R10_SINT_PACK32 = 69;
  VK_FORMAT_R16_UNORM = 70;
  VK_FORMAT_R16_SNORM = 71;
  VK_FORMAT_R16_USCALED = 72;
  VK_FORMAT_R16_SSCALED = 73;
  VK_FORMAT_R16_UINT = 74;
  VK_FORMAT_R16_SINT = 75;
  VK_FORMAT_R16_SFLOAT = 76;
  VK_FORMAT_R16G16_UNORM = 77;
  VK_FORMAT_R16G16_SNORM = 78;
  VK_FORMAT_R16G16_USCALED = 79;
  VK_FORMAT_R16G16_SSCALED = 80;
  VK_FORMAT_R16G16_UINT = 81;
  VK_FORMAT_R16G16_SINT = 82;
  VK_FORMAT_R16G16_SFLOAT = 83;
  VK_FORMAT_R16G16B16_UNORM = 84;
  VK_FORMAT_R16G16B16_SNORM = 85;
  VK_FORMAT_R16G16B16_USCALED = 86;
  VK_FORMAT_R16G16B16_SSCALED = 87;
  VK_FORMAT_R16G16B16_UINT = 88;
  VK_FORMAT_R16G16B16_SINT = 89;
  VK_FORMAT_R16G16B16_SFLOAT = 90;
  VK_FORMAT_R16G16B16A16_UNORM = 91;
  VK_FORMAT_R16G16B16A16_SNORM = 92;
  VK_FORMAT_R16G16B16A16_USCALED = 93;
  VK_FORMAT_R16G16B16A16_SSCALED = 94;
  VK_FORMAT_R16G16B16A16_UINT = 95;
  VK_FORMAT_R16G16B16A16_SINT = 96;
  VK_FORMAT_R16G16B16A16_SFLOAT = 97;
  VK_FORMAT_R32_UINT = 98;
  VK_FORMAT_R32_SINT = 99;
  VK_FORMAT_R32_SFLOAT = 100;
  VK_FORMAT_R32G32_UINT = 101;
  VK_FORMAT_R32G32_SINT = 102;
  VK_FORMAT_R32G32_SFLOAT = 103;
  VK_FORMAT_R32G32B32_UINT = 104;
  VK_FORMAT_R32G32B32_SINT = 105;
  VK_FORMAT_R32G32B32_SFLOAT = 106;
  VK_FORMAT_R32G32B32A32_UINT = 107;
  VK_FORMAT_R32G32B32A32_SINT = 108;
  VK_FORMAT_R32G32B32A32_SFLOAT = 109;
  VK_FORMAT_R64_UINT = 110;
  VK_FORMAT_R64_SINT = 111;
  VK_FORMAT_R64_SFLOAT = 112;
  VK_FORMAT_R64G64_UINT = 113;
  VK_FORMAT_R64G64_SINT = 114;
  VK_FORMAT_R64G64_SFLOAT = 115;
  VK_FORMAT_R64G64B64_UINT = 116;
  VK_FORMAT_R64G64B64_SINT = 117;
  VK_FORMAT_R64G64B64_SFLOAT = 118;
  VK_FORMAT_R64G64B64A64_UINT = 119;
  VK_FORMAT_R64G64B64A64_SINT = 120;
  VK_FORMAT_R64G64B64A64_SFLOAT = 121;
  VK_FORMAT_B10G11R11_UFLOAT_PACK32 = 122;
  VK_FORMAT_E5B9G9R9_UFLOAT_PACK32 = 123;
  VK_FORMAT_D16_UNORM = 124;
  VK_FORMAT_X8_D24_UNORM_PACK32 = 125;
  VK_FORMAT_D32_SFLOAT = 126;
  VK_FORMAT_S8_UINT = 127;
  VK_FORMAT_D16_UNORM_S8_UINT = 128;
  VK_FORMAT_D24_UNORM_S8_UINT = 129;
  VK_FORMAT_D32_SFLOAT_S8_UINT = 130;
  VK_FORMAT_BC1_RGB_UNORM_BLOCK = 131;
  VK_FORMAT_BC1_RGB_SRGB_BLOCK = 132;
  VK_FORMAT_BC1_RGBA_UNORM_BLOCK = 133;
  VK_FORMAT_BC1_RGBA_SRGB_BLOCK = 134;
  VK_FORMAT_BC2_UNORM_BLOCK = 135;
  VK_FORMAT_BC2_SRGB_BLOCK = 136;
  VK_FORMAT_BC3_UNORM_BLOCK = 137;
  VK_FORMAT_BC3_SRGB_BLOCK = 138;
  VK_FORMAT_BC4_UNORM_BLOCK = 139;
  VK_FORMAT_BC4_SNORM_BLOCK = 140;
  VK_FORMAT_BC5_UNORM_BLOCK = 141;
  VK_FORMAT_BC5_SNORM_BLOCK = 142;
  VK_FORMAT_BC6H_UFLOAT_BLOCK = 143;
  VK_FORMAT_BC6H_SFLOAT_BLOCK = 144;
  VK_FORMAT_BC7_UNORM_BLOCK = 145;
  VK_FORMAT_BC7_SRGB_BLOCK = 146;
  VK_FORMAT_ETC2_R8G8B8_UNORM_BLOCK = 147;
  VK_FORMAT_ETC2_R8G8B8_SRGB_BLOCK = 148;
  VK_FORMAT_ETC2_R8G8B8A1_UNORM_BLOCK = 149;
  VK_FORMAT_ETC2_R8G8B8A1_SRGB_BLOCK = 150;
  VK_FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK = 151;
  VK_FORMAT_ETC2_R8G8B8A8_SRGB_BLOCK = 152;
  VK_FORMAT_EAC_R11_UNORM_BLOCK = 153;
  VK_FORMAT_EAC_R11_SNORM_BLOCK = 154;
  VK_FORMAT_EAC_R11G11_UNORM_BLOCK = 155;
  VK_FORMAT_EAC_R11G11_SNORM_BLOCK = 156;
  VK_FORMAT_ASTC_4x4_UNORM_BLOCK = 157;
  VK_FORMAT_ASTC_4x4_SRGB_BLOCK = 158;
  VK_FORMAT_ASTC_5x4_UNORM_BLOCK = 159;
  VK_FORMAT_ASTC_5x4_SRGB_BLOCK = 160;
  VK_FORMAT_ASTC_5x5_UNORM_BLOCK = 161;
  VK_FORMAT_ASTC_5x5_SRGB_BLOCK = 162;
  VK_FORMAT_ASTC_6x5_UNORM_BLOCK = 163;
  VK_FORMAT_ASTC_6x5_SRGB_BLOCK = 164;
  VK_FORMAT_ASTC_6x6_UNORM_BLOCK = 165;
  VK_FORMAT_ASTC_6x6_SRGB_BLOCK = 166;
  VK_FORMAT_ASTC_8x5_UNORM_BLOCK = 167;
  VK_FORMAT_ASTC_8x5_SRGB_BLOCK = 168;
  VK_FORMAT_ASTC_8x6_UNORM_BLOCK = 169;
  VK_FORMAT_ASTC_8x6_SRGB_BLOCK = 170;
  VK_FORMAT_ASTC_8x8_UNORM_BLOCK = 171;
  VK_FORMAT_ASTC_8x8_SRGB_BLOCK = 172;
  VK_FORMAT_ASTC_10x5_UNORM_BLOCK = 173;
  VK_FORMAT_ASTC_10x5_SRGB_BLOCK = 174;
  VK_FORMAT_ASTC_10x6_UNORM_BLOCK = 175;
  VK_FORMAT_ASTC_10x6_SRGB_BLOCK = 176;
  VK_FORMAT_ASTC_10x8_UNORM_BLOCK = 177;
  VK_FORMAT_ASTC_10x8_SRGB_BLOCK = 178;
  VK_FORMAT_ASTC_10x10_UNORM_BLOCK = 179;
  VK_FORMAT_ASTC_10x10_SRGB_BLOCK = 180;
  VK_FORMAT_ASTC_12x10_UNORM_BLOCK = 181;
  VK_FORMAT_ASTC_12x10_SRGB_BLOCK = 182;
  VK_FORMAT_ASTC_12x12_UNORM_BLOCK = 183;
  VK_FORMAT_ASTC_12x12_SRGB_BLOCK = 184;
  VK_STRUCTURE_TYPE_APPLICATION_INFO = 0;
  VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO = 1;
  VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO = 2;
  VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO = 3;
  VK_STRUCTURE_TYPE_SUBMIT_INFO = 4;
  VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO = 5;
  VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE = 6;
  VK_STRUCTURE_TYPE_BIND_SPARSE_INFO = 7;
  VK_STRUCTURE_TYPE_FENCE_CREATE_INFO = 8;
  VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO = 9;
  VK_STRUCTURE_TYPE_EVENT_CREATE_INFO = 10;
  VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO = 11;
  VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO = 12;
  VK_STRUCTURE_TYPE_BUFFER_VIEW_CREATE_INFO = 13;
  VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO = 14;
  VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO = 15;
  VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO = 16;
  VK_STRUCTURE_TYPE_PIPELINE_CACHE_CREATE_INFO = 17;
  VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO = 18;
  VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO = 19;
  VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO = 20;
  VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_STATE_CREATE_INFO = 21;
  VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO = 22;
  VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO = 23;
  VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO = 24;
  VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO = 25;
  VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO = 26;
  VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO = 27;
  VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO = 28;
  VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO = 29;
  VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO = 30;
  VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO = 31;
  VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO = 32;
  VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO = 33;
  VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO = 34;
  VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET = 35;
  VK_STRUCTURE_TYPE_COPY_DESCRIPTOR_SET = 36;
  VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO = 37;
  VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO = 38;
  VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO = 39;
  VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO = 40;
  VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_INFO = 41;
  VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO = 42;
  VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO = 43;
  VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER = 44;
  VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER = 45;
  VK_STRUCTURE_TYPE_MEMORY_BARRIER = 46;
  VK_STRUCTURE_TYPE_LOADER_INSTANCE_CREATE_INFO = 47;
  VK_STRUCTURE_TYPE_LOADER_DEVICE_CREATE_INFO = 48;
  VK_SUBPASS_CONTENTS_INLINE = 0;
  VK_SUBPASS_CONTENTS_SECONDARY_COMMAND_BUFFERS = 1;
  VK_SUCCESS = 0;
  VK_NOT_READY = 1;
  VK_TIMEOUT = 2;
  VK_EVENT_SET = 3;
  VK_EVENT_RESET = 4;
  VK_INCOMPLETE = 5;
  VK_ERROR_OUT_OF_HOST_MEMORY = -1;
  VK_ERROR_OUT_OF_DEVICE_MEMORY = -2;
  VK_ERROR_INITIALIZATION_FAILED = -3;
  VK_ERROR_DEVICE_LOST = -4;
  VK_ERROR_MEMORY_MAP_FAILED = -5;
  VK_ERROR_LAYER_NOT_PRESENT = -6;
  VK_ERROR_EXTENSION_NOT_PRESENT = -7;
  VK_ERROR_FEATURE_NOT_PRESENT = -8;
  VK_ERROR_INCOMPATIBLE_DRIVER = -9;
  VK_ERROR_TOO_MANY_OBJECTS = -10;
  VK_ERROR_FORMAT_NOT_SUPPORTED = -11;
  VK_ERROR_FRAGMENTED_POOL = -12;
  VK_ERROR_UNKNOWN = -13;
  VK_DYNAMIC_STATE_VIEWPORT = 0;
  VK_DYNAMIC_STATE_SCISSOR = 1;
  VK_DYNAMIC_STATE_LINE_WIDTH = 2;
  VK_DYNAMIC_STATE_DEPTH_BIAS = 3;
  VK_DYNAMIC_STATE_BLEND_CONSTANTS = 4;
  VK_DYNAMIC_STATE_DEPTH_BOUNDS = 5;
  VK_DYNAMIC_STATE_STENCIL_COMPARE_MASK = 6;
  VK_DYNAMIC_STATE_STENCIL_WRITE_MASK = 7;
  VK_DYNAMIC_STATE_STENCIL_REFERENCE = 8;
  VK_DESCRIPTOR_UPDATE_TEMPLATE_TYPE_DESCRIPTOR_SET = 0;
  VK_OBJECT_TYPE_UNKNOWN = 0;
  VK_OBJECT_TYPE_INSTANCE = 1;
  VK_OBJECT_TYPE_PHYSICAL_DEVICE = 2;
  VK_OBJECT_TYPE_DEVICE = 3;
  VK_OBJECT_TYPE_QUEUE = 4;
  VK_OBJECT_TYPE_SEMAPHORE = 5;
  VK_OBJECT_TYPE_COMMAND_BUFFER = 6;
  VK_OBJECT_TYPE_FENCE = 7;
  VK_OBJECT_TYPE_DEVICE_MEMORY = 8;
  VK_OBJECT_TYPE_BUFFER = 9;
  VK_OBJECT_TYPE_IMAGE = 10;
  VK_OBJECT_TYPE_EVENT = 11;
  VK_OBJECT_TYPE_QUERY_POOL = 12;
  VK_OBJECT_TYPE_BUFFER_VIEW = 13;
  VK_OBJECT_TYPE_IMAGE_VIEW = 14;
  VK_OBJECT_TYPE_SHADER_MODULE = 15;
  VK_OBJECT_TYPE_PIPELINE_CACHE = 16;
  VK_OBJECT_TYPE_PIPELINE_LAYOUT = 17;
  VK_OBJECT_TYPE_RENDER_PASS = 18;
  VK_OBJECT_TYPE_PIPELINE = 19;
  VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT = 20;
  VK_OBJECT_TYPE_SAMPLER = 21;
  VK_OBJECT_TYPE_DESCRIPTOR_POOL = 22;
  VK_OBJECT_TYPE_DESCRIPTOR_SET = 23;
  VK_OBJECT_TYPE_FRAMEBUFFER = 24;
  VK_OBJECT_TYPE_COMMAND_POOL = 25;
  VK_QUEUE_GRAPHICS_BIT = 1 shl 0;
  VK_QUEUE_COMPUTE_BIT = 1 shl 1;
  VK_QUEUE_TRANSFER_BIT = 1 shl 2;
  VK_QUEUE_SPARSE_BINDING_BIT = 1 shl 3;
  VK_CULL_MODE_NONE = 0;
  VK_CULL_MODE_FRONT_BIT = 1 shl 0;
  VK_CULL_MODE_BACK_BIT = 1 shl 1;
  VK_CULL_MODE_FRONT_AND_BACK = $00000003;
  VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT = 1 shl 0;
  VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT = 1 shl 1;
  VK_MEMORY_PROPERTY_HOST_COHERENT_BIT = 1 shl 2;
  VK_MEMORY_PROPERTY_HOST_CACHED_BIT = 1 shl 3;
  VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT = 1 shl 4;
  VK_MEMORY_HEAP_DEVICE_LOCAL_BIT = 1 shl 0;
  VK_ACCESS_INDIRECT_COMMAND_READ_BIT = 1 shl 0;
  VK_ACCESS_INDEX_READ_BIT = 1 shl 1;
  VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT = 1 shl 2;
  VK_ACCESS_UNIFORM_READ_BIT = 1 shl 3;
  VK_ACCESS_INPUT_ATTACHMENT_READ_BIT = 1 shl 4;
  VK_ACCESS_SHADER_READ_BIT = 1 shl 5;
  VK_ACCESS_SHADER_WRITE_BIT = 1 shl 6;
  VK_ACCESS_COLOR_ATTACHMENT_READ_BIT = 1 shl 7;
  VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT = 1 shl 8;
  VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT = 1 shl 9;
  VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT = 1 shl 10;
  VK_ACCESS_TRANSFER_READ_BIT = 1 shl 11;
  VK_ACCESS_TRANSFER_WRITE_BIT = 1 shl 12;
  VK_ACCESS_HOST_READ_BIT = 1 shl 13;
  VK_ACCESS_HOST_WRITE_BIT = 1 shl 14;
  VK_ACCESS_MEMORY_READ_BIT = 1 shl 15;
  VK_ACCESS_MEMORY_WRITE_BIT = 1 shl 16;
  VK_BUFFER_USAGE_TRANSFER_SRC_BIT = 1 shl 0;
  VK_BUFFER_USAGE_TRANSFER_DST_BIT = 1 shl 1;
  VK_BUFFER_USAGE_UNIFORM_TEXEL_BUFFER_BIT = 1 shl 2;
  VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT = 1 shl 3;
  VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT = 1 shl 4;
  VK_BUFFER_USAGE_STORAGE_BUFFER_BIT = 1 shl 5;
  VK_BUFFER_USAGE_INDEX_BUFFER_BIT = 1 shl 6;
  VK_BUFFER_USAGE_VERTEX_BUFFER_BIT = 1 shl 7;
  VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT = 1 shl 8;
  VK_BUFFER_CREATE_SPARSE_BINDING_BIT = 1 shl 0;
  VK_BUFFER_CREATE_SPARSE_RESIDENCY_BIT = 1 shl 1;
  VK_BUFFER_CREATE_SPARSE_ALIASED_BIT = 1 shl 2;
  VK_SHADER_STAGE_VERTEX_BIT = 1 shl 0;
  VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT = 1 shl 1;
  VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT = 1 shl 2;
  VK_SHADER_STAGE_GEOMETRY_BIT = 1 shl 3;
  VK_SHADER_STAGE_FRAGMENT_BIT = 1 shl 4;
  VK_SHADER_STAGE_COMPUTE_BIT = 1 shl 5;
  VK_SHADER_STAGE_ALL_GRAPHICS = $0000001F;
  VK_SHADER_STAGE_ALL = $7FFFFFFF;
  VK_IMAGE_USAGE_TRANSFER_SRC_BIT = 1 shl 0;
  VK_IMAGE_USAGE_TRANSFER_DST_BIT = 1 shl 1;
  VK_IMAGE_USAGE_SAMPLED_BIT = 1 shl 2;
  VK_IMAGE_USAGE_STORAGE_BIT = 1 shl 3;
  VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT = 1 shl 4;
  VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT = 1 shl 5;
  VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT = 1 shl 6;
  VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT = 1 shl 7;
  VK_IMAGE_CREATE_SPARSE_BINDING_BIT = 1 shl 0;
  VK_IMAGE_CREATE_SPARSE_RESIDENCY_BIT = 1 shl 1;
  VK_IMAGE_CREATE_SPARSE_ALIASED_BIT = 1 shl 2;
  VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT = 1 shl 3;
  VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT = 1 shl 4;
  VK_PIPELINE_CREATE_DISABLE_OPTIMIZATION_BIT = 1 shl 0;
  VK_PIPELINE_CREATE_ALLOW_DERIVATIVES_BIT = 1 shl 1;
  VK_PIPELINE_CREATE_DERIVATIVE_BIT = 1 shl 2;
  VK_COLOR_COMPONENT_R_BIT = 1 shl 0;
  VK_COLOR_COMPONENT_G_BIT = 1 shl 1;
  VK_COLOR_COMPONENT_B_BIT = 1 shl 2;
  VK_COLOR_COMPONENT_A_BIT = 1 shl 3;
  VK_FENCE_CREATE_SIGNALED_BIT = 1 shl 0;
  VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT = 1 shl 0;
  VK_FORMAT_FEATURE_STORAGE_IMAGE_BIT = 1 shl 1;
  VK_FORMAT_FEATURE_STORAGE_IMAGE_ATOMIC_BIT = 1 shl 2;
  VK_FORMAT_FEATURE_UNIFORM_TEXEL_BUFFER_BIT = 1 shl 3;
  VK_FORMAT_FEATURE_STORAGE_TEXEL_BUFFER_BIT = 1 shl 4;
  VK_FORMAT_FEATURE_STORAGE_TEXEL_BUFFER_ATOMIC_BIT = 1 shl 5;
  VK_FORMAT_FEATURE_VERTEX_BUFFER_BIT = 1 shl 6;
  VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BIT = 1 shl 7;
  VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BLEND_BIT = 1 shl 8;
  VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT = 1 shl 9;
  VK_FORMAT_FEATURE_BLIT_SRC_BIT = 1 shl 10;
  VK_FORMAT_FEATURE_BLIT_DST_BIT = 1 shl 11;
  VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT = 1 shl 12;
  VK_QUERY_CONTROL_PRECISE_BIT = 1 shl 0;
  VK_QUERY_RESULT_64_BIT = 1 shl 0;
  VK_QUERY_RESULT_WAIT_BIT = 1 shl 1;
  VK_QUERY_RESULT_WITH_AVAILABILITY_BIT = 1 shl 2;
  VK_QUERY_RESULT_PARTIAL_BIT = 1 shl 3;
  VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT = 1 shl 0;
  VK_COMMAND_BUFFER_USAGE_RENDER_PASS_CONTINUE_BIT = 1 shl 1;
  VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT = 1 shl 2;
  VK_QUERY_PIPELINE_STATISTIC_INPUT_ASSEMBLY_VERTICES_BIT = 1 shl 0;
  VK_QUERY_PIPELINE_STATISTIC_INPUT_ASSEMBLY_PRIMITIVES_BIT = 1 shl 1;
  VK_QUERY_PIPELINE_STATISTIC_VERTEX_SHADER_INVOCATIONS_BIT = 1 shl 2;
  VK_QUERY_PIPELINE_STATISTIC_GEOMETRY_SHADER_INVOCATIONS_BIT = 1 shl 3;
  VK_QUERY_PIPELINE_STATISTIC_GEOMETRY_SHADER_PRIMITIVES_BIT = 1 shl 4;
  VK_QUERY_PIPELINE_STATISTIC_CLIPPING_INVOCATIONS_BIT = 1 shl 5;
  VK_QUERY_PIPELINE_STATISTIC_CLIPPING_PRIMITIVES_BIT = 1 shl 6;
  VK_QUERY_PIPELINE_STATISTIC_FRAGMENT_SHADER_INVOCATIONS_BIT = 1 shl 7;
  VK_QUERY_PIPELINE_STATISTIC_TESSELLATION_CONTROL_SHADER_PATCHES_BIT = 1 shl 8;
  VK_QUERY_PIPELINE_STATISTIC_TESSELLATION_EVALUATION_SHADER_INVOCATIONS_BIT = 1 shl 9;
  VK_QUERY_PIPELINE_STATISTIC_COMPUTE_SHADER_INVOCATIONS_BIT = 1 shl 10;
  VK_IMAGE_ASPECT_COLOR_BIT = 1 shl 0;
  VK_IMAGE_ASPECT_DEPTH_BIT = 1 shl 1;
  VK_IMAGE_ASPECT_STENCIL_BIT = 1 shl 2;
  VK_IMAGE_ASPECT_METADATA_BIT = 1 shl 3;
  VK_SPARSE_IMAGE_FORMAT_SINGLE_MIPTAIL_BIT = 1 shl 0;
  VK_SPARSE_IMAGE_FORMAT_ALIGNED_MIP_SIZE_BIT = 1 shl 1;
  VK_SPARSE_IMAGE_FORMAT_NONSTANDARD_BLOCK_SIZE_BIT = 1 shl 2;
  VK_SPARSE_MEMORY_BIND_METADATA_BIT = 1 shl 0;
  VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT = 1 shl 0;
  VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT = 1 shl 1;
  VK_PIPELINE_STAGE_VERTEX_INPUT_BIT = 1 shl 2;
  VK_PIPELINE_STAGE_VERTEX_SHADER_BIT = 1 shl 3;
  VK_PIPELINE_STAGE_TESSELLATION_CONTROL_SHADER_BIT = 1 shl 4;
  VK_PIPELINE_STAGE_TESSELLATION_EVALUATION_SHADER_BIT = 1 shl 5;
  VK_PIPELINE_STAGE_GEOMETRY_SHADER_BIT = 1 shl 6;
  VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT = 1 shl 7;
  VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT = 1 shl 8;
  VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT = 1 shl 9;
  VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT = 1 shl 10;
  VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT = 1 shl 11;
  VK_PIPELINE_STAGE_TRANSFER_BIT = 1 shl 12;
  VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT = 1 shl 13;
  VK_PIPELINE_STAGE_HOST_BIT = 1 shl 14;
  VK_PIPELINE_STAGE_ALL_GRAPHICS_BIT = 1 shl 15;
  VK_PIPELINE_STAGE_ALL_COMMANDS_BIT = 1 shl 16;
  VK_COMMAND_POOL_CREATE_TRANSIENT_BIT = 1 shl 0;
  VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT = 1 shl 1;
  VK_COMMAND_POOL_RESET_RELEASE_RESOURCES_BIT = 1 shl 0;
  VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT = 1 shl 0;
  VK_SAMPLE_COUNT_1_BIT = 1 shl 0;
  VK_SAMPLE_COUNT_2_BIT = 1 shl 1;
  VK_SAMPLE_COUNT_4_BIT = 1 shl 2;
  VK_SAMPLE_COUNT_8_BIT = 1 shl 3;
  VK_SAMPLE_COUNT_16_BIT = 1 shl 4;
  VK_SAMPLE_COUNT_32_BIT = 1 shl 5;
  VK_SAMPLE_COUNT_64_BIT = 1 shl 6;
  VK_ATTACHMENT_DESCRIPTION_MAY_ALIAS_BIT = 1 shl 0;
  VK_STENCIL_FACE_FRONT_BIT = 1 shl 0;
  VK_STENCIL_FACE_BACK_BIT = 1 shl 1;
  VK_STENCIL_FACE_FRONT_AND_BACK = $00000003;
  VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT = 1 shl 0;
  VK_DEPENDENCY_BY_REGION_BIT = 1 shl 0;
  VK_SEMAPHORE_TYPE_BINARY = 0;
  VK_SEMAPHORE_TYPE_TIMELINE = 1;
  VK_SEMAPHORE_WAIT_ANY_BIT = 1 shl 0;
  VK_PRESENT_MODE_IMMEDIATE_KHR = 0;
  VK_PRESENT_MODE_MAILBOX_KHR = 1;
  VK_PRESENT_MODE_FIFO_KHR = 2;
  VK_PRESENT_MODE_FIFO_RELAXED_KHR = 3;
  VK_COLOR_SPACE_SRGB_NONLINEAR_KHR = 0;
  VK_DISPLAY_PLANE_ALPHA_OPAQUE_BIT_KHR = 1 shl 0;
  VK_DISPLAY_PLANE_ALPHA_GLOBAL_BIT_KHR = 1 shl 1;
  VK_DISPLAY_PLANE_ALPHA_PER_PIXEL_BIT_KHR = 1 shl 2;
  VK_DISPLAY_PLANE_ALPHA_PER_PIXEL_PREMULTIPLIED_BIT_KHR = 1 shl 3;
  VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR = 1 shl 0;
  VK_COMPOSITE_ALPHA_PRE_MULTIPLIED_BIT_KHR = 1 shl 1;
  VK_COMPOSITE_ALPHA_POST_MULTIPLIED_BIT_KHR = 1 shl 2;
  VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR = 1 shl 3;
  VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR = 1 shl 0;
  VK_SURFACE_TRANSFORM_ROTATE_90_BIT_KHR = 1 shl 1;
  VK_SURFACE_TRANSFORM_ROTATE_180_BIT_KHR = 1 shl 2;
  VK_SURFACE_TRANSFORM_ROTATE_270_BIT_KHR = 1 shl 3;
  VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_BIT_KHR = 1 shl 4;
  VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_90_BIT_KHR = 1 shl 5;
  VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_180_BIT_KHR = 1 shl 6;
  VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_270_BIT_KHR = 1 shl 7;
  VK_SURFACE_TRANSFORM_INHERIT_BIT_KHR = 1 shl 8;
  VK_SWAPCHAIN_IMAGE_USAGE_SHARED_BIT_ANDROID = 1 shl 0;
  VK_TIME_DOMAIN_DEVICE_EXT = 0;
  VK_TIME_DOMAIN_CLOCK_MONOTONIC_EXT = 1;
  VK_TIME_DOMAIN_CLOCK_MONOTONIC_RAW_EXT = 2;
  VK_TIME_DOMAIN_QUERY_PERFORMANCE_COUNTER_EXT = 3;
  VK_DEBUG_REPORT_INFORMATION_BIT_EXT = 1 shl 0;
  VK_DEBUG_REPORT_WARNING_BIT_EXT = 1 shl 1;
  VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT = 1 shl 2;
  VK_DEBUG_REPORT_ERROR_BIT_EXT = 1 shl 3;
  VK_DEBUG_REPORT_DEBUG_BIT_EXT = 1 shl 4;
  VK_DEBUG_REPORT_OBJECT_TYPE_UNKNOWN_EXT = 0;
  VK_DEBUG_REPORT_OBJECT_TYPE_INSTANCE_EXT = 1;
  VK_DEBUG_REPORT_OBJECT_TYPE_PHYSICAL_DEVICE_EXT = 2;
  VK_DEBUG_REPORT_OBJECT_TYPE_DEVICE_EXT = 3;
  VK_DEBUG_REPORT_OBJECT_TYPE_QUEUE_EXT = 4;
  VK_DEBUG_REPORT_OBJECT_TYPE_SEMAPHORE_EXT = 5;
  VK_DEBUG_REPORT_OBJECT_TYPE_COMMAND_BUFFER_EXT = 6;
  VK_DEBUG_REPORT_OBJECT_TYPE_FENCE_EXT = 7;
  VK_DEBUG_REPORT_OBJECT_TYPE_DEVICE_MEMORY_EXT = 8;
  VK_DEBUG_REPORT_OBJECT_TYPE_BUFFER_EXT = 9;
  VK_DEBUG_REPORT_OBJECT_TYPE_IMAGE_EXT = 10;
  VK_DEBUG_REPORT_OBJECT_TYPE_EVENT_EXT = 11;
  VK_DEBUG_REPORT_OBJECT_TYPE_QUERY_POOL_EXT = 12;
  VK_DEBUG_REPORT_OBJECT_TYPE_BUFFER_VIEW_EXT = 13;
  VK_DEBUG_REPORT_OBJECT_TYPE_IMAGE_VIEW_EXT = 14;
  VK_DEBUG_REPORT_OBJECT_TYPE_SHADER_MODULE_EXT = 15;
  VK_DEBUG_REPORT_OBJECT_TYPE_PIPELINE_CACHE_EXT = 16;
  VK_DEBUG_REPORT_OBJECT_TYPE_PIPELINE_LAYOUT_EXT = 17;
  VK_DEBUG_REPORT_OBJECT_TYPE_RENDER_PASS_EXT = 18;
  VK_DEBUG_REPORT_OBJECT_TYPE_PIPELINE_EXT = 19;
  VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT_EXT = 20;
  VK_DEBUG_REPORT_OBJECT_TYPE_SAMPLER_EXT = 21;
  VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_POOL_EXT = 22;
  VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_SET_EXT = 23;
  VK_DEBUG_REPORT_OBJECT_TYPE_FRAMEBUFFER_EXT = 24;
  VK_DEBUG_REPORT_OBJECT_TYPE_COMMAND_POOL_EXT = 25;
  VK_DEBUG_REPORT_OBJECT_TYPE_SURFACE_KHR_EXT = 26;
  VK_DEBUG_REPORT_OBJECT_TYPE_SWAPCHAIN_KHR_EXT = 27;
  VK_DEBUG_REPORT_OBJECT_TYPE_DEBUG_REPORT_CALLBACK_EXT_EXT = 28;
  VK_DEBUG_REPORT_OBJECT_TYPE_DISPLAY_KHR_EXT = 29;
  VK_DEBUG_REPORT_OBJECT_TYPE_DISPLAY_MODE_KHR_EXT = 30;
  VK_DEBUG_REPORT_OBJECT_TYPE_VALIDATION_CACHE_EXT_EXT = 33;
  VK_DEVICE_MEMORY_REPORT_EVENT_TYPE_ALLOCATE_EXT = 0;
  VK_DEVICE_MEMORY_REPORT_EVENT_TYPE_FREE_EXT = 1;
  VK_DEVICE_MEMORY_REPORT_EVENT_TYPE_IMPORT_EXT = 2;
  VK_DEVICE_MEMORY_REPORT_EVENT_TYPE_UNIMPORT_EXT = 3;
  VK_DEVICE_MEMORY_REPORT_EVENT_TYPE_ALLOCATION_FAILED_EXT = 4;
  VK_RASTERIZATION_ORDER_STRICT_AMD = 0;
  VK_RASTERIZATION_ORDER_RELAXED_AMD = 1;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT_NV = 1 shl 0;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_KMT_BIT_NV = 1 shl 1;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D11_IMAGE_BIT_NV = 1 shl 2;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D11_IMAGE_KMT_BIT_NV = 1 shl 3;
  VK_EXTERNAL_MEMORY_FEATURE_DEDICATED_ONLY_BIT_NV = 1 shl 0;
  VK_EXTERNAL_MEMORY_FEATURE_EXPORTABLE_BIT_NV = 1 shl 1;
  VK_EXTERNAL_MEMORY_FEATURE_IMPORTABLE_BIT_NV = 1 shl 2;
  VK_VALIDATION_CHECK_ALL_EXT = 0;
  VK_VALIDATION_CHECK_SHADERS_EXT = 1;
  VK_VALIDATION_FEATURE_ENABLE_GPU_ASSISTED_EXT = 0;
  VK_VALIDATION_FEATURE_ENABLE_GPU_ASSISTED_RESERVE_BINDING_SLOT_EXT = 1;
  VK_VALIDATION_FEATURE_ENABLE_BEST_PRACTICES_EXT = 2;
  VK_VALIDATION_FEATURE_ENABLE_DEBUG_PRINTF_EXT = 3;
  VK_VALIDATION_FEATURE_ENABLE_SYNCHRONIZATION_VALIDATION_EXT = 4;
  VK_VALIDATION_FEATURE_DISABLE_ALL_EXT = 0;
  VK_VALIDATION_FEATURE_DISABLE_SHADERS_EXT = 1;
  VK_VALIDATION_FEATURE_DISABLE_THREAD_SAFETY_EXT = 2;
  VK_VALIDATION_FEATURE_DISABLE_API_PARAMETERS_EXT = 3;
  VK_VALIDATION_FEATURE_DISABLE_OBJECT_LIFETIMES_EXT = 4;
  VK_VALIDATION_FEATURE_DISABLE_CORE_CHECKS_EXT = 5;
  VK_VALIDATION_FEATURE_DISABLE_UNIQUE_HANDLES_EXT = 6;
  VK_VALIDATION_FEATURE_DISABLE_SHADER_VALIDATION_CACHE_EXT = 7;
  VK_SUBGROUP_FEATURE_BASIC_BIT = 1 shl 0;
  VK_SUBGROUP_FEATURE_VOTE_BIT = 1 shl 1;
  VK_SUBGROUP_FEATURE_ARITHMETIC_BIT = 1 shl 2;
  VK_SUBGROUP_FEATURE_BALLOT_BIT = 1 shl 3;
  VK_SUBGROUP_FEATURE_SHUFFLE_BIT = 1 shl 4;
  VK_SUBGROUP_FEATURE_SHUFFLE_RELATIVE_BIT = 1 shl 5;
  VK_SUBGROUP_FEATURE_CLUSTERED_BIT = 1 shl 6;
  VK_SUBGROUP_FEATURE_QUAD_BIT = 1 shl 7;
  VK_INDIRECT_COMMANDS_LAYOUT_USAGE_EXPLICIT_PREPROCESS_BIT_NV = 1 shl 0;
  VK_INDIRECT_COMMANDS_LAYOUT_USAGE_INDEXED_SEQUENCES_BIT_NV = 1 shl 1;
  VK_INDIRECT_COMMANDS_LAYOUT_USAGE_UNORDERED_SEQUENCES_BIT_NV = 1 shl 2;
  VK_INDIRECT_STATE_FLAG_FRONTFACE_BIT_NV = 1 shl 0;
  VK_INDIRECT_COMMANDS_TOKEN_TYPE_SHADER_GROUP_NV = 0;
  VK_INDIRECT_COMMANDS_TOKEN_TYPE_STATE_FLAGS_NV = 1;
  VK_INDIRECT_COMMANDS_TOKEN_TYPE_INDEX_BUFFER_NV = 2;
  VK_INDIRECT_COMMANDS_TOKEN_TYPE_VERTEX_BUFFER_NV = 3;
  VK_INDIRECT_COMMANDS_TOKEN_TYPE_PUSH_CONSTANT_NV = 4;
  VK_INDIRECT_COMMANDS_TOKEN_TYPE_DRAW_INDEXED_NV = 5;
  VK_INDIRECT_COMMANDS_TOKEN_TYPE_DRAW_NV = 6;
  VK_INDIRECT_COMMANDS_TOKEN_TYPE_DRAW_TASKS_NV = 7;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_FD_BIT = 1 shl 0;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT = 1 shl 1;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_KMT_BIT = 1 shl 2;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D11_TEXTURE_BIT = 1 shl 3;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D11_TEXTURE_KMT_BIT = 1 shl 4;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D12_HEAP_BIT = 1 shl 5;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D12_RESOURCE_BIT = 1 shl 6;
  VK_EXTERNAL_MEMORY_FEATURE_DEDICATED_ONLY_BIT = 1 shl 0;
  VK_EXTERNAL_MEMORY_FEATURE_EXPORTABLE_BIT = 1 shl 1;
  VK_EXTERNAL_MEMORY_FEATURE_IMPORTABLE_BIT = 1 shl 2;
  VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_FD_BIT = 1 shl 0;
  VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT = 1 shl 1;
  VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_KMT_BIT = 1 shl 2;
  VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_D3D12_FENCE_BIT = 1 shl 3;
  VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_SYNC_FD_BIT = 1 shl 4;
  VK_EXTERNAL_SEMAPHORE_FEATURE_EXPORTABLE_BIT = 1 shl 0;
  VK_EXTERNAL_SEMAPHORE_FEATURE_IMPORTABLE_BIT = 1 shl 1;
  VK_SEMAPHORE_IMPORT_TEMPORARY_BIT = 1 shl 0;
  VK_EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_FD_BIT = 1 shl 0;
  VK_EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_WIN32_BIT = 1 shl 1;
  VK_EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_WIN32_KMT_BIT = 1 shl 2;
  VK_EXTERNAL_FENCE_HANDLE_TYPE_SYNC_FD_BIT = 1 shl 3;
  VK_EXTERNAL_FENCE_FEATURE_EXPORTABLE_BIT = 1 shl 0;
  VK_EXTERNAL_FENCE_FEATURE_IMPORTABLE_BIT = 1 shl 1;
  VK_FENCE_IMPORT_TEMPORARY_BIT = 1 shl 0;
  VK_SURFACE_COUNTER_VBLANK_BIT_EXT = 1 shl 0;
  VK_DISPLAY_POWER_STATE_OFF_EXT = 0;
  VK_DISPLAY_POWER_STATE_SUSPEND_EXT = 1;
  VK_DISPLAY_POWER_STATE_ON_EXT = 2;
  VK_DEVICE_EVENT_TYPE_DISPLAY_HOTPLUG_EXT = 0;
  VK_DISPLAY_EVENT_TYPE_FIRST_PIXEL_OUT_EXT = 0;
  VK_PEER_MEMORY_FEATURE_COPY_SRC_BIT = 1 shl 0;
  VK_PEER_MEMORY_FEATURE_COPY_DST_BIT = 1 shl 1;
  VK_PEER_MEMORY_FEATURE_GENERIC_SRC_BIT = 1 shl 2;
  VK_PEER_MEMORY_FEATURE_GENERIC_DST_BIT = 1 shl 3;
  VK_MEMORY_ALLOCATE_DEVICE_MASK_BIT = 1 shl 0;
  VK_DEVICE_GROUP_PRESENT_MODE_LOCAL_BIT_KHR = 1 shl 0;
  VK_DEVICE_GROUP_PRESENT_MODE_REMOTE_BIT_KHR = 1 shl 1;
  VK_DEVICE_GROUP_PRESENT_MODE_SUM_BIT_KHR = 1 shl 2;
  VK_DEVICE_GROUP_PRESENT_MODE_LOCAL_MULTI_DEVICE_BIT_KHR = 1 shl 3;
  VK_VIEWPORT_COORDINATE_SWIZZLE_POSITIVE_X_NV = 0;
  VK_VIEWPORT_COORDINATE_SWIZZLE_NEGATIVE_X_NV = 1;
  VK_VIEWPORT_COORDINATE_SWIZZLE_POSITIVE_Y_NV = 2;
  VK_VIEWPORT_COORDINATE_SWIZZLE_NEGATIVE_Y_NV = 3;
  VK_VIEWPORT_COORDINATE_SWIZZLE_POSITIVE_Z_NV = 4;
  VK_VIEWPORT_COORDINATE_SWIZZLE_NEGATIVE_Z_NV = 5;
  VK_VIEWPORT_COORDINATE_SWIZZLE_POSITIVE_W_NV = 6;
  VK_VIEWPORT_COORDINATE_SWIZZLE_NEGATIVE_W_NV = 7;
  VK_DISCARD_RECTANGLE_MODE_INCLUSIVE_EXT = 0;
  VK_DISCARD_RECTANGLE_MODE_EXCLUSIVE_EXT = 1;
  VK_POINT_CLIPPING_BEHAVIOR_ALL_CLIP_PLANES = 0;
  VK_POINT_CLIPPING_BEHAVIOR_USER_CLIP_PLANES_ONLY = 1;
  VK_SAMPLER_REDUCTION_MODE_WEIGHTED_AVERAGE = 0;
  VK_SAMPLER_REDUCTION_MODE_MIN = 1;
  VK_SAMPLER_REDUCTION_MODE_MAX = 2;
  VK_TESSELLATION_DOMAIN_ORIGIN_UPPER_LEFT = 0;
  VK_TESSELLATION_DOMAIN_ORIGIN_LOWER_LEFT = 1;
  VK_SAMPLER_YCBCR_MODEL_CONVERSION_RGB_IDENTITY = 0;
  VK_SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_IDENTITY = 1;
  VK_SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_709 = 2;
  VK_SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_601 = 3;
  VK_SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_2020 = 4;
  VK_SAMPLER_YCBCR_RANGE_ITU_FULL = 0;
  VK_SAMPLER_YCBCR_RANGE_ITU_NARROW = 1;
  VK_CHROMA_LOCATION_COSITED_EVEN = 0;
  VK_CHROMA_LOCATION_MIDPOINT = 1;
  VK_BLEND_OVERLAP_UNCORRELATED_EXT = 0;
  VK_BLEND_OVERLAP_DISJOINT_EXT = 1;
  VK_BLEND_OVERLAP_CONJOINT_EXT = 2;
  VK_COVERAGE_MODULATION_MODE_NONE_NV = 0;
  VK_COVERAGE_MODULATION_MODE_RGB_NV = 1;
  VK_COVERAGE_MODULATION_MODE_ALPHA_NV = 2;
  VK_COVERAGE_MODULATION_MODE_RGBA_NV = 3;
  VK_COVERAGE_REDUCTION_MODE_MERGE_NV = 0;
  VK_COVERAGE_REDUCTION_MODE_TRUNCATE_NV = 1;
  VK_VALIDATION_CACHE_HEADER_VERSION_ONE_EXT = 1;
  VK_SHADER_INFO_TYPE_STATISTICS_AMD = 0;
  VK_SHADER_INFO_TYPE_BINARY_AMD = 1;
  VK_SHADER_INFO_TYPE_DISASSEMBLY_AMD = 2;
  VK_QUEUE_GLOBAL_PRIORITY_LOW_EXT = 128;
  VK_QUEUE_GLOBAL_PRIORITY_MEDIUM_EXT = 256;
  VK_QUEUE_GLOBAL_PRIORITY_HIGH_EXT = 512;
  VK_QUEUE_GLOBAL_PRIORITY_REALTIME_EXT = 1024;
  VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT = 1 shl 0;
  VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT = 1 shl 4;
  VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT = 1 shl 8;
  VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT = 1 shl 12;
  VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT = 1 shl 0;
  VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT = 1 shl 1;
  VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT = 1 shl 2;
  VK_CONSERVATIVE_RASTERIZATION_MODE_DISABLED_EXT = 0;
  VK_CONSERVATIVE_RASTERIZATION_MODE_OVERESTIMATE_EXT = 1;
  VK_CONSERVATIVE_RASTERIZATION_MODE_UNDERESTIMATE_EXT = 2;
  VK_DESCRIPTOR_BINDING_UPDATE_AFTER_BIND_BIT = 1 shl 0;
  VK_DESCRIPTOR_BINDING_UPDATE_UNUSED_WHILE_PENDING_BIT = 1 shl 1;
  VK_DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT = 1 shl 2;
  VK_DESCRIPTOR_BINDING_VARIABLE_DESCRIPTOR_COUNT_BIT = 1 shl 3;
  VK_VENDOR_ID_VIV = $10001;
  VK_VENDOR_ID_VSI = $10002;
  VK_VENDOR_ID_KAZAN = $10003;
  VK_VENDOR_ID_CODEPLAY = $10004;
  VK_VENDOR_ID_MESA = $10005;
  VK_VENDOR_ID_POCL = $10006;
  VK_DRIVER_ID_AMD_PROPRIETARY = 1;
  VK_DRIVER_ID_AMD_OPEN_SOURCE = 2;
  VK_DRIVER_ID_MESA_RADV = 3;
  VK_DRIVER_ID_NVIDIA_PROPRIETARY = 4;
  VK_DRIVER_ID_INTEL_PROPRIETARY_WINDOWS = 5;
  VK_DRIVER_ID_INTEL_OPEN_SOURCE_MESA = 6;
  VK_DRIVER_ID_IMAGINATION_PROPRIETARY = 7;
  VK_DRIVER_ID_QUALCOMM_PROPRIETARY = 8;
  VK_DRIVER_ID_ARM_PROPRIETARY = 9;
  VK_DRIVER_ID_GOOGLE_SWIFTSHADER = 10;
  VK_DRIVER_ID_GGP_PROPRIETARY = 11;
  VK_DRIVER_ID_BROADCOM_PROPRIETARY = 12;
  VK_DRIVER_ID_MESA_LLVMPIPE = 13;
  VK_DRIVER_ID_MOLTENVK = 14;
  VK_DRIVER_ID_COREAVI_PROPRIETARY = 15;
  VK_DRIVER_ID_JUICE_PROPRIETARY = 16;
  VK_DRIVER_ID_VERISILICON_PROPRIETARY = 17;
  VK_CONDITIONAL_RENDERING_INVERTED_BIT_EXT = 1 shl 0;
  VK_RESOLVE_MODE_NONE = 0;
  VK_RESOLVE_MODE_SAMPLE_ZERO_BIT = 1 shl 0;
  VK_RESOLVE_MODE_AVERAGE_BIT = 1 shl 1;
  VK_RESOLVE_MODE_MIN_BIT = 1 shl 2;
  VK_RESOLVE_MODE_MAX_BIT = 1 shl 3;
  VK_SHADING_RATE_PALETTE_ENTRY_NO_INVOCATIONS_NV = 0;
  VK_SHADING_RATE_PALETTE_ENTRY_16_INVOCATIONS_PER_PIXEL_NV = 1;
  VK_SHADING_RATE_PALETTE_ENTRY_8_INVOCATIONS_PER_PIXEL_NV = 2;
  VK_SHADING_RATE_PALETTE_ENTRY_4_INVOCATIONS_PER_PIXEL_NV = 3;
  VK_SHADING_RATE_PALETTE_ENTRY_2_INVOCATIONS_PER_PIXEL_NV = 4;
  VK_SHADING_RATE_PALETTE_ENTRY_1_INVOCATION_PER_PIXEL_NV = 5;
  VK_SHADING_RATE_PALETTE_ENTRY_1_INVOCATION_PER_2X1_PIXELS_NV = 6;
  VK_SHADING_RATE_PALETTE_ENTRY_1_INVOCATION_PER_1X2_PIXELS_NV = 7;
  VK_SHADING_RATE_PALETTE_ENTRY_1_INVOCATION_PER_2X2_PIXELS_NV = 8;
  VK_SHADING_RATE_PALETTE_ENTRY_1_INVOCATION_PER_4X2_PIXELS_NV = 9;
  VK_SHADING_RATE_PALETTE_ENTRY_1_INVOCATION_PER_2X4_PIXELS_NV = 10;
  VK_SHADING_RATE_PALETTE_ENTRY_1_INVOCATION_PER_4X4_PIXELS_NV = 11;
  VK_COARSE_SAMPLE_ORDER_TYPE_DEFAULT_NV = 0;
  VK_COARSE_SAMPLE_ORDER_TYPE_CUSTOM_NV = 1;
  VK_COARSE_SAMPLE_ORDER_TYPE_PIXEL_MAJOR_NV = 2;
  VK_COARSE_SAMPLE_ORDER_TYPE_SAMPLE_MAJOR_NV = 3;
  VK_GEOMETRY_INSTANCE_TRIANGLE_FACING_CULL_DISABLE_BIT_KHR = 1 shl 0;
  VK_GEOMETRY_INSTANCE_TRIANGLE_FLIP_FACING_BIT_KHR = 1 shl 1;
  VK_GEOMETRY_INSTANCE_FORCE_OPAQUE_BIT_KHR = 1 shl 2;
  VK_GEOMETRY_INSTANCE_FORCE_NO_OPAQUE_BIT_KHR = 1 shl 3;
  VK_GEOMETRY_OPAQUE_BIT_KHR = 1 shl 0;
  VK_GEOMETRY_NO_DUPLICATE_ANY_HIT_INVOCATION_BIT_KHR = 1 shl 1;
  VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_UPDATE_BIT_KHR = 1 shl 0;
  VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_COMPACTION_BIT_KHR = 1 shl 1;
  VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR = 1 shl 2;
  VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_BUILD_BIT_KHR = 1 shl 3;
  VK_BUILD_ACCELERATION_STRUCTURE_LOW_MEMORY_BIT_KHR = 1 shl 4;
  VK_ACCELERATION_STRUCTURE_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT_KHR = 1 shl 0;
  VK_COPY_ACCELERATION_STRUCTURE_MODE_CLONE_KHR = 0;
  VK_COPY_ACCELERATION_STRUCTURE_MODE_COMPACT_KHR = 1;
  VK_COPY_ACCELERATION_STRUCTURE_MODE_SERIALIZE_KHR = 2;
  VK_COPY_ACCELERATION_STRUCTURE_MODE_DESERIALIZE_KHR = 3;
  VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR = 0;
  VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR = 1;
  VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR = 0;
  VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR = 1;
  VK_ACCELERATION_STRUCTURE_TYPE_GENERIC_KHR = 2;
  VK_GEOMETRY_TYPE_TRIANGLES_KHR = 0;
  VK_GEOMETRY_TYPE_AABBS_KHR = 1;
  VK_GEOMETRY_TYPE_INSTANCES_KHR = 2;
  VK_ACCELERATION_STRUCTURE_MEMORY_REQUIREMENTS_TYPE_OBJECT_NV = 0;
  VK_ACCELERATION_STRUCTURE_MEMORY_REQUIREMENTS_TYPE_BUILD_SCRATCH_NV = 1;
  VK_ACCELERATION_STRUCTURE_MEMORY_REQUIREMENTS_TYPE_UPDATE_SCRATCH_NV = 2;
  VK_ACCELERATION_STRUCTURE_BUILD_TYPE_HOST_KHR = 0;
  VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR = 1;
  VK_ACCELERATION_STRUCTURE_BUILD_TYPE_HOST_OR_DEVICE_KHR = 2;
  VK_RAY_TRACING_SHADER_GROUP_TYPE_GENERAL_KHR = 0;
  VK_RAY_TRACING_SHADER_GROUP_TYPE_TRIANGLES_HIT_GROUP_KHR = 1;
  VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR = 2;
  VK_ACCELERATION_STRUCTURE_COMPATIBILITY_COMPATIBLE_KHR = 0;
  VK_ACCELERATION_STRUCTURE_COMPATIBILITY_INCOMPATIBLE_KHR = 1;
  VK_SHADER_GROUP_SHADER_GENERAL_KHR = 0;
  VK_SHADER_GROUP_SHADER_CLOSEST_HIT_KHR = 1;
  VK_SHADER_GROUP_SHADER_ANY_HIT_KHR = 2;
  VK_SHADER_GROUP_SHADER_INTERSECTION_KHR = 3;
  VK_MEMORY_OVERALLOCATION_BEHAVIOR_DEFAULT_AMD = 0;
  VK_MEMORY_OVERALLOCATION_BEHAVIOR_ALLOWED_AMD = 1;
  VK_MEMORY_OVERALLOCATION_BEHAVIOR_DISALLOWED_AMD = 2;
  VK_SCOPE_DEVICE_NV = 1;
  VK_SCOPE_WORKGROUP_NV = 2;
  VK_SCOPE_SUBGROUP_NV = 3;
  VK_SCOPE_QUEUE_FAMILY_NV = 5;
  VK_COMPONENT_TYPE_FLOAT16_NV = 0;
  VK_COMPONENT_TYPE_FLOAT32_NV = 1;
  VK_COMPONENT_TYPE_FLOAT64_NV = 2;
  VK_COMPONENT_TYPE_SINT8_NV = 3;
  VK_COMPONENT_TYPE_SINT16_NV = 4;
  VK_COMPONENT_TYPE_SINT32_NV = 5;
  VK_COMPONENT_TYPE_SINT64_NV = 6;
  VK_COMPONENT_TYPE_UINT8_NV = 7;
  VK_COMPONENT_TYPE_UINT16_NV = 8;
  VK_COMPONENT_TYPE_UINT32_NV = 9;
  VK_COMPONENT_TYPE_UINT64_NV = 10;
  VK_DEVICE_DIAGNOSTICS_CONFIG_ENABLE_SHADER_DEBUG_INFO_BIT_NV = 1 shl 0;
  VK_DEVICE_DIAGNOSTICS_CONFIG_ENABLE_RESOURCE_TRACKING_BIT_NV = 1 shl 1;
  VK_DEVICE_DIAGNOSTICS_CONFIG_ENABLE_AUTOMATIC_CHECKPOINTS_BIT_NV = 1 shl 2;
  VK_PIPELINE_CREATION_FEEDBACK_VALID_BIT_EXT = 1 shl 0;
  VK_PIPELINE_CREATION_FEEDBACK_APPLICATION_PIPELINE_CACHE_HIT_BIT_EXT = 1 shl 1;
  VK_PIPELINE_CREATION_FEEDBACK_BASE_PIPELINE_ACCELERATION_BIT_EXT = 1 shl 2;
  VK_FULL_SCREEN_EXCLUSIVE_DEFAULT_EXT = 0;
  VK_FULL_SCREEN_EXCLUSIVE_ALLOWED_EXT = 1;
  VK_FULL_SCREEN_EXCLUSIVE_DISALLOWED_EXT = 2;
  VK_FULL_SCREEN_EXCLUSIVE_APPLICATION_CONTROLLED_EXT = 3;
  VK_PERFORMANCE_COUNTER_SCOPE_COMMAND_BUFFER_KHR = 0;
  VK_PERFORMANCE_COUNTER_SCOPE_RENDER_PASS_KHR = 1;
  VK_PERFORMANCE_COUNTER_SCOPE_COMMAND_KHR = 2;
  VK_PERFORMANCE_COUNTER_UNIT_GENERIC_KHR = 0;
  VK_PERFORMANCE_COUNTER_UNIT_PERCENTAGE_KHR = 1;
  VK_PERFORMANCE_COUNTER_UNIT_NANOSECONDS_KHR = 2;
  VK_PERFORMANCE_COUNTER_UNIT_BYTES_KHR = 3;
  VK_PERFORMANCE_COUNTER_UNIT_BYTES_PER_SECOND_KHR = 4;
  VK_PERFORMANCE_COUNTER_UNIT_KELVIN_KHR = 5;
  VK_PERFORMANCE_COUNTER_UNIT_WATTS_KHR = 6;
  VK_PERFORMANCE_COUNTER_UNIT_VOLTS_KHR = 7;
  VK_PERFORMANCE_COUNTER_UNIT_AMPS_KHR = 8;
  VK_PERFORMANCE_COUNTER_UNIT_HERTZ_KHR = 9;
  VK_PERFORMANCE_COUNTER_UNIT_CYCLES_KHR = 10;
  VK_PERFORMANCE_COUNTER_STORAGE_INT32_KHR = 0;
  VK_PERFORMANCE_COUNTER_STORAGE_INT64_KHR = 1;
  VK_PERFORMANCE_COUNTER_STORAGE_UINT32_KHR = 2;
  VK_PERFORMANCE_COUNTER_STORAGE_UINT64_KHR = 3;
  VK_PERFORMANCE_COUNTER_STORAGE_FLOAT32_KHR = 4;
  VK_PERFORMANCE_COUNTER_STORAGE_FLOAT64_KHR = 5;
  VK_PERFORMANCE_COUNTER_DESCRIPTION_PERFORMANCE_IMPACTING_BIT_KHR = 1 shl 0;
  VK_PERFORMANCE_COUNTER_DESCRIPTION_CONCURRENTLY_IMPACTED_BIT_KHR = 1 shl 1;
  VK_PERFORMANCE_CONFIGURATION_TYPE_COMMAND_QUEUE_METRICS_DISCOVERY_ACTIVATED_INTEL = 0;
  VK_QUERY_POOL_SAMPLING_MODE_MANUAL_INTEL = 0;
  VK_PERFORMANCE_OVERRIDE_TYPE_NULL_HARDWARE_INTEL = 0;
  VK_PERFORMANCE_OVERRIDE_TYPE_FLUSH_GPU_CACHES_INTEL = 1;
  VK_PERFORMANCE_PARAMETER_TYPE_HW_COUNTERS_SUPPORTED_INTEL = 0;
  VK_PERFORMANCE_PARAMETER_TYPE_STREAM_MARKER_VALID_BITS_INTEL = 1;
  VK_PERFORMANCE_VALUE_TYPE_UINT32_INTEL = 0;
  VK_PERFORMANCE_VALUE_TYPE_UINT64_INTEL = 1;
  VK_PERFORMANCE_VALUE_TYPE_FLOAT_INTEL = 2;
  VK_PERFORMANCE_VALUE_TYPE_BOOL_INTEL = 3;
  VK_PERFORMANCE_VALUE_TYPE_STRING_INTEL = 4;
  VK_SHADER_FLOAT_CONTROLS_INDEPENDENCE_32_BIT_ONLY = 0;
  VK_SHADER_FLOAT_CONTROLS_INDEPENDENCE_ALL = 1;
  VK_SHADER_FLOAT_CONTROLS_INDEPENDENCE_NONE = 2;
  VK_PIPELINE_EXECUTABLE_STATISTIC_FORMAT_BOOL32_KHR = 0;
  VK_PIPELINE_EXECUTABLE_STATISTIC_FORMAT_INT64_KHR = 1;
  VK_PIPELINE_EXECUTABLE_STATISTIC_FORMAT_UINT64_KHR = 2;
  VK_PIPELINE_EXECUTABLE_STATISTIC_FORMAT_FLOAT64_KHR = 3;
  VK_LINE_RASTERIZATION_MODE_DEFAULT_EXT = 0;
  VK_LINE_RASTERIZATION_MODE_RECTANGULAR_EXT = 1;
  VK_LINE_RASTERIZATION_MODE_BRESENHAM_EXT = 2;
  VK_LINE_RASTERIZATION_MODE_RECTANGULAR_SMOOTH_EXT = 3;
  VK_TOOL_PURPOSE_VALIDATION_BIT_EXT = 1 shl 0;
  VK_TOOL_PURPOSE_PROFILING_BIT_EXT = 1 shl 1;
  VK_TOOL_PURPOSE_TRACING_BIT_EXT = 1 shl 2;
  VK_TOOL_PURPOSE_ADDITIONAL_FEATURES_BIT_EXT = 1 shl 3;
  VK_TOOL_PURPOSE_MODIFYING_FEATURES_BIT_EXT = 1 shl 4;
  VK_FRAGMENT_SHADING_RATE_COMBINER_OP_KEEP_KHR = 0;
  VK_FRAGMENT_SHADING_RATE_COMBINER_OP_REPLACE_KHR = 1;
  VK_FRAGMENT_SHADING_RATE_COMBINER_OP_MIN_KHR = 2;
  VK_FRAGMENT_SHADING_RATE_COMBINER_OP_MAX_KHR = 3;
  VK_FRAGMENT_SHADING_RATE_COMBINER_OP_MUL_KHR = 4;
  VK_FRAGMENT_SHADING_RATE_1_INVOCATION_PER_PIXEL_NV = 0;
  VK_FRAGMENT_SHADING_RATE_1_INVOCATION_PER_1X2_PIXELS_NV = 1;
  VK_FRAGMENT_SHADING_RATE_1_INVOCATION_PER_2X1_PIXELS_NV = 4;
  VK_FRAGMENT_SHADING_RATE_1_INVOCATION_PER_2X2_PIXELS_NV = 5;
  VK_FRAGMENT_SHADING_RATE_1_INVOCATION_PER_2X4_PIXELS_NV = 6;
  VK_FRAGMENT_SHADING_RATE_1_INVOCATION_PER_4X2_PIXELS_NV = 9;
  VK_FRAGMENT_SHADING_RATE_1_INVOCATION_PER_4X4_PIXELS_NV = 10;
  VK_FRAGMENT_SHADING_RATE_2_INVOCATIONS_PER_PIXEL_NV = 11;
  VK_FRAGMENT_SHADING_RATE_4_INVOCATIONS_PER_PIXEL_NV = 12;
  VK_FRAGMENT_SHADING_RATE_8_INVOCATIONS_PER_PIXEL_NV = 13;
  VK_FRAGMENT_SHADING_RATE_16_INVOCATIONS_PER_PIXEL_NV = 14;
  VK_FRAGMENT_SHADING_RATE_NO_INVOCATIONS_NV = 15;
  VK_FRAGMENT_SHADING_RATE_TYPE_FRAGMENT_SIZE_NV = 0;
  VK_FRAGMENT_SHADING_RATE_TYPE_ENUMS_NV = 1;
  VK_ACCESS_2_NONE_KHR = 0;
  VK_ACCESS_2_INDIRECT_COMMAND_READ_BIT_KHR = 1 shl 0;
  VK_ACCESS_2_INDEX_READ_BIT_KHR = 1 shl 1;
  VK_ACCESS_2_VERTEX_ATTRIBUTE_READ_BIT_KHR = 1 shl 2;
  VK_ACCESS_2_UNIFORM_READ_BIT_KHR = 1 shl 3;
  VK_ACCESS_2_INPUT_ATTACHMENT_READ_BIT_KHR = 1 shl 4;
  VK_ACCESS_2_SHADER_READ_BIT_KHR = 1 shl 5;
  VK_ACCESS_2_SHADER_WRITE_BIT_KHR = 1 shl 6;
  VK_ACCESS_2_COLOR_ATTACHMENT_READ_BIT_KHR = 1 shl 7;
  VK_ACCESS_2_COLOR_ATTACHMENT_WRITE_BIT_KHR = 1 shl 8;
  VK_ACCESS_2_DEPTH_STENCIL_ATTACHMENT_READ_BIT_KHR = 1 shl 9;
  VK_ACCESS_2_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT_KHR = 1 shl 10;
  VK_ACCESS_2_TRANSFER_READ_BIT_KHR = 1 shl 11;
  VK_ACCESS_2_TRANSFER_WRITE_BIT_KHR = 1 shl 12;
  VK_ACCESS_2_HOST_READ_BIT_KHR = 1 shl 13;
  VK_ACCESS_2_HOST_WRITE_BIT_KHR = 1 shl 14;
  VK_ACCESS_2_MEMORY_READ_BIT_KHR = 1 shl 15;
  VK_ACCESS_2_MEMORY_WRITE_BIT_KHR = 1 shl 16;
  VK_ACCESS_2_SHADER_SAMPLED_READ_BIT_KHR = 1 shl 32;
  VK_ACCESS_2_SHADER_STORAGE_READ_BIT_KHR = 1 shl 33;
  VK_ACCESS_2_SHADER_STORAGE_WRITE_BIT_KHR = 1 shl 34;
  VK_PIPELINE_STAGE_2_NONE_KHR = 0;
  VK_PIPELINE_STAGE_2_TOP_OF_PIPE_BIT_KHR = 1 shl 0;
  VK_PIPELINE_STAGE_2_DRAW_INDIRECT_BIT_KHR = 1 shl 1;
  VK_PIPELINE_STAGE_2_VERTEX_INPUT_BIT_KHR = 1 shl 2;
  VK_PIPELINE_STAGE_2_VERTEX_SHADER_BIT_KHR = 1 shl 3;
  VK_PIPELINE_STAGE_2_TESSELLATION_CONTROL_SHADER_BIT_KHR = 1 shl 4;
  VK_PIPELINE_STAGE_2_TESSELLATION_EVALUATION_SHADER_BIT_KHR = 1 shl 5;
  VK_PIPELINE_STAGE_2_GEOMETRY_SHADER_BIT_KHR = 1 shl 6;
  VK_PIPELINE_STAGE_2_FRAGMENT_SHADER_BIT_KHR = 1 shl 7;
  VK_PIPELINE_STAGE_2_EARLY_FRAGMENT_TESTS_BIT_KHR = 1 shl 8;
  VK_PIPELINE_STAGE_2_LATE_FRAGMENT_TESTS_BIT_KHR = 1 shl 9;
  VK_PIPELINE_STAGE_2_COLOR_ATTACHMENT_OUTPUT_BIT_KHR = 1 shl 10;
  VK_PIPELINE_STAGE_2_COMPUTE_SHADER_BIT_KHR = 1 shl 11;
  VK_PIPELINE_STAGE_2_ALL_TRANSFER_BIT_KHR = 1 shl 12;
  VK_PIPELINE_STAGE_2_BOTTOM_OF_PIPE_BIT_KHR = 1 shl 13;
  VK_PIPELINE_STAGE_2_HOST_BIT_KHR = 1 shl 14;
  VK_PIPELINE_STAGE_2_ALL_GRAPHICS_BIT_KHR = 1 shl 15;
  VK_PIPELINE_STAGE_2_ALL_COMMANDS_BIT_KHR = 1 shl 16;
  VK_PIPELINE_STAGE_2_COPY_BIT_KHR = 1 shl 32;
  VK_PIPELINE_STAGE_2_RESOLVE_BIT_KHR = 1 shl 33;
  VK_PIPELINE_STAGE_2_BLIT_BIT_KHR = 1 shl 34;
  VK_PIPELINE_STAGE_2_CLEAR_BIT_KHR = 1 shl 35;
  VK_PIPELINE_STAGE_2_INDEX_INPUT_BIT_KHR = 1 shl 36;
  VK_PIPELINE_STAGE_2_VERTEX_ATTRIBUTE_INPUT_BIT_KHR = 1 shl 37;
  VK_PIPELINE_STAGE_2_PRE_RASTERIZATION_SHADERS_BIT_KHR = 1 shl 38;
  VK_SUBMIT_PROTECTED_BIT_KHR = 1 shl 0;
  VK_PROVOKING_VERTEX_MODE_FIRST_VERTEX_EXT = 0;
  VK_PROVOKING_VERTEX_MODE_LAST_VERTEX_EXT = 1;
  VK_ACCELERATION_STRUCTURE_MOTION_INSTANCE_TYPE_STATIC_NV = 0;
  VK_ACCELERATION_STRUCTURE_MOTION_INSTANCE_TYPE_MATRIX_MOTION_NV = 1;
  VK_ACCELERATION_STRUCTURE_MOTION_INSTANCE_TYPE_SRT_MOTION_NV = 2;
  VK_VIDEO_CODEC_OPERATION_INVALID_BIT_KHR = 0;
  VK_VIDEO_CHROMA_SUBSAMPLING_INVALID_BIT_KHR = 0;
  VK_VIDEO_CHROMA_SUBSAMPLING_MONOCHROME_BIT_KHR = 1 shl 0;
  VK_VIDEO_CHROMA_SUBSAMPLING_420_BIT_KHR = 1 shl 1;
  VK_VIDEO_CHROMA_SUBSAMPLING_422_BIT_KHR = 1 shl 2;
  VK_VIDEO_CHROMA_SUBSAMPLING_444_BIT_KHR = 1 shl 3;
  VK_VIDEO_COMPONENT_BIT_DEPTH_INVALID_KHR = 0;
  VK_VIDEO_COMPONENT_BIT_DEPTH_8_BIT_KHR = 1 shl 0;
  VK_VIDEO_COMPONENT_BIT_DEPTH_10_BIT_KHR = 1 shl 2;
  VK_VIDEO_COMPONENT_BIT_DEPTH_12_BIT_KHR = 1 shl 4;
  VK_VIDEO_CAPABILITY_PROTECTED_CONTENT_BIT_KHR = 1 shl 0;
  VK_VIDEO_CAPABILITY_SEPARATE_REFERENCE_IMAGES_BIT_KHR = 1 shl 1;
  VK_VIDEO_SESSION_CREATE_DEFAULT_KHR = 0;
  VK_VIDEO_SESSION_CREATE_PROTECTED_CONTENT_BIT_KHR = 1 shl 0;
  VK_VIDEO_CODING_QUALITY_PRESET_DEFAULT_BIT_KHR = 0;
  VK_VIDEO_CODING_QUALITY_PRESET_NORMAL_BIT_KHR = 1 shl 0;
  VK_VIDEO_CODING_QUALITY_PRESET_POWER_BIT_KHR = 1 shl 1;
  VK_VIDEO_CODING_QUALITY_PRESET_QUALITY_BIT_KHR = 1 shl 2;
  VK_VIDEO_DECODE_H264_PICTURE_LAYOUT_PROGRESSIVE_EXT = 0;
  VK_VIDEO_DECODE_H264_PICTURE_LAYOUT_INTERLACED_INTERLEAVED_LINES_BIT_EXT = 1 shl 0;
  VK_VIDEO_DECODE_H264_PICTURE_LAYOUT_INTERLACED_SEPARATE_PLANES_BIT_EXT = 1 shl 1;
  VK_VIDEO_CODING_CONTROL_DEFAULT_KHR = 0;
  VK_VIDEO_CODING_CONTROL_RESET_BIT_KHR = 1 shl 0;
  VK_QUERY_RESULT_STATUS_ERROR_KHR = -1;
  VK_QUERY_RESULT_STATUS_NOT_READY_KHR = 0;
  VK_QUERY_RESULT_STATUS_COMPLETE_KHR = 1;
  VK_VIDEO_DECODE_DEFAULT_KHR = 0;
  VK_VIDEO_DECODE_RESERVED_0_BIT_KHR = 1 shl 0;
  VK_VIDEO_ENCODE_DEFAULT_KHR = 0;
  VK_VIDEO_ENCODE_RESERVED_0_BIT_KHR = 1 shl 0;
  VK_VIDEO_ENCODE_RATE_CONTROL_DEFAULT_KHR = 0;
  VK_VIDEO_ENCODE_RATE_CONTROL_RESET_BIT_KHR = 1 shl 0;
  VK_VIDEO_ENCODE_RATE_CONTROL_MODE_NONE_BIT_KHR = 0;
  VK_VIDEO_ENCODE_RATE_CONTROL_MODE_CBR_BIT_KHR = 1;
  VK_VIDEO_ENCODE_RATE_CONTROL_MODE_VBR_BIT_KHR = 2;
  VK_VIDEO_ENCODE_H264_CAPABILITY_CABAC_BIT_EXT = 1 shl 0;
  VK_VIDEO_ENCODE_H264_CAPABILITY_CAVLC_BIT_EXT = 1 shl 1;
  VK_VIDEO_ENCODE_H264_CAPABILITY_WEIGHTED_BI_PRED_IMPLICIT_BIT_EXT = 1 shl 2;
  VK_VIDEO_ENCODE_H264_CAPABILITY_TRANSFORM_8X8_BIT_EXT = 1 shl 3;
  VK_VIDEO_ENCODE_H264_CAPABILITY_CHROMA_QP_OFFSET_BIT_EXT = 1 shl 4;
  VK_VIDEO_ENCODE_H264_CAPABILITY_SECOND_CHROMA_QP_OFFSET_BIT_EXT = 1 shl 5;
  VK_VIDEO_ENCODE_H264_CAPABILITY_DEBLOCKING_FILTER_DISABLED_BIT_EXT = 1 shl 6;
  VK_VIDEO_ENCODE_H264_CAPABILITY_DEBLOCKING_FILTER_ENABLED_BIT_EXT = 1 shl 7;
  VK_VIDEO_ENCODE_H264_CAPABILITY_DEBLOCKING_FILTER_PARTIAL_BIT_EXT = 1 shl 8;
  VK_VIDEO_ENCODE_H264_CAPABILITY_MULTIPLE_SLICE_PER_FRAME_BIT_EXT = 1 shl 9;
  VK_VIDEO_ENCODE_H264_CAPABILITY_EVENLY_DISTRIBUTED_SLICE_SIZE_BIT_EXT = 1 shl 10;
  VK_VIDEO_ENCODE_H264_INPUT_MODE_FRAME_BIT_EXT = 1 shl 0;
  VK_VIDEO_ENCODE_H264_INPUT_MODE_SLICE_BIT_EXT = 1 shl 1;
  VK_VIDEO_ENCODE_H264_INPUT_MODE_NON_VCL_BIT_EXT = 1 shl 2;
  VK_VIDEO_ENCODE_H264_OUTPUT_MODE_FRAME_BIT_EXT = 1 shl 0;
  VK_VIDEO_ENCODE_H264_OUTPUT_MODE_SLICE_BIT_EXT = 1 shl 1;
  VK_VIDEO_ENCODE_H264_OUTPUT_MODE_NON_VCL_BIT_EXT = 1 shl 2;
  VK_VIDEO_ENCODE_H264_CREATE_DEFAULT_EXT = 0;
  VK_VIDEO_ENCODE_H264_CREATE_RESERVED_0_BIT_EXT = 1 shl 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBGROUP_PROPERTIES = 1000000000 + (95 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_BIND_BUFFER_MEMORY_INFO = 1000000000 + (158 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_BIND_IMAGE_MEMORY_INFO = 1000000000 + (158 - 1) * 1000 + 1;
  VK_IMAGE_CREATE_ALIAS_BIT = 1 shl 10;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_16BIT_STORAGE_FEATURES = 1000000000 + (84 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_MEMORY_DEDICATED_REQUIREMENTS = 1000000000 + (128 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_MEMORY_DEDICATED_ALLOCATE_INFO = 1000000000 + (128 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_FLAGS_INFO = 1000000000 + (61 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_DEVICE_GROUP_RENDER_PASS_BEGIN_INFO = 1000000000 + (61 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_DEVICE_GROUP_COMMAND_BUFFER_BEGIN_INFO = 1000000000 + (61 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_DEVICE_GROUP_SUBMIT_INFO = 1000000000 + (61 - 1) * 1000 + 5;
  VK_STRUCTURE_TYPE_DEVICE_GROUP_BIND_SPARSE_INFO = 1000000000 + (61 - 1) * 1000 + 6;
  VK_PIPELINE_CREATE_VIEW_INDEX_FROM_DEVICE_INDEX_BIT = 1 shl 3;
  VK_PIPELINE_CREATE_DISPATCH_BASE_BIT = 1 shl 4;
  VK_DEPENDENCY_DEVICE_GROUP_BIT = 1 shl 2;
  VK_STRUCTURE_TYPE_BIND_BUFFER_MEMORY_DEVICE_GROUP_INFO = 1000000000 + (61 - 1) * 1000 + 13;
  VK_STRUCTURE_TYPE_BIND_IMAGE_MEMORY_DEVICE_GROUP_INFO = 1000000000 + (61 - 1) * 1000 + 14;
  VK_IMAGE_CREATE_SPLIT_INSTANCE_BIND_REGIONS_BIT = 1 shl 6;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_GROUP_PROPERTIES = 1000000000 + (71 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_DEVICE_GROUP_DEVICE_CREATE_INFO = 1000000000 + (71 - 1) * 1000 + 1;
  VK_MEMORY_HEAP_MULTI_INSTANCE_BIT = 1 shl 1;
  VK_STRUCTURE_TYPE_BUFFER_MEMORY_REQUIREMENTS_INFO_2 = 1000000000 + (147 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_IMAGE_MEMORY_REQUIREMENTS_INFO_2 = 1000000000 + (147 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_IMAGE_SPARSE_MEMORY_REQUIREMENTS_INFO_2 = 1000000000 + (147 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_MEMORY_REQUIREMENTS_2 = 1000000000 + (147 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_SPARSE_IMAGE_MEMORY_REQUIREMENTS_2 = 1000000000 + (147 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2 = 1000000000 + (60 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2 = 1000000000 + (60 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_FORMAT_PROPERTIES_2 = 1000000000 + (60 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_IMAGE_FORMAT_PROPERTIES_2 = 1000000000 + (60 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_FORMAT_INFO_2 = 1000000000 + (60 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_QUEUE_FAMILY_PROPERTIES_2 = 1000000000 + (60 - 1) * 1000 + 5;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MEMORY_PROPERTIES_2 = 1000000000 + (60 - 1) * 1000 + 6;
  VK_STRUCTURE_TYPE_SPARSE_IMAGE_FORMAT_PROPERTIES_2 = 1000000000 + (60 - 1) * 1000 + 7;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SPARSE_IMAGE_FORMAT_INFO_2 = 1000000000 + (60 - 1) * 1000 + 8;
  VK_ERROR_OUT_OF_POOL_MEMORY = - (1000000000 + (70 - 1) * 1000 + 0);
  VK_FORMAT_FEATURE_TRANSFER_SRC_BIT = 1 shl 14;
  VK_FORMAT_FEATURE_TRANSFER_DST_BIT = 1 shl 15;
  VK_IMAGE_CREATE_2D_ARRAY_COMPATIBLE_BIT = 1 shl 5;
  VK_IMAGE_CREATE_BLOCK_TEXEL_VIEW_COMPATIBLE_BIT = 1 shl 7;
  VK_IMAGE_CREATE_EXTENDED_USAGE_BIT = 1 shl 8;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_POINT_CLIPPING_PROPERTIES = 1000000000 + (118 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_RENDER_PASS_INPUT_ATTACHMENT_ASPECT_CREATE_INFO = 1000000000 + (118 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_IMAGE_VIEW_USAGE_CREATE_INFO = 1000000000 + (118 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_DOMAIN_ORIGIN_STATE_CREATE_INFO = 1000000000 + (118 - 1) * 1000 + 3;
  VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL = 1000000000 + (118 - 1) * 1000 + 0;
  VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL = 1000000000 + (118 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_RENDER_PASS_MULTIVIEW_CREATE_INFO = 1000000000 + (54 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTIVIEW_FEATURES = 1000000000 + (54 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTIVIEW_PROPERTIES = 1000000000 + (54 - 1) * 1000 + 2;
  VK_DEPENDENCY_VIEW_LOCAL_BIT = 1 shl 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VARIABLE_POINTERS_FEATURES = 1000000000 + (121 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PROTECTED_SUBMIT_INFO = 1000000000 + (146 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROTECTED_MEMORY_FEATURES = 1000000000 + (146 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROTECTED_MEMORY_PROPERTIES = 1000000000 + (146 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_DEVICE_QUEUE_INFO_2 = 1000000000 + (146 - 1) * 1000 + 3;
  VK_QUEUE_PROTECTED_BIT = 1 shl 4;
  VK_DEVICE_QUEUE_CREATE_PROTECTED_BIT = 1 shl 0;
  VK_MEMORY_PROPERTY_PROTECTED_BIT = 1 shl 5;
  VK_BUFFER_CREATE_PROTECTED_BIT = 1 shl 3;
  VK_IMAGE_CREATE_PROTECTED_BIT = 1 shl 11;
  VK_COMMAND_POOL_CREATE_PROTECTED_BIT = 1 shl 2;
  VK_STRUCTURE_TYPE_SAMPLER_YCBCR_CONVERSION_CREATE_INFO = 1000000000 + (157 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_SAMPLER_YCBCR_CONVERSION_INFO = 1000000000 + (157 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_BIND_IMAGE_PLANE_MEMORY_INFO = 1000000000 + (157 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_IMAGE_PLANE_MEMORY_REQUIREMENTS_INFO = 1000000000 + (157 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SAMPLER_YCBCR_CONVERSION_FEATURES = 1000000000 + (157 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_SAMPLER_YCBCR_CONVERSION_IMAGE_FORMAT_PROPERTIES = 1000000000 + (157 - 1) * 1000 + 5;
  VK_OBJECT_TYPE_SAMPLER_YCBCR_CONVERSION = 1000000000 + (157 - 1) * 1000 + 0;
  VK_FORMAT_G8B8G8R8_422_UNORM = 1000000000 + (157 - 1) * 1000 + 0;
  VK_FORMAT_B8G8R8G8_422_UNORM = 1000000000 + (157 - 1) * 1000 + 1;
  VK_FORMAT_G8_B8_R8_3PLANE_420_UNORM = 1000000000 + (157 - 1) * 1000 + 2;
  VK_FORMAT_G8_B8R8_2PLANE_420_UNORM = 1000000000 + (157 - 1) * 1000 + 3;
  VK_FORMAT_G8_B8_R8_3PLANE_422_UNORM = 1000000000 + (157 - 1) * 1000 + 4;
  VK_FORMAT_G8_B8R8_2PLANE_422_UNORM = 1000000000 + (157 - 1) * 1000 + 5;
  VK_FORMAT_G8_B8_R8_3PLANE_444_UNORM = 1000000000 + (157 - 1) * 1000 + 6;
  VK_FORMAT_R10X6_UNORM_PACK16 = 1000000000 + (157 - 1) * 1000 + 7;
  VK_FORMAT_R10X6G10X6_UNORM_2PACK16 = 1000000000 + (157 - 1) * 1000 + 8;
  VK_FORMAT_R10X6G10X6B10X6A10X6_UNORM_4PACK16 = 1000000000 + (157 - 1) * 1000 + 9;
  VK_FORMAT_G10X6B10X6G10X6R10X6_422_UNORM_4PACK16 = 1000000000 + (157 - 1) * 1000 + 10;
  VK_FORMAT_B10X6G10X6R10X6G10X6_422_UNORM_4PACK16 = 1000000000 + (157 - 1) * 1000 + 11;
  VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16 = 1000000000 + (157 - 1) * 1000 + 12;
  VK_FORMAT_G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16 = 1000000000 + (157 - 1) * 1000 + 13;
  VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16 = 1000000000 + (157 - 1) * 1000 + 14;
  VK_FORMAT_G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16 = 1000000000 + (157 - 1) * 1000 + 15;
  VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16 = 1000000000 + (157 - 1) * 1000 + 16;
  VK_FORMAT_R12X4_UNORM_PACK16 = 1000000000 + (157 - 1) * 1000 + 17;
  VK_FORMAT_R12X4G12X4_UNORM_2PACK16 = 1000000000 + (157 - 1) * 1000 + 18;
  VK_FORMAT_R12X4G12X4B12X4A12X4_UNORM_4PACK16 = 1000000000 + (157 - 1) * 1000 + 19;
  VK_FORMAT_G12X4B12X4G12X4R12X4_422_UNORM_4PACK16 = 1000000000 + (157 - 1) * 1000 + 20;
  VK_FORMAT_B12X4G12X4R12X4G12X4_422_UNORM_4PACK16 = 1000000000 + (157 - 1) * 1000 + 21;
  VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16 = 1000000000 + (157 - 1) * 1000 + 22;
  VK_FORMAT_G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16 = 1000000000 + (157 - 1) * 1000 + 23;
  VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16 = 1000000000 + (157 - 1) * 1000 + 24;
  VK_FORMAT_G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16 = 1000000000 + (157 - 1) * 1000 + 25;
  VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16 = 1000000000 + (157 - 1) * 1000 + 26;
  VK_FORMAT_G16B16G16R16_422_UNORM = 1000000000 + (157 - 1) * 1000 + 27;
  VK_FORMAT_B16G16R16G16_422_UNORM = 1000000000 + (157 - 1) * 1000 + 28;
  VK_FORMAT_G16_B16_R16_3PLANE_420_UNORM = 1000000000 + (157 - 1) * 1000 + 29;
  VK_FORMAT_G16_B16R16_2PLANE_420_UNORM = 1000000000 + (157 - 1) * 1000 + 30;
  VK_FORMAT_G16_B16_R16_3PLANE_422_UNORM = 1000000000 + (157 - 1) * 1000 + 31;
  VK_FORMAT_G16_B16R16_2PLANE_422_UNORM = 1000000000 + (157 - 1) * 1000 + 32;
  VK_FORMAT_G16_B16_R16_3PLANE_444_UNORM = 1000000000 + (157 - 1) * 1000 + 33;
  VK_IMAGE_ASPECT_PLANE_0_BIT = 1 shl 4;
  VK_IMAGE_ASPECT_PLANE_1_BIT = 1 shl 5;
  VK_IMAGE_ASPECT_PLANE_2_BIT = 1 shl 6;
  VK_IMAGE_CREATE_DISJOINT_BIT = 1 shl 9;
  VK_FORMAT_FEATURE_MIDPOINT_CHROMA_SAMPLES_BIT = 1 shl 17;
  VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_LINEAR_FILTER_BIT = 1 shl 18;
  VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_SEPARATE_RECONSTRUCTION_FILTER_BIT = 1 shl 19;
  VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_CHROMA_RECONSTRUCTION_EXPLICIT_BIT = 1 shl 20;
  VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_CHROMA_RECONSTRUCTION_EXPLICIT_FORCEABLE_BIT = 1 shl 21;
  VK_FORMAT_FEATURE_DISJOINT_BIT = 1 shl 22;
  VK_FORMAT_FEATURE_COSITED_CHROMA_SAMPLES_BIT = 1 shl 23;
  VK_STRUCTURE_TYPE_DESCRIPTOR_UPDATE_TEMPLATE_CREATE_INFO = 1000000000 + (86 - 1) * 1000 + 0;
  VK_OBJECT_TYPE_DESCRIPTOR_UPDATE_TEMPLATE = 1000000000 + (86 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_IMAGE_FORMAT_INFO = 1000000000 + (72 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_EXTERNAL_IMAGE_FORMAT_PROPERTIES = 1000000000 + (72 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_BUFFER_INFO = 1000000000 + (72 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_EXTERNAL_BUFFER_PROPERTIES = 1000000000 + (72 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ID_PROPERTIES = 1000000000 + (72 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_BUFFER_CREATE_INFO = 1000000000 + (73 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMAGE_CREATE_INFO = 1000000000 + (73 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_EXPORT_MEMORY_ALLOCATE_INFO = 1000000000 + (73 - 1) * 1000 + 2;
  VK_ERROR_INVALID_EXTERNAL_HANDLE = - (1000000000 + (73 - 1) * 1000 + 3);
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_FENCE_INFO = 1000000000 + (113 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_EXTERNAL_FENCE_PROPERTIES = 1000000000 + (113 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_EXPORT_FENCE_CREATE_INFO = 1000000000 + (114 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_EXPORT_SEMAPHORE_CREATE_INFO = 1000000000 + (78 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_SEMAPHORE_INFO = 1000000000 + (77 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_PROPERTIES = 1000000000 + (77 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MAINTENANCE_3_PROPERTIES = 1000000000 + (169 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_SUPPORT = 1000000000 + (169 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_DRAW_PARAMETERS_FEATURES = 1000000000 + (64 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_FEATURES = 49;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_PROPERTIES = 50;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES = 51;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_PROPERTIES = 52;
  VK_STRUCTURE_TYPE_IMAGE_FORMAT_LIST_CREATE_INFO = 1000000000 + (148 - 1) * 1000 + 0;
  VK_SAMPLER_ADDRESS_MODE_MIRROR_CLAMP_TO_EDGE = 4;
  VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_2 = 1000000000 + (110 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2 = 1000000000 + (110 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_SUBPASS_DESCRIPTION_2 = 1000000000 + (110 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_SUBPASS_DEPENDENCY_2 = 1000000000 + (110 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO_2 = 1000000000 + (110 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_SUBPASS_BEGIN_INFO = 1000000000 + (110 - 1) * 1000 + 5;
  VK_STRUCTURE_TYPE_SUBPASS_END_INFO = 1000000000 + (110 - 1) * 1000 + 6;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_8BIT_STORAGE_FEATURES = 1000000000 + (178 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DRIVER_PROPERTIES = 1000000000 + (197 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_ATOMIC_INT64_FEATURES = 1000000000 + (181 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_FLOAT16_INT8_FEATURES = 1000000000 + (83 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FLOAT_CONTROLS_PROPERTIES = 1000000000 + (198 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_BINDING_FLAGS_CREATE_INFO = 1000000000 + (162 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_FEATURES = 1000000000 + (162 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_PROPERTIES = 1000000000 + (162 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_DESCRIPTOR_SET_VARIABLE_DESCRIPTOR_COUNT_ALLOCATE_INFO = 1000000000 + (162 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_DESCRIPTOR_SET_VARIABLE_DESCRIPTOR_COUNT_LAYOUT_SUPPORT = 1000000000 + (162 - 1) * 1000 + 4;
  VK_DESCRIPTOR_POOL_CREATE_UPDATE_AFTER_BIND_BIT = 1 shl 1;
  VK_DESCRIPTOR_SET_LAYOUT_CREATE_UPDATE_AFTER_BIND_POOL_BIT = 1 shl 1;
  VK_ERROR_FRAGMENTATION = - (1000000000 + (162 - 1) * 1000 + 0);
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEPTH_STENCIL_RESOLVE_PROPERTIES = 1000000000 + (200 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_SUBPASS_DESCRIPTION_DEPTH_STENCIL_RESOLVE = 1000000000 + (200 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SCALAR_BLOCK_LAYOUT_FEATURES = 1000000000 + (222 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_IMAGE_STENCIL_USAGE_CREATE_INFO = 1000000000 + (247 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SAMPLER_FILTER_MINMAX_PROPERTIES = 1000000000 + (131 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_SAMPLER_REDUCTION_MODE_CREATE_INFO = 1000000000 + (131 - 1) * 1000 + 1;
  VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_MINMAX_BIT = 1 shl 16;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_MEMORY_MODEL_FEATURES = 1000000000 + (212 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGELESS_FRAMEBUFFER_FEATURES = 1000000000 + (109 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_FRAMEBUFFER_ATTACHMENTS_CREATE_INFO = 1000000000 + (109 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_FRAMEBUFFER_ATTACHMENT_IMAGE_INFO = 1000000000 + (109 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_RENDER_PASS_ATTACHMENT_BEGIN_INFO = 1000000000 + (109 - 1) * 1000 + 3;
  VK_FRAMEBUFFER_CREATE_IMAGELESS_BIT = 1 shl 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_UNIFORM_BUFFER_STANDARD_LAYOUT_FEATURES = 1000000000 + (254 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_SUBGROUP_EXTENDED_TYPES_FEATURES = 1000000000 + (176 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SEPARATE_DEPTH_STENCIL_LAYOUTS_FEATURES = 1000000000 + (242 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_STENCIL_LAYOUT = 1000000000 + (242 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_STENCIL_LAYOUT = 1000000000 + (242 - 1) * 1000 + 2;
  VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL = 1000000000 + (242 - 1) * 1000 + 0;
  VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL = 1000000000 + (242 - 1) * 1000 + 1;
  VK_IMAGE_LAYOUT_STENCIL_ATTACHMENT_OPTIMAL = 1000000000 + (242 - 1) * 1000 + 2;
  VK_IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL = 1000000000 + (242 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_HOST_QUERY_RESET_FEATURES = 1000000000 + (262 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TIMELINE_SEMAPHORE_FEATURES = 1000000000 + (208 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TIMELINE_SEMAPHORE_PROPERTIES = 1000000000 + (208 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_SEMAPHORE_TYPE_CREATE_INFO = 1000000000 + (208 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_TIMELINE_SEMAPHORE_SUBMIT_INFO = 1000000000 + (208 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_SEMAPHORE_WAIT_INFO = 1000000000 + (208 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_SEMAPHORE_SIGNAL_INFO = 1000000000 + (208 - 1) * 1000 + 5;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BUFFER_DEVICE_ADDRESS_FEATURES = 1000000000 + (258 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO = 1000000000 + (245 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_BUFFER_OPAQUE_CAPTURE_ADDRESS_CREATE_INFO = 1000000000 + (258 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_MEMORY_OPAQUE_CAPTURE_ADDRESS_ALLOCATE_INFO = 1000000000 + (258 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_DEVICE_MEMORY_OPAQUE_CAPTURE_ADDRESS_INFO = 1000000000 + (258 - 1) * 1000 + 4;
  VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT = 1 shl 17;
  VK_BUFFER_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT = 1 shl 4;
  VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT = 1 shl 1;
  VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT = 1 shl 2;
  VK_ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS = - (1000000000 + (258 - 1) * 1000 + 0);
  VK_KHR_SURFACE_SPEC_VERSION = 25;
  VK_ERROR_SURFACE_LOST_KHR = - (1000000000 + (1 - 1) * 1000 + 0);
  VK_ERROR_NATIVE_WINDOW_IN_USE_KHR = - (1000000000 + (1 - 1) * 1000 + 1);
  VK_OBJECT_TYPE_SURFACE_KHR = 1000000000 + (1 - 1) * 1000 + 0;
  VK_KHR_SWAPCHAIN_SPEC_VERSION = 70;
  VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR = 1000000000 + (2 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PRESENT_INFO_KHR = 1000000000 + (2 - 1) * 1000 + 1;
  VK_IMAGE_LAYOUT_PRESENT_SRC_KHR = 1000000000 + (2 - 1) * 1000 + 2;
  VK_SUBOPTIMAL_KHR = 1000000000 + (2 - 1) * 1000 + 3;
  VK_ERROR_OUT_OF_DATE_KHR = - (1000000000 + (2 - 1) * 1000 + 4);
  VK_OBJECT_TYPE_SWAPCHAIN_KHR = 1000000000 + (2 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_DEVICE_GROUP_PRESENT_CAPABILITIES_KHR = 1000000000 + (61 - 1) * 1000 + 7;
  VK_STRUCTURE_TYPE_IMAGE_SWAPCHAIN_CREATE_INFO_KHR = 1000000000 + (61 - 1) * 1000 + 8;
  VK_STRUCTURE_TYPE_BIND_IMAGE_MEMORY_SWAPCHAIN_INFO_KHR = 1000000000 + (61 - 1) * 1000 + 9;
  VK_STRUCTURE_TYPE_ACQUIRE_NEXT_IMAGE_INFO_KHR = 1000000000 + (61 - 1) * 1000 + 10;
  VK_STRUCTURE_TYPE_DEVICE_GROUP_PRESENT_INFO_KHR = 1000000000 + (61 - 1) * 1000 + 11;
  VK_STRUCTURE_TYPE_DEVICE_GROUP_SWAPCHAIN_CREATE_INFO_KHR = 1000000000 + (61 - 1) * 1000 + 12;
  VK_SWAPCHAIN_CREATE_SPLIT_INSTANCE_BIND_REGIONS_BIT_KHR = 1 shl 0;
  VK_SWAPCHAIN_CREATE_PROTECTED_BIT_KHR = 1 shl 1;
  VK_KHR_DISPLAY_SPEC_VERSION = 23;
  VK_STRUCTURE_TYPE_DISPLAY_MODE_CREATE_INFO_KHR = 1000000000 + (3 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_DISPLAY_SURFACE_CREATE_INFO_KHR = 1000000000 + (3 - 1) * 1000 + 1;
  VK_OBJECT_TYPE_DISPLAY_KHR = 1000000000 + (3 - 1) * 1000 + 0;
  VK_OBJECT_TYPE_DISPLAY_MODE_KHR = 1000000000 + (3 - 1) * 1000 + 1;
  VK_KHR_DISPLAY_SWAPCHAIN_SPEC_VERSION = 10;
  VK_STRUCTURE_TYPE_DISPLAY_PRESENT_INFO_KHR = 1000000000 + (4 - 1) * 1000 + 0;
  VK_ERROR_INCOMPATIBLE_DISPLAY_KHR = - (1000000000 + (4 - 1) * 1000 + 1);
  VK_KHR_XLIB_SURFACE_SPEC_VERSION = 6;
  VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR = 1000000000 + (5 - 1) * 1000 + 0;
  VK_KHR_XCB_SURFACE_SPEC_VERSION = 6;
  VK_STRUCTURE_TYPE_XCB_SURFACE_CREATE_INFO_KHR = 1000000000 + (6 - 1) * 1000 + 0;
  VK_KHR_WAYLAND_SURFACE_SPEC_VERSION = 6;
  VK_STRUCTURE_TYPE_WAYLAND_SURFACE_CREATE_INFO_KHR = 1000000000 + (7 - 1) * 1000 + 0;
  VK_KHR_MIR_SURFACE_SPEC_VERSION = 4;
  VK_KHR_ANDROID_SURFACE_SPEC_VERSION = 6;
  VK_STRUCTURE_TYPE_ANDROID_SURFACE_CREATE_INFO_KHR = 1000000000 + (9 - 1) * 1000 + 0;
  VK_KHR_WIN32_SURFACE_SPEC_VERSION = 6;
  VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR = 1000000000 + (10 - 1) * 1000 + 0;
  VK_ANDROID_NATIVE_BUFFER_SPEC_VERSION = 8;
  VK_ANDROID_NATIVE_BUFFER_NUMBER = 11;
  VK_STRUCTURE_TYPE_NATIVE_BUFFER_ANDROID = 1000000000 + (11 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_SWAPCHAIN_IMAGE_CREATE_INFO_ANDROID = 1000000000 + (11 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PRESENTATION_PROPERTIES_ANDROID = 1000000000 + (11 - 1) * 1000 + 2;
  VK_EXT_DEBUG_REPORT_SPEC_VERSION = 10;
  VK_STRUCTURE_TYPE_DEBUG_REPORT_CALLBACK_CREATE_INFO_EXT = 1000000000 + (12 - 1) * 1000 + 0;
  VK_ERROR_VALIDATION_FAILED_EXT = - (1000000000 + (12 - 1) * 1000 + 1);
  VK_OBJECT_TYPE_DEBUG_REPORT_CALLBACK_EXT = 1000000000 + (12 - 1) * 1000 + 0;
  VK_DEBUG_REPORT_OBJECT_TYPE_SAMPLER_YCBCR_CONVERSION_EXT = 1000000000 + (157 - 1) * 1000 + 0;
  VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_UPDATE_TEMPLATE_EXT = 1000000000 + (86 - 1) * 1000 + 0;
  VK_NV_GLSL_SHADER_SPEC_VERSION = 1;
  VK_ERROR_INVALID_SHADER_NV = - (1000000000 + (13 - 1) * 1000 + 0);
  VK_EXT_DEPTH_RANGE_UNRESTRICTED_SPEC_VERSION = 1;
  VK_KHR_SAMPLER_MIRROR_CLAMP_TO_EDGE_SPEC_VERSION = 3;
  VK_IMG_FILTER_CUBIC_SPEC_VERSION = 1;
  VK_FILTER_CUBIC_IMG = 1000000000 + (16 - 1) * 1000 + 0;
  VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_CUBIC_BIT_IMG = 1 shl 13;
  VK_AMD_EXTENSION_17_SPEC_VERSION = 0;
  VK_AMD_EXTENSION_18_SPEC_VERSION = 0;
  VK_AMD_RASTERIZATION_ORDER_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_RASTERIZATION_ORDER_AMD = 1000000000 + (19 - 1) * 1000 + 0;
  VK_AMD_EXTENSION_20_SPEC_VERSION = 0;
  VK_AMD_SHADER_TRINARY_MINMAX_SPEC_VERSION = 1;
  VK_AMD_SHADER_EXPLICIT_VERTEX_PARAMETER_SPEC_VERSION = 1;
  VK_EXT_DEBUG_MARKER_SPEC_VERSION = 4;
  VK_STRUCTURE_TYPE_DEBUG_MARKER_OBJECT_NAME_INFO_EXT = 1000000000 + (23 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_DEBUG_MARKER_OBJECT_TAG_INFO_EXT = 1000000000 + (23 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_DEBUG_MARKER_MARKER_INFO_EXT = 1000000000 + (23 - 1) * 1000 + 2;
  VK_KHR_VIDEO_QUEUE_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_VIDEO_PROFILE_KHR = 1000000000 + (24 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_VIDEO_CAPABILITIES_KHR = 1000000000 + (24 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_VIDEO_PICTURE_RESOURCE_KHR = 1000000000 + (24 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_VIDEO_GET_MEMORY_PROPERTIES_KHR = 1000000000 + (24 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_VIDEO_BIND_MEMORY_KHR = 1000000000 + (24 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_VIDEO_SESSION_CREATE_INFO_KHR = 1000000000 + (24 - 1) * 1000 + 5;
  VK_STRUCTURE_TYPE_VIDEO_SESSION_PARAMETERS_CREATE_INFO_KHR = 1000000000 + (24 - 1) * 1000 + 6;
  VK_STRUCTURE_TYPE_VIDEO_SESSION_PARAMETERS_UPDATE_INFO_KHR = 1000000000 + (24 - 1) * 1000 + 7;
  VK_STRUCTURE_TYPE_VIDEO_BEGIN_CODING_INFO_KHR = 1000000000 + (24 - 1) * 1000 + 8;
  VK_STRUCTURE_TYPE_VIDEO_END_CODING_INFO_KHR = 1000000000 + (24 - 1) * 1000 + 9;
  VK_STRUCTURE_TYPE_VIDEO_CODING_CONTROL_INFO_KHR = 1000000000 + (24 - 1) * 1000 + 10;
  VK_STRUCTURE_TYPE_VIDEO_REFERENCE_SLOT_KHR = 1000000000 + (24 - 1) * 1000 + 11;
  VK_STRUCTURE_TYPE_VIDEO_QUEUE_FAMILY_PROPERTIES_2_KHR = 1000000000 + (24 - 1) * 1000 + 12;
  VK_STRUCTURE_TYPE_VIDEO_PROFILES_KHR = 1000000000 + (24 - 1) * 1000 + 13;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VIDEO_FORMAT_INFO_KHR = 1000000000 + (24 - 1) * 1000 + 14;
  VK_STRUCTURE_TYPE_VIDEO_FORMAT_PROPERTIES_KHR = 1000000000 + (24 - 1) * 1000 + 15;
  VK_OBJECT_TYPE_VIDEO_SESSION_KHR = 1000000000 + (24 - 1) * 1000 + 0;
  VK_OBJECT_TYPE_VIDEO_SESSION_PARAMETERS_KHR = 1000000000 + (24 - 1) * 1000 + 1;
  VK_QUERY_TYPE_RESULT_STATUS_ONLY_KHR = 1000000000 + (24 - 1) * 1000 + 0;
  VK_QUERY_RESULT_WITH_STATUS_BIT_KHR = 1 shl 4;
  VK_KHR_VIDEO_DECODE_QUEUE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_INFO_KHR = 1000000000 + (25 - 1) * 1000 + 0;
  VK_QUEUE_VIDEO_DECODE_BIT_KHR = 1 shl 5;
  VK_PIPELINE_STAGE_2_VIDEO_DECODE_BIT_KHR = 1 shl 26;
  VK_ACCESS_2_VIDEO_DECODE_READ_BIT_KHR = 1 shl 35;
  VK_ACCESS_2_VIDEO_DECODE_WRITE_BIT_KHR = 1 shl 36;
  VK_BUFFER_USAGE_VIDEO_DECODE_SRC_BIT_KHR = 1 shl 13;
  VK_BUFFER_USAGE_VIDEO_DECODE_DST_BIT_KHR = 1 shl 14;
  VK_IMAGE_USAGE_VIDEO_DECODE_DST_BIT_KHR = 1 shl 10;
  VK_IMAGE_USAGE_VIDEO_DECODE_SRC_BIT_KHR = 1 shl 11;
  VK_IMAGE_USAGE_VIDEO_DECODE_DPB_BIT_KHR = 1 shl 12;
  VK_FORMAT_FEATURE_VIDEO_DECODE_OUTPUT_BIT_KHR = 1 shl 25;
  VK_FORMAT_FEATURE_VIDEO_DECODE_DPB_BIT_KHR = 1 shl 26;
  VK_IMAGE_LAYOUT_VIDEO_DECODE_DST_KHR = 1000000000 + (25 - 1) * 1000 + 0;
  VK_IMAGE_LAYOUT_VIDEO_DECODE_SRC_KHR = 1000000000 + (25 - 1) * 1000 + 1;
  VK_IMAGE_LAYOUT_VIDEO_DECODE_DPB_KHR = 1000000000 + (25 - 1) * 1000 + 2;
  VK_AMD_GCN_SHADER_SPEC_VERSION = 1;
  VK_NV_DEDICATED_ALLOCATION_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_DEDICATED_ALLOCATION_IMAGE_CREATE_INFO_NV = 1000000000 + (27 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_DEDICATED_ALLOCATION_BUFFER_CREATE_INFO_NV = 1000000000 + (27 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_DEDICATED_ALLOCATION_MEMORY_ALLOCATE_INFO_NV = 1000000000 + (27 - 1) * 1000 + 2;
  VK_EXT_EXTENSION_28_SPEC_VERSION = 0;
  VK_EXT_TRANSFORM_FEEDBACK_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TRANSFORM_FEEDBACK_FEATURES_EXT = 1000000000 + (29 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TRANSFORM_FEEDBACK_PROPERTIES_EXT = 1000000000 + (29 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_STREAM_CREATE_INFO_EXT = 1000000000 + (29 - 1) * 1000 + 2;
  VK_QUERY_TYPE_TRANSFORM_FEEDBACK_STREAM_EXT = 1000000000 + (29 - 1) * 1000 + 4;
  VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_BUFFER_BIT_EXT = 1 shl 11;
  VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_COUNTER_BUFFER_BIT_EXT = 1 shl 12;
  VK_ACCESS_TRANSFORM_FEEDBACK_WRITE_BIT_EXT = 1 shl 25;
  VK_ACCESS_TRANSFORM_FEEDBACK_COUNTER_READ_BIT_EXT = 1 shl 26;
  VK_ACCESS_TRANSFORM_FEEDBACK_COUNTER_WRITE_BIT_EXT = 1 shl 27;
  VK_PIPELINE_STAGE_TRANSFORM_FEEDBACK_BIT_EXT = 1 shl 24;
  VK_NVX_BINARY_IMPORT_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_CU_MODULE_CREATE_INFO_NVX = 1000000000 + (30 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_CU_FUNCTION_CREATE_INFO_NVX = 1000000000 + (30 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_CU_LAUNCH_INFO_NVX = 1000000000 + (30 - 1) * 1000 + 2;
  VK_OBJECT_TYPE_CU_MODULE_NVX = 1000000000 + (30 - 1) * 1000 + 0;
  VK_OBJECT_TYPE_CU_FUNCTION_NVX = 1000000000 + (30 - 1) * 1000 + 1;
  VK_DEBUG_REPORT_OBJECT_TYPE_CU_MODULE_NVX_EXT = 1000000000 + (30 - 1) * 1000 + 0;
  VK_DEBUG_REPORT_OBJECT_TYPE_CU_FUNCTION_NVX_EXT = 1000000000 + (30 - 1) * 1000 + 1;
  VK_NVX_IMAGE_VIEW_HANDLE_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_IMAGE_VIEW_HANDLE_INFO_NVX = 1000000000 + (31 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_IMAGE_VIEW_ADDRESS_PROPERTIES_NVX = 1000000000 + (31 - 1) * 1000 + 1;
  VK_AMD_EXTENSION_32_SPEC_VERSION = 0;
  VK_AMD_EXTENSION_33_SPEC_VERSION = 0;
  VK_AMD_DRAW_INDIRECT_COUNT_SPEC_VERSION = 2;
  VK_AMD_EXTENSION_35_SPEC_VERSION = 0;
  VK_AMD_NEGATIVE_VIEWPORT_HEIGHT_SPEC_VERSION = 1;
  VK_AMD_GPU_SHADER_HALF_FLOAT_SPEC_VERSION = 2;
  VK_AMD_SHADER_BALLOT_SPEC_VERSION = 1;
  VK_EXT_VIDEO_ENCODE_H264_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_VIDEO_ENCODE_H264_CAPABILITIES_EXT = 1000000000 + (39 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_VIDEO_ENCODE_H264_SESSION_CREATE_INFO_EXT = 1000000000 + (39 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_VIDEO_ENCODE_H264_SESSION_PARAMETERS_CREATE_INFO_EXT = 1000000000 + (39 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_VIDEO_ENCODE_H264_SESSION_PARAMETERS_ADD_INFO_EXT = 1000000000 + (39 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_VIDEO_ENCODE_H264_VCL_FRAME_INFO_EXT = 1000000000 + (39 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_VIDEO_ENCODE_H264_DPB_SLOT_INFO_EXT = 1000000000 + (39 - 1) * 1000 + 5;
  VK_STRUCTURE_TYPE_VIDEO_ENCODE_H264_NALU_SLICE_EXT = 1000000000 + (39 - 1) * 1000 + 6;
  VK_STRUCTURE_TYPE_VIDEO_ENCODE_H264_EMIT_PICTURE_PARAMETERS_EXT = 1000000000 + (39 - 1) * 1000 + 7;
  VK_STRUCTURE_TYPE_VIDEO_ENCODE_H264_PROFILE_EXT = 1000000000 + (39 - 1) * 1000 + 8;
  VK_VIDEO_CODEC_OPERATION_ENCODE_H264_BIT_EXT = 1 shl 16;
  VK_EXT_VIDEO_ENCODE_H265_SPEC_VERSION = 0;
  VK_EXT_VIDEO_DECODE_H264_SPEC_VERSION = 3;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_CAPABILITIES_EXT = 1000000000 + (41 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_SESSION_CREATE_INFO_EXT = 1000000000 + (41 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_PICTURE_INFO_EXT = 1000000000 + (41 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_MVC_EXT = 1000000000 + (41 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_PROFILE_EXT = 1000000000 + (41 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_SESSION_PARAMETERS_CREATE_INFO_EXT = 1000000000 + (41 - 1) * 1000 + 5;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_SESSION_PARAMETERS_ADD_INFO_EXT = 1000000000 + (41 - 1) * 1000 + 6;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_H264_DPB_SLOT_INFO_EXT = 1000000000 + (41 - 1) * 1000 + 7;
  VK_VIDEO_CODEC_OPERATION_DECODE_H264_BIT_EXT = 1 shl 0;
  VK_AMD_TEXTURE_GATHER_BIAS_LOD_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_TEXTURE_LOD_GATHER_FORMAT_PROPERTIES_AMD = 1000000000 + (42 - 1) * 1000 + 0;
  VK_AMD_SHADER_INFO_SPEC_VERSION = 1;
  VK_AMD_EXTENSION_44_SPEC_VERSION = 0;
  VK_AMD_EXTENSION_45_SPEC_VERSION = 0;
  VK_PIPELINE_CREATE_RESERVED_21_BIT_AMD = 1 shl 21;
  VK_PIPELINE_CREATE_RESERVED_22_BIT_AMD = 1 shl 22;
  VK_AMD_EXTENSION_46_SPEC_VERSION = 0;
  VK_AMD_SHADER_IMAGE_LOAD_STORE_LOD_SPEC_VERSION = 1;
  VK_NVX_EXTENSION_48_SPEC_VERSION = 0;
  VK_GOOGLE_EXTENSION_49_SPEC_VERSION = 0;
  VK_GGP_STREAM_DESCRIPTOR_SURFACE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_STREAM_DESCRIPTOR_SURFACE_CREATE_INFO_GGP = 1000000000 + (50 - 1) * 1000 + 0;
  VK_NV_CORNER_SAMPLED_IMAGE_SPEC_VERSION = 2;
  VK_IMAGE_CREATE_CORNER_SAMPLED_BIT_NV = 1 shl 13;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CORNER_SAMPLED_IMAGE_FEATURES_NV = 1000000000 + (51 - 1) * 1000 + 0;
  VK_NV_EXTENSION_52_SPEC_VERSION = 0;
  VK_SHADER_MODULE_CREATE_RESERVED_0_BIT_NV = 1 shl 0;
  VK_PIPELINE_SHADER_STAGE_CREATE_RESERVED_2_BIT_NV = 1 shl 2;
  VK_NV_EXTENSION_53_SPEC_VERSION = 0;
  VK_KHR_MULTIVIEW_SPEC_VERSION = 1;
  VK_IMG_FORMAT_PVRTC_SPEC_VERSION = 1;
  VK_FORMAT_PVRTC1_2BPP_UNORM_BLOCK_IMG = 1000000000 + (55 - 1) * 1000 + 0;
  VK_FORMAT_PVRTC1_4BPP_UNORM_BLOCK_IMG = 1000000000 + (55 - 1) * 1000 + 1;
  VK_FORMAT_PVRTC2_2BPP_UNORM_BLOCK_IMG = 1000000000 + (55 - 1) * 1000 + 2;
  VK_FORMAT_PVRTC2_4BPP_UNORM_BLOCK_IMG = 1000000000 + (55 - 1) * 1000 + 3;
  VK_FORMAT_PVRTC1_2BPP_SRGB_BLOCK_IMG = 1000000000 + (55 - 1) * 1000 + 4;
  VK_FORMAT_PVRTC1_4BPP_SRGB_BLOCK_IMG = 1000000000 + (55 - 1) * 1000 + 5;
  VK_FORMAT_PVRTC2_2BPP_SRGB_BLOCK_IMG = 1000000000 + (55 - 1) * 1000 + 6;
  VK_FORMAT_PVRTC2_4BPP_SRGB_BLOCK_IMG = 1000000000 + (55 - 1) * 1000 + 7;
  VK_NV_EXTERNAL_MEMORY_CAPABILITIES_SPEC_VERSION = 1;
  VK_NV_EXTERNAL_MEMORY_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMAGE_CREATE_INFO_NV = 1000000000 + (57 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_EXPORT_MEMORY_ALLOCATE_INFO_NV = 1000000000 + (57 - 1) * 1000 + 1;
  VK_NV_EXTERNAL_MEMORY_WIN32_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_IMPORT_MEMORY_WIN32_HANDLE_INFO_NV = 1000000000 + (58 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_EXPORT_MEMORY_WIN32_HANDLE_INFO_NV = 1000000000 + (58 - 1) * 1000 + 1;
  VK_NV_WIN32_KEYED_MUTEX_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_WIN32_KEYED_MUTEX_ACQUIRE_RELEASE_INFO_NV = 1000000000 + (59 - 1) * 1000 + 0;
  VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_SPEC_VERSION = 2;
  VK_KHR_DEVICE_GROUP_SPEC_VERSION = 4;
  VK_EXT_VALIDATION_FLAGS_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_VALIDATION_FLAGS_EXT = 1000000000 + (62 - 1) * 1000 + 0;
  VK_NN_VI_SURFACE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_VI_SURFACE_CREATE_INFO_NN = 1000000000 + (63 - 1) * 1000 + 0;
  VK_KHR_SHADER_DRAW_PARAMETERS_SPEC_VERSION = 1;
  VK_EXT_SHADER_SUBGROUP_BALLOT_SPEC_VERSION = 1;
  VK_EXT_SHADER_SUBGROUP_VOTE_SPEC_VERSION = 1;
  VK_EXT_TEXTURE_COMPRESSION_ASTC_HDR_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TEXTURE_COMPRESSION_ASTC_HDR_FEATURES_EXT = 1000000000 + (67 - 1) * 1000 + 0;
  VK_FORMAT_ASTC_4x4_SFLOAT_BLOCK_EXT = 1000000000 + (67 - 1) * 1000 + 0;
  VK_FORMAT_ASTC_5x4_SFLOAT_BLOCK_EXT = 1000000000 + (67 - 1) * 1000 + 1;
  VK_FORMAT_ASTC_5x5_SFLOAT_BLOCK_EXT = 1000000000 + (67 - 1) * 1000 + 2;
  VK_FORMAT_ASTC_6x5_SFLOAT_BLOCK_EXT = 1000000000 + (67 - 1) * 1000 + 3;
  VK_FORMAT_ASTC_6x6_SFLOAT_BLOCK_EXT = 1000000000 + (67 - 1) * 1000 + 4;
  VK_FORMAT_ASTC_8x5_SFLOAT_BLOCK_EXT = 1000000000 + (67 - 1) * 1000 + 5;
  VK_FORMAT_ASTC_8x6_SFLOAT_BLOCK_EXT = 1000000000 + (67 - 1) * 1000 + 6;
  VK_FORMAT_ASTC_8x8_SFLOAT_BLOCK_EXT = 1000000000 + (67 - 1) * 1000 + 7;
  VK_FORMAT_ASTC_10x5_SFLOAT_BLOCK_EXT = 1000000000 + (67 - 1) * 1000 + 8;
  VK_FORMAT_ASTC_10x6_SFLOAT_BLOCK_EXT = 1000000000 + (67 - 1) * 1000 + 9;
  VK_FORMAT_ASTC_10x8_SFLOAT_BLOCK_EXT = 1000000000 + (67 - 1) * 1000 + 10;
  VK_FORMAT_ASTC_10x10_SFLOAT_BLOCK_EXT = 1000000000 + (67 - 1) * 1000 + 11;
  VK_FORMAT_ASTC_12x10_SFLOAT_BLOCK_EXT = 1000000000 + (67 - 1) * 1000 + 12;
  VK_FORMAT_ASTC_12x12_SFLOAT_BLOCK_EXT = 1000000000 + (67 - 1) * 1000 + 13;
  VK_EXT_ASTC_DECODE_MODE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_IMAGE_VIEW_ASTC_DECODE_MODE_EXT = 1000000000 + (68 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ASTC_DECODE_FEATURES_EXT = 1000000000 + (68 - 1) * 1000 + 1;
  VK_IMG_EXTENSION_69_SPEC_VERSION = 0;
  VK_KHR_MAINTENANCE1_SPEC_VERSION = 2;
  VK_KHR_DEVICE_GROUP_CREATION_SPEC_VERSION = 1;
  VK_KHR_EXTERNAL_MEMORY_CAPABILITIES_SPEC_VERSION = 1;
  VK_KHR_EXTERNAL_MEMORY_SPEC_VERSION = 1;
  VK_KHR_EXTERNAL_MEMORY_WIN32_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_IMPORT_MEMORY_WIN32_HANDLE_INFO_KHR = 1000000000 + (74 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_EXPORT_MEMORY_WIN32_HANDLE_INFO_KHR = 1000000000 + (74 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_MEMORY_WIN32_HANDLE_PROPERTIES_KHR = 1000000000 + (74 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_MEMORY_GET_WIN32_HANDLE_INFO_KHR = 1000000000 + (74 - 1) * 1000 + 3;
  VK_KHR_EXTERNAL_MEMORY_FD_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_IMPORT_MEMORY_FD_INFO_KHR = 1000000000 + (75 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_MEMORY_FD_PROPERTIES_KHR = 1000000000 + (75 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_MEMORY_GET_FD_INFO_KHR = 1000000000 + (75 - 1) * 1000 + 2;
  VK_KHR_WIN32_KEYED_MUTEX_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_WIN32_KEYED_MUTEX_ACQUIRE_RELEASE_INFO_KHR = 1000000000 + (76 - 1) * 1000 + 0;
  VK_KHR_EXTERNAL_SEMAPHORE_CAPABILITIES_SPEC_VERSION = 1;
  VK_KHR_EXTERNAL_SEMAPHORE_SPEC_VERSION = 1;
  VK_KHR_EXTERNAL_SEMAPHORE_WIN32_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_IMPORT_SEMAPHORE_WIN32_HANDLE_INFO_KHR = 1000000000 + (79 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_EXPORT_SEMAPHORE_WIN32_HANDLE_INFO_KHR = 1000000000 + (79 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_D3D12_FENCE_SUBMIT_INFO_KHR = 1000000000 + (79 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_SEMAPHORE_GET_WIN32_HANDLE_INFO_KHR = 1000000000 + (79 - 1) * 1000 + 3;
  VK_KHR_EXTERNAL_SEMAPHORE_FD_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_IMPORT_SEMAPHORE_FD_INFO_KHR = 1000000000 + (80 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_SEMAPHORE_GET_FD_INFO_KHR = 1000000000 + (80 - 1) * 1000 + 1;
  VK_KHR_PUSH_DESCRIPTOR_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PUSH_DESCRIPTOR_PROPERTIES_KHR = 1000000000 + (81 - 1) * 1000 + 0;
  VK_DESCRIPTOR_SET_LAYOUT_CREATE_PUSH_DESCRIPTOR_BIT_KHR = 1 shl 0;
  VK_DESCRIPTOR_UPDATE_TEMPLATE_TYPE_PUSH_DESCRIPTORS_KHR = 1;
  VK_EXT_CONDITIONAL_RENDERING_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_CONDITIONAL_RENDERING_INFO_EXT = 1000000000 + (82 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CONDITIONAL_RENDERING_FEATURES_EXT = 1000000000 + (82 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_CONDITIONAL_RENDERING_BEGIN_INFO_EXT = 1000000000 + (82 - 1) * 1000 + 2;
  VK_ACCESS_CONDITIONAL_RENDERING_READ_BIT_EXT = 1 shl 20;
  VK_BUFFER_USAGE_CONDITIONAL_RENDERING_BIT_EXT = 1 shl 9;
  VK_PIPELINE_STAGE_CONDITIONAL_RENDERING_BIT_EXT = 1 shl 18;
  VK_KHR_SHADER_FLOAT16_INT8_SPEC_VERSION = 1;
  VK_KHR_16BIT_STORAGE_SPEC_VERSION = 1;
  VK_KHR_INCREMENTAL_PRESENT_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_PRESENT_REGIONS_KHR = 1000000000 + (85 - 1) * 1000 + 0;
  VK_KHR_DESCRIPTOR_UPDATE_TEMPLATE_SPEC_VERSION = 1;
  VK_NVX_DEVICE_GENERATED_COMMANDS_SPEC_VERSION = 3;
  VK_NV_CLIP_SPACE_W_SCALING_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_W_SCALING_STATE_CREATE_INFO_NV = 1000000000 + (88 - 1) * 1000 + 0;
  VK_DYNAMIC_STATE_VIEWPORT_W_SCALING_NV = 1000000000 + (88 - 1) * 1000 + 0;
  VK_EXT_DIRECT_MODE_DISPLAY_SPEC_VERSION = 1;
  VK_EXT_ACQUIRE_XLIB_DISPLAY_SPEC_VERSION = 1;
  VK_EXT_DISPLAY_SURFACE_COUNTER_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_SURFACE_CAPABILITIES_2_EXT = 1000000000 + (91 - 1) * 1000 + 0;
  VK_EXT_DISPLAY_CONTROL_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_DISPLAY_POWER_INFO_EXT = 1000000000 + (92 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_DEVICE_EVENT_INFO_EXT = 1000000000 + (92 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_DISPLAY_EVENT_INFO_EXT = 1000000000 + (92 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_SWAPCHAIN_COUNTER_CREATE_INFO_EXT = 1000000000 + (92 - 1) * 1000 + 3;
  VK_GOOGLE_DISPLAY_TIMING_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PRESENT_TIMES_INFO_GOOGLE = 1000000000 + (93 - 1) * 1000 + 0;
  VK_NV_SAMPLE_MASK_OVERRIDE_COVERAGE_SPEC_VERSION = 1;
  VK_NV_GEOMETRY_SHADER_PASSTHROUGH_SPEC_VERSION = 1;
  VK_NV_VIEWPORT_ARRAY2_SPEC_VERSION = 1;
  VK_NVX_MULTIVIEW_PER_VIEW_ATTRIBUTES_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTIVIEW_PER_VIEW_ATTRIBUTES_PROPERTIES_NVX = 1000000000 + (98 - 1) * 1000 + 0;
  VK_SUBPASS_DESCRIPTION_PER_VIEW_ATTRIBUTES_BIT_NVX = 1 shl 0;
  VK_SUBPASS_DESCRIPTION_PER_VIEW_POSITION_X_ONLY_BIT_NVX = 1 shl 1;
  VK_NV_VIEWPORT_SWIZZLE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_SWIZZLE_STATE_CREATE_INFO_NV = 1000000000 + (99 - 1) * 1000 + 0;
  VK_EXT_DISCARD_RECTANGLES_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DISCARD_RECTANGLE_PROPERTIES_EXT = 1000000000 + (100 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PIPELINE_DISCARD_RECTANGLE_STATE_CREATE_INFO_EXT = 1000000000 + (100 - 1) * 1000 + 1;
  VK_DYNAMIC_STATE_DISCARD_RECTANGLE_EXT = 1000000000 + (100 - 1) * 1000 + 0;
  VK_NV_EXTENSION_101_SPEC_VERSION = 0;
  VK_EXT_CONSERVATIVE_RASTERIZATION_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CONSERVATIVE_RASTERIZATION_PROPERTIES_EXT = 1000000000 + (102 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_CONSERVATIVE_STATE_CREATE_INFO_EXT = 1000000000 + (102 - 1) * 1000 + 1;
  VK_EXT_DEPTH_CLIP_ENABLE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEPTH_CLIP_ENABLE_FEATURES_EXT = 1000000000 + (103 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_DEPTH_CLIP_STATE_CREATE_INFO_EXT = 1000000000 + (103 - 1) * 1000 + 1;
  VK_NV_EXTENSION_104_SPEC_VERSION = 0;
  VK_EXT_SWAPCHAIN_COLOR_SPACE_SPEC_VERSION = 4;
  VK_COLOR_SPACE_DISPLAY_P3_NONLINEAR_EXT = 1000000000 + (105 - 1) * 1000 + 1;
  VK_COLOR_SPACE_EXTENDED_SRGB_LINEAR_EXT = 1000000000 + (105 - 1) * 1000 + 2;
  VK_COLOR_SPACE_DISPLAY_P3_LINEAR_EXT = 1000000000 + (105 - 1) * 1000 + 3;
  VK_COLOR_SPACE_DCI_P3_NONLINEAR_EXT = 1000000000 + (105 - 1) * 1000 + 4;
  VK_COLOR_SPACE_BT709_LINEAR_EXT = 1000000000 + (105 - 1) * 1000 + 5;
  VK_COLOR_SPACE_BT709_NONLINEAR_EXT = 1000000000 + (105 - 1) * 1000 + 6;
  VK_COLOR_SPACE_BT2020_LINEAR_EXT = 1000000000 + (105 - 1) * 1000 + 7;
  VK_COLOR_SPACE_HDR10_ST2084_EXT = 1000000000 + (105 - 1) * 1000 + 8;
  VK_COLOR_SPACE_DOLBYVISION_EXT = 1000000000 + (105 - 1) * 1000 + 9;
  VK_COLOR_SPACE_HDR10_HLG_EXT = 1000000000 + (105 - 1) * 1000 + 10;
  VK_COLOR_SPACE_ADOBERGB_LINEAR_EXT = 1000000000 + (105 - 1) * 1000 + 11;
  VK_COLOR_SPACE_ADOBERGB_NONLINEAR_EXT = 1000000000 + (105 - 1) * 1000 + 12;
  VK_COLOR_SPACE_PASS_THROUGH_EXT = 1000000000 + (105 - 1) * 1000 + 13;
  VK_COLOR_SPACE_EXTENDED_SRGB_NONLINEAR_EXT = 1000000000 + (105 - 1) * 1000 + 14;
  VK_EXT_HDR_METADATA_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_HDR_METADATA_EXT = 1000000000 + (106 - 1) * 1000 + 0;
  VK_IMG_EXTENSION_107_SPEC_VERSION = 0;
  VK_IMG_EXTENSION_108_SPEC_VERSION = 0;
  VK_KHR_IMAGELESS_FRAMEBUFFER_SPEC_VERSION = 1;
  VK_KHR_CREATE_RENDERPASS_2_SPEC_VERSION = 1;
  VK_IMG_EXTENSION_111_SPEC_VERSION = 0;
  VK_KHR_SHARED_PRESENTABLE_IMAGE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_SHARED_PRESENT_SURFACE_CAPABILITIES_KHR = 1000000000 + (112 - 1) * 1000 + 0;
  VK_PRESENT_MODE_SHARED_DEMAND_REFRESH_KHR = 1000000000 + (112 - 1) * 1000 + 0;
  VK_PRESENT_MODE_SHARED_CONTINUOUS_REFRESH_KHR = 1000000000 + (112 - 1) * 1000 + 1;
  VK_IMAGE_LAYOUT_SHARED_PRESENT_KHR = 1000000000 + (112 - 1) * 1000 + 0;
  VK_KHR_EXTERNAL_FENCE_CAPABILITIES_SPEC_VERSION = 1;
  VK_KHR_EXTERNAL_FENCE_SPEC_VERSION = 1;
  VK_KHR_EXTERNAL_FENCE_WIN32_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_IMPORT_FENCE_WIN32_HANDLE_INFO_KHR = 1000000000 + (115 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_EXPORT_FENCE_WIN32_HANDLE_INFO_KHR = 1000000000 + (115 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_FENCE_GET_WIN32_HANDLE_INFO_KHR = 1000000000 + (115 - 1) * 1000 + 2;
  VK_KHR_EXTERNAL_FENCE_FD_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_IMPORT_FENCE_FD_INFO_KHR = 1000000000 + (116 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_FENCE_GET_FD_INFO_KHR = 1000000000 + (116 - 1) * 1000 + 1;
  VK_KHR_PERFORMANCE_QUERY_SPEC_VERSION = 1;
  VK_QUERY_TYPE_PERFORMANCE_QUERY_KHR = 1000000000 + (117 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PERFORMANCE_QUERY_FEATURES_KHR = 1000000000 + (117 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PERFORMANCE_QUERY_PROPERTIES_KHR = 1000000000 + (117 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_QUERY_POOL_PERFORMANCE_CREATE_INFO_KHR = 1000000000 + (117 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_PERFORMANCE_QUERY_SUBMIT_INFO_KHR = 1000000000 + (117 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_ACQUIRE_PROFILING_LOCK_INFO_KHR = 1000000000 + (117 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_PERFORMANCE_COUNTER_KHR = 1000000000 + (117 - 1) * 1000 + 5;
  VK_STRUCTURE_TYPE_PERFORMANCE_COUNTER_DESCRIPTION_KHR = 1000000000 + (117 - 1) * 1000 + 6;
  VK_KHR_MAINTENANCE2_SPEC_VERSION = 1;
  VK_KHR_EXTENSION_119_SPEC_VERSION = 0;
  VK_KHR_GET_SURFACE_CAPABILITIES_2_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SURFACE_INFO_2_KHR = 1000000000 + (120 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_SURFACE_CAPABILITIES_2_KHR = 1000000000 + (120 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_SURFACE_FORMAT_2_KHR = 1000000000 + (120 - 1) * 1000 + 2;
  VK_KHR_VARIABLE_POINTERS_SPEC_VERSION = 1;
  VK_KHR_GET_DISPLAY_PROPERTIES_2_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_DISPLAY_PROPERTIES_2_KHR = 1000000000 + (122 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_DISPLAY_PLANE_PROPERTIES_2_KHR = 1000000000 + (122 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_DISPLAY_MODE_PROPERTIES_2_KHR = 1000000000 + (122 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_DISPLAY_PLANE_INFO_2_KHR = 1000000000 + (122 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_DISPLAY_PLANE_CAPABILITIES_2_KHR = 1000000000 + (122 - 1) * 1000 + 4;
  VK_MVK_IOS_SURFACE_SPEC_VERSION = 3;
  VK_STRUCTURE_TYPE_IOS_SURFACE_CREATE_INFO_MVK = 1000000000 + (123 - 1) * 1000 + 0;
  VK_MVK_MACOS_SURFACE_SPEC_VERSION = 3;
  VK_STRUCTURE_TYPE_MACOS_SURFACE_CREATE_INFO_MVK = 1000000000 + (124 - 1) * 1000 + 0;
  VK_MVK_MOLTENVK_SPEC_VERSION = 0;
  VK_EXT_EXTERNAL_MEMORY_DMA_BUF_SPEC_VERSION = 1;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_DMA_BUF_BIT_EXT = 1 shl 9;
  VK_EXT_QUEUE_FAMILY_FOREIGN_SPEC_VERSION = 1;
  VK_KHR_DEDICATED_ALLOCATION_SPEC_VERSION = 3;
  VK_EXT_DEBUG_UTILS_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_DEBUG_UTILS_OBJECT_NAME_INFO_EXT = 1000000000 + (129 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_DEBUG_UTILS_OBJECT_TAG_INFO_EXT = 1000000000 + (129 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_DEBUG_UTILS_LABEL_EXT = 1000000000 + (129 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CALLBACK_DATA_EXT = 1000000000 + (129 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT = 1000000000 + (129 - 1) * 1000 + 4;
  VK_OBJECT_TYPE_DEBUG_UTILS_MESSENGER_EXT = 1000000000 + (129 - 1) * 1000 + 0;
  VK_ANDROID_EXTERNAL_MEMORY_ANDROID_HARDWARE_BUFFER_SPEC_VERSION = 3;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_ANDROID_HARDWARE_BUFFER_BIT_ANDROID = 1 shl 10;
  VK_STRUCTURE_TYPE_ANDROID_HARDWARE_BUFFER_USAGE_ANDROID = 1000000000 + (130 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_ANDROID_HARDWARE_BUFFER_PROPERTIES_ANDROID = 1000000000 + (130 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_ANDROID_HARDWARE_BUFFER_FORMAT_PROPERTIES_ANDROID = 1000000000 + (130 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_IMPORT_ANDROID_HARDWARE_BUFFER_INFO_ANDROID = 1000000000 + (130 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_MEMORY_GET_ANDROID_HARDWARE_BUFFER_INFO_ANDROID = 1000000000 + (130 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_EXTERNAL_FORMAT_ANDROID = 1000000000 + (130 - 1) * 1000 + 5;
  VK_EXT_SAMPLER_FILTER_MINMAX_SPEC_VERSION = 2;
  VK_KHR_STORAGE_BUFFER_STORAGE_CLASS_SPEC_VERSION = 1;
  VK_AMD_GPU_SHADER_INT16_SPEC_VERSION = 2;
  VK_AMD_EXTENSION_134_SPEC_VERSION = 0;
  VK_AMD_EXTENSION_135_SPEC_VERSION = 0;
  VK_AMD_EXTENSION_136_SPEC_VERSION = 0;
  VK_AMD_MIXED_ATTACHMENT_SAMPLES_SPEC_VERSION = 1;
  VK_AMD_SHADER_FRAGMENT_MASK_SPEC_VERSION = 1;
  VK_EXT_INLINE_UNIFORM_BLOCK_SPEC_VERSION = 1;
  VK_DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK_EXT = 1000000000 + (139 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_INLINE_UNIFORM_BLOCK_FEATURES_EXT = 1000000000 + (139 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_INLINE_UNIFORM_BLOCK_PROPERTIES_EXT = 1000000000 + (139 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET_INLINE_UNIFORM_BLOCK_EXT = 1000000000 + (139 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_INLINE_UNIFORM_BLOCK_CREATE_INFO_EXT = 1000000000 + (139 - 1) * 1000 + 3;
  VK_AMD_EXTENSION_140_SPEC_VERSION = 0;
  VK_EXT_SHADER_STENCIL_EXPORT_SPEC_VERSION = 1;
  VK_AMD_EXTENSION_142_SPEC_VERSION = 0;
  VK_AMD_EXTENSION_143_SPEC_VERSION = 0;
  VK_EXT_SAMPLE_LOCATIONS_SPEC_VERSION = 1;
  VK_IMAGE_CREATE_SAMPLE_LOCATIONS_COMPATIBLE_DEPTH_BIT_EXT = 1 shl 12;
  VK_STRUCTURE_TYPE_SAMPLE_LOCATIONS_INFO_EXT = 1000000000 + (144 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_RENDER_PASS_SAMPLE_LOCATIONS_BEGIN_INFO_EXT = 1000000000 + (144 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PIPELINE_SAMPLE_LOCATIONS_STATE_CREATE_INFO_EXT = 1000000000 + (144 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SAMPLE_LOCATIONS_PROPERTIES_EXT = 1000000000 + (144 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_MULTISAMPLE_PROPERTIES_EXT = 1000000000 + (144 - 1) * 1000 + 4;
  VK_DYNAMIC_STATE_SAMPLE_LOCATIONS_EXT = 1000000000 + (144 - 1) * 1000 + 0;
  VK_KHR_RELAXED_BLOCK_LAYOUT_SPEC_VERSION = 1;
  VK_KHR_GET_MEMORY_REQUIREMENTS_2_SPEC_VERSION = 1;
  VK_KHR_IMAGE_FORMAT_LIST_SPEC_VERSION = 1;
  VK_EXT_BLEND_OPERATION_ADVANCED_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BLEND_OPERATION_ADVANCED_FEATURES_EXT = 1000000000 + (149 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BLEND_OPERATION_ADVANCED_PROPERTIES_EXT = 1000000000 + (149 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_ADVANCED_STATE_CREATE_INFO_EXT = 1000000000 + (149 - 1) * 1000 + 2;
  VK_BLEND_OP_ZERO_EXT = 1000000000 + (149 - 1) * 1000 + 0;
  VK_BLEND_OP_SRC_EXT = 1000000000 + (149 - 1) * 1000 + 1;
  VK_BLEND_OP_DST_EXT = 1000000000 + (149 - 1) * 1000 + 2;
  VK_BLEND_OP_SRC_OVER_EXT = 1000000000 + (149 - 1) * 1000 + 3;
  VK_BLEND_OP_DST_OVER_EXT = 1000000000 + (149 - 1) * 1000 + 4;
  VK_BLEND_OP_SRC_IN_EXT = 1000000000 + (149 - 1) * 1000 + 5;
  VK_BLEND_OP_DST_IN_EXT = 1000000000 + (149 - 1) * 1000 + 6;
  VK_BLEND_OP_SRC_OUT_EXT = 1000000000 + (149 - 1) * 1000 + 7;
  VK_BLEND_OP_DST_OUT_EXT = 1000000000 + (149 - 1) * 1000 + 8;
  VK_BLEND_OP_SRC_ATOP_EXT = 1000000000 + (149 - 1) * 1000 + 9;
  VK_BLEND_OP_DST_ATOP_EXT = 1000000000 + (149 - 1) * 1000 + 10;
  VK_BLEND_OP_XOR_EXT = 1000000000 + (149 - 1) * 1000 + 11;
  VK_BLEND_OP_MULTIPLY_EXT = 1000000000 + (149 - 1) * 1000 + 12;
  VK_BLEND_OP_SCREEN_EXT = 1000000000 + (149 - 1) * 1000 + 13;
  VK_BLEND_OP_OVERLAY_EXT = 1000000000 + (149 - 1) * 1000 + 14;
  VK_BLEND_OP_DARKEN_EXT = 1000000000 + (149 - 1) * 1000 + 15;
  VK_BLEND_OP_LIGHTEN_EXT = 1000000000 + (149 - 1) * 1000 + 16;
  VK_BLEND_OP_COLORDODGE_EXT = 1000000000 + (149 - 1) * 1000 + 17;
  VK_BLEND_OP_COLORBURN_EXT = 1000000000 + (149 - 1) * 1000 + 18;
  VK_BLEND_OP_HARDLIGHT_EXT = 1000000000 + (149 - 1) * 1000 + 19;
  VK_BLEND_OP_SOFTLIGHT_EXT = 1000000000 + (149 - 1) * 1000 + 20;
  VK_BLEND_OP_DIFFERENCE_EXT = 1000000000 + (149 - 1) * 1000 + 21;
  VK_BLEND_OP_EXCLUSION_EXT = 1000000000 + (149 - 1) * 1000 + 22;
  VK_BLEND_OP_INVERT_EXT = 1000000000 + (149 - 1) * 1000 + 23;
  VK_BLEND_OP_INVERT_RGB_EXT = 1000000000 + (149 - 1) * 1000 + 24;
  VK_BLEND_OP_LINEARDODGE_EXT = 1000000000 + (149 - 1) * 1000 + 25;
  VK_BLEND_OP_LINEARBURN_EXT = 1000000000 + (149 - 1) * 1000 + 26;
  VK_BLEND_OP_VIVIDLIGHT_EXT = 1000000000 + (149 - 1) * 1000 + 27;
  VK_BLEND_OP_LINEARLIGHT_EXT = 1000000000 + (149 - 1) * 1000 + 28;
  VK_BLEND_OP_PINLIGHT_EXT = 1000000000 + (149 - 1) * 1000 + 29;
  VK_BLEND_OP_HARDMIX_EXT = 1000000000 + (149 - 1) * 1000 + 30;
  VK_BLEND_OP_HSL_HUE_EXT = 1000000000 + (149 - 1) * 1000 + 31;
  VK_BLEND_OP_HSL_SATURATION_EXT = 1000000000 + (149 - 1) * 1000 + 32;
  VK_BLEND_OP_HSL_COLOR_EXT = 1000000000 + (149 - 1) * 1000 + 33;
  VK_BLEND_OP_HSL_LUMINOSITY_EXT = 1000000000 + (149 - 1) * 1000 + 34;
  VK_BLEND_OP_PLUS_EXT = 1000000000 + (149 - 1) * 1000 + 35;
  VK_BLEND_OP_PLUS_CLAMPED_EXT = 1000000000 + (149 - 1) * 1000 + 36;
  VK_BLEND_OP_PLUS_CLAMPED_ALPHA_EXT = 1000000000 + (149 - 1) * 1000 + 37;
  VK_BLEND_OP_PLUS_DARKER_EXT = 1000000000 + (149 - 1) * 1000 + 38;
  VK_BLEND_OP_MINUS_EXT = 1000000000 + (149 - 1) * 1000 + 39;
  VK_BLEND_OP_MINUS_CLAMPED_EXT = 1000000000 + (149 - 1) * 1000 + 40;
  VK_BLEND_OP_CONTRAST_EXT = 1000000000 + (149 - 1) * 1000 + 41;
  VK_BLEND_OP_INVERT_OVG_EXT = 1000000000 + (149 - 1) * 1000 + 42;
  VK_BLEND_OP_RED_EXT = 1000000000 + (149 - 1) * 1000 + 43;
  VK_BLEND_OP_GREEN_EXT = 1000000000 + (149 - 1) * 1000 + 44;
  VK_BLEND_OP_BLUE_EXT = 1000000000 + (149 - 1) * 1000 + 45;
  VK_ACCESS_COLOR_ATTACHMENT_READ_NONCOHERENT_BIT_EXT = 1 shl 19;
  VK_NV_FRAGMENT_COVERAGE_TO_COLOR_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PIPELINE_COVERAGE_TO_COLOR_STATE_CREATE_INFO_NV = 1000000000 + (150 - 1) * 1000 + 0;
  VK_KHR_ACCELERATION_STRUCTURE_SPEC_VERSION = 12;
  VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET_ACCELERATION_STRUCTURE_KHR = 1000000000 + (151 - 1) * 1000 + 7;
  VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR = 1000000000 + (151 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_DEVICE_ADDRESS_INFO_KHR = 1000000000 + (151 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_AABBS_DATA_KHR = 1000000000 + (151 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR = 1000000000 + (151 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR = 1000000000 + (151 - 1) * 1000 + 5;
  VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR = 1000000000 + (151 - 1) * 1000 + 6;
  VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_VERSION_INFO_KHR = 1000000000 + (151 - 1) * 1000 + 9;
  VK_STRUCTURE_TYPE_COPY_ACCELERATION_STRUCTURE_INFO_KHR = 1000000000 + (151 - 1) * 1000 + 10;
  VK_STRUCTURE_TYPE_COPY_ACCELERATION_STRUCTURE_TO_MEMORY_INFO_KHR = 1000000000 + (151 - 1) * 1000 + 11;
  VK_STRUCTURE_TYPE_COPY_MEMORY_TO_ACCELERATION_STRUCTURE_INFO_KHR = 1000000000 + (151 - 1) * 1000 + 12;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_FEATURES_KHR = 1000000000 + (151 - 1) * 1000 + 13;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_PROPERTIES_KHR = 1000000000 + (151 - 1) * 1000 + 14;
  VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_KHR = 1000000000 + (151 - 1) * 1000 + 17;
  VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR = 1000000000 + (151 - 1) * 1000 + 20;
  VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR = 1 shl 25;
  VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR = 1000000000 + (151 - 1) * 1000 + 0;
  VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR = 1 shl 21;
  VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR = 1 shl 22;
  VK_QUERY_TYPE_ACCELERATION_STRUCTURE_COMPACTED_SIZE_KHR = 1000000000 + (151 - 1) * 1000 + 0;
  VK_QUERY_TYPE_ACCELERATION_STRUCTURE_SERIALIZATION_SIZE_KHR = 1000000000 + (151 - 1) * 1000 + 1;
  VK_OBJECT_TYPE_ACCELERATION_STRUCTURE_KHR = 1000000000 + (151 - 1) * 1000 + 0;
  VK_DEBUG_REPORT_OBJECT_TYPE_ACCELERATION_STRUCTURE_KHR_EXT = 1000000000 + (151 - 1) * 1000 + 0;
  VK_INDEX_TYPE_NONE_KHR = 1000000000 + (166 - 1) * 1000 + 0;
  VK_FORMAT_FEATURE_ACCELERATION_STRUCTURE_VERTEX_BUFFER_BIT_KHR = 1 shl 29;
  VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR = 1 shl 19;
  VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR = 1 shl 20;
  VK_KHR_RAY_TRACING_PIPELINE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PIPELINE_FEATURES_KHR = 1000000000 + (348 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PIPELINE_PROPERTIES_KHR = 1000000000 + (348 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_CREATE_INFO_KHR = 1000000000 + (151 - 1) * 1000 + 15;
  VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_KHR = 1000000000 + (151 - 1) * 1000 + 16;
  VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_INTERFACE_CREATE_INFO_KHR = 1000000000 + (151 - 1) * 1000 + 18;
  VK_SHADER_STAGE_RAYGEN_BIT_KHR = 1 shl 8;
  VK_SHADER_STAGE_ANY_HIT_BIT_KHR = 1 shl 9;
  VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR = 1 shl 10;
  VK_SHADER_STAGE_MISS_BIT_KHR = 1 shl 11;
  VK_SHADER_STAGE_INTERSECTION_BIT_KHR = 1 shl 12;
  VK_SHADER_STAGE_CALLABLE_BIT_KHR = 1 shl 13;
  VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR = 1 shl 21;
  VK_BUFFER_USAGE_SHADER_BINDING_TABLE_BIT_KHR = 1 shl 10;
  VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR = 1000000000 + (166 - 1) * 1000 + 0;
  VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_ANY_HIT_SHADERS_BIT_KHR = 1 shl 14;
  VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_CLOSEST_HIT_SHADERS_BIT_KHR = 1 shl 15;
  VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_MISS_SHADERS_BIT_KHR = 1 shl 16;
  VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_INTERSECTION_SHADERS_BIT_KHR = 1 shl 17;
  VK_PIPELINE_CREATE_RAY_TRACING_SKIP_TRIANGLES_BIT_KHR = 1 shl 12;
  VK_PIPELINE_CREATE_RAY_TRACING_SKIP_AABBS_BIT_KHR = 1 shl 13;
  VK_PIPELINE_CREATE_RAY_TRACING_SHADER_GROUP_HANDLE_CAPTURE_REPLAY_BIT_KHR = 1 shl 19;
  VK_DYNAMIC_STATE_RAY_TRACING_PIPELINE_STACK_SIZE_KHR = 1000000000 + (348 - 1) * 1000 + 0;
  VK_KHR_RAY_QUERY_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_QUERY_FEATURES_KHR = 1000000000 + (349 - 1) * 1000 + 13;
  VK_NV_EXTENSION_152_SPEC_VERSION = 0;
  VK_NV_FRAMEBUFFER_MIXED_SAMPLES_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PIPELINE_COVERAGE_MODULATION_STATE_CREATE_INFO_NV = 1000000000 + (153 - 1) * 1000 + 0;
  VK_NV_FILL_RECTANGLE_SPEC_VERSION = 1;
  VK_POLYGON_MODE_FILL_RECTANGLE_NV = 1000000000 + (154 - 1) * 1000 + 0;
  VK_NV_SHADER_SM_BUILTINS_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_SM_BUILTINS_FEATURES_NV = 1000000000 + (155 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_SM_BUILTINS_PROPERTIES_NV = 1000000000 + (155 - 1) * 1000 + 1;
  VK_EXT_POST_DEPTH_COVERAGE_SPEC_VERSION = 1;
  VK_KHR_SAMPLER_YCBCR_CONVERSION_SPEC_VERSION = 14;
  VK_KHR_BIND_MEMORY_2_SPEC_VERSION = 1;
  VK_EXT_IMAGE_DRM_FORMAT_MODIFIER_SPEC_VERSION = 1;
  VK_ERROR_INVALID_DRM_FORMAT_MODIFIER_PLANE_LAYOUT_EXT = - (1000000000 + (159 - 1) * 1000 + 0);
  VK_STRUCTURE_TYPE_DRM_FORMAT_MODIFIER_PROPERTIES_LIST_EXT = 1000000000 + (159 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_DRM_FORMAT_MODIFIER_INFO_EXT = 1000000000 + (159 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_IMAGE_DRM_FORMAT_MODIFIER_LIST_CREATE_INFO_EXT = 1000000000 + (159 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_IMAGE_DRM_FORMAT_MODIFIER_EXPLICIT_CREATE_INFO_EXT = 1000000000 + (159 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_IMAGE_DRM_FORMAT_MODIFIER_PROPERTIES_EXT = 1000000000 + (159 - 1) * 1000 + 5;
  VK_IMAGE_TILING_DRM_FORMAT_MODIFIER_EXT = 1000000000 + (159 - 1) * 1000 + 0;
  VK_IMAGE_ASPECT_MEMORY_PLANE_0_BIT_EXT = 1 shl 7;
  VK_IMAGE_ASPECT_MEMORY_PLANE_1_BIT_EXT = 1 shl 8;
  VK_IMAGE_ASPECT_MEMORY_PLANE_2_BIT_EXT = 1 shl 9;
  VK_IMAGE_ASPECT_MEMORY_PLANE_3_BIT_EXT = 1 shl 10;
  VK_EXT_EXTENSION_160_SPEC_VERSION = 0;
  VK_EXT_VALIDATION_CACHE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_VALIDATION_CACHE_CREATE_INFO_EXT = 1000000000 + (161 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_SHADER_MODULE_VALIDATION_CACHE_CREATE_INFO_EXT = 1000000000 + (161 - 1) * 1000 + 1;
  VK_OBJECT_TYPE_VALIDATION_CACHE_EXT = 1000000000 + (161 - 1) * 1000 + 0;
  VK_EXT_DESCRIPTOR_INDEXING_SPEC_VERSION = 2;
  VK_EXT_SHADER_VIEWPORT_INDEX_LAYER_SPEC_VERSION = 1;
  VK_KHR_PORTABILITY_SUBSET_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PORTABILITY_SUBSET_FEATURES_KHR = 1000000000 + (164 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PORTABILITY_SUBSET_PROPERTIES_KHR = 1000000000 + (164 - 1) * 1000 + 1;
  VK_NV_SHADING_RATE_IMAGE_SPEC_VERSION = 3;
  VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_SHADING_RATE_IMAGE_STATE_CREATE_INFO_NV = 1000000000 + (165 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADING_RATE_IMAGE_FEATURES_NV = 1000000000 + (165 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADING_RATE_IMAGE_PROPERTIES_NV = 1000000000 + (165 - 1) * 1000 + 2;
  VK_DYNAMIC_STATE_VIEWPORT_SHADING_RATE_PALETTE_NV = 1000000000 + (165 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_COARSE_SAMPLE_ORDER_STATE_CREATE_INFO_NV = 1000000000 + (165 - 1) * 1000 + 5;
  VK_DYNAMIC_STATE_VIEWPORT_COARSE_SAMPLE_ORDER_NV = 1000000000 + (165 - 1) * 1000 + 6;
  VK_NV_RAY_TRACING_SPEC_VERSION = 3;
  VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_CREATE_INFO_NV = 1000000000 + (166 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_NV = 1000000000 + (166 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_GEOMETRY_NV = 1000000000 + (166 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_GEOMETRY_TRIANGLES_NV = 1000000000 + (166 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_GEOMETRY_AABB_NV = 1000000000 + (166 - 1) * 1000 + 5;
  VK_STRUCTURE_TYPE_BIND_ACCELERATION_STRUCTURE_MEMORY_INFO_NV = 1000000000 + (166 - 1) * 1000 + 6;
  VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET_ACCELERATION_STRUCTURE_NV = 1000000000 + (166 - 1) * 1000 + 7;
  VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_MEMORY_REQUIREMENTS_INFO_NV = 1000000000 + (166 - 1) * 1000 + 8;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PROPERTIES_NV = 1000000000 + (166 - 1) * 1000 + 9;
  VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_NV = 1000000000 + (166 - 1) * 1000 + 11;
  VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_INFO_NV = 1000000000 + (166 - 1) * 1000 + 12;
  VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_NV = 1000000000 + (166 - 1) * 1000 + 0;
  VK_QUERY_TYPE_ACCELERATION_STRUCTURE_COMPACTED_SIZE_NV = 1000000000 + (166 - 1) * 1000 + 0;
  VK_PIPELINE_CREATE_DEFER_COMPILE_BIT_NV = 1 shl 5;
  VK_OBJECT_TYPE_ACCELERATION_STRUCTURE_NV = 1000000000 + (166 - 1) * 1000 + 0;
  VK_DEBUG_REPORT_OBJECT_TYPE_ACCELERATION_STRUCTURE_NV_EXT = 1000000000 + (166 - 1) * 1000 + 0;
  VK_NV_REPRESENTATIVE_FRAGMENT_TEST_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_REPRESENTATIVE_FRAGMENT_TEST_FEATURES_NV = 1000000000 + (167 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PIPELINE_REPRESENTATIVE_FRAGMENT_TEST_STATE_CREATE_INFO_NV = 1000000000 + (167 - 1) * 1000 + 1;
  VK_EXT_EXTENSION_168_SPEC_VERSION = 0;
  VK_KHR_MAINTENANCE3_SPEC_VERSION = 1;
  VK_KHR_DRAW_INDIRECT_COUNT_SPEC_VERSION = 1;
  VK_EXT_FILTER_CUBIC_SPEC_VERSION = 3;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_VIEW_IMAGE_FORMAT_INFO_EXT = 1000000000 + (171 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_FILTER_CUBIC_IMAGE_VIEW_IMAGE_FORMAT_PROPERTIES_EXT = 1000000000 + (171 - 1) * 1000 + 1;
  VK_QCOM_RENDER_PASS_SHADER_RESOLVE_SPEC_VERSION = 4;
  VK_SUBPASS_DESCRIPTION_FRAGMENT_REGION_BIT_QCOM = 1 shl 2;
  VK_SUBPASS_DESCRIPTION_SHADER_RESOLVE_BIT_QCOM = 1 shl 3;
  VK_QCOM_extension_173_SPEC_VERSION = 0;
  VK_BUFFER_USAGE_RESERVED_18_BIT_QCOM = 1 shl 18;
  VK_IMAGE_USAGE_RESERVED_16_BIT_QCOM = 1 shl 16;
  VK_IMAGE_USAGE_RESERVED_17_BIT_QCOM = 1 shl 17;
  VK_QCOM_extension_174_SPEC_VERSION = 0;
  VK_EXT_GLOBAL_PRIORITY_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_DEVICE_QUEUE_GLOBAL_PRIORITY_CREATE_INFO_EXT = 1000000000 + (175 - 1) * 1000 + 0;
  VK_ERROR_NOT_PERMITTED_EXT = - (1000000000 + (175 - 1) * 1000 + 1);
  VK_KHR_SHADER_SUBGROUP_EXTENDED_TYPES_SPEC_VERSION = 1;
  VK_KHR_EXTENSION_177_SPEC_VERSION = 0;
  VK_KHR_8BIT_STORAGE_SPEC_VERSION = 1;
  VK_EXT_EXTERNAL_MEMORY_HOST_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_IMPORT_MEMORY_HOST_POINTER_INFO_EXT = 1000000000 + (179 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_MEMORY_HOST_POINTER_PROPERTIES_EXT = 1000000000 + (179 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_MEMORY_HOST_PROPERTIES_EXT = 1000000000 + (179 - 1) * 1000 + 2;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_HOST_ALLOCATION_BIT_EXT = 1 shl 7;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_HOST_MAPPED_FOREIGN_MEMORY_BIT_EXT = 1 shl 8;
  VK_AMD_BUFFER_MARKER_SPEC_VERSION = 1;
  VK_KHR_SHADER_ATOMIC_INT64_SPEC_VERSION = 1;
  VK_KHR_SHADER_CLOCK_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_CLOCK_FEATURES_KHR = 1000000000 + (182 - 1) * 1000 + 0;
  VK_KHR_EXTENSION_183_SPEC_VERSION = 0;
  VK_AMD_PIPELINE_COMPILER_CONTROL_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PIPELINE_COMPILER_CONTROL_CREATE_INFO_AMD = 1000000000 + (184 - 1) * 1000 + 0;
  VK_EXT_CALIBRATED_TIMESTAMPS_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_CALIBRATED_TIMESTAMP_INFO_EXT = 1000000000 + (185 - 1) * 1000 + 0;
  VK_AMD_SHADER_CORE_PROPERTIES_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_CORE_PROPERTIES_AMD = 1000000000 + (186 - 1) * 1000 + 0;
  VK_KHR_EXTENSION_187_SPEC_VERSION = 0;
  VK_EXT_VIDEO_DECODE_H265_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_H265_CAPABILITIES_EXT = 1000000000 + (188 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_H265_SESSION_CREATE_INFO_EXT = 1000000000 + (188 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_H265_SESSION_PARAMETERS_CREATE_INFO_EXT = 1000000000 + (188 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_H265_SESSION_PARAMETERS_ADD_INFO_EXT = 1000000000 + (188 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_H265_PROFILE_EXT = 1000000000 + (188 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_H265_PICTURE_INFO_EXT = 1000000000 + (188 - 1) * 1000 + 5;
  VK_STRUCTURE_TYPE_VIDEO_DECODE_H265_DPB_SLOT_INFO_EXT = 1000000000 + (188 - 1) * 1000 + 6;
  VK_VIDEO_CODEC_OPERATION_DECODE_H265_BIT_EXT = 1 shl 1;
  VK_KHR_EXTENSION_189_SPEC_VERSION = 0;
  VK_AMD_MEMORY_OVERALLOCATION_BEHAVIOR_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_DEVICE_MEMORY_OVERALLOCATION_CREATE_INFO_AMD = 1000000000 + (190 - 1) * 1000 + 0;
  VK_EXT_VERTEX_ATTRIBUTE_DIVISOR_SPEC_VERSION = 3;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VERTEX_ATTRIBUTE_DIVISOR_PROPERTIES_EXT = 1000000000 + (191 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_DIVISOR_STATE_CREATE_INFO_EXT = 1000000000 + (191 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VERTEX_ATTRIBUTE_DIVISOR_FEATURES_EXT = 1000000000 + (191 - 1) * 1000 + 2;
  VK_GGP_FRAME_TOKEN_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PRESENT_FRAME_TOKEN_GGP = 1000000000 + (192 - 1) * 1000 + 0;
  VK_EXT_PIPELINE_CREATION_FEEDBACK_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PIPELINE_CREATION_FEEDBACK_CREATE_INFO_EXT = 1000000000 + (193 - 1) * 1000 + 0;
  VK_GOOGLE_EXTENSION_194_SPEC_VERSION = 0;
  VK_GOOGLE_EXTENSION_195_SPEC_VERSION = 0;
  VK_GOOGLE_EXTENSION_196_SPEC_VERSION = 0;
  VK_PIPELINE_CACHE_CREATE_RESERVED_1_BIT_EXT = 1 shl 1;
  VK_KHR_DRIVER_PROPERTIES_SPEC_VERSION = 1;
  VK_KHR_SHADER_FLOAT_CONTROLS_SPEC_VERSION = 4;
  VK_NV_SHADER_SUBGROUP_PARTITIONED_SPEC_VERSION = 1;
  VK_SUBGROUP_FEATURE_PARTITIONED_BIT_NV = 1 shl 8;
  VK_KHR_DEPTH_STENCIL_RESOLVE_SPEC_VERSION = 1;
  VK_KHR_SWAPCHAIN_MUTABLE_FORMAT_SPEC_VERSION = 1;
  VK_SWAPCHAIN_CREATE_MUTABLE_FORMAT_BIT_KHR = 1 shl 2;
  VK_NV_COMPUTE_SHADER_DERIVATIVES_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COMPUTE_SHADER_DERIVATIVES_FEATURES_NV = 1000000000 + (202 - 1) * 1000 + 0;
  VK_NV_MESH_SHADER_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MESH_SHADER_FEATURES_NV = 1000000000 + (203 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MESH_SHADER_PROPERTIES_NV = 1000000000 + (203 - 1) * 1000 + 1;
  VK_SHADER_STAGE_TASK_BIT_NV = 1 shl 6;
  VK_SHADER_STAGE_MESH_BIT_NV = 1 shl 7;
  VK_PIPELINE_STAGE_TASK_SHADER_BIT_NV = 1 shl 19;
  VK_PIPELINE_STAGE_MESH_SHADER_BIT_NV = 1 shl 20;
  VK_NV_FRAGMENT_SHADER_BARYCENTRIC_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADER_BARYCENTRIC_FEATURES_NV = 1000000000 + (204 - 1) * 1000 + 0;
  VK_NV_SHADER_IMAGE_FOOTPRINT_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_IMAGE_FOOTPRINT_FEATURES_NV = 1000000000 + (205 - 1) * 1000 + 0;
  VK_NV_SCISSOR_EXCLUSIVE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_EXCLUSIVE_SCISSOR_STATE_CREATE_INFO_NV = 1000000000 + (206 - 1) * 1000 + 0;
  VK_DYNAMIC_STATE_EXCLUSIVE_SCISSOR_NV = 1000000000 + (206 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXCLUSIVE_SCISSOR_FEATURES_NV = 1000000000 + (206 - 1) * 1000 + 2;
  VK_NV_DEVICE_DIAGNOSTIC_CHECKPOINTS_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_CHECKPOINT_DATA_NV = 1000000000 + (207 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_QUEUE_FAMILY_CHECKPOINT_PROPERTIES_NV = 1000000000 + (207 - 1) * 1000 + 1;
  VK_KHR_TIMELINE_SEMAPHORE_SPEC_VERSION = 2;
  VK_KHR_EXTENSION_209_SPEC_VERSION = 0;
  VK_INTEL_SHADER_INTEGER_FUNCTIONS_2_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_INTEGER_FUNCTIONS_2_FEATURES_INTEL = 1000000000 + (210 - 1) * 1000 + 0;
  VK_INTEL_PERFORMANCE_QUERY_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_QUERY_POOL_PERFORMANCE_QUERY_CREATE_INFO_INTEL = 1000000000 + (211 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_INITIALIZE_PERFORMANCE_API_INFO_INTEL = 1000000000 + (211 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PERFORMANCE_MARKER_INFO_INTEL = 1000000000 + (211 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_PERFORMANCE_STREAM_MARKER_INFO_INTEL = 1000000000 + (211 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_PERFORMANCE_OVERRIDE_INFO_INTEL = 1000000000 + (211 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_PERFORMANCE_CONFIGURATION_ACQUIRE_INFO_INTEL = 1000000000 + (211 - 1) * 1000 + 5;
  VK_QUERY_TYPE_PERFORMANCE_QUERY_INTEL = 1000000000 + (211 - 1) * 1000 + 0;
  VK_OBJECT_TYPE_PERFORMANCE_CONFIGURATION_INTEL = 1000000000 + (211 - 1) * 1000 + 0;
  VK_KHR_VULKAN_MEMORY_MODEL_SPEC_VERSION = 3;
  VK_EXT_PCI_BUS_INFO_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PCI_BUS_INFO_PROPERTIES_EXT = 1000000000 + (213 - 1) * 1000 + 0;
  VK_AMD_DISPLAY_NATIVE_HDR_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_DISPLAY_NATIVE_HDR_SURFACE_CAPABILITIES_AMD = 1000000000 + (214 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_SWAPCHAIN_DISPLAY_NATIVE_HDR_CREATE_INFO_AMD = 1000000000 + (214 - 1) * 1000 + 1;
  VK_COLOR_SPACE_DISPLAY_NATIVE_AMD = 1000000000 + (214 - 1) * 1000 + 0;
  VK_FUCHSIA_IMAGEPIPE_SURFACE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_IMAGEPIPE_SURFACE_CREATE_INFO_FUCHSIA = 1000000000 + (215 - 1) * 1000 + 0;
  VK_KHR_SHADER_TERMINATE_INVOCATION_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_TERMINATE_INVOCATION_FEATURES_KHR = 1000000000 + (216 - 1) * 1000 + 0;
  VK_KHR_EXTENSION_217_SPEC_VERSION = 0;
  VK_EXT_METAL_SURFACE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_METAL_SURFACE_CREATE_INFO_EXT = 1000000000 + (218 - 1) * 1000 + 0;
  VK_EXT_FRAGMENT_DENSITY_MAP_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_DENSITY_MAP_FEATURES_EXT = 1000000000 + (219 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_DENSITY_MAP_PROPERTIES_EXT = 1000000000 + (219 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_RENDER_PASS_FRAGMENT_DENSITY_MAP_CREATE_INFO_EXT = 1000000000 + (219 - 1) * 1000 + 2;
  VK_IMAGE_CREATE_SUBSAMPLED_BIT_EXT = 1 shl 14;
  VK_IMAGE_LAYOUT_FRAGMENT_DENSITY_MAP_OPTIMAL_EXT = 1000000000 + (219 - 1) * 1000 + 0;
  VK_ACCESS_FRAGMENT_DENSITY_MAP_READ_BIT_EXT = 1 shl 24;
  VK_FORMAT_FEATURE_FRAGMENT_DENSITY_MAP_BIT_EXT = 1 shl 24;
  VK_IMAGE_USAGE_FRAGMENT_DENSITY_MAP_BIT_EXT = 1 shl 9;
  VK_IMAGE_VIEW_CREATE_FRAGMENT_DENSITY_MAP_DYNAMIC_BIT_EXT = 1 shl 0;
  VK_PIPELINE_STAGE_FRAGMENT_DENSITY_PROCESS_BIT_EXT = 1 shl 23;
  VK_SAMPLER_CREATE_SUBSAMPLED_BIT_EXT = 1 shl 0;
  VK_SAMPLER_CREATE_SUBSAMPLED_COARSE_RECONSTRUCTION_BIT_EXT = 1 shl 1;
  VK_EXT_EXTENSION_220_SPEC_VERSION = 0;
  VK_KHR_EXTENSION_221_SPEC_VERSION = 0;
  VK_RENDER_PASS_CREATE_RESERVED_0_BIT_KHR = 1 shl 0;
  VK_EXT_SCALAR_BLOCK_LAYOUT_SPEC_VERSION = 1;
  VK_EXT_EXTENSION_223_SPEC_VERSION = 0;
  VK_GOOGLE_HLSL_FUNCTIONALITY1_SPEC_VERSION = 1;
  VK_GOOGLE_DECORATE_STRING_SPEC_VERSION = 1;
  VK_EXT_SUBGROUP_SIZE_CONTROL_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBGROUP_SIZE_CONTROL_PROPERTIES_EXT = 1000000000 + (226 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_REQUIRED_SUBGROUP_SIZE_CREATE_INFO_EXT = 1000000000 + (226 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBGROUP_SIZE_CONTROL_FEATURES_EXT = 1000000000 + (226 - 1) * 1000 + 2;
  VK_PIPELINE_SHADER_STAGE_CREATE_ALLOW_VARYING_SUBGROUP_SIZE_BIT_EXT = 1 shl 0;
  VK_PIPELINE_SHADER_STAGE_CREATE_REQUIRE_FULL_SUBGROUPS_BIT_EXT = 1 shl 1;
  VK_KHR_FRAGMENT_SHADING_RATE_SPEC_VERSION = 1;
  VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR = 1000000000 + (165 - 1) * 1000 + 3;
  VK_DYNAMIC_STATE_FRAGMENT_SHADING_RATE_KHR = 1000000000 + (227 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_FRAGMENT_SHADING_RATE_ATTACHMENT_INFO_KHR = 1000000000 + (227 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PIPELINE_FRAGMENT_SHADING_RATE_STATE_CREATE_INFO_KHR = 1000000000 + (227 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_PROPERTIES_KHR = 1000000000 + (227 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_FEATURES_KHR = 1000000000 + (227 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_KHR = 1000000000 + (227 - 1) * 1000 + 4;
  VK_ACCESS_FRAGMENT_SHADING_RATE_ATTACHMENT_READ_BIT_KHR = 1 shl 23;
  VK_IMAGE_USAGE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR = 1 shl 8;
  VK_PIPELINE_STAGE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR = 1 shl 22;
  VK_FORMAT_FEATURE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR = 1 shl 30;
  VK_AMD_SHADER_CORE_PROPERTIES_2_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_CORE_PROPERTIES_2_AMD = 1000000000 + (228 - 1) * 1000 + 0;
  VK_AMD_EXTENSION_229_SPEC_VERSION = 0;
  VK_AMD_DEVICE_COHERENT_MEMORY_SPEC_VERSION = 1;
  VK_MEMORY_PROPERTY_DEVICE_COHERENT_BIT_AMD = 1 shl 6;
  VK_MEMORY_PROPERTY_DEVICE_UNCACHED_BIT_AMD = 1 shl 7;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COHERENT_MEMORY_FEATURES_AMD = 1000000000 + (230 - 1) * 1000 + 0;
  VK_AMD_EXTENSION_231_SPEC_VERSION = 0;
  VK_AMD_EXTENSION_232_SPEC_VERSION = 0;
  VK_AMD_EXTENSION_233_SPEC_VERSION = 0;
  VK_AMD_EXTENSION_234_SPEC_VERSION = 0;
  VK_EXT_SHADER_IMAGE_ATOMIC_INT64_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_IMAGE_ATOMIC_INT64_FEATURES_EXT = 1000000000 + (235 - 1) * 1000 + 0;
  VK_AMD_EXTENSION_236_SPEC_VERSION = 0;
  VK_KHR_SPIRV_1_4_SPEC_VERSION = 1;
  VK_EXT_MEMORY_BUDGET_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MEMORY_BUDGET_PROPERTIES_EXT = 1000000000 + (238 - 1) * 1000 + 0;
  VK_EXT_MEMORY_PRIORITY_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MEMORY_PRIORITY_FEATURES_EXT = 1000000000 + (239 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_MEMORY_PRIORITY_ALLOCATE_INFO_EXT = 1000000000 + (239 - 1) * 1000 + 1;
  VK_KHR_SURFACE_PROTECTED_CAPABILITIES_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_SURFACE_PROTECTED_CAPABILITIES_KHR = 1000000000 + (240 - 1) * 1000 + 0;
  VK_NV_DEDICATED_ALLOCATION_IMAGE_ALIASING_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEDICATED_ALLOCATION_IMAGE_ALIASING_FEATURES_NV = 1000000000 + (241 - 1) * 1000 + 0;
  VK_KHR_SEPARATE_DEPTH_STENCIL_LAYOUTS_SPEC_VERSION = 1;
  VK_INTEL_EXTENSION_243_SPEC_VERSION = 0;
  VK_MESA_EXTENSION_244_SPEC_VERSION = 0;
  VK_EXT_BUFFER_DEVICE_ADDRESS_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BUFFER_DEVICE_ADDRESS_FEATURES_EXT = 1000000000 + (245 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_CREATE_INFO_EXT = 1000000000 + (245 - 1) * 1000 + 2;
  VK_EXT_TOOLING_INFO_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TOOL_PROPERTIES_EXT = 1000000000 + (246 - 1) * 1000 + 0;
  VK_TOOL_PURPOSE_DEBUG_REPORTING_BIT_EXT = 1 shl 5;
  VK_TOOL_PURPOSE_DEBUG_MARKERS_BIT_EXT = 1 shl 6;
  VK_EXT_SEPARATE_STENCIL_USAGE_SPEC_VERSION = 1;
  VK_EXT_VALIDATION_FEATURES_SPEC_VERSION = 5;
  VK_STRUCTURE_TYPE_VALIDATION_FEATURES_EXT = 1000000000 + (248 - 1) * 1000 + 0;
  VK_KHR_PRESENT_WAIT_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PRESENT_WAIT_FEATURES_KHR = 1000000000 + (249 - 1) * 1000 + 0;
  VK_NV_COOPERATIVE_MATRIX_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COOPERATIVE_MATRIX_FEATURES_NV = 1000000000 + (250 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_COOPERATIVE_MATRIX_PROPERTIES_NV = 1000000000 + (250 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COOPERATIVE_MATRIX_PROPERTIES_NV = 1000000000 + (250 - 1) * 1000 + 2;
  VK_NV_COVERAGE_REDUCTION_MODE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COVERAGE_REDUCTION_MODE_FEATURES_NV = 1000000000 + (251 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PIPELINE_COVERAGE_REDUCTION_STATE_CREATE_INFO_NV = 1000000000 + (251 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_FRAMEBUFFER_MIXED_SAMPLES_COMBINATION_NV = 1000000000 + (251 - 1) * 1000 + 2;
  VK_EXT_FRAGMENT_SHADER_INTERLOCK_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADER_INTERLOCK_FEATURES_EXT = 1000000000 + (252 - 1) * 1000 + 0;
  VK_EXT_YCBCR_IMAGE_ARRAYS_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_YCBCR_IMAGE_ARRAYS_FEATURES_EXT = 1000000000 + (253 - 1) * 1000 + 0;
  VK_KHR_UNIFORM_BUFFER_STANDARD_LAYOUT_SPEC_VERSION = 1;
  VK_EXT_PROVOKING_VERTEX_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROVOKING_VERTEX_FEATURES_EXT = 1000000000 + (255 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_PROVOKING_VERTEX_STATE_CREATE_INFO_EXT = 1000000000 + (255 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROVOKING_VERTEX_PROPERTIES_EXT = 1000000000 + (255 - 1) * 1000 + 2;
  VK_EXT_FULL_SCREEN_EXCLUSIVE_SPEC_VERSION = 4;
  VK_STRUCTURE_TYPE_SURFACE_FULL_SCREEN_EXCLUSIVE_INFO_EXT = 1000000000 + (256 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_SURFACE_CAPABILITIES_FULL_SCREEN_EXCLUSIVE_EXT = 1000000000 + (256 - 1) * 1000 + 2;
  VK_ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT = - (1000000000 + (256 - 1) * 1000 + 0);
  VK_STRUCTURE_TYPE_SURFACE_FULL_SCREEN_EXCLUSIVE_WIN32_INFO_EXT = 1000000000 + (256 - 1) * 1000 + 1;
  VK_EXT_HEADLESS_SURFACE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_HEADLESS_SURFACE_CREATE_INFO_EXT = 1000000000 + (257 - 1) * 1000 + 0;
  VK_KHR_BUFFER_DEVICE_ADDRESS_SPEC_VERSION = 1;
  VK_EXT_EXTENSION_259_SPEC_VERSION = 0;
  VK_EXT_LINE_RASTERIZATION_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_LINE_RASTERIZATION_FEATURES_EXT = 1000000000 + (260 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_LINE_STATE_CREATE_INFO_EXT = 1000000000 + (260 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_LINE_RASTERIZATION_PROPERTIES_EXT = 1000000000 + (260 - 1) * 1000 + 2;
  VK_DYNAMIC_STATE_LINE_STIPPLE_EXT = 1000000000 + (260 - 1) * 1000 + 0;
  VK_EXT_SHADER_ATOMIC_FLOAT_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_ATOMIC_FLOAT_FEATURES_EXT = 1000000000 + (261 - 1) * 1000 + 0;
  VK_EXT_HOST_QUERY_RESET_SPEC_VERSION = 1;
  VK_GOOGLE_EXTENSION_263_SPEC_VERSION = 0;
  VK_BRCM_EXTENSION_264_SPEC_VERSION = 0;
  VK_BRCM_EXTENSION_265_SPEC_VERSION = 0;
  VK_EXT_INDEX_TYPE_UINT8_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_INDEX_TYPE_UINT8_FEATURES_EXT = 1000000000 + (266 - 1) * 1000 + 0;
  VK_INDEX_TYPE_UINT8_EXT = 1000000000 + (266 - 1) * 1000 + 0;
  VK_EXT_EXTENSION_267_SPEC_VERSION = 0;
  VK_EXT_EXTENDED_DYNAMIC_STATE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_FEATURES_EXT = 1000000000 + (268 - 1) * 1000 + 0;
  VK_DYNAMIC_STATE_CULL_MODE_EXT = 1000000000 + (268 - 1) * 1000 + 0;
  VK_DYNAMIC_STATE_FRONT_FACE_EXT = 1000000000 + (268 - 1) * 1000 + 1;
  VK_DYNAMIC_STATE_PRIMITIVE_TOPOLOGY_EXT = 1000000000 + (268 - 1) * 1000 + 2;
  VK_DYNAMIC_STATE_VIEWPORT_WITH_COUNT_EXT = 1000000000 + (268 - 1) * 1000 + 3;
  VK_DYNAMIC_STATE_SCISSOR_WITH_COUNT_EXT = 1000000000 + (268 - 1) * 1000 + 4;
  VK_DYNAMIC_STATE_VERTEX_INPUT_BINDING_STRIDE_EXT = 1000000000 + (268 - 1) * 1000 + 5;
  VK_DYNAMIC_STATE_DEPTH_TEST_ENABLE_EXT = 1000000000 + (268 - 1) * 1000 + 6;
  VK_DYNAMIC_STATE_DEPTH_WRITE_ENABLE_EXT = 1000000000 + (268 - 1) * 1000 + 7;
  VK_DYNAMIC_STATE_DEPTH_COMPARE_OP_EXT = 1000000000 + (268 - 1) * 1000 + 8;
  VK_DYNAMIC_STATE_DEPTH_BOUNDS_TEST_ENABLE_EXT = 1000000000 + (268 - 1) * 1000 + 9;
  VK_DYNAMIC_STATE_STENCIL_TEST_ENABLE_EXT = 1000000000 + (268 - 1) * 1000 + 10;
  VK_DYNAMIC_STATE_STENCIL_OP_EXT = 1000000000 + (268 - 1) * 1000 + 11;
  VK_KHR_DEFERRED_HOST_OPERATIONS_SPEC_VERSION = 4;
  VK_OBJECT_TYPE_DEFERRED_OPERATION_KHR = 1000000000 + (269 - 1) * 1000 + 0;
  VK_THREAD_IDLE_KHR = 1000000000 + (269 - 1) * 1000 + 0;
  VK_THREAD_DONE_KHR = 1000000000 + (269 - 1) * 1000 + 1;
  VK_OPERATION_DEFERRED_KHR = 1000000000 + (269 - 1) * 1000 + 2;
  VK_OPERATION_NOT_DEFERRED_KHR = 1000000000 + (269 - 1) * 1000 + 3;
  VK_KHR_PIPELINE_EXECUTABLE_PROPERTIES_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PIPELINE_EXECUTABLE_PROPERTIES_FEATURES_KHR = 1000000000 + (270 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PIPELINE_INFO_KHR = 1000000000 + (270 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PIPELINE_EXECUTABLE_PROPERTIES_KHR = 1000000000 + (270 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_PIPELINE_EXECUTABLE_INFO_KHR = 1000000000 + (270 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_PIPELINE_EXECUTABLE_STATISTIC_KHR = 1000000000 + (270 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_PIPELINE_EXECUTABLE_INTERNAL_REPRESENTATION_KHR = 1000000000 + (270 - 1) * 1000 + 5;
  VK_PIPELINE_CREATE_CAPTURE_STATISTICS_BIT_KHR = 1 shl 6;
  VK_PIPELINE_CREATE_CAPTURE_INTERNAL_REPRESENTATIONS_BIT_KHR = 1 shl 7;
  VK_INTEL_EXTENSION_271_SPEC_VERSION = 0;
  VK_INTEL_EXTENSION_272_SPEC_VERSION = 0;
  VK_INTEL_EXTENSION_273_SPEC_VERSION = 0;
  VK_EXT_SHADER_ATOMIC_FLOAT_2_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_ATOMIC_FLOAT_2_FEATURES_EXT = 1000000000 + (274 - 1) * 1000 + 0;
  VK_KHR_EXTENSION_275_SPEC_VERSION = 0;
  VK_KHR_EXTENSION_276_SPEC_VERSION = 0;
  VK_EXT_SHADER_DEMOTE_TO_HELPER_INVOCATION_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_DEMOTE_TO_HELPER_INVOCATION_FEATURES_EXT = 1000000000 + (277 - 1) * 1000 + 0;
  VK_NV_DEVICE_GENERATED_COMMANDS_SPEC_VERSION = 3;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEVICE_GENERATED_COMMANDS_PROPERTIES_NV = 1000000000 + (278 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_GRAPHICS_SHADER_GROUP_CREATE_INFO_NV = 1000000000 + (278 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_SHADER_GROUPS_CREATE_INFO_NV = 1000000000 + (278 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_INDIRECT_COMMANDS_LAYOUT_TOKEN_NV = 1000000000 + (278 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_INDIRECT_COMMANDS_LAYOUT_CREATE_INFO_NV = 1000000000 + (278 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_GENERATED_COMMANDS_INFO_NV = 1000000000 + (278 - 1) * 1000 + 5;
  VK_STRUCTURE_TYPE_GENERATED_COMMANDS_MEMORY_REQUIREMENTS_INFO_NV = 1000000000 + (278 - 1) * 1000 + 6;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEVICE_GENERATED_COMMANDS_FEATURES_NV = 1000000000 + (278 - 1) * 1000 + 7;
  VK_PIPELINE_CREATE_INDIRECT_BINDABLE_BIT_NV = 1 shl 18;
  VK_PIPELINE_STAGE_COMMAND_PREPROCESS_BIT_NV = 1 shl 17;
  VK_ACCESS_COMMAND_PREPROCESS_READ_BIT_NV = 1 shl 17;
  VK_ACCESS_COMMAND_PREPROCESS_WRITE_BIT_NV = 1 shl 18;
  VK_OBJECT_TYPE_INDIRECT_COMMANDS_LAYOUT_NV = 1000000000 + (278 - 1) * 1000 + 0;
  VK_NV_INHERITED_VIEWPORT_SCISSOR_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_INHERITED_VIEWPORT_SCISSOR_FEATURES_NV = 1000000000 + (279 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_VIEWPORT_SCISSOR_INFO_NV = 1000000000 + (279 - 1) * 1000 + 1;
  VK_KHR_EXTENSION_280_SPEC_VERSION = 0;
  VK_ARM_EXTENSION_281_SPEC_VERSION = 0;
  VK_EXT_TEXEL_BUFFER_ALIGNMENT_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TEXEL_BUFFER_ALIGNMENT_FEATURES_EXT = 1000000000 + (282 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TEXEL_BUFFER_ALIGNMENT_PROPERTIES_EXT = 1000000000 + (282 - 1) * 1000 + 1;
  VK_QCOM_RENDER_PASS_TRANSFORM_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_RENDER_PASS_TRANSFORM_INFO_QCOM = 1000000000 + (283 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_RENDER_PASS_TRANSFORM_BEGIN_INFO_QCOM = 1000000000 + (283 - 1) * 1000 + 1;
  VK_RENDER_PASS_CREATE_TRANSFORM_BIT_QCOM = 1 shl 1;
  VK_EXT_EXTENSION_284_SPEC_VERSION = 0;
  VK_EXT_DEVICE_MEMORY_REPORT_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEVICE_MEMORY_REPORT_FEATURES_EXT = 1000000000 + (285 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_DEVICE_DEVICE_MEMORY_REPORT_CREATE_INFO_EXT = 1000000000 + (285 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_DEVICE_MEMORY_REPORT_CALLBACK_DATA_EXT = 1000000000 + (285 - 1) * 1000 + 2;
  VK_EXT_ACQUIRE_DRM_DISPLAY_SPEC_VERSION = 1;
  VK_EXT_ROBUSTNESS_2_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ROBUSTNESS_2_FEATURES_EXT = 1000000000 + (287 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ROBUSTNESS_2_PROPERTIES_EXT = 1000000000 + (287 - 1) * 1000 + 1;
  VK_EXT_CUSTOM_BORDER_COLOR_SPEC_VERSION = 12;
  VK_STRUCTURE_TYPE_SAMPLER_CUSTOM_BORDER_COLOR_CREATE_INFO_EXT = 1000000000 + (288 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CUSTOM_BORDER_COLOR_PROPERTIES_EXT = 1000000000 + (288 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CUSTOM_BORDER_COLOR_FEATURES_EXT = 1000000000 + (288 - 1) * 1000 + 2;
  VK_BORDER_COLOR_FLOAT_CUSTOM_EXT = 1000000000 + (288 - 1) * 1000 + 3;
  VK_BORDER_COLOR_INT_CUSTOM_EXT = 1000000000 + (288 - 1) * 1000 + 4;
  VK_EXT_EXTENSION_289_SPEC_VERSION = 0;
  VK_FORMAT_ASTC_3x3x3_UNORM_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 0;
  VK_FORMAT_ASTC_3x3x3_SRGB_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 1;
  VK_FORMAT_ASTC_3x3x3_SFLOAT_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 2;
  VK_FORMAT_ASTC_4x3x3_UNORM_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 3;
  VK_FORMAT_ASTC_4x3x3_SRGB_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 4;
  VK_FORMAT_ASTC_4x3x3_SFLOAT_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 5;
  VK_FORMAT_ASTC_4x4x3_UNORM_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 6;
  VK_FORMAT_ASTC_4x4x3_SRGB_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 7;
  VK_FORMAT_ASTC_4x4x3_SFLOAT_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 8;
  VK_FORMAT_ASTC_4x4x4_UNORM_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 9;
  VK_FORMAT_ASTC_4x4x4_SRGB_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 10;
  VK_FORMAT_ASTC_4x4x4_SFLOAT_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 11;
  VK_FORMAT_ASTC_5x4x4_UNORM_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 12;
  VK_FORMAT_ASTC_5x4x4_SRGB_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 13;
  VK_FORMAT_ASTC_5x4x4_SFLOAT_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 14;
  VK_FORMAT_ASTC_5x5x4_UNORM_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 15;
  VK_FORMAT_ASTC_5x5x4_SRGB_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 16;
  VK_FORMAT_ASTC_5x5x4_SFLOAT_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 17;
  VK_FORMAT_ASTC_5x5x5_UNORM_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 18;
  VK_FORMAT_ASTC_5x5x5_SRGB_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 19;
  VK_FORMAT_ASTC_5x5x5_SFLOAT_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 20;
  VK_FORMAT_ASTC_6x5x5_UNORM_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 21;
  VK_FORMAT_ASTC_6x5x5_SRGB_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 22;
  VK_FORMAT_ASTC_6x5x5_SFLOAT_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 23;
  VK_FORMAT_ASTC_6x6x5_UNORM_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 24;
  VK_FORMAT_ASTC_6x6x5_SRGB_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 25;
  VK_FORMAT_ASTC_6x6x5_SFLOAT_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 26;
  VK_FORMAT_ASTC_6x6x6_UNORM_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 27;
  VK_FORMAT_ASTC_6x6x6_SRGB_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 28;
  VK_FORMAT_ASTC_6x6x6_SFLOAT_BLOCK_EXT = 1000000000 + (289 - 1) * 1000 + 29;
  VK_GOOGLE_USER_TYPE_SPEC_VERSION = 1;
  VK_KHR_PIPELINE_LIBRARY_SPEC_VERSION = 1;
  VK_PIPELINE_CREATE_LIBRARY_BIT_KHR = 1 shl 11;
  VK_STRUCTURE_TYPE_PIPELINE_LIBRARY_CREATE_INFO_KHR = 1000000000 + (291 - 1) * 1000 + 0;
  VK_NV_EXTENSION_292_SPEC_VERSION = 0;
  VK_NV_EXTENSION_293_SPEC_VERSION = 0;
  VK_KHR_SHADER_NON_SEMANTIC_INFO_SPEC_VERSION = 1;
  VK_KHR_PRESENT_ID_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PRESENT_ID_KHR = 1000000000 + (295 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PRESENT_ID_FEATURES_KHR = 1000000000 + (295 - 1) * 1000 + 1;
  VK_EXT_PRIVATE_DATA_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PRIVATE_DATA_FEATURES_EXT = 1000000000 + (296 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_DEVICE_PRIVATE_DATA_CREATE_INFO_EXT = 1000000000 + (296 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PRIVATE_DATA_SLOT_CREATE_INFO_EXT = 1000000000 + (296 - 1) * 1000 + 2;
  VK_OBJECT_TYPE_PRIVATE_DATA_SLOT_EXT = 1000000000 + (296 - 1) * 1000 + 0;
  VK_KHR_EXTENSION_297_SPEC_VERSION = 0;
  VK_PIPELINE_SHADER_STAGE_CREATE_RESERVED_3_BIT_KHR = 1 shl 3;
  VK_EXT_PIPELINE_CREATION_CACHE_CONTROL_SPEC_VERSION = 3;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PIPELINE_CREATION_CACHE_CONTROL_FEATURES_EXT = 1000000000 + (298 - 1) * 1000 + 0;
  VK_PIPELINE_CREATE_FAIL_ON_PIPELINE_COMPILE_REQUIRED_BIT_EXT = 1 shl 8;
  VK_PIPELINE_CREATE_EARLY_RETURN_ON_FAILURE_BIT_EXT = 1 shl 9;
  VK_PIPELINE_COMPILE_REQUIRED_EXT = 1000000000 + (298 - 1) * 1000 + 0;
  VK_PIPELINE_CACHE_CREATE_EXTERNALLY_SYNCHRONIZED_BIT_EXT = 1 shl 0;
  VK_KHR_EXTENSION_299_SPEC_VERSION = 0;
  VK_MEMORY_HEAP_RESERVED_2_BIT_KHR = 1 shl 2;
  VK_PIPELINE_CACHE_CREATE_RESERVED_2_BIT_KHR = 1 shl 2;
  VK_KHR_VIDEO_ENCODE_QUEUE_SPEC_VERSION = 2;
  VK_PIPELINE_STAGE_2_VIDEO_ENCODE_BIT_KHR = 1 shl 27;
  VK_ACCESS_2_VIDEO_ENCODE_READ_BIT_KHR = 1 shl 37;
  VK_ACCESS_2_VIDEO_ENCODE_WRITE_BIT_KHR = 1 shl 38;
  VK_STRUCTURE_TYPE_VIDEO_ENCODE_INFO_KHR = 1000000000 + (300 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_VIDEO_ENCODE_RATE_CONTROL_INFO_KHR = 1000000000 + (300 - 1) * 1000 + 1;
  VK_QUEUE_VIDEO_ENCODE_BIT_KHR = 1 shl 6;
  VK_BUFFER_USAGE_VIDEO_ENCODE_DST_BIT_KHR = 1 shl 15;
  VK_BUFFER_USAGE_VIDEO_ENCODE_SRC_BIT_KHR = 1 shl 16;
  VK_IMAGE_USAGE_VIDEO_ENCODE_DST_BIT_KHR = 1 shl 13;
  VK_IMAGE_USAGE_VIDEO_ENCODE_SRC_BIT_KHR = 1 shl 14;
  VK_IMAGE_USAGE_VIDEO_ENCODE_DPB_BIT_KHR = 1 shl 15;
  VK_FORMAT_FEATURE_VIDEO_ENCODE_INPUT_BIT_KHR = 1 shl 27;
  VK_FORMAT_FEATURE_VIDEO_ENCODE_DPB_BIT_KHR = 1 shl 28;
  VK_IMAGE_LAYOUT_VIDEO_ENCODE_DST_KHR = 1000000000 + (300 - 1) * 1000 + 0;
  VK_IMAGE_LAYOUT_VIDEO_ENCODE_SRC_KHR = 1000000000 + (300 - 1) * 1000 + 1;
  VK_IMAGE_LAYOUT_VIDEO_ENCODE_DPB_KHR = 1000000000 + (300 - 1) * 1000 + 2;
  VK_QUERY_TYPE_VIDEO_ENCODE_BITSTREAM_BUFFER_RANGE_KHR = 1000000000 + (300 - 1) * 1000 + 0;
  VK_NV_DEVICE_DIAGNOSTICS_CONFIG_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DIAGNOSTICS_CONFIG_FEATURES_NV = 1000000000 + (301 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_DEVICE_DIAGNOSTICS_CONFIG_CREATE_INFO_NV = 1000000000 + (301 - 1) * 1000 + 1;
  VK_QCOM_RENDER_PASS_STORE_OPS_SPEC_VERSION = 2;
  VK_QCOM_extension_303_SPEC_VERSION = 0;
  VK_QCOM_extension_304_SPEC_VERSION = 0;
  VK_QCOM_extension_305_SPEC_VERSION = 0;
  VK_QCOM_extension_306_SPEC_VERSION = 0;
  VK_QCOM_extension_307_SPEC_VERSION = 0;
  VK_NV_EXTENSION_308_SPEC_VERSION = 0;
  VK_KHR_EXTENSION_309_SPEC_VERSION = 0;
  VK_QCOM_extension_310_SPEC_VERSION = 0;
  VK_STRUCTURE_TYPE_RESERVED_QCOM = 1000000000 + (310 - 1) * 1000 + 0;
  VK_NV_EXTENSION_311_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_312_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_313_SPEC_VERSION = 0;
  VK_AMD_EXTENSION_314_SPEC_VERSION = 0;
  VK_KHR_SYNCHRONIZATION_2_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_MEMORY_BARRIER_2_KHR = 1000000000 + (315 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER_2_KHR = 1000000000 + (315 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER_2_KHR = 1000000000 + (315 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_DEPENDENCY_INFO_KHR = 1000000000 + (315 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_SUBMIT_INFO_2_KHR = 1000000000 + (315 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_SEMAPHORE_SUBMIT_INFO_KHR = 1000000000 + (315 - 1) * 1000 + 5;
  VK_STRUCTURE_TYPE_COMMAND_BUFFER_SUBMIT_INFO_KHR = 1000000000 + (315 - 1) * 1000 + 6;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SYNCHRONIZATION_2_FEATURES_KHR = 1000000000 + (315 - 1) * 1000 + 7;
  VK_EVENT_CREATE_DEVICE_ONLY_BIT_KHR = 1 shl 0;
  VK_IMAGE_LAYOUT_READ_ONLY_OPTIMAL_KHR = 1000000000 + (315 - 1) * 1000 + 0;
  VK_IMAGE_LAYOUT_ATTACHMENT_OPTIMAL_KHR = 1000000000 + (315 - 1) * 1000 + 1;
  VK_PIPELINE_STAGE_NONE_KHR = 0;
  VK_ACCESS_NONE_KHR = 0;
  VK_PIPELINE_STAGE_2_TRANSFORM_FEEDBACK_BIT_EXT = 1 shl 24;
  VK_ACCESS_2_TRANSFORM_FEEDBACK_WRITE_BIT_EXT = 1 shl 25;
  VK_ACCESS_2_TRANSFORM_FEEDBACK_COUNTER_READ_BIT_EXT = 1 shl 26;
  VK_ACCESS_2_TRANSFORM_FEEDBACK_COUNTER_WRITE_BIT_EXT = 1 shl 27;
  VK_PIPELINE_STAGE_2_CONDITIONAL_RENDERING_BIT_EXT = 1 shl 18;
  VK_ACCESS_2_CONDITIONAL_RENDERING_READ_BIT_EXT = 1 shl 20;
  VK_PIPELINE_STAGE_2_COMMAND_PREPROCESS_BIT_NV = 1 shl 17;
  VK_ACCESS_2_COMMAND_PREPROCESS_READ_BIT_NV = 1 shl 17;
  VK_ACCESS_2_COMMAND_PREPROCESS_WRITE_BIT_NV = 1 shl 18;
  VK_PIPELINE_STAGE_2_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR = 1 shl 22;
  VK_ACCESS_2_FRAGMENT_SHADING_RATE_ATTACHMENT_READ_BIT_KHR = 1 shl 23;
  VK_PIPELINE_STAGE_2_ACCELERATION_STRUCTURE_BUILD_BIT_KHR = 1 shl 25;
  VK_ACCESS_2_ACCELERATION_STRUCTURE_READ_BIT_KHR = 1 shl 21;
  VK_ACCESS_2_ACCELERATION_STRUCTURE_WRITE_BIT_KHR = 1 shl 22;
  VK_PIPELINE_STAGE_2_RAY_TRACING_SHADER_BIT_KHR = 1 shl 21;
  VK_PIPELINE_STAGE_2_FRAGMENT_DENSITY_PROCESS_BIT_EXT = 1 shl 23;
  VK_ACCESS_2_FRAGMENT_DENSITY_MAP_READ_BIT_EXT = 1 shl 24;
  VK_ACCESS_2_COLOR_ATTACHMENT_READ_NONCOHERENT_BIT_EXT = 1 shl 19;
  VK_PIPELINE_STAGE_2_TASK_SHADER_BIT_NV = 1 shl 19;
  VK_PIPELINE_STAGE_2_MESH_SHADER_BIT_NV = 1 shl 20;
  VK_STRUCTURE_TYPE_QUEUE_FAMILY_CHECKPOINT_PROPERTIES_2_NV = 1000000000 + (315 - 1) * 1000 + 8;
  VK_STRUCTURE_TYPE_CHECKPOINT_DATA_2_NV = 1000000000 + (315 - 1) * 1000 + 9;
  VK_AMD_EXTENSION_316_SPEC_VERSION = 0;
  VK_AMD_EXTENSION_317_SPEC_VERSION = 0;
  VK_AMD_EXTENSION_318_SPEC_VERSION = 0;
  VK_AMD_EXTENSION_319_SPEC_VERSION = 0;
  VK_DESCRIPTOR_SET_LAYOUT_CREATE_RESERVED_3_BIT_AMD = 1 shl 3;
  VK_PIPELINE_LAYOUT_CREATE_RESERVED_0_BIT_AMD = 1 shl 0;
  VK_AMD_EXTENSION_320_SPEC_VERSION = 0;
  VK_AMD_EXTENSION_321_SPEC_VERSION = 0;
  VK_PIPELINE_CREATE_RESERVED_23_BIT_AMD = 1 shl 23;
  VK_PIPELINE_CREATE_RESERVED_10_BIT_AMD = 1 shl 10;
  VK_AMD_EXTENSION_322_SPEC_VERSION = 0;
  VK_AMD_EXTENSION_323_SPEC_VERSION = 0;
  VK_KHR_SHADER_SUBGROUP_UNIFORM_CONTROL_FLOW_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_SUBGROUP_UNIFORM_CONTROL_FLOW_FEATURES_KHR = 1000000000 + (324 - 1) * 1000 + 0;
  VK_KHR_EXTENSION_325_SPEC_VERSION = 0;
  VK_KHR_ZERO_INITIALIZE_WORKGROUP_MEMORY_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ZERO_INITIALIZE_WORKGROUP_MEMORY_FEATURES_KHR = 1000000000 + (326 - 1) * 1000 + 0;
  VK_NV_FRAGMENT_SHADING_RATE_ENUMS_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_ENUMS_PROPERTIES_NV = 1000000000 + (327 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_ENUMS_FEATURES_NV = 1000000000 + (327 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PIPELINE_FRAGMENT_SHADING_RATE_ENUM_STATE_CREATE_INFO_NV = 1000000000 + (327 - 1) * 1000 + 2;
  VK_NV_RAY_TRACING_MOTION_BLUR_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_MOTION_TRIANGLES_DATA_NV = 1000000000 + (328 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_MOTION_BLUR_FEATURES_NV = 1000000000 + (328 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_MOTION_INFO_NV = 1000000000 + (328 - 1) * 1000 + 2;
  VK_BUILD_ACCELERATION_STRUCTURE_MOTION_BIT_NV = 1 shl 5;
  VK_ACCELERATION_STRUCTURE_CREATE_MOTION_BIT_NV = 1 shl 2;
  VK_PIPELINE_CREATE_RAY_TRACING_ALLOW_MOTION_BIT_NV = 1 shl 20;
  VK_NV_EXTENSION_329_SPEC_VERSION = 0;
  VK_NV_EXTENSION_330_SPEC_VERSION = 0;
  VK_EXT_YCBCR_2PLANE_444_FORMATS_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_YCBCR_2_PLANE_444_FORMATS_FEATURES_EXT = 1000000000 + (331 - 1) * 1000 + 0;
  VK_FORMAT_G8_B8R8_2PLANE_444_UNORM_EXT = 1000000000 + (331 - 1) * 1000 + 0;
  VK_FORMAT_G10X6_B10X6R10X6_2PLANE_444_UNORM_3PACK16_EXT = 1000000000 + (331 - 1) * 1000 + 1;
  VK_FORMAT_G12X4_B12X4R12X4_2PLANE_444_UNORM_3PACK16_EXT = 1000000000 + (331 - 1) * 1000 + 2;
  VK_FORMAT_G16_B16R16_2PLANE_444_UNORM_EXT = 1000000000 + (331 - 1) * 1000 + 3;
  VK_NV_EXTENSION_332_SPEC_VERSION = 0;
  VK_EXT_FRAGMENT_DENSITY_MAP_2_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_DENSITY_MAP_2_FEATURES_EXT = 1000000000 + (333 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_DENSITY_MAP_2_PROPERTIES_EXT = 1000000000 + (333 - 1) * 1000 + 1;
  VK_IMAGE_VIEW_CREATE_FRAGMENT_DENSITY_MAP_DEFERRED_BIT_EXT = 1 shl 1;
  VK_QCOM_ROTATED_COPY_COMMANDS_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_COPY_COMMAND_TRANSFORM_INFO_QCOM = 1000000000 + (334 - 1) * 1000 + 0;
  VK_KHR_EXTENSION_335_SPEC_VERSION = 0;
  VK_EXT_IMAGE_ROBUSTNESS_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_ROBUSTNESS_FEATURES_EXT = 1000000000 + (336 - 1) * 1000 + 0;
  VK_KHR_WORKGROUP_MEMORY_EXPLICIT_LAYOUT_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_WORKGROUP_MEMORY_EXPLICIT_LAYOUT_FEATURES_KHR = 1000000000 + (337 - 1) * 1000 + 0;
  VK_KHR_COPY_COMMANDS_2_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_COPY_BUFFER_INFO_2_KHR = 1000000000 + (338 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_COPY_IMAGE_INFO_2_KHR = 1000000000 + (338 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_COPY_BUFFER_TO_IMAGE_INFO_2_KHR = 1000000000 + (338 - 1) * 1000 + 2;
  VK_STRUCTURE_TYPE_COPY_IMAGE_TO_BUFFER_INFO_2_KHR = 1000000000 + (338 - 1) * 1000 + 3;
  VK_STRUCTURE_TYPE_BLIT_IMAGE_INFO_2_KHR = 1000000000 + (338 - 1) * 1000 + 4;
  VK_STRUCTURE_TYPE_RESOLVE_IMAGE_INFO_2_KHR = 1000000000 + (338 - 1) * 1000 + 5;
  VK_STRUCTURE_TYPE_BUFFER_COPY_2_KHR = 1000000000 + (338 - 1) * 1000 + 6;
  VK_STRUCTURE_TYPE_IMAGE_COPY_2_KHR = 1000000000 + (338 - 1) * 1000 + 7;
  VK_STRUCTURE_TYPE_IMAGE_BLIT_2_KHR = 1000000000 + (338 - 1) * 1000 + 8;
  VK_STRUCTURE_TYPE_BUFFER_IMAGE_COPY_2_KHR = 1000000000 + (338 - 1) * 1000 + 9;
  VK_STRUCTURE_TYPE_IMAGE_RESOLVE_2_KHR = 1000000000 + (338 - 1) * 1000 + 10;
  VK_ARM_EXTENSION_339_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_340_SPEC_VERSION = 0;
  VK_IMAGE_USAGE_RESERVED_19_BIT_EXT = 1 shl 19;
  VK_EXT_4444_FORMATS_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_4444_FORMATS_FEATURES_EXT = 1000000000 + (341 - 1) * 1000 + 0;
  VK_FORMAT_A4R4G4B4_UNORM_PACK16_EXT = 1000000000 + (341 - 1) * 1000 + 0;
  VK_FORMAT_A4B4G4R4_UNORM_PACK16_EXT = 1000000000 + (341 - 1) * 1000 + 1;
  VK_EXT_EXTENSION_342_SPEC_VERSION = 0;
  VK_ARM_EXTENSION_343_SPEC_VERSION = 0;
  VK_ARM_EXTENSION_344_SPEC_VERSION = 0;
  VK_ARM_EXTENSION_345_SPEC_VERSION = 0;
  VK_NV_ACQUIRE_WINRT_DISPLAY_SPEC_VERSION = 1;
  VK_EXT_DIRECTFB_SURFACE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_DIRECTFB_SURFACE_CREATE_INFO_EXT = 1000000000 + (347 - 1) * 1000 + 0;
  VK_KHR_EXTENSION_350_SPEC_VERSION = 0;
  VK_NV_EXTENSION_351_SPEC_VERSION = 0;
  VK_VALVE_MUTABLE_DESCRIPTOR_TYPE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MUTABLE_DESCRIPTOR_TYPE_FEATURES_VALVE = 1000000000 + (352 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_MUTABLE_DESCRIPTOR_TYPE_CREATE_INFO_VALVE = 1000000000 + (352 - 1) * 1000 + 2;
  VK_DESCRIPTOR_TYPE_MUTABLE_VALVE = 1000000000 + (352 - 1) * 1000 + 0;
  VK_DESCRIPTOR_POOL_CREATE_HOST_ONLY_BIT_VALVE = 1 shl 2;
  VK_DESCRIPTOR_SET_LAYOUT_CREATE_HOST_ONLY_POOL_BIT_VALVE = 1 shl 2;
  VK_EXT_VERTEX_INPUT_DYNAMIC_STATE_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VERTEX_INPUT_DYNAMIC_STATE_FEATURES_EXT = 1000000000 + (353 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_VERTEX_INPUT_BINDING_DESCRIPTION_2_EXT = 1000000000 + (353 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_VERTEX_INPUT_ATTRIBUTE_DESCRIPTION_2_EXT = 1000000000 + (353 - 1) * 1000 + 2;
  VK_DYNAMIC_STATE_VERTEX_INPUT_EXT = 1000000000 + (353 - 1) * 1000 + 0;
  VK_EXT_PHYSICAL_DEVICE_DRM_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DRM_PROPERTIES_EXT = 1000000000 + (354 - 1) * 1000 + 0;
  VK_EXT_EXTENSION_355_SPEC_VERSION = 0;
  VK_EXT_VERTEX_ATTRIBUTE_ALIASING_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_357 = 0;
  VK_KHR_EXTENSION_358_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_359 = 0;
  VK_EXT_EXTENSION_360 = 0;
  VK_EXT_EXTENSION_361 = 0;
  VK_EXT_EXTENSION_362_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_363_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_364_SPEC_VERSION = 0;
  VK_FUCHSIA_EXTERNAL_MEMORY_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_IMPORT_MEMORY_ZIRCON_HANDLE_INFO_FUCHSIA = 1000000000 + (365 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_MEMORY_ZIRCON_HANDLE_PROPERTIES_FUCHSIA = 1000000000 + (365 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_MEMORY_GET_ZIRCON_HANDLE_INFO_FUCHSIA = 1000000000 + (365 - 1) * 1000 + 2;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_ZIRCON_VMO_BIT_FUCHSIA = 1 shl 11;
  VK_FUCHSIA_EXTERNAL_SEMAPHORE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_IMPORT_SEMAPHORE_ZIRCON_HANDLE_INFO_FUCHSIA = 1000000000 + (366 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_SEMAPHORE_GET_ZIRCON_HANDLE_INFO_FUCHSIA = 1000000000 + (366 - 1) * 1000 + 1;
  VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_ZIRCON_EVENT_BIT_FUCHSIA = 1 shl 7;
  VK_EXT_EXTENSION_367_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_368_SPEC_VERSION = 0;
  VK_QCOM_EXTENSION_369_SPEC_VERSION = 0;
  VK_DESCRIPTOR_BINDING_RESERVED_4_BIT_QCOM = 1 shl 4;
  VK_HUAWEI_SUBPASS_SHADING_SPEC_VERSION = 2;
  VK_STRUCTURE_TYPE_SUBPASS_SHADING_PIPELINE_CREATE_INFO_HUAWEI = 1000000000 + (370 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBPASS_SHADING_FEATURES_HUAWEI = 1000000000 + (370 - 1) * 1000 + 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBPASS_SHADING_PROPERTIES_HUAWEI = 1000000000 + (370 - 1) * 1000 + 2;
  VK_PIPELINE_BIND_POINT_SUBPASS_SHADING_HUAWEI = 1000000000 + (370 - 1) * 1000 + 3;
  VK_PIPELINE_STAGE_2_SUBPASS_SHADING_BIT_HUAWEI = 1 shl 39;
  VK_SHADER_STAGE_SUBPASS_SHADING_BIT_HUAWEI = 1 shl 14;
  VK_HUAWEI_INVOCATION_MASK_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_INVOCATION_MASK_FEATURES_HUAWEI = 1000000000 + (371 - 1) * 1000 + 0;
  VK_ACCESS_2_INVOCATION_MASK_READ_BIT_HUAWEI = 1 shl 39;
  VK_IMAGE_USAGE_INVOCATION_MASK_BIT_HUAWEI = 1 shl 18;
  VK_PIPELINE_STAGE_2_INVOCATION_MASK_BIT_HUAWEI = 1 shl 40;
  VK_NV_EXTERNAL_MEMORY_RDMA_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_MEMORY_GET_REMOTE_ADDRESS_INFO_NV = 1000000000 + (372 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_MEMORY_RDMA_FEATURES_NV = 1000000000 + (372 - 1) * 1000 + 1;
  VK_MEMORY_PROPERTY_RDMA_CAPABLE_BIT_NV = 1 shl 8;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_RDMA_ADDRESS_BIT_NV = 1 shl 12;
  VK_NV_EXTENSION_373_SPEC_VERSION = 0;
  VK_NV_EXTENSION_374_SPEC_VERSION = 0;
  VK_EXTERNAL_FENCE_HANDLE_TYPE_RESERVED_4_BIT_NV = 1 shl 4;
  VK_EXTERNAL_FENCE_HANDLE_TYPE_RESERVED_5_BIT_NV = 1 shl 5;
  VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_RESERVED_5_BIT_NV = 1 shl 5;
  VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_RESERVED_6_BIT_NV = 1 shl 6;
  VK_NV_EXTENSION_375_SPEC_VERSION = 0;
  VK_EXTERNAL_MEMORY_HANDLE_TYPE_RESERVED_13_BIT_NV = 1 shl 13;
  VK_EXT_EXTENSION_376_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_377_SPEC_VERSION = 0;
  VK_EXT_EXTENDED_DYNAMIC_STATE_2_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_2_FEATURES_EXT = 1000000000 + (378 - 1) * 1000 + 0;
  VK_DYNAMIC_STATE_PATCH_CONTROL_POINTS_EXT = 1000000000 + (378 - 1) * 1000 + 0;
  VK_DYNAMIC_STATE_RASTERIZER_DISCARD_ENABLE_EXT = 1000000000 + (378 - 1) * 1000 + 1;
  VK_DYNAMIC_STATE_DEPTH_BIAS_ENABLE_EXT = 1000000000 + (378 - 1) * 1000 + 2;
  VK_DYNAMIC_STATE_LOGIC_OP_EXT = 1000000000 + (378 - 1) * 1000 + 3;
  VK_DYNAMIC_STATE_PRIMITIVE_RESTART_ENABLE_EXT = 1000000000 + (378 - 1) * 1000 + 4;
  VK_QNX_SCREEN_SURFACE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_SCREEN_SURFACE_CREATE_INFO_QNX = 1000000000 + (379 - 1) * 1000 + 0;
  VK_KHR_EXTENSION_380_SPEC_VERSION = 0;
  VK_KHR_EXTENSION_381_SPEC_VERSION = 0;
  VK_EXT_COLOR_WRITE_ENABLE_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COLOR_WRITE_ENABLE_FEATURES_EXT = 1000000000 + (382 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PIPELINE_COLOR_WRITE_CREATE_INFO_EXT = 1000000000 + (382 - 1) * 1000 + 1;
  VK_DYNAMIC_STATE_COLOR_WRITE_ENABLE_EXT = 1000000000 + (382 - 1) * 1000 + 0;
  VK_EXT_EXTENSION_383_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_384_SPEC_VERSION = 0;
  VK_MESA_EXTENSION_385_SPEC_VERSION = 0;
  VK_GOOGLE_EXTENSION_386_SPEC_VERSION = 0;
  VK_KHR_EXTENSION_387_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_388_SPEC_VERSION = 0;
  VK_EXT_GLOBAL_PRIORITY_QUERY_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_GLOBAL_PRIORITY_QUERY_FEATURES_EXT = 1000000000 + (389 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_QUEUE_FAMILY_GLOBAL_PRIORITY_PROPERTIES_EXT = 1000000000 + (389 - 1) * 1000 + 1;
  VK_EXT_EXTENSION_390_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_391_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_392_SPEC_VERSION = 0;
  VK_EXT_MULTI_DRAW_SPEC_VERSION = 1;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTI_DRAW_FEATURES_EXT = 1000000000 + (393 - 1) * 1000 + 0;
  VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTI_DRAW_PROPERTIES_EXT = 1000000000 + (393 - 1) * 1000 + 1;
  VK_EXT_EXTENSION_394_SPEC_VERSION = 0;
  VK_KHR_EXTENSION_395_SPEC_VERSION = 0;
  VK_KHR_EXTENSION_396_SPEC_VERSION = 0;
  VK_NV_EXTENSION_397_SPEC_VERSION = 0;
  VK_NV_EXTENSION_398_SPEC_VERSION = 0;
  VK_JUICE_EXTENSION_399_SPEC_VERSION = 0;
  VK_JUICE_EXTENSION_400_SPEC_VERSION = 0;
  VK_EXT_LOAD_STORE_OP_NONE_SPEC_VERSION = 1;
  VK_ATTACHMENT_LOAD_OP_NONE_EXT = 1000000000 + (401 - 1) * 1000 + 0;
  VK_ATTACHMENT_STORE_OP_NONE_EXT = 1000000000 + (302 - 1) * 1000 + 0;
  VK_FB_EXTENSION_402_SPEC_VERSION = 0;
  VK_FB_EXTENSION_403_SPEC_VERSION = 0;
  VK_FB_EXTENSION_404_SPEC_VERSION = 0;
  VK_HUAWEI_EXTENSION_405_SPEC_VERSION = 0;
  VK_HUAWEI_EXTENSION_406_SPEC_VERSION = 0;
  VK_GGP_EXTENSION_407_SPEC_VERSION = 0;
  VK_GGP_EXTENSION_408_SPEC_VERSION = 0;
  VK_GGP_EXTENSION_409_SPEC_VERSION = 0;
  VK_GGP_EXTENSION_410_SPEC_VERSION = 0;
  VK_GGP_EXTENSION_411_SPEC_VERSION = 0;
  VK_NV_EXTENSION_412_SPEC_VERSION = 0;
  VK_NV_EXTENSION_413_SPEC_VERSION = 0;
  VK_NV_EXTENSION_414_SPEC_VERSION = 0;
  VK_HUAWEI_EXTENSION_415_SPEC_VERSION = 0;
  VK_ARM_EXTENSION_416_SPEC_VERSION = 0;
  VK_ARM_EXTENSION_417_SPEC_VERSION = 0;
  VK_ARM_EXTENSION_418_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_419_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_420_SPEC_VERSION = 0;
  VK_KHR_EXTENSION_421_SPEC_VERSION = 0;
  VK_EXT_EXTENSION_422_SPEC_VERSION = 0;

{$IF Defined(DVULKAN_NAMES)}
  VK_KHR_SURFACE_EXTENSION_NAME = 'VK_KHR_surface';
  VK_KHR_SWAPCHAIN_EXTENSION_NAME = 'VK_KHR_swapchain';
  VK_KHR_DISPLAY_EXTENSION_NAME = 'VK_KHR_display';
  VK_KHR_DISPLAY_SWAPCHAIN_EXTENSION_NAME = 'VK_KHR_display_swapchain';
  VK_KHR_XLIB_SURFACE_EXTENSION_NAME = 'VK_KHR_xlib_surface';
  VK_KHR_XCB_SURFACE_EXTENSION_NAME = 'VK_KHR_xcb_surface';
  VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME = 'VK_KHR_wayland_surface';
  VK_KHR_MIR_SURFACE_EXTENSION_NAME = 'VK_KHR_mir_surface';
  VK_KHR_ANDROID_SURFACE_EXTENSION_NAME = 'VK_KHR_android_surface';
  VK_KHR_WIN32_SURFACE_EXTENSION_NAME = 'VK_KHR_win32_surface';
  VK_ANDROID_NATIVE_BUFFER_NAME = 'VK_ANDROID_native_buffer';
  VK_EXT_DEBUG_REPORT_EXTENSION_NAME = 'VK_EXT_debug_report';
  VK_NV_GLSL_SHADER_EXTENSION_NAME = 'VK_NV_glsl_shader';
  VK_EXT_DEPTH_RANGE_UNRESTRICTED_EXTENSION_NAME = 'VK_EXT_depth_range_unrestricted';
  VK_KHR_SAMPLER_MIRROR_CLAMP_TO_EDGE_EXTENSION_NAME = 'VK_KHR_sampler_mirror_clamp_to_edge';
  VK_IMG_FILTER_CUBIC_EXTENSION_NAME = 'VK_IMG_filter_cubic';
  VK_AMD_EXTENSION_17_EXTENSION_NAME = 'VK_AMD_extension_17';
  VK_AMD_EXTENSION_18_EXTENSION_NAME = 'VK_AMD_extension_18';
  VK_AMD_RASTERIZATION_ORDER_EXTENSION_NAME = 'VK_AMD_rasterization_order';
  VK_AMD_EXTENSION_20_EXTENSION_NAME = 'VK_AMD_extension_20';
  VK_AMD_SHADER_TRINARY_MINMAX_EXTENSION_NAME = 'VK_AMD_shader_trinary_minmax';
  VK_AMD_SHADER_EXPLICIT_VERTEX_PARAMETER_EXTENSION_NAME = 'VK_AMD_shader_explicit_vertex_parameter';
  VK_EXT_DEBUG_MARKER_EXTENSION_NAME = 'VK_EXT_debug_marker';
  VK_KHR_VIDEO_QUEUE_EXTENSION_NAME = 'VK_KHR_video_queue';
  VK_KHR_VIDEO_DECODE_QUEUE_EXTENSION_NAME = 'VK_KHR_video_decode_queue';
  VK_AMD_GCN_SHADER_EXTENSION_NAME = 'VK_AMD_gcn_shader';
  VK_NV_DEDICATED_ALLOCATION_EXTENSION_NAME = 'VK_NV_dedicated_allocation';
  VK_EXT_EXTENSION_28_EXTENSION_NAME = 'VK_NV_extension_28';
  VK_EXT_TRANSFORM_FEEDBACK_EXTENSION_NAME = 'VK_EXT_transform_feedback';
  VK_NVX_BINARY_IMPORT_EXTENSION_NAME = 'VK_NVX_binary_import';
  VK_NVX_IMAGE_VIEW_HANDLE_EXTENSION_NAME = 'VK_NVX_image_view_handle';
  VK_AMD_EXTENSION_32_EXTENSION_NAME = 'VK_AMD_extension_32';
  VK_AMD_EXTENSION_33_EXTENSION_NAME = 'VK_AMD_extension_33';
  VK_AMD_DRAW_INDIRECT_COUNT_EXTENSION_NAME = 'VK_AMD_draw_indirect_count';
  VK_AMD_EXTENSION_35_EXTENSION_NAME = 'VK_AMD_extension_35';
  VK_AMD_NEGATIVE_VIEWPORT_HEIGHT_EXTENSION_NAME = 'VK_AMD_negative_viewport_height';
  VK_AMD_GPU_SHADER_HALF_FLOAT_EXTENSION_NAME = 'VK_AMD_gpu_shader_half_float';
  VK_AMD_SHADER_BALLOT_EXTENSION_NAME = 'VK_AMD_shader_ballot';
  VK_EXT_VIDEO_ENCODE_H264_EXTENSION_NAME = 'VK_EXT_video_encode_h264';
  VK_EXT_VIDEO_ENCODE_H265_EXTENSION_NAME = 'VK_EXT_video_encode_h265';
  VK_EXT_VIDEO_DECODE_H264_EXTENSION_NAME = 'VK_EXT_video_decode_h264';
  VK_AMD_TEXTURE_GATHER_BIAS_LOD_EXTENSION_NAME = 'VK_AMD_texture_gather_bias_lod';
  VK_AMD_SHADER_INFO_EXTENSION_NAME = 'VK_AMD_shader_info';
  VK_AMD_EXTENSION_44_EXTENSION_NAME = 'VK_AMD_extension_44';
  VK_AMD_EXTENSION_45_EXTENSION_NAME = 'VK_AMD_extension_45';
  VK_AMD_EXTENSION_46_EXTENSION_NAME = 'VK_AMD_extension_46';
  VK_AMD_SHADER_IMAGE_LOAD_STORE_LOD_EXTENSION_NAME = 'VK_AMD_shader_image_load_store_lod';
  VK_NVX_EXTENSION_48_EXTENSION_NAME = 'VK_NVX_extension_48';
  VK_GOOGLE_EXTENSION_49_EXTENSION_NAME = 'VK_GOOGLE_extension_49';
  VK_GGP_STREAM_DESCRIPTOR_SURFACE_EXTENSION_NAME = 'VK_GGP_stream_descriptor_surface';
  VK_NV_CORNER_SAMPLED_IMAGE_EXTENSION_NAME = 'VK_NV_corner_sampled_image';
  VK_NV_EXTENSION_52_EXTENSION_NAME = 'VK_NV_extension_52';
  VK_NV_EXTENSION_53_EXTENSION_NAME = 'VK_NV_extension_53';
  VK_KHR_MULTIVIEW_EXTENSION_NAME = 'VK_KHR_multiview';
  VK_IMG_FORMAT_PVRTC_EXTENSION_NAME = 'VK_IMG_format_pvrtc';
  VK_NV_EXTERNAL_MEMORY_CAPABILITIES_EXTENSION_NAME = 'VK_NV_external_memory_capabilities';
  VK_NV_EXTERNAL_MEMORY_EXTENSION_NAME = 'VK_NV_external_memory';
  VK_NV_EXTERNAL_MEMORY_WIN32_EXTENSION_NAME = 'VK_NV_external_memory_win32';
  VK_NV_WIN32_KEYED_MUTEX_EXTENSION_NAME = 'VK_NV_win32_keyed_mutex';
  VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME = 'VK_KHR_get_physical_device_properties2';
  VK_KHR_DEVICE_GROUP_EXTENSION_NAME = 'VK_KHR_device_group';
  VK_EXT_VALIDATION_FLAGS_EXTENSION_NAME = 'VK_EXT_validation_flags';
  VK_NN_VI_SURFACE_EXTENSION_NAME = 'VK_NN_vi_surface';
  VK_KHR_SHADER_DRAW_PARAMETERS_EXTENSION_NAME = 'VK_KHR_shader_draw_parameters';
  VK_EXT_SHADER_SUBGROUP_BALLOT_EXTENSION_NAME = 'VK_EXT_shader_subgroup_ballot';
  VK_EXT_SHADER_SUBGROUP_VOTE_EXTENSION_NAME = 'VK_EXT_shader_subgroup_vote';
  VK_EXT_TEXTURE_COMPRESSION_ASTC_HDR_EXTENSION_NAME = 'VK_EXT_texture_compression_astc_hdr';
  VK_EXT_ASTC_DECODE_MODE_EXTENSION_NAME = 'VK_EXT_astc_decode_mode';
  VK_IMG_EXTENSION_69_EXTENSION_NAME = 'VK_IMG_extension_69';
  VK_KHR_MAINTENANCE1_EXTENSION_NAME = 'VK_KHR_maintenance1';
  VK_KHR_DEVICE_GROUP_CREATION_EXTENSION_NAME = 'VK_KHR_device_group_creation';
  VK_KHR_EXTERNAL_MEMORY_CAPABILITIES_EXTENSION_NAME = 'VK_KHR_external_memory_capabilities';
  VK_KHR_EXTERNAL_MEMORY_EXTENSION_NAME = 'VK_KHR_external_memory';
  VK_KHR_EXTERNAL_MEMORY_WIN32_EXTENSION_NAME = 'VK_KHR_external_memory_win32';
  VK_KHR_EXTERNAL_MEMORY_FD_EXTENSION_NAME = 'VK_KHR_external_memory_fd';
  VK_KHR_WIN32_KEYED_MUTEX_EXTENSION_NAME = 'VK_KHR_win32_keyed_mutex';
  VK_KHR_EXTERNAL_SEMAPHORE_CAPABILITIES_EXTENSION_NAME = 'VK_KHR_external_semaphore_capabilities';
  VK_KHR_EXTERNAL_SEMAPHORE_EXTENSION_NAME = 'VK_KHR_external_semaphore';
  VK_KHR_EXTERNAL_SEMAPHORE_WIN32_EXTENSION_NAME = 'VK_KHR_external_semaphore_win32';
  VK_KHR_EXTERNAL_SEMAPHORE_FD_EXTENSION_NAME = 'VK_KHR_external_semaphore_fd';
  VK_KHR_PUSH_DESCRIPTOR_EXTENSION_NAME = 'VK_KHR_push_descriptor';
  VK_EXT_CONDITIONAL_RENDERING_EXTENSION_NAME = 'VK_EXT_conditional_rendering';
  VK_KHR_SHADER_FLOAT16_INT8_EXTENSION_NAME = 'VK_KHR_shader_float16_int8';
  VK_KHR_16BIT_STORAGE_EXTENSION_NAME = 'VK_KHR_16bit_storage';
  VK_KHR_INCREMENTAL_PRESENT_EXTENSION_NAME = 'VK_KHR_incremental_present';
  VK_KHR_DESCRIPTOR_UPDATE_TEMPLATE_EXTENSION_NAME = 'VK_KHR_descriptor_update_template';
  VK_NVX_DEVICE_GENERATED_COMMANDS_EXTENSION_NAME = 'VK_NVX_device_generated_commands';
  VK_NV_CLIP_SPACE_W_SCALING_EXTENSION_NAME = 'VK_NV_clip_space_w_scaling';
  VK_EXT_DIRECT_MODE_DISPLAY_EXTENSION_NAME = 'VK_EXT_direct_mode_display';
  VK_EXT_ACQUIRE_XLIB_DISPLAY_EXTENSION_NAME = 'VK_EXT_acquire_xlib_display';
  VK_EXT_DISPLAY_SURFACE_COUNTER_EXTENSION_NAME = 'VK_EXT_display_surface_counter';
  VK_EXT_DISPLAY_CONTROL_EXTENSION_NAME = 'VK_EXT_display_control';
  VK_GOOGLE_DISPLAY_TIMING_EXTENSION_NAME = 'VK_GOOGLE_display_timing';
  VK_NV_SAMPLE_MASK_OVERRIDE_COVERAGE_EXTENSION_NAME = 'VK_NV_sample_mask_override_coverage';
  VK_NV_GEOMETRY_SHADER_PASSTHROUGH_EXTENSION_NAME = 'VK_NV_geometry_shader_passthrough';
  VK_NV_VIEWPORT_ARRAY2_EXTENSION_NAME = 'VK_NV_viewport_array2';
  VK_NVX_MULTIVIEW_PER_VIEW_ATTRIBUTES_EXTENSION_NAME = 'VK_NVX_multiview_per_view_attributes';
  VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME = 'VK_NV_viewport_swizzle';
  VK_EXT_DISCARD_RECTANGLES_EXTENSION_NAME = 'VK_EXT_discard_rectangles';
  VK_NV_EXTENSION_101_EXTENSION_NAME = 'VK_NV_extension_101';
  VK_EXT_CONSERVATIVE_RASTERIZATION_EXTENSION_NAME = 'VK_EXT_conservative_rasterization';
  VK_EXT_DEPTH_CLIP_ENABLE_EXTENSION_NAME = 'VK_EXT_depth_clip_enable';
  VK_NV_EXTENSION_104_EXTENSION_NAME = 'VK_NV_extension_104';
  VK_EXT_SWAPCHAIN_COLOR_SPACE_EXTENSION_NAME = 'VK_EXT_swapchain_colorspace';
  VK_EXT_HDR_METADATA_EXTENSION_NAME = 'VK_EXT_hdr_metadata';
  VK_IMG_EXTENSION_107_EXTENSION_NAME = 'VK_IMG_extension_107';
  VK_IMG_EXTENSION_108_EXTENSION_NAME = 'VK_IMG_extension_108';
  VK_KHR_IMAGELESS_FRAMEBUFFER_EXTENSION_NAME = 'VK_KHR_imageless_framebuffer';
  VK_KHR_CREATE_RENDERPASS_2_EXTENSION_NAME = 'VK_KHR_create_renderpass2';
  VK_IMG_EXTENSION_111_EXTENSION_NAME = 'VK_IMG_extension_111';
  VK_KHR_SHARED_PRESENTABLE_IMAGE_EXTENSION_NAME = 'VK_KHR_shared_presentable_image';
  VK_KHR_EXTERNAL_FENCE_CAPABILITIES_EXTENSION_NAME = 'VK_KHR_external_fence_capabilities';
  VK_KHR_EXTERNAL_FENCE_EXTENSION_NAME = 'VK_KHR_external_fence';
  VK_KHR_EXTERNAL_FENCE_WIN32_EXTENSION_NAME = 'VK_KHR_external_fence_win32';
  VK_KHR_EXTERNAL_FENCE_FD_EXTENSION_NAME = 'VK_KHR_external_fence_fd';
  VK_KHR_PERFORMANCE_QUERY_EXTENSION_NAME = 'VK_KHR_performance_query';
  VK_KHR_MAINTENANCE2_EXTENSION_NAME = 'VK_KHR_maintenance2';
  VK_KHR_EXTENSION_119_EXTENSION_NAME = 'VK_KHR_extension_119';
  VK_KHR_GET_SURFACE_CAPABILITIES_2_EXTENSION_NAME = 'VK_KHR_get_surface_capabilities2';
  VK_KHR_VARIABLE_POINTERS_EXTENSION_NAME = 'VK_KHR_variable_pointers';
  VK_KHR_GET_DISPLAY_PROPERTIES_2_EXTENSION_NAME = 'VK_KHR_get_display_properties2';
  VK_MVK_IOS_SURFACE_EXTENSION_NAME = 'VK_MVK_ios_surface';
  VK_MVK_MACOS_SURFACE_EXTENSION_NAME = 'VK_MVK_macos_surface';
  VK_MVK_MOLTENVK_EXTENSION_NAME = 'VK_MVK_moltenvk';
  VK_EXT_EXTERNAL_MEMORY_DMA_BUF_EXTENSION_NAME = 'VK_EXT_external_memory_dma_buf';
  VK_EXT_QUEUE_FAMILY_FOREIGN_EXTENSION_NAME = 'VK_EXT_queue_family_foreign';
  VK_KHR_DEDICATED_ALLOCATION_EXTENSION_NAME = 'VK_KHR_dedicated_allocation';
  VK_EXT_DEBUG_UTILS_EXTENSION_NAME = 'VK_EXT_debug_utils';
  VK_ANDROID_EXTERNAL_MEMORY_ANDROID_HARDWARE_BUFFER_EXTENSION_NAME = 'VK_ANDROID_external_memory_android_hardware_buffer';
  VK_EXT_SAMPLER_FILTER_MINMAX_EXTENSION_NAME = 'VK_EXT_sampler_filter_minmax';
  VK_KHR_STORAGE_BUFFER_STORAGE_CLASS_EXTENSION_NAME = 'VK_KHR_storage_buffer_storage_class';
  VK_AMD_GPU_SHADER_INT16_EXTENSION_NAME = 'VK_AMD_gpu_shader_int16';
  VK_AMD_EXTENSION_134_EXTENSION_NAME = 'VK_AMD_extension_134';
  VK_AMD_EXTENSION_135_EXTENSION_NAME = 'VK_AMD_extension_135';
  VK_AMD_EXTENSION_136_EXTENSION_NAME = 'VK_AMD_extension_136';
  VK_AMD_MIXED_ATTACHMENT_SAMPLES_EXTENSION_NAME = 'VK_AMD_mixed_attachment_samples';
  VK_AMD_SHADER_FRAGMENT_MASK_EXTENSION_NAME = 'VK_AMD_shader_fragment_mask';
  VK_EXT_INLINE_UNIFORM_BLOCK_EXTENSION_NAME = 'VK_EXT_inline_uniform_block';
  VK_AMD_EXTENSION_140_EXTENSION_NAME = 'VK_AMD_extension_140';
  VK_EXT_SHADER_STENCIL_EXPORT_EXTENSION_NAME = 'VK_EXT_shader_stencil_export';
  VK_AMD_EXTENSION_142_EXTENSION_NAME = 'VK_AMD_extension_142';
  VK_AMD_EXTENSION_143_EXTENSION_NAME = 'VK_AMD_extension_143';
  VK_EXT_SAMPLE_LOCATIONS_EXTENSION_NAME = 'VK_EXT_sample_locations';
  VK_KHR_RELAXED_BLOCK_LAYOUT_EXTENSION_NAME = 'VK_KHR_relaxed_block_layout';
  VK_KHR_GET_MEMORY_REQUIREMENTS_2_EXTENSION_NAME = 'VK_KHR_get_memory_requirements2';
  VK_KHR_IMAGE_FORMAT_LIST_EXTENSION_NAME = 'VK_KHR_image_format_list';
  VK_EXT_BLEND_OPERATION_ADVANCED_EXTENSION_NAME = 'VK_EXT_blend_operation_advanced';
  VK_NV_FRAGMENT_COVERAGE_TO_COLOR_EXTENSION_NAME = 'VK_NV_fragment_coverage_to_color';
  VK_KHR_ACCELERATION_STRUCTURE_EXTENSION_NAME = 'VK_KHR_acceleration_structure';
  VK_KHR_RAY_TRACING_PIPELINE_EXTENSION_NAME = 'VK_KHR_ray_tracing_pipeline';
  VK_KHR_RAY_QUERY_EXTENSION_NAME = 'VK_KHR_ray_query';
  VK_NV_EXTENSION_152_EXTENSION_NAME = 'VK_NV_extension_152';
  VK_NV_FRAMEBUFFER_MIXED_SAMPLES_EXTENSION_NAME = 'VK_NV_framebuffer_mixed_samples';
  VK_NV_FILL_RECTANGLE_EXTENSION_NAME = 'VK_NV_fill_rectangle';
  VK_NV_SHADER_SM_BUILTINS_EXTENSION_NAME = 'VK_NV_shader_sm_builtins';
  VK_EXT_POST_DEPTH_COVERAGE_EXTENSION_NAME = 'VK_EXT_post_depth_coverage';
  VK_KHR_SAMPLER_YCBCR_CONVERSION_EXTENSION_NAME = 'VK_KHR_sampler_ycbcr_conversion';
  VK_KHR_BIND_MEMORY_2_EXTENSION_NAME = 'VK_KHR_bind_memory2';
  VK_EXT_IMAGE_DRM_FORMAT_MODIFIER_EXTENSION_NAME = 'VK_EXT_image_drm_format_modifier';
  VK_EXT_EXTENSION_160_EXTENSION_NAME = 'VK_EXT_extension_160';
  VK_EXT_VALIDATION_CACHE_EXTENSION_NAME = 'VK_EXT_validation_cache';
  VK_EXT_DESCRIPTOR_INDEXING_EXTENSION_NAME = 'VK_EXT_descriptor_indexing';
  VK_EXT_SHADER_VIEWPORT_INDEX_LAYER_EXTENSION_NAME = 'VK_EXT_shader_viewport_index_layer';
  VK_KHR_PORTABILITY_SUBSET_EXTENSION_NAME = 'VK_KHR_portability_subset';
  VK_NV_SHADING_RATE_IMAGE_EXTENSION_NAME = 'VK_NV_shading_rate_image';
  VK_NV_RAY_TRACING_EXTENSION_NAME = 'VK_NV_ray_tracing';
  VK_NV_REPRESENTATIVE_FRAGMENT_TEST_EXTENSION_NAME = 'VK_NV_representative_fragment_test';
  VK_EXT_EXTENSION_168_EXTENSION_NAME = 'VK_NV_extension_168';
  VK_KHR_MAINTENANCE3_EXTENSION_NAME = 'VK_KHR_maintenance3';
  VK_KHR_DRAW_INDIRECT_COUNT_EXTENSION_NAME = 'VK_KHR_draw_indirect_count';
  VK_EXT_FILTER_CUBIC_EXTENSION_NAME = 'VK_EXT_filter_cubic';
  VK_QCOM_RENDER_PASS_SHADER_RESOLVE_EXTENSION_NAME = 'VK_QCOM_render_pass_shader_resolve';
  VK_QCOM_extension_173_EXTENSION_NAME = 'VK_QCOM_extension_173';
  VK_QCOM_extension_174_EXTENSION_NAME = 'VK_QCOM_extension_174';
  VK_EXT_GLOBAL_PRIORITY_EXTENSION_NAME = 'VK_EXT_global_priority';
  VK_KHR_SHADER_SUBGROUP_EXTENDED_TYPES_EXTENSION_NAME = 'VK_KHR_shader_subgroup_extended_types';
  VK_KHR_EXTENSION_177_EXTENSION_NAME = 'VK_KHR_extension_177';
  VK_KHR_8BIT_STORAGE_EXTENSION_NAME = 'VK_KHR_8bit_storage';
  VK_EXT_EXTERNAL_MEMORY_HOST_EXTENSION_NAME = 'VK_EXT_external_memory_host';
  VK_AMD_BUFFER_MARKER_EXTENSION_NAME = 'VK_AMD_buffer_marker';
  VK_KHR_SHADER_ATOMIC_INT64_EXTENSION_NAME = 'VK_KHR_shader_atomic_int64';
  VK_KHR_SHADER_CLOCK_EXTENSION_NAME = 'VK_KHR_shader_clock';
  VK_KHR_EXTENSION_183_EXTENSION_NAME = 'VK_AMD_extension_183';
  VK_AMD_PIPELINE_COMPILER_CONTROL_EXTENSION_NAME = 'VK_AMD_pipeline_compiler_control';
  VK_EXT_CALIBRATED_TIMESTAMPS_EXTENSION_NAME = 'VK_EXT_calibrated_timestamps';
  VK_AMD_SHADER_CORE_PROPERTIES_EXTENSION_NAME = 'VK_AMD_shader_core_properties';
  VK_KHR_EXTENSION_187_EXTENSION_NAME = 'VK_AMD_extension_187';
  VK_EXT_VIDEO_DECODE_H265_EXTENSION_NAME = 'VK_EXT_video_decode_h265';
  VK_KHR_EXTENSION_189_EXTENSION_NAME = 'VK_AMD_extension_189';
  VK_AMD_MEMORY_OVERALLOCATION_BEHAVIOR_EXTENSION_NAME = 'VK_AMD_memory_overallocation_behavior';
  VK_EXT_VERTEX_ATTRIBUTE_DIVISOR_EXTENSION_NAME = 'VK_EXT_vertex_attribute_divisor';
  VK_GGP_FRAME_TOKEN_EXTENSION_NAME = 'VK_GGP_frame_token';
  VK_EXT_PIPELINE_CREATION_FEEDBACK_EXTENSION_NAME = 'VK_EXT_pipeline_creation_feedback';
  VK_GOOGLE_EXTENSION_194_EXTENSION_NAME = 'VK_GOOGLE_extension_194';
  VK_GOOGLE_EXTENSION_195_EXTENSION_NAME = 'VK_GOOGLE_extension_195';
  VK_GOOGLE_EXTENSION_196_EXTENSION_NAME = 'VK_GOOGLE_extension_196';
  VK_KHR_DRIVER_PROPERTIES_EXTENSION_NAME = 'VK_KHR_driver_properties';
  VK_KHR_SHADER_FLOAT_CONTROLS_EXTENSION_NAME = 'VK_KHR_shader_float_controls';
  VK_NV_SHADER_SUBGROUP_PARTITIONED_EXTENSION_NAME = 'VK_NV_shader_subgroup_partitioned';
  VK_KHR_DEPTH_STENCIL_RESOLVE_EXTENSION_NAME = 'VK_KHR_depth_stencil_resolve';
  VK_KHR_SWAPCHAIN_MUTABLE_FORMAT_EXTENSION_NAME = 'VK_KHR_swapchain_mutable_format';
  VK_NV_COMPUTE_SHADER_DERIVATIVES_EXTENSION_NAME = 'VK_NV_compute_shader_derivatives';
  VK_NV_MESH_SHADER_EXTENSION_NAME = 'VK_NV_mesh_shader';
  VK_NV_FRAGMENT_SHADER_BARYCENTRIC_EXTENSION_NAME = 'VK_NV_fragment_shader_barycentric';
  VK_NV_SHADER_IMAGE_FOOTPRINT_EXTENSION_NAME = 'VK_NV_shader_image_footprint';
  VK_NV_SCISSOR_EXCLUSIVE_EXTENSION_NAME = 'VK_NV_scissor_exclusive';
  VK_NV_DEVICE_DIAGNOSTIC_CHECKPOINTS_EXTENSION_NAME = 'VK_NV_device_diagnostic_checkpoints';
  VK_KHR_TIMELINE_SEMAPHORE_EXTENSION_NAME = 'VK_KHR_timeline_semaphore';
  VK_KHR_EXTENSION_209_EXTENSION_NAME = 'VK_KHR_extension_209';
  VK_INTEL_SHADER_INTEGER_FUNCTIONS_2_EXTENSION_NAME = 'VK_INTEL_shader_integer_functions2';
  VK_INTEL_PERFORMANCE_QUERY_EXTENSION_NAME = 'VK_INTEL_performance_query';
  VK_KHR_VULKAN_MEMORY_MODEL_EXTENSION_NAME = 'VK_KHR_vulkan_memory_model';
  VK_EXT_PCI_BUS_INFO_EXTENSION_NAME = 'VK_EXT_pci_bus_info';
  VK_AMD_DISPLAY_NATIVE_HDR_EXTENSION_NAME = 'VK_AMD_display_native_hdr';
  VK_FUCHSIA_IMAGEPIPE_SURFACE_EXTENSION_NAME = 'VK_FUCHSIA_imagepipe_surface';
  VK_KHR_SHADER_TERMINATE_INVOCATION_EXTENSION_NAME = 'VK_KHR_shader_terminate_invocation';
  VK_KHR_EXTENSION_217_EXTENSION_NAME = 'VK_KHR_extension_217';
  VK_EXT_METAL_SURFACE_EXTENSION_NAME = 'VK_EXT_metal_surface';
  VK_EXT_FRAGMENT_DENSITY_MAP_EXTENSION_NAME = 'VK_EXT_fragment_density_map';
  VK_EXT_EXTENSION_220_EXTENSION_NAME = 'VK_EXT_extension_220';
  VK_KHR_EXTENSION_221_EXTENSION_NAME = 'VK_KHR_extension_221';
  VK_EXT_SCALAR_BLOCK_LAYOUT_EXTENSION_NAME = 'VK_EXT_scalar_block_layout';
  VK_EXT_EXTENSION_223_EXTENSION_NAME = 'VK_EXT_extension_223';
  VK_GOOGLE_HLSL_FUNCTIONALITY1_EXTENSION_NAME = 'VK_GOOGLE_hlsl_functionality1';
  VK_GOOGLE_DECORATE_STRING_EXTENSION_NAME = 'VK_GOOGLE_decorate_string';
  VK_EXT_SUBGROUP_SIZE_CONTROL_EXTENSION_NAME = 'VK_EXT_subgroup_size_control';
  VK_KHR_FRAGMENT_SHADING_RATE_EXTENSION_NAME = 'VK_KHR_fragment_shading_rate';
  VK_AMD_SHADER_CORE_PROPERTIES_2_EXTENSION_NAME = 'VK_AMD_shader_core_properties2';
  VK_AMD_EXTENSION_229_EXTENSION_NAME = 'VK_AMD_extension_229';
  VK_AMD_DEVICE_COHERENT_MEMORY_EXTENSION_NAME = 'VK_AMD_device_coherent_memory';
  VK_AMD_EXTENSION_231_EXTENSION_NAME = 'VK_AMD_extension_231';
  VK_AMD_EXTENSION_232_EXTENSION_NAME = 'VK_AMD_extension_232';
  VK_AMD_EXTENSION_233_EXTENSION_NAME = 'VK_AMD_extension_233';
  VK_AMD_EXTENSION_234_EXTENSION_NAME = 'VK_AMD_extension_234';
  VK_EXT_SHADER_IMAGE_ATOMIC_INT64_EXTENSION_NAME = 'VK_EXT_shader_image_atomic_int64';
  VK_AMD_EXTENSION_236_EXTENSION_NAME = 'VK_AMD_extension_236';
  VK_KHR_SPIRV_1_4_EXTENSION_NAME = 'VK_KHR_spirv_1_4';
  VK_EXT_MEMORY_BUDGET_EXTENSION_NAME = 'VK_EXT_memory_budget';
  VK_EXT_MEMORY_PRIORITY_EXTENSION_NAME = 'VK_EXT_memory_priority';
  VK_KHR_SURFACE_PROTECTED_CAPABILITIES_EXTENSION_NAME = 'VK_KHR_surface_protected_capabilities';
  VK_NV_DEDICATED_ALLOCATION_IMAGE_ALIASING_EXTENSION_NAME = 'VK_NV_dedicated_allocation_image_aliasing';
  VK_KHR_SEPARATE_DEPTH_STENCIL_LAYOUTS_EXTENSION_NAME = 'VK_KHR_separate_depth_stencil_layouts';
  VK_INTEL_EXTENSION_243_EXTENSION_NAME = 'VK_INTEL_extension_243';
  VK_MESA_EXTENSION_244_EXTENSION_NAME = 'VK_MESA_extension_244';
  VK_EXT_BUFFER_DEVICE_ADDRESS_EXTENSION_NAME = 'VK_EXT_buffer_device_address';
  VK_EXT_TOOLING_INFO_EXTENSION_NAME = 'VK_EXT_tooling_info';
  VK_EXT_SEPARATE_STENCIL_USAGE_EXTENSION_NAME = 'VK_EXT_separate_stencil_usage';
  VK_EXT_VALIDATION_FEATURES_EXTENSION_NAME = 'VK_EXT_validation_features';
  VK_KHR_PRESENT_WAIT_EXTENSION_NAME = 'VK_KHR_present_wait';
  VK_NV_COOPERATIVE_MATRIX_EXTENSION_NAME = 'VK_NV_cooperative_matrix';
  VK_NV_COVERAGE_REDUCTION_MODE_EXTENSION_NAME = 'VK_NV_coverage_reduction_mode';
  VK_EXT_FRAGMENT_SHADER_INTERLOCK_EXTENSION_NAME = 'VK_EXT_fragment_shader_interlock';
  VK_EXT_YCBCR_IMAGE_ARRAYS_EXTENSION_NAME = 'VK_EXT_ycbcr_image_arrays';
  VK_KHR_UNIFORM_BUFFER_STANDARD_LAYOUT_EXTENSION_NAME = 'VK_KHR_uniform_buffer_standard_layout';
  VK_EXT_PROVOKING_VERTEX_EXTENSION_NAME = 'VK_EXT_provoking_vertex';
  VK_EXT_FULL_SCREEN_EXCLUSIVE_EXTENSION_NAME = 'VK_EXT_full_screen_exclusive';
  VK_EXT_HEADLESS_SURFACE_EXTENSION_NAME = 'VK_EXT_headless_surface';
  VK_KHR_BUFFER_DEVICE_ADDRESS_EXTENSION_NAME = 'VK_KHR_buffer_device_address';
  VK_EXT_EXTENSION_259_EXTENSION_NAME = 'VK_EXT_extension_259';
  VK_EXT_LINE_RASTERIZATION_EXTENSION_NAME = 'VK_EXT_line_rasterization';
  VK_EXT_SHADER_ATOMIC_FLOAT_EXTENSION_NAME = 'VK_EXT_shader_atomic_float';
  VK_EXT_HOST_QUERY_RESET_EXTENSION_NAME = 'VK_EXT_host_query_reset';
  VK_GOOGLE_EXTENSION_263_EXTENSION_NAME = 'VK_GGP_extension_263';
  VK_BRCM_EXTENSION_264_EXTENSION_NAME = 'VK_BRCM_extension_264';
  VK_BRCM_EXTENSION_265_EXTENSION_NAME = 'VK_BRCM_extension_265';
  VK_EXT_INDEX_TYPE_UINT8_EXTENSION_NAME = 'VK_EXT_index_type_uint8';
  VK_EXT_extension_267 = 'VK_EXT_extension_267';
  VK_EXT_EXTENDED_DYNAMIC_STATE_EXTENSION_NAME = 'VK_EXT_extended_dynamic_state';
  VK_KHR_DEFERRED_HOST_OPERATIONS_EXTENSION_NAME = 'VK_KHR_deferred_host_operations';
  VK_KHR_PIPELINE_EXECUTABLE_PROPERTIES_EXTENSION_NAME = 'VK_KHR_pipeline_executable_properties';
  VK_INTEL_extension_271 = 'VK_KHR_extension_271';
  VK_INTEL_extension_272 = 'VK_KHR_extension_272';
  VK_INTEL_extension_273 = 'VK_KHR_extension_273';
  VK_EXT_SHADER_ATOMIC_FLOAT_2_EXTENSION_NAME = 'VK_EXT_shader_atomic_float2';
  VK_KHR_extension_275 = 'VK_KHR_extension_275';
  VK_KHR_extension_276 = 'VK_KHR_extension_276';
  VK_EXT_SHADER_DEMOTE_TO_HELPER_INVOCATION_EXTENSION_NAME = 'VK_EXT_shader_demote_to_helper_invocation';
  VK_NV_DEVICE_GENERATED_COMMANDS_EXTENSION_NAME = 'VK_NV_device_generated_commands';
  VK_NV_INHERITED_VIEWPORT_SCISSOR_EXTENSION_NAME = 'VK_NV_inherited_viewport_scissor';
  VK_KHR_extension_280 = 'VK_KHR_extension_280';
  VK_ARM_extension_281 = 'VK_ARM_extension_281';
  VK_EXT_TEXEL_BUFFER_ALIGNMENT_EXTENSION_NAME = 'VK_EXT_texel_buffer_alignment';
  VK_QCOM_RENDER_PASS_TRANSFORM_EXTENSION_NAME = 'VK_QCOM_render_pass_transform';
  VK_EXT_extension_284 = 'VK_EXT_extension_284';
  VK_EXT_DEVICE_MEMORY_REPORT_EXTENSION_NAME = 'VK_EXT_device_memory_report';
  VK_EXT_ACQUIRE_DRM_DISPLAY_EXTENSION_NAME = 'VK_EXT_acquire_drm_display';
  VK_EXT_ROBUSTNESS_2_EXTENSION_NAME = 'VK_EXT_robustness2';
  VK_EXT_CUSTOM_BORDER_COLOR_EXTENSION_NAME = 'VK_EXT_custom_border_color';
  VK_EXT_EXTENSION_289_EXTENSION_NAME = 'VK_EXT_extension_289';
  VK_GOOGLE_USER_TYPE_EXTENSION_NAME = 'VK_GOOGLE_user_type';
  VK_KHR_PIPELINE_LIBRARY_EXTENSION_NAME = 'VK_KHR_pipeline_library';
  VK_NV_EXTENSION_292_EXTENSION_NAME = 'VK_NV_extension_292';
  VK_NV_EXTENSION_293_EXTENSION_NAME = 'VK_NV_extension_293';
  VK_KHR_SHADER_NON_SEMANTIC_INFO_EXTENSION_NAME = 'VK_KHR_shader_non_semantic_info';
  VK_KHR_PRESENT_ID_EXTENSION_NAME = 'VK_KHR_present_id';
  VK_EXT_PRIVATE_DATA_EXTENSION_NAME = 'VK_EXT_private_data';
  VK_KHR_EXTENSION_297_EXTENSION_NAME = 'VK_KHR_extension_297';
  VK_EXT_PIPELINE_CREATION_CACHE_CONTROL_EXTENSION_NAME = 'VK_EXT_pipeline_creation_cache_control';
  VK_KHR_EXTENSION_299_EXTENSION_NAME = 'VK_KHR_extension_299';
  VK_KHR_VIDEO_ENCODE_QUEUE_EXTENSION_NAME = 'VK_KHR_video_encode_queue';
  VK_NV_DEVICE_DIAGNOSTICS_CONFIG_EXTENSION_NAME = 'VK_NV_device_diagnostics_config';
  VK_QCOM_RENDER_PASS_STORE_OPS_EXTENSION_NAME = 'VK_QCOM_render_pass_store_ops';
  VK_QCOM_extension_303_EXTENSION_NAME = 'VK_QCOM_extension_303';
  VK_QCOM_extension_304_EXTENSION_NAME = 'VK_QCOM_extension_304';
  VK_QCOM_extension_305_EXTENSION_NAME = 'VK_QCOM_extension_305';
  VK_QCOM_extension_306_EXTENSION_NAME = 'VK_QCOM_extension_306';
  VK_QCOM_extension_307_EXTENSION_NAME = 'VK_QCOM_extension_307';
  VK_NV_EXTENSION_308_EXTENSION_NAME = 'VK_NV_extension_308';
  VK_KHR_EXTENSION_309_EXTENSION_NAME = 'VK_KHR_extension_309';
  VK_QCOM_extension_310_EXTENSION_NAME = 'VK_QCOM_extension_310';
  VK_NV_EXTENSION_311_EXTENSION_NAME = 'VK_NV_extension_311';
  VK_EXT_EXTENSION_312_EXTENSION_NAME = 'VK_EXT_extension_312';
  VK_EXT_EXTENSION_313_EXTENSION_NAME = 'VK_EXT_extension_313';
  VK_AMD_EXTENSION_314_EXTENSION_NAME = 'VK_AMD_extension_314';
  VK_KHR_SYNCHRONIZATION_2_EXTENSION_NAME = 'VK_KHR_synchronization2';
  VK_AMD_EXTENSION_316_EXTENSION_NAME = 'VK_AMD_extension_316';
  VK_AMD_EXTENSION_317_EXTENSION_NAME = 'VK_AMD_extension_317';
  VK_AMD_EXTENSION_318_EXTENSION_NAME = 'VK_AMD_extension_318';
  VK_AMD_EXTENSION_319_EXTENSION_NAME = 'VK_AMD_extension_319';
  VK_AMD_EXTENSION_320_EXTENSION_NAME = 'VK_AMD_extension_320';
  VK_AMD_EXTENSION_321_EXTENSION_NAME = 'VK_AMD_extension_321';
  VK_AMD_EXTENSION_322_EXTENSION_NAME = 'VK_AMD_extension_322';
  VK_AMD_EXTENSION_323_EXTENSION_NAME = 'VK_AMD_extension_323';
  VK_KHR_SHADER_SUBGROUP_UNIFORM_CONTROL_FLOW_EXTENSION_NAME = 'VK_KHR_shader_subgroup_uniform_control_flow';
  VK_KHR_EXTENSION_325_EXTENSION_NAME = 'VK_KHR_extension_325';
  VK_KHR_ZERO_INITIALIZE_WORKGROUP_MEMORY_EXTENSION_NAME = 'VK_KHR_zero_initialize_workgroup_memory';
  VK_NV_FRAGMENT_SHADING_RATE_ENUMS_EXTENSION_NAME = 'VK_NV_fragment_shading_rate_enums';
  VK_NV_RAY_TRACING_MOTION_BLUR_EXTENSION_NAME = 'VK_NV_ray_tracing_motion_blur';
  VK_NV_EXTENSION_329_EXTENSION_NAME = 'VK_NV_extension_329';
  VK_NV_EXTENSION_330_EXTENSION_NAME = 'VK_NV_extension_330';
  VK_EXT_YCBCR_2PLANE_444_FORMATS_EXTENSION_NAME = 'VK_EXT_ycbcr_2plane_444_formats';
  VK_NV_EXTENSION_332_EXTENSION_NAME = 'VK_NV_extension_332';
  VK_EXT_FRAGMENT_DENSITY_MAP_2_EXTENSION_NAME = 'VK_EXT_fragment_density_map2';
  VK_QCOM_ROTATED_COPY_COMMANDS_EXTENSION_NAME = 'VK_QCOM_rotated_copy_commands';
  VK_KHR_EXTENSION_335_EXTENSION_NAME = 'VK_KHR_extension_335';
  VK_EXT_IMAGE_ROBUSTNESS_EXTENSION_NAME = 'VK_EXT_image_robustness';
  VK_KHR_WORKGROUP_MEMORY_EXPLICIT_LAYOUT_EXTENSION_NAME = 'VK_KHR_workgroup_memory_explicit_layout';
  VK_KHR_COPY_COMMANDS_2_EXTENSION_NAME = 'VK_KHR_copy_commands2';
  VK_ARM_EXTENSION_339_EXTENSION_NAME = 'VK_ARM_extension_339';
  VK_EXT_EXTENSION_340_EXTENSION_NAME = 'VK_EXT_extension_340';
  VK_EXT_4444_FORMATS_EXTENSION_NAME = 'VK_EXT_4444_formats';
  VK_EXT_EXTENSION_342_EXTENSION_NAME = 'VK_EXT_extension_342';
  VK_ARM_EXTENSION_343_EXTENSION_NAME = 'VK_ARM_extension_343';
  VK_ARM_EXTENSION_344_EXTENSION_NAME = 'VK_ARM_extension_344';
  VK_ARM_EXTENSION_345_EXTENSION_NAME = 'VK_ARM_extension_345';
  VK_NV_ACQUIRE_WINRT_DISPLAY_EXTENSION_NAME = 'VK_NV_acquire_winrt_display';
  VK_EXT_DIRECTFB_SURFACE_EXTENSION_NAME = 'VK_EXT_directfb_surface';
  VK_KHR_EXTENSION_350_EXTENSION_NAME = 'VK_KHR_extension_350';
  VK_NV_EXTENSION_351_EXTENSION_NAME = 'VK_NV_extension_351';
  VK_VALVE_MUTABLE_DESCRIPTOR_TYPE_EXTENSION_NAME = 'VK_VALVE_mutable_descriptor_type';
  VK_EXT_VERTEX_INPUT_DYNAMIC_STATE_EXTENSION_NAME = 'VK_EXT_vertex_input_dynamic_state';
  VK_EXT_PHYSICAL_DEVICE_DRM_EXTENSION_NAME = 'VK_EXT_physical_device_drm';
  VK_EXT_EXTENSION_355_EXTENSION_NAME = 'VK_EXT_extension_355';
  VK_EXT_VERTEX_ATTRIBUTE_ALIASING_EXTENSION_NAME = 'VK_EXT_vertex_attribute_aliasing';
  VK_KHR_EXTENSION_358_EXTENSION_NAME = 'VK_KHR_extension_358';
  VK_EXT_EXTENSION_362_EXTENSION_NAME = 'VK_EXT_extension_362';
  VK_EXT_EXTENSION_363_EXTENSION_NAME = 'VK_EXT_extension_363';
  VK_EXT_EXTENSION_364_EXTENSION_NAME = 'VK_EXT_extension_364';
  VK_FUCHSIA_EXTERNAL_MEMORY_EXTENSION_NAME = 'VK_FUCHSIA_external_memory';
  VK_FUCHSIA_EXTERNAL_SEMAPHORE_EXTENSION_NAME = 'VK_FUCHSIA_external_semaphore';
  VK_EXT_EXTENSION_367_EXTENSION_NAME = 'VK_EXT_extension_367';
  VK_EXT_EXTENSION_368_EXTENSION_NAME = 'VK_EXT_extension_368';
  VK_QCOM_EXTENSION_369_EXTENSION_NAME = 'VK_QCOM_extension_369';
  VK_HUAWEI_SUBPASS_SHADING_EXTENSION_NAME = 'VK_HUAWEI_subpass_shading';
  VK_HUAWEI_INVOCATION_MASK_EXTENSION_NAME = 'VK_HUAWEI_invocation_mask';
  VK_NV_EXTERNAL_MEMORY_RDMA_EXTENSION_NAME = 'VK_NV_external_memory_rdma';
  VK_NV_EXTENSION_373_EXTENSION_NAME = 'VK_NV_extension_373';
  VK_NV_EXTENSION_374_EXTENSION_NAME = 'VK_NV_extension_374';
  VK_NV_EXTENSION_375_EXTENSION_NAME = 'VK_NV_extension_375';
  VK_EXT_EXTENSION_376_EXTENSION_NAME = 'VK_EXT_extension_376';
  VK_EXT_EXTENSION_377_EXTENSION_NAME = 'VK_EXT_extension_377';
  VK_EXT_EXTENDED_DYNAMIC_STATE_2_EXTENSION_NAME = 'VK_EXT_extended_dynamic_state2';
  VK_QNX_SCREEN_SURFACE_EXTENSION_NAME = 'VK_QNX_screen_surface';
  VK_KHR_EXTENSION_380_EXTENSION_NAME = 'VK_KHR_extension_380';
  VK_KHR_EXTENSION_381_EXTENSION_NAME = 'VK_KHR_extension_381';
  VK_EXT_COLOR_WRITE_ENABLE_EXTENSION_NAME = 'VK_EXT_color_write_enable';
  VK_EXT_EXTENSION_383_EXTENSION_NAME = 'VK_EXT_extension_383';
  VK_EXT_EXTENSION_384_EXTENSION_NAME = 'VK_EXT_extension_384';
  VK_MESA_EXTENSION_385_EXTENSION_NAME = 'VK_MESA_extension_385';
  VK_GOOGLE_EXTENSION_386_EXTENSION_NAME = 'VK_GOOGLE_extension_386';
  VK_KHR_EXTENSION_387_EXTENSION_NAME = 'VK_KHR_extension_387';
  VK_EXT_EXTENSION_388_EXTENSION_NAME = 'VK_EXT_extension_388';
  VK_EXT_GLOBAL_PRIORITY_QUERY_EXTENSION_NAME = 'VK_EXT_global_priority_query';
  VK_EXT_EXTENSION_390_EXTENSION_NAME = 'VK_EXT_extension_390';
  VK_EXT_EXTENSION_391_EXTENSION_NAME = 'VK_EXT_extension_391';
  VK_EXT_EXTENSION_392_EXTENSION_NAME = 'VK_EXT_extension_392';
  VK_EXT_MULTI_DRAW_EXTENSION_NAME = 'VK_EXT_multi_draw';
  VK_EXT_EXTENSION_394_EXTENSION_NAME = 'VK_EXT_extension_394';
  VK_KHR_EXTENSION_395_EXTENSION_NAME = 'VK_KHR_extension_395';
  VK_KHR_EXTENSION_396_EXTENSION_NAME = 'VK_KHR_extension_396';
  VK_NV_EXTENSION_397_EXTENSION_NAME = 'VK_NV_extension_397';
  VK_NV_EXTENSION_398_EXTENSION_NAME = 'VK_NV_extension_398';
  VK_JUICE_EXTENSION_399_EXTENSION_NAME = 'VK_JUICE_extension_399';
  VK_JUICE_EXTENSION_400_EXTENSION_NAME = 'VK_JUICE_extension_400';
  VK_EXT_LOAD_STORE_OP_NONE_EXTENSION_NAME = 'VK_EXT_load_store_op_none';
  VK_FB_EXTENSION_402_EXTENSION_NAME = 'VK_FB_extension_402';
  VK_FB_EXTENSION_403_EXTENSION_NAME = 'VK_FB_extension_403';
  VK_FB_EXTENSION_404_EXTENSION_NAME = 'VK_FB_extension_404';
  VK_HUAWEI_EXTENSION_405_EXTENSION_NAME = 'VK_HUAWEI_extension_405';
  VK_HUAWEI_EXTENSION_406_EXTENSION_NAME = 'VK_HUAWEI_extension_406';
  VK_GGP_EXTENSION_407_EXTENSION_NAME = 'VK_GGP_extension_407';
  VK_GGP_EXTENSION_408_EXTENSION_NAME = 'VK_GGP_extension_408';
  VK_GGP_EXTENSION_409_EXTENSION_NAME = 'VK_GGP_extension_409';
  VK_GGP_EXTENSION_410_EXTENSION_NAME = 'VK_GGP_extension_410';
  VK_GGP_EXTENSION_411_EXTENSION_NAME = 'VK_GGP_extension_411';
  VK_NV_EXTENSION_412_EXTENSION_NAME = 'VK_NV_extension_412';
  VK_NV_EXTENSION_413_EXTENSION_NAME = 'VK_NV_extension_413';
  VK_NV_EXTENSION_414_EXTENSION_NAME = 'VK_NV_extension_414';
  VK_HUAWEI_EXTENSION_415_EXTENSION_NAME = 'VK_HUAWEI_extension_415';
  VK_ARM_EXTENSION_416_EXTENSION_NAME = 'VK_ARM_extension_416';
  VK_ARM_EXTENSION_417_EXTENSION_NAME = 'VK_ARM_extension_417';
  VK_ARM_EXTENSION_418_EXTENSION_NAME = 'VK_ARM_extension_418';
  VK_EXT_EXTENSION_419_EXTENSION_NAME = 'VK_EXT_extension_419';
  VK_EXT_EXTENSION_420_EXTENSION_NAME = 'VK_EXT_extension_420';
  VK_KHR_EXTENSION_421_EXTENSION_NAME = 'VK_KHR_extension_421';
  VK_EXT_EXTENSION_422_EXTENSION_NAME = 'VK_EXT_extension_422';
{$ENDIF} // DVULKAN_NAMES

type
  PFN_vkInternalAllocationNotification = procedure (pUserData: Pointer; size: SizeUInt; allocationType: VkInternalAllocationType; allocationScope: VkSystemAllocationScope); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
  PFN_vkInternalFreeNotification = procedure (pUserData: Pointer; size: SizeUInt; allocationType: VkInternalAllocationType; allocationScope: VkSystemAllocationScope); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
  PFN_vkReallocationFunction = function  (pUserData: Pointer; pOriginal: Pointer; size: SizeUInt; alignment: SizeUInt; allocationScope: VkSystemAllocationScope): Pointer; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
  PFN_vkAllocationFunction = function  (pUserData: Pointer; size: SizeUInt; alignment: SizeUInt; allocationScope: VkSystemAllocationScope): Pointer; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
  PFN_vkFreeFunction = procedure (pUserData: Pointer; pMemory: Pointer); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
  PFN_vkDebugReportCallbackEXT = function  (flags: VkDebugReportFlagsEXT; objectType: VkDebugReportObjectTypeEXT; _object: UInt64; location: SizeUInt; messageCode: Int32; pLayerPrefix: PAnsiChar; pMessage: PAnsiChar; pUserData: Pointer): UInt32; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
  PVkDebugUtilsMessengerCallbackDataEXT = ^VkDebugUtilsMessengerCallbackDataEXT;
  PFN_vkDebugUtilsMessengerCallbackEXT = function  (messageSeverity: VkDebugUtilsMessageSeverityFlagBitsEXT; messageTypes: VkDebugUtilsMessageTypeFlagsEXT; pCallbackData: PVkDebugUtilsMessengerCallbackDataEXT; pUserData: Pointer): UInt32; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
  PVkDeviceMemoryReportCallbackDataEXT = ^VkDeviceMemoryReportCallbackDataEXT;
  PFN_vkDeviceMemoryReportCallbackEXT = procedure (pCallbackData: PVkDeviceMemoryReportCallbackDataEXT; pUserData: Pointer); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}

PVkBaseOutStructure = ^VkBaseOutStructure;
PPVkBaseOutStructure = ^PVkBaseOutStructure;
VkBaseOutStructure = record
  sType: VkStructureType;
  pNext: PVkBaseOutStructure;
end;


PVkBaseInStructure = ^VkBaseInStructure;
PPVkBaseInStructure = ^PVkBaseInStructure;
VkBaseInStructure = record
  sType: VkStructureType;
  pNext: PVkBaseInStructure;
end;


PVkOffset2D  =  ^VkOffset2D;
PPVkOffset2D = ^PVkOffset2D;
VkOffset2D = record
  x: Int32;
  y: Int32;
end;


PVkOffset3D  =  ^VkOffset3D;
PPVkOffset3D = ^PVkOffset3D;
VkOffset3D = record
  x: Int32;
  y: Int32;
  z: Int32;
end;


PVkExtent2D  =  ^VkExtent2D;
PPVkExtent2D = ^PVkExtent2D;
VkExtent2D = record
  width: UInt32;
  height: UInt32;
end;


PVkExtent3D  =  ^VkExtent3D;
PPVkExtent3D = ^PVkExtent3D;
VkExtent3D = record
  width: UInt32;
  height: UInt32;
  depth: UInt32;
end;


PVkViewport  =  ^VkViewport;
PPVkViewport = ^PVkViewport;
VkViewport = record
  x: Single;
  y: Single;
  width: Single;
  height: Single;
  minDepth: Single;
  maxDepth: Single;
end;


PVkRect2D  =  ^VkRect2D;
PPVkRect2D = ^PVkRect2D;
VkRect2D = record
  offset: VkOffset2D;
  extent: VkExtent2D;
end;


PVkClearRect  =  ^VkClearRect;
PPVkClearRect = ^PVkClearRect;
VkClearRect = record
  rect: VkRect2D;
  baseArrayLayer: UInt32;
  layerCount: UInt32;
end;


PVkComponentMapping  =  ^VkComponentMapping;
PPVkComponentMapping = ^PVkComponentMapping;
VkComponentMapping = record
  r: VkComponentSwizzle;
  g: VkComponentSwizzle;
  b: VkComponentSwizzle;
  a: VkComponentSwizzle;
end;


PVkExtensionProperties  =  ^VkExtensionProperties;
PPVkExtensionProperties = ^PVkExtensionProperties;
VkExtensionProperties = record
  extensionName: array[0 .. VK_MAX_EXTENSION_NAME_SIZE - 1] of AnsiChar;
  specVersion: UInt32;
end;


PVkLayerProperties  =  ^VkLayerProperties;
PPVkLayerProperties = ^PVkLayerProperties;
VkLayerProperties = record
  layerName: array[0 .. VK_MAX_EXTENSION_NAME_SIZE - 1] of AnsiChar;
  specVersion: UInt32;
  implementationVersion: UInt32;
  description: array[0 .. VK_MAX_DESCRIPTION_SIZE - 1] of AnsiChar;
end;


PVkApplicationInfo  =  ^VkApplicationInfo;
PPVkApplicationInfo = ^PVkApplicationInfo;
VkApplicationInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  pApplicationName: PAnsiChar;
  applicationVersion: UInt32;
  pEngineName: PAnsiChar;
  engineVersion: UInt32;
  apiVersion: UInt32;
end;


PVkAllocationCallbacks  =  ^VkAllocationCallbacks;
PPVkAllocationCallbacks = ^PVkAllocationCallbacks;
VkAllocationCallbacks = record
  pUserData: Pointer;
  pfnAllocation: PFN_vkAllocationFunction;
  pfnReallocation: PFN_vkReallocationFunction;
  pfnFree: PFN_vkFreeFunction;
  pfnInternalAllocation: PFN_vkInternalAllocationNotification;
  pfnInternalFree: PFN_vkInternalFreeNotification;
end;


PSingle = ^Single;
PVkDeviceQueueCreateInfo  =  ^VkDeviceQueueCreateInfo;
PPVkDeviceQueueCreateInfo = ^PVkDeviceQueueCreateInfo;
VkDeviceQueueCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkDeviceQueueCreateFlags;
  queueFamilyIndex: UInt32;
  queueCount: UInt32;
  pQueuePriorities: PSingle;
end;


PVkPhysicalDeviceFeatures = ^VkPhysicalDeviceFeatures;
PVkDeviceCreateInfo  =  ^VkDeviceCreateInfo;
PPVkDeviceCreateInfo = ^PVkDeviceCreateInfo;
VkDeviceCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkDeviceCreateFlags;
  queueCreateInfoCount: UInt32;
  pQueueCreateInfos: PVkDeviceQueueCreateInfo;
  enabledLayerCount: UInt32;
  ppEnabledLayerNames: PPAnsiChar;
  enabledExtensionCount: UInt32;
  ppEnabledExtensionNames: PPAnsiChar;
  pEnabledFeatures: PVkPhysicalDeviceFeatures;
end;


PVkInstanceCreateInfo  =  ^VkInstanceCreateInfo;
PPVkInstanceCreateInfo = ^PVkInstanceCreateInfo;
VkInstanceCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkInstanceCreateFlags;
  pApplicationInfo: PVkApplicationInfo;
  enabledLayerCount: UInt32;
  ppEnabledLayerNames: PPAnsiChar;
  enabledExtensionCount: UInt32;
  ppEnabledExtensionNames: PPAnsiChar;
end;


PVkQueueFamilyProperties  =  ^VkQueueFamilyProperties;
PPVkQueueFamilyProperties = ^PVkQueueFamilyProperties;
VkQueueFamilyProperties = record
  queueFlags: VkQueueFlags;
  queueCount: UInt32;
  timestampValidBits: UInt32;
  minImageTransferGranularity: VkExtent3D;
end;


PVkMemoryAllocateInfo  =  ^VkMemoryAllocateInfo;
PPVkMemoryAllocateInfo = ^PVkMemoryAllocateInfo;
VkMemoryAllocateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  allocationSize: VkDeviceSize;
  memoryTypeIndex: UInt32;
end;


PVkMemoryRequirements  =  ^VkMemoryRequirements;
PPVkMemoryRequirements = ^PVkMemoryRequirements;
VkMemoryRequirements = record
  size: VkDeviceSize;
  alignment: VkDeviceSize;
  memoryTypeBits: UInt32;
end;


PVkSparseImageFormatProperties  =  ^VkSparseImageFormatProperties;
PPVkSparseImageFormatProperties = ^PVkSparseImageFormatProperties;
VkSparseImageFormatProperties = record
  aspectMask: VkImageAspectFlags;
  imageGranularity: VkExtent3D;
  flags: VkSparseImageFormatFlags;
end;


PVkSparseImageMemoryRequirements  =  ^VkSparseImageMemoryRequirements;
PPVkSparseImageMemoryRequirements = ^PVkSparseImageMemoryRequirements;
VkSparseImageMemoryRequirements = record
  formatProperties: VkSparseImageFormatProperties;
  imageMipTailFirstLod: UInt32;
  imageMipTailSize: VkDeviceSize;
  imageMipTailOffset: VkDeviceSize;
  imageMipTailStride: VkDeviceSize;
end;


PVkMemoryType  =  ^VkMemoryType;
PPVkMemoryType = ^PVkMemoryType;
VkMemoryType = record
  propertyFlags: VkMemoryPropertyFlags;
  heapIndex: UInt32;
end;


PVkMemoryHeap  =  ^VkMemoryHeap;
PPVkMemoryHeap = ^PVkMemoryHeap;
VkMemoryHeap = record
  size: VkDeviceSize;
  flags: VkMemoryHeapFlags;
end;


PVkMappedMemoryRange  =  ^VkMappedMemoryRange;
PPVkMappedMemoryRange = ^PVkMappedMemoryRange;
VkMappedMemoryRange = record
  sType: VkStructureType;
  pNext: Pointer;
  memory: VkDeviceMemory;
  offset: VkDeviceSize;
  size: VkDeviceSize;
end;


PVkFormatProperties  =  ^VkFormatProperties;
PPVkFormatProperties = ^PVkFormatProperties;
VkFormatProperties = record
  linearTilingFeatures: VkFormatFeatureFlags;
  optimalTilingFeatures: VkFormatFeatureFlags;
  bufferFeatures: VkFormatFeatureFlags;
end;


PVkImageFormatProperties  =  ^VkImageFormatProperties;
PPVkImageFormatProperties = ^PVkImageFormatProperties;
VkImageFormatProperties = record
  maxExtent: VkExtent3D;
  maxMipLevels: UInt32;
  maxArrayLayers: UInt32;
  sampleCounts: VkSampleCountFlags;
  maxResourceSize: VkDeviceSize;
end;


PVkDescriptorBufferInfo  =  ^VkDescriptorBufferInfo;
PPVkDescriptorBufferInfo = ^PVkDescriptorBufferInfo;
VkDescriptorBufferInfo = record
  buffer: VkBuffer;
  offset: VkDeviceSize;
  range: VkDeviceSize;
end;


PVkDescriptorImageInfo  =  ^VkDescriptorImageInfo;
PPVkDescriptorImageInfo = ^PVkDescriptorImageInfo;
VkDescriptorImageInfo = record
  sampler: VkSampler;
  imageView: VkImageView;
  imageLayout: VkImageLayout;
end;


PVkWriteDescriptorSet  =  ^VkWriteDescriptorSet;
PPVkWriteDescriptorSet = ^PVkWriteDescriptorSet;
VkWriteDescriptorSet = record
  sType: VkStructureType;
  pNext: Pointer;
  dstSet: VkDescriptorSet;
  dstBinding: UInt32;
  dstArrayElement: UInt32;
  descriptorCount: UInt32;
  descriptorType: VkDescriptorType;
  pImageInfo: PVkDescriptorImageInfo;
  pBufferInfo: PVkDescriptorBufferInfo;
  pTexelBufferView: PVkBufferView;
end;


PVkCopyDescriptorSet  =  ^VkCopyDescriptorSet;
PPVkCopyDescriptorSet = ^PVkCopyDescriptorSet;
VkCopyDescriptorSet = record
  sType: VkStructureType;
  pNext: Pointer;
  srcSet: VkDescriptorSet;
  srcBinding: UInt32;
  srcArrayElement: UInt32;
  dstSet: VkDescriptorSet;
  dstBinding: UInt32;
  dstArrayElement: UInt32;
  descriptorCount: UInt32;
end;


PVkBufferCreateInfo  =  ^VkBufferCreateInfo;
PPVkBufferCreateInfo = ^PVkBufferCreateInfo;
VkBufferCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkBufferCreateFlags;
  size: VkDeviceSize;
  usage: VkBufferUsageFlags;
  sharingMode: VkSharingMode;
  queueFamilyIndexCount: UInt32;
  pQueueFamilyIndices: PUInt32;
end;


PVkBufferViewCreateInfo  =  ^VkBufferViewCreateInfo;
PPVkBufferViewCreateInfo = ^PVkBufferViewCreateInfo;
VkBufferViewCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkBufferViewCreateFlags;
  buffer: VkBuffer;
  format: VkFormat;
  offset: VkDeviceSize;
  range: VkDeviceSize;
end;


PVkImageSubresource  =  ^VkImageSubresource;
PPVkImageSubresource = ^PVkImageSubresource;
VkImageSubresource = record
  aspectMask: VkImageAspectFlags;
  mipLevel: UInt32;
  arrayLayer: UInt32;
end;


PVkImageSubresourceLayers  =  ^VkImageSubresourceLayers;
PPVkImageSubresourceLayers = ^PVkImageSubresourceLayers;
VkImageSubresourceLayers = record
  aspectMask: VkImageAspectFlags;
  mipLevel: UInt32;
  baseArrayLayer: UInt32;
  layerCount: UInt32;
end;


PVkImageSubresourceRange  =  ^VkImageSubresourceRange;
PPVkImageSubresourceRange = ^PVkImageSubresourceRange;
VkImageSubresourceRange = record
  aspectMask: VkImageAspectFlags;
  baseMipLevel: UInt32;
  levelCount: UInt32;
  baseArrayLayer: UInt32;
  layerCount: UInt32;
end;


PVkMemoryBarrier  =  ^VkMemoryBarrier;
PPVkMemoryBarrier = ^PVkMemoryBarrier;
VkMemoryBarrier = record
  sType: VkStructureType;
  pNext: Pointer;
  srcAccessMask: VkAccessFlags;
  dstAccessMask: VkAccessFlags;
end;


PVkBufferMemoryBarrier  =  ^VkBufferMemoryBarrier;
PPVkBufferMemoryBarrier = ^PVkBufferMemoryBarrier;
VkBufferMemoryBarrier = record
  sType: VkStructureType;
  pNext: Pointer;
  srcAccessMask: VkAccessFlags;
  dstAccessMask: VkAccessFlags;
  srcQueueFamilyIndex: UInt32;
  dstQueueFamilyIndex: UInt32;
  buffer: VkBuffer;
  offset: VkDeviceSize;
  size: VkDeviceSize;
end;


PVkImageMemoryBarrier  =  ^VkImageMemoryBarrier;
PPVkImageMemoryBarrier = ^PVkImageMemoryBarrier;
VkImageMemoryBarrier = record
  sType: VkStructureType;
  pNext: Pointer;
  srcAccessMask: VkAccessFlags;
  dstAccessMask: VkAccessFlags;
  oldLayout: VkImageLayout;
  newLayout: VkImageLayout;
  srcQueueFamilyIndex: UInt32;
  dstQueueFamilyIndex: UInt32;
  image: VkImage;
  subresourceRange: VkImageSubresourceRange;
end;


PVkImageCreateInfo  =  ^VkImageCreateInfo;
PPVkImageCreateInfo = ^PVkImageCreateInfo;
VkImageCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkImageCreateFlags;
  imageType: VkImageType;
  format: VkFormat;
  extent: VkExtent3D;
  mipLevels: UInt32;
  arrayLayers: UInt32;
  samples: VkSampleCountFlagBits;
  tiling: VkImageTiling;
  usage: VkImageUsageFlags;
  sharingMode: VkSharingMode;
  queueFamilyIndexCount: UInt32;
  pQueueFamilyIndices: PUInt32;
  initialLayout: VkImageLayout;
end;


PVkSubresourceLayout  =  ^VkSubresourceLayout;
PPVkSubresourceLayout = ^PVkSubresourceLayout;
VkSubresourceLayout = record
  offset: VkDeviceSize;
  size: VkDeviceSize;
  rowPitch: VkDeviceSize;
  arrayPitch: VkDeviceSize;
  depthPitch: VkDeviceSize;
end;


PVkImageViewCreateInfo  =  ^VkImageViewCreateInfo;
PPVkImageViewCreateInfo = ^PVkImageViewCreateInfo;
VkImageViewCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkImageViewCreateFlags;
  image: VkImage;
  viewType: VkImageViewType;
  format: VkFormat;
  components: VkComponentMapping;
  subresourceRange: VkImageSubresourceRange;
end;


PVkBufferCopy  =  ^VkBufferCopy;
PPVkBufferCopy = ^PVkBufferCopy;
VkBufferCopy = record
  srcOffset: VkDeviceSize;
  dstOffset: VkDeviceSize;
  size: VkDeviceSize;
end;


PVkSparseMemoryBind  =  ^VkSparseMemoryBind;
PPVkSparseMemoryBind = ^PVkSparseMemoryBind;
VkSparseMemoryBind = record
  resourceOffset: VkDeviceSize;
  size: VkDeviceSize;
  memory: VkDeviceMemory;
  memoryOffset: VkDeviceSize;
  flags: VkSparseMemoryBindFlags;
end;


PVkSparseImageMemoryBind  =  ^VkSparseImageMemoryBind;
PPVkSparseImageMemoryBind = ^PVkSparseImageMemoryBind;
VkSparseImageMemoryBind = record
  subresource: VkImageSubresource;
  offset: VkOffset3D;
  extent: VkExtent3D;
  memory: VkDeviceMemory;
  memoryOffset: VkDeviceSize;
  flags: VkSparseMemoryBindFlags;
end;


PVkSparseBufferMemoryBindInfo  =  ^VkSparseBufferMemoryBindInfo;
PPVkSparseBufferMemoryBindInfo = ^PVkSparseBufferMemoryBindInfo;
VkSparseBufferMemoryBindInfo = record
  buffer: VkBuffer;
  bindCount: UInt32;
  pBinds: PVkSparseMemoryBind;
end;


PVkSparseImageOpaqueMemoryBindInfo  =  ^VkSparseImageOpaqueMemoryBindInfo;
PPVkSparseImageOpaqueMemoryBindInfo = ^PVkSparseImageOpaqueMemoryBindInfo;
VkSparseImageOpaqueMemoryBindInfo = record
  image: VkImage;
  bindCount: UInt32;
  pBinds: PVkSparseMemoryBind;
end;


PVkSparseImageMemoryBindInfo  =  ^VkSparseImageMemoryBindInfo;
PPVkSparseImageMemoryBindInfo = ^PVkSparseImageMemoryBindInfo;
VkSparseImageMemoryBindInfo = record
  image: VkImage;
  bindCount: UInt32;
  pBinds: PVkSparseImageMemoryBind;
end;


PVkBindSparseInfo  =  ^VkBindSparseInfo;
PPVkBindSparseInfo = ^PVkBindSparseInfo;
VkBindSparseInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  waitSemaphoreCount: UInt32;
  pWaitSemaphores: PVkSemaphore;
  bufferBindCount: UInt32;
  pBufferBinds: PVkSparseBufferMemoryBindInfo;
  imageOpaqueBindCount: UInt32;
  pImageOpaqueBinds: PVkSparseImageOpaqueMemoryBindInfo;
  imageBindCount: UInt32;
  pImageBinds: PVkSparseImageMemoryBindInfo;
  signalSemaphoreCount: UInt32;
  pSignalSemaphores: PVkSemaphore;
end;


PVkImageCopy  =  ^VkImageCopy;
PPVkImageCopy = ^PVkImageCopy;
VkImageCopy = record
  srcSubresource: VkImageSubresourceLayers;
  srcOffset: VkOffset3D;
  dstSubresource: VkImageSubresourceLayers;
  dstOffset: VkOffset3D;
  extent: VkExtent3D;
end;


PVkImageBlit  =  ^VkImageBlit;
PPVkImageBlit = ^PVkImageBlit;
VkImageBlit = record
  srcSubresource: VkImageSubresourceLayers;
  srcOffsets: array[0 .. 2 - 1] of VkOffset3D;
  dstSubresource: VkImageSubresourceLayers;
  dstOffsets: array[0 .. 2 - 1] of VkOffset3D;
end;


PVkBufferImageCopy  =  ^VkBufferImageCopy;
PPVkBufferImageCopy = ^PVkBufferImageCopy;
VkBufferImageCopy = record
  bufferOffset: VkDeviceSize;
  bufferRowLength: UInt32;
  bufferImageHeight: UInt32;
  imageSubresource: VkImageSubresourceLayers;
  imageOffset: VkOffset3D;
  imageExtent: VkExtent3D;
end;


PVkImageResolve  =  ^VkImageResolve;
PPVkImageResolve = ^PVkImageResolve;
VkImageResolve = record
  srcSubresource: VkImageSubresourceLayers;
  srcOffset: VkOffset3D;
  dstSubresource: VkImageSubresourceLayers;
  dstOffset: VkOffset3D;
  extent: VkExtent3D;
end;


PVkShaderModuleCreateInfo  =  ^VkShaderModuleCreateInfo;
PPVkShaderModuleCreateInfo = ^PVkShaderModuleCreateInfo;
VkShaderModuleCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkShaderModuleCreateFlags;
  codeSize: SizeUInt;
  pCode: PUInt32;
end;


PVkDescriptorSetLayoutBinding  =  ^VkDescriptorSetLayoutBinding;
PPVkDescriptorSetLayoutBinding = ^PVkDescriptorSetLayoutBinding;
VkDescriptorSetLayoutBinding = record
  binding: UInt32;
  descriptorType: VkDescriptorType;
  descriptorCount: UInt32;
  stageFlags: VkShaderStageFlags;
  pImmutableSamplers: PVkSampler;
end;


PVkDescriptorSetLayoutCreateInfo  =  ^VkDescriptorSetLayoutCreateInfo;
PPVkDescriptorSetLayoutCreateInfo = ^PVkDescriptorSetLayoutCreateInfo;
VkDescriptorSetLayoutCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkDescriptorSetLayoutCreateFlags;
  bindingCount: UInt32;
  pBindings: PVkDescriptorSetLayoutBinding;
end;


PVkDescriptorPoolSize  =  ^VkDescriptorPoolSize;
PPVkDescriptorPoolSize = ^PVkDescriptorPoolSize;
VkDescriptorPoolSize = record
  _type: VkDescriptorType;
  descriptorCount: UInt32;
end;


PVkDescriptorPoolCreateInfo  =  ^VkDescriptorPoolCreateInfo;
PPVkDescriptorPoolCreateInfo = ^PVkDescriptorPoolCreateInfo;
VkDescriptorPoolCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkDescriptorPoolCreateFlags;
  maxSets: UInt32;
  poolSizeCount: UInt32;
  pPoolSizes: PVkDescriptorPoolSize;
end;


PVkDescriptorSetAllocateInfo  =  ^VkDescriptorSetAllocateInfo;
PPVkDescriptorSetAllocateInfo = ^PVkDescriptorSetAllocateInfo;
VkDescriptorSetAllocateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  descriptorPool: VkDescriptorPool;
  descriptorSetCount: UInt32;
  pSetLayouts: PVkDescriptorSetLayout;
end;


PVkSpecializationMapEntry  =  ^VkSpecializationMapEntry;
PPVkSpecializationMapEntry = ^PVkSpecializationMapEntry;
VkSpecializationMapEntry = record
  constantID: UInt32;
  offset: UInt32;
  size: SizeUInt;
end;


PVkSpecializationInfo  =  ^VkSpecializationInfo;
PPVkSpecializationInfo = ^PVkSpecializationInfo;
VkSpecializationInfo = record
  mapEntryCount: UInt32;
  pMapEntries: PVkSpecializationMapEntry;
  dataSize: SizeUInt;
  pData: Pointer;
end;


PVkPipelineShaderStageCreateInfo  =  ^VkPipelineShaderStageCreateInfo;
PPVkPipelineShaderStageCreateInfo = ^PVkPipelineShaderStageCreateInfo;
VkPipelineShaderStageCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineShaderStageCreateFlags;
  stage: VkShaderStageFlagBits;
  module: VkShaderModule;
  pName: PAnsiChar;
  pSpecializationInfo: PVkSpecializationInfo;
end;


PVkComputePipelineCreateInfo  =  ^VkComputePipelineCreateInfo;
PPVkComputePipelineCreateInfo = ^PVkComputePipelineCreateInfo;
VkComputePipelineCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineCreateFlags;
  stage: VkPipelineShaderStageCreateInfo;
  layout: VkPipelineLayout;
  basePipelineHandle: VkPipeline;
  basePipelineIndex: Int32;
end;


PVkVertexInputBindingDescription  =  ^VkVertexInputBindingDescription;
PPVkVertexInputBindingDescription = ^PVkVertexInputBindingDescription;
VkVertexInputBindingDescription = record
  binding: UInt32;
  stride: UInt32;
  inputRate: VkVertexInputRate;
end;


PVkVertexInputAttributeDescription  =  ^VkVertexInputAttributeDescription;
PPVkVertexInputAttributeDescription = ^PVkVertexInputAttributeDescription;
VkVertexInputAttributeDescription = record
  location: UInt32;
  binding: UInt32;
  format: VkFormat;
  offset: UInt32;
end;


PVkPipelineVertexInputStateCreateInfo  =  ^VkPipelineVertexInputStateCreateInfo;
PPVkPipelineVertexInputStateCreateInfo = ^PVkPipelineVertexInputStateCreateInfo;
VkPipelineVertexInputStateCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineVertexInputStateCreateFlags;
  vertexBindingDescriptionCount: UInt32;
  pVertexBindingDescriptions: PVkVertexInputBindingDescription;
  vertexAttributeDescriptionCount: UInt32;
  pVertexAttributeDescriptions: PVkVertexInputAttributeDescription;
end;


PVkPipelineInputAssemblyStateCreateInfo  =  ^VkPipelineInputAssemblyStateCreateInfo;
PPVkPipelineInputAssemblyStateCreateInfo = ^PVkPipelineInputAssemblyStateCreateInfo;
VkPipelineInputAssemblyStateCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineInputAssemblyStateCreateFlags;
  topology: VkPrimitiveTopology;
  primitiveRestartEnable: VkBool32;
end;


PVkPipelineTessellationStateCreateInfo  =  ^VkPipelineTessellationStateCreateInfo;
PPVkPipelineTessellationStateCreateInfo = ^PVkPipelineTessellationStateCreateInfo;
VkPipelineTessellationStateCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineTessellationStateCreateFlags;
  patchControlPoints: UInt32;
end;


PVkPipelineViewportStateCreateInfo  =  ^VkPipelineViewportStateCreateInfo;
PPVkPipelineViewportStateCreateInfo = ^PVkPipelineViewportStateCreateInfo;
VkPipelineViewportStateCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineViewportStateCreateFlags;
  viewportCount: UInt32;
  pViewports: PVkViewport;
  scissorCount: UInt32;
  pScissors: PVkRect2D;
end;


PVkPipelineRasterizationStateCreateInfo  =  ^VkPipelineRasterizationStateCreateInfo;
PPVkPipelineRasterizationStateCreateInfo = ^PVkPipelineRasterizationStateCreateInfo;
VkPipelineRasterizationStateCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineRasterizationStateCreateFlags;
  depthClampEnable: VkBool32;
  rasterizerDiscardEnable: VkBool32;
  polygonMode: VkPolygonMode;
  cullMode: VkCullModeFlags;
  frontFace: VkFrontFace;
  depthBiasEnable: VkBool32;
  depthBiasConstantFactor: Single;
  depthBiasClamp: Single;
  depthBiasSlopeFactor: Single;
  lineWidth: Single;
end;


PVkPipelineMultisampleStateCreateInfo  =  ^VkPipelineMultisampleStateCreateInfo;
PPVkPipelineMultisampleStateCreateInfo = ^PVkPipelineMultisampleStateCreateInfo;
VkPipelineMultisampleStateCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineMultisampleStateCreateFlags;
  rasterizationSamples: VkSampleCountFlagBits;
  sampleShadingEnable: VkBool32;
  minSampleShading: Single;
  pSampleMask: PVkSampleMask;
  alphaToCoverageEnable: VkBool32;
  alphaToOneEnable: VkBool32;
end;


PVkPipelineColorBlendAttachmentState  =  ^VkPipelineColorBlendAttachmentState;
PPVkPipelineColorBlendAttachmentState = ^PVkPipelineColorBlendAttachmentState;
VkPipelineColorBlendAttachmentState = record
  blendEnable: VkBool32;
  srcColorBlendFactor: VkBlendFactor;
  dstColorBlendFactor: VkBlendFactor;
  colorBlendOp: VkBlendOp;
  srcAlphaBlendFactor: VkBlendFactor;
  dstAlphaBlendFactor: VkBlendFactor;
  alphaBlendOp: VkBlendOp;
  colorWriteMask: VkColorComponentFlags;
end;


PVkPipelineColorBlendStateCreateInfo  =  ^VkPipelineColorBlendStateCreateInfo;
PPVkPipelineColorBlendStateCreateInfo = ^PVkPipelineColorBlendStateCreateInfo;
VkPipelineColorBlendStateCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineColorBlendStateCreateFlags;
  logicOpEnable: VkBool32;
  logicOp: VkLogicOp;
  attachmentCount: UInt32;
  pAttachments: PVkPipelineColorBlendAttachmentState;
  blendConstants: array[0 .. 4 - 1] of Single;
end;


PVkPipelineDynamicStateCreateInfo  =  ^VkPipelineDynamicStateCreateInfo;
PPVkPipelineDynamicStateCreateInfo = ^PVkPipelineDynamicStateCreateInfo;
VkPipelineDynamicStateCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineDynamicStateCreateFlags;
  dynamicStateCount: UInt32;
  pDynamicStates: PVkDynamicState;
end;


PVkStencilOpState  =  ^VkStencilOpState;
PPVkStencilOpState = ^PVkStencilOpState;
VkStencilOpState = record
  failOp: VkStencilOp;
  passOp: VkStencilOp;
  depthFailOp: VkStencilOp;
  compareOp: VkCompareOp;
  compareMask: UInt32;
  writeMask: UInt32;
  reference: UInt32;
end;


PVkPipelineDepthStencilStateCreateInfo  =  ^VkPipelineDepthStencilStateCreateInfo;
PPVkPipelineDepthStencilStateCreateInfo = ^PVkPipelineDepthStencilStateCreateInfo;
VkPipelineDepthStencilStateCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineDepthStencilStateCreateFlags;
  depthTestEnable: VkBool32;
  depthWriteEnable: VkBool32;
  depthCompareOp: VkCompareOp;
  depthBoundsTestEnable: VkBool32;
  stencilTestEnable: VkBool32;
  front: VkStencilOpState;
  back: VkStencilOpState;
  minDepthBounds: Single;
  maxDepthBounds: Single;
end;


PVkGraphicsPipelineCreateInfo  =  ^VkGraphicsPipelineCreateInfo;
PPVkGraphicsPipelineCreateInfo = ^PVkGraphicsPipelineCreateInfo;
VkGraphicsPipelineCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineCreateFlags;
  stageCount: UInt32;
  pStages: PVkPipelineShaderStageCreateInfo;
  pVertexInputState: PVkPipelineVertexInputStateCreateInfo;
  pInputAssemblyState: PVkPipelineInputAssemblyStateCreateInfo;
  pTessellationState: PVkPipelineTessellationStateCreateInfo;
  pViewportState: PVkPipelineViewportStateCreateInfo;
  pRasterizationState: PVkPipelineRasterizationStateCreateInfo;
  pMultisampleState: PVkPipelineMultisampleStateCreateInfo;
  pDepthStencilState: PVkPipelineDepthStencilStateCreateInfo;
  pColorBlendState: PVkPipelineColorBlendStateCreateInfo;
  pDynamicState: PVkPipelineDynamicStateCreateInfo;
  layout: VkPipelineLayout;
  renderPass: VkRenderPass;
  subpass: UInt32;
  basePipelineHandle: VkPipeline;
  basePipelineIndex: Int32;
end;


PVkPipelineCacheCreateInfo  =  ^VkPipelineCacheCreateInfo;
PPVkPipelineCacheCreateInfo = ^PVkPipelineCacheCreateInfo;
VkPipelineCacheCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineCacheCreateFlags;
  initialDataSize: SizeUInt;
  pInitialData: Pointer;
end;


PVkPipelineCacheHeaderVersionOne  =  ^VkPipelineCacheHeaderVersionOne;
PPVkPipelineCacheHeaderVersionOne = ^PVkPipelineCacheHeaderVersionOne;
VkPipelineCacheHeaderVersionOne = record
  headerSize: UInt32;
  headerVersion: VkPipelineCacheHeaderVersion;
  vendorID: UInt32;
  deviceID: UInt32;
  pipelineCacheUUID: array[0 .. VK_UUID_SIZE - 1] of UInt8;
end;


PVkPushConstantRange  =  ^VkPushConstantRange;
PPVkPushConstantRange = ^PVkPushConstantRange;
VkPushConstantRange = record
  stageFlags: VkShaderStageFlags;
  offset: UInt32;
  size: UInt32;
end;


PVkPipelineLayoutCreateInfo  =  ^VkPipelineLayoutCreateInfo;
PPVkPipelineLayoutCreateInfo = ^PVkPipelineLayoutCreateInfo;
VkPipelineLayoutCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineLayoutCreateFlags;
  setLayoutCount: UInt32;
  pSetLayouts: PVkDescriptorSetLayout;
  pushConstantRangeCount: UInt32;
  pPushConstantRanges: PVkPushConstantRange;
end;


PVkSamplerCreateInfo  =  ^VkSamplerCreateInfo;
PPVkSamplerCreateInfo = ^PVkSamplerCreateInfo;
VkSamplerCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkSamplerCreateFlags;
  magFilter: VkFilter;
  minFilter: VkFilter;
  mipmapMode: VkSamplerMipmapMode;
  addressModeU: VkSamplerAddressMode;
  addressModeV: VkSamplerAddressMode;
  addressModeW: VkSamplerAddressMode;
  mipLodBias: Single;
  anisotropyEnable: VkBool32;
  maxAnisotropy: Single;
  compareEnable: VkBool32;
  compareOp: VkCompareOp;
  minLod: Single;
  maxLod: Single;
  borderColor: VkBorderColor;
  unnormalizedCoordinates: VkBool32;
end;


PVkCommandPoolCreateInfo  =  ^VkCommandPoolCreateInfo;
PPVkCommandPoolCreateInfo = ^PVkCommandPoolCreateInfo;
VkCommandPoolCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkCommandPoolCreateFlags;
  queueFamilyIndex: UInt32;
end;


PVkCommandBufferAllocateInfo  =  ^VkCommandBufferAllocateInfo;
PPVkCommandBufferAllocateInfo = ^PVkCommandBufferAllocateInfo;
VkCommandBufferAllocateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  commandPool: VkCommandPool;
  level: VkCommandBufferLevel;
  commandBufferCount: UInt32;
end;


PVkCommandBufferInheritanceInfo  =  ^VkCommandBufferInheritanceInfo;
PPVkCommandBufferInheritanceInfo = ^PVkCommandBufferInheritanceInfo;
VkCommandBufferInheritanceInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  renderPass: VkRenderPass;
  subpass: UInt32;
  framebuffer: VkFramebuffer;
  occlusionQueryEnable: VkBool32;
  queryFlags: VkQueryControlFlags;
  pipelineStatistics: VkQueryPipelineStatisticFlags;
end;


PVkCommandBufferBeginInfo  =  ^VkCommandBufferBeginInfo;
PPVkCommandBufferBeginInfo = ^PVkCommandBufferBeginInfo;
VkCommandBufferBeginInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkCommandBufferUsageFlags;
  pInheritanceInfo: PVkCommandBufferInheritanceInfo;
end;


PVkClearValue = ^VkClearValue;
PVkRenderPassBeginInfo  =  ^VkRenderPassBeginInfo;
PPVkRenderPassBeginInfo = ^PVkRenderPassBeginInfo;
VkRenderPassBeginInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  renderPass: VkRenderPass;
  framebuffer: VkFramebuffer;
  renderArea: VkRect2D;
  clearValueCount: UInt32;
  pClearValues: PVkClearValue;
end;


PVkClearColorValue  =  ^VkClearColorValue;
PPVkClearColorValue = ^PVkClearColorValue;
VkClearColorValue = record
case Byte of
  0: (float32: array[0 .. 4 - 1] of Single);
  1: (int32: array[0 .. 4 - 1] of Int32);
  2: (uint32: array[0 .. 4 - 1] of UInt32);
end;


PVkClearDepthStencilValue  =  ^VkClearDepthStencilValue;
PPVkClearDepthStencilValue = ^PVkClearDepthStencilValue;
VkClearDepthStencilValue = record
  depth: Single;
  stencil: UInt32;
end;


PPVkClearValue = ^PVkClearValue;
VkClearValue = record
case Byte of
  0: (color: VkClearColorValue);
  1: (depthStencil: VkClearDepthStencilValue);
end;


PVkClearAttachment  =  ^VkClearAttachment;
PPVkClearAttachment = ^PVkClearAttachment;
VkClearAttachment = record
  aspectMask: VkImageAspectFlags;
  colorAttachment: UInt32;
  clearValue: VkClearValue;
end;


PVkAttachmentDescription  =  ^VkAttachmentDescription;
PPVkAttachmentDescription = ^PVkAttachmentDescription;
VkAttachmentDescription = record
  flags: VkAttachmentDescriptionFlags;
  format: VkFormat;
  samples: VkSampleCountFlagBits;
  loadOp: VkAttachmentLoadOp;
  storeOp: VkAttachmentStoreOp;
  stencilLoadOp: VkAttachmentLoadOp;
  stencilStoreOp: VkAttachmentStoreOp;
  initialLayout: VkImageLayout;
  finalLayout: VkImageLayout;
end;


PVkAttachmentReference  =  ^VkAttachmentReference;
PPVkAttachmentReference = ^PVkAttachmentReference;
VkAttachmentReference = record
  attachment: UInt32;
  layout: VkImageLayout;
end;


PVkSubpassDescription  =  ^VkSubpassDescription;
PPVkSubpassDescription = ^PVkSubpassDescription;
VkSubpassDescription = record
  flags: VkSubpassDescriptionFlags;
  pipelineBindPoint: VkPipelineBindPoint;
  inputAttachmentCount: UInt32;
  pInputAttachments: PVkAttachmentReference;
  colorAttachmentCount: UInt32;
  pColorAttachments: PVkAttachmentReference;
  pResolveAttachments: PVkAttachmentReference;
  pDepthStencilAttachment: PVkAttachmentReference;
  preserveAttachmentCount: UInt32;
  pPreserveAttachments: PUInt32;
end;


PVkSubpassDependency  =  ^VkSubpassDependency;
PPVkSubpassDependency = ^PVkSubpassDependency;
VkSubpassDependency = record
  srcSubpass: UInt32;
  dstSubpass: UInt32;
  srcStageMask: VkPipelineStageFlags;
  dstStageMask: VkPipelineStageFlags;
  srcAccessMask: VkAccessFlags;
  dstAccessMask: VkAccessFlags;
  dependencyFlags: VkDependencyFlags;
end;


PVkRenderPassCreateInfo  =  ^VkRenderPassCreateInfo;
PPVkRenderPassCreateInfo = ^PVkRenderPassCreateInfo;
VkRenderPassCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkRenderPassCreateFlags;
  attachmentCount: UInt32;
  pAttachments: PVkAttachmentDescription;
  subpassCount: UInt32;
  pSubpasses: PVkSubpassDescription;
  dependencyCount: UInt32;
  pDependencies: PVkSubpassDependency;
end;


PVkEventCreateInfo  =  ^VkEventCreateInfo;
PPVkEventCreateInfo = ^PVkEventCreateInfo;
VkEventCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkEventCreateFlags;
end;


PVkFenceCreateInfo  =  ^VkFenceCreateInfo;
PPVkFenceCreateInfo = ^PVkFenceCreateInfo;
VkFenceCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkFenceCreateFlags;
end;


PPVkPhysicalDeviceFeatures = ^PVkPhysicalDeviceFeatures;
VkPhysicalDeviceFeatures = record
  robustBufferAccess: VkBool32;
  fullDrawIndexUint32: VkBool32;
  imageCubeArray: VkBool32;
  independentBlend: VkBool32;
  geometryShader: VkBool32;
  tessellationShader: VkBool32;
  sampleRateShading: VkBool32;
  dualSrcBlend: VkBool32;
  logicOp: VkBool32;
  multiDrawIndirect: VkBool32;
  drawIndirectFirstInstance: VkBool32;
  depthClamp: VkBool32;
  depthBiasClamp: VkBool32;
  fillModeNonSolid: VkBool32;
  depthBounds: VkBool32;
  wideLines: VkBool32;
  largePoints: VkBool32;
  alphaToOne: VkBool32;
  multiViewport: VkBool32;
  samplerAnisotropy: VkBool32;
  textureCompressionETC2: VkBool32;
  textureCompressionASTC_LDR: VkBool32;
  textureCompressionBC: VkBool32;
  occlusionQueryPrecise: VkBool32;
  pipelineStatisticsQuery: VkBool32;
  vertexPipelineStoresAndAtomics: VkBool32;
  fragmentStoresAndAtomics: VkBool32;
  shaderTessellationAndGeometryPointSize: VkBool32;
  shaderImageGatherExtended: VkBool32;
  shaderStorageImageExtendedFormats: VkBool32;
  shaderStorageImageMultisample: VkBool32;
  shaderStorageImageReadWithoutFormat: VkBool32;
  shaderStorageImageWriteWithoutFormat: VkBool32;
  shaderUniformBufferArrayDynamicIndexing: VkBool32;
  shaderSampledImageArrayDynamicIndexing: VkBool32;
  shaderStorageBufferArrayDynamicIndexing: VkBool32;
  shaderStorageImageArrayDynamicIndexing: VkBool32;
  shaderClipDistance: VkBool32;
  shaderCullDistance: VkBool32;
  shaderFloat64: VkBool32;
  shaderInt64: VkBool32;
  shaderInt16: VkBool32;
  shaderResourceResidency: VkBool32;
  shaderResourceMinLod: VkBool32;
  sparseBinding: VkBool32;
  sparseResidencyBuffer: VkBool32;
  sparseResidencyImage2D: VkBool32;
  sparseResidencyImage3D: VkBool32;
  sparseResidency2Samples: VkBool32;
  sparseResidency4Samples: VkBool32;
  sparseResidency8Samples: VkBool32;
  sparseResidency16Samples: VkBool32;
  sparseResidencyAliased: VkBool32;
  variableMultisampleRate: VkBool32;
  inheritedQueries: VkBool32;
end;


PVkPhysicalDeviceSparseProperties  =  ^VkPhysicalDeviceSparseProperties;
PPVkPhysicalDeviceSparseProperties = ^PVkPhysicalDeviceSparseProperties;
VkPhysicalDeviceSparseProperties = record
  residencyStandard2DBlockShape: VkBool32;
  residencyStandard2DMultisampleBlockShape: VkBool32;
  residencyStandard3DBlockShape: VkBool32;
  residencyAlignedMipSize: VkBool32;
  residencyNonResidentStrict: VkBool32;
end;


PVkPhysicalDeviceLimits  =  ^VkPhysicalDeviceLimits;
PPVkPhysicalDeviceLimits = ^PVkPhysicalDeviceLimits;
VkPhysicalDeviceLimits = record
  maxImageDimension1D: UInt32;
  maxImageDimension2D: UInt32;
  maxImageDimension3D: UInt32;
  maxImageDimensionCube: UInt32;
  maxImageArrayLayers: UInt32;
  maxTexelBufferElements: UInt32;
  maxUniformBufferRange: UInt32;
  maxStorageBufferRange: UInt32;
  maxPushConstantsSize: UInt32;
  maxMemoryAllocationCount: UInt32;
  maxSamplerAllocationCount: UInt32;
  bufferImageGranularity: VkDeviceSize;
  sparseAddressSpaceSize: VkDeviceSize;
  maxBoundDescriptorSets: UInt32;
  maxPerStageDescriptorSamplers: UInt32;
  maxPerStageDescriptorUniformBuffers: UInt32;
  maxPerStageDescriptorStorageBuffers: UInt32;
  maxPerStageDescriptorSampledImages: UInt32;
  maxPerStageDescriptorStorageImages: UInt32;
  maxPerStageDescriptorInputAttachments: UInt32;
  maxPerStageResources: UInt32;
  maxDescriptorSetSamplers: UInt32;
  maxDescriptorSetUniformBuffers: UInt32;
  maxDescriptorSetUniformBuffersDynamic: UInt32;
  maxDescriptorSetStorageBuffers: UInt32;
  maxDescriptorSetStorageBuffersDynamic: UInt32;
  maxDescriptorSetSampledImages: UInt32;
  maxDescriptorSetStorageImages: UInt32;
  maxDescriptorSetInputAttachments: UInt32;
  maxVertexInputAttributes: UInt32;
  maxVertexInputBindings: UInt32;
  maxVertexInputAttributeOffset: UInt32;
  maxVertexInputBindingStride: UInt32;
  maxVertexOutputComponents: UInt32;
  maxTessellationGenerationLevel: UInt32;
  maxTessellationPatchSize: UInt32;
  maxTessellationControlPerVertexInputComponents: UInt32;
  maxTessellationControlPerVertexOutputComponents: UInt32;
  maxTessellationControlPerPatchOutputComponents: UInt32;
  maxTessellationControlTotalOutputComponents: UInt32;
  maxTessellationEvaluationInputComponents: UInt32;
  maxTessellationEvaluationOutputComponents: UInt32;
  maxGeometryShaderInvocations: UInt32;
  maxGeometryInputComponents: UInt32;
  maxGeometryOutputComponents: UInt32;
  maxGeometryOutputVertices: UInt32;
  maxGeometryTotalOutputComponents: UInt32;
  maxFragmentInputComponents: UInt32;
  maxFragmentOutputAttachments: UInt32;
  maxFragmentDualSrcAttachments: UInt32;
  maxFragmentCombinedOutputResources: UInt32;
  maxComputeSharedMemorySize: UInt32;
  maxComputeWorkGroupCount: array[0 .. 3 - 1] of UInt32;
  maxComputeWorkGroupInvocations: UInt32;
  maxComputeWorkGroupSize: array[0 .. 3 - 1] of UInt32;
  subPixelPrecisionBits: UInt32;
  subTexelPrecisionBits: UInt32;
  mipmapPrecisionBits: UInt32;
  maxDrawIndexedIndexValue: UInt32;
  maxDrawIndirectCount: UInt32;
  maxSamplerLodBias: Single;
  maxSamplerAnisotropy: Single;
  maxViewports: UInt32;
  maxViewportDimensions: array[0 .. 2 - 1] of UInt32;
  viewportBoundsRange: array[0 .. 2 - 1] of Single;
  viewportSubPixelBits: UInt32;
  minMemoryMapAlignment: SizeUInt;
  minTexelBufferOffsetAlignment: VkDeviceSize;
  minUniformBufferOffsetAlignment: VkDeviceSize;
  minStorageBufferOffsetAlignment: VkDeviceSize;
  minTexelOffset: Int32;
  maxTexelOffset: UInt32;
  minTexelGatherOffset: Int32;
  maxTexelGatherOffset: UInt32;
  minInterpolationOffset: Single;
  maxInterpolationOffset: Single;
  subPixelInterpolationOffsetBits: UInt32;
  maxFramebufferWidth: UInt32;
  maxFramebufferHeight: UInt32;
  maxFramebufferLayers: UInt32;
  framebufferColorSampleCounts: VkSampleCountFlags;
  framebufferDepthSampleCounts: VkSampleCountFlags;
  framebufferStencilSampleCounts: VkSampleCountFlags;
  framebufferNoAttachmentsSampleCounts: VkSampleCountFlags;
  maxColorAttachments: UInt32;
  sampledImageColorSampleCounts: VkSampleCountFlags;
  sampledImageIntegerSampleCounts: VkSampleCountFlags;
  sampledImageDepthSampleCounts: VkSampleCountFlags;
  sampledImageStencilSampleCounts: VkSampleCountFlags;
  storageImageSampleCounts: VkSampleCountFlags;
  maxSampleMaskWords: UInt32;
  timestampComputeAndGraphics: VkBool32;
  timestampPeriod: Single;
  maxClipDistances: UInt32;
  maxCullDistances: UInt32;
  maxCombinedClipAndCullDistances: UInt32;
  discreteQueuePriorities: UInt32;
  pointSizeRange: array[0 .. 2 - 1] of Single;
  lineWidthRange: array[0 .. 2 - 1] of Single;
  pointSizeGranularity: Single;
  lineWidthGranularity: Single;
  strictLines: VkBool32;
  standardSampleLocations: VkBool32;
  optimalBufferCopyOffsetAlignment: VkDeviceSize;
  optimalBufferCopyRowPitchAlignment: VkDeviceSize;
  nonCoherentAtomSize: VkDeviceSize;
end;


PVkSemaphoreCreateInfo  =  ^VkSemaphoreCreateInfo;
PPVkSemaphoreCreateInfo = ^PVkSemaphoreCreateInfo;
VkSemaphoreCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkSemaphoreCreateFlags;
end;


PVkQueryPoolCreateInfo  =  ^VkQueryPoolCreateInfo;
PPVkQueryPoolCreateInfo = ^PVkQueryPoolCreateInfo;
VkQueryPoolCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkQueryPoolCreateFlags;
  queryType: VkQueryType;
  queryCount: UInt32;
  pipelineStatistics: VkQueryPipelineStatisticFlags;
end;


PVkFramebufferCreateInfo  =  ^VkFramebufferCreateInfo;
PPVkFramebufferCreateInfo = ^PVkFramebufferCreateInfo;
VkFramebufferCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkFramebufferCreateFlags;
  renderPass: VkRenderPass;
  attachmentCount: UInt32;
  pAttachments: PVkImageView;
  width: UInt32;
  height: UInt32;
  layers: UInt32;
end;


PVkDrawIndirectCommand  =  ^VkDrawIndirectCommand;
PPVkDrawIndirectCommand = ^PVkDrawIndirectCommand;
VkDrawIndirectCommand = record
  vertexCount: UInt32;
  instanceCount: UInt32;
  firstVertex: UInt32;
  firstInstance: UInt32;
end;


PVkDrawIndexedIndirectCommand  =  ^VkDrawIndexedIndirectCommand;
PPVkDrawIndexedIndirectCommand = ^PVkDrawIndexedIndirectCommand;
VkDrawIndexedIndirectCommand = record
  indexCount: UInt32;
  instanceCount: UInt32;
  firstIndex: UInt32;
  vertexOffset: Int32;
  firstInstance: UInt32;
end;


PVkDispatchIndirectCommand  =  ^VkDispatchIndirectCommand;
PPVkDispatchIndirectCommand = ^PVkDispatchIndirectCommand;
VkDispatchIndirectCommand = record
  x: UInt32;
  y: UInt32;
  z: UInt32;
end;


PVkMultiDrawInfoEXT  =  ^VkMultiDrawInfoEXT;
PPVkMultiDrawInfoEXT = ^PVkMultiDrawInfoEXT;
VkMultiDrawInfoEXT = record
  firstVertex: UInt32;
  vertexCount: UInt32;
end;


PVkMultiDrawIndexedInfoEXT  =  ^VkMultiDrawIndexedInfoEXT;
PPVkMultiDrawIndexedInfoEXT = ^PVkMultiDrawIndexedInfoEXT;
VkMultiDrawIndexedInfoEXT = record
  firstIndex: UInt32;
  indexCount: UInt32;
  vertexOffset: Int32;
end;


PVkSubmitInfo  =  ^VkSubmitInfo;
PPVkSubmitInfo = ^PVkSubmitInfo;
VkSubmitInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  waitSemaphoreCount: UInt32;
  pWaitSemaphores: PVkSemaphore;
  pWaitDstStageMask: PVkPipelineStageFlags;
  commandBufferCount: UInt32;
  pCommandBuffers: PVkCommandBuffer;
  signalSemaphoreCount: UInt32;
  pSignalSemaphores: PVkSemaphore;
end;


PVkDisplayPropertiesKHR  =  ^VkDisplayPropertiesKHR;
PPVkDisplayPropertiesKHR = ^PVkDisplayPropertiesKHR;
VkDisplayPropertiesKHR = record
  display: VkDisplayKHR;
  displayName: PAnsiChar;
  physicalDimensions: VkExtent2D;
  physicalResolution: VkExtent2D;
  supportedTransforms: VkSurfaceTransformFlagsKHR;
  planeReorderPossible: VkBool32;
  persistentContent: VkBool32;
end;


PVkDisplayPlanePropertiesKHR  =  ^VkDisplayPlanePropertiesKHR;
PPVkDisplayPlanePropertiesKHR = ^PVkDisplayPlanePropertiesKHR;
VkDisplayPlanePropertiesKHR = record
  currentDisplay: VkDisplayKHR;
  currentStackIndex: UInt32;
end;


PVkDisplayModeParametersKHR  =  ^VkDisplayModeParametersKHR;
PPVkDisplayModeParametersKHR = ^PVkDisplayModeParametersKHR;
VkDisplayModeParametersKHR = record
  visibleRegion: VkExtent2D;
  refreshRate: UInt32;
end;


PVkDisplayModePropertiesKHR  =  ^VkDisplayModePropertiesKHR;
PPVkDisplayModePropertiesKHR = ^PVkDisplayModePropertiesKHR;
VkDisplayModePropertiesKHR = record
  displayMode: VkDisplayModeKHR;
  parameters: VkDisplayModeParametersKHR;
end;


PVkDisplayModeCreateInfoKHR  =  ^VkDisplayModeCreateInfoKHR;
PPVkDisplayModeCreateInfoKHR = ^PVkDisplayModeCreateInfoKHR;
VkDisplayModeCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkDisplayModeCreateFlagsKHR;
  parameters: VkDisplayModeParametersKHR;
end;


PVkDisplayPlaneCapabilitiesKHR  =  ^VkDisplayPlaneCapabilitiesKHR;
PPVkDisplayPlaneCapabilitiesKHR = ^PVkDisplayPlaneCapabilitiesKHR;
VkDisplayPlaneCapabilitiesKHR = record
  supportedAlpha: VkDisplayPlaneAlphaFlagsKHR;
  minSrcPosition: VkOffset2D;
  maxSrcPosition: VkOffset2D;
  minSrcExtent: VkExtent2D;
  maxSrcExtent: VkExtent2D;
  minDstPosition: VkOffset2D;
  maxDstPosition: VkOffset2D;
  minDstExtent: VkExtent2D;
  maxDstExtent: VkExtent2D;
end;


PVkDisplaySurfaceCreateInfoKHR  =  ^VkDisplaySurfaceCreateInfoKHR;
PPVkDisplaySurfaceCreateInfoKHR = ^PVkDisplaySurfaceCreateInfoKHR;
VkDisplaySurfaceCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkDisplaySurfaceCreateFlagsKHR;
  displayMode: VkDisplayModeKHR;
  planeIndex: UInt32;
  planeStackIndex: UInt32;
  transform: VkSurfaceTransformFlagBitsKHR;
  globalAlpha: Single;
  alphaMode: VkDisplayPlaneAlphaFlagBitsKHR;
  imageExtent: VkExtent2D;
end;


PVkDisplayPresentInfoKHR  =  ^VkDisplayPresentInfoKHR;
PPVkDisplayPresentInfoKHR = ^PVkDisplayPresentInfoKHR;
VkDisplayPresentInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  srcRect: VkRect2D;
  dstRect: VkRect2D;
  persistent: VkBool32;
end;


PVkSurfaceCapabilitiesKHR  =  ^VkSurfaceCapabilitiesKHR;
PPVkSurfaceCapabilitiesKHR = ^PVkSurfaceCapabilitiesKHR;
VkSurfaceCapabilitiesKHR = record
  minImageCount: UInt32;
  maxImageCount: UInt32;
  currentExtent: VkExtent2D;
  minImageExtent: VkExtent2D;
  maxImageExtent: VkExtent2D;
  maxImageArrayLayers: UInt32;
  supportedTransforms: VkSurfaceTransformFlagsKHR;
  currentTransform: VkSurfaceTransformFlagBitsKHR;
  supportedCompositeAlpha: VkCompositeAlphaFlagsKHR;
  supportedUsageFlags: VkImageUsageFlags;
end;


PVkAndroidSurfaceCreateInfoKHR  =  ^VkAndroidSurfaceCreateInfoKHR;
PPVkAndroidSurfaceCreateInfoKHR = ^PVkAndroidSurfaceCreateInfoKHR;
VkAndroidSurfaceCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkAndroidSurfaceCreateFlagsKHR;
  window: PANativeWindow;
end;


PVkViSurfaceCreateInfoNN  =  ^VkViSurfaceCreateInfoNN;
PPVkViSurfaceCreateInfoNN = ^PVkViSurfaceCreateInfoNN;
VkViSurfaceCreateInfoNN = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkViSurfaceCreateFlagsNN;
  window: Pointer;
end;


PVkWin32SurfaceCreateInfoKHR  =  ^VkWin32SurfaceCreateInfoKHR;
PPVkWin32SurfaceCreateInfoKHR = ^PVkWin32SurfaceCreateInfoKHR;
VkWin32SurfaceCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkWin32SurfaceCreateFlagsKHR;
  hinstance: HINSTANCE;
  hwnd: HWND;
end;


PVkSurfaceFormatKHR  =  ^VkSurfaceFormatKHR;
PPVkSurfaceFormatKHR = ^PVkSurfaceFormatKHR;
VkSurfaceFormatKHR = record
  format: VkFormat;
  colorSpace: VkColorSpaceKHR;
end;


PVkSwapchainCreateInfoKHR  =  ^VkSwapchainCreateInfoKHR;
PPVkSwapchainCreateInfoKHR = ^PVkSwapchainCreateInfoKHR;
VkSwapchainCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkSwapchainCreateFlagsKHR;
  surface: VkSurfaceKHR;
  minImageCount: UInt32;
  imageFormat: VkFormat;
  imageColorSpace: VkColorSpaceKHR;
  imageExtent: VkExtent2D;
  imageArrayLayers: UInt32;
  imageUsage: VkImageUsageFlags;
  imageSharingMode: VkSharingMode;
  queueFamilyIndexCount: UInt32;
  pQueueFamilyIndices: PUInt32;
  preTransform: VkSurfaceTransformFlagBitsKHR;
  compositeAlpha: VkCompositeAlphaFlagBitsKHR;
  presentMode: VkPresentModeKHR;
  clipped: VkBool32;
  oldSwapchain: VkSwapchainKHR;
end;


PVkPresentInfoKHR  =  ^VkPresentInfoKHR;
PPVkPresentInfoKHR = ^PVkPresentInfoKHR;
VkPresentInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  waitSemaphoreCount: UInt32;
  pWaitSemaphores: PVkSemaphore;
  swapchainCount: UInt32;
  pSwapchains: PVkSwapchainKHR;
  pImageIndices: PUInt32;
  pResults: PVkResult;
end;


PVkDebugReportCallbackCreateInfoEXT  =  ^VkDebugReportCallbackCreateInfoEXT;
PPVkDebugReportCallbackCreateInfoEXT = ^PVkDebugReportCallbackCreateInfoEXT;
VkDebugReportCallbackCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkDebugReportFlagsEXT;
  pfnCallback: PFN_vkDebugReportCallbackEXT;
  pUserData: Pointer;
end;


PVkValidationFlagsEXT  =  ^VkValidationFlagsEXT;
PPVkValidationFlagsEXT = ^PVkValidationFlagsEXT;
VkValidationFlagsEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  disabledValidationCheckCount: UInt32;
  pDisabledValidationChecks: PVkValidationCheckEXT;
end;


PVkValidationFeaturesEXT  =  ^VkValidationFeaturesEXT;
PPVkValidationFeaturesEXT = ^PVkValidationFeaturesEXT;
VkValidationFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  enabledValidationFeatureCount: UInt32;
  pEnabledValidationFeatures: PVkValidationFeatureEnableEXT;
  disabledValidationFeatureCount: UInt32;
  pDisabledValidationFeatures: PVkValidationFeatureDisableEXT;
end;


PVkPipelineRasterizationStateRasterizationOrderAMD  =  ^VkPipelineRasterizationStateRasterizationOrderAMD;
PPVkPipelineRasterizationStateRasterizationOrderAMD = ^PVkPipelineRasterizationStateRasterizationOrderAMD;
VkPipelineRasterizationStateRasterizationOrderAMD = record
  sType: VkStructureType;
  pNext: Pointer;
  rasterizationOrder: VkRasterizationOrderAMD;
end;


PVkDebugMarkerObjectNameInfoEXT  =  ^VkDebugMarkerObjectNameInfoEXT;
PPVkDebugMarkerObjectNameInfoEXT = ^PVkDebugMarkerObjectNameInfoEXT;
VkDebugMarkerObjectNameInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  objectType: VkDebugReportObjectTypeEXT;
  _object: UInt64;
  pObjectName: PAnsiChar;
end;


PVkDebugMarkerObjectTagInfoEXT  =  ^VkDebugMarkerObjectTagInfoEXT;
PPVkDebugMarkerObjectTagInfoEXT = ^PVkDebugMarkerObjectTagInfoEXT;
VkDebugMarkerObjectTagInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  objectType: VkDebugReportObjectTypeEXT;
  _object: UInt64;
  tagName: UInt64;
  tagSize: SizeUInt;
  pTag: Pointer;
end;


PVkDebugMarkerMarkerInfoEXT  =  ^VkDebugMarkerMarkerInfoEXT;
PPVkDebugMarkerMarkerInfoEXT = ^PVkDebugMarkerMarkerInfoEXT;
VkDebugMarkerMarkerInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  pMarkerName: PAnsiChar;
  color: array[0 .. 4 - 1] of Single;
end;


PVkDedicatedAllocationImageCreateInfoNV  =  ^VkDedicatedAllocationImageCreateInfoNV;
PPVkDedicatedAllocationImageCreateInfoNV = ^PVkDedicatedAllocationImageCreateInfoNV;
VkDedicatedAllocationImageCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  dedicatedAllocation: VkBool32;
end;


PVkDedicatedAllocationBufferCreateInfoNV  =  ^VkDedicatedAllocationBufferCreateInfoNV;
PPVkDedicatedAllocationBufferCreateInfoNV = ^PVkDedicatedAllocationBufferCreateInfoNV;
VkDedicatedAllocationBufferCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  dedicatedAllocation: VkBool32;
end;


PVkDedicatedAllocationMemoryAllocateInfoNV  =  ^VkDedicatedAllocationMemoryAllocateInfoNV;
PPVkDedicatedAllocationMemoryAllocateInfoNV = ^PVkDedicatedAllocationMemoryAllocateInfoNV;
VkDedicatedAllocationMemoryAllocateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  image: VkImage;
  buffer: VkBuffer;
end;


PVkExternalImageFormatPropertiesNV  =  ^VkExternalImageFormatPropertiesNV;
PPVkExternalImageFormatPropertiesNV = ^PVkExternalImageFormatPropertiesNV;
VkExternalImageFormatPropertiesNV = record
  imageFormatProperties: VkImageFormatProperties;
  externalMemoryFeatures: VkExternalMemoryFeatureFlagsNV;
  exportFromImportedHandleTypes: VkExternalMemoryHandleTypeFlagsNV;
  compatibleHandleTypes: VkExternalMemoryHandleTypeFlagsNV;
end;


PVkExternalMemoryImageCreateInfoNV  =  ^VkExternalMemoryImageCreateInfoNV;
PPVkExternalMemoryImageCreateInfoNV = ^PVkExternalMemoryImageCreateInfoNV;
VkExternalMemoryImageCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  handleTypes: VkExternalMemoryHandleTypeFlagsNV;
end;


PVkExportMemoryAllocateInfoNV  =  ^VkExportMemoryAllocateInfoNV;
PPVkExportMemoryAllocateInfoNV = ^PVkExportMemoryAllocateInfoNV;
VkExportMemoryAllocateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  handleTypes: VkExternalMemoryHandleTypeFlagsNV;
end;


PVkImportMemoryWin32HandleInfoNV  =  ^VkImportMemoryWin32HandleInfoNV;
PPVkImportMemoryWin32HandleInfoNV = ^PVkImportMemoryWin32HandleInfoNV;
VkImportMemoryWin32HandleInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  handleType: VkExternalMemoryHandleTypeFlagsNV;
  handle: HANDLE;
end;


PSECURITY_ATTRIBUTES = ^SECURITY_ATTRIBUTES;
PVkExportMemoryWin32HandleInfoNV  =  ^VkExportMemoryWin32HandleInfoNV;
PPVkExportMemoryWin32HandleInfoNV = ^PVkExportMemoryWin32HandleInfoNV;
VkExportMemoryWin32HandleInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  pAttributes: PSECURITY_ATTRIBUTES;
  dwAccess: DWORD;
end;


PVkWin32KeyedMutexAcquireReleaseInfoNV  =  ^VkWin32KeyedMutexAcquireReleaseInfoNV;
PPVkWin32KeyedMutexAcquireReleaseInfoNV = ^PVkWin32KeyedMutexAcquireReleaseInfoNV;
VkWin32KeyedMutexAcquireReleaseInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  acquireCount: UInt32;
  pAcquireSyncs: PVkDeviceMemory;
  pAcquireKeys: PUInt64;
  pAcquireTimeoutMilliseconds: PUInt32;
  releaseCount: UInt32;
  pReleaseSyncs: PVkDeviceMemory;
  pReleaseKeys: PUInt64;
end;


PVkPhysicalDeviceDeviceGeneratedCommandsFeaturesNV  =  ^VkPhysicalDeviceDeviceGeneratedCommandsFeaturesNV;
PPVkPhysicalDeviceDeviceGeneratedCommandsFeaturesNV = ^PVkPhysicalDeviceDeviceGeneratedCommandsFeaturesNV;
VkPhysicalDeviceDeviceGeneratedCommandsFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  deviceGeneratedCommands: VkBool32;
end;


PVkDevicePrivateDataCreateInfoEXT  =  ^VkDevicePrivateDataCreateInfoEXT;
PPVkDevicePrivateDataCreateInfoEXT = ^PVkDevicePrivateDataCreateInfoEXT;
VkDevicePrivateDataCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  privateDataSlotRequestCount: UInt32;
end;


PVkPrivateDataSlotCreateInfoEXT  =  ^VkPrivateDataSlotCreateInfoEXT;
PPVkPrivateDataSlotCreateInfoEXT = ^PVkPrivateDataSlotCreateInfoEXT;
VkPrivateDataSlotCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPrivateDataSlotCreateFlagsEXT;
end;


PVkPhysicalDevicePrivateDataFeaturesEXT  =  ^VkPhysicalDevicePrivateDataFeaturesEXT;
PPVkPhysicalDevicePrivateDataFeaturesEXT = ^PVkPhysicalDevicePrivateDataFeaturesEXT;
VkPhysicalDevicePrivateDataFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  privateData: VkBool32;
end;


PVkPhysicalDeviceDeviceGeneratedCommandsPropertiesNV  =  ^VkPhysicalDeviceDeviceGeneratedCommandsPropertiesNV;
PPVkPhysicalDeviceDeviceGeneratedCommandsPropertiesNV = ^PVkPhysicalDeviceDeviceGeneratedCommandsPropertiesNV;
VkPhysicalDeviceDeviceGeneratedCommandsPropertiesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  maxGraphicsShaderGroupCount: UInt32;
  maxIndirectSequenceCount: UInt32;
  maxIndirectCommandsTokenCount: UInt32;
  maxIndirectCommandsStreamCount: UInt32;
  maxIndirectCommandsTokenOffset: UInt32;
  maxIndirectCommandsStreamStride: UInt32;
  minSequencesCountBufferOffsetAlignment: UInt32;
  minSequencesIndexBufferOffsetAlignment: UInt32;
  minIndirectCommandsBufferOffsetAlignment: UInt32;
end;


PVkPhysicalDeviceMultiDrawPropertiesEXT  =  ^VkPhysicalDeviceMultiDrawPropertiesEXT;
PPVkPhysicalDeviceMultiDrawPropertiesEXT = ^PVkPhysicalDeviceMultiDrawPropertiesEXT;
VkPhysicalDeviceMultiDrawPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  maxMultiDrawCount: UInt32;
end;


PVkGraphicsShaderGroupCreateInfoNV  =  ^VkGraphicsShaderGroupCreateInfoNV;
PPVkGraphicsShaderGroupCreateInfoNV = ^PVkGraphicsShaderGroupCreateInfoNV;
VkGraphicsShaderGroupCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  stageCount: UInt32;
  pStages: PVkPipelineShaderStageCreateInfo;
  pVertexInputState: PVkPipelineVertexInputStateCreateInfo;
  pTessellationState: PVkPipelineTessellationStateCreateInfo;
end;


PVkGraphicsPipelineShaderGroupsCreateInfoNV  =  ^VkGraphicsPipelineShaderGroupsCreateInfoNV;
PPVkGraphicsPipelineShaderGroupsCreateInfoNV = ^PVkGraphicsPipelineShaderGroupsCreateInfoNV;
VkGraphicsPipelineShaderGroupsCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  groupCount: UInt32;
  pGroups: PVkGraphicsShaderGroupCreateInfoNV;
  pipelineCount: UInt32;
  pPipelines: PVkPipeline;
end;


PVkBindShaderGroupIndirectCommandNV  =  ^VkBindShaderGroupIndirectCommandNV;
PPVkBindShaderGroupIndirectCommandNV = ^PVkBindShaderGroupIndirectCommandNV;
VkBindShaderGroupIndirectCommandNV = record
  groupIndex: UInt32;
end;


PVkBindIndexBufferIndirectCommandNV  =  ^VkBindIndexBufferIndirectCommandNV;
PPVkBindIndexBufferIndirectCommandNV = ^PVkBindIndexBufferIndirectCommandNV;
VkBindIndexBufferIndirectCommandNV = record
  bufferAddress: VkDeviceAddress;
  size: UInt32;
  indexType: VkIndexType;
end;


PVkBindVertexBufferIndirectCommandNV  =  ^VkBindVertexBufferIndirectCommandNV;
PPVkBindVertexBufferIndirectCommandNV = ^PVkBindVertexBufferIndirectCommandNV;
VkBindVertexBufferIndirectCommandNV = record
  bufferAddress: VkDeviceAddress;
  size: UInt32;
  stride: UInt32;
end;


PVkSetStateFlagsIndirectCommandNV  =  ^VkSetStateFlagsIndirectCommandNV;
PPVkSetStateFlagsIndirectCommandNV = ^PVkSetStateFlagsIndirectCommandNV;
VkSetStateFlagsIndirectCommandNV = record
  data: UInt32;
end;


PVkIndirectCommandsStreamNV  =  ^VkIndirectCommandsStreamNV;
PPVkIndirectCommandsStreamNV = ^PVkIndirectCommandsStreamNV;
VkIndirectCommandsStreamNV = record
  buffer: VkBuffer;
  offset: VkDeviceSize;
end;


PVkIndirectCommandsLayoutTokenNV  =  ^VkIndirectCommandsLayoutTokenNV;
PPVkIndirectCommandsLayoutTokenNV = ^PVkIndirectCommandsLayoutTokenNV;
VkIndirectCommandsLayoutTokenNV = record
  sType: VkStructureType;
  pNext: Pointer;
  tokenType: VkIndirectCommandsTokenTypeNV;
  stream: UInt32;
  offset: UInt32;
  vertexBindingUnit: UInt32;
  vertexDynamicStride: VkBool32;
  pushconstantPipelineLayout: VkPipelineLayout;
  pushconstantShaderStageFlags: VkShaderStageFlags;
  pushconstantOffset: UInt32;
  pushconstantSize: UInt32;
  indirectStateFlags: VkIndirectStateFlagsNV;
  indexTypeCount: UInt32;
  pIndexTypes: PVkIndexType;
  pIndexTypeValues: PUInt32;
end;


PVkIndirectCommandsLayoutCreateInfoNV  =  ^VkIndirectCommandsLayoutCreateInfoNV;
PPVkIndirectCommandsLayoutCreateInfoNV = ^PVkIndirectCommandsLayoutCreateInfoNV;
VkIndirectCommandsLayoutCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkIndirectCommandsLayoutUsageFlagsNV;
  pipelineBindPoint: VkPipelineBindPoint;
  tokenCount: UInt32;
  pTokens: PVkIndirectCommandsLayoutTokenNV;
  streamCount: UInt32;
  pStreamStrides: PUInt32;
end;


PVkGeneratedCommandsInfoNV  =  ^VkGeneratedCommandsInfoNV;
PPVkGeneratedCommandsInfoNV = ^PVkGeneratedCommandsInfoNV;
VkGeneratedCommandsInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  pipelineBindPoint: VkPipelineBindPoint;
  pipeline: VkPipeline;
  indirectCommandsLayout: VkIndirectCommandsLayoutNV;
  streamCount: UInt32;
  pStreams: PVkIndirectCommandsStreamNV;
  sequencesCount: UInt32;
  preprocessBuffer: VkBuffer;
  preprocessOffset: VkDeviceSize;
  preprocessSize: VkDeviceSize;
  sequencesCountBuffer: VkBuffer;
  sequencesCountOffset: VkDeviceSize;
  sequencesIndexBuffer: VkBuffer;
  sequencesIndexOffset: VkDeviceSize;
end;


PVkGeneratedCommandsMemoryRequirementsInfoNV  =  ^VkGeneratedCommandsMemoryRequirementsInfoNV;
PPVkGeneratedCommandsMemoryRequirementsInfoNV = ^PVkGeneratedCommandsMemoryRequirementsInfoNV;
VkGeneratedCommandsMemoryRequirementsInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  pipelineBindPoint: VkPipelineBindPoint;
  pipeline: VkPipeline;
  indirectCommandsLayout: VkIndirectCommandsLayoutNV;
  maxSequencesCount: UInt32;
end;


PVkPhysicalDeviceFeatures2  =  ^VkPhysicalDeviceFeatures2;
PPVkPhysicalDeviceFeatures2 = ^PVkPhysicalDeviceFeatures2;
VkPhysicalDeviceFeatures2 = record
  sType: VkStructureType;
  pNext: Pointer;
  features: VkPhysicalDeviceFeatures;
end;


PVkPhysicalDeviceProperties  =  ^VkPhysicalDeviceProperties;
PPVkPhysicalDeviceProperties = ^PVkPhysicalDeviceProperties;
VkPhysicalDeviceProperties = record
  apiVersion: UInt32;
  driverVersion: UInt32;
  vendorID: UInt32;
  deviceID: UInt32;
  deviceType: VkPhysicalDeviceType;
  deviceName: array[0 .. VK_MAX_PHYSICAL_DEVICE_NAME_SIZE - 1] of AnsiChar;
  pipelineCacheUUID: array[0 .. VK_UUID_SIZE - 1] of UInt8;
  limits: VkPhysicalDeviceLimits;
  sparseProperties: VkPhysicalDeviceSparseProperties;
end;


PVkPhysicalDeviceProperties2  =  ^VkPhysicalDeviceProperties2;
PPVkPhysicalDeviceProperties2 = ^PVkPhysicalDeviceProperties2;
VkPhysicalDeviceProperties2 = record
  sType: VkStructureType;
  pNext: Pointer;
  properties: VkPhysicalDeviceProperties;
end;


PVkFormatProperties2  =  ^VkFormatProperties2;
PPVkFormatProperties2 = ^PVkFormatProperties2;
VkFormatProperties2 = record
  sType: VkStructureType;
  pNext: Pointer;
  formatProperties: VkFormatProperties;
end;


PVkImageFormatProperties2  =  ^VkImageFormatProperties2;
PPVkImageFormatProperties2 = ^PVkImageFormatProperties2;
VkImageFormatProperties2 = record
  sType: VkStructureType;
  pNext: Pointer;
  imageFormatProperties: VkImageFormatProperties;
end;


PVkPhysicalDeviceImageFormatInfo2  =  ^VkPhysicalDeviceImageFormatInfo2;
PPVkPhysicalDeviceImageFormatInfo2 = ^PVkPhysicalDeviceImageFormatInfo2;
VkPhysicalDeviceImageFormatInfo2 = record
  sType: VkStructureType;
  pNext: Pointer;
  format: VkFormat;
  _type: VkImageType;
  tiling: VkImageTiling;
  usage: VkImageUsageFlags;
  flags: VkImageCreateFlags;
end;


PVkQueueFamilyProperties2  =  ^VkQueueFamilyProperties2;
PPVkQueueFamilyProperties2 = ^PVkQueueFamilyProperties2;
VkQueueFamilyProperties2 = record
  sType: VkStructureType;
  pNext: Pointer;
  queueFamilyProperties: VkQueueFamilyProperties;
end;


PVkPhysicalDeviceMemoryProperties  =  ^VkPhysicalDeviceMemoryProperties;
PPVkPhysicalDeviceMemoryProperties = ^PVkPhysicalDeviceMemoryProperties;
VkPhysicalDeviceMemoryProperties = record
  memoryTypeCount: UInt32;
  memoryTypes: array[0 .. VK_MAX_MEMORY_TYPES - 1] of VkMemoryType;
  memoryHeapCount: UInt32;
  memoryHeaps: array[0 .. VK_MAX_MEMORY_HEAPS - 1] of VkMemoryHeap;
end;


PVkPhysicalDeviceMemoryProperties2  =  ^VkPhysicalDeviceMemoryProperties2;
PPVkPhysicalDeviceMemoryProperties2 = ^PVkPhysicalDeviceMemoryProperties2;
VkPhysicalDeviceMemoryProperties2 = record
  sType: VkStructureType;
  pNext: Pointer;
  memoryProperties: VkPhysicalDeviceMemoryProperties;
end;


PVkSparseImageFormatProperties2  =  ^VkSparseImageFormatProperties2;
PPVkSparseImageFormatProperties2 = ^PVkSparseImageFormatProperties2;
VkSparseImageFormatProperties2 = record
  sType: VkStructureType;
  pNext: Pointer;
  properties: VkSparseImageFormatProperties;
end;


PVkPhysicalDeviceSparseImageFormatInfo2  =  ^VkPhysicalDeviceSparseImageFormatInfo2;
PPVkPhysicalDeviceSparseImageFormatInfo2 = ^PVkPhysicalDeviceSparseImageFormatInfo2;
VkPhysicalDeviceSparseImageFormatInfo2 = record
  sType: VkStructureType;
  pNext: Pointer;
  format: VkFormat;
  _type: VkImageType;
  samples: VkSampleCountFlagBits;
  usage: VkImageUsageFlags;
  tiling: VkImageTiling;
end;


PVkPhysicalDevicePushDescriptorPropertiesKHR  =  ^VkPhysicalDevicePushDescriptorPropertiesKHR;
PPVkPhysicalDevicePushDescriptorPropertiesKHR = ^PVkPhysicalDevicePushDescriptorPropertiesKHR;
VkPhysicalDevicePushDescriptorPropertiesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  maxPushDescriptors: UInt32;
end;


PVkConformanceVersion  =  ^VkConformanceVersion;
PPVkConformanceVersion = ^PVkConformanceVersion;
VkConformanceVersion = record
  major: UInt8;
  minor: UInt8;
  subminor: UInt8;
  patch: UInt8;
end;


PVkPhysicalDeviceDriverProperties  =  ^VkPhysicalDeviceDriverProperties;
PPVkPhysicalDeviceDriverProperties = ^PVkPhysicalDeviceDriverProperties;
VkPhysicalDeviceDriverProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  driverID: VkDriverId;
  driverName: array[0 .. VK_MAX_DRIVER_NAME_SIZE - 1] of AnsiChar;
  driverInfo: array[0 .. VK_MAX_DRIVER_INFO_SIZE - 1] of AnsiChar;
  conformanceVersion: VkConformanceVersion;
end;


PVkPresentRegionKHR = ^VkPresentRegionKHR;
PVkPresentRegionsKHR  =  ^VkPresentRegionsKHR;
PPVkPresentRegionsKHR = ^PVkPresentRegionsKHR;
VkPresentRegionsKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  swapchainCount: UInt32;
  pRegions: PVkPresentRegionKHR;
end;


PVkRectLayerKHR = ^VkRectLayerKHR;
PPVkPresentRegionKHR = ^PVkPresentRegionKHR;
VkPresentRegionKHR = record
  rectangleCount: UInt32;
  pRectangles: PVkRectLayerKHR;
end;


PPVkRectLayerKHR = ^PVkRectLayerKHR;
VkRectLayerKHR = record
  offset: VkOffset2D;
  extent: VkExtent2D;
  layer: UInt32;
end;


PVkPhysicalDeviceVariablePointersFeatures  =  ^VkPhysicalDeviceVariablePointersFeatures;
PPVkPhysicalDeviceVariablePointersFeatures = ^PVkPhysicalDeviceVariablePointersFeatures;
VkPhysicalDeviceVariablePointersFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  variablePointersStorageBuffer: VkBool32;
  variablePointers: VkBool32;
end;


PVkExternalMemoryProperties  =  ^VkExternalMemoryProperties;
PPVkExternalMemoryProperties = ^PVkExternalMemoryProperties;
VkExternalMemoryProperties = record
  externalMemoryFeatures: VkExternalMemoryFeatureFlags;
  exportFromImportedHandleTypes: VkExternalMemoryHandleTypeFlags;
  compatibleHandleTypes: VkExternalMemoryHandleTypeFlags;
end;


PVkPhysicalDeviceExternalImageFormatInfo  =  ^VkPhysicalDeviceExternalImageFormatInfo;
PPVkPhysicalDeviceExternalImageFormatInfo = ^PVkPhysicalDeviceExternalImageFormatInfo;
VkPhysicalDeviceExternalImageFormatInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  handleType: VkExternalMemoryHandleTypeFlagBits;
end;


PVkExternalImageFormatProperties  =  ^VkExternalImageFormatProperties;
PPVkExternalImageFormatProperties = ^PVkExternalImageFormatProperties;
VkExternalImageFormatProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  externalMemoryProperties: VkExternalMemoryProperties;
end;


PVkPhysicalDeviceExternalBufferInfo  =  ^VkPhysicalDeviceExternalBufferInfo;
PPVkPhysicalDeviceExternalBufferInfo = ^PVkPhysicalDeviceExternalBufferInfo;
VkPhysicalDeviceExternalBufferInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkBufferCreateFlags;
  usage: VkBufferUsageFlags;
  handleType: VkExternalMemoryHandleTypeFlagBits;
end;


PVkExternalBufferProperties  =  ^VkExternalBufferProperties;
PPVkExternalBufferProperties = ^PVkExternalBufferProperties;
VkExternalBufferProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  externalMemoryProperties: VkExternalMemoryProperties;
end;


PVkPhysicalDeviceIDProperties  =  ^VkPhysicalDeviceIDProperties;
PPVkPhysicalDeviceIDProperties = ^PVkPhysicalDeviceIDProperties;
VkPhysicalDeviceIDProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  deviceUUID: array[0 .. VK_UUID_SIZE - 1] of UInt8;
  driverUUID: array[0 .. VK_UUID_SIZE - 1] of UInt8;
  deviceLUID: array[0 .. VK_LUID_SIZE - 1] of UInt8;
  deviceNodeMask: UInt32;
  deviceLUIDValid: VkBool32;
end;


PVkExternalMemoryImageCreateInfo  =  ^VkExternalMemoryImageCreateInfo;
PPVkExternalMemoryImageCreateInfo = ^PVkExternalMemoryImageCreateInfo;
VkExternalMemoryImageCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  handleTypes: VkExternalMemoryHandleTypeFlags;
end;


PVkExternalMemoryBufferCreateInfo  =  ^VkExternalMemoryBufferCreateInfo;
PPVkExternalMemoryBufferCreateInfo = ^PVkExternalMemoryBufferCreateInfo;
VkExternalMemoryBufferCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  handleTypes: VkExternalMemoryHandleTypeFlags;
end;


PVkExportMemoryAllocateInfo  =  ^VkExportMemoryAllocateInfo;
PPVkExportMemoryAllocateInfo = ^PVkExportMemoryAllocateInfo;
VkExportMemoryAllocateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  handleTypes: VkExternalMemoryHandleTypeFlags;
end;


PVkImportMemoryWin32HandleInfoKHR  =  ^VkImportMemoryWin32HandleInfoKHR;
PPVkImportMemoryWin32HandleInfoKHR = ^PVkImportMemoryWin32HandleInfoKHR;
VkImportMemoryWin32HandleInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  handleType: VkExternalMemoryHandleTypeFlagBits;
  handle: HANDLE;
  name: LPCWSTR;
end;


PVkExportMemoryWin32HandleInfoKHR  =  ^VkExportMemoryWin32HandleInfoKHR;
PPVkExportMemoryWin32HandleInfoKHR = ^PVkExportMemoryWin32HandleInfoKHR;
VkExportMemoryWin32HandleInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  pAttributes: PSECURITY_ATTRIBUTES;
  dwAccess: DWORD;
  name: LPCWSTR;
end;


PVkMemoryWin32HandlePropertiesKHR  =  ^VkMemoryWin32HandlePropertiesKHR;
PPVkMemoryWin32HandlePropertiesKHR = ^PVkMemoryWin32HandlePropertiesKHR;
VkMemoryWin32HandlePropertiesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  memoryTypeBits: UInt32;
end;


PVkMemoryGetWin32HandleInfoKHR  =  ^VkMemoryGetWin32HandleInfoKHR;
PPVkMemoryGetWin32HandleInfoKHR = ^PVkMemoryGetWin32HandleInfoKHR;
VkMemoryGetWin32HandleInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  memory: VkDeviceMemory;
  handleType: VkExternalMemoryHandleTypeFlagBits;
end;


PVkImportMemoryFdInfoKHR  =  ^VkImportMemoryFdInfoKHR;
PPVkImportMemoryFdInfoKHR = ^PVkImportMemoryFdInfoKHR;
VkImportMemoryFdInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  handleType: VkExternalMemoryHandleTypeFlagBits;
  fd: Int32;
end;


PVkMemoryFdPropertiesKHR  =  ^VkMemoryFdPropertiesKHR;
PPVkMemoryFdPropertiesKHR = ^PVkMemoryFdPropertiesKHR;
VkMemoryFdPropertiesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  memoryTypeBits: UInt32;
end;


PVkMemoryGetFdInfoKHR  =  ^VkMemoryGetFdInfoKHR;
PPVkMemoryGetFdInfoKHR = ^PVkMemoryGetFdInfoKHR;
VkMemoryGetFdInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  memory: VkDeviceMemory;
  handleType: VkExternalMemoryHandleTypeFlagBits;
end;


PVkWin32KeyedMutexAcquireReleaseInfoKHR  =  ^VkWin32KeyedMutexAcquireReleaseInfoKHR;
PPVkWin32KeyedMutexAcquireReleaseInfoKHR = ^PVkWin32KeyedMutexAcquireReleaseInfoKHR;
VkWin32KeyedMutexAcquireReleaseInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  acquireCount: UInt32;
  pAcquireSyncs: PVkDeviceMemory;
  pAcquireKeys: PUInt64;
  pAcquireTimeouts: PUInt32;
  releaseCount: UInt32;
  pReleaseSyncs: PVkDeviceMemory;
  pReleaseKeys: PUInt64;
end;


PVkPhysicalDeviceExternalSemaphoreInfo  =  ^VkPhysicalDeviceExternalSemaphoreInfo;
PPVkPhysicalDeviceExternalSemaphoreInfo = ^PVkPhysicalDeviceExternalSemaphoreInfo;
VkPhysicalDeviceExternalSemaphoreInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  handleType: VkExternalSemaphoreHandleTypeFlagBits;
end;


PVkExternalSemaphoreProperties  =  ^VkExternalSemaphoreProperties;
PPVkExternalSemaphoreProperties = ^PVkExternalSemaphoreProperties;
VkExternalSemaphoreProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  exportFromImportedHandleTypes: VkExternalSemaphoreHandleTypeFlags;
  compatibleHandleTypes: VkExternalSemaphoreHandleTypeFlags;
  externalSemaphoreFeatures: VkExternalSemaphoreFeatureFlags;
end;


PVkExportSemaphoreCreateInfo  =  ^VkExportSemaphoreCreateInfo;
PPVkExportSemaphoreCreateInfo = ^PVkExportSemaphoreCreateInfo;
VkExportSemaphoreCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  handleTypes: VkExternalSemaphoreHandleTypeFlags;
end;


PVkImportSemaphoreWin32HandleInfoKHR  =  ^VkImportSemaphoreWin32HandleInfoKHR;
PPVkImportSemaphoreWin32HandleInfoKHR = ^PVkImportSemaphoreWin32HandleInfoKHR;
VkImportSemaphoreWin32HandleInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  semaphore: VkSemaphore;
  flags: VkSemaphoreImportFlags;
  handleType: VkExternalSemaphoreHandleTypeFlagBits;
  handle: HANDLE;
  name: LPCWSTR;
end;


PVkExportSemaphoreWin32HandleInfoKHR  =  ^VkExportSemaphoreWin32HandleInfoKHR;
PPVkExportSemaphoreWin32HandleInfoKHR = ^PVkExportSemaphoreWin32HandleInfoKHR;
VkExportSemaphoreWin32HandleInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  pAttributes: PSECURITY_ATTRIBUTES;
  dwAccess: DWORD;
  name: LPCWSTR;
end;


PVkD3D12FenceSubmitInfoKHR  =  ^VkD3D12FenceSubmitInfoKHR;
PPVkD3D12FenceSubmitInfoKHR = ^PVkD3D12FenceSubmitInfoKHR;
VkD3D12FenceSubmitInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  waitSemaphoreValuesCount: UInt32;
  pWaitSemaphoreValues: PUInt64;
  signalSemaphoreValuesCount: UInt32;
  pSignalSemaphoreValues: PUInt64;
end;


PVkSemaphoreGetWin32HandleInfoKHR  =  ^VkSemaphoreGetWin32HandleInfoKHR;
PPVkSemaphoreGetWin32HandleInfoKHR = ^PVkSemaphoreGetWin32HandleInfoKHR;
VkSemaphoreGetWin32HandleInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  semaphore: VkSemaphore;
  handleType: VkExternalSemaphoreHandleTypeFlagBits;
end;


PVkImportSemaphoreFdInfoKHR  =  ^VkImportSemaphoreFdInfoKHR;
PPVkImportSemaphoreFdInfoKHR = ^PVkImportSemaphoreFdInfoKHR;
VkImportSemaphoreFdInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  semaphore: VkSemaphore;
  flags: VkSemaphoreImportFlags;
  handleType: VkExternalSemaphoreHandleTypeFlagBits;
  fd: Int32;
end;


PVkSemaphoreGetFdInfoKHR  =  ^VkSemaphoreGetFdInfoKHR;
PPVkSemaphoreGetFdInfoKHR = ^PVkSemaphoreGetFdInfoKHR;
VkSemaphoreGetFdInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  semaphore: VkSemaphore;
  handleType: VkExternalSemaphoreHandleTypeFlagBits;
end;


PVkPhysicalDeviceExternalFenceInfo  =  ^VkPhysicalDeviceExternalFenceInfo;
PPVkPhysicalDeviceExternalFenceInfo = ^PVkPhysicalDeviceExternalFenceInfo;
VkPhysicalDeviceExternalFenceInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  handleType: VkExternalFenceHandleTypeFlagBits;
end;


PVkExternalFenceProperties  =  ^VkExternalFenceProperties;
PPVkExternalFenceProperties = ^PVkExternalFenceProperties;
VkExternalFenceProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  exportFromImportedHandleTypes: VkExternalFenceHandleTypeFlags;
  compatibleHandleTypes: VkExternalFenceHandleTypeFlags;
  externalFenceFeatures: VkExternalFenceFeatureFlags;
end;


PVkExportFenceCreateInfo  =  ^VkExportFenceCreateInfo;
PPVkExportFenceCreateInfo = ^PVkExportFenceCreateInfo;
VkExportFenceCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  handleTypes: VkExternalFenceHandleTypeFlags;
end;


PVkImportFenceWin32HandleInfoKHR  =  ^VkImportFenceWin32HandleInfoKHR;
PPVkImportFenceWin32HandleInfoKHR = ^PVkImportFenceWin32HandleInfoKHR;
VkImportFenceWin32HandleInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  fence: VkFence;
  flags: VkFenceImportFlags;
  handleType: VkExternalFenceHandleTypeFlagBits;
  handle: HANDLE;
  name: LPCWSTR;
end;


PVkExportFenceWin32HandleInfoKHR  =  ^VkExportFenceWin32HandleInfoKHR;
PPVkExportFenceWin32HandleInfoKHR = ^PVkExportFenceWin32HandleInfoKHR;
VkExportFenceWin32HandleInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  pAttributes: PSECURITY_ATTRIBUTES;
  dwAccess: DWORD;
  name: LPCWSTR;
end;


PVkFenceGetWin32HandleInfoKHR  =  ^VkFenceGetWin32HandleInfoKHR;
PPVkFenceGetWin32HandleInfoKHR = ^PVkFenceGetWin32HandleInfoKHR;
VkFenceGetWin32HandleInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  fence: VkFence;
  handleType: VkExternalFenceHandleTypeFlagBits;
end;


PVkImportFenceFdInfoKHR  =  ^VkImportFenceFdInfoKHR;
PPVkImportFenceFdInfoKHR = ^PVkImportFenceFdInfoKHR;
VkImportFenceFdInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  fence: VkFence;
  flags: VkFenceImportFlags;
  handleType: VkExternalFenceHandleTypeFlagBits;
  fd: Int32;
end;


PVkFenceGetFdInfoKHR  =  ^VkFenceGetFdInfoKHR;
PPVkFenceGetFdInfoKHR = ^PVkFenceGetFdInfoKHR;
VkFenceGetFdInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  fence: VkFence;
  handleType: VkExternalFenceHandleTypeFlagBits;
end;


PVkPhysicalDeviceMultiviewFeatures  =  ^VkPhysicalDeviceMultiviewFeatures;
PPVkPhysicalDeviceMultiviewFeatures = ^PVkPhysicalDeviceMultiviewFeatures;
VkPhysicalDeviceMultiviewFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  multiview: VkBool32;
  multiviewGeometryShader: VkBool32;
  multiviewTessellationShader: VkBool32;
end;


PVkPhysicalDeviceMultiviewProperties  =  ^VkPhysicalDeviceMultiviewProperties;
PPVkPhysicalDeviceMultiviewProperties = ^PVkPhysicalDeviceMultiviewProperties;
VkPhysicalDeviceMultiviewProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  maxMultiviewViewCount: UInt32;
  maxMultiviewInstanceIndex: UInt32;
end;


PVkRenderPassMultiviewCreateInfo  =  ^VkRenderPassMultiviewCreateInfo;
PPVkRenderPassMultiviewCreateInfo = ^PVkRenderPassMultiviewCreateInfo;
VkRenderPassMultiviewCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  subpassCount: UInt32;
  pViewMasks: PUInt32;
  dependencyCount: UInt32;
  pViewOffsets: PInt32;
  correlationMaskCount: UInt32;
  pCorrelationMasks: PUInt32;
end;


PVkSurfaceCapabilities2EXT  =  ^VkSurfaceCapabilities2EXT;
PPVkSurfaceCapabilities2EXT = ^PVkSurfaceCapabilities2EXT;
VkSurfaceCapabilities2EXT = record
  sType: VkStructureType;
  pNext: Pointer;
  minImageCount: UInt32;
  maxImageCount: UInt32;
  currentExtent: VkExtent2D;
  minImageExtent: VkExtent2D;
  maxImageExtent: VkExtent2D;
  maxImageArrayLayers: UInt32;
  supportedTransforms: VkSurfaceTransformFlagsKHR;
  currentTransform: VkSurfaceTransformFlagBitsKHR;
  supportedCompositeAlpha: VkCompositeAlphaFlagsKHR;
  supportedUsageFlags: VkImageUsageFlags;
  supportedSurfaceCounters: VkSurfaceCounterFlagsEXT;
end;


PVkDisplayPowerInfoEXT  =  ^VkDisplayPowerInfoEXT;
PPVkDisplayPowerInfoEXT = ^PVkDisplayPowerInfoEXT;
VkDisplayPowerInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  powerState: VkDisplayPowerStateEXT;
end;


PVkDeviceEventInfoEXT  =  ^VkDeviceEventInfoEXT;
PPVkDeviceEventInfoEXT = ^PVkDeviceEventInfoEXT;
VkDeviceEventInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  deviceEvent: VkDeviceEventTypeEXT;
end;


PVkDisplayEventInfoEXT  =  ^VkDisplayEventInfoEXT;
PPVkDisplayEventInfoEXT = ^PVkDisplayEventInfoEXT;
VkDisplayEventInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  displayEvent: VkDisplayEventTypeEXT;
end;


PVkSwapchainCounterCreateInfoEXT  =  ^VkSwapchainCounterCreateInfoEXT;
PPVkSwapchainCounterCreateInfoEXT = ^PVkSwapchainCounterCreateInfoEXT;
VkSwapchainCounterCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  surfaceCounters: VkSurfaceCounterFlagsEXT;
end;


PVkPhysicalDeviceGroupProperties  =  ^VkPhysicalDeviceGroupProperties;
PPVkPhysicalDeviceGroupProperties = ^PVkPhysicalDeviceGroupProperties;
VkPhysicalDeviceGroupProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  physicalDeviceCount: UInt32;
  physicalDevices: array[0 .. VK_MAX_DEVICE_GROUP_SIZE - 1] of VkPhysicalDevice;
  subsetAllocation: VkBool32;
end;


PVkMemoryAllocateFlagsInfo  =  ^VkMemoryAllocateFlagsInfo;
PPVkMemoryAllocateFlagsInfo = ^PVkMemoryAllocateFlagsInfo;
VkMemoryAllocateFlagsInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkMemoryAllocateFlags;
  deviceMask: UInt32;
end;


PVkBindBufferMemoryInfo  =  ^VkBindBufferMemoryInfo;
PPVkBindBufferMemoryInfo = ^PVkBindBufferMemoryInfo;
VkBindBufferMemoryInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  buffer: VkBuffer;
  memory: VkDeviceMemory;
  memoryOffset: VkDeviceSize;
end;


PVkBindBufferMemoryDeviceGroupInfo  =  ^VkBindBufferMemoryDeviceGroupInfo;
PPVkBindBufferMemoryDeviceGroupInfo = ^PVkBindBufferMemoryDeviceGroupInfo;
VkBindBufferMemoryDeviceGroupInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  deviceIndexCount: UInt32;
  pDeviceIndices: PUInt32;
end;


PVkBindImageMemoryInfo  =  ^VkBindImageMemoryInfo;
PPVkBindImageMemoryInfo = ^PVkBindImageMemoryInfo;
VkBindImageMemoryInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  image: VkImage;
  memory: VkDeviceMemory;
  memoryOffset: VkDeviceSize;
end;


PVkBindImageMemoryDeviceGroupInfo  =  ^VkBindImageMemoryDeviceGroupInfo;
PPVkBindImageMemoryDeviceGroupInfo = ^PVkBindImageMemoryDeviceGroupInfo;
VkBindImageMemoryDeviceGroupInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  deviceIndexCount: UInt32;
  pDeviceIndices: PUInt32;
  splitInstanceBindRegionCount: UInt32;
  pSplitInstanceBindRegions: PVkRect2D;
end;


PVkDeviceGroupRenderPassBeginInfo  =  ^VkDeviceGroupRenderPassBeginInfo;
PPVkDeviceGroupRenderPassBeginInfo = ^PVkDeviceGroupRenderPassBeginInfo;
VkDeviceGroupRenderPassBeginInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  deviceMask: UInt32;
  deviceRenderAreaCount: UInt32;
  pDeviceRenderAreas: PVkRect2D;
end;


PVkDeviceGroupCommandBufferBeginInfo  =  ^VkDeviceGroupCommandBufferBeginInfo;
PPVkDeviceGroupCommandBufferBeginInfo = ^PVkDeviceGroupCommandBufferBeginInfo;
VkDeviceGroupCommandBufferBeginInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  deviceMask: UInt32;
end;


PVkDeviceGroupSubmitInfo  =  ^VkDeviceGroupSubmitInfo;
PPVkDeviceGroupSubmitInfo = ^PVkDeviceGroupSubmitInfo;
VkDeviceGroupSubmitInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  waitSemaphoreCount: UInt32;
  pWaitSemaphoreDeviceIndices: PUInt32;
  commandBufferCount: UInt32;
  pCommandBufferDeviceMasks: PUInt32;
  signalSemaphoreCount: UInt32;
  pSignalSemaphoreDeviceIndices: PUInt32;
end;


PVkDeviceGroupBindSparseInfo  =  ^VkDeviceGroupBindSparseInfo;
PPVkDeviceGroupBindSparseInfo = ^PVkDeviceGroupBindSparseInfo;
VkDeviceGroupBindSparseInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  resourceDeviceIndex: UInt32;
  memoryDeviceIndex: UInt32;
end;


PVkDeviceGroupPresentCapabilitiesKHR  =  ^VkDeviceGroupPresentCapabilitiesKHR;
PPVkDeviceGroupPresentCapabilitiesKHR = ^PVkDeviceGroupPresentCapabilitiesKHR;
VkDeviceGroupPresentCapabilitiesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  presentMask: array[0 .. VK_MAX_DEVICE_GROUP_SIZE - 1] of UInt32;
  modes: VkDeviceGroupPresentModeFlagsKHR;
end;


PVkImageSwapchainCreateInfoKHR  =  ^VkImageSwapchainCreateInfoKHR;
PPVkImageSwapchainCreateInfoKHR = ^PVkImageSwapchainCreateInfoKHR;
VkImageSwapchainCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  swapchain: VkSwapchainKHR;
end;


PVkBindImageMemorySwapchainInfoKHR  =  ^VkBindImageMemorySwapchainInfoKHR;
PPVkBindImageMemorySwapchainInfoKHR = ^PVkBindImageMemorySwapchainInfoKHR;
VkBindImageMemorySwapchainInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  swapchain: VkSwapchainKHR;
  imageIndex: UInt32;
end;


PVkAcquireNextImageInfoKHR  =  ^VkAcquireNextImageInfoKHR;
PPVkAcquireNextImageInfoKHR = ^PVkAcquireNextImageInfoKHR;
VkAcquireNextImageInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  swapchain: VkSwapchainKHR;
  timeout: UInt64;
  semaphore: VkSemaphore;
  fence: VkFence;
  deviceMask: UInt32;
end;


PVkDeviceGroupPresentInfoKHR  =  ^VkDeviceGroupPresentInfoKHR;
PPVkDeviceGroupPresentInfoKHR = ^PVkDeviceGroupPresentInfoKHR;
VkDeviceGroupPresentInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  swapchainCount: UInt32;
  pDeviceMasks: PUInt32;
  mode: VkDeviceGroupPresentModeFlagBitsKHR;
end;


PVkDeviceGroupDeviceCreateInfo  =  ^VkDeviceGroupDeviceCreateInfo;
PPVkDeviceGroupDeviceCreateInfo = ^PVkDeviceGroupDeviceCreateInfo;
VkDeviceGroupDeviceCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  physicalDeviceCount: UInt32;
  pPhysicalDevices: PVkPhysicalDevice;
end;


PVkDeviceGroupSwapchainCreateInfoKHR  =  ^VkDeviceGroupSwapchainCreateInfoKHR;
PPVkDeviceGroupSwapchainCreateInfoKHR = ^PVkDeviceGroupSwapchainCreateInfoKHR;
VkDeviceGroupSwapchainCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  modes: VkDeviceGroupPresentModeFlagsKHR;
end;


PVkDescriptorUpdateTemplateEntry  =  ^VkDescriptorUpdateTemplateEntry;
PPVkDescriptorUpdateTemplateEntry = ^PVkDescriptorUpdateTemplateEntry;
VkDescriptorUpdateTemplateEntry = record
  dstBinding: UInt32;
  dstArrayElement: UInt32;
  descriptorCount: UInt32;
  descriptorType: VkDescriptorType;
  offset: SizeUInt;
  stride: SizeUInt;
end;


PVkDescriptorUpdateTemplateCreateInfo  =  ^VkDescriptorUpdateTemplateCreateInfo;
PPVkDescriptorUpdateTemplateCreateInfo = ^PVkDescriptorUpdateTemplateCreateInfo;
VkDescriptorUpdateTemplateCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkDescriptorUpdateTemplateCreateFlags;
  descriptorUpdateEntryCount: UInt32;
  pDescriptorUpdateEntries: PVkDescriptorUpdateTemplateEntry;
  templateType: VkDescriptorUpdateTemplateType;
  descriptorSetLayout: VkDescriptorSetLayout;
  pipelineBindPoint: VkPipelineBindPoint;
  pipelineLayout: VkPipelineLayout;
  _set: UInt32;
end;


PVkXYColorEXT  =  ^VkXYColorEXT;
PPVkXYColorEXT = ^PVkXYColorEXT;
VkXYColorEXT = record
  x: Single;
  y: Single;
end;


PVkPhysicalDevicePresentIdFeaturesKHR  =  ^VkPhysicalDevicePresentIdFeaturesKHR;
PPVkPhysicalDevicePresentIdFeaturesKHR = ^PVkPhysicalDevicePresentIdFeaturesKHR;
VkPhysicalDevicePresentIdFeaturesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  presentId: VkBool32;
end;


PVkPresentIdKHR  =  ^VkPresentIdKHR;
PPVkPresentIdKHR = ^PVkPresentIdKHR;
VkPresentIdKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  swapchainCount: UInt32;
  pPresentIds: PUInt64;
end;


PVkPhysicalDevicePresentWaitFeaturesKHR  =  ^VkPhysicalDevicePresentWaitFeaturesKHR;
PPVkPhysicalDevicePresentWaitFeaturesKHR = ^PVkPhysicalDevicePresentWaitFeaturesKHR;
VkPhysicalDevicePresentWaitFeaturesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  presentWait: VkBool32;
end;


PVkHdrMetadataEXT  =  ^VkHdrMetadataEXT;
PPVkHdrMetadataEXT = ^PVkHdrMetadataEXT;
VkHdrMetadataEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  displayPrimaryRed: VkXYColorEXT;
  displayPrimaryGreen: VkXYColorEXT;
  displayPrimaryBlue: VkXYColorEXT;
  whitePoint: VkXYColorEXT;
  maxLuminance: Single;
  minLuminance: Single;
  maxContentLightLevel: Single;
  maxFrameAverageLightLevel: Single;
end;


PVkDisplayNativeHdrSurfaceCapabilitiesAMD  =  ^VkDisplayNativeHdrSurfaceCapabilitiesAMD;
PPVkDisplayNativeHdrSurfaceCapabilitiesAMD = ^PVkDisplayNativeHdrSurfaceCapabilitiesAMD;
VkDisplayNativeHdrSurfaceCapabilitiesAMD = record
  sType: VkStructureType;
  pNext: Pointer;
  localDimmingSupport: VkBool32;
end;


PVkSwapchainDisplayNativeHdrCreateInfoAMD  =  ^VkSwapchainDisplayNativeHdrCreateInfoAMD;
PPVkSwapchainDisplayNativeHdrCreateInfoAMD = ^PVkSwapchainDisplayNativeHdrCreateInfoAMD;
VkSwapchainDisplayNativeHdrCreateInfoAMD = record
  sType: VkStructureType;
  pNext: Pointer;
  localDimmingEnable: VkBool32;
end;


PVkRefreshCycleDurationGOOGLE  =  ^VkRefreshCycleDurationGOOGLE;
PPVkRefreshCycleDurationGOOGLE = ^PVkRefreshCycleDurationGOOGLE;
VkRefreshCycleDurationGOOGLE = record
  refreshDuration: UInt64;
end;


PVkPastPresentationTimingGOOGLE  =  ^VkPastPresentationTimingGOOGLE;
PPVkPastPresentationTimingGOOGLE = ^PVkPastPresentationTimingGOOGLE;
VkPastPresentationTimingGOOGLE = record
  presentID: UInt32;
  desiredPresentTime: UInt64;
  actualPresentTime: UInt64;
  earliestPresentTime: UInt64;
  presentMargin: UInt64;
end;


PVkPresentTimeGOOGLE = ^VkPresentTimeGOOGLE;
PVkPresentTimesInfoGOOGLE  =  ^VkPresentTimesInfoGOOGLE;
PPVkPresentTimesInfoGOOGLE = ^PVkPresentTimesInfoGOOGLE;
VkPresentTimesInfoGOOGLE = record
  sType: VkStructureType;
  pNext: Pointer;
  swapchainCount: UInt32;
  pTimes: PVkPresentTimeGOOGLE;
end;


PPVkPresentTimeGOOGLE = ^PVkPresentTimeGOOGLE;
VkPresentTimeGOOGLE = record
  presentID: UInt32;
  desiredPresentTime: UInt64;
end;


PVkIOSSurfaceCreateInfoMVK  =  ^VkIOSSurfaceCreateInfoMVK;
PPVkIOSSurfaceCreateInfoMVK = ^PVkIOSSurfaceCreateInfoMVK;
VkIOSSurfaceCreateInfoMVK = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkIOSSurfaceCreateFlagsMVK;
  pView: Pointer;
end;


PVkMacOSSurfaceCreateInfoMVK  =  ^VkMacOSSurfaceCreateInfoMVK;
PPVkMacOSSurfaceCreateInfoMVK = ^PVkMacOSSurfaceCreateInfoMVK;
VkMacOSSurfaceCreateInfoMVK = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkMacOSSurfaceCreateFlagsMVK;
  pView: Pointer;
end;


PVkMetalSurfaceCreateInfoEXT  =  ^VkMetalSurfaceCreateInfoEXT;
PPVkMetalSurfaceCreateInfoEXT = ^PVkMetalSurfaceCreateInfoEXT;
VkMetalSurfaceCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkMetalSurfaceCreateFlagsEXT;
  pLayer: PCAMetalLayer;
end;


PVkViewportWScalingNV  =  ^VkViewportWScalingNV;
PPVkViewportWScalingNV = ^PVkViewportWScalingNV;
VkViewportWScalingNV = record
  xcoeff: Single;
  ycoeff: Single;
end;


PVkPipelineViewportWScalingStateCreateInfoNV  =  ^VkPipelineViewportWScalingStateCreateInfoNV;
PPVkPipelineViewportWScalingStateCreateInfoNV = ^PVkPipelineViewportWScalingStateCreateInfoNV;
VkPipelineViewportWScalingStateCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  viewportWScalingEnable: VkBool32;
  viewportCount: UInt32;
  pViewportWScalings: PVkViewportWScalingNV;
end;


PVkViewportSwizzleNV  =  ^VkViewportSwizzleNV;
PPVkViewportSwizzleNV = ^PVkViewportSwizzleNV;
VkViewportSwizzleNV = record
  x: VkViewportCoordinateSwizzleNV;
  y: VkViewportCoordinateSwizzleNV;
  z: VkViewportCoordinateSwizzleNV;
  w: VkViewportCoordinateSwizzleNV;
end;


PVkPipelineViewportSwizzleStateCreateInfoNV  =  ^VkPipelineViewportSwizzleStateCreateInfoNV;
PPVkPipelineViewportSwizzleStateCreateInfoNV = ^PVkPipelineViewportSwizzleStateCreateInfoNV;
VkPipelineViewportSwizzleStateCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineViewportSwizzleStateCreateFlagsNV;
  viewportCount: UInt32;
  pViewportSwizzles: PVkViewportSwizzleNV;
end;


PVkPhysicalDeviceDiscardRectanglePropertiesEXT  =  ^VkPhysicalDeviceDiscardRectanglePropertiesEXT;
PPVkPhysicalDeviceDiscardRectanglePropertiesEXT = ^PVkPhysicalDeviceDiscardRectanglePropertiesEXT;
VkPhysicalDeviceDiscardRectanglePropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  maxDiscardRectangles: UInt32;
end;


PVkPipelineDiscardRectangleStateCreateInfoEXT  =  ^VkPipelineDiscardRectangleStateCreateInfoEXT;
PPVkPipelineDiscardRectangleStateCreateInfoEXT = ^PVkPipelineDiscardRectangleStateCreateInfoEXT;
VkPipelineDiscardRectangleStateCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineDiscardRectangleStateCreateFlagsEXT;
  discardRectangleMode: VkDiscardRectangleModeEXT;
  discardRectangleCount: UInt32;
  pDiscardRectangles: PVkRect2D;
end;


PVkPhysicalDeviceMultiviewPerViewAttributesPropertiesNVX  =  ^VkPhysicalDeviceMultiviewPerViewAttributesPropertiesNVX;
PPVkPhysicalDeviceMultiviewPerViewAttributesPropertiesNVX = ^PVkPhysicalDeviceMultiviewPerViewAttributesPropertiesNVX;
VkPhysicalDeviceMultiviewPerViewAttributesPropertiesNVX = record
  sType: VkStructureType;
  pNext: Pointer;
  perViewPositionAllComponents: VkBool32;
end;


PVkInputAttachmentAspectReference  =  ^VkInputAttachmentAspectReference;
PPVkInputAttachmentAspectReference = ^PVkInputAttachmentAspectReference;
VkInputAttachmentAspectReference = record
  subpass: UInt32;
  inputAttachmentIndex: UInt32;
  aspectMask: VkImageAspectFlags;
end;


PVkRenderPassInputAttachmentAspectCreateInfo  =  ^VkRenderPassInputAttachmentAspectCreateInfo;
PPVkRenderPassInputAttachmentAspectCreateInfo = ^PVkRenderPassInputAttachmentAspectCreateInfo;
VkRenderPassInputAttachmentAspectCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  aspectReferenceCount: UInt32;
  pAspectReferences: PVkInputAttachmentAspectReference;
end;


PVkPhysicalDeviceSurfaceInfo2KHR  =  ^VkPhysicalDeviceSurfaceInfo2KHR;
PPVkPhysicalDeviceSurfaceInfo2KHR = ^PVkPhysicalDeviceSurfaceInfo2KHR;
VkPhysicalDeviceSurfaceInfo2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  surface: VkSurfaceKHR;
end;


PVkSurfaceCapabilities2KHR  =  ^VkSurfaceCapabilities2KHR;
PPVkSurfaceCapabilities2KHR = ^PVkSurfaceCapabilities2KHR;
VkSurfaceCapabilities2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  surfaceCapabilities: VkSurfaceCapabilitiesKHR;
end;


PVkSurfaceFormat2KHR  =  ^VkSurfaceFormat2KHR;
PPVkSurfaceFormat2KHR = ^PVkSurfaceFormat2KHR;
VkSurfaceFormat2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  surfaceFormat: VkSurfaceFormatKHR;
end;


PVkDisplayProperties2KHR  =  ^VkDisplayProperties2KHR;
PPVkDisplayProperties2KHR = ^PVkDisplayProperties2KHR;
VkDisplayProperties2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  displayProperties: VkDisplayPropertiesKHR;
end;


PVkDisplayPlaneProperties2KHR  =  ^VkDisplayPlaneProperties2KHR;
PPVkDisplayPlaneProperties2KHR = ^PVkDisplayPlaneProperties2KHR;
VkDisplayPlaneProperties2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  displayPlaneProperties: VkDisplayPlanePropertiesKHR;
end;


PVkDisplayModeProperties2KHR  =  ^VkDisplayModeProperties2KHR;
PPVkDisplayModeProperties2KHR = ^PVkDisplayModeProperties2KHR;
VkDisplayModeProperties2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  displayModeProperties: VkDisplayModePropertiesKHR;
end;


PVkDisplayPlaneInfo2KHR  =  ^VkDisplayPlaneInfo2KHR;
PPVkDisplayPlaneInfo2KHR = ^PVkDisplayPlaneInfo2KHR;
VkDisplayPlaneInfo2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  mode: VkDisplayModeKHR;
  planeIndex: UInt32;
end;


PVkDisplayPlaneCapabilities2KHR  =  ^VkDisplayPlaneCapabilities2KHR;
PPVkDisplayPlaneCapabilities2KHR = ^PVkDisplayPlaneCapabilities2KHR;
VkDisplayPlaneCapabilities2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  capabilities: VkDisplayPlaneCapabilitiesKHR;
end;


PVkSharedPresentSurfaceCapabilitiesKHR  =  ^VkSharedPresentSurfaceCapabilitiesKHR;
PPVkSharedPresentSurfaceCapabilitiesKHR = ^PVkSharedPresentSurfaceCapabilitiesKHR;
VkSharedPresentSurfaceCapabilitiesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  sharedPresentSupportedUsageFlags: VkImageUsageFlags;
end;


PVkPhysicalDevice16BitStorageFeatures  =  ^VkPhysicalDevice16BitStorageFeatures;
PPVkPhysicalDevice16BitStorageFeatures = ^PVkPhysicalDevice16BitStorageFeatures;
VkPhysicalDevice16BitStorageFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  storageBuffer16BitAccess: VkBool32;
  uniformAndStorageBuffer16BitAccess: VkBool32;
  storagePushConstant16: VkBool32;
  storageInputOutput16: VkBool32;
end;


PVkPhysicalDeviceSubgroupProperties  =  ^VkPhysicalDeviceSubgroupProperties;
PPVkPhysicalDeviceSubgroupProperties = ^PVkPhysicalDeviceSubgroupProperties;
VkPhysicalDeviceSubgroupProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  subgroupSize: UInt32;
  supportedStages: VkShaderStageFlags;
  supportedOperations: VkSubgroupFeatureFlags;
  quadOperationsInAllStages: VkBool32;
end;


PVkPhysicalDeviceShaderSubgroupExtendedTypesFeatures  =  ^VkPhysicalDeviceShaderSubgroupExtendedTypesFeatures;
PPVkPhysicalDeviceShaderSubgroupExtendedTypesFeatures = ^PVkPhysicalDeviceShaderSubgroupExtendedTypesFeatures;
VkPhysicalDeviceShaderSubgroupExtendedTypesFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderSubgroupExtendedTypes: VkBool32;
end;


PVkBufferMemoryRequirementsInfo2  =  ^VkBufferMemoryRequirementsInfo2;
PPVkBufferMemoryRequirementsInfo2 = ^PVkBufferMemoryRequirementsInfo2;
VkBufferMemoryRequirementsInfo2 = record
  sType: VkStructureType;
  pNext: Pointer;
  buffer: VkBuffer;
end;


PVkImageMemoryRequirementsInfo2  =  ^VkImageMemoryRequirementsInfo2;
PPVkImageMemoryRequirementsInfo2 = ^PVkImageMemoryRequirementsInfo2;
VkImageMemoryRequirementsInfo2 = record
  sType: VkStructureType;
  pNext: Pointer;
  image: VkImage;
end;


PVkImageSparseMemoryRequirementsInfo2  =  ^VkImageSparseMemoryRequirementsInfo2;
PPVkImageSparseMemoryRequirementsInfo2 = ^PVkImageSparseMemoryRequirementsInfo2;
VkImageSparseMemoryRequirementsInfo2 = record
  sType: VkStructureType;
  pNext: Pointer;
  image: VkImage;
end;


PVkMemoryRequirements2  =  ^VkMemoryRequirements2;
PPVkMemoryRequirements2 = ^PVkMemoryRequirements2;
VkMemoryRequirements2 = record
  sType: VkStructureType;
  pNext: Pointer;
  memoryRequirements: VkMemoryRequirements;
end;


PVkSparseImageMemoryRequirements2  =  ^VkSparseImageMemoryRequirements2;
PPVkSparseImageMemoryRequirements2 = ^PVkSparseImageMemoryRequirements2;
VkSparseImageMemoryRequirements2 = record
  sType: VkStructureType;
  pNext: Pointer;
  memoryRequirements: VkSparseImageMemoryRequirements;
end;


PVkPhysicalDevicePointClippingProperties  =  ^VkPhysicalDevicePointClippingProperties;
PPVkPhysicalDevicePointClippingProperties = ^PVkPhysicalDevicePointClippingProperties;
VkPhysicalDevicePointClippingProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  pointClippingBehavior: VkPointClippingBehavior;
end;


PVkMemoryDedicatedRequirements  =  ^VkMemoryDedicatedRequirements;
PPVkMemoryDedicatedRequirements = ^PVkMemoryDedicatedRequirements;
VkMemoryDedicatedRequirements = record
  sType: VkStructureType;
  pNext: Pointer;
  prefersDedicatedAllocation: VkBool32;
  requiresDedicatedAllocation: VkBool32;
end;


PVkMemoryDedicatedAllocateInfo  =  ^VkMemoryDedicatedAllocateInfo;
PPVkMemoryDedicatedAllocateInfo = ^PVkMemoryDedicatedAllocateInfo;
VkMemoryDedicatedAllocateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  image: VkImage;
  buffer: VkBuffer;
end;


PVkImageViewUsageCreateInfo  =  ^VkImageViewUsageCreateInfo;
PPVkImageViewUsageCreateInfo = ^PVkImageViewUsageCreateInfo;
VkImageViewUsageCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  usage: VkImageUsageFlags;
end;


PVkPipelineTessellationDomainOriginStateCreateInfo  =  ^VkPipelineTessellationDomainOriginStateCreateInfo;
PPVkPipelineTessellationDomainOriginStateCreateInfo = ^PVkPipelineTessellationDomainOriginStateCreateInfo;
VkPipelineTessellationDomainOriginStateCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  domainOrigin: VkTessellationDomainOrigin;
end;


PVkSamplerYcbcrConversionInfo  =  ^VkSamplerYcbcrConversionInfo;
PPVkSamplerYcbcrConversionInfo = ^PVkSamplerYcbcrConversionInfo;
VkSamplerYcbcrConversionInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  conversion: VkSamplerYcbcrConversion;
end;


PVkSamplerYcbcrConversionCreateInfo  =  ^VkSamplerYcbcrConversionCreateInfo;
PPVkSamplerYcbcrConversionCreateInfo = ^PVkSamplerYcbcrConversionCreateInfo;
VkSamplerYcbcrConversionCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  format: VkFormat;
  ycbcrModel: VkSamplerYcbcrModelConversion;
  ycbcrRange: VkSamplerYcbcrRange;
  components: VkComponentMapping;
  xChromaOffset: VkChromaLocation;
  yChromaOffset: VkChromaLocation;
  chromaFilter: VkFilter;
  forceExplicitReconstruction: VkBool32;
end;


PVkBindImagePlaneMemoryInfo  =  ^VkBindImagePlaneMemoryInfo;
PPVkBindImagePlaneMemoryInfo = ^PVkBindImagePlaneMemoryInfo;
VkBindImagePlaneMemoryInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  planeAspect: VkImageAspectFlagBits;
end;


PVkImagePlaneMemoryRequirementsInfo  =  ^VkImagePlaneMemoryRequirementsInfo;
PPVkImagePlaneMemoryRequirementsInfo = ^PVkImagePlaneMemoryRequirementsInfo;
VkImagePlaneMemoryRequirementsInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  planeAspect: VkImageAspectFlagBits;
end;


PVkPhysicalDeviceSamplerYcbcrConversionFeatures  =  ^VkPhysicalDeviceSamplerYcbcrConversionFeatures;
PPVkPhysicalDeviceSamplerYcbcrConversionFeatures = ^PVkPhysicalDeviceSamplerYcbcrConversionFeatures;
VkPhysicalDeviceSamplerYcbcrConversionFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  samplerYcbcrConversion: VkBool32;
end;


PVkSamplerYcbcrConversionImageFormatProperties  =  ^VkSamplerYcbcrConversionImageFormatProperties;
PPVkSamplerYcbcrConversionImageFormatProperties = ^PVkSamplerYcbcrConversionImageFormatProperties;
VkSamplerYcbcrConversionImageFormatProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  combinedImageSamplerDescriptorCount: UInt32;
end;


PVkTextureLODGatherFormatPropertiesAMD  =  ^VkTextureLODGatherFormatPropertiesAMD;
PPVkTextureLODGatherFormatPropertiesAMD = ^PVkTextureLODGatherFormatPropertiesAMD;
VkTextureLODGatherFormatPropertiesAMD = record
  sType: VkStructureType;
  pNext: Pointer;
  supportsTextureGatherLODBiasAMD: VkBool32;
end;


PVkConditionalRenderingBeginInfoEXT  =  ^VkConditionalRenderingBeginInfoEXT;
PPVkConditionalRenderingBeginInfoEXT = ^PVkConditionalRenderingBeginInfoEXT;
VkConditionalRenderingBeginInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  buffer: VkBuffer;
  offset: VkDeviceSize;
  flags: VkConditionalRenderingFlagsEXT;
end;


PVkProtectedSubmitInfo  =  ^VkProtectedSubmitInfo;
PPVkProtectedSubmitInfo = ^PVkProtectedSubmitInfo;
VkProtectedSubmitInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  protectedSubmit: VkBool32;
end;


PVkPhysicalDeviceProtectedMemoryFeatures  =  ^VkPhysicalDeviceProtectedMemoryFeatures;
PPVkPhysicalDeviceProtectedMemoryFeatures = ^PVkPhysicalDeviceProtectedMemoryFeatures;
VkPhysicalDeviceProtectedMemoryFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  protectedMemory: VkBool32;
end;


PVkPhysicalDeviceProtectedMemoryProperties  =  ^VkPhysicalDeviceProtectedMemoryProperties;
PPVkPhysicalDeviceProtectedMemoryProperties = ^PVkPhysicalDeviceProtectedMemoryProperties;
VkPhysicalDeviceProtectedMemoryProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  protectedNoFault: VkBool32;
end;


PVkDeviceQueueInfo2  =  ^VkDeviceQueueInfo2;
PPVkDeviceQueueInfo2 = ^PVkDeviceQueueInfo2;
VkDeviceQueueInfo2 = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkDeviceQueueCreateFlags;
  queueFamilyIndex: UInt32;
  queueIndex: UInt32;
end;


PVkPipelineCoverageToColorStateCreateInfoNV  =  ^VkPipelineCoverageToColorStateCreateInfoNV;
PPVkPipelineCoverageToColorStateCreateInfoNV = ^PVkPipelineCoverageToColorStateCreateInfoNV;
VkPipelineCoverageToColorStateCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineCoverageToColorStateCreateFlagsNV;
  coverageToColorEnable: VkBool32;
  coverageToColorLocation: UInt32;
end;


PVkPhysicalDeviceSamplerFilterMinmaxProperties  =  ^VkPhysicalDeviceSamplerFilterMinmaxProperties;
PPVkPhysicalDeviceSamplerFilterMinmaxProperties = ^PVkPhysicalDeviceSamplerFilterMinmaxProperties;
VkPhysicalDeviceSamplerFilterMinmaxProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  filterMinmaxSingleComponentFormats: VkBool32;
  filterMinmaxImageComponentMapping: VkBool32;
end;


PVkSampleLocationEXT  =  ^VkSampleLocationEXT;
PPVkSampleLocationEXT = ^PVkSampleLocationEXT;
VkSampleLocationEXT = record
  x: Single;
  y: Single;
end;


PVkSampleLocationsInfoEXT  =  ^VkSampleLocationsInfoEXT;
PPVkSampleLocationsInfoEXT = ^PVkSampleLocationsInfoEXT;
VkSampleLocationsInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  sampleLocationsPerPixel: VkSampleCountFlagBits;
  sampleLocationGridSize: VkExtent2D;
  sampleLocationsCount: UInt32;
  pSampleLocations: PVkSampleLocationEXT;
end;


PVkAttachmentSampleLocationsEXT  =  ^VkAttachmentSampleLocationsEXT;
PPVkAttachmentSampleLocationsEXT = ^PVkAttachmentSampleLocationsEXT;
VkAttachmentSampleLocationsEXT = record
  attachmentIndex: UInt32;
  sampleLocationsInfo: VkSampleLocationsInfoEXT;
end;


PVkSubpassSampleLocationsEXT  =  ^VkSubpassSampleLocationsEXT;
PPVkSubpassSampleLocationsEXT = ^PVkSubpassSampleLocationsEXT;
VkSubpassSampleLocationsEXT = record
  subpassIndex: UInt32;
  sampleLocationsInfo: VkSampleLocationsInfoEXT;
end;


PVkRenderPassSampleLocationsBeginInfoEXT  =  ^VkRenderPassSampleLocationsBeginInfoEXT;
PPVkRenderPassSampleLocationsBeginInfoEXT = ^PVkRenderPassSampleLocationsBeginInfoEXT;
VkRenderPassSampleLocationsBeginInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  attachmentInitialSampleLocationsCount: UInt32;
  pAttachmentInitialSampleLocations: PVkAttachmentSampleLocationsEXT;
  postSubpassSampleLocationsCount: UInt32;
  pPostSubpassSampleLocations: PVkSubpassSampleLocationsEXT;
end;


PVkPipelineSampleLocationsStateCreateInfoEXT  =  ^VkPipelineSampleLocationsStateCreateInfoEXT;
PPVkPipelineSampleLocationsStateCreateInfoEXT = ^PVkPipelineSampleLocationsStateCreateInfoEXT;
VkPipelineSampleLocationsStateCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  sampleLocationsEnable: VkBool32;
  sampleLocationsInfo: VkSampleLocationsInfoEXT;
end;


PVkPhysicalDeviceSampleLocationsPropertiesEXT  =  ^VkPhysicalDeviceSampleLocationsPropertiesEXT;
PPVkPhysicalDeviceSampleLocationsPropertiesEXT = ^PVkPhysicalDeviceSampleLocationsPropertiesEXT;
VkPhysicalDeviceSampleLocationsPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  sampleLocationSampleCounts: VkSampleCountFlags;
  maxSampleLocationGridSize: VkExtent2D;
  sampleLocationCoordinateRange: array[0 .. 2 - 1] of Single;
  sampleLocationSubPixelBits: UInt32;
  variableSampleLocations: VkBool32;
end;


PVkMultisamplePropertiesEXT  =  ^VkMultisamplePropertiesEXT;
PPVkMultisamplePropertiesEXT = ^PVkMultisamplePropertiesEXT;
VkMultisamplePropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  maxSampleLocationGridSize: VkExtent2D;
end;


PVkSamplerReductionModeCreateInfo  =  ^VkSamplerReductionModeCreateInfo;
PPVkSamplerReductionModeCreateInfo = ^PVkSamplerReductionModeCreateInfo;
VkSamplerReductionModeCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  reductionMode: VkSamplerReductionMode;
end;


PVkPhysicalDeviceBlendOperationAdvancedFeaturesEXT  =  ^VkPhysicalDeviceBlendOperationAdvancedFeaturesEXT;
PPVkPhysicalDeviceBlendOperationAdvancedFeaturesEXT = ^PVkPhysicalDeviceBlendOperationAdvancedFeaturesEXT;
VkPhysicalDeviceBlendOperationAdvancedFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  advancedBlendCoherentOperations: VkBool32;
end;


PVkPhysicalDeviceMultiDrawFeaturesEXT  =  ^VkPhysicalDeviceMultiDrawFeaturesEXT;
PPVkPhysicalDeviceMultiDrawFeaturesEXT = ^PVkPhysicalDeviceMultiDrawFeaturesEXT;
VkPhysicalDeviceMultiDrawFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  multiDraw: VkBool32;
end;


PVkPhysicalDeviceBlendOperationAdvancedPropertiesEXT  =  ^VkPhysicalDeviceBlendOperationAdvancedPropertiesEXT;
PPVkPhysicalDeviceBlendOperationAdvancedPropertiesEXT = ^PVkPhysicalDeviceBlendOperationAdvancedPropertiesEXT;
VkPhysicalDeviceBlendOperationAdvancedPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  advancedBlendMaxColorAttachments: UInt32;
  advancedBlendIndependentBlend: VkBool32;
  advancedBlendNonPremultipliedSrcColor: VkBool32;
  advancedBlendNonPremultipliedDstColor: VkBool32;
  advancedBlendCorrelatedOverlap: VkBool32;
  advancedBlendAllOperations: VkBool32;
end;


PVkPipelineColorBlendAdvancedStateCreateInfoEXT  =  ^VkPipelineColorBlendAdvancedStateCreateInfoEXT;
PPVkPipelineColorBlendAdvancedStateCreateInfoEXT = ^PVkPipelineColorBlendAdvancedStateCreateInfoEXT;
VkPipelineColorBlendAdvancedStateCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  srcPremultiplied: VkBool32;
  dstPremultiplied: VkBool32;
  blendOverlap: VkBlendOverlapEXT;
end;


PVkPhysicalDeviceInlineUniformBlockFeaturesEXT  =  ^VkPhysicalDeviceInlineUniformBlockFeaturesEXT;
PPVkPhysicalDeviceInlineUniformBlockFeaturesEXT = ^PVkPhysicalDeviceInlineUniformBlockFeaturesEXT;
VkPhysicalDeviceInlineUniformBlockFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  inlineUniformBlock: VkBool32;
  descriptorBindingInlineUniformBlockUpdateAfterBind: VkBool32;
end;


PVkPhysicalDeviceInlineUniformBlockPropertiesEXT  =  ^VkPhysicalDeviceInlineUniformBlockPropertiesEXT;
PPVkPhysicalDeviceInlineUniformBlockPropertiesEXT = ^PVkPhysicalDeviceInlineUniformBlockPropertiesEXT;
VkPhysicalDeviceInlineUniformBlockPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  maxInlineUniformBlockSize: UInt32;
  maxPerStageDescriptorInlineUniformBlocks: UInt32;
  maxPerStageDescriptorUpdateAfterBindInlineUniformBlocks: UInt32;
  maxDescriptorSetInlineUniformBlocks: UInt32;
  maxDescriptorSetUpdateAfterBindInlineUniformBlocks: UInt32;
end;


PVkWriteDescriptorSetInlineUniformBlockEXT  =  ^VkWriteDescriptorSetInlineUniformBlockEXT;
PPVkWriteDescriptorSetInlineUniformBlockEXT = ^PVkWriteDescriptorSetInlineUniformBlockEXT;
VkWriteDescriptorSetInlineUniformBlockEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  dataSize: UInt32;
  pData: Pointer;
end;


PVkDescriptorPoolInlineUniformBlockCreateInfoEXT  =  ^VkDescriptorPoolInlineUniformBlockCreateInfoEXT;
PPVkDescriptorPoolInlineUniformBlockCreateInfoEXT = ^PVkDescriptorPoolInlineUniformBlockCreateInfoEXT;
VkDescriptorPoolInlineUniformBlockCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  maxInlineUniformBlockBindings: UInt32;
end;


PVkPipelineCoverageModulationStateCreateInfoNV  =  ^VkPipelineCoverageModulationStateCreateInfoNV;
PPVkPipelineCoverageModulationStateCreateInfoNV = ^PVkPipelineCoverageModulationStateCreateInfoNV;
VkPipelineCoverageModulationStateCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineCoverageModulationStateCreateFlagsNV;
  coverageModulationMode: VkCoverageModulationModeNV;
  coverageModulationTableEnable: VkBool32;
  coverageModulationTableCount: UInt32;
  pCoverageModulationTable: PSingle;
end;


PVkImageFormatListCreateInfo  =  ^VkImageFormatListCreateInfo;
PPVkImageFormatListCreateInfo = ^PVkImageFormatListCreateInfo;
VkImageFormatListCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  viewFormatCount: UInt32;
  pViewFormats: PVkFormat;
end;


PVkValidationCacheCreateInfoEXT  =  ^VkValidationCacheCreateInfoEXT;
PPVkValidationCacheCreateInfoEXT = ^PVkValidationCacheCreateInfoEXT;
VkValidationCacheCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkValidationCacheCreateFlagsEXT;
  initialDataSize: SizeUInt;
  pInitialData: Pointer;
end;


PVkShaderModuleValidationCacheCreateInfoEXT  =  ^VkShaderModuleValidationCacheCreateInfoEXT;
PPVkShaderModuleValidationCacheCreateInfoEXT = ^PVkShaderModuleValidationCacheCreateInfoEXT;
VkShaderModuleValidationCacheCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  validationCache: VkValidationCacheEXT;
end;


PVkPhysicalDeviceMaintenance3Properties  =  ^VkPhysicalDeviceMaintenance3Properties;
PPVkPhysicalDeviceMaintenance3Properties = ^PVkPhysicalDeviceMaintenance3Properties;
VkPhysicalDeviceMaintenance3Properties = record
  sType: VkStructureType;
  pNext: Pointer;
  maxPerSetDescriptors: UInt32;
  maxMemoryAllocationSize: VkDeviceSize;
end;


PVkDescriptorSetLayoutSupport  =  ^VkDescriptorSetLayoutSupport;
PPVkDescriptorSetLayoutSupport = ^PVkDescriptorSetLayoutSupport;
VkDescriptorSetLayoutSupport = record
  sType: VkStructureType;
  pNext: Pointer;
  supported: VkBool32;
end;


PVkPhysicalDeviceShaderDrawParametersFeatures  =  ^VkPhysicalDeviceShaderDrawParametersFeatures;
PPVkPhysicalDeviceShaderDrawParametersFeatures = ^PVkPhysicalDeviceShaderDrawParametersFeatures;
VkPhysicalDeviceShaderDrawParametersFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderDrawParameters: VkBool32;
end;


PVkPhysicalDeviceShaderFloat16Int8Features  =  ^VkPhysicalDeviceShaderFloat16Int8Features;
PPVkPhysicalDeviceShaderFloat16Int8Features = ^PVkPhysicalDeviceShaderFloat16Int8Features;
VkPhysicalDeviceShaderFloat16Int8Features = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderFloat16: VkBool32;
  shaderInt8: VkBool32;
end;


PVkPhysicalDeviceFloatControlsProperties  =  ^VkPhysicalDeviceFloatControlsProperties;
PPVkPhysicalDeviceFloatControlsProperties = ^PVkPhysicalDeviceFloatControlsProperties;
VkPhysicalDeviceFloatControlsProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  denormBehaviorIndependence: VkShaderFloatControlsIndependence;
  roundingModeIndependence: VkShaderFloatControlsIndependence;
  shaderSignedZeroInfNanPreserveFloat16: VkBool32;
  shaderSignedZeroInfNanPreserveFloat32: VkBool32;
  shaderSignedZeroInfNanPreserveFloat64: VkBool32;
  shaderDenormPreserveFloat16: VkBool32;
  shaderDenormPreserveFloat32: VkBool32;
  shaderDenormPreserveFloat64: VkBool32;
  shaderDenormFlushToZeroFloat16: VkBool32;
  shaderDenormFlushToZeroFloat32: VkBool32;
  shaderDenormFlushToZeroFloat64: VkBool32;
  shaderRoundingModeRTEFloat16: VkBool32;
  shaderRoundingModeRTEFloat32: VkBool32;
  shaderRoundingModeRTEFloat64: VkBool32;
  shaderRoundingModeRTZFloat16: VkBool32;
  shaderRoundingModeRTZFloat32: VkBool32;
  shaderRoundingModeRTZFloat64: VkBool32;
end;


PVkPhysicalDeviceHostQueryResetFeatures  =  ^VkPhysicalDeviceHostQueryResetFeatures;
PPVkPhysicalDeviceHostQueryResetFeatures = ^PVkPhysicalDeviceHostQueryResetFeatures;
VkPhysicalDeviceHostQueryResetFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  hostQueryReset: VkBool32;
end;


PVkNativeBufferUsage2ANDROID  =  ^VkNativeBufferUsage2ANDROID;
PPVkNativeBufferUsage2ANDROID = ^PVkNativeBufferUsage2ANDROID;
VkNativeBufferUsage2ANDROID = record
  consumer: UInt64;
  producer: UInt64;
end;


PVkNativeBufferANDROID  =  ^VkNativeBufferANDROID;
PPVkNativeBufferANDROID = ^PVkNativeBufferANDROID;
VkNativeBufferANDROID = record
  sType: VkStructureType;
  pNext: Pointer;
  handle: Pointer;
  stride: Int32;
  format: Int32;
  usage: Int32;
  usage2: VkNativeBufferUsage2ANDROID;
end;


PVkSwapchainImageCreateInfoANDROID  =  ^VkSwapchainImageCreateInfoANDROID;
PPVkSwapchainImageCreateInfoANDROID = ^PVkSwapchainImageCreateInfoANDROID;
VkSwapchainImageCreateInfoANDROID = record
  sType: VkStructureType;
  pNext: Pointer;
  usage: VkSwapchainImageUsageFlagsANDROID;
end;


PVkPhysicalDevicePresentationPropertiesANDROID  =  ^VkPhysicalDevicePresentationPropertiesANDROID;
PPVkPhysicalDevicePresentationPropertiesANDROID = ^PVkPhysicalDevicePresentationPropertiesANDROID;
VkPhysicalDevicePresentationPropertiesANDROID = record
  sType: VkStructureType;
  pNext: Pointer;
  sharedImage: VkBool32;
end;


PVkShaderResourceUsageAMD  =  ^VkShaderResourceUsageAMD;
PPVkShaderResourceUsageAMD = ^PVkShaderResourceUsageAMD;
VkShaderResourceUsageAMD = record
  numUsedVgprs: UInt32;
  numUsedSgprs: UInt32;
  ldsSizePerLocalWorkGroup: UInt32;
  ldsUsageSizeInBytes: SizeUInt;
  scratchMemUsageInBytes: SizeUInt;
end;


PVkShaderStatisticsInfoAMD  =  ^VkShaderStatisticsInfoAMD;
PPVkShaderStatisticsInfoAMD = ^PVkShaderStatisticsInfoAMD;
VkShaderStatisticsInfoAMD = record
  shaderStageMask: VkShaderStageFlags;
  resourceUsage: VkShaderResourceUsageAMD;
  numPhysicalVgprs: UInt32;
  numPhysicalSgprs: UInt32;
  numAvailableVgprs: UInt32;
  numAvailableSgprs: UInt32;
  computeWorkGroupSize: array[0 .. 3 - 1] of UInt32;
end;


PVkDeviceQueueGlobalPriorityCreateInfoEXT  =  ^VkDeviceQueueGlobalPriorityCreateInfoEXT;
PPVkDeviceQueueGlobalPriorityCreateInfoEXT = ^PVkDeviceQueueGlobalPriorityCreateInfoEXT;
VkDeviceQueueGlobalPriorityCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  globalPriority: VkQueueGlobalPriorityEXT;
end;


PVkPhysicalDeviceGlobalPriorityQueryFeaturesEXT  =  ^VkPhysicalDeviceGlobalPriorityQueryFeaturesEXT;
PPVkPhysicalDeviceGlobalPriorityQueryFeaturesEXT = ^PVkPhysicalDeviceGlobalPriorityQueryFeaturesEXT;
VkPhysicalDeviceGlobalPriorityQueryFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  globalPriorityQuery: VkBool32;
end;


PVkQueueFamilyGlobalPriorityPropertiesEXT  =  ^VkQueueFamilyGlobalPriorityPropertiesEXT;
PPVkQueueFamilyGlobalPriorityPropertiesEXT = ^PVkQueueFamilyGlobalPriorityPropertiesEXT;
VkQueueFamilyGlobalPriorityPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  priorityCount: UInt32;
  priorities: array[0 .. VK_MAX_GLOBAL_PRIORITY_SIZE_EXT - 1] of VkQueueGlobalPriorityEXT;
end;


PVkDebugUtilsObjectNameInfoEXT  =  ^VkDebugUtilsObjectNameInfoEXT;
PPVkDebugUtilsObjectNameInfoEXT = ^PVkDebugUtilsObjectNameInfoEXT;
VkDebugUtilsObjectNameInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  objectType: VkObjectType;
  objectHandle: UInt64;
  pObjectName: PAnsiChar;
end;


PVkDebugUtilsObjectTagInfoEXT  =  ^VkDebugUtilsObjectTagInfoEXT;
PPVkDebugUtilsObjectTagInfoEXT = ^PVkDebugUtilsObjectTagInfoEXT;
VkDebugUtilsObjectTagInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  objectType: VkObjectType;
  objectHandle: UInt64;
  tagName: UInt64;
  tagSize: SizeUInt;
  pTag: Pointer;
end;


PVkDebugUtilsLabelEXT  =  ^VkDebugUtilsLabelEXT;
PPVkDebugUtilsLabelEXT = ^PVkDebugUtilsLabelEXT;
VkDebugUtilsLabelEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  pLabelName: PAnsiChar;
  color: array[0 .. 4 - 1] of Single;
end;


PVkDebugUtilsMessengerCreateInfoEXT  =  ^VkDebugUtilsMessengerCreateInfoEXT;
PPVkDebugUtilsMessengerCreateInfoEXT = ^PVkDebugUtilsMessengerCreateInfoEXT;
VkDebugUtilsMessengerCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkDebugUtilsMessengerCreateFlagsEXT;
  messageSeverity: VkDebugUtilsMessageSeverityFlagsEXT;
  messageType: VkDebugUtilsMessageTypeFlagsEXT;
  pfnUserCallback: PFN_vkDebugUtilsMessengerCallbackEXT;
  pUserData: Pointer;
end;


PPVkDebugUtilsMessengerCallbackDataEXT = ^PVkDebugUtilsMessengerCallbackDataEXT;
VkDebugUtilsMessengerCallbackDataEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkDebugUtilsMessengerCallbackDataFlagsEXT;
  pMessageIdName: PAnsiChar;
  messageIdNumber: Int32;
  pMessage: PAnsiChar;
  queueLabelCount: UInt32;
  pQueueLabels: PVkDebugUtilsLabelEXT;
  cmdBufLabelCount: UInt32;
  pCmdBufLabels: PVkDebugUtilsLabelEXT;
  objectCount: UInt32;
  pObjects: PVkDebugUtilsObjectNameInfoEXT;
end;


PVkPhysicalDeviceDeviceMemoryReportFeaturesEXT  =  ^VkPhysicalDeviceDeviceMemoryReportFeaturesEXT;
PPVkPhysicalDeviceDeviceMemoryReportFeaturesEXT = ^PVkPhysicalDeviceDeviceMemoryReportFeaturesEXT;
VkPhysicalDeviceDeviceMemoryReportFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  deviceMemoryReport: VkBool32;
end;


PVkDeviceDeviceMemoryReportCreateInfoEXT  =  ^VkDeviceDeviceMemoryReportCreateInfoEXT;
PPVkDeviceDeviceMemoryReportCreateInfoEXT = ^PVkDeviceDeviceMemoryReportCreateInfoEXT;
VkDeviceDeviceMemoryReportCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkDeviceMemoryReportFlagsEXT;
  pfnUserCallback: PFN_vkDeviceMemoryReportCallbackEXT;
  pUserData: Pointer;
end;


PPVkDeviceMemoryReportCallbackDataEXT = ^PVkDeviceMemoryReportCallbackDataEXT;
VkDeviceMemoryReportCallbackDataEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkDeviceMemoryReportFlagsEXT;
  _type: VkDeviceMemoryReportEventTypeEXT;
  memoryObjectId: UInt64;
  size: VkDeviceSize;
  objectType: VkObjectType;
  objectHandle: UInt64;
  heapIndex: UInt32;
end;


PVkImportMemoryHostPointerInfoEXT  =  ^VkImportMemoryHostPointerInfoEXT;
PPVkImportMemoryHostPointerInfoEXT = ^PVkImportMemoryHostPointerInfoEXT;
VkImportMemoryHostPointerInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  handleType: VkExternalMemoryHandleTypeFlagBits;
  pHostPointer: Pointer;
end;


PVkMemoryHostPointerPropertiesEXT  =  ^VkMemoryHostPointerPropertiesEXT;
PPVkMemoryHostPointerPropertiesEXT = ^PVkMemoryHostPointerPropertiesEXT;
VkMemoryHostPointerPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  memoryTypeBits: UInt32;
end;


PVkPhysicalDeviceExternalMemoryHostPropertiesEXT  =  ^VkPhysicalDeviceExternalMemoryHostPropertiesEXT;
PPVkPhysicalDeviceExternalMemoryHostPropertiesEXT = ^PVkPhysicalDeviceExternalMemoryHostPropertiesEXT;
VkPhysicalDeviceExternalMemoryHostPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  minImportedHostPointerAlignment: VkDeviceSize;
end;


PVkPhysicalDeviceConservativeRasterizationPropertiesEXT  =  ^VkPhysicalDeviceConservativeRasterizationPropertiesEXT;
PPVkPhysicalDeviceConservativeRasterizationPropertiesEXT = ^PVkPhysicalDeviceConservativeRasterizationPropertiesEXT;
VkPhysicalDeviceConservativeRasterizationPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  primitiveOverestimationSize: Single;
  maxExtraPrimitiveOverestimationSize: Single;
  extraPrimitiveOverestimationSizeGranularity: Single;
  primitiveUnderestimation: VkBool32;
  conservativePointAndLineRasterization: VkBool32;
  degenerateTrianglesRasterized: VkBool32;
  degenerateLinesRasterized: VkBool32;
  fullyCoveredFragmentShaderInputVariable: VkBool32;
  conservativeRasterizationPostDepthCoverage: VkBool32;
end;


PVkCalibratedTimestampInfoEXT  =  ^VkCalibratedTimestampInfoEXT;
PPVkCalibratedTimestampInfoEXT = ^PVkCalibratedTimestampInfoEXT;
VkCalibratedTimestampInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  timeDomain: VkTimeDomainEXT;
end;


PVkPhysicalDeviceShaderCorePropertiesAMD  =  ^VkPhysicalDeviceShaderCorePropertiesAMD;
PPVkPhysicalDeviceShaderCorePropertiesAMD = ^PVkPhysicalDeviceShaderCorePropertiesAMD;
VkPhysicalDeviceShaderCorePropertiesAMD = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderEngineCount: UInt32;
  shaderArraysPerEngineCount: UInt32;
  computeUnitsPerShaderArray: UInt32;
  simdPerComputeUnit: UInt32;
  wavefrontsPerSimd: UInt32;
  wavefrontSize: UInt32;
  sgprsPerSimd: UInt32;
  minSgprAllocation: UInt32;
  maxSgprAllocation: UInt32;
  sgprAllocationGranularity: UInt32;
  vgprsPerSimd: UInt32;
  minVgprAllocation: UInt32;
  maxVgprAllocation: UInt32;
  vgprAllocationGranularity: UInt32;
end;


PVkPhysicalDeviceShaderCoreProperties2AMD  =  ^VkPhysicalDeviceShaderCoreProperties2AMD;
PPVkPhysicalDeviceShaderCoreProperties2AMD = ^PVkPhysicalDeviceShaderCoreProperties2AMD;
VkPhysicalDeviceShaderCoreProperties2AMD = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderCoreFeatures: VkShaderCorePropertiesFlagsAMD;
  activeComputeUnitCount: UInt32;
end;


PVkPipelineRasterizationConservativeStateCreateInfoEXT  =  ^VkPipelineRasterizationConservativeStateCreateInfoEXT;
PPVkPipelineRasterizationConservativeStateCreateInfoEXT = ^PVkPipelineRasterizationConservativeStateCreateInfoEXT;
VkPipelineRasterizationConservativeStateCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineRasterizationConservativeStateCreateFlagsEXT;
  conservativeRasterizationMode: VkConservativeRasterizationModeEXT;
  extraPrimitiveOverestimationSize: Single;
end;


PVkPhysicalDeviceDescriptorIndexingFeatures  =  ^VkPhysicalDeviceDescriptorIndexingFeatures;
PPVkPhysicalDeviceDescriptorIndexingFeatures = ^PVkPhysicalDeviceDescriptorIndexingFeatures;
VkPhysicalDeviceDescriptorIndexingFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderInputAttachmentArrayDynamicIndexing: VkBool32;
  shaderUniformTexelBufferArrayDynamicIndexing: VkBool32;
  shaderStorageTexelBufferArrayDynamicIndexing: VkBool32;
  shaderUniformBufferArrayNonUniformIndexing: VkBool32;
  shaderSampledImageArrayNonUniformIndexing: VkBool32;
  shaderStorageBufferArrayNonUniformIndexing: VkBool32;
  shaderStorageImageArrayNonUniformIndexing: VkBool32;
  shaderInputAttachmentArrayNonUniformIndexing: VkBool32;
  shaderUniformTexelBufferArrayNonUniformIndexing: VkBool32;
  shaderStorageTexelBufferArrayNonUniformIndexing: VkBool32;
  descriptorBindingUniformBufferUpdateAfterBind: VkBool32;
  descriptorBindingSampledImageUpdateAfterBind: VkBool32;
  descriptorBindingStorageImageUpdateAfterBind: VkBool32;
  descriptorBindingStorageBufferUpdateAfterBind: VkBool32;
  descriptorBindingUniformTexelBufferUpdateAfterBind: VkBool32;
  descriptorBindingStorageTexelBufferUpdateAfterBind: VkBool32;
  descriptorBindingUpdateUnusedWhilePending: VkBool32;
  descriptorBindingPartiallyBound: VkBool32;
  descriptorBindingVariableDescriptorCount: VkBool32;
  runtimeDescriptorArray: VkBool32;
end;


PVkPhysicalDeviceDescriptorIndexingProperties  =  ^VkPhysicalDeviceDescriptorIndexingProperties;
PPVkPhysicalDeviceDescriptorIndexingProperties = ^PVkPhysicalDeviceDescriptorIndexingProperties;
VkPhysicalDeviceDescriptorIndexingProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  maxUpdateAfterBindDescriptorsInAllPools: UInt32;
  shaderUniformBufferArrayNonUniformIndexingNative: VkBool32;
  shaderSampledImageArrayNonUniformIndexingNative: VkBool32;
  shaderStorageBufferArrayNonUniformIndexingNative: VkBool32;
  shaderStorageImageArrayNonUniformIndexingNative: VkBool32;
  shaderInputAttachmentArrayNonUniformIndexingNative: VkBool32;
  robustBufferAccessUpdateAfterBind: VkBool32;
  quadDivergentImplicitLod: VkBool32;
  maxPerStageDescriptorUpdateAfterBindSamplers: UInt32;
  maxPerStageDescriptorUpdateAfterBindUniformBuffers: UInt32;
  maxPerStageDescriptorUpdateAfterBindStorageBuffers: UInt32;
  maxPerStageDescriptorUpdateAfterBindSampledImages: UInt32;
  maxPerStageDescriptorUpdateAfterBindStorageImages: UInt32;
  maxPerStageDescriptorUpdateAfterBindInputAttachments: UInt32;
  maxPerStageUpdateAfterBindResources: UInt32;
  maxDescriptorSetUpdateAfterBindSamplers: UInt32;
  maxDescriptorSetUpdateAfterBindUniformBuffers: UInt32;
  maxDescriptorSetUpdateAfterBindUniformBuffersDynamic: UInt32;
  maxDescriptorSetUpdateAfterBindStorageBuffers: UInt32;
  maxDescriptorSetUpdateAfterBindStorageBuffersDynamic: UInt32;
  maxDescriptorSetUpdateAfterBindSampledImages: UInt32;
  maxDescriptorSetUpdateAfterBindStorageImages: UInt32;
  maxDescriptorSetUpdateAfterBindInputAttachments: UInt32;
end;


PVkDescriptorSetLayoutBindingFlagsCreateInfo  =  ^VkDescriptorSetLayoutBindingFlagsCreateInfo;
PPVkDescriptorSetLayoutBindingFlagsCreateInfo = ^PVkDescriptorSetLayoutBindingFlagsCreateInfo;
VkDescriptorSetLayoutBindingFlagsCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  bindingCount: UInt32;
  pBindingFlags: PVkDescriptorBindingFlags;
end;


PVkDescriptorSetVariableDescriptorCountAllocateInfo  =  ^VkDescriptorSetVariableDescriptorCountAllocateInfo;
PPVkDescriptorSetVariableDescriptorCountAllocateInfo = ^PVkDescriptorSetVariableDescriptorCountAllocateInfo;
VkDescriptorSetVariableDescriptorCountAllocateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  descriptorSetCount: UInt32;
  pDescriptorCounts: PUInt32;
end;


PVkDescriptorSetVariableDescriptorCountLayoutSupport  =  ^VkDescriptorSetVariableDescriptorCountLayoutSupport;
PPVkDescriptorSetVariableDescriptorCountLayoutSupport = ^PVkDescriptorSetVariableDescriptorCountLayoutSupport;
VkDescriptorSetVariableDescriptorCountLayoutSupport = record
  sType: VkStructureType;
  pNext: Pointer;
  maxVariableDescriptorCount: UInt32;
end;


PVkAttachmentDescription2  =  ^VkAttachmentDescription2;
PPVkAttachmentDescription2 = ^PVkAttachmentDescription2;
VkAttachmentDescription2 = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkAttachmentDescriptionFlags;
  format: VkFormat;
  samples: VkSampleCountFlagBits;
  loadOp: VkAttachmentLoadOp;
  storeOp: VkAttachmentStoreOp;
  stencilLoadOp: VkAttachmentLoadOp;
  stencilStoreOp: VkAttachmentStoreOp;
  initialLayout: VkImageLayout;
  finalLayout: VkImageLayout;
end;


PVkAttachmentReference2  =  ^VkAttachmentReference2;
PPVkAttachmentReference2 = ^PVkAttachmentReference2;
VkAttachmentReference2 = record
  sType: VkStructureType;
  pNext: Pointer;
  attachment: UInt32;
  layout: VkImageLayout;
  aspectMask: VkImageAspectFlags;
end;


PVkSubpassDescription2  =  ^VkSubpassDescription2;
PPVkSubpassDescription2 = ^PVkSubpassDescription2;
VkSubpassDescription2 = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkSubpassDescriptionFlags;
  pipelineBindPoint: VkPipelineBindPoint;
  viewMask: UInt32;
  inputAttachmentCount: UInt32;
  pInputAttachments: PVkAttachmentReference2;
  colorAttachmentCount: UInt32;
  pColorAttachments: PVkAttachmentReference2;
  pResolveAttachments: PVkAttachmentReference2;
  pDepthStencilAttachment: PVkAttachmentReference2;
  preserveAttachmentCount: UInt32;
  pPreserveAttachments: PUInt32;
end;


PVkSubpassDependency2  =  ^VkSubpassDependency2;
PPVkSubpassDependency2 = ^PVkSubpassDependency2;
VkSubpassDependency2 = record
  sType: VkStructureType;
  pNext: Pointer;
  srcSubpass: UInt32;
  dstSubpass: UInt32;
  srcStageMask: VkPipelineStageFlags;
  dstStageMask: VkPipelineStageFlags;
  srcAccessMask: VkAccessFlags;
  dstAccessMask: VkAccessFlags;
  dependencyFlags: VkDependencyFlags;
  viewOffset: Int32;
end;


PVkRenderPassCreateInfo2  =  ^VkRenderPassCreateInfo2;
PPVkRenderPassCreateInfo2 = ^PVkRenderPassCreateInfo2;
VkRenderPassCreateInfo2 = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkRenderPassCreateFlags;
  attachmentCount: UInt32;
  pAttachments: PVkAttachmentDescription2;
  subpassCount: UInt32;
  pSubpasses: PVkSubpassDescription2;
  dependencyCount: UInt32;
  pDependencies: PVkSubpassDependency2;
  correlatedViewMaskCount: UInt32;
  pCorrelatedViewMasks: PUInt32;
end;


PVkSubpassBeginInfo  =  ^VkSubpassBeginInfo;
PPVkSubpassBeginInfo = ^PVkSubpassBeginInfo;
VkSubpassBeginInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  contents: VkSubpassContents;
end;


PVkSubpassEndInfo  =  ^VkSubpassEndInfo;
PPVkSubpassEndInfo = ^PVkSubpassEndInfo;
VkSubpassEndInfo = record
  sType: VkStructureType;
  pNext: Pointer;
end;


PVkPhysicalDeviceTimelineSemaphoreFeatures  =  ^VkPhysicalDeviceTimelineSemaphoreFeatures;
PPVkPhysicalDeviceTimelineSemaphoreFeatures = ^PVkPhysicalDeviceTimelineSemaphoreFeatures;
VkPhysicalDeviceTimelineSemaphoreFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  timelineSemaphore: VkBool32;
end;


PVkPhysicalDeviceTimelineSemaphoreProperties  =  ^VkPhysicalDeviceTimelineSemaphoreProperties;
PPVkPhysicalDeviceTimelineSemaphoreProperties = ^PVkPhysicalDeviceTimelineSemaphoreProperties;
VkPhysicalDeviceTimelineSemaphoreProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  maxTimelineSemaphoreValueDifference: UInt64;
end;


PVkSemaphoreTypeCreateInfo  =  ^VkSemaphoreTypeCreateInfo;
PPVkSemaphoreTypeCreateInfo = ^PVkSemaphoreTypeCreateInfo;
VkSemaphoreTypeCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  semaphoreType: VkSemaphoreType;
  initialValue: UInt64;
end;


PVkTimelineSemaphoreSubmitInfo  =  ^VkTimelineSemaphoreSubmitInfo;
PPVkTimelineSemaphoreSubmitInfo = ^PVkTimelineSemaphoreSubmitInfo;
VkTimelineSemaphoreSubmitInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  waitSemaphoreValueCount: UInt32;
  pWaitSemaphoreValues: PUInt64;
  signalSemaphoreValueCount: UInt32;
  pSignalSemaphoreValues: PUInt64;
end;


PVkSemaphoreWaitInfo  =  ^VkSemaphoreWaitInfo;
PPVkSemaphoreWaitInfo = ^PVkSemaphoreWaitInfo;
VkSemaphoreWaitInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkSemaphoreWaitFlags;
  semaphoreCount: UInt32;
  pSemaphores: PVkSemaphore;
  pValues: PUInt64;
end;


PVkSemaphoreSignalInfo  =  ^VkSemaphoreSignalInfo;
PPVkSemaphoreSignalInfo = ^PVkSemaphoreSignalInfo;
VkSemaphoreSignalInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  semaphore: VkSemaphore;
  value: UInt64;
end;


PVkVertexInputBindingDivisorDescriptionEXT  =  ^VkVertexInputBindingDivisorDescriptionEXT;
PPVkVertexInputBindingDivisorDescriptionEXT = ^PVkVertexInputBindingDivisorDescriptionEXT;
VkVertexInputBindingDivisorDescriptionEXT = record
  binding: UInt32;
  divisor: UInt32;
end;


PVkPipelineVertexInputDivisorStateCreateInfoEXT  =  ^VkPipelineVertexInputDivisorStateCreateInfoEXT;
PPVkPipelineVertexInputDivisorStateCreateInfoEXT = ^PVkPipelineVertexInputDivisorStateCreateInfoEXT;
VkPipelineVertexInputDivisorStateCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  vertexBindingDivisorCount: UInt32;
  pVertexBindingDivisors: PVkVertexInputBindingDivisorDescriptionEXT;
end;


PVkPhysicalDeviceVertexAttributeDivisorPropertiesEXT  =  ^VkPhysicalDeviceVertexAttributeDivisorPropertiesEXT;
PPVkPhysicalDeviceVertexAttributeDivisorPropertiesEXT = ^PVkPhysicalDeviceVertexAttributeDivisorPropertiesEXT;
VkPhysicalDeviceVertexAttributeDivisorPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  maxVertexAttribDivisor: UInt32;
end;


PVkPhysicalDevicePCIBusInfoPropertiesEXT  =  ^VkPhysicalDevicePCIBusInfoPropertiesEXT;
PPVkPhysicalDevicePCIBusInfoPropertiesEXT = ^PVkPhysicalDevicePCIBusInfoPropertiesEXT;
VkPhysicalDevicePCIBusInfoPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  pciDomain: UInt32;
  pciBus: UInt32;
  pciDevice: UInt32;
  pciFunction: UInt32;
end;


PVkImportAndroidHardwareBufferInfoANDROID  =  ^VkImportAndroidHardwareBufferInfoANDROID;
PPVkImportAndroidHardwareBufferInfoANDROID = ^PVkImportAndroidHardwareBufferInfoANDROID;
VkImportAndroidHardwareBufferInfoANDROID = record
  sType: VkStructureType;
  pNext: Pointer;
  buffer: PAHardwareBuffer;
end;


PVkAndroidHardwareBufferUsageANDROID  =  ^VkAndroidHardwareBufferUsageANDROID;
PPVkAndroidHardwareBufferUsageANDROID = ^PVkAndroidHardwareBufferUsageANDROID;
VkAndroidHardwareBufferUsageANDROID = record
  sType: VkStructureType;
  pNext: Pointer;
  androidHardwareBufferUsage: UInt64;
end;


PVkAndroidHardwareBufferPropertiesANDROID  =  ^VkAndroidHardwareBufferPropertiesANDROID;
PPVkAndroidHardwareBufferPropertiesANDROID = ^PVkAndroidHardwareBufferPropertiesANDROID;
VkAndroidHardwareBufferPropertiesANDROID = record
  sType: VkStructureType;
  pNext: Pointer;
  allocationSize: VkDeviceSize;
  memoryTypeBits: UInt32;
end;


PVkMemoryGetAndroidHardwareBufferInfoANDROID  =  ^VkMemoryGetAndroidHardwareBufferInfoANDROID;
PPVkMemoryGetAndroidHardwareBufferInfoANDROID = ^PVkMemoryGetAndroidHardwareBufferInfoANDROID;
VkMemoryGetAndroidHardwareBufferInfoANDROID = record
  sType: VkStructureType;
  pNext: Pointer;
  memory: VkDeviceMemory;
end;


PVkAndroidHardwareBufferFormatPropertiesANDROID  =  ^VkAndroidHardwareBufferFormatPropertiesANDROID;
PPVkAndroidHardwareBufferFormatPropertiesANDROID = ^PVkAndroidHardwareBufferFormatPropertiesANDROID;
VkAndroidHardwareBufferFormatPropertiesANDROID = record
  sType: VkStructureType;
  pNext: Pointer;
  format: VkFormat;
  externalFormat: UInt64;
  formatFeatures: VkFormatFeatureFlags;
  samplerYcbcrConversionComponents: VkComponentMapping;
  suggestedYcbcrModel: VkSamplerYcbcrModelConversion;
  suggestedYcbcrRange: VkSamplerYcbcrRange;
  suggestedXChromaOffset: VkChromaLocation;
  suggestedYChromaOffset: VkChromaLocation;
end;


PVkCommandBufferInheritanceConditionalRenderingInfoEXT  =  ^VkCommandBufferInheritanceConditionalRenderingInfoEXT;
PPVkCommandBufferInheritanceConditionalRenderingInfoEXT = ^PVkCommandBufferInheritanceConditionalRenderingInfoEXT;
VkCommandBufferInheritanceConditionalRenderingInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  conditionalRenderingEnable: VkBool32;
end;


PVkExternalFormatANDROID  =  ^VkExternalFormatANDROID;
PPVkExternalFormatANDROID = ^PVkExternalFormatANDROID;
VkExternalFormatANDROID = record
  sType: VkStructureType;
  pNext: Pointer;
  externalFormat: UInt64;
end;


PVkPhysicalDevice8BitStorageFeatures  =  ^VkPhysicalDevice8BitStorageFeatures;
PPVkPhysicalDevice8BitStorageFeatures = ^PVkPhysicalDevice8BitStorageFeatures;
VkPhysicalDevice8BitStorageFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  storageBuffer8BitAccess: VkBool32;
  uniformAndStorageBuffer8BitAccess: VkBool32;
  storagePushConstant8: VkBool32;
end;


PVkPhysicalDeviceConditionalRenderingFeaturesEXT  =  ^VkPhysicalDeviceConditionalRenderingFeaturesEXT;
PPVkPhysicalDeviceConditionalRenderingFeaturesEXT = ^PVkPhysicalDeviceConditionalRenderingFeaturesEXT;
VkPhysicalDeviceConditionalRenderingFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  conditionalRendering: VkBool32;
  inheritedConditionalRendering: VkBool32;
end;


PVkPhysicalDeviceVulkanMemoryModelFeatures  =  ^VkPhysicalDeviceVulkanMemoryModelFeatures;
PPVkPhysicalDeviceVulkanMemoryModelFeatures = ^PVkPhysicalDeviceVulkanMemoryModelFeatures;
VkPhysicalDeviceVulkanMemoryModelFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  vulkanMemoryModel: VkBool32;
  vulkanMemoryModelDeviceScope: VkBool32;
  vulkanMemoryModelAvailabilityVisibilityChains: VkBool32;
end;


PVkPhysicalDeviceShaderAtomicInt64Features  =  ^VkPhysicalDeviceShaderAtomicInt64Features;
PPVkPhysicalDeviceShaderAtomicInt64Features = ^PVkPhysicalDeviceShaderAtomicInt64Features;
VkPhysicalDeviceShaderAtomicInt64Features = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderBufferInt64Atomics: VkBool32;
  shaderSharedInt64Atomics: VkBool32;
end;


PVkPhysicalDeviceShaderAtomicFloatFeaturesEXT  =  ^VkPhysicalDeviceShaderAtomicFloatFeaturesEXT;
PPVkPhysicalDeviceShaderAtomicFloatFeaturesEXT = ^PVkPhysicalDeviceShaderAtomicFloatFeaturesEXT;
VkPhysicalDeviceShaderAtomicFloatFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderBufferFloat32Atomics: VkBool32;
  shaderBufferFloat32AtomicAdd: VkBool32;
  shaderBufferFloat64Atomics: VkBool32;
  shaderBufferFloat64AtomicAdd: VkBool32;
  shaderSharedFloat32Atomics: VkBool32;
  shaderSharedFloat32AtomicAdd: VkBool32;
  shaderSharedFloat64Atomics: VkBool32;
  shaderSharedFloat64AtomicAdd: VkBool32;
  shaderImageFloat32Atomics: VkBool32;
  shaderImageFloat32AtomicAdd: VkBool32;
  sparseImageFloat32Atomics: VkBool32;
  sparseImageFloat32AtomicAdd: VkBool32;
end;


PVkPhysicalDeviceShaderAtomicFloat2FeaturesEXT  =  ^VkPhysicalDeviceShaderAtomicFloat2FeaturesEXT;
PPVkPhysicalDeviceShaderAtomicFloat2FeaturesEXT = ^PVkPhysicalDeviceShaderAtomicFloat2FeaturesEXT;
VkPhysicalDeviceShaderAtomicFloat2FeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderBufferFloat16Atomics: VkBool32;
  shaderBufferFloat16AtomicAdd: VkBool32;
  shaderBufferFloat16AtomicMinMax: VkBool32;
  shaderBufferFloat32AtomicMinMax: VkBool32;
  shaderBufferFloat64AtomicMinMax: VkBool32;
  shaderSharedFloat16Atomics: VkBool32;
  shaderSharedFloat16AtomicAdd: VkBool32;
  shaderSharedFloat16AtomicMinMax: VkBool32;
  shaderSharedFloat32AtomicMinMax: VkBool32;
  shaderSharedFloat64AtomicMinMax: VkBool32;
  shaderImageFloat32AtomicMinMax: VkBool32;
  sparseImageFloat32AtomicMinMax: VkBool32;
end;


PVkPhysicalDeviceVertexAttributeDivisorFeaturesEXT  =  ^VkPhysicalDeviceVertexAttributeDivisorFeaturesEXT;
PPVkPhysicalDeviceVertexAttributeDivisorFeaturesEXT = ^PVkPhysicalDeviceVertexAttributeDivisorFeaturesEXT;
VkPhysicalDeviceVertexAttributeDivisorFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  vertexAttributeInstanceRateDivisor: VkBool32;
  vertexAttributeInstanceRateZeroDivisor: VkBool32;
end;


PVkQueueFamilyCheckpointPropertiesNV  =  ^VkQueueFamilyCheckpointPropertiesNV;
PPVkQueueFamilyCheckpointPropertiesNV = ^PVkQueueFamilyCheckpointPropertiesNV;
VkQueueFamilyCheckpointPropertiesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  checkpointExecutionStageMask: VkPipelineStageFlags;
end;


PVkCheckpointDataNV  =  ^VkCheckpointDataNV;
PPVkCheckpointDataNV = ^PVkCheckpointDataNV;
VkCheckpointDataNV = record
  sType: VkStructureType;
  pNext: Pointer;
  stage: VkPipelineStageFlagBits;
  pCheckpointMarker: Pointer;
end;


PVkPhysicalDeviceDepthStencilResolveProperties  =  ^VkPhysicalDeviceDepthStencilResolveProperties;
PPVkPhysicalDeviceDepthStencilResolveProperties = ^PVkPhysicalDeviceDepthStencilResolveProperties;
VkPhysicalDeviceDepthStencilResolveProperties = record
  sType: VkStructureType;
  pNext: Pointer;
  supportedDepthResolveModes: VkResolveModeFlags;
  supportedStencilResolveModes: VkResolveModeFlags;
  independentResolveNone: VkBool32;
  independentResolve: VkBool32;
end;


PVkSubpassDescriptionDepthStencilResolve  =  ^VkSubpassDescriptionDepthStencilResolve;
PPVkSubpassDescriptionDepthStencilResolve = ^PVkSubpassDescriptionDepthStencilResolve;
VkSubpassDescriptionDepthStencilResolve = record
  sType: VkStructureType;
  pNext: Pointer;
  depthResolveMode: VkResolveModeFlagBits;
  stencilResolveMode: VkResolveModeFlagBits;
  pDepthStencilResolveAttachment: PVkAttachmentReference2;
end;


PVkImageViewASTCDecodeModeEXT  =  ^VkImageViewASTCDecodeModeEXT;
PPVkImageViewASTCDecodeModeEXT = ^PVkImageViewASTCDecodeModeEXT;
VkImageViewASTCDecodeModeEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  decodeMode: VkFormat;
end;


PVkPhysicalDeviceASTCDecodeFeaturesEXT  =  ^VkPhysicalDeviceASTCDecodeFeaturesEXT;
PPVkPhysicalDeviceASTCDecodeFeaturesEXT = ^PVkPhysicalDeviceASTCDecodeFeaturesEXT;
VkPhysicalDeviceASTCDecodeFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  decodeModeSharedExponent: VkBool32;
end;


PVkPhysicalDeviceTransformFeedbackFeaturesEXT  =  ^VkPhysicalDeviceTransformFeedbackFeaturesEXT;
PPVkPhysicalDeviceTransformFeedbackFeaturesEXT = ^PVkPhysicalDeviceTransformFeedbackFeaturesEXT;
VkPhysicalDeviceTransformFeedbackFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  transformFeedback: VkBool32;
  geometryStreams: VkBool32;
end;


PVkPhysicalDeviceTransformFeedbackPropertiesEXT  =  ^VkPhysicalDeviceTransformFeedbackPropertiesEXT;
PPVkPhysicalDeviceTransformFeedbackPropertiesEXT = ^PVkPhysicalDeviceTransformFeedbackPropertiesEXT;
VkPhysicalDeviceTransformFeedbackPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  maxTransformFeedbackStreams: UInt32;
  maxTransformFeedbackBuffers: UInt32;
  maxTransformFeedbackBufferSize: VkDeviceSize;
  maxTransformFeedbackStreamDataSize: UInt32;
  maxTransformFeedbackBufferDataSize: UInt32;
  maxTransformFeedbackBufferDataStride: UInt32;
  transformFeedbackQueries: VkBool32;
  transformFeedbackStreamsLinesTriangles: VkBool32;
  transformFeedbackRasterizationStreamSelect: VkBool32;
  transformFeedbackDraw: VkBool32;
end;


PVkPipelineRasterizationStateStreamCreateInfoEXT  =  ^VkPipelineRasterizationStateStreamCreateInfoEXT;
PPVkPipelineRasterizationStateStreamCreateInfoEXT = ^PVkPipelineRasterizationStateStreamCreateInfoEXT;
VkPipelineRasterizationStateStreamCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineRasterizationStateStreamCreateFlagsEXT;
  rasterizationStream: UInt32;
end;


PVkPhysicalDeviceRepresentativeFragmentTestFeaturesNV  =  ^VkPhysicalDeviceRepresentativeFragmentTestFeaturesNV;
PPVkPhysicalDeviceRepresentativeFragmentTestFeaturesNV = ^PVkPhysicalDeviceRepresentativeFragmentTestFeaturesNV;
VkPhysicalDeviceRepresentativeFragmentTestFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  representativeFragmentTest: VkBool32;
end;


PVkPipelineRepresentativeFragmentTestStateCreateInfoNV  =  ^VkPipelineRepresentativeFragmentTestStateCreateInfoNV;
PPVkPipelineRepresentativeFragmentTestStateCreateInfoNV = ^PVkPipelineRepresentativeFragmentTestStateCreateInfoNV;
VkPipelineRepresentativeFragmentTestStateCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  representativeFragmentTestEnable: VkBool32;
end;


PVkPhysicalDeviceExclusiveScissorFeaturesNV  =  ^VkPhysicalDeviceExclusiveScissorFeaturesNV;
PPVkPhysicalDeviceExclusiveScissorFeaturesNV = ^PVkPhysicalDeviceExclusiveScissorFeaturesNV;
VkPhysicalDeviceExclusiveScissorFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  exclusiveScissor: VkBool32;
end;


PVkPipelineViewportExclusiveScissorStateCreateInfoNV  =  ^VkPipelineViewportExclusiveScissorStateCreateInfoNV;
PPVkPipelineViewportExclusiveScissorStateCreateInfoNV = ^PVkPipelineViewportExclusiveScissorStateCreateInfoNV;
VkPipelineViewportExclusiveScissorStateCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  exclusiveScissorCount: UInt32;
  pExclusiveScissors: PVkRect2D;
end;


PVkPhysicalDeviceCornerSampledImageFeaturesNV  =  ^VkPhysicalDeviceCornerSampledImageFeaturesNV;
PPVkPhysicalDeviceCornerSampledImageFeaturesNV = ^PVkPhysicalDeviceCornerSampledImageFeaturesNV;
VkPhysicalDeviceCornerSampledImageFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  cornerSampledImage: VkBool32;
end;


PVkPhysicalDeviceComputeShaderDerivativesFeaturesNV  =  ^VkPhysicalDeviceComputeShaderDerivativesFeaturesNV;
PPVkPhysicalDeviceComputeShaderDerivativesFeaturesNV = ^PVkPhysicalDeviceComputeShaderDerivativesFeaturesNV;
VkPhysicalDeviceComputeShaderDerivativesFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  computeDerivativeGroupQuads: VkBool32;
  computeDerivativeGroupLinear: VkBool32;
end;


PVkPhysicalDeviceFragmentShaderBarycentricFeaturesNV  =  ^VkPhysicalDeviceFragmentShaderBarycentricFeaturesNV;
PPVkPhysicalDeviceFragmentShaderBarycentricFeaturesNV = ^PVkPhysicalDeviceFragmentShaderBarycentricFeaturesNV;
VkPhysicalDeviceFragmentShaderBarycentricFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  fragmentShaderBarycentric: VkBool32;
end;


PVkPhysicalDeviceShaderImageFootprintFeaturesNV  =  ^VkPhysicalDeviceShaderImageFootprintFeaturesNV;
PPVkPhysicalDeviceShaderImageFootprintFeaturesNV = ^PVkPhysicalDeviceShaderImageFootprintFeaturesNV;
VkPhysicalDeviceShaderImageFootprintFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  imageFootprint: VkBool32;
end;


PVkPhysicalDeviceDedicatedAllocationImageAliasingFeaturesNV  =  ^VkPhysicalDeviceDedicatedAllocationImageAliasingFeaturesNV;
PPVkPhysicalDeviceDedicatedAllocationImageAliasingFeaturesNV = ^PVkPhysicalDeviceDedicatedAllocationImageAliasingFeaturesNV;
VkPhysicalDeviceDedicatedAllocationImageAliasingFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  dedicatedAllocationImageAliasing: VkBool32;
end;


PVkShadingRatePaletteNV  =  ^VkShadingRatePaletteNV;
PPVkShadingRatePaletteNV = ^PVkShadingRatePaletteNV;
VkShadingRatePaletteNV = record
  shadingRatePaletteEntryCount: UInt32;
  pShadingRatePaletteEntries: PVkShadingRatePaletteEntryNV;
end;


PVkPipelineViewportShadingRateImageStateCreateInfoNV  =  ^VkPipelineViewportShadingRateImageStateCreateInfoNV;
PPVkPipelineViewportShadingRateImageStateCreateInfoNV = ^PVkPipelineViewportShadingRateImageStateCreateInfoNV;
VkPipelineViewportShadingRateImageStateCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  shadingRateImageEnable: VkBool32;
  viewportCount: UInt32;
  pShadingRatePalettes: PVkShadingRatePaletteNV;
end;


PVkPhysicalDeviceShadingRateImageFeaturesNV  =  ^VkPhysicalDeviceShadingRateImageFeaturesNV;
PPVkPhysicalDeviceShadingRateImageFeaturesNV = ^PVkPhysicalDeviceShadingRateImageFeaturesNV;
VkPhysicalDeviceShadingRateImageFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  shadingRateImage: VkBool32;
  shadingRateCoarseSampleOrder: VkBool32;
end;


PVkPhysicalDeviceShadingRateImagePropertiesNV  =  ^VkPhysicalDeviceShadingRateImagePropertiesNV;
PPVkPhysicalDeviceShadingRateImagePropertiesNV = ^PVkPhysicalDeviceShadingRateImagePropertiesNV;
VkPhysicalDeviceShadingRateImagePropertiesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  shadingRateTexelSize: VkExtent2D;
  shadingRatePaletteSize: UInt32;
  shadingRateMaxCoarseSamples: UInt32;
end;


PVkPhysicalDeviceInvocationMaskFeaturesHUAWEI  =  ^VkPhysicalDeviceInvocationMaskFeaturesHUAWEI;
PPVkPhysicalDeviceInvocationMaskFeaturesHUAWEI = ^PVkPhysicalDeviceInvocationMaskFeaturesHUAWEI;
VkPhysicalDeviceInvocationMaskFeaturesHUAWEI = record
  sType: VkStructureType;
  pNext: Pointer;
  invocationMask: VkBool32;
end;


PVkCoarseSampleLocationNV  =  ^VkCoarseSampleLocationNV;
PPVkCoarseSampleLocationNV = ^PVkCoarseSampleLocationNV;
VkCoarseSampleLocationNV = record
  pixelX: UInt32;
  pixelY: UInt32;
  sample: UInt32;
end;


PVkCoarseSampleOrderCustomNV  =  ^VkCoarseSampleOrderCustomNV;
PPVkCoarseSampleOrderCustomNV = ^PVkCoarseSampleOrderCustomNV;
VkCoarseSampleOrderCustomNV = record
  shadingRate: VkShadingRatePaletteEntryNV;
  sampleCount: UInt32;
  sampleLocationCount: UInt32;
  pSampleLocations: PVkCoarseSampleLocationNV;
end;


PVkPipelineViewportCoarseSampleOrderStateCreateInfoNV  =  ^VkPipelineViewportCoarseSampleOrderStateCreateInfoNV;
PPVkPipelineViewportCoarseSampleOrderStateCreateInfoNV = ^PVkPipelineViewportCoarseSampleOrderStateCreateInfoNV;
VkPipelineViewportCoarseSampleOrderStateCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  sampleOrderType: VkCoarseSampleOrderTypeNV;
  customSampleOrderCount: UInt32;
  pCustomSampleOrders: PVkCoarseSampleOrderCustomNV;
end;


PVkPhysicalDeviceMeshShaderFeaturesNV  =  ^VkPhysicalDeviceMeshShaderFeaturesNV;
PPVkPhysicalDeviceMeshShaderFeaturesNV = ^PVkPhysicalDeviceMeshShaderFeaturesNV;
VkPhysicalDeviceMeshShaderFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  taskShader: VkBool32;
  meshShader: VkBool32;
end;


PVkPhysicalDeviceMeshShaderPropertiesNV  =  ^VkPhysicalDeviceMeshShaderPropertiesNV;
PPVkPhysicalDeviceMeshShaderPropertiesNV = ^PVkPhysicalDeviceMeshShaderPropertiesNV;
VkPhysicalDeviceMeshShaderPropertiesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  maxDrawMeshTasksCount: UInt32;
  maxTaskWorkGroupInvocations: UInt32;
  maxTaskWorkGroupSize: array[0 .. 3 - 1] of UInt32;
  maxTaskTotalMemorySize: UInt32;
  maxTaskOutputCount: UInt32;
  maxMeshWorkGroupInvocations: UInt32;
  maxMeshWorkGroupSize: array[0 .. 3 - 1] of UInt32;
  maxMeshTotalMemorySize: UInt32;
  maxMeshOutputVertices: UInt32;
  maxMeshOutputPrimitives: UInt32;
  maxMeshMultiviewViewCount: UInt32;
  meshOutputPerVertexGranularity: UInt32;
  meshOutputPerPrimitiveGranularity: UInt32;
end;


PVkDrawMeshTasksIndirectCommandNV  =  ^VkDrawMeshTasksIndirectCommandNV;
PPVkDrawMeshTasksIndirectCommandNV = ^PVkDrawMeshTasksIndirectCommandNV;
VkDrawMeshTasksIndirectCommandNV = record
  taskCount: UInt32;
  firstTask: UInt32;
end;


PVkRayTracingShaderGroupCreateInfoNV  =  ^VkRayTracingShaderGroupCreateInfoNV;
PPVkRayTracingShaderGroupCreateInfoNV = ^PVkRayTracingShaderGroupCreateInfoNV;
VkRayTracingShaderGroupCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  _type: VkRayTracingShaderGroupTypeKHR;
  generalShader: UInt32;
  closestHitShader: UInt32;
  anyHitShader: UInt32;
  intersectionShader: UInt32;
end;


PVkRayTracingShaderGroupCreateInfoKHR  =  ^VkRayTracingShaderGroupCreateInfoKHR;
PPVkRayTracingShaderGroupCreateInfoKHR = ^PVkRayTracingShaderGroupCreateInfoKHR;
VkRayTracingShaderGroupCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  _type: VkRayTracingShaderGroupTypeKHR;
  generalShader: UInt32;
  closestHitShader: UInt32;
  anyHitShader: UInt32;
  intersectionShader: UInt32;
  pShaderGroupCaptureReplayHandle: Pointer;
end;


PVkRayTracingPipelineCreateInfoNV  =  ^VkRayTracingPipelineCreateInfoNV;
PPVkRayTracingPipelineCreateInfoNV = ^PVkRayTracingPipelineCreateInfoNV;
VkRayTracingPipelineCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineCreateFlags;
  stageCount: UInt32;
  pStages: PVkPipelineShaderStageCreateInfo;
  groupCount: UInt32;
  pGroups: PVkRayTracingShaderGroupCreateInfoNV;
  maxRecursionDepth: UInt32;
  layout: VkPipelineLayout;
  basePipelineHandle: VkPipeline;
  basePipelineIndex: Int32;
end;


PVkPipelineLibraryCreateInfoKHR = ^VkPipelineLibraryCreateInfoKHR;
PVkRayTracingPipelineInterfaceCreateInfoKHR = ^VkRayTracingPipelineInterfaceCreateInfoKHR;
PVkRayTracingPipelineCreateInfoKHR  =  ^VkRayTracingPipelineCreateInfoKHR;
PPVkRayTracingPipelineCreateInfoKHR = ^PVkRayTracingPipelineCreateInfoKHR;
VkRayTracingPipelineCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineCreateFlags;
  stageCount: UInt32;
  pStages: PVkPipelineShaderStageCreateInfo;
  groupCount: UInt32;
  pGroups: PVkRayTracingShaderGroupCreateInfoKHR;
  maxPipelineRayRecursionDepth: UInt32;
  pLibraryInfo: PVkPipelineLibraryCreateInfoKHR;
  pLibraryInterface: PVkRayTracingPipelineInterfaceCreateInfoKHR;
  pDynamicState: PVkPipelineDynamicStateCreateInfo;
  layout: VkPipelineLayout;
  basePipelineHandle: VkPipeline;
  basePipelineIndex: Int32;
end;


PVkGeometryTrianglesNV  =  ^VkGeometryTrianglesNV;
PPVkGeometryTrianglesNV = ^PVkGeometryTrianglesNV;
VkGeometryTrianglesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  vertexData: VkBuffer;
  vertexOffset: VkDeviceSize;
  vertexCount: UInt32;
  vertexStride: VkDeviceSize;
  vertexFormat: VkFormat;
  indexData: VkBuffer;
  indexOffset: VkDeviceSize;
  indexCount: UInt32;
  indexType: VkIndexType;
  transformData: VkBuffer;
  transformOffset: VkDeviceSize;
end;


PVkGeometryAABBNV  =  ^VkGeometryAABBNV;
PPVkGeometryAABBNV = ^PVkGeometryAABBNV;
VkGeometryAABBNV = record
  sType: VkStructureType;
  pNext: Pointer;
  aabbData: VkBuffer;
  numAABBs: UInt32;
  stride: UInt32;
  offset: VkDeviceSize;
end;


PVkGeometryDataNV  =  ^VkGeometryDataNV;
PPVkGeometryDataNV = ^PVkGeometryDataNV;
VkGeometryDataNV = record
  triangles: VkGeometryTrianglesNV;
  aabbs: VkGeometryAABBNV;
end;


PVkGeometryNV  =  ^VkGeometryNV;
PPVkGeometryNV = ^PVkGeometryNV;
VkGeometryNV = record
  sType: VkStructureType;
  pNext: Pointer;
  geometryType: VkGeometryTypeKHR;
  geometry: VkGeometryDataNV;
  flags: VkGeometryFlagsKHR;
end;


PVkAccelerationStructureInfoNV  =  ^VkAccelerationStructureInfoNV;
PPVkAccelerationStructureInfoNV = ^PVkAccelerationStructureInfoNV;
VkAccelerationStructureInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  _type: VkAccelerationStructureTypeNV;
  flags: VkBuildAccelerationStructureFlagsNV;
  instanceCount: UInt32;
  geometryCount: UInt32;
  pGeometries: PVkGeometryNV;
end;


PVkAccelerationStructureCreateInfoNV  =  ^VkAccelerationStructureCreateInfoNV;
PPVkAccelerationStructureCreateInfoNV = ^PVkAccelerationStructureCreateInfoNV;
VkAccelerationStructureCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  compactedSize: VkDeviceSize;
  info: VkAccelerationStructureInfoNV;
end;


PVkBindAccelerationStructureMemoryInfoNV  =  ^VkBindAccelerationStructureMemoryInfoNV;
PPVkBindAccelerationStructureMemoryInfoNV = ^PVkBindAccelerationStructureMemoryInfoNV;
VkBindAccelerationStructureMemoryInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  accelerationStructure: VkAccelerationStructureNV;
  memory: VkDeviceMemory;
  memoryOffset: VkDeviceSize;
  deviceIndexCount: UInt32;
  pDeviceIndices: PUInt32;
end;


PVkWriteDescriptorSetAccelerationStructureKHR  =  ^VkWriteDescriptorSetAccelerationStructureKHR;
PPVkWriteDescriptorSetAccelerationStructureKHR = ^PVkWriteDescriptorSetAccelerationStructureKHR;
VkWriteDescriptorSetAccelerationStructureKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  accelerationStructureCount: UInt32;
  pAccelerationStructures: PVkAccelerationStructureKHR;
end;


PVkWriteDescriptorSetAccelerationStructureNV  =  ^VkWriteDescriptorSetAccelerationStructureNV;
PPVkWriteDescriptorSetAccelerationStructureNV = ^PVkWriteDescriptorSetAccelerationStructureNV;
VkWriteDescriptorSetAccelerationStructureNV = record
  sType: VkStructureType;
  pNext: Pointer;
  accelerationStructureCount: UInt32;
  pAccelerationStructures: PVkAccelerationStructureNV;
end;


PVkAccelerationStructureMemoryRequirementsInfoNV  =  ^VkAccelerationStructureMemoryRequirementsInfoNV;
PPVkAccelerationStructureMemoryRequirementsInfoNV = ^PVkAccelerationStructureMemoryRequirementsInfoNV;
VkAccelerationStructureMemoryRequirementsInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  _type: VkAccelerationStructureMemoryRequirementsTypeNV;
  accelerationStructure: VkAccelerationStructureNV;
end;


PVkPhysicalDeviceAccelerationStructureFeaturesKHR  =  ^VkPhysicalDeviceAccelerationStructureFeaturesKHR;
PPVkPhysicalDeviceAccelerationStructureFeaturesKHR = ^PVkPhysicalDeviceAccelerationStructureFeaturesKHR;
VkPhysicalDeviceAccelerationStructureFeaturesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  accelerationStructure: VkBool32;
  accelerationStructureCaptureReplay: VkBool32;
  accelerationStructureIndirectBuild: VkBool32;
  accelerationStructureHostCommands: VkBool32;
  descriptorBindingAccelerationStructureUpdateAfterBind: VkBool32;
end;


PVkPhysicalDeviceRayTracingPipelineFeaturesKHR  =  ^VkPhysicalDeviceRayTracingPipelineFeaturesKHR;
PPVkPhysicalDeviceRayTracingPipelineFeaturesKHR = ^PVkPhysicalDeviceRayTracingPipelineFeaturesKHR;
VkPhysicalDeviceRayTracingPipelineFeaturesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  rayTracingPipeline: VkBool32;
  rayTracingPipelineShaderGroupHandleCaptureReplay: VkBool32;
  rayTracingPipelineShaderGroupHandleCaptureReplayMixed: VkBool32;
  rayTracingPipelineTraceRaysIndirect: VkBool32;
  rayTraversalPrimitiveCulling: VkBool32;
end;


PVkPhysicalDeviceRayQueryFeaturesKHR  =  ^VkPhysicalDeviceRayQueryFeaturesKHR;
PPVkPhysicalDeviceRayQueryFeaturesKHR = ^PVkPhysicalDeviceRayQueryFeaturesKHR;
VkPhysicalDeviceRayQueryFeaturesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  rayQuery: VkBool32;
end;


PVkPhysicalDeviceAccelerationStructurePropertiesKHR  =  ^VkPhysicalDeviceAccelerationStructurePropertiesKHR;
PPVkPhysicalDeviceAccelerationStructurePropertiesKHR = ^PVkPhysicalDeviceAccelerationStructurePropertiesKHR;
VkPhysicalDeviceAccelerationStructurePropertiesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  maxGeometryCount: UInt64;
  maxInstanceCount: UInt64;
  maxPrimitiveCount: UInt64;
  maxPerStageDescriptorAccelerationStructures: UInt32;
  maxPerStageDescriptorUpdateAfterBindAccelerationStructures: UInt32;
  maxDescriptorSetAccelerationStructures: UInt32;
  maxDescriptorSetUpdateAfterBindAccelerationStructures: UInt32;
  minAccelerationStructureScratchOffsetAlignment: UInt32;
end;


PVkPhysicalDeviceRayTracingPipelinePropertiesKHR  =  ^VkPhysicalDeviceRayTracingPipelinePropertiesKHR;
PPVkPhysicalDeviceRayTracingPipelinePropertiesKHR = ^PVkPhysicalDeviceRayTracingPipelinePropertiesKHR;
VkPhysicalDeviceRayTracingPipelinePropertiesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderGroupHandleSize: UInt32;
  maxRayRecursionDepth: UInt32;
  maxShaderGroupStride: UInt32;
  shaderGroupBaseAlignment: UInt32;
  shaderGroupHandleCaptureReplaySize: UInt32;
  maxRayDispatchInvocationCount: UInt32;
  shaderGroupHandleAlignment: UInt32;
  maxRayHitAttributeSize: UInt32;
end;


PVkPhysicalDeviceRayTracingPropertiesNV  =  ^VkPhysicalDeviceRayTracingPropertiesNV;
PPVkPhysicalDeviceRayTracingPropertiesNV = ^PVkPhysicalDeviceRayTracingPropertiesNV;
VkPhysicalDeviceRayTracingPropertiesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderGroupHandleSize: UInt32;
  maxRecursionDepth: UInt32;
  maxShaderGroupStride: UInt32;
  shaderGroupBaseAlignment: UInt32;
  maxGeometryCount: UInt64;
  maxInstanceCount: UInt64;
  maxTriangleCount: UInt64;
  maxDescriptorSetAccelerationStructures: UInt32;
end;


PVkStridedDeviceAddressRegionKHR  =  ^VkStridedDeviceAddressRegionKHR;
PPVkStridedDeviceAddressRegionKHR = ^PVkStridedDeviceAddressRegionKHR;
VkStridedDeviceAddressRegionKHR = record
  deviceAddress: VkDeviceAddress;
  stride: VkDeviceSize;
  size: VkDeviceSize;
end;


PVkTraceRaysIndirectCommandKHR  =  ^VkTraceRaysIndirectCommandKHR;
PPVkTraceRaysIndirectCommandKHR = ^PVkTraceRaysIndirectCommandKHR;
VkTraceRaysIndirectCommandKHR = record
  width: UInt32;
  height: UInt32;
  depth: UInt32;
end;


PVkDrmFormatModifierPropertiesEXT = ^VkDrmFormatModifierPropertiesEXT;
PVkDrmFormatModifierPropertiesListEXT  =  ^VkDrmFormatModifierPropertiesListEXT;
PPVkDrmFormatModifierPropertiesListEXT = ^PVkDrmFormatModifierPropertiesListEXT;
VkDrmFormatModifierPropertiesListEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  drmFormatModifierCount: UInt32;
  pDrmFormatModifierProperties: PVkDrmFormatModifierPropertiesEXT;
end;


PPVkDrmFormatModifierPropertiesEXT = ^PVkDrmFormatModifierPropertiesEXT;
VkDrmFormatModifierPropertiesEXT = record
  drmFormatModifier: UInt64;
  drmFormatModifierPlaneCount: UInt32;
  drmFormatModifierTilingFeatures: VkFormatFeatureFlags;
end;


PVkPhysicalDeviceImageDrmFormatModifierInfoEXT  =  ^VkPhysicalDeviceImageDrmFormatModifierInfoEXT;
PPVkPhysicalDeviceImageDrmFormatModifierInfoEXT = ^PVkPhysicalDeviceImageDrmFormatModifierInfoEXT;
VkPhysicalDeviceImageDrmFormatModifierInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  drmFormatModifier: UInt64;
  sharingMode: VkSharingMode;
  queueFamilyIndexCount: UInt32;
  pQueueFamilyIndices: PUInt32;
end;


PVkImageDrmFormatModifierListCreateInfoEXT  =  ^VkImageDrmFormatModifierListCreateInfoEXT;
PPVkImageDrmFormatModifierListCreateInfoEXT = ^PVkImageDrmFormatModifierListCreateInfoEXT;
VkImageDrmFormatModifierListCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  drmFormatModifierCount: UInt32;
  pDrmFormatModifiers: PUInt64;
end;


PVkImageDrmFormatModifierExplicitCreateInfoEXT  =  ^VkImageDrmFormatModifierExplicitCreateInfoEXT;
PPVkImageDrmFormatModifierExplicitCreateInfoEXT = ^PVkImageDrmFormatModifierExplicitCreateInfoEXT;
VkImageDrmFormatModifierExplicitCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  drmFormatModifier: UInt64;
  drmFormatModifierPlaneCount: UInt32;
  pPlaneLayouts: PVkSubresourceLayout;
end;


PVkImageDrmFormatModifierPropertiesEXT  =  ^VkImageDrmFormatModifierPropertiesEXT;
PPVkImageDrmFormatModifierPropertiesEXT = ^PVkImageDrmFormatModifierPropertiesEXT;
VkImageDrmFormatModifierPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  drmFormatModifier: UInt64;
end;


PVkImageStencilUsageCreateInfo  =  ^VkImageStencilUsageCreateInfo;
PPVkImageStencilUsageCreateInfo = ^PVkImageStencilUsageCreateInfo;
VkImageStencilUsageCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  stencilUsage: VkImageUsageFlags;
end;


PVkDeviceMemoryOverallocationCreateInfoAMD  =  ^VkDeviceMemoryOverallocationCreateInfoAMD;
PPVkDeviceMemoryOverallocationCreateInfoAMD = ^PVkDeviceMemoryOverallocationCreateInfoAMD;
VkDeviceMemoryOverallocationCreateInfoAMD = record
  sType: VkStructureType;
  pNext: Pointer;
  overallocationBehavior: VkMemoryOverallocationBehaviorAMD;
end;


PVkPhysicalDeviceFragmentDensityMapFeaturesEXT  =  ^VkPhysicalDeviceFragmentDensityMapFeaturesEXT;
PPVkPhysicalDeviceFragmentDensityMapFeaturesEXT = ^PVkPhysicalDeviceFragmentDensityMapFeaturesEXT;
VkPhysicalDeviceFragmentDensityMapFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  fragmentDensityMap: VkBool32;
  fragmentDensityMapDynamic: VkBool32;
  fragmentDensityMapNonSubsampledImages: VkBool32;
end;


PVkPhysicalDeviceFragmentDensityMap2FeaturesEXT  =  ^VkPhysicalDeviceFragmentDensityMap2FeaturesEXT;
PPVkPhysicalDeviceFragmentDensityMap2FeaturesEXT = ^PVkPhysicalDeviceFragmentDensityMap2FeaturesEXT;
VkPhysicalDeviceFragmentDensityMap2FeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  fragmentDensityMapDeferred: VkBool32;
end;


PVkPhysicalDeviceFragmentDensityMapPropertiesEXT  =  ^VkPhysicalDeviceFragmentDensityMapPropertiesEXT;
PPVkPhysicalDeviceFragmentDensityMapPropertiesEXT = ^PVkPhysicalDeviceFragmentDensityMapPropertiesEXT;
VkPhysicalDeviceFragmentDensityMapPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  minFragmentDensityTexelSize: VkExtent2D;
  maxFragmentDensityTexelSize: VkExtent2D;
  fragmentDensityInvocations: VkBool32;
end;


PVkPhysicalDeviceFragmentDensityMap2PropertiesEXT  =  ^VkPhysicalDeviceFragmentDensityMap2PropertiesEXT;
PPVkPhysicalDeviceFragmentDensityMap2PropertiesEXT = ^PVkPhysicalDeviceFragmentDensityMap2PropertiesEXT;
VkPhysicalDeviceFragmentDensityMap2PropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  subsampledLoads: VkBool32;
  subsampledCoarseReconstructionEarlyAccess: VkBool32;
  maxSubsampledArrayLayers: UInt32;
  maxDescriptorSetSubsampledSamplers: UInt32;
end;


PVkRenderPassFragmentDensityMapCreateInfoEXT  =  ^VkRenderPassFragmentDensityMapCreateInfoEXT;
PPVkRenderPassFragmentDensityMapCreateInfoEXT = ^PVkRenderPassFragmentDensityMapCreateInfoEXT;
VkRenderPassFragmentDensityMapCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  fragmentDensityMapAttachment: VkAttachmentReference;
end;


PVkPhysicalDeviceScalarBlockLayoutFeatures  =  ^VkPhysicalDeviceScalarBlockLayoutFeatures;
PPVkPhysicalDeviceScalarBlockLayoutFeatures = ^PVkPhysicalDeviceScalarBlockLayoutFeatures;
VkPhysicalDeviceScalarBlockLayoutFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  scalarBlockLayout: VkBool32;
end;


PVkSurfaceProtectedCapabilitiesKHR  =  ^VkSurfaceProtectedCapabilitiesKHR;
PPVkSurfaceProtectedCapabilitiesKHR = ^PVkSurfaceProtectedCapabilitiesKHR;
VkSurfaceProtectedCapabilitiesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  supportsProtected: VkBool32;
end;


PVkPhysicalDeviceUniformBufferStandardLayoutFeatures  =  ^VkPhysicalDeviceUniformBufferStandardLayoutFeatures;
PPVkPhysicalDeviceUniformBufferStandardLayoutFeatures = ^PVkPhysicalDeviceUniformBufferStandardLayoutFeatures;
VkPhysicalDeviceUniformBufferStandardLayoutFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  uniformBufferStandardLayout: VkBool32;
end;


PVkPhysicalDeviceDepthClipEnableFeaturesEXT  =  ^VkPhysicalDeviceDepthClipEnableFeaturesEXT;
PPVkPhysicalDeviceDepthClipEnableFeaturesEXT = ^PVkPhysicalDeviceDepthClipEnableFeaturesEXT;
VkPhysicalDeviceDepthClipEnableFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  depthClipEnable: VkBool32;
end;


PVkPipelineRasterizationDepthClipStateCreateInfoEXT  =  ^VkPipelineRasterizationDepthClipStateCreateInfoEXT;
PPVkPipelineRasterizationDepthClipStateCreateInfoEXT = ^PVkPipelineRasterizationDepthClipStateCreateInfoEXT;
VkPipelineRasterizationDepthClipStateCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineRasterizationDepthClipStateCreateFlagsEXT;
  depthClipEnable: VkBool32;
end;


PVkPhysicalDeviceMemoryBudgetPropertiesEXT  =  ^VkPhysicalDeviceMemoryBudgetPropertiesEXT;
PPVkPhysicalDeviceMemoryBudgetPropertiesEXT = ^PVkPhysicalDeviceMemoryBudgetPropertiesEXT;
VkPhysicalDeviceMemoryBudgetPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  heapBudget: array[0 .. VK_MAX_MEMORY_HEAPS - 1] of VkDeviceSize;
  heapUsage: array[0 .. VK_MAX_MEMORY_HEAPS - 1] of VkDeviceSize;
end;


PVkPhysicalDeviceMemoryPriorityFeaturesEXT  =  ^VkPhysicalDeviceMemoryPriorityFeaturesEXT;
PPVkPhysicalDeviceMemoryPriorityFeaturesEXT = ^PVkPhysicalDeviceMemoryPriorityFeaturesEXT;
VkPhysicalDeviceMemoryPriorityFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  memoryPriority: VkBool32;
end;


PVkMemoryPriorityAllocateInfoEXT  =  ^VkMemoryPriorityAllocateInfoEXT;
PPVkMemoryPriorityAllocateInfoEXT = ^PVkMemoryPriorityAllocateInfoEXT;
VkMemoryPriorityAllocateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  priority: Single;
end;


PVkPhysicalDeviceBufferDeviceAddressFeatures  =  ^VkPhysicalDeviceBufferDeviceAddressFeatures;
PPVkPhysicalDeviceBufferDeviceAddressFeatures = ^PVkPhysicalDeviceBufferDeviceAddressFeatures;
VkPhysicalDeviceBufferDeviceAddressFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  bufferDeviceAddress: VkBool32;
  bufferDeviceAddressCaptureReplay: VkBool32;
  bufferDeviceAddressMultiDevice: VkBool32;
end;


PVkPhysicalDeviceBufferDeviceAddressFeaturesEXT  =  ^VkPhysicalDeviceBufferDeviceAddressFeaturesEXT;
PPVkPhysicalDeviceBufferDeviceAddressFeaturesEXT = ^PVkPhysicalDeviceBufferDeviceAddressFeaturesEXT;
VkPhysicalDeviceBufferDeviceAddressFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  bufferDeviceAddress: VkBool32;
  bufferDeviceAddressCaptureReplay: VkBool32;
  bufferDeviceAddressMultiDevice: VkBool32;
end;


PVkBufferDeviceAddressInfo  =  ^VkBufferDeviceAddressInfo;
PPVkBufferDeviceAddressInfo = ^PVkBufferDeviceAddressInfo;
VkBufferDeviceAddressInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  buffer: VkBuffer;
end;


PVkBufferOpaqueCaptureAddressCreateInfo  =  ^VkBufferOpaqueCaptureAddressCreateInfo;
PPVkBufferOpaqueCaptureAddressCreateInfo = ^PVkBufferOpaqueCaptureAddressCreateInfo;
VkBufferOpaqueCaptureAddressCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  opaqueCaptureAddress: UInt64;
end;


PVkBufferDeviceAddressCreateInfoEXT  =  ^VkBufferDeviceAddressCreateInfoEXT;
PPVkBufferDeviceAddressCreateInfoEXT = ^PVkBufferDeviceAddressCreateInfoEXT;
VkBufferDeviceAddressCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  deviceAddress: VkDeviceAddress;
end;


PVkPhysicalDeviceImageViewImageFormatInfoEXT  =  ^VkPhysicalDeviceImageViewImageFormatInfoEXT;
PPVkPhysicalDeviceImageViewImageFormatInfoEXT = ^PVkPhysicalDeviceImageViewImageFormatInfoEXT;
VkPhysicalDeviceImageViewImageFormatInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  imageViewType: VkImageViewType;
end;


PVkFilterCubicImageViewImageFormatPropertiesEXT  =  ^VkFilterCubicImageViewImageFormatPropertiesEXT;
PPVkFilterCubicImageViewImageFormatPropertiesEXT = ^PVkFilterCubicImageViewImageFormatPropertiesEXT;
VkFilterCubicImageViewImageFormatPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  filterCubic: VkBool32;
  filterCubicMinmax: VkBool32;
end;


PVkPhysicalDeviceImagelessFramebufferFeatures  =  ^VkPhysicalDeviceImagelessFramebufferFeatures;
PPVkPhysicalDeviceImagelessFramebufferFeatures = ^PVkPhysicalDeviceImagelessFramebufferFeatures;
VkPhysicalDeviceImagelessFramebufferFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  imagelessFramebuffer: VkBool32;
end;


PVkFramebufferAttachmentImageInfo = ^VkFramebufferAttachmentImageInfo;
PVkFramebufferAttachmentsCreateInfo  =  ^VkFramebufferAttachmentsCreateInfo;
PPVkFramebufferAttachmentsCreateInfo = ^PVkFramebufferAttachmentsCreateInfo;
VkFramebufferAttachmentsCreateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  attachmentImageInfoCount: UInt32;
  pAttachmentImageInfos: PVkFramebufferAttachmentImageInfo;
end;


PPVkFramebufferAttachmentImageInfo = ^PVkFramebufferAttachmentImageInfo;
VkFramebufferAttachmentImageInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkImageCreateFlags;
  usage: VkImageUsageFlags;
  width: UInt32;
  height: UInt32;
  layerCount: UInt32;
  viewFormatCount: UInt32;
  pViewFormats: PVkFormat;
end;


PVkRenderPassAttachmentBeginInfo  =  ^VkRenderPassAttachmentBeginInfo;
PPVkRenderPassAttachmentBeginInfo = ^PVkRenderPassAttachmentBeginInfo;
VkRenderPassAttachmentBeginInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  attachmentCount: UInt32;
  pAttachments: PVkImageView;
end;


PVkPhysicalDeviceTextureCompressionASTCHDRFeaturesEXT  =  ^VkPhysicalDeviceTextureCompressionASTCHDRFeaturesEXT;
PPVkPhysicalDeviceTextureCompressionASTCHDRFeaturesEXT = ^PVkPhysicalDeviceTextureCompressionASTCHDRFeaturesEXT;
VkPhysicalDeviceTextureCompressionASTCHDRFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  textureCompressionASTC_HDR: VkBool32;
end;


PVkPhysicalDeviceCooperativeMatrixFeaturesNV  =  ^VkPhysicalDeviceCooperativeMatrixFeaturesNV;
PPVkPhysicalDeviceCooperativeMatrixFeaturesNV = ^PVkPhysicalDeviceCooperativeMatrixFeaturesNV;
VkPhysicalDeviceCooperativeMatrixFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  cooperativeMatrix: VkBool32;
  cooperativeMatrixRobustBufferAccess: VkBool32;
end;


PVkPhysicalDeviceCooperativeMatrixPropertiesNV  =  ^VkPhysicalDeviceCooperativeMatrixPropertiesNV;
PPVkPhysicalDeviceCooperativeMatrixPropertiesNV = ^PVkPhysicalDeviceCooperativeMatrixPropertiesNV;
VkPhysicalDeviceCooperativeMatrixPropertiesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  cooperativeMatrixSupportedStages: VkShaderStageFlags;
end;


PVkCooperativeMatrixPropertiesNV  =  ^VkCooperativeMatrixPropertiesNV;
PPVkCooperativeMatrixPropertiesNV = ^PVkCooperativeMatrixPropertiesNV;
VkCooperativeMatrixPropertiesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  MSize: UInt32;
  NSize: UInt32;
  KSize: UInt32;
  AType: VkComponentTypeNV;
  BType: VkComponentTypeNV;
  CType: VkComponentTypeNV;
  DType: VkComponentTypeNV;
  scope: VkScopeNV;
end;


PVkPhysicalDeviceYcbcrImageArraysFeaturesEXT  =  ^VkPhysicalDeviceYcbcrImageArraysFeaturesEXT;
PPVkPhysicalDeviceYcbcrImageArraysFeaturesEXT = ^PVkPhysicalDeviceYcbcrImageArraysFeaturesEXT;
VkPhysicalDeviceYcbcrImageArraysFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  ycbcrImageArrays: VkBool32;
end;


PVkImageViewHandleInfoNVX  =  ^VkImageViewHandleInfoNVX;
PPVkImageViewHandleInfoNVX = ^PVkImageViewHandleInfoNVX;
VkImageViewHandleInfoNVX = record
  sType: VkStructureType;
  pNext: Pointer;
  imageView: VkImageView;
  descriptorType: VkDescriptorType;
  sampler: VkSampler;
end;


PVkImageViewAddressPropertiesNVX  =  ^VkImageViewAddressPropertiesNVX;
PPVkImageViewAddressPropertiesNVX = ^PVkImageViewAddressPropertiesNVX;
VkImageViewAddressPropertiesNVX = record
  sType: VkStructureType;
  pNext: Pointer;
  deviceAddress: VkDeviceAddress;
  size: VkDeviceSize;
end;


PVkPipelineCreationFeedbackEXT  =  ^VkPipelineCreationFeedbackEXT;
PPVkPipelineCreationFeedbackEXT = ^PVkPipelineCreationFeedbackEXT;
VkPipelineCreationFeedbackEXT = record
  flags: VkPipelineCreationFeedbackFlagsEXT;
  duration: UInt64;
end;


PVkPipelineCreationFeedbackCreateInfoEXT  =  ^VkPipelineCreationFeedbackCreateInfoEXT;
PPVkPipelineCreationFeedbackCreateInfoEXT = ^PVkPipelineCreationFeedbackCreateInfoEXT;
VkPipelineCreationFeedbackCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  pPipelineCreationFeedback: PVkPipelineCreationFeedbackEXT;
  pipelineStageCreationFeedbackCount: UInt32;
  pPipelineStageCreationFeedbacks: PVkPipelineCreationFeedbackEXT;
end;


PVkSurfaceFullScreenExclusiveInfoEXT  =  ^VkSurfaceFullScreenExclusiveInfoEXT;
PPVkSurfaceFullScreenExclusiveInfoEXT = ^PVkSurfaceFullScreenExclusiveInfoEXT;
VkSurfaceFullScreenExclusiveInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  fullScreenExclusive: VkFullScreenExclusiveEXT;
end;


PVkSurfaceFullScreenExclusiveWin32InfoEXT  =  ^VkSurfaceFullScreenExclusiveWin32InfoEXT;
PPVkSurfaceFullScreenExclusiveWin32InfoEXT = ^PVkSurfaceFullScreenExclusiveWin32InfoEXT;
VkSurfaceFullScreenExclusiveWin32InfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  hmonitor: HMONITOR;
end;


PVkSurfaceCapabilitiesFullScreenExclusiveEXT  =  ^VkSurfaceCapabilitiesFullScreenExclusiveEXT;
PPVkSurfaceCapabilitiesFullScreenExclusiveEXT = ^PVkSurfaceCapabilitiesFullScreenExclusiveEXT;
VkSurfaceCapabilitiesFullScreenExclusiveEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  fullScreenExclusiveSupported: VkBool32;
end;


PVkPhysicalDevicePerformanceQueryFeaturesKHR  =  ^VkPhysicalDevicePerformanceQueryFeaturesKHR;
PPVkPhysicalDevicePerformanceQueryFeaturesKHR = ^PVkPhysicalDevicePerformanceQueryFeaturesKHR;
VkPhysicalDevicePerformanceQueryFeaturesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  performanceCounterQueryPools: VkBool32;
  performanceCounterMultipleQueryPools: VkBool32;
end;


PVkPhysicalDevicePerformanceQueryPropertiesKHR  =  ^VkPhysicalDevicePerformanceQueryPropertiesKHR;
PPVkPhysicalDevicePerformanceQueryPropertiesKHR = ^PVkPhysicalDevicePerformanceQueryPropertiesKHR;
VkPhysicalDevicePerformanceQueryPropertiesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  allowCommandBufferQueryCopies: VkBool32;
end;


PVkPerformanceCounterKHR  =  ^VkPerformanceCounterKHR;
PPVkPerformanceCounterKHR = ^PVkPerformanceCounterKHR;
VkPerformanceCounterKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  _unit: VkPerformanceCounterUnitKHR;
  scope: VkPerformanceCounterScopeKHR;
  storage: VkPerformanceCounterStorageKHR;
  uuid: array[0 .. VK_UUID_SIZE - 1] of UInt8;
end;


PVkPerformanceCounterDescriptionKHR  =  ^VkPerformanceCounterDescriptionKHR;
PPVkPerformanceCounterDescriptionKHR = ^PVkPerformanceCounterDescriptionKHR;
VkPerformanceCounterDescriptionKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPerformanceCounterDescriptionFlagsKHR;
  name: array[0 .. VK_MAX_DESCRIPTION_SIZE - 1] of AnsiChar;
  category: array[0 .. VK_MAX_DESCRIPTION_SIZE - 1] of AnsiChar;
  description: array[0 .. VK_MAX_DESCRIPTION_SIZE - 1] of AnsiChar;
end;


PVkQueryPoolPerformanceCreateInfoKHR  =  ^VkQueryPoolPerformanceCreateInfoKHR;
PPVkQueryPoolPerformanceCreateInfoKHR = ^PVkQueryPoolPerformanceCreateInfoKHR;
VkQueryPoolPerformanceCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  queueFamilyIndex: UInt32;
  counterIndexCount: UInt32;
  pCounterIndices: PUInt32;
end;


PVkPerformanceCounterResultKHR  =  ^VkPerformanceCounterResultKHR;
PPVkPerformanceCounterResultKHR = ^PVkPerformanceCounterResultKHR;
VkPerformanceCounterResultKHR = record
case Byte of
  0: (int32: Int32);
  1: (int64: Int64);
  2: (uint32: UInt32);
  3: (uint64: UInt64);
  4: (float32: Single);
  5: (float64: Double);
end;


PVkAcquireProfilingLockInfoKHR  =  ^VkAcquireProfilingLockInfoKHR;
PPVkAcquireProfilingLockInfoKHR = ^PVkAcquireProfilingLockInfoKHR;
VkAcquireProfilingLockInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkAcquireProfilingLockFlagsKHR;
  timeout: UInt64;
end;


PVkPerformanceQuerySubmitInfoKHR  =  ^VkPerformanceQuerySubmitInfoKHR;
PPVkPerformanceQuerySubmitInfoKHR = ^PVkPerformanceQuerySubmitInfoKHR;
VkPerformanceQuerySubmitInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  counterPassIndex: UInt32;
end;


PVkHeadlessSurfaceCreateInfoEXT  =  ^VkHeadlessSurfaceCreateInfoEXT;
PPVkHeadlessSurfaceCreateInfoEXT = ^PVkHeadlessSurfaceCreateInfoEXT;
VkHeadlessSurfaceCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkHeadlessSurfaceCreateFlagsEXT;
end;


PVkPhysicalDeviceCoverageReductionModeFeaturesNV  =  ^VkPhysicalDeviceCoverageReductionModeFeaturesNV;
PPVkPhysicalDeviceCoverageReductionModeFeaturesNV = ^PVkPhysicalDeviceCoverageReductionModeFeaturesNV;
VkPhysicalDeviceCoverageReductionModeFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  coverageReductionMode: VkBool32;
end;


PVkPipelineCoverageReductionStateCreateInfoNV  =  ^VkPipelineCoverageReductionStateCreateInfoNV;
PPVkPipelineCoverageReductionStateCreateInfoNV = ^PVkPipelineCoverageReductionStateCreateInfoNV;
VkPipelineCoverageReductionStateCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkPipelineCoverageReductionStateCreateFlagsNV;
  coverageReductionMode: VkCoverageReductionModeNV;
end;


PVkFramebufferMixedSamplesCombinationNV  =  ^VkFramebufferMixedSamplesCombinationNV;
PPVkFramebufferMixedSamplesCombinationNV = ^PVkFramebufferMixedSamplesCombinationNV;
VkFramebufferMixedSamplesCombinationNV = record
  sType: VkStructureType;
  pNext: Pointer;
  coverageReductionMode: VkCoverageReductionModeNV;
  rasterizationSamples: VkSampleCountFlagBits;
  depthStencilSamples: VkSampleCountFlags;
  colorSamples: VkSampleCountFlags;
end;


PVkPhysicalDeviceShaderIntegerFunctions2FeaturesINTEL  =  ^VkPhysicalDeviceShaderIntegerFunctions2FeaturesINTEL;
PPVkPhysicalDeviceShaderIntegerFunctions2FeaturesINTEL = ^PVkPhysicalDeviceShaderIntegerFunctions2FeaturesINTEL;
VkPhysicalDeviceShaderIntegerFunctions2FeaturesINTEL = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderIntegerFunctions2: VkBool32;
end;


PVkPerformanceValueDataINTEL  =  ^VkPerformanceValueDataINTEL;
PPVkPerformanceValueDataINTEL = ^PVkPerformanceValueDataINTEL;
VkPerformanceValueDataINTEL = record
case Byte of
  0: (value32: UInt32);
  1: (value64: UInt64);
  2: (valueFloat: Single);
  3: (valueBool: VkBool32);
  4: (valueString: PAnsiChar);
end;


PVkPerformanceValueINTEL  =  ^VkPerformanceValueINTEL;
PPVkPerformanceValueINTEL = ^PVkPerformanceValueINTEL;
VkPerformanceValueINTEL = record
  _type: VkPerformanceValueTypeINTEL;
  data: VkPerformanceValueDataINTEL;
end;


PVkInitializePerformanceApiInfoINTEL  =  ^VkInitializePerformanceApiInfoINTEL;
PPVkInitializePerformanceApiInfoINTEL = ^PVkInitializePerformanceApiInfoINTEL;
VkInitializePerformanceApiInfoINTEL = record
  sType: VkStructureType;
  pNext: Pointer;
  pUserData: Pointer;
end;


PVkQueryPoolPerformanceQueryCreateInfoINTEL  =  ^VkQueryPoolPerformanceQueryCreateInfoINTEL;
PPVkQueryPoolPerformanceQueryCreateInfoINTEL = ^PVkQueryPoolPerformanceQueryCreateInfoINTEL;
VkQueryPoolPerformanceQueryCreateInfoINTEL = record
  sType: VkStructureType;
  pNext: Pointer;
  performanceCountersSampling: VkQueryPoolSamplingModeINTEL;
end;


PVkPerformanceMarkerInfoINTEL  =  ^VkPerformanceMarkerInfoINTEL;
PPVkPerformanceMarkerInfoINTEL = ^PVkPerformanceMarkerInfoINTEL;
VkPerformanceMarkerInfoINTEL = record
  sType: VkStructureType;
  pNext: Pointer;
  marker: UInt64;
end;


PVkPerformanceStreamMarkerInfoINTEL  =  ^VkPerformanceStreamMarkerInfoINTEL;
PPVkPerformanceStreamMarkerInfoINTEL = ^PVkPerformanceStreamMarkerInfoINTEL;
VkPerformanceStreamMarkerInfoINTEL = record
  sType: VkStructureType;
  pNext: Pointer;
  marker: UInt32;
end;


PVkPerformanceOverrideInfoINTEL  =  ^VkPerformanceOverrideInfoINTEL;
PPVkPerformanceOverrideInfoINTEL = ^PVkPerformanceOverrideInfoINTEL;
VkPerformanceOverrideInfoINTEL = record
  sType: VkStructureType;
  pNext: Pointer;
  _type: VkPerformanceOverrideTypeINTEL;
  enable: VkBool32;
  parameter: UInt64;
end;


PVkPerformanceConfigurationAcquireInfoINTEL  =  ^VkPerformanceConfigurationAcquireInfoINTEL;
PPVkPerformanceConfigurationAcquireInfoINTEL = ^PVkPerformanceConfigurationAcquireInfoINTEL;
VkPerformanceConfigurationAcquireInfoINTEL = record
  sType: VkStructureType;
  pNext: Pointer;
  _type: VkPerformanceConfigurationTypeINTEL;
end;


PVkPhysicalDeviceShaderClockFeaturesKHR  =  ^VkPhysicalDeviceShaderClockFeaturesKHR;
PPVkPhysicalDeviceShaderClockFeaturesKHR = ^PVkPhysicalDeviceShaderClockFeaturesKHR;
VkPhysicalDeviceShaderClockFeaturesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderSubgroupClock: VkBool32;
  shaderDeviceClock: VkBool32;
end;


PVkPhysicalDeviceIndexTypeUint8FeaturesEXT  =  ^VkPhysicalDeviceIndexTypeUint8FeaturesEXT;
PPVkPhysicalDeviceIndexTypeUint8FeaturesEXT = ^PVkPhysicalDeviceIndexTypeUint8FeaturesEXT;
VkPhysicalDeviceIndexTypeUint8FeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  indexTypeUint8: VkBool32;
end;


PVkPhysicalDeviceShaderSMBuiltinsPropertiesNV  =  ^VkPhysicalDeviceShaderSMBuiltinsPropertiesNV;
PPVkPhysicalDeviceShaderSMBuiltinsPropertiesNV = ^PVkPhysicalDeviceShaderSMBuiltinsPropertiesNV;
VkPhysicalDeviceShaderSMBuiltinsPropertiesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderSMCount: UInt32;
  shaderWarpsPerSM: UInt32;
end;


PVkPhysicalDeviceShaderSMBuiltinsFeaturesNV  =  ^VkPhysicalDeviceShaderSMBuiltinsFeaturesNV;
PPVkPhysicalDeviceShaderSMBuiltinsFeaturesNV = ^PVkPhysicalDeviceShaderSMBuiltinsFeaturesNV;
VkPhysicalDeviceShaderSMBuiltinsFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderSMBuiltins: VkBool32;
end;


PVkPhysicalDeviceFragmentShaderInterlockFeaturesEXT  =  ^VkPhysicalDeviceFragmentShaderInterlockFeaturesEXT;
PPVkPhysicalDeviceFragmentShaderInterlockFeaturesEXT = ^PVkPhysicalDeviceFragmentShaderInterlockFeaturesEXT;
VkPhysicalDeviceFragmentShaderInterlockFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  fragmentShaderSampleInterlock: VkBool32;
  fragmentShaderPixelInterlock: VkBool32;
  fragmentShaderShadingRateInterlock: VkBool32;
end;


PVkPhysicalDeviceSeparateDepthStencilLayoutsFeatures  =  ^VkPhysicalDeviceSeparateDepthStencilLayoutsFeatures;
PPVkPhysicalDeviceSeparateDepthStencilLayoutsFeatures = ^PVkPhysicalDeviceSeparateDepthStencilLayoutsFeatures;
VkPhysicalDeviceSeparateDepthStencilLayoutsFeatures = record
  sType: VkStructureType;
  pNext: Pointer;
  separateDepthStencilLayouts: VkBool32;
end;


PVkAttachmentReferenceStencilLayout  =  ^VkAttachmentReferenceStencilLayout;
PPVkAttachmentReferenceStencilLayout = ^PVkAttachmentReferenceStencilLayout;
VkAttachmentReferenceStencilLayout = record
  sType: VkStructureType;
  pNext: Pointer;
  stencilLayout: VkImageLayout;
end;


PVkAttachmentDescriptionStencilLayout  =  ^VkAttachmentDescriptionStencilLayout;
PPVkAttachmentDescriptionStencilLayout = ^PVkAttachmentDescriptionStencilLayout;
VkAttachmentDescriptionStencilLayout = record
  sType: VkStructureType;
  pNext: Pointer;
  stencilInitialLayout: VkImageLayout;
  stencilFinalLayout: VkImageLayout;
end;


PVkPhysicalDevicePipelineExecutablePropertiesFeaturesKHR  =  ^VkPhysicalDevicePipelineExecutablePropertiesFeaturesKHR;
PPVkPhysicalDevicePipelineExecutablePropertiesFeaturesKHR = ^PVkPhysicalDevicePipelineExecutablePropertiesFeaturesKHR;
VkPhysicalDevicePipelineExecutablePropertiesFeaturesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  pipelineExecutableInfo: VkBool32;
end;


PVkPipelineInfoKHR  =  ^VkPipelineInfoKHR;
PPVkPipelineInfoKHR = ^PVkPipelineInfoKHR;
VkPipelineInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  pipeline: VkPipeline;
end;


PVkPipelineExecutablePropertiesKHR  =  ^VkPipelineExecutablePropertiesKHR;
PPVkPipelineExecutablePropertiesKHR = ^PVkPipelineExecutablePropertiesKHR;
VkPipelineExecutablePropertiesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  stages: VkShaderStageFlags;
  name: array[0 .. VK_MAX_DESCRIPTION_SIZE - 1] of AnsiChar;
  description: array[0 .. VK_MAX_DESCRIPTION_SIZE - 1] of AnsiChar;
  subgroupSize: UInt32;
end;


PVkPipelineExecutableInfoKHR  =  ^VkPipelineExecutableInfoKHR;
PPVkPipelineExecutableInfoKHR = ^PVkPipelineExecutableInfoKHR;
VkPipelineExecutableInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  pipeline: VkPipeline;
  executableIndex: UInt32;
end;


PVkPipelineExecutableStatisticValueKHR  =  ^VkPipelineExecutableStatisticValueKHR;
PPVkPipelineExecutableStatisticValueKHR = ^PVkPipelineExecutableStatisticValueKHR;
VkPipelineExecutableStatisticValueKHR = record
case Byte of
  0: (b32: VkBool32);
  1: (i64: Int64);
  2: (u64: UInt64);
  3: (f64: Double);
end;


PVkPipelineExecutableStatisticKHR  =  ^VkPipelineExecutableStatisticKHR;
PPVkPipelineExecutableStatisticKHR = ^PVkPipelineExecutableStatisticKHR;
VkPipelineExecutableStatisticKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  name: array[0 .. VK_MAX_DESCRIPTION_SIZE - 1] of AnsiChar;
  description: array[0 .. VK_MAX_DESCRIPTION_SIZE - 1] of AnsiChar;
  format: VkPipelineExecutableStatisticFormatKHR;
  value: VkPipelineExecutableStatisticValueKHR;
end;


PVkPipelineExecutableInternalRepresentationKHR  =  ^VkPipelineExecutableInternalRepresentationKHR;
PPVkPipelineExecutableInternalRepresentationKHR = ^PVkPipelineExecutableInternalRepresentationKHR;
VkPipelineExecutableInternalRepresentationKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  name: array[0 .. VK_MAX_DESCRIPTION_SIZE - 1] of AnsiChar;
  description: array[0 .. VK_MAX_DESCRIPTION_SIZE - 1] of AnsiChar;
  isText: VkBool32;
  dataSize: SizeUInt;
  pData: Pointer;
end;


PVkPhysicalDeviceShaderDemoteToHelperInvocationFeaturesEXT  =  ^VkPhysicalDeviceShaderDemoteToHelperInvocationFeaturesEXT;
PPVkPhysicalDeviceShaderDemoteToHelperInvocationFeaturesEXT = ^PVkPhysicalDeviceShaderDemoteToHelperInvocationFeaturesEXT;
VkPhysicalDeviceShaderDemoteToHelperInvocationFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderDemoteToHelperInvocation: VkBool32;
end;


PVkPhysicalDeviceTexelBufferAlignmentFeaturesEXT  =  ^VkPhysicalDeviceTexelBufferAlignmentFeaturesEXT;
PPVkPhysicalDeviceTexelBufferAlignmentFeaturesEXT = ^PVkPhysicalDeviceTexelBufferAlignmentFeaturesEXT;
VkPhysicalDeviceTexelBufferAlignmentFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  texelBufferAlignment: VkBool32;
end;


PVkPhysicalDeviceTexelBufferAlignmentPropertiesEXT  =  ^VkPhysicalDeviceTexelBufferAlignmentPropertiesEXT;
PPVkPhysicalDeviceTexelBufferAlignmentPropertiesEXT = ^PVkPhysicalDeviceTexelBufferAlignmentPropertiesEXT;
VkPhysicalDeviceTexelBufferAlignmentPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  storageTexelBufferOffsetAlignmentBytes: VkDeviceSize;
  storageTexelBufferOffsetSingleTexelAlignment: VkBool32;
  uniformTexelBufferOffsetAlignmentBytes: VkDeviceSize;
  uniformTexelBufferOffsetSingleTexelAlignment: VkBool32;
end;


PVkPhysicalDeviceSubgroupSizeControlFeaturesEXT  =  ^VkPhysicalDeviceSubgroupSizeControlFeaturesEXT;
PPVkPhysicalDeviceSubgroupSizeControlFeaturesEXT = ^PVkPhysicalDeviceSubgroupSizeControlFeaturesEXT;
VkPhysicalDeviceSubgroupSizeControlFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  subgroupSizeControl: VkBool32;
  computeFullSubgroups: VkBool32;
end;


PVkPhysicalDeviceSubgroupSizeControlPropertiesEXT  =  ^VkPhysicalDeviceSubgroupSizeControlPropertiesEXT;
PPVkPhysicalDeviceSubgroupSizeControlPropertiesEXT = ^PVkPhysicalDeviceSubgroupSizeControlPropertiesEXT;
VkPhysicalDeviceSubgroupSizeControlPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  minSubgroupSize: UInt32;
  maxSubgroupSize: UInt32;
  maxComputeWorkgroupSubgroups: UInt32;
  requiredSubgroupSizeStages: VkShaderStageFlags;
end;


PVkPipelineShaderStageRequiredSubgroupSizeCreateInfoEXT  =  ^VkPipelineShaderStageRequiredSubgroupSizeCreateInfoEXT;
PPVkPipelineShaderStageRequiredSubgroupSizeCreateInfoEXT = ^PVkPipelineShaderStageRequiredSubgroupSizeCreateInfoEXT;
VkPipelineShaderStageRequiredSubgroupSizeCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  requiredSubgroupSize: UInt32;
end;


PVkSubpassShadingPipelineCreateInfoHUAWEI  =  ^VkSubpassShadingPipelineCreateInfoHUAWEI;
PPVkSubpassShadingPipelineCreateInfoHUAWEI = ^PVkSubpassShadingPipelineCreateInfoHUAWEI;
VkSubpassShadingPipelineCreateInfoHUAWEI = record
  sType: VkStructureType;
  pNext: Pointer;
  renderPass: VkRenderPass;
  subpass: UInt32;
end;


PVkPhysicalDeviceSubpassShadingPropertiesHUAWEI  =  ^VkPhysicalDeviceSubpassShadingPropertiesHUAWEI;
PPVkPhysicalDeviceSubpassShadingPropertiesHUAWEI = ^PVkPhysicalDeviceSubpassShadingPropertiesHUAWEI;
VkPhysicalDeviceSubpassShadingPropertiesHUAWEI = record
  sType: VkStructureType;
  pNext: Pointer;
  maxSubpassShadingWorkgroupSizeAspectRatio: UInt32;
end;


PVkMemoryOpaqueCaptureAddressAllocateInfo  =  ^VkMemoryOpaqueCaptureAddressAllocateInfo;
PPVkMemoryOpaqueCaptureAddressAllocateInfo = ^PVkMemoryOpaqueCaptureAddressAllocateInfo;
VkMemoryOpaqueCaptureAddressAllocateInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  opaqueCaptureAddress: UInt64;
end;


PVkDeviceMemoryOpaqueCaptureAddressInfo  =  ^VkDeviceMemoryOpaqueCaptureAddressInfo;
PPVkDeviceMemoryOpaqueCaptureAddressInfo = ^PVkDeviceMemoryOpaqueCaptureAddressInfo;
VkDeviceMemoryOpaqueCaptureAddressInfo = record
  sType: VkStructureType;
  pNext: Pointer;
  memory: VkDeviceMemory;
end;


PVkPhysicalDeviceLineRasterizationFeaturesEXT  =  ^VkPhysicalDeviceLineRasterizationFeaturesEXT;
PPVkPhysicalDeviceLineRasterizationFeaturesEXT = ^PVkPhysicalDeviceLineRasterizationFeaturesEXT;
VkPhysicalDeviceLineRasterizationFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  rectangularLines: VkBool32;
  bresenhamLines: VkBool32;
  smoothLines: VkBool32;
  stippledRectangularLines: VkBool32;
  stippledBresenhamLines: VkBool32;
  stippledSmoothLines: VkBool32;
end;


PVkPhysicalDeviceLineRasterizationPropertiesEXT  =  ^VkPhysicalDeviceLineRasterizationPropertiesEXT;
PPVkPhysicalDeviceLineRasterizationPropertiesEXT = ^PVkPhysicalDeviceLineRasterizationPropertiesEXT;
VkPhysicalDeviceLineRasterizationPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  lineSubPixelPrecisionBits: UInt32;
end;


PVkPipelineRasterizationLineStateCreateInfoEXT  =  ^VkPipelineRasterizationLineStateCreateInfoEXT;
PPVkPipelineRasterizationLineStateCreateInfoEXT = ^PVkPipelineRasterizationLineStateCreateInfoEXT;
VkPipelineRasterizationLineStateCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  lineRasterizationMode: VkLineRasterizationModeEXT;
  stippledLineEnable: VkBool32;
  lineStippleFactor: UInt32;
  lineStipplePattern: UInt16;
end;


PVkPhysicalDevicePipelineCreationCacheControlFeaturesEXT  =  ^VkPhysicalDevicePipelineCreationCacheControlFeaturesEXT;
PPVkPhysicalDevicePipelineCreationCacheControlFeaturesEXT = ^PVkPhysicalDevicePipelineCreationCacheControlFeaturesEXT;
VkPhysicalDevicePipelineCreationCacheControlFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  pipelineCreationCacheControl: VkBool32;
end;


PVkPhysicalDeviceVulkan11Features  =  ^VkPhysicalDeviceVulkan11Features;
PPVkPhysicalDeviceVulkan11Features = ^PVkPhysicalDeviceVulkan11Features;
VkPhysicalDeviceVulkan11Features = record
  sType: VkStructureType;
  pNext: Pointer;
  storageBuffer16BitAccess: VkBool32;
  uniformAndStorageBuffer16BitAccess: VkBool32;
  storagePushConstant16: VkBool32;
  storageInputOutput16: VkBool32;
  multiview: VkBool32;
  multiviewGeometryShader: VkBool32;
  multiviewTessellationShader: VkBool32;
  variablePointersStorageBuffer: VkBool32;
  variablePointers: VkBool32;
  protectedMemory: VkBool32;
  samplerYcbcrConversion: VkBool32;
  shaderDrawParameters: VkBool32;
end;


PVkPhysicalDeviceVulkan11Properties  =  ^VkPhysicalDeviceVulkan11Properties;
PPVkPhysicalDeviceVulkan11Properties = ^PVkPhysicalDeviceVulkan11Properties;
VkPhysicalDeviceVulkan11Properties = record
  sType: VkStructureType;
  pNext: Pointer;
  deviceUUID: array[0 .. VK_UUID_SIZE - 1] of UInt8;
  driverUUID: array[0 .. VK_UUID_SIZE - 1] of UInt8;
  deviceLUID: array[0 .. VK_LUID_SIZE - 1] of UInt8;
  deviceNodeMask: UInt32;
  deviceLUIDValid: VkBool32;
  subgroupSize: UInt32;
  subgroupSupportedStages: VkShaderStageFlags;
  subgroupSupportedOperations: VkSubgroupFeatureFlags;
  subgroupQuadOperationsInAllStages: VkBool32;
  pointClippingBehavior: VkPointClippingBehavior;
  maxMultiviewViewCount: UInt32;
  maxMultiviewInstanceIndex: UInt32;
  protectedNoFault: VkBool32;
  maxPerSetDescriptors: UInt32;
  maxMemoryAllocationSize: VkDeviceSize;
end;


PVkPhysicalDeviceVulkan12Features  =  ^VkPhysicalDeviceVulkan12Features;
PPVkPhysicalDeviceVulkan12Features = ^PVkPhysicalDeviceVulkan12Features;
VkPhysicalDeviceVulkan12Features = record
  sType: VkStructureType;
  pNext: Pointer;
  samplerMirrorClampToEdge: VkBool32;
  drawIndirectCount: VkBool32;
  storageBuffer8BitAccess: VkBool32;
  uniformAndStorageBuffer8BitAccess: VkBool32;
  storagePushConstant8: VkBool32;
  shaderBufferInt64Atomics: VkBool32;
  shaderSharedInt64Atomics: VkBool32;
  shaderFloat16: VkBool32;
  shaderInt8: VkBool32;
  descriptorIndexing: VkBool32;
  shaderInputAttachmentArrayDynamicIndexing: VkBool32;
  shaderUniformTexelBufferArrayDynamicIndexing: VkBool32;
  shaderStorageTexelBufferArrayDynamicIndexing: VkBool32;
  shaderUniformBufferArrayNonUniformIndexing: VkBool32;
  shaderSampledImageArrayNonUniformIndexing: VkBool32;
  shaderStorageBufferArrayNonUniformIndexing: VkBool32;
  shaderStorageImageArrayNonUniformIndexing: VkBool32;
  shaderInputAttachmentArrayNonUniformIndexing: VkBool32;
  shaderUniformTexelBufferArrayNonUniformIndexing: VkBool32;
  shaderStorageTexelBufferArrayNonUniformIndexing: VkBool32;
  descriptorBindingUniformBufferUpdateAfterBind: VkBool32;
  descriptorBindingSampledImageUpdateAfterBind: VkBool32;
  descriptorBindingStorageImageUpdateAfterBind: VkBool32;
  descriptorBindingStorageBufferUpdateAfterBind: VkBool32;
  descriptorBindingUniformTexelBufferUpdateAfterBind: VkBool32;
  descriptorBindingStorageTexelBufferUpdateAfterBind: VkBool32;
  descriptorBindingUpdateUnusedWhilePending: VkBool32;
  descriptorBindingPartiallyBound: VkBool32;
  descriptorBindingVariableDescriptorCount: VkBool32;
  runtimeDescriptorArray: VkBool32;
  samplerFilterMinmax: VkBool32;
  scalarBlockLayout: VkBool32;
  imagelessFramebuffer: VkBool32;
  uniformBufferStandardLayout: VkBool32;
  shaderSubgroupExtendedTypes: VkBool32;
  separateDepthStencilLayouts: VkBool32;
  hostQueryReset: VkBool32;
  timelineSemaphore: VkBool32;
  bufferDeviceAddress: VkBool32;
  bufferDeviceAddressCaptureReplay: VkBool32;
  bufferDeviceAddressMultiDevice: VkBool32;
  vulkanMemoryModel: VkBool32;
  vulkanMemoryModelDeviceScope: VkBool32;
  vulkanMemoryModelAvailabilityVisibilityChains: VkBool32;
  shaderOutputViewportIndex: VkBool32;
  shaderOutputLayer: VkBool32;
  subgroupBroadcastDynamicId: VkBool32;
end;


PVkPhysicalDeviceVulkan12Properties  =  ^VkPhysicalDeviceVulkan12Properties;
PPVkPhysicalDeviceVulkan12Properties = ^PVkPhysicalDeviceVulkan12Properties;
VkPhysicalDeviceVulkan12Properties = record
  sType: VkStructureType;
  pNext: Pointer;
  driverID: VkDriverId;
  driverName: array[0 .. VK_MAX_DRIVER_NAME_SIZE - 1] of AnsiChar;
  driverInfo: array[0 .. VK_MAX_DRIVER_INFO_SIZE - 1] of AnsiChar;
  conformanceVersion: VkConformanceVersion;
  denormBehaviorIndependence: VkShaderFloatControlsIndependence;
  roundingModeIndependence: VkShaderFloatControlsIndependence;
  shaderSignedZeroInfNanPreserveFloat16: VkBool32;
  shaderSignedZeroInfNanPreserveFloat32: VkBool32;
  shaderSignedZeroInfNanPreserveFloat64: VkBool32;
  shaderDenormPreserveFloat16: VkBool32;
  shaderDenormPreserveFloat32: VkBool32;
  shaderDenormPreserveFloat64: VkBool32;
  shaderDenormFlushToZeroFloat16: VkBool32;
  shaderDenormFlushToZeroFloat32: VkBool32;
  shaderDenormFlushToZeroFloat64: VkBool32;
  shaderRoundingModeRTEFloat16: VkBool32;
  shaderRoundingModeRTEFloat32: VkBool32;
  shaderRoundingModeRTEFloat64: VkBool32;
  shaderRoundingModeRTZFloat16: VkBool32;
  shaderRoundingModeRTZFloat32: VkBool32;
  shaderRoundingModeRTZFloat64: VkBool32;
  maxUpdateAfterBindDescriptorsInAllPools: UInt32;
  shaderUniformBufferArrayNonUniformIndexingNative: VkBool32;
  shaderSampledImageArrayNonUniformIndexingNative: VkBool32;
  shaderStorageBufferArrayNonUniformIndexingNative: VkBool32;
  shaderStorageImageArrayNonUniformIndexingNative: VkBool32;
  shaderInputAttachmentArrayNonUniformIndexingNative: VkBool32;
  robustBufferAccessUpdateAfterBind: VkBool32;
  quadDivergentImplicitLod: VkBool32;
  maxPerStageDescriptorUpdateAfterBindSamplers: UInt32;
  maxPerStageDescriptorUpdateAfterBindUniformBuffers: UInt32;
  maxPerStageDescriptorUpdateAfterBindStorageBuffers: UInt32;
  maxPerStageDescriptorUpdateAfterBindSampledImages: UInt32;
  maxPerStageDescriptorUpdateAfterBindStorageImages: UInt32;
  maxPerStageDescriptorUpdateAfterBindInputAttachments: UInt32;
  maxPerStageUpdateAfterBindResources: UInt32;
  maxDescriptorSetUpdateAfterBindSamplers: UInt32;
  maxDescriptorSetUpdateAfterBindUniformBuffers: UInt32;
  maxDescriptorSetUpdateAfterBindUniformBuffersDynamic: UInt32;
  maxDescriptorSetUpdateAfterBindStorageBuffers: UInt32;
  maxDescriptorSetUpdateAfterBindStorageBuffersDynamic: UInt32;
  maxDescriptorSetUpdateAfterBindSampledImages: UInt32;
  maxDescriptorSetUpdateAfterBindStorageImages: UInt32;
  maxDescriptorSetUpdateAfterBindInputAttachments: UInt32;
  supportedDepthResolveModes: VkResolveModeFlags;
  supportedStencilResolveModes: VkResolveModeFlags;
  independentResolveNone: VkBool32;
  independentResolve: VkBool32;
  filterMinmaxSingleComponentFormats: VkBool32;
  filterMinmaxImageComponentMapping: VkBool32;
  maxTimelineSemaphoreValueDifference: UInt64;
  framebufferIntegerColorSampleCounts: VkSampleCountFlags;
end;


PVkPipelineCompilerControlCreateInfoAMD  =  ^VkPipelineCompilerControlCreateInfoAMD;
PPVkPipelineCompilerControlCreateInfoAMD = ^PVkPipelineCompilerControlCreateInfoAMD;
VkPipelineCompilerControlCreateInfoAMD = record
  sType: VkStructureType;
  pNext: Pointer;
  compilerControlFlags: VkPipelineCompilerControlFlagsAMD;
end;


PVkPhysicalDeviceCoherentMemoryFeaturesAMD  =  ^VkPhysicalDeviceCoherentMemoryFeaturesAMD;
PPVkPhysicalDeviceCoherentMemoryFeaturesAMD = ^PVkPhysicalDeviceCoherentMemoryFeaturesAMD;
VkPhysicalDeviceCoherentMemoryFeaturesAMD = record
  sType: VkStructureType;
  pNext: Pointer;
  deviceCoherentMemory: VkBool32;
end;


PVkPhysicalDeviceToolPropertiesEXT  =  ^VkPhysicalDeviceToolPropertiesEXT;
PPVkPhysicalDeviceToolPropertiesEXT = ^PVkPhysicalDeviceToolPropertiesEXT;
VkPhysicalDeviceToolPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  name: array[0 .. VK_MAX_EXTENSION_NAME_SIZE - 1] of AnsiChar;
  version: array[0 .. VK_MAX_EXTENSION_NAME_SIZE - 1] of AnsiChar;
  purposes: VkToolPurposeFlagsEXT;
  description: array[0 .. VK_MAX_DESCRIPTION_SIZE - 1] of AnsiChar;
  layer: array[0 .. VK_MAX_EXTENSION_NAME_SIZE - 1] of AnsiChar;
end;


PVkSamplerCustomBorderColorCreateInfoEXT  =  ^VkSamplerCustomBorderColorCreateInfoEXT;
PPVkSamplerCustomBorderColorCreateInfoEXT = ^PVkSamplerCustomBorderColorCreateInfoEXT;
VkSamplerCustomBorderColorCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  customBorderColor: VkClearColorValue;
  format: VkFormat;
end;


PVkPhysicalDeviceCustomBorderColorPropertiesEXT  =  ^VkPhysicalDeviceCustomBorderColorPropertiesEXT;
PPVkPhysicalDeviceCustomBorderColorPropertiesEXT = ^PVkPhysicalDeviceCustomBorderColorPropertiesEXT;
VkPhysicalDeviceCustomBorderColorPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  maxCustomBorderColorSamplers: UInt32;
end;


PVkPhysicalDeviceCustomBorderColorFeaturesEXT  =  ^VkPhysicalDeviceCustomBorderColorFeaturesEXT;
PPVkPhysicalDeviceCustomBorderColorFeaturesEXT = ^PVkPhysicalDeviceCustomBorderColorFeaturesEXT;
VkPhysicalDeviceCustomBorderColorFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  customBorderColors: VkBool32;
  customBorderColorWithoutFormat: VkBool32;
end;


PVkDeviceOrHostAddressKHR  =  ^VkDeviceOrHostAddressKHR;
PPVkDeviceOrHostAddressKHR = ^PVkDeviceOrHostAddressKHR;
VkDeviceOrHostAddressKHR = record
case Byte of
  0: (deviceAddress: VkDeviceAddress);
  1: (hostAddress: Pointer);
end;


PVkDeviceOrHostAddressConstKHR  =  ^VkDeviceOrHostAddressConstKHR;
PPVkDeviceOrHostAddressConstKHR = ^PVkDeviceOrHostAddressConstKHR;
VkDeviceOrHostAddressConstKHR = record
case Byte of
  0: (deviceAddress: VkDeviceAddress);
  1: (hostAddress: Pointer);
end;


PVkAccelerationStructureGeometryTrianglesDataKHR  =  ^VkAccelerationStructureGeometryTrianglesDataKHR;
PPVkAccelerationStructureGeometryTrianglesDataKHR = ^PVkAccelerationStructureGeometryTrianglesDataKHR;
VkAccelerationStructureGeometryTrianglesDataKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  vertexFormat: VkFormat;
  vertexData: VkDeviceOrHostAddressConstKHR;
  vertexStride: VkDeviceSize;
  maxVertex: UInt32;
  indexType: VkIndexType;
  indexData: VkDeviceOrHostAddressConstKHR;
  transformData: VkDeviceOrHostAddressConstKHR;
end;


PVkAccelerationStructureGeometryAabbsDataKHR  =  ^VkAccelerationStructureGeometryAabbsDataKHR;
PPVkAccelerationStructureGeometryAabbsDataKHR = ^PVkAccelerationStructureGeometryAabbsDataKHR;
VkAccelerationStructureGeometryAabbsDataKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  data: VkDeviceOrHostAddressConstKHR;
  stride: VkDeviceSize;
end;


PVkAccelerationStructureGeometryInstancesDataKHR  =  ^VkAccelerationStructureGeometryInstancesDataKHR;
PPVkAccelerationStructureGeometryInstancesDataKHR = ^PVkAccelerationStructureGeometryInstancesDataKHR;
VkAccelerationStructureGeometryInstancesDataKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  arrayOfPointers: VkBool32;
  data: VkDeviceOrHostAddressConstKHR;
end;


PVkAccelerationStructureGeometryDataKHR  =  ^VkAccelerationStructureGeometryDataKHR;
PPVkAccelerationStructureGeometryDataKHR = ^PVkAccelerationStructureGeometryDataKHR;
VkAccelerationStructureGeometryDataKHR = record
case Byte of
  0: (triangles: VkAccelerationStructureGeometryTrianglesDataKHR);
  1: (aabbs: VkAccelerationStructureGeometryAabbsDataKHR);
  2: (instances: VkAccelerationStructureGeometryInstancesDataKHR);
end;


PVkAccelerationStructureGeometryKHR  =  ^VkAccelerationStructureGeometryKHR;
PPVkAccelerationStructureGeometryKHR = ^PVkAccelerationStructureGeometryKHR;
VkAccelerationStructureGeometryKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  geometryType: VkGeometryTypeKHR;
  geometry: VkAccelerationStructureGeometryDataKHR;
  flags: VkGeometryFlagsKHR;
end;


PVkAccelerationStructureBuildGeometryInfoKHR  =  ^VkAccelerationStructureBuildGeometryInfoKHR;
PPVkAccelerationStructureBuildGeometryInfoKHR = ^PVkAccelerationStructureBuildGeometryInfoKHR;
VkAccelerationStructureBuildGeometryInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  _type: VkAccelerationStructureTypeKHR;
  flags: VkBuildAccelerationStructureFlagsKHR;
  mode: VkBuildAccelerationStructureModeKHR;
  srcAccelerationStructure: VkAccelerationStructureKHR;
  dstAccelerationStructure: VkAccelerationStructureKHR;
  geometryCount: UInt32;
  pGeometries: PVkAccelerationStructureGeometryKHR;
  ppGeometries: PPVkAccelerationStructureGeometryKHR;
  scratchData: VkDeviceOrHostAddressKHR;
end;


PVkAccelerationStructureBuildRangeInfoKHR  =  ^VkAccelerationStructureBuildRangeInfoKHR;
PPVkAccelerationStructureBuildRangeInfoKHR = ^PVkAccelerationStructureBuildRangeInfoKHR;
VkAccelerationStructureBuildRangeInfoKHR = record
  primitiveCount: UInt32;
  primitiveOffset: UInt32;
  firstVertex: UInt32;
  transformOffset: UInt32;
end;


PVkAccelerationStructureCreateInfoKHR  =  ^VkAccelerationStructureCreateInfoKHR;
PPVkAccelerationStructureCreateInfoKHR = ^PVkAccelerationStructureCreateInfoKHR;
VkAccelerationStructureCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  createFlags: VkAccelerationStructureCreateFlagsKHR;
  buffer: VkBuffer;
  offset: VkDeviceSize;
  size: VkDeviceSize;
  _type: VkAccelerationStructureTypeKHR;
  deviceAddress: VkDeviceAddress;
end;


PVkAabbPositionsKHR  =  ^VkAabbPositionsKHR;
PPVkAabbPositionsKHR = ^PVkAabbPositionsKHR;
VkAabbPositionsKHR = record
  minX: Single;
  minY: Single;
  minZ: Single;
  maxX: Single;
  maxY: Single;
  maxZ: Single;
end;


PVkTransformMatrixKHR  =  ^VkTransformMatrixKHR;
PPVkTransformMatrixKHR = ^PVkTransformMatrixKHR;
VkTransformMatrixKHR = record
  matrix: array[0 .. 3 - 1] of array[0 .. 4 - 1] of Single;
end;


PVkAccelerationStructureInstanceKHR  =  ^VkAccelerationStructureInstanceKHR;
PPVkAccelerationStructureInstanceKHR = ^PVkAccelerationStructureInstanceKHR;
VkAccelerationStructureInstanceKHR = record
  transform: VkTransformMatrixKHR;
  instanceCustomIndex: UInt32;
  mask: UInt32;
  instanceShaderBindingTableRecordOffset: UInt32;
  flags: VkGeometryInstanceFlagsKHR;
  accelerationStructureReference: UInt64;
end;


PVkAccelerationStructureDeviceAddressInfoKHR  =  ^VkAccelerationStructureDeviceAddressInfoKHR;
PPVkAccelerationStructureDeviceAddressInfoKHR = ^PVkAccelerationStructureDeviceAddressInfoKHR;
VkAccelerationStructureDeviceAddressInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  accelerationStructure: VkAccelerationStructureKHR;
end;


PVkAccelerationStructureVersionInfoKHR  =  ^VkAccelerationStructureVersionInfoKHR;
PPVkAccelerationStructureVersionInfoKHR = ^PVkAccelerationStructureVersionInfoKHR;
VkAccelerationStructureVersionInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  pVersionData: PUInt8;
end;


PVkCopyAccelerationStructureInfoKHR  =  ^VkCopyAccelerationStructureInfoKHR;
PPVkCopyAccelerationStructureInfoKHR = ^PVkCopyAccelerationStructureInfoKHR;
VkCopyAccelerationStructureInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  src: VkAccelerationStructureKHR;
  dst: VkAccelerationStructureKHR;
  mode: VkCopyAccelerationStructureModeKHR;
end;


PVkCopyAccelerationStructureToMemoryInfoKHR  =  ^VkCopyAccelerationStructureToMemoryInfoKHR;
PPVkCopyAccelerationStructureToMemoryInfoKHR = ^PVkCopyAccelerationStructureToMemoryInfoKHR;
VkCopyAccelerationStructureToMemoryInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  src: VkAccelerationStructureKHR;
  dst: VkDeviceOrHostAddressKHR;
  mode: VkCopyAccelerationStructureModeKHR;
end;


PVkCopyMemoryToAccelerationStructureInfoKHR  =  ^VkCopyMemoryToAccelerationStructureInfoKHR;
PPVkCopyMemoryToAccelerationStructureInfoKHR = ^PVkCopyMemoryToAccelerationStructureInfoKHR;
VkCopyMemoryToAccelerationStructureInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  src: VkDeviceOrHostAddressConstKHR;
  dst: VkAccelerationStructureKHR;
  mode: VkCopyAccelerationStructureModeKHR;
end;


PPVkRayTracingPipelineInterfaceCreateInfoKHR = ^PVkRayTracingPipelineInterfaceCreateInfoKHR;
VkRayTracingPipelineInterfaceCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  maxPipelineRayPayloadSize: UInt32;
  maxPipelineRayHitAttributeSize: UInt32;
end;


PPVkPipelineLibraryCreateInfoKHR = ^PVkPipelineLibraryCreateInfoKHR;
VkPipelineLibraryCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  libraryCount: UInt32;
  pLibraries: PVkPipeline;
end;


PVkPhysicalDeviceExtendedDynamicStateFeaturesEXT  =  ^VkPhysicalDeviceExtendedDynamicStateFeaturesEXT;
PPVkPhysicalDeviceExtendedDynamicStateFeaturesEXT = ^PVkPhysicalDeviceExtendedDynamicStateFeaturesEXT;
VkPhysicalDeviceExtendedDynamicStateFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  extendedDynamicState: VkBool32;
end;


PVkPhysicalDeviceExtendedDynamicState2FeaturesEXT  =  ^VkPhysicalDeviceExtendedDynamicState2FeaturesEXT;
PPVkPhysicalDeviceExtendedDynamicState2FeaturesEXT = ^PVkPhysicalDeviceExtendedDynamicState2FeaturesEXT;
VkPhysicalDeviceExtendedDynamicState2FeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  extendedDynamicState2: VkBool32;
  extendedDynamicState2LogicOp: VkBool32;
  extendedDynamicState2PatchControlPoints: VkBool32;
end;


PVkRenderPassTransformBeginInfoQCOM  =  ^VkRenderPassTransformBeginInfoQCOM;
PPVkRenderPassTransformBeginInfoQCOM = ^PVkRenderPassTransformBeginInfoQCOM;
VkRenderPassTransformBeginInfoQCOM = record
  sType: VkStructureType;
  pNext: Pointer;
  transform: VkSurfaceTransformFlagBitsKHR;
end;


PVkCopyCommandTransformInfoQCOM  =  ^VkCopyCommandTransformInfoQCOM;
PPVkCopyCommandTransformInfoQCOM = ^PVkCopyCommandTransformInfoQCOM;
VkCopyCommandTransformInfoQCOM = record
  sType: VkStructureType;
  pNext: Pointer;
  transform: VkSurfaceTransformFlagBitsKHR;
end;


PVkCommandBufferInheritanceRenderPassTransformInfoQCOM  =  ^VkCommandBufferInheritanceRenderPassTransformInfoQCOM;
PPVkCommandBufferInheritanceRenderPassTransformInfoQCOM = ^PVkCommandBufferInheritanceRenderPassTransformInfoQCOM;
VkCommandBufferInheritanceRenderPassTransformInfoQCOM = record
  sType: VkStructureType;
  pNext: Pointer;
  transform: VkSurfaceTransformFlagBitsKHR;
  renderArea: VkRect2D;
end;


PVkPhysicalDeviceDiagnosticsConfigFeaturesNV  =  ^VkPhysicalDeviceDiagnosticsConfigFeaturesNV;
PPVkPhysicalDeviceDiagnosticsConfigFeaturesNV = ^PVkPhysicalDeviceDiagnosticsConfigFeaturesNV;
VkPhysicalDeviceDiagnosticsConfigFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  diagnosticsConfig: VkBool32;
end;


PVkDeviceDiagnosticsConfigCreateInfoNV  =  ^VkDeviceDiagnosticsConfigCreateInfoNV;
PPVkDeviceDiagnosticsConfigCreateInfoNV = ^PVkDeviceDiagnosticsConfigCreateInfoNV;
VkDeviceDiagnosticsConfigCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkDeviceDiagnosticsConfigFlagsNV;
end;


PVkPhysicalDeviceZeroInitializeWorkgroupMemoryFeaturesKHR  =  ^VkPhysicalDeviceZeroInitializeWorkgroupMemoryFeaturesKHR;
PPVkPhysicalDeviceZeroInitializeWorkgroupMemoryFeaturesKHR = ^PVkPhysicalDeviceZeroInitializeWorkgroupMemoryFeaturesKHR;
VkPhysicalDeviceZeroInitializeWorkgroupMemoryFeaturesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderZeroInitializeWorkgroupMemory: VkBool32;
end;


PVkPhysicalDeviceShaderSubgroupUniformControlFlowFeaturesKHR  =  ^VkPhysicalDeviceShaderSubgroupUniformControlFlowFeaturesKHR;
PPVkPhysicalDeviceShaderSubgroupUniformControlFlowFeaturesKHR = ^PVkPhysicalDeviceShaderSubgroupUniformControlFlowFeaturesKHR;
VkPhysicalDeviceShaderSubgroupUniformControlFlowFeaturesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderSubgroupUniformControlFlow: VkBool32;
end;


PVkPhysicalDeviceRobustness2FeaturesEXT  =  ^VkPhysicalDeviceRobustness2FeaturesEXT;
PPVkPhysicalDeviceRobustness2FeaturesEXT = ^PVkPhysicalDeviceRobustness2FeaturesEXT;
VkPhysicalDeviceRobustness2FeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  robustBufferAccess2: VkBool32;
  robustImageAccess2: VkBool32;
  nullDescriptor: VkBool32;
end;


PVkPhysicalDeviceRobustness2PropertiesEXT  =  ^VkPhysicalDeviceRobustness2PropertiesEXT;
PPVkPhysicalDeviceRobustness2PropertiesEXT = ^PVkPhysicalDeviceRobustness2PropertiesEXT;
VkPhysicalDeviceRobustness2PropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  robustStorageBufferAccessSizeAlignment: VkDeviceSize;
  robustUniformBufferAccessSizeAlignment: VkDeviceSize;
end;


PVkPhysicalDeviceImageRobustnessFeaturesEXT  =  ^VkPhysicalDeviceImageRobustnessFeaturesEXT;
PPVkPhysicalDeviceImageRobustnessFeaturesEXT = ^PVkPhysicalDeviceImageRobustnessFeaturesEXT;
VkPhysicalDeviceImageRobustnessFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  robustImageAccess: VkBool32;
end;


PVkPhysicalDeviceWorkgroupMemoryExplicitLayoutFeaturesKHR  =  ^VkPhysicalDeviceWorkgroupMemoryExplicitLayoutFeaturesKHR;
PPVkPhysicalDeviceWorkgroupMemoryExplicitLayoutFeaturesKHR = ^PVkPhysicalDeviceWorkgroupMemoryExplicitLayoutFeaturesKHR;
VkPhysicalDeviceWorkgroupMemoryExplicitLayoutFeaturesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  workgroupMemoryExplicitLayout: VkBool32;
  workgroupMemoryExplicitLayoutScalarBlockLayout: VkBool32;
  workgroupMemoryExplicitLayout8BitAccess: VkBool32;
  workgroupMemoryExplicitLayout16BitAccess: VkBool32;
end;


PVkPhysicalDevicePortabilitySubsetFeaturesKHR  =  ^VkPhysicalDevicePortabilitySubsetFeaturesKHR;
PPVkPhysicalDevicePortabilitySubsetFeaturesKHR = ^PVkPhysicalDevicePortabilitySubsetFeaturesKHR;
VkPhysicalDevicePortabilitySubsetFeaturesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  constantAlphaColorBlendFactors: VkBool32;
  events: VkBool32;
  imageViewFormatReinterpretation: VkBool32;
  imageViewFormatSwizzle: VkBool32;
  imageView2DOn3DImage: VkBool32;
  multisampleArrayImage: VkBool32;
  mutableComparisonSamplers: VkBool32;
  pointPolygons: VkBool32;
  samplerMipLodBias: VkBool32;
  separateStencilMaskRef: VkBool32;
  shaderSampleRateInterpolationFunctions: VkBool32;
  tessellationIsolines: VkBool32;
  tessellationPointMode: VkBool32;
  triangleFans: VkBool32;
  vertexAttributeAccessBeyondStride: VkBool32;
end;


PVkPhysicalDevicePortabilitySubsetPropertiesKHR  =  ^VkPhysicalDevicePortabilitySubsetPropertiesKHR;
PPVkPhysicalDevicePortabilitySubsetPropertiesKHR = ^PVkPhysicalDevicePortabilitySubsetPropertiesKHR;
VkPhysicalDevicePortabilitySubsetPropertiesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  minVertexInputBindingStrideAlignment: UInt32;
end;


PVkPhysicalDevice4444FormatsFeaturesEXT  =  ^VkPhysicalDevice4444FormatsFeaturesEXT;
PPVkPhysicalDevice4444FormatsFeaturesEXT = ^PVkPhysicalDevice4444FormatsFeaturesEXT;
VkPhysicalDevice4444FormatsFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  formatA4R4G4B4: VkBool32;
  formatA4B4G4R4: VkBool32;
end;


PVkPhysicalDeviceSubpassShadingFeaturesHUAWEI  =  ^VkPhysicalDeviceSubpassShadingFeaturesHUAWEI;
PPVkPhysicalDeviceSubpassShadingFeaturesHUAWEI = ^PVkPhysicalDeviceSubpassShadingFeaturesHUAWEI;
VkPhysicalDeviceSubpassShadingFeaturesHUAWEI = record
  sType: VkStructureType;
  pNext: Pointer;
  subpassShading: VkBool32;
end;


PVkBufferCopy2KHR  =  ^VkBufferCopy2KHR;
PPVkBufferCopy2KHR = ^PVkBufferCopy2KHR;
VkBufferCopy2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  srcOffset: VkDeviceSize;
  dstOffset: VkDeviceSize;
  size: VkDeviceSize;
end;


PVkImageCopy2KHR  =  ^VkImageCopy2KHR;
PPVkImageCopy2KHR = ^PVkImageCopy2KHR;
VkImageCopy2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  srcSubresource: VkImageSubresourceLayers;
  srcOffset: VkOffset3D;
  dstSubresource: VkImageSubresourceLayers;
  dstOffset: VkOffset3D;
  extent: VkExtent3D;
end;


PVkImageBlit2KHR  =  ^VkImageBlit2KHR;
PPVkImageBlit2KHR = ^PVkImageBlit2KHR;
VkImageBlit2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  srcSubresource: VkImageSubresourceLayers;
  srcOffsets: array[0 .. 2 - 1] of VkOffset3D;
  dstSubresource: VkImageSubresourceLayers;
  dstOffsets: array[0 .. 2 - 1] of VkOffset3D;
end;


PVkBufferImageCopy2KHR  =  ^VkBufferImageCopy2KHR;
PPVkBufferImageCopy2KHR = ^PVkBufferImageCopy2KHR;
VkBufferImageCopy2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  bufferOffset: VkDeviceSize;
  bufferRowLength: UInt32;
  bufferImageHeight: UInt32;
  imageSubresource: VkImageSubresourceLayers;
  imageOffset: VkOffset3D;
  imageExtent: VkExtent3D;
end;


PVkImageResolve2KHR  =  ^VkImageResolve2KHR;
PPVkImageResolve2KHR = ^PVkImageResolve2KHR;
VkImageResolve2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  srcSubresource: VkImageSubresourceLayers;
  srcOffset: VkOffset3D;
  dstSubresource: VkImageSubresourceLayers;
  dstOffset: VkOffset3D;
  extent: VkExtent3D;
end;


PVkCopyBufferInfo2KHR  =  ^VkCopyBufferInfo2KHR;
PPVkCopyBufferInfo2KHR = ^PVkCopyBufferInfo2KHR;
VkCopyBufferInfo2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  srcBuffer: VkBuffer;
  dstBuffer: VkBuffer;
  regionCount: UInt32;
  pRegions: PVkBufferCopy2KHR;
end;


PVkCopyImageInfo2KHR  =  ^VkCopyImageInfo2KHR;
PPVkCopyImageInfo2KHR = ^PVkCopyImageInfo2KHR;
VkCopyImageInfo2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  srcImage: VkImage;
  srcImageLayout: VkImageLayout;
  dstImage: VkImage;
  dstImageLayout: VkImageLayout;
  regionCount: UInt32;
  pRegions: PVkImageCopy2KHR;
end;


PVkBlitImageInfo2KHR  =  ^VkBlitImageInfo2KHR;
PPVkBlitImageInfo2KHR = ^PVkBlitImageInfo2KHR;
VkBlitImageInfo2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  srcImage: VkImage;
  srcImageLayout: VkImageLayout;
  dstImage: VkImage;
  dstImageLayout: VkImageLayout;
  regionCount: UInt32;
  pRegions: PVkImageBlit2KHR;
  filter: VkFilter;
end;


PVkCopyBufferToImageInfo2KHR  =  ^VkCopyBufferToImageInfo2KHR;
PPVkCopyBufferToImageInfo2KHR = ^PVkCopyBufferToImageInfo2KHR;
VkCopyBufferToImageInfo2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  srcBuffer: VkBuffer;
  dstImage: VkImage;
  dstImageLayout: VkImageLayout;
  regionCount: UInt32;
  pRegions: PVkBufferImageCopy2KHR;
end;


PVkCopyImageToBufferInfo2KHR  =  ^VkCopyImageToBufferInfo2KHR;
PPVkCopyImageToBufferInfo2KHR = ^PVkCopyImageToBufferInfo2KHR;
VkCopyImageToBufferInfo2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  srcImage: VkImage;
  srcImageLayout: VkImageLayout;
  dstBuffer: VkBuffer;
  regionCount: UInt32;
  pRegions: PVkBufferImageCopy2KHR;
end;


PVkResolveImageInfo2KHR  =  ^VkResolveImageInfo2KHR;
PPVkResolveImageInfo2KHR = ^PVkResolveImageInfo2KHR;
VkResolveImageInfo2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  srcImage: VkImage;
  srcImageLayout: VkImageLayout;
  dstImage: VkImage;
  dstImageLayout: VkImageLayout;
  regionCount: UInt32;
  pRegions: PVkImageResolve2KHR;
end;


PVkPhysicalDeviceShaderImageAtomicInt64FeaturesEXT  =  ^VkPhysicalDeviceShaderImageAtomicInt64FeaturesEXT;
PPVkPhysicalDeviceShaderImageAtomicInt64FeaturesEXT = ^PVkPhysicalDeviceShaderImageAtomicInt64FeaturesEXT;
VkPhysicalDeviceShaderImageAtomicInt64FeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderImageInt64Atomics: VkBool32;
  sparseImageInt64Atomics: VkBool32;
end;


PVkFragmentShadingRateAttachmentInfoKHR  =  ^VkFragmentShadingRateAttachmentInfoKHR;
PPVkFragmentShadingRateAttachmentInfoKHR = ^PVkFragmentShadingRateAttachmentInfoKHR;
VkFragmentShadingRateAttachmentInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  pFragmentShadingRateAttachment: PVkAttachmentReference2;
  shadingRateAttachmentTexelSize: VkExtent2D;
end;


PVkPipelineFragmentShadingRateStateCreateInfoKHR  =  ^VkPipelineFragmentShadingRateStateCreateInfoKHR;
PPVkPipelineFragmentShadingRateStateCreateInfoKHR = ^PVkPipelineFragmentShadingRateStateCreateInfoKHR;
VkPipelineFragmentShadingRateStateCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  fragmentSize: VkExtent2D;
  combinerOps: array[0 .. 2 - 1] of VkFragmentShadingRateCombinerOpKHR;
end;


PVkPhysicalDeviceFragmentShadingRateFeaturesKHR  =  ^VkPhysicalDeviceFragmentShadingRateFeaturesKHR;
PPVkPhysicalDeviceFragmentShadingRateFeaturesKHR = ^PVkPhysicalDeviceFragmentShadingRateFeaturesKHR;
VkPhysicalDeviceFragmentShadingRateFeaturesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  pipelineFragmentShadingRate: VkBool32;
  primitiveFragmentShadingRate: VkBool32;
  attachmentFragmentShadingRate: VkBool32;
end;


PVkPhysicalDeviceFragmentShadingRatePropertiesKHR  =  ^VkPhysicalDeviceFragmentShadingRatePropertiesKHR;
PPVkPhysicalDeviceFragmentShadingRatePropertiesKHR = ^PVkPhysicalDeviceFragmentShadingRatePropertiesKHR;
VkPhysicalDeviceFragmentShadingRatePropertiesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  minFragmentShadingRateAttachmentTexelSize: VkExtent2D;
  maxFragmentShadingRateAttachmentTexelSize: VkExtent2D;
  maxFragmentShadingRateAttachmentTexelSizeAspectRatio: UInt32;
  primitiveFragmentShadingRateWithMultipleViewports: VkBool32;
  layeredShadingRateAttachments: VkBool32;
  fragmentShadingRateNonTrivialCombinerOps: VkBool32;
  maxFragmentSize: VkExtent2D;
  maxFragmentSizeAspectRatio: UInt32;
  maxFragmentShadingRateCoverageSamples: UInt32;
  maxFragmentShadingRateRasterizationSamples: VkSampleCountFlagBits;
  fragmentShadingRateWithShaderDepthStencilWrites: VkBool32;
  fragmentShadingRateWithSampleMask: VkBool32;
  fragmentShadingRateWithShaderSampleMask: VkBool32;
  fragmentShadingRateWithConservativeRasterization: VkBool32;
  fragmentShadingRateWithFragmentShaderInterlock: VkBool32;
  fragmentShadingRateWithCustomSampleLocations: VkBool32;
  fragmentShadingRateStrictMultiplyCombiner: VkBool32;
end;


PVkPhysicalDeviceFragmentShadingRateKHR  =  ^VkPhysicalDeviceFragmentShadingRateKHR;
PPVkPhysicalDeviceFragmentShadingRateKHR = ^PVkPhysicalDeviceFragmentShadingRateKHR;
VkPhysicalDeviceFragmentShadingRateKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  sampleCounts: VkSampleCountFlags;
  fragmentSize: VkExtent2D;
end;


PVkPhysicalDeviceShaderTerminateInvocationFeaturesKHR  =  ^VkPhysicalDeviceShaderTerminateInvocationFeaturesKHR;
PPVkPhysicalDeviceShaderTerminateInvocationFeaturesKHR = ^PVkPhysicalDeviceShaderTerminateInvocationFeaturesKHR;
VkPhysicalDeviceShaderTerminateInvocationFeaturesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  shaderTerminateInvocation: VkBool32;
end;


PVkPhysicalDeviceFragmentShadingRateEnumsFeaturesNV  =  ^VkPhysicalDeviceFragmentShadingRateEnumsFeaturesNV;
PPVkPhysicalDeviceFragmentShadingRateEnumsFeaturesNV = ^PVkPhysicalDeviceFragmentShadingRateEnumsFeaturesNV;
VkPhysicalDeviceFragmentShadingRateEnumsFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  fragmentShadingRateEnums: VkBool32;
  supersampleFragmentShadingRates: VkBool32;
  noInvocationFragmentShadingRates: VkBool32;
end;


PVkPhysicalDeviceFragmentShadingRateEnumsPropertiesNV  =  ^VkPhysicalDeviceFragmentShadingRateEnumsPropertiesNV;
PPVkPhysicalDeviceFragmentShadingRateEnumsPropertiesNV = ^PVkPhysicalDeviceFragmentShadingRateEnumsPropertiesNV;
VkPhysicalDeviceFragmentShadingRateEnumsPropertiesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  maxFragmentShadingRateInvocationCount: VkSampleCountFlagBits;
end;


PVkPipelineFragmentShadingRateEnumStateCreateInfoNV  =  ^VkPipelineFragmentShadingRateEnumStateCreateInfoNV;
PPVkPipelineFragmentShadingRateEnumStateCreateInfoNV = ^PVkPipelineFragmentShadingRateEnumStateCreateInfoNV;
VkPipelineFragmentShadingRateEnumStateCreateInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  shadingRateType: VkFragmentShadingRateTypeNV;
  shadingRate: VkFragmentShadingRateNV;
  combinerOps: array[0 .. 2 - 1] of VkFragmentShadingRateCombinerOpKHR;
end;


PVkAccelerationStructureBuildSizesInfoKHR  =  ^VkAccelerationStructureBuildSizesInfoKHR;
PPVkAccelerationStructureBuildSizesInfoKHR = ^PVkAccelerationStructureBuildSizesInfoKHR;
VkAccelerationStructureBuildSizesInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  accelerationStructureSize: VkDeviceSize;
  updateScratchSize: VkDeviceSize;
  buildScratchSize: VkDeviceSize;
end;


PVkPhysicalDeviceMutableDescriptorTypeFeaturesVALVE  =  ^VkPhysicalDeviceMutableDescriptorTypeFeaturesVALVE;
PPVkPhysicalDeviceMutableDescriptorTypeFeaturesVALVE = ^PVkPhysicalDeviceMutableDescriptorTypeFeaturesVALVE;
VkPhysicalDeviceMutableDescriptorTypeFeaturesVALVE = record
  sType: VkStructureType;
  pNext: Pointer;
  mutableDescriptorType: VkBool32;
end;


PVkMutableDescriptorTypeListVALVE  =  ^VkMutableDescriptorTypeListVALVE;
PPVkMutableDescriptorTypeListVALVE = ^PVkMutableDescriptorTypeListVALVE;
VkMutableDescriptorTypeListVALVE = record
  descriptorTypeCount: UInt32;
  pDescriptorTypes: PVkDescriptorType;
end;


PVkMutableDescriptorTypeCreateInfoVALVE  =  ^VkMutableDescriptorTypeCreateInfoVALVE;
PPVkMutableDescriptorTypeCreateInfoVALVE = ^PVkMutableDescriptorTypeCreateInfoVALVE;
VkMutableDescriptorTypeCreateInfoVALVE = record
  sType: VkStructureType;
  pNext: Pointer;
  mutableDescriptorTypeListCount: UInt32;
  pMutableDescriptorTypeLists: PVkMutableDescriptorTypeListVALVE;
end;


PVkPhysicalDeviceVertexInputDynamicStateFeaturesEXT  =  ^VkPhysicalDeviceVertexInputDynamicStateFeaturesEXT;
PPVkPhysicalDeviceVertexInputDynamicStateFeaturesEXT = ^PVkPhysicalDeviceVertexInputDynamicStateFeaturesEXT;
VkPhysicalDeviceVertexInputDynamicStateFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  vertexInputDynamicState: VkBool32;
end;


PVkPhysicalDeviceExternalMemoryRDMAFeaturesNV  =  ^VkPhysicalDeviceExternalMemoryRDMAFeaturesNV;
PPVkPhysicalDeviceExternalMemoryRDMAFeaturesNV = ^PVkPhysicalDeviceExternalMemoryRDMAFeaturesNV;
VkPhysicalDeviceExternalMemoryRDMAFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  externalMemoryRDMA: VkBool32;
end;


PVkVertexInputBindingDescription2EXT  =  ^VkVertexInputBindingDescription2EXT;
PPVkVertexInputBindingDescription2EXT = ^PVkVertexInputBindingDescription2EXT;
VkVertexInputBindingDescription2EXT = record
  sType: VkStructureType;
  pNext: Pointer;
  binding: UInt32;
  stride: UInt32;
  inputRate: VkVertexInputRate;
  divisor: UInt32;
end;


PVkVertexInputAttributeDescription2EXT  =  ^VkVertexInputAttributeDescription2EXT;
PPVkVertexInputAttributeDescription2EXT = ^PVkVertexInputAttributeDescription2EXT;
VkVertexInputAttributeDescription2EXT = record
  sType: VkStructureType;
  pNext: Pointer;
  location: UInt32;
  binding: UInt32;
  format: VkFormat;
  offset: UInt32;
end;


PVkPhysicalDeviceColorWriteEnableFeaturesEXT  =  ^VkPhysicalDeviceColorWriteEnableFeaturesEXT;
PPVkPhysicalDeviceColorWriteEnableFeaturesEXT = ^PVkPhysicalDeviceColorWriteEnableFeaturesEXT;
VkPhysicalDeviceColorWriteEnableFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  colorWriteEnable: VkBool32;
end;


PVkPipelineColorWriteCreateInfoEXT  =  ^VkPipelineColorWriteCreateInfoEXT;
PPVkPipelineColorWriteCreateInfoEXT = ^PVkPipelineColorWriteCreateInfoEXT;
VkPipelineColorWriteCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  attachmentCount: UInt32;
  pColorWriteEnables: PVkBool32;
end;


PVkMemoryBarrier2KHR  =  ^VkMemoryBarrier2KHR;
PPVkMemoryBarrier2KHR = ^PVkMemoryBarrier2KHR;
VkMemoryBarrier2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  srcStageMask: VkPipelineStageFlags2KHR;
  srcAccessMask: VkAccessFlags2KHR;
  dstStageMask: VkPipelineStageFlags2KHR;
  dstAccessMask: VkAccessFlags2KHR;
end;


PVkImageMemoryBarrier2KHR  =  ^VkImageMemoryBarrier2KHR;
PPVkImageMemoryBarrier2KHR = ^PVkImageMemoryBarrier2KHR;
VkImageMemoryBarrier2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  srcStageMask: VkPipelineStageFlags2KHR;
  srcAccessMask: VkAccessFlags2KHR;
  dstStageMask: VkPipelineStageFlags2KHR;
  dstAccessMask: VkAccessFlags2KHR;
  oldLayout: VkImageLayout;
  newLayout: VkImageLayout;
  srcQueueFamilyIndex: UInt32;
  dstQueueFamilyIndex: UInt32;
  image: VkImage;
  subresourceRange: VkImageSubresourceRange;
end;


PVkBufferMemoryBarrier2KHR  =  ^VkBufferMemoryBarrier2KHR;
PPVkBufferMemoryBarrier2KHR = ^PVkBufferMemoryBarrier2KHR;
VkBufferMemoryBarrier2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  srcStageMask: VkPipelineStageFlags2KHR;
  srcAccessMask: VkAccessFlags2KHR;
  dstStageMask: VkPipelineStageFlags2KHR;
  dstAccessMask: VkAccessFlags2KHR;
  srcQueueFamilyIndex: UInt32;
  dstQueueFamilyIndex: UInt32;
  buffer: VkBuffer;
  offset: VkDeviceSize;
  size: VkDeviceSize;
end;


PVkDependencyInfoKHR  =  ^VkDependencyInfoKHR;
PPVkDependencyInfoKHR = ^PVkDependencyInfoKHR;
VkDependencyInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  dependencyFlags: VkDependencyFlags;
  memoryBarrierCount: UInt32;
  pMemoryBarriers: PVkMemoryBarrier2KHR;
  bufferMemoryBarrierCount: UInt32;
  pBufferMemoryBarriers: PVkBufferMemoryBarrier2KHR;
  imageMemoryBarrierCount: UInt32;
  pImageMemoryBarriers: PVkImageMemoryBarrier2KHR;
end;


PVkSemaphoreSubmitInfoKHR  =  ^VkSemaphoreSubmitInfoKHR;
PPVkSemaphoreSubmitInfoKHR = ^PVkSemaphoreSubmitInfoKHR;
VkSemaphoreSubmitInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  semaphore: VkSemaphore;
  value: UInt64;
  stageMask: VkPipelineStageFlags2KHR;
  deviceIndex: UInt32;
end;


PVkCommandBufferSubmitInfoKHR  =  ^VkCommandBufferSubmitInfoKHR;
PPVkCommandBufferSubmitInfoKHR = ^PVkCommandBufferSubmitInfoKHR;
VkCommandBufferSubmitInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  commandBuffer: VkCommandBuffer;
  deviceMask: UInt32;
end;


PVkSubmitInfo2KHR  =  ^VkSubmitInfo2KHR;
PPVkSubmitInfo2KHR = ^PVkSubmitInfo2KHR;
VkSubmitInfo2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkSubmitFlagsKHR;
  waitSemaphoreInfoCount: UInt32;
  pWaitSemaphoreInfos: PVkSemaphoreSubmitInfoKHR;
  commandBufferInfoCount: UInt32;
  pCommandBufferInfos: PVkCommandBufferSubmitInfoKHR;
  signalSemaphoreInfoCount: UInt32;
  pSignalSemaphoreInfos: PVkSemaphoreSubmitInfoKHR;
end;


PVkQueueFamilyCheckpointProperties2NV  =  ^VkQueueFamilyCheckpointProperties2NV;
PPVkQueueFamilyCheckpointProperties2NV = ^PVkQueueFamilyCheckpointProperties2NV;
VkQueueFamilyCheckpointProperties2NV = record
  sType: VkStructureType;
  pNext: Pointer;
  checkpointExecutionStageMask: VkPipelineStageFlags2KHR;
end;


PVkCheckpointData2NV  =  ^VkCheckpointData2NV;
PPVkCheckpointData2NV = ^PVkCheckpointData2NV;
VkCheckpointData2NV = record
  sType: VkStructureType;
  pNext: Pointer;
  stage: VkPipelineStageFlags2KHR;
  pCheckpointMarker: Pointer;
end;


PVkPhysicalDeviceSynchronization2FeaturesKHR  =  ^VkPhysicalDeviceSynchronization2FeaturesKHR;
PPVkPhysicalDeviceSynchronization2FeaturesKHR = ^PVkPhysicalDeviceSynchronization2FeaturesKHR;
VkPhysicalDeviceSynchronization2FeaturesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  synchronization2: VkBool32;
end;


PVkVideoQueueFamilyProperties2KHR  =  ^VkVideoQueueFamilyProperties2KHR;
PPVkVideoQueueFamilyProperties2KHR = ^PVkVideoQueueFamilyProperties2KHR;
VkVideoQueueFamilyProperties2KHR = record
  sType: VkStructureType;
  pNext: Pointer;
  videoCodecOperations: VkVideoCodecOperationFlagsKHR;
end;


PVkVideoProfileKHR = ^VkVideoProfileKHR;
PVkVideoProfilesKHR  =  ^VkVideoProfilesKHR;
PPVkVideoProfilesKHR = ^PVkVideoProfilesKHR;
VkVideoProfilesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  profileCount: UInt32;
  pProfiles: PVkVideoProfileKHR;
end;


PVkPhysicalDeviceVideoFormatInfoKHR  =  ^VkPhysicalDeviceVideoFormatInfoKHR;
PPVkPhysicalDeviceVideoFormatInfoKHR = ^PVkPhysicalDeviceVideoFormatInfoKHR;
VkPhysicalDeviceVideoFormatInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  imageUsage: VkImageUsageFlags;
  pVideoProfiles: PVkVideoProfilesKHR;
end;


PVkVideoFormatPropertiesKHR  =  ^VkVideoFormatPropertiesKHR;
PPVkVideoFormatPropertiesKHR = ^PVkVideoFormatPropertiesKHR;
VkVideoFormatPropertiesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  format: VkFormat;
end;


PPVkVideoProfileKHR = ^PVkVideoProfileKHR;
VkVideoProfileKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  videoCodecOperation: VkVideoCodecOperationFlagBitsKHR;
  chromaSubsampling: VkVideoChromaSubsamplingFlagsKHR;
  lumaBitDepth: VkVideoComponentBitDepthFlagsKHR;
  chromaBitDepth: VkVideoComponentBitDepthFlagsKHR;
end;


PVkVideoCapabilitiesKHR  =  ^VkVideoCapabilitiesKHR;
PPVkVideoCapabilitiesKHR = ^PVkVideoCapabilitiesKHR;
VkVideoCapabilitiesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  capabilityFlags: VkVideoCapabilityFlagsKHR;
  minBitstreamBufferOffsetAlignment: VkDeviceSize;
  minBitstreamBufferSizeAlignment: VkDeviceSize;
  videoPictureExtentGranularity: VkExtent2D;
  minExtent: VkExtent2D;
  maxExtent: VkExtent2D;
  maxReferencePicturesSlotsCount: UInt32;
  maxReferencePicturesActiveCount: UInt32;
end;


PVkVideoGetMemoryPropertiesKHR  =  ^VkVideoGetMemoryPropertiesKHR;
PPVkVideoGetMemoryPropertiesKHR = ^PVkVideoGetMemoryPropertiesKHR;
VkVideoGetMemoryPropertiesKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  memoryBindIndex: UInt32;
  pMemoryRequirements: PVkMemoryRequirements2;
end;


PVkVideoBindMemoryKHR  =  ^VkVideoBindMemoryKHR;
PPVkVideoBindMemoryKHR = ^PVkVideoBindMemoryKHR;
VkVideoBindMemoryKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  memoryBindIndex: UInt32;
  memory: VkDeviceMemory;
  memoryOffset: VkDeviceSize;
  memorySize: VkDeviceSize;
end;


PVkVideoPictureResourceKHR  =  ^VkVideoPictureResourceKHR;
PPVkVideoPictureResourceKHR = ^PVkVideoPictureResourceKHR;
VkVideoPictureResourceKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  codedOffset: VkOffset2D;
  codedExtent: VkExtent2D;
  baseArrayLayer: UInt32;
  imageViewBinding: VkImageView;
end;


PVkVideoReferenceSlotKHR  =  ^VkVideoReferenceSlotKHR;
PPVkVideoReferenceSlotKHR = ^PVkVideoReferenceSlotKHR;
VkVideoReferenceSlotKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  slotIndex: Int8;
  pPictureResource: PVkVideoPictureResourceKHR;
end;


PVkVideoDecodeInfoKHR  =  ^VkVideoDecodeInfoKHR;
PPVkVideoDecodeInfoKHR = ^PVkVideoDecodeInfoKHR;
VkVideoDecodeInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkVideoDecodeFlagsKHR;
  codedOffset: VkOffset2D;
  codedExtent: VkExtent2D;
  srcBuffer: VkBuffer;
  srcBufferOffset: VkDeviceSize;
  srcBufferRange: VkDeviceSize;
  dstPictureResource: VkVideoPictureResourceKHR;
  pSetupReferenceSlot: PVkVideoReferenceSlotKHR;
  referenceSlotCount: UInt32;
  pReferenceSlots: PVkVideoReferenceSlotKHR;
end;


PVkVideoDecodeH264CapabilitiesEXT  =  ^VkVideoDecodeH264CapabilitiesEXT;
PPVkVideoDecodeH264CapabilitiesEXT = ^PVkVideoDecodeH264CapabilitiesEXT;
VkVideoDecodeH264CapabilitiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  maxLevel: UInt32;
  fieldOffsetGranularity: VkOffset2D;
  stdExtensionVersion: VkExtensionProperties;
end;


PVkVideoDecodeH264SessionCreateInfoEXT  =  ^VkVideoDecodeH264SessionCreateInfoEXT;
PPVkVideoDecodeH264SessionCreateInfoEXT = ^PVkVideoDecodeH264SessionCreateInfoEXT;
VkVideoDecodeH264SessionCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkVideoDecodeH264CreateFlagsEXT;
  pStdExtensionVersion: PVkExtensionProperties;
end;


PVkVideoDecodeH265CapabilitiesEXT  =  ^VkVideoDecodeH265CapabilitiesEXT;
PPVkVideoDecodeH265CapabilitiesEXT = ^PVkVideoDecodeH265CapabilitiesEXT;
VkVideoDecodeH265CapabilitiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  maxLevel: UInt32;
  stdExtensionVersion: VkExtensionProperties;
end;


PVkVideoDecodeH265SessionCreateInfoEXT  =  ^VkVideoDecodeH265SessionCreateInfoEXT;
PPVkVideoDecodeH265SessionCreateInfoEXT = ^PVkVideoDecodeH265SessionCreateInfoEXT;
VkVideoDecodeH265SessionCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkVideoDecodeH265CreateFlagsEXT;
  pStdExtensionVersion: PVkExtensionProperties;
end;


PVkVideoSessionCreateInfoKHR  =  ^VkVideoSessionCreateInfoKHR;
PPVkVideoSessionCreateInfoKHR = ^PVkVideoSessionCreateInfoKHR;
VkVideoSessionCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  queueFamilyIndex: UInt32;
  flags: VkVideoSessionCreateFlagsKHR;
  pVideoProfile: PVkVideoProfileKHR;
  pictureFormat: VkFormat;
  maxCodedExtent: VkExtent2D;
  referencePicturesFormat: VkFormat;
  maxReferencePicturesSlotsCount: UInt32;
  maxReferencePicturesActiveCount: UInt32;
end;


PVkVideoSessionParametersCreateInfoKHR  =  ^VkVideoSessionParametersCreateInfoKHR;
PPVkVideoSessionParametersCreateInfoKHR = ^PVkVideoSessionParametersCreateInfoKHR;
VkVideoSessionParametersCreateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  videoSessionParametersTemplate: VkVideoSessionParametersKHR;
  videoSession: VkVideoSessionKHR;
end;


PVkVideoSessionParametersUpdateInfoKHR  =  ^VkVideoSessionParametersUpdateInfoKHR;
PPVkVideoSessionParametersUpdateInfoKHR = ^PVkVideoSessionParametersUpdateInfoKHR;
VkVideoSessionParametersUpdateInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  updateSequenceCount: UInt32;
end;


PVkVideoBeginCodingInfoKHR  =  ^VkVideoBeginCodingInfoKHR;
PPVkVideoBeginCodingInfoKHR = ^PVkVideoBeginCodingInfoKHR;
VkVideoBeginCodingInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkVideoBeginCodingFlagsKHR;
  codecQualityPreset: VkVideoCodingQualityPresetFlagsKHR;
  videoSession: VkVideoSessionKHR;
  videoSessionParameters: VkVideoSessionParametersKHR;
  referenceSlotCount: UInt32;
  pReferenceSlots: PVkVideoReferenceSlotKHR;
end;


PVkVideoEndCodingInfoKHR  =  ^VkVideoEndCodingInfoKHR;
PPVkVideoEndCodingInfoKHR = ^PVkVideoEndCodingInfoKHR;
VkVideoEndCodingInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkVideoEndCodingFlagsKHR;
end;


PVkVideoCodingControlInfoKHR  =  ^VkVideoCodingControlInfoKHR;
PPVkVideoCodingControlInfoKHR = ^PVkVideoCodingControlInfoKHR;
VkVideoCodingControlInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkVideoCodingControlFlagsKHR;
end;


PVkVideoEncodeInfoKHR  =  ^VkVideoEncodeInfoKHR;
PPVkVideoEncodeInfoKHR = ^PVkVideoEncodeInfoKHR;
VkVideoEncodeInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkVideoEncodeFlagsKHR;
  qualityLevel: UInt32;
  codedExtent: VkExtent2D;
  dstBitstreamBuffer: VkBuffer;
  dstBitstreamBufferOffset: VkDeviceSize;
  dstBitstreamBufferMaxRange: VkDeviceSize;
  srcPictureResource: VkVideoPictureResourceKHR;
  pSetupReferenceSlot: PVkVideoReferenceSlotKHR;
  referenceSlotCount: UInt32;
  pReferenceSlots: PVkVideoReferenceSlotKHR;
end;


PVkVideoEncodeRateControlInfoKHR  =  ^VkVideoEncodeRateControlInfoKHR;
PPVkVideoEncodeRateControlInfoKHR = ^PVkVideoEncodeRateControlInfoKHR;
VkVideoEncodeRateControlInfoKHR = record
  sType: VkStructureType;
  pNext: Pointer;
  flags: VkVideoEncodeRateControlFlagsKHR;
  rateControlMode: VkVideoEncodeRateControlModeFlagBitsKHR;
  averageBitrate: UInt32;
  peakToAverageBitrateRatio: UInt16;
  frameRateNumerator: UInt16;
  frameRateDenominator: UInt16;
  virtualBufferSizeInMs: UInt32;
end;


PVkVideoEncodeH264EmitPictureParametersEXT  =  ^VkVideoEncodeH264EmitPictureParametersEXT;
PPVkVideoEncodeH264EmitPictureParametersEXT = ^PVkVideoEncodeH264EmitPictureParametersEXT;
VkVideoEncodeH264EmitPictureParametersEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  spsId: UInt8;
  emitSpsEnable: VkBool32;
  ppsIdEntryCount: UInt32;
  ppsIdEntries: PUInt8;
end;


PVkPhysicalDeviceInheritedViewportScissorFeaturesNV  =  ^VkPhysicalDeviceInheritedViewportScissorFeaturesNV;
PPVkPhysicalDeviceInheritedViewportScissorFeaturesNV = ^PVkPhysicalDeviceInheritedViewportScissorFeaturesNV;
VkPhysicalDeviceInheritedViewportScissorFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  inheritedViewportScissor2D: VkBool32;
end;


PVkCommandBufferInheritanceViewportScissorInfoNV  =  ^VkCommandBufferInheritanceViewportScissorInfoNV;
PPVkCommandBufferInheritanceViewportScissorInfoNV = ^PVkCommandBufferInheritanceViewportScissorInfoNV;
VkCommandBufferInheritanceViewportScissorInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  viewportScissor2D: VkBool32;
  viewportDepthCount: UInt32;
  pViewportDepths: PVkViewport;
end;


PVkPhysicalDeviceYcbcr2Plane444FormatsFeaturesEXT  =  ^VkPhysicalDeviceYcbcr2Plane444FormatsFeaturesEXT;
PPVkPhysicalDeviceYcbcr2Plane444FormatsFeaturesEXT = ^PVkPhysicalDeviceYcbcr2Plane444FormatsFeaturesEXT;
VkPhysicalDeviceYcbcr2Plane444FormatsFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  ycbcr2plane444Formats: VkBool32;
end;


PVkPhysicalDeviceProvokingVertexFeaturesEXT  =  ^VkPhysicalDeviceProvokingVertexFeaturesEXT;
PPVkPhysicalDeviceProvokingVertexFeaturesEXT = ^PVkPhysicalDeviceProvokingVertexFeaturesEXT;
VkPhysicalDeviceProvokingVertexFeaturesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  provokingVertexLast: VkBool32;
  transformFeedbackPreservesProvokingVertex: VkBool32;
end;


PVkPhysicalDeviceProvokingVertexPropertiesEXT  =  ^VkPhysicalDeviceProvokingVertexPropertiesEXT;
PPVkPhysicalDeviceProvokingVertexPropertiesEXT = ^PVkPhysicalDeviceProvokingVertexPropertiesEXT;
VkPhysicalDeviceProvokingVertexPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  provokingVertexModePerPipeline: VkBool32;
  transformFeedbackPreservesTriangleFanProvokingVertex: VkBool32;
end;


PVkPipelineRasterizationProvokingVertexStateCreateInfoEXT  =  ^VkPipelineRasterizationProvokingVertexStateCreateInfoEXT;
PPVkPipelineRasterizationProvokingVertexStateCreateInfoEXT = ^PVkPipelineRasterizationProvokingVertexStateCreateInfoEXT;
VkPipelineRasterizationProvokingVertexStateCreateInfoEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  provokingVertexMode: VkProvokingVertexModeEXT;
end;


PVkCuModuleCreateInfoNVX  =  ^VkCuModuleCreateInfoNVX;
PPVkCuModuleCreateInfoNVX = ^PVkCuModuleCreateInfoNVX;
VkCuModuleCreateInfoNVX = record
  sType: VkStructureType;
  pNext: Pointer;
  dataSize: SizeUInt;
  pData: Pointer;
end;


PVkCuFunctionCreateInfoNVX  =  ^VkCuFunctionCreateInfoNVX;
PPVkCuFunctionCreateInfoNVX = ^PVkCuFunctionCreateInfoNVX;
VkCuFunctionCreateInfoNVX = record
  sType: VkStructureType;
  pNext: Pointer;
  module: VkCuModuleNVX;
  pName: PAnsiChar;
end;


PVkCuLaunchInfoNVX  =  ^VkCuLaunchInfoNVX;
PPVkCuLaunchInfoNVX = ^PVkCuLaunchInfoNVX;
VkCuLaunchInfoNVX = record
  sType: VkStructureType;
  pNext: Pointer;
  _function: VkCuFunctionNVX;
  gridDimX: UInt32;
  gridDimY: UInt32;
  gridDimZ: UInt32;
  blockDimX: UInt32;
  blockDimY: UInt32;
  blockDimZ: UInt32;
  sharedMemBytes: UInt32;
  paramCount: SizeUInt;
  pParams: Pointer;
  extraCount: SizeUInt;
  pExtras: Pointer;
end;


PVkPhysicalDeviceDrmPropertiesEXT  =  ^VkPhysicalDeviceDrmPropertiesEXT;
PPVkPhysicalDeviceDrmPropertiesEXT = ^PVkPhysicalDeviceDrmPropertiesEXT;
VkPhysicalDeviceDrmPropertiesEXT = record
  sType: VkStructureType;
  pNext: Pointer;
  hasPrimary: VkBool32;
  hasRender: VkBool32;
  primaryMajor: Int64;
  primaryMinor: Int64;
  renderMajor: Int64;
  renderMinor: Int64;
end;


PVkPhysicalDeviceRayTracingMotionBlurFeaturesNV  =  ^VkPhysicalDeviceRayTracingMotionBlurFeaturesNV;
PPVkPhysicalDeviceRayTracingMotionBlurFeaturesNV = ^PVkPhysicalDeviceRayTracingMotionBlurFeaturesNV;
VkPhysicalDeviceRayTracingMotionBlurFeaturesNV = record
  sType: VkStructureType;
  pNext: Pointer;
  rayTracingMotionBlur: VkBool32;
  rayTracingMotionBlurPipelineTraceRaysIndirect: VkBool32;
end;


PVkAccelerationStructureGeometryMotionTrianglesDataNV  =  ^VkAccelerationStructureGeometryMotionTrianglesDataNV;
PPVkAccelerationStructureGeometryMotionTrianglesDataNV = ^PVkAccelerationStructureGeometryMotionTrianglesDataNV;
VkAccelerationStructureGeometryMotionTrianglesDataNV = record
  sType: VkStructureType;
  pNext: Pointer;
  vertexData: VkDeviceOrHostAddressConstKHR;
end;


PVkAccelerationStructureMotionInfoNV  =  ^VkAccelerationStructureMotionInfoNV;
PPVkAccelerationStructureMotionInfoNV = ^PVkAccelerationStructureMotionInfoNV;
VkAccelerationStructureMotionInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  maxInstances: UInt32;
  flags: VkAccelerationStructureMotionInfoFlagsNV;
end;


PVkSRTDataNV  =  ^VkSRTDataNV;
PPVkSRTDataNV = ^PVkSRTDataNV;
VkSRTDataNV = record
  sx: Single;
  a: Single;
  b: Single;
  pvx: Single;
  sy: Single;
  c: Single;
  pvy: Single;
  sz: Single;
  pvz: Single;
  qx: Single;
  qy: Single;
  qz: Single;
  qw: Single;
  tx: Single;
  ty: Single;
  tz: Single;
end;


PVkAccelerationStructureSRTMotionInstanceNV  =  ^VkAccelerationStructureSRTMotionInstanceNV;
PPVkAccelerationStructureSRTMotionInstanceNV = ^PVkAccelerationStructureSRTMotionInstanceNV;
VkAccelerationStructureSRTMotionInstanceNV = record
  transformT0: VkSRTDataNV;
  transformT1: VkSRTDataNV;
  instanceCustomIndex: UInt32;
  mask: UInt32;
  instanceShaderBindingTableRecordOffset: UInt32;
  flags: VkGeometryInstanceFlagsKHR;
  accelerationStructureReference: UInt64;
end;


PVkAccelerationStructureMatrixMotionInstanceNV  =  ^VkAccelerationStructureMatrixMotionInstanceNV;
PPVkAccelerationStructureMatrixMotionInstanceNV = ^PVkAccelerationStructureMatrixMotionInstanceNV;
VkAccelerationStructureMatrixMotionInstanceNV = record
  transformT0: VkTransformMatrixKHR;
  transformT1: VkTransformMatrixKHR;
  instanceCustomIndex: UInt32;
  mask: UInt32;
  instanceShaderBindingTableRecordOffset: UInt32;
  flags: VkGeometryInstanceFlagsKHR;
  accelerationStructureReference: UInt64;
end;


PVkAccelerationStructureMotionInstanceDataNV  =  ^VkAccelerationStructureMotionInstanceDataNV;
PPVkAccelerationStructureMotionInstanceDataNV = ^PVkAccelerationStructureMotionInstanceDataNV;
VkAccelerationStructureMotionInstanceDataNV = record
case Byte of
  0: (staticInstance: VkAccelerationStructureInstanceKHR);
  1: (matrixMotionInstance: VkAccelerationStructureMatrixMotionInstanceNV);
  2: (srtMotionInstance: VkAccelerationStructureSRTMotionInstanceNV);
end;


PVkAccelerationStructureMotionInstanceNV  =  ^VkAccelerationStructureMotionInstanceNV;
PPVkAccelerationStructureMotionInstanceNV = ^PVkAccelerationStructureMotionInstanceNV;
VkAccelerationStructureMotionInstanceNV = record
  _type: VkAccelerationStructureMotionInstanceTypeNV;
  flags: VkAccelerationStructureMotionInstanceFlagsNV;
  data: VkAccelerationStructureMotionInstanceDataNV;
end;


PVkMemoryGetRemoteAddressInfoNV  =  ^VkMemoryGetRemoteAddressInfoNV;
PPVkMemoryGetRemoteAddressInfoNV = ^PVkMemoryGetRemoteAddressInfoNV;
VkMemoryGetRemoteAddressInfoNV = record
  sType: VkStructureType;
  pNext: Pointer;
  memory: VkDeviceMemory;
  handleType: VkExternalMemoryHandleTypeFlagBits;
end;

VkPhysicalDeviceFeatures2KHR = VkPhysicalDeviceFeatures2;
PVkPhysicalDeviceFeatures2KHR = ^VkPhysicalDeviceFeatures2KHR;
PPVkPhysicalDeviceFeatures2KHR = ^PVkPhysicalDeviceFeatures2KHR;
VkPhysicalDeviceProperties2KHR = VkPhysicalDeviceProperties2;
PVkPhysicalDeviceProperties2KHR = ^VkPhysicalDeviceProperties2KHR;
PPVkPhysicalDeviceProperties2KHR = ^PVkPhysicalDeviceProperties2KHR;
VkFormatProperties2KHR = VkFormatProperties2;
PVkFormatProperties2KHR = ^VkFormatProperties2KHR;
PPVkFormatProperties2KHR = ^PVkFormatProperties2KHR;
VkImageFormatProperties2KHR = VkImageFormatProperties2;
PVkImageFormatProperties2KHR = ^VkImageFormatProperties2KHR;
PPVkImageFormatProperties2KHR = ^PVkImageFormatProperties2KHR;
VkPhysicalDeviceImageFormatInfo2KHR = VkPhysicalDeviceImageFormatInfo2;
PVkPhysicalDeviceImageFormatInfo2KHR = ^VkPhysicalDeviceImageFormatInfo2KHR;
PPVkPhysicalDeviceImageFormatInfo2KHR = ^PVkPhysicalDeviceImageFormatInfo2KHR;
VkQueueFamilyProperties2KHR = VkQueueFamilyProperties2;
PVkQueueFamilyProperties2KHR = ^VkQueueFamilyProperties2KHR;
PPVkQueueFamilyProperties2KHR = ^PVkQueueFamilyProperties2KHR;
VkPhysicalDeviceMemoryProperties2KHR = VkPhysicalDeviceMemoryProperties2;
PVkPhysicalDeviceMemoryProperties2KHR = ^VkPhysicalDeviceMemoryProperties2KHR;
PPVkPhysicalDeviceMemoryProperties2KHR = ^PVkPhysicalDeviceMemoryProperties2KHR;
VkSparseImageFormatProperties2KHR = VkSparseImageFormatProperties2;
PVkSparseImageFormatProperties2KHR = ^VkSparseImageFormatProperties2KHR;
PPVkSparseImageFormatProperties2KHR = ^PVkSparseImageFormatProperties2KHR;
VkPhysicalDeviceSparseImageFormatInfo2KHR = VkPhysicalDeviceSparseImageFormatInfo2;
PVkPhysicalDeviceSparseImageFormatInfo2KHR = ^VkPhysicalDeviceSparseImageFormatInfo2KHR;
PPVkPhysicalDeviceSparseImageFormatInfo2KHR = ^PVkPhysicalDeviceSparseImageFormatInfo2KHR;
VkConformanceVersionKHR = VkConformanceVersion;
PVkConformanceVersionKHR = ^VkConformanceVersionKHR;
PPVkConformanceVersionKHR = ^PVkConformanceVersionKHR;
VkPhysicalDeviceDriverPropertiesKHR = VkPhysicalDeviceDriverProperties;
PVkPhysicalDeviceDriverPropertiesKHR = ^VkPhysicalDeviceDriverPropertiesKHR;
PPVkPhysicalDeviceDriverPropertiesKHR = ^PVkPhysicalDeviceDriverPropertiesKHR;
VkPhysicalDeviceVariablePointersFeaturesKHR = VkPhysicalDeviceVariablePointersFeatures;
PVkPhysicalDeviceVariablePointersFeaturesKHR = ^VkPhysicalDeviceVariablePointersFeaturesKHR;
PPVkPhysicalDeviceVariablePointersFeaturesKHR = ^PVkPhysicalDeviceVariablePointersFeaturesKHR;
VkPhysicalDeviceVariablePointerFeaturesKHR = VkPhysicalDeviceVariablePointersFeatures;
PVkPhysicalDeviceVariablePointerFeaturesKHR = ^VkPhysicalDeviceVariablePointerFeaturesKHR;
PPVkPhysicalDeviceVariablePointerFeaturesKHR = ^PVkPhysicalDeviceVariablePointerFeaturesKHR;
VkPhysicalDeviceVariablePointerFeatures = VkPhysicalDeviceVariablePointersFeatures;
PVkPhysicalDeviceVariablePointerFeatures = ^VkPhysicalDeviceVariablePointerFeatures;
PPVkPhysicalDeviceVariablePointerFeatures = ^PVkPhysicalDeviceVariablePointerFeatures;
VkExternalMemoryPropertiesKHR = VkExternalMemoryProperties;
PVkExternalMemoryPropertiesKHR = ^VkExternalMemoryPropertiesKHR;
PPVkExternalMemoryPropertiesKHR = ^PVkExternalMemoryPropertiesKHR;
VkPhysicalDeviceExternalImageFormatInfoKHR = VkPhysicalDeviceExternalImageFormatInfo;
PVkPhysicalDeviceExternalImageFormatInfoKHR = ^VkPhysicalDeviceExternalImageFormatInfoKHR;
PPVkPhysicalDeviceExternalImageFormatInfoKHR = ^PVkPhysicalDeviceExternalImageFormatInfoKHR;
VkExternalImageFormatPropertiesKHR = VkExternalImageFormatProperties;
PVkExternalImageFormatPropertiesKHR = ^VkExternalImageFormatPropertiesKHR;
PPVkExternalImageFormatPropertiesKHR = ^PVkExternalImageFormatPropertiesKHR;
VkPhysicalDeviceExternalBufferInfoKHR = VkPhysicalDeviceExternalBufferInfo;
PVkPhysicalDeviceExternalBufferInfoKHR = ^VkPhysicalDeviceExternalBufferInfoKHR;
PPVkPhysicalDeviceExternalBufferInfoKHR = ^PVkPhysicalDeviceExternalBufferInfoKHR;
VkExternalBufferPropertiesKHR = VkExternalBufferProperties;
PVkExternalBufferPropertiesKHR = ^VkExternalBufferPropertiesKHR;
PPVkExternalBufferPropertiesKHR = ^PVkExternalBufferPropertiesKHR;
VkPhysicalDeviceIDPropertiesKHR = VkPhysicalDeviceIDProperties;
PVkPhysicalDeviceIDPropertiesKHR = ^VkPhysicalDeviceIDPropertiesKHR;
PPVkPhysicalDeviceIDPropertiesKHR = ^PVkPhysicalDeviceIDPropertiesKHR;
VkExternalMemoryImageCreateInfoKHR = VkExternalMemoryImageCreateInfo;
PVkExternalMemoryImageCreateInfoKHR = ^VkExternalMemoryImageCreateInfoKHR;
PPVkExternalMemoryImageCreateInfoKHR = ^PVkExternalMemoryImageCreateInfoKHR;
VkExternalMemoryBufferCreateInfoKHR = VkExternalMemoryBufferCreateInfo;
PVkExternalMemoryBufferCreateInfoKHR = ^VkExternalMemoryBufferCreateInfoKHR;
PPVkExternalMemoryBufferCreateInfoKHR = ^PVkExternalMemoryBufferCreateInfoKHR;
VkExportMemoryAllocateInfoKHR = VkExportMemoryAllocateInfo;
PVkExportMemoryAllocateInfoKHR = ^VkExportMemoryAllocateInfoKHR;
PPVkExportMemoryAllocateInfoKHR = ^PVkExportMemoryAllocateInfoKHR;
VkPhysicalDeviceExternalSemaphoreInfoKHR = VkPhysicalDeviceExternalSemaphoreInfo;
PVkPhysicalDeviceExternalSemaphoreInfoKHR = ^VkPhysicalDeviceExternalSemaphoreInfoKHR;
PPVkPhysicalDeviceExternalSemaphoreInfoKHR = ^PVkPhysicalDeviceExternalSemaphoreInfoKHR;
VkExternalSemaphorePropertiesKHR = VkExternalSemaphoreProperties;
PVkExternalSemaphorePropertiesKHR = ^VkExternalSemaphorePropertiesKHR;
PPVkExternalSemaphorePropertiesKHR = ^PVkExternalSemaphorePropertiesKHR;
VkExportSemaphoreCreateInfoKHR = VkExportSemaphoreCreateInfo;
PVkExportSemaphoreCreateInfoKHR = ^VkExportSemaphoreCreateInfoKHR;
PPVkExportSemaphoreCreateInfoKHR = ^PVkExportSemaphoreCreateInfoKHR;
VkPhysicalDeviceExternalFenceInfoKHR = VkPhysicalDeviceExternalFenceInfo;
PVkPhysicalDeviceExternalFenceInfoKHR = ^VkPhysicalDeviceExternalFenceInfoKHR;
PPVkPhysicalDeviceExternalFenceInfoKHR = ^PVkPhysicalDeviceExternalFenceInfoKHR;
VkExternalFencePropertiesKHR = VkExternalFenceProperties;
PVkExternalFencePropertiesKHR = ^VkExternalFencePropertiesKHR;
PPVkExternalFencePropertiesKHR = ^PVkExternalFencePropertiesKHR;
VkExportFenceCreateInfoKHR = VkExportFenceCreateInfo;
PVkExportFenceCreateInfoKHR = ^VkExportFenceCreateInfoKHR;
PPVkExportFenceCreateInfoKHR = ^PVkExportFenceCreateInfoKHR;
VkPhysicalDeviceMultiviewFeaturesKHR = VkPhysicalDeviceMultiviewFeatures;
PVkPhysicalDeviceMultiviewFeaturesKHR = ^VkPhysicalDeviceMultiviewFeaturesKHR;
PPVkPhysicalDeviceMultiviewFeaturesKHR = ^PVkPhysicalDeviceMultiviewFeaturesKHR;
VkPhysicalDeviceMultiviewPropertiesKHR = VkPhysicalDeviceMultiviewProperties;
PVkPhysicalDeviceMultiviewPropertiesKHR = ^VkPhysicalDeviceMultiviewPropertiesKHR;
PPVkPhysicalDeviceMultiviewPropertiesKHR = ^PVkPhysicalDeviceMultiviewPropertiesKHR;
VkRenderPassMultiviewCreateInfoKHR = VkRenderPassMultiviewCreateInfo;
PVkRenderPassMultiviewCreateInfoKHR = ^VkRenderPassMultiviewCreateInfoKHR;
PPVkRenderPassMultiviewCreateInfoKHR = ^PVkRenderPassMultiviewCreateInfoKHR;
VkPhysicalDeviceGroupPropertiesKHR = VkPhysicalDeviceGroupProperties;
PVkPhysicalDeviceGroupPropertiesKHR = ^VkPhysicalDeviceGroupPropertiesKHR;
PPVkPhysicalDeviceGroupPropertiesKHR = ^PVkPhysicalDeviceGroupPropertiesKHR;
VkMemoryAllocateFlagsInfoKHR = VkMemoryAllocateFlagsInfo;
PVkMemoryAllocateFlagsInfoKHR = ^VkMemoryAllocateFlagsInfoKHR;
PPVkMemoryAllocateFlagsInfoKHR = ^PVkMemoryAllocateFlagsInfoKHR;
VkBindBufferMemoryInfoKHR = VkBindBufferMemoryInfo;
PVkBindBufferMemoryInfoKHR = ^VkBindBufferMemoryInfoKHR;
PPVkBindBufferMemoryInfoKHR = ^PVkBindBufferMemoryInfoKHR;
VkBindBufferMemoryDeviceGroupInfoKHR = VkBindBufferMemoryDeviceGroupInfo;
PVkBindBufferMemoryDeviceGroupInfoKHR = ^VkBindBufferMemoryDeviceGroupInfoKHR;
PPVkBindBufferMemoryDeviceGroupInfoKHR = ^PVkBindBufferMemoryDeviceGroupInfoKHR;
VkBindImageMemoryInfoKHR = VkBindImageMemoryInfo;
PVkBindImageMemoryInfoKHR = ^VkBindImageMemoryInfoKHR;
PPVkBindImageMemoryInfoKHR = ^PVkBindImageMemoryInfoKHR;
VkBindImageMemoryDeviceGroupInfoKHR = VkBindImageMemoryDeviceGroupInfo;
PVkBindImageMemoryDeviceGroupInfoKHR = ^VkBindImageMemoryDeviceGroupInfoKHR;
PPVkBindImageMemoryDeviceGroupInfoKHR = ^PVkBindImageMemoryDeviceGroupInfoKHR;
VkDeviceGroupRenderPassBeginInfoKHR = VkDeviceGroupRenderPassBeginInfo;
PVkDeviceGroupRenderPassBeginInfoKHR = ^VkDeviceGroupRenderPassBeginInfoKHR;
PPVkDeviceGroupRenderPassBeginInfoKHR = ^PVkDeviceGroupRenderPassBeginInfoKHR;
VkDeviceGroupCommandBufferBeginInfoKHR = VkDeviceGroupCommandBufferBeginInfo;
PVkDeviceGroupCommandBufferBeginInfoKHR = ^VkDeviceGroupCommandBufferBeginInfoKHR;
PPVkDeviceGroupCommandBufferBeginInfoKHR = ^PVkDeviceGroupCommandBufferBeginInfoKHR;
VkDeviceGroupSubmitInfoKHR = VkDeviceGroupSubmitInfo;
PVkDeviceGroupSubmitInfoKHR = ^VkDeviceGroupSubmitInfoKHR;
PPVkDeviceGroupSubmitInfoKHR = ^PVkDeviceGroupSubmitInfoKHR;
VkDeviceGroupBindSparseInfoKHR = VkDeviceGroupBindSparseInfo;
PVkDeviceGroupBindSparseInfoKHR = ^VkDeviceGroupBindSparseInfoKHR;
PPVkDeviceGroupBindSparseInfoKHR = ^PVkDeviceGroupBindSparseInfoKHR;
VkDeviceGroupDeviceCreateInfoKHR = VkDeviceGroupDeviceCreateInfo;
PVkDeviceGroupDeviceCreateInfoKHR = ^VkDeviceGroupDeviceCreateInfoKHR;
PPVkDeviceGroupDeviceCreateInfoKHR = ^PVkDeviceGroupDeviceCreateInfoKHR;
VkDescriptorUpdateTemplateEntryKHR = VkDescriptorUpdateTemplateEntry;
PVkDescriptorUpdateTemplateEntryKHR = ^VkDescriptorUpdateTemplateEntryKHR;
PPVkDescriptorUpdateTemplateEntryKHR = ^PVkDescriptorUpdateTemplateEntryKHR;
VkDescriptorUpdateTemplateCreateInfoKHR = VkDescriptorUpdateTemplateCreateInfo;
PVkDescriptorUpdateTemplateCreateInfoKHR = ^VkDescriptorUpdateTemplateCreateInfoKHR;
PPVkDescriptorUpdateTemplateCreateInfoKHR = ^PVkDescriptorUpdateTemplateCreateInfoKHR;
VkInputAttachmentAspectReferenceKHR = VkInputAttachmentAspectReference;
PVkInputAttachmentAspectReferenceKHR = ^VkInputAttachmentAspectReferenceKHR;
PPVkInputAttachmentAspectReferenceKHR = ^PVkInputAttachmentAspectReferenceKHR;
VkRenderPassInputAttachmentAspectCreateInfoKHR = VkRenderPassInputAttachmentAspectCreateInfo;
PVkRenderPassInputAttachmentAspectCreateInfoKHR = ^VkRenderPassInputAttachmentAspectCreateInfoKHR;
PPVkRenderPassInputAttachmentAspectCreateInfoKHR = ^PVkRenderPassInputAttachmentAspectCreateInfoKHR;
VkPhysicalDevice16BitStorageFeaturesKHR = VkPhysicalDevice16BitStorageFeatures;
PVkPhysicalDevice16BitStorageFeaturesKHR = ^VkPhysicalDevice16BitStorageFeaturesKHR;
PPVkPhysicalDevice16BitStorageFeaturesKHR = ^PVkPhysicalDevice16BitStorageFeaturesKHR;
VkPhysicalDeviceShaderSubgroupExtendedTypesFeaturesKHR = VkPhysicalDeviceShaderSubgroupExtendedTypesFeatures;
PVkPhysicalDeviceShaderSubgroupExtendedTypesFeaturesKHR = ^VkPhysicalDeviceShaderSubgroupExtendedTypesFeaturesKHR;
PPVkPhysicalDeviceShaderSubgroupExtendedTypesFeaturesKHR = ^PVkPhysicalDeviceShaderSubgroupExtendedTypesFeaturesKHR;
VkBufferMemoryRequirementsInfo2KHR = VkBufferMemoryRequirementsInfo2;
PVkBufferMemoryRequirementsInfo2KHR = ^VkBufferMemoryRequirementsInfo2KHR;
PPVkBufferMemoryRequirementsInfo2KHR = ^PVkBufferMemoryRequirementsInfo2KHR;
VkImageMemoryRequirementsInfo2KHR = VkImageMemoryRequirementsInfo2;
PVkImageMemoryRequirementsInfo2KHR = ^VkImageMemoryRequirementsInfo2KHR;
PPVkImageMemoryRequirementsInfo2KHR = ^PVkImageMemoryRequirementsInfo2KHR;
VkImageSparseMemoryRequirementsInfo2KHR = VkImageSparseMemoryRequirementsInfo2;
PVkImageSparseMemoryRequirementsInfo2KHR = ^VkImageSparseMemoryRequirementsInfo2KHR;
PPVkImageSparseMemoryRequirementsInfo2KHR = ^PVkImageSparseMemoryRequirementsInfo2KHR;
VkMemoryRequirements2KHR = VkMemoryRequirements2;
PVkMemoryRequirements2KHR = ^VkMemoryRequirements2KHR;
PPVkMemoryRequirements2KHR = ^PVkMemoryRequirements2KHR;
VkSparseImageMemoryRequirements2KHR = VkSparseImageMemoryRequirements2;
PVkSparseImageMemoryRequirements2KHR = ^VkSparseImageMemoryRequirements2KHR;
PPVkSparseImageMemoryRequirements2KHR = ^PVkSparseImageMemoryRequirements2KHR;
VkPhysicalDevicePointClippingPropertiesKHR = VkPhysicalDevicePointClippingProperties;
PVkPhysicalDevicePointClippingPropertiesKHR = ^VkPhysicalDevicePointClippingPropertiesKHR;
PPVkPhysicalDevicePointClippingPropertiesKHR = ^PVkPhysicalDevicePointClippingPropertiesKHR;
VkMemoryDedicatedRequirementsKHR = VkMemoryDedicatedRequirements;
PVkMemoryDedicatedRequirementsKHR = ^VkMemoryDedicatedRequirementsKHR;
PPVkMemoryDedicatedRequirementsKHR = ^PVkMemoryDedicatedRequirementsKHR;
VkMemoryDedicatedAllocateInfoKHR = VkMemoryDedicatedAllocateInfo;
PVkMemoryDedicatedAllocateInfoKHR = ^VkMemoryDedicatedAllocateInfoKHR;
PPVkMemoryDedicatedAllocateInfoKHR = ^PVkMemoryDedicatedAllocateInfoKHR;
VkImageViewUsageCreateInfoKHR = VkImageViewUsageCreateInfo;
PVkImageViewUsageCreateInfoKHR = ^VkImageViewUsageCreateInfoKHR;
PPVkImageViewUsageCreateInfoKHR = ^PVkImageViewUsageCreateInfoKHR;
VkPipelineTessellationDomainOriginStateCreateInfoKHR = VkPipelineTessellationDomainOriginStateCreateInfo;
PVkPipelineTessellationDomainOriginStateCreateInfoKHR = ^VkPipelineTessellationDomainOriginStateCreateInfoKHR;
PPVkPipelineTessellationDomainOriginStateCreateInfoKHR = ^PVkPipelineTessellationDomainOriginStateCreateInfoKHR;
VkSamplerYcbcrConversionInfoKHR = VkSamplerYcbcrConversionInfo;
PVkSamplerYcbcrConversionInfoKHR = ^VkSamplerYcbcrConversionInfoKHR;
PPVkSamplerYcbcrConversionInfoKHR = ^PVkSamplerYcbcrConversionInfoKHR;
VkSamplerYcbcrConversionCreateInfoKHR = VkSamplerYcbcrConversionCreateInfo;
PVkSamplerYcbcrConversionCreateInfoKHR = ^VkSamplerYcbcrConversionCreateInfoKHR;
PPVkSamplerYcbcrConversionCreateInfoKHR = ^PVkSamplerYcbcrConversionCreateInfoKHR;
VkBindImagePlaneMemoryInfoKHR = VkBindImagePlaneMemoryInfo;
PVkBindImagePlaneMemoryInfoKHR = ^VkBindImagePlaneMemoryInfoKHR;
PPVkBindImagePlaneMemoryInfoKHR = ^PVkBindImagePlaneMemoryInfoKHR;
VkImagePlaneMemoryRequirementsInfoKHR = VkImagePlaneMemoryRequirementsInfo;
PVkImagePlaneMemoryRequirementsInfoKHR = ^VkImagePlaneMemoryRequirementsInfoKHR;
PPVkImagePlaneMemoryRequirementsInfoKHR = ^PVkImagePlaneMemoryRequirementsInfoKHR;
VkPhysicalDeviceSamplerYcbcrConversionFeaturesKHR = VkPhysicalDeviceSamplerYcbcrConversionFeatures;
PVkPhysicalDeviceSamplerYcbcrConversionFeaturesKHR = ^VkPhysicalDeviceSamplerYcbcrConversionFeaturesKHR;
PPVkPhysicalDeviceSamplerYcbcrConversionFeaturesKHR = ^PVkPhysicalDeviceSamplerYcbcrConversionFeaturesKHR;
VkSamplerYcbcrConversionImageFormatPropertiesKHR = VkSamplerYcbcrConversionImageFormatProperties;
PVkSamplerYcbcrConversionImageFormatPropertiesKHR = ^VkSamplerYcbcrConversionImageFormatPropertiesKHR;
PPVkSamplerYcbcrConversionImageFormatPropertiesKHR = ^PVkSamplerYcbcrConversionImageFormatPropertiesKHR;
VkPhysicalDeviceSamplerFilterMinmaxPropertiesEXT = VkPhysicalDeviceSamplerFilterMinmaxProperties;
PVkPhysicalDeviceSamplerFilterMinmaxPropertiesEXT = ^VkPhysicalDeviceSamplerFilterMinmaxPropertiesEXT;
PPVkPhysicalDeviceSamplerFilterMinmaxPropertiesEXT = ^PVkPhysicalDeviceSamplerFilterMinmaxPropertiesEXT;
VkSamplerReductionModeCreateInfoEXT = VkSamplerReductionModeCreateInfo;
PVkSamplerReductionModeCreateInfoEXT = ^VkSamplerReductionModeCreateInfoEXT;
PPVkSamplerReductionModeCreateInfoEXT = ^PVkSamplerReductionModeCreateInfoEXT;
VkImageFormatListCreateInfoKHR = VkImageFormatListCreateInfo;
PVkImageFormatListCreateInfoKHR = ^VkImageFormatListCreateInfoKHR;
PPVkImageFormatListCreateInfoKHR = ^PVkImageFormatListCreateInfoKHR;
VkPhysicalDeviceMaintenance3PropertiesKHR = VkPhysicalDeviceMaintenance3Properties;
PVkPhysicalDeviceMaintenance3PropertiesKHR = ^VkPhysicalDeviceMaintenance3PropertiesKHR;
PPVkPhysicalDeviceMaintenance3PropertiesKHR = ^PVkPhysicalDeviceMaintenance3PropertiesKHR;
VkDescriptorSetLayoutSupportKHR = VkDescriptorSetLayoutSupport;
PVkDescriptorSetLayoutSupportKHR = ^VkDescriptorSetLayoutSupportKHR;
PPVkDescriptorSetLayoutSupportKHR = ^PVkDescriptorSetLayoutSupportKHR;
VkPhysicalDeviceShaderDrawParameterFeatures = VkPhysicalDeviceShaderDrawParametersFeatures;
PVkPhysicalDeviceShaderDrawParameterFeatures = ^VkPhysicalDeviceShaderDrawParameterFeatures;
PPVkPhysicalDeviceShaderDrawParameterFeatures = ^PVkPhysicalDeviceShaderDrawParameterFeatures;
VkPhysicalDeviceShaderFloat16Int8FeaturesKHR = VkPhysicalDeviceShaderFloat16Int8Features;
PVkPhysicalDeviceShaderFloat16Int8FeaturesKHR = ^VkPhysicalDeviceShaderFloat16Int8FeaturesKHR;
PPVkPhysicalDeviceShaderFloat16Int8FeaturesKHR = ^PVkPhysicalDeviceShaderFloat16Int8FeaturesKHR;
VkPhysicalDeviceFloat16Int8FeaturesKHR = VkPhysicalDeviceShaderFloat16Int8Features;
PVkPhysicalDeviceFloat16Int8FeaturesKHR = ^VkPhysicalDeviceFloat16Int8FeaturesKHR;
PPVkPhysicalDeviceFloat16Int8FeaturesKHR = ^PVkPhysicalDeviceFloat16Int8FeaturesKHR;
VkPhysicalDeviceFloatControlsPropertiesKHR = VkPhysicalDeviceFloatControlsProperties;
PVkPhysicalDeviceFloatControlsPropertiesKHR = ^VkPhysicalDeviceFloatControlsPropertiesKHR;
PPVkPhysicalDeviceFloatControlsPropertiesKHR = ^PVkPhysicalDeviceFloatControlsPropertiesKHR;
VkPhysicalDeviceHostQueryResetFeaturesEXT = VkPhysicalDeviceHostQueryResetFeatures;
PVkPhysicalDeviceHostQueryResetFeaturesEXT = ^VkPhysicalDeviceHostQueryResetFeaturesEXT;
PPVkPhysicalDeviceHostQueryResetFeaturesEXT = ^PVkPhysicalDeviceHostQueryResetFeaturesEXT;
VkPhysicalDeviceDescriptorIndexingFeaturesEXT = VkPhysicalDeviceDescriptorIndexingFeatures;
PVkPhysicalDeviceDescriptorIndexingFeaturesEXT = ^VkPhysicalDeviceDescriptorIndexingFeaturesEXT;
PPVkPhysicalDeviceDescriptorIndexingFeaturesEXT = ^PVkPhysicalDeviceDescriptorIndexingFeaturesEXT;
VkPhysicalDeviceDescriptorIndexingPropertiesEXT = VkPhysicalDeviceDescriptorIndexingProperties;
PVkPhysicalDeviceDescriptorIndexingPropertiesEXT = ^VkPhysicalDeviceDescriptorIndexingPropertiesEXT;
PPVkPhysicalDeviceDescriptorIndexingPropertiesEXT = ^PVkPhysicalDeviceDescriptorIndexingPropertiesEXT;
VkDescriptorSetLayoutBindingFlagsCreateInfoEXT = VkDescriptorSetLayoutBindingFlagsCreateInfo;
PVkDescriptorSetLayoutBindingFlagsCreateInfoEXT = ^VkDescriptorSetLayoutBindingFlagsCreateInfoEXT;
PPVkDescriptorSetLayoutBindingFlagsCreateInfoEXT = ^PVkDescriptorSetLayoutBindingFlagsCreateInfoEXT;
VkDescriptorSetVariableDescriptorCountAllocateInfoEXT = VkDescriptorSetVariableDescriptorCountAllocateInfo;
PVkDescriptorSetVariableDescriptorCountAllocateInfoEXT = ^VkDescriptorSetVariableDescriptorCountAllocateInfoEXT;
PPVkDescriptorSetVariableDescriptorCountAllocateInfoEXT = ^PVkDescriptorSetVariableDescriptorCountAllocateInfoEXT;
VkDescriptorSetVariableDescriptorCountLayoutSupportEXT = VkDescriptorSetVariableDescriptorCountLayoutSupport;
PVkDescriptorSetVariableDescriptorCountLayoutSupportEXT = ^VkDescriptorSetVariableDescriptorCountLayoutSupportEXT;
PPVkDescriptorSetVariableDescriptorCountLayoutSupportEXT = ^PVkDescriptorSetVariableDescriptorCountLayoutSupportEXT;
VkAttachmentDescription2KHR = VkAttachmentDescription2;
PVkAttachmentDescription2KHR = ^VkAttachmentDescription2KHR;
PPVkAttachmentDescription2KHR = ^PVkAttachmentDescription2KHR;
VkAttachmentReference2KHR = VkAttachmentReference2;
PVkAttachmentReference2KHR = ^VkAttachmentReference2KHR;
PPVkAttachmentReference2KHR = ^PVkAttachmentReference2KHR;
VkSubpassDescription2KHR = VkSubpassDescription2;
PVkSubpassDescription2KHR = ^VkSubpassDescription2KHR;
PPVkSubpassDescription2KHR = ^PVkSubpassDescription2KHR;
VkSubpassDependency2KHR = VkSubpassDependency2;
PVkSubpassDependency2KHR = ^VkSubpassDependency2KHR;
PPVkSubpassDependency2KHR = ^PVkSubpassDependency2KHR;
VkRenderPassCreateInfo2KHR = VkRenderPassCreateInfo2;
PVkRenderPassCreateInfo2KHR = ^VkRenderPassCreateInfo2KHR;
PPVkRenderPassCreateInfo2KHR = ^PVkRenderPassCreateInfo2KHR;
VkSubpassBeginInfoKHR = VkSubpassBeginInfo;
PVkSubpassBeginInfoKHR = ^VkSubpassBeginInfoKHR;
PPVkSubpassBeginInfoKHR = ^PVkSubpassBeginInfoKHR;
VkSubpassEndInfoKHR = VkSubpassEndInfo;
PVkSubpassEndInfoKHR = ^VkSubpassEndInfoKHR;
PPVkSubpassEndInfoKHR = ^PVkSubpassEndInfoKHR;
VkPhysicalDeviceTimelineSemaphoreFeaturesKHR = VkPhysicalDeviceTimelineSemaphoreFeatures;
PVkPhysicalDeviceTimelineSemaphoreFeaturesKHR = ^VkPhysicalDeviceTimelineSemaphoreFeaturesKHR;
PPVkPhysicalDeviceTimelineSemaphoreFeaturesKHR = ^PVkPhysicalDeviceTimelineSemaphoreFeaturesKHR;
VkPhysicalDeviceTimelineSemaphorePropertiesKHR = VkPhysicalDeviceTimelineSemaphoreProperties;
PVkPhysicalDeviceTimelineSemaphorePropertiesKHR = ^VkPhysicalDeviceTimelineSemaphorePropertiesKHR;
PPVkPhysicalDeviceTimelineSemaphorePropertiesKHR = ^PVkPhysicalDeviceTimelineSemaphorePropertiesKHR;
VkSemaphoreTypeCreateInfoKHR = VkSemaphoreTypeCreateInfo;
PVkSemaphoreTypeCreateInfoKHR = ^VkSemaphoreTypeCreateInfoKHR;
PPVkSemaphoreTypeCreateInfoKHR = ^PVkSemaphoreTypeCreateInfoKHR;
VkTimelineSemaphoreSubmitInfoKHR = VkTimelineSemaphoreSubmitInfo;
PVkTimelineSemaphoreSubmitInfoKHR = ^VkTimelineSemaphoreSubmitInfoKHR;
PPVkTimelineSemaphoreSubmitInfoKHR = ^PVkTimelineSemaphoreSubmitInfoKHR;
VkSemaphoreWaitInfoKHR = VkSemaphoreWaitInfo;
PVkSemaphoreWaitInfoKHR = ^VkSemaphoreWaitInfoKHR;
PPVkSemaphoreWaitInfoKHR = ^PVkSemaphoreWaitInfoKHR;
VkSemaphoreSignalInfoKHR = VkSemaphoreSignalInfo;
PVkSemaphoreSignalInfoKHR = ^VkSemaphoreSignalInfoKHR;
PPVkSemaphoreSignalInfoKHR = ^PVkSemaphoreSignalInfoKHR;
VkPhysicalDevice8BitStorageFeaturesKHR = VkPhysicalDevice8BitStorageFeatures;
PVkPhysicalDevice8BitStorageFeaturesKHR = ^VkPhysicalDevice8BitStorageFeaturesKHR;
PPVkPhysicalDevice8BitStorageFeaturesKHR = ^PVkPhysicalDevice8BitStorageFeaturesKHR;
VkPhysicalDeviceVulkanMemoryModelFeaturesKHR = VkPhysicalDeviceVulkanMemoryModelFeatures;
PVkPhysicalDeviceVulkanMemoryModelFeaturesKHR = ^VkPhysicalDeviceVulkanMemoryModelFeaturesKHR;
PPVkPhysicalDeviceVulkanMemoryModelFeaturesKHR = ^PVkPhysicalDeviceVulkanMemoryModelFeaturesKHR;
VkPhysicalDeviceShaderAtomicInt64FeaturesKHR = VkPhysicalDeviceShaderAtomicInt64Features;
PVkPhysicalDeviceShaderAtomicInt64FeaturesKHR = ^VkPhysicalDeviceShaderAtomicInt64FeaturesKHR;
PPVkPhysicalDeviceShaderAtomicInt64FeaturesKHR = ^PVkPhysicalDeviceShaderAtomicInt64FeaturesKHR;
VkPhysicalDeviceDepthStencilResolvePropertiesKHR = VkPhysicalDeviceDepthStencilResolveProperties;
PVkPhysicalDeviceDepthStencilResolvePropertiesKHR = ^VkPhysicalDeviceDepthStencilResolvePropertiesKHR;
PPVkPhysicalDeviceDepthStencilResolvePropertiesKHR = ^PVkPhysicalDeviceDepthStencilResolvePropertiesKHR;
VkSubpassDescriptionDepthStencilResolveKHR = VkSubpassDescriptionDepthStencilResolve;
PVkSubpassDescriptionDepthStencilResolveKHR = ^VkSubpassDescriptionDepthStencilResolveKHR;
PPVkSubpassDescriptionDepthStencilResolveKHR = ^PVkSubpassDescriptionDepthStencilResolveKHR;
VkImageStencilUsageCreateInfoEXT = VkImageStencilUsageCreateInfo;
PVkImageStencilUsageCreateInfoEXT = ^VkImageStencilUsageCreateInfoEXT;
PPVkImageStencilUsageCreateInfoEXT = ^PVkImageStencilUsageCreateInfoEXT;
VkPhysicalDeviceScalarBlockLayoutFeaturesEXT = VkPhysicalDeviceScalarBlockLayoutFeatures;
PVkPhysicalDeviceScalarBlockLayoutFeaturesEXT = ^VkPhysicalDeviceScalarBlockLayoutFeaturesEXT;
PPVkPhysicalDeviceScalarBlockLayoutFeaturesEXT = ^PVkPhysicalDeviceScalarBlockLayoutFeaturesEXT;
VkPhysicalDeviceUniformBufferStandardLayoutFeaturesKHR = VkPhysicalDeviceUniformBufferStandardLayoutFeatures;
PVkPhysicalDeviceUniformBufferStandardLayoutFeaturesKHR = ^VkPhysicalDeviceUniformBufferStandardLayoutFeaturesKHR;
PPVkPhysicalDeviceUniformBufferStandardLayoutFeaturesKHR = ^PVkPhysicalDeviceUniformBufferStandardLayoutFeaturesKHR;
VkPhysicalDeviceBufferDeviceAddressFeaturesKHR = VkPhysicalDeviceBufferDeviceAddressFeatures;
PVkPhysicalDeviceBufferDeviceAddressFeaturesKHR = ^VkPhysicalDeviceBufferDeviceAddressFeaturesKHR;
PPVkPhysicalDeviceBufferDeviceAddressFeaturesKHR = ^PVkPhysicalDeviceBufferDeviceAddressFeaturesKHR;
VkPhysicalDeviceBufferAddressFeaturesEXT = VkPhysicalDeviceBufferDeviceAddressFeaturesEXT;
PVkPhysicalDeviceBufferAddressFeaturesEXT = ^VkPhysicalDeviceBufferAddressFeaturesEXT;
PPVkPhysicalDeviceBufferAddressFeaturesEXT = ^PVkPhysicalDeviceBufferAddressFeaturesEXT;
VkBufferDeviceAddressInfoKHR = VkBufferDeviceAddressInfo;
PVkBufferDeviceAddressInfoKHR = ^VkBufferDeviceAddressInfoKHR;
PPVkBufferDeviceAddressInfoKHR = ^PVkBufferDeviceAddressInfoKHR;
VkBufferDeviceAddressInfoEXT = VkBufferDeviceAddressInfo;
PVkBufferDeviceAddressInfoEXT = ^VkBufferDeviceAddressInfoEXT;
PPVkBufferDeviceAddressInfoEXT = ^PVkBufferDeviceAddressInfoEXT;
VkBufferOpaqueCaptureAddressCreateInfoKHR = VkBufferOpaqueCaptureAddressCreateInfo;
PVkBufferOpaqueCaptureAddressCreateInfoKHR = ^VkBufferOpaqueCaptureAddressCreateInfoKHR;
PPVkBufferOpaqueCaptureAddressCreateInfoKHR = ^PVkBufferOpaqueCaptureAddressCreateInfoKHR;
VkPhysicalDeviceImagelessFramebufferFeaturesKHR = VkPhysicalDeviceImagelessFramebufferFeatures;
PVkPhysicalDeviceImagelessFramebufferFeaturesKHR = ^VkPhysicalDeviceImagelessFramebufferFeaturesKHR;
PPVkPhysicalDeviceImagelessFramebufferFeaturesKHR = ^PVkPhysicalDeviceImagelessFramebufferFeaturesKHR;
VkFramebufferAttachmentsCreateInfoKHR = VkFramebufferAttachmentsCreateInfo;
PVkFramebufferAttachmentsCreateInfoKHR = ^VkFramebufferAttachmentsCreateInfoKHR;
PPVkFramebufferAttachmentsCreateInfoKHR = ^PVkFramebufferAttachmentsCreateInfoKHR;
VkFramebufferAttachmentImageInfoKHR = VkFramebufferAttachmentImageInfo;
PVkFramebufferAttachmentImageInfoKHR = ^VkFramebufferAttachmentImageInfoKHR;
PPVkFramebufferAttachmentImageInfoKHR = ^PVkFramebufferAttachmentImageInfoKHR;
VkRenderPassAttachmentBeginInfoKHR = VkRenderPassAttachmentBeginInfo;
PVkRenderPassAttachmentBeginInfoKHR = ^VkRenderPassAttachmentBeginInfoKHR;
PPVkRenderPassAttachmentBeginInfoKHR = ^PVkRenderPassAttachmentBeginInfoKHR;
VkQueryPoolCreateInfoINTEL = VkQueryPoolPerformanceQueryCreateInfoINTEL;
PVkQueryPoolCreateInfoINTEL = ^VkQueryPoolCreateInfoINTEL;
PPVkQueryPoolCreateInfoINTEL = ^PVkQueryPoolCreateInfoINTEL;
VkPhysicalDeviceSeparateDepthStencilLayoutsFeaturesKHR = VkPhysicalDeviceSeparateDepthStencilLayoutsFeatures;
PVkPhysicalDeviceSeparateDepthStencilLayoutsFeaturesKHR = ^VkPhysicalDeviceSeparateDepthStencilLayoutsFeaturesKHR;
PPVkPhysicalDeviceSeparateDepthStencilLayoutsFeaturesKHR = ^PVkPhysicalDeviceSeparateDepthStencilLayoutsFeaturesKHR;
VkAttachmentReferenceStencilLayoutKHR = VkAttachmentReferenceStencilLayout;
PVkAttachmentReferenceStencilLayoutKHR = ^VkAttachmentReferenceStencilLayoutKHR;
PPVkAttachmentReferenceStencilLayoutKHR = ^PVkAttachmentReferenceStencilLayoutKHR;
VkAttachmentDescriptionStencilLayoutKHR = VkAttachmentDescriptionStencilLayout;
PVkAttachmentDescriptionStencilLayoutKHR = ^VkAttachmentDescriptionStencilLayoutKHR;
PPVkAttachmentDescriptionStencilLayoutKHR = ^PVkAttachmentDescriptionStencilLayoutKHR;
VkMemoryOpaqueCaptureAddressAllocateInfoKHR = VkMemoryOpaqueCaptureAddressAllocateInfo;
PVkMemoryOpaqueCaptureAddressAllocateInfoKHR = ^VkMemoryOpaqueCaptureAddressAllocateInfoKHR;
PPVkMemoryOpaqueCaptureAddressAllocateInfoKHR = ^PVkMemoryOpaqueCaptureAddressAllocateInfoKHR;
VkDeviceMemoryOpaqueCaptureAddressInfoKHR = VkDeviceMemoryOpaqueCaptureAddressInfo;
PVkDeviceMemoryOpaqueCaptureAddressInfoKHR = ^VkDeviceMemoryOpaqueCaptureAddressInfoKHR;
PPVkDeviceMemoryOpaqueCaptureAddressInfoKHR = ^PVkDeviceMemoryOpaqueCaptureAddressInfoKHR;
VkAabbPositionsNV = VkAabbPositionsKHR;
PVkAabbPositionsNV = ^VkAabbPositionsNV;
PPVkAabbPositionsNV = ^PVkAabbPositionsNV;
VkTransformMatrixNV = VkTransformMatrixKHR;
PVkTransformMatrixNV = ^VkTransformMatrixNV;
PPVkTransformMatrixNV = ^PVkTransformMatrixNV;
VkAccelerationStructureInstanceNV = VkAccelerationStructureInstanceKHR;
PVkAccelerationStructureInstanceNV = ^VkAccelerationStructureInstanceNV;
PPVkAccelerationStructureInstanceNV = ^PVkAccelerationStructureInstanceNV;

PFN_vkCreateInstance = function  (
      pCreateInfo : PVkInstanceCreateInfo;
      pAllocator  : PVkAllocationCallbacks;
      pInstance   : PVkInstance
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyInstance = procedure (
      instance   : VkInstance;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkEnumeratePhysicalDevices = function  (
      instance             : VkInstance;
      pPhysicalDeviceCount : PUInt32;
      pPhysicalDevices     : PVkPhysicalDevice
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDeviceProcAddr = function  (
      device : VkDevice;
      pName  : PAnsiChar
  ): PFN_vkVoidFunction; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetInstanceProcAddr = function  (
      instance : VkInstance;
      pName    : PAnsiChar
  ): PFN_vkVoidFunction; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceProperties = procedure (
      physicalDevice : VkPhysicalDevice;
      pProperties    : PVkPhysicalDeviceProperties
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceQueueFamilyProperties = procedure (
      physicalDevice            : VkPhysicalDevice;
      pQueueFamilyPropertyCount : PUInt32;
      pQueueFamilyProperties    : PVkQueueFamilyProperties
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceMemoryProperties = procedure (
      physicalDevice    : VkPhysicalDevice;
      pMemoryProperties : PVkPhysicalDeviceMemoryProperties
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceFeatures = procedure (
      physicalDevice : VkPhysicalDevice;
      pFeatures      : PVkPhysicalDeviceFeatures
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceFormatProperties = procedure (
      physicalDevice    : VkPhysicalDevice;
      format            : VkFormat;
      pFormatProperties : PVkFormatProperties
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceImageFormatProperties = function  (
      physicalDevice         : VkPhysicalDevice;
      format                 : VkFormat;
      _type                  : VkImageType;
      tiling                 : VkImageTiling;
      usage                  : VkImageUsageFlags;
      flags                  : VkImageCreateFlags;
      pImageFormatProperties : PVkImageFormatProperties
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateDevice = function  (
      physicalDevice : VkPhysicalDevice;
      pCreateInfo    : PVkDeviceCreateInfo;
      pAllocator     : PVkAllocationCallbacks;
      pDevice        : PVkDevice
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyDevice = procedure (
      device     : VkDevice;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkEnumerateInstanceVersion = function  (
      pApiVersion : PUInt32
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkEnumerateInstanceLayerProperties = function  (
      pPropertyCount : PUInt32;
      pProperties    : PVkLayerProperties
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkEnumerateInstanceExtensionProperties = function  (
      pLayerName     : PAnsiChar;
      pPropertyCount : PUInt32;
      pProperties    : PVkExtensionProperties
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkEnumerateDeviceLayerProperties = function  (
      physicalDevice : VkPhysicalDevice;
      pPropertyCount : PUInt32;
      pProperties    : PVkLayerProperties
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkEnumerateDeviceExtensionProperties = function  (
      physicalDevice : VkPhysicalDevice;
      pLayerName     : PAnsiChar;
      pPropertyCount : PUInt32;
      pProperties    : PVkExtensionProperties
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDeviceQueue = procedure (
      device           : VkDevice;
      queueFamilyIndex : UInt32;
      queueIndex       : UInt32;
      pQueue           : PVkQueue
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkQueueSubmit = function  (
      queue       : VkQueue;
      submitCount : UInt32;
      pSubmits    : PVkSubmitInfo;
      fence       : VkFence
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkQueueWaitIdle = function  (
      queue : VkQueue
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDeviceWaitIdle = function  (
      device : VkDevice
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkAllocateMemory = function  (
      device        : VkDevice;
      pAllocateInfo : PVkMemoryAllocateInfo;
      pAllocator    : PVkAllocationCallbacks;
      pMemory       : PVkDeviceMemory
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkFreeMemory = procedure (
      device     : VkDevice;
      memory     : VkDeviceMemory;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkMapMemory = function  (
      device : VkDevice;
      memory : VkDeviceMemory;
      offset : VkDeviceSize;
      size   : VkDeviceSize;
      flags  : VkMemoryMapFlags;
      ppData : Pvoid
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkUnmapMemory = procedure (
      device : VkDevice;
      memory : VkDeviceMemory
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkFlushMappedMemoryRanges = function  (
      device           : VkDevice;
      memoryRangeCount : UInt32;
      pMemoryRanges    : PVkMappedMemoryRange
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkInvalidateMappedMemoryRanges = function  (
      device           : VkDevice;
      memoryRangeCount : UInt32;
      pMemoryRanges    : PVkMappedMemoryRange
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDeviceMemoryCommitment = procedure (
      device                  : VkDevice;
      memory                  : VkDeviceMemory;
      pCommittedMemoryInBytes : PVkDeviceSize
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetBufferMemoryRequirements = procedure (
      device              : VkDevice;
      buffer              : VkBuffer;
      pMemoryRequirements : PVkMemoryRequirements
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkBindBufferMemory = function  (
      device       : VkDevice;
      buffer       : VkBuffer;
      memory       : VkDeviceMemory;
      memoryOffset : VkDeviceSize
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetImageMemoryRequirements = procedure (
      device              : VkDevice;
      image               : VkImage;
      pMemoryRequirements : PVkMemoryRequirements
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkBindImageMemory = function  (
      device       : VkDevice;
      image        : VkImage;
      memory       : VkDeviceMemory;
      memoryOffset : VkDeviceSize
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetImageSparseMemoryRequirements = procedure (
      device                        : VkDevice;
      image                         : VkImage;
      pSparseMemoryRequirementCount : PUInt32;
      pSparseMemoryRequirements     : PVkSparseImageMemoryRequirements
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceSparseImageFormatProperties = procedure (
      physicalDevice : VkPhysicalDevice;
      format         : VkFormat;
      _type          : VkImageType;
      samples        : VkSampleCountFlagBits;
      usage          : VkImageUsageFlags;
      tiling         : VkImageTiling;
      pPropertyCount : PUInt32;
      pProperties    : PVkSparseImageFormatProperties
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkQueueBindSparse = function  (
      queue         : VkQueue;
      bindInfoCount : UInt32;
      pBindInfo     : PVkBindSparseInfo;
      fence         : VkFence
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateFence = function  (
      device      : VkDevice;
      pCreateInfo : PVkFenceCreateInfo;
      pAllocator  : PVkAllocationCallbacks;
      pFence      : PVkFence
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyFence = procedure (
      device     : VkDevice;
      fence      : VkFence;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkResetFences = function  (
      device     : VkDevice;
      fenceCount : UInt32;
      pFences    : PVkFence
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetFenceStatus = function  (
      device : VkDevice;
      fence  : VkFence
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkWaitForFences = function  (
      device     : VkDevice;
      fenceCount : UInt32;
      pFences    : PVkFence;
      waitAll    : VkBool32;
      timeout    : UInt64
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateSemaphore = function  (
      device      : VkDevice;
      pCreateInfo : PVkSemaphoreCreateInfo;
      pAllocator  : PVkAllocationCallbacks;
      pSemaphore  : PVkSemaphore
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroySemaphore = procedure (
      device     : VkDevice;
      semaphore  : VkSemaphore;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateEvent = function  (
      device      : VkDevice;
      pCreateInfo : PVkEventCreateInfo;
      pAllocator  : PVkAllocationCallbacks;
      pEvent      : PVkEvent
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyEvent = procedure (
      device     : VkDevice;
      event      : VkEvent;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetEventStatus = function  (
      device : VkDevice;
      event  : VkEvent
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkSetEvent = function  (
      device : VkDevice;
      event  : VkEvent
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkResetEvent = function  (
      device : VkDevice;
      event  : VkEvent
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateQueryPool = function  (
      device      : VkDevice;
      pCreateInfo : PVkQueryPoolCreateInfo;
      pAllocator  : PVkAllocationCallbacks;
      pQueryPool  : PVkQueryPool
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyQueryPool = procedure (
      device     : VkDevice;
      queryPool  : VkQueryPool;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetQueryPoolResults = function  (
      device     : VkDevice;
      queryPool  : VkQueryPool;
      firstQuery : UInt32;
      queryCount : UInt32;
      dataSize   : SizeUInt;
      pData      : Pvoid;
      stride     : VkDeviceSize;
      flags      : VkQueryResultFlags
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkResetQueryPool = procedure (
      device     : VkDevice;
      queryPool  : VkQueryPool;
      firstQuery : UInt32;
      queryCount : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateBuffer = function  (
      device      : VkDevice;
      pCreateInfo : PVkBufferCreateInfo;
      pAllocator  : PVkAllocationCallbacks;
      pBuffer     : PVkBuffer
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyBuffer = procedure (
      device     : VkDevice;
      buffer     : VkBuffer;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateBufferView = function  (
      device      : VkDevice;
      pCreateInfo : PVkBufferViewCreateInfo;
      pAllocator  : PVkAllocationCallbacks;
      pView       : PVkBufferView
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyBufferView = procedure (
      device     : VkDevice;
      bufferView : VkBufferView;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateImage = function  (
      device      : VkDevice;
      pCreateInfo : PVkImageCreateInfo;
      pAllocator  : PVkAllocationCallbacks;
      pImage      : PVkImage
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyImage = procedure (
      device     : VkDevice;
      image      : VkImage;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetImageSubresourceLayout = procedure (
      device       : VkDevice;
      image        : VkImage;
      pSubresource : PVkImageSubresource;
      pLayout      : PVkSubresourceLayout
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateImageView = function  (
      device      : VkDevice;
      pCreateInfo : PVkImageViewCreateInfo;
      pAllocator  : PVkAllocationCallbacks;
      pView       : PVkImageView
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyImageView = procedure (
      device     : VkDevice;
      imageView  : VkImageView;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateShaderModule = function  (
      device        : VkDevice;
      pCreateInfo   : PVkShaderModuleCreateInfo;
      pAllocator    : PVkAllocationCallbacks;
      pShaderModule : PVkShaderModule
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyShaderModule = procedure (
      device       : VkDevice;
      shaderModule : VkShaderModule;
      pAllocator   : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreatePipelineCache = function  (
      device         : VkDevice;
      pCreateInfo    : PVkPipelineCacheCreateInfo;
      pAllocator     : PVkAllocationCallbacks;
      pPipelineCache : PVkPipelineCache
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyPipelineCache = procedure (
      device        : VkDevice;
      pipelineCache : VkPipelineCache;
      pAllocator    : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPipelineCacheData = function  (
      device        : VkDevice;
      pipelineCache : VkPipelineCache;
      pDataSize     : PSizeUInt;
      pData         : Pvoid
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkMergePipelineCaches = function  (
      device        : VkDevice;
      dstCache      : VkPipelineCache;
      srcCacheCount : UInt32;
      pSrcCaches    : PVkPipelineCache
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateGraphicsPipelines = function  (
      device          : VkDevice;
      pipelineCache   : VkPipelineCache;
      createInfoCount : UInt32;
      pCreateInfos    : PVkGraphicsPipelineCreateInfo;
      pAllocator      : PVkAllocationCallbacks;
      pPipelines      : PVkPipeline
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateComputePipelines = function  (
      device          : VkDevice;
      pipelineCache   : VkPipelineCache;
      createInfoCount : UInt32;
      pCreateInfos    : PVkComputePipelineCreateInfo;
      pAllocator      : PVkAllocationCallbacks;
      pPipelines      : PVkPipeline
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI = function  (
      device            : VkDevice;
      renderpass        : VkRenderPass;
      pMaxWorkgroupSize : PVkExtent2D
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyPipeline = procedure (
      device     : VkDevice;
      pipeline   : VkPipeline;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreatePipelineLayout = function  (
      device          : VkDevice;
      pCreateInfo     : PVkPipelineLayoutCreateInfo;
      pAllocator      : PVkAllocationCallbacks;
      pPipelineLayout : PVkPipelineLayout
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyPipelineLayout = procedure (
      device         : VkDevice;
      pipelineLayout : VkPipelineLayout;
      pAllocator     : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateSampler = function  (
      device      : VkDevice;
      pCreateInfo : PVkSamplerCreateInfo;
      pAllocator  : PVkAllocationCallbacks;
      pSampler    : PVkSampler
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroySampler = procedure (
      device     : VkDevice;
      sampler    : VkSampler;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateDescriptorSetLayout = function  (
      device      : VkDevice;
      pCreateInfo : PVkDescriptorSetLayoutCreateInfo;
      pAllocator  : PVkAllocationCallbacks;
      pSetLayout  : PVkDescriptorSetLayout
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyDescriptorSetLayout = procedure (
      device              : VkDevice;
      descriptorSetLayout : VkDescriptorSetLayout;
      pAllocator          : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateDescriptorPool = function  (
      device          : VkDevice;
      pCreateInfo     : PVkDescriptorPoolCreateInfo;
      pAllocator      : PVkAllocationCallbacks;
      pDescriptorPool : PVkDescriptorPool
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyDescriptorPool = procedure (
      device         : VkDevice;
      descriptorPool : VkDescriptorPool;
      pAllocator     : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkResetDescriptorPool = function  (
      device         : VkDevice;
      descriptorPool : VkDescriptorPool;
      flags          : VkDescriptorPoolResetFlags
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkAllocateDescriptorSets = function  (
      device          : VkDevice;
      pAllocateInfo   : PVkDescriptorSetAllocateInfo;
      pDescriptorSets : PVkDescriptorSet
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkFreeDescriptorSets = function  (
      device             : VkDevice;
      descriptorPool     : VkDescriptorPool;
      descriptorSetCount : UInt32;
      pDescriptorSets    : PVkDescriptorSet
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkUpdateDescriptorSets = procedure (
      device               : VkDevice;
      descriptorWriteCount : UInt32;
      pDescriptorWrites    : PVkWriteDescriptorSet;
      descriptorCopyCount  : UInt32;
      pDescriptorCopies    : PVkCopyDescriptorSet
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateFramebuffer = function  (
      device       : VkDevice;
      pCreateInfo  : PVkFramebufferCreateInfo;
      pAllocator   : PVkAllocationCallbacks;
      pFramebuffer : PVkFramebuffer
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyFramebuffer = procedure (
      device      : VkDevice;
      framebuffer : VkFramebuffer;
      pAllocator  : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateRenderPass = function  (
      device      : VkDevice;
      pCreateInfo : PVkRenderPassCreateInfo;
      pAllocator  : PVkAllocationCallbacks;
      pRenderPass : PVkRenderPass
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyRenderPass = procedure (
      device     : VkDevice;
      renderPass : VkRenderPass;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetRenderAreaGranularity = procedure (
      device       : VkDevice;
      renderPass   : VkRenderPass;
      pGranularity : PVkExtent2D
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateCommandPool = function  (
      device       : VkDevice;
      pCreateInfo  : PVkCommandPoolCreateInfo;
      pAllocator   : PVkAllocationCallbacks;
      pCommandPool : PVkCommandPool
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyCommandPool = procedure (
      device      : VkDevice;
      commandPool : VkCommandPool;
      pAllocator  : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkResetCommandPool = function  (
      device      : VkDevice;
      commandPool : VkCommandPool;
      flags       : VkCommandPoolResetFlags
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkAllocateCommandBuffers = function  (
      device          : VkDevice;
      pAllocateInfo   : PVkCommandBufferAllocateInfo;
      pCommandBuffers : PVkCommandBuffer
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkFreeCommandBuffers = procedure (
      device             : VkDevice;
      commandPool        : VkCommandPool;
      commandBufferCount : UInt32;
      pCommandBuffers    : PVkCommandBuffer
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkBeginCommandBuffer = function  (
      commandBuffer : VkCommandBuffer;
      pBeginInfo    : PVkCommandBufferBeginInfo
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkEndCommandBuffer = function  (
      commandBuffer : VkCommandBuffer
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkResetCommandBuffer = function  (
      commandBuffer : VkCommandBuffer;
      flags         : VkCommandBufferResetFlags
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBindPipeline = procedure (
      commandBuffer     : VkCommandBuffer;
      pipelineBindPoint : VkPipelineBindPoint;
      pipeline          : VkPipeline
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetViewport = procedure (
      commandBuffer : VkCommandBuffer;
      firstViewport : UInt32;
      viewportCount : UInt32;
      pViewports    : PVkViewport
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetScissor = procedure (
      commandBuffer : VkCommandBuffer;
      firstScissor  : UInt32;
      scissorCount  : UInt32;
      pScissors     : PVkRect2D
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetLineWidth = procedure (
      commandBuffer : VkCommandBuffer;
      lineWidth     : Single
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetDepthBias = procedure (
      commandBuffer           : VkCommandBuffer;
      depthBiasConstantFactor : Single;
      depthBiasClamp          : Single;
      depthBiasSlopeFactor    : Single
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetBlendConstants = procedure (
      commandBuffer  : VkCommandBuffer;
      blendConstants : Single
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetDepthBounds = procedure (
      commandBuffer  : VkCommandBuffer;
      minDepthBounds : Single;
      maxDepthBounds : Single
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetStencilCompareMask = procedure (
      commandBuffer : VkCommandBuffer;
      faceMask      : VkStencilFaceFlags;
      compareMask   : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetStencilWriteMask = procedure (
      commandBuffer : VkCommandBuffer;
      faceMask      : VkStencilFaceFlags;
      writeMask     : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetStencilReference = procedure (
      commandBuffer : VkCommandBuffer;
      faceMask      : VkStencilFaceFlags;
      reference     : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBindDescriptorSets = procedure (
      commandBuffer      : VkCommandBuffer;
      pipelineBindPoint  : VkPipelineBindPoint;
      layout             : VkPipelineLayout;
      firstSet           : UInt32;
      descriptorSetCount : UInt32;
      pDescriptorSets    : PVkDescriptorSet;
      dynamicOffsetCount : UInt32;
      pDynamicOffsets    : PUInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBindIndexBuffer = procedure (
      commandBuffer : VkCommandBuffer;
      buffer        : VkBuffer;
      offset        : VkDeviceSize;
      indexType     : VkIndexType
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBindVertexBuffers = procedure (
      commandBuffer : VkCommandBuffer;
      firstBinding  : UInt32;
      bindingCount  : UInt32;
      pBuffers      : PVkBuffer;
      pOffsets      : PVkDeviceSize
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDraw = procedure (
      commandBuffer : VkCommandBuffer;
      vertexCount   : UInt32;
      instanceCount : UInt32;
      firstVertex   : UInt32;
      firstInstance : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDrawIndexed = procedure (
      commandBuffer : VkCommandBuffer;
      indexCount    : UInt32;
      instanceCount : UInt32;
      firstIndex    : UInt32;
      vertexOffset  : Int32;
      firstInstance : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDrawMultiEXT = procedure (
      commandBuffer : VkCommandBuffer;
      drawCount     : UInt32;
      pVertexInfo   : PVkMultiDrawInfoEXT;
      instanceCount : UInt32;
      firstInstance : UInt32;
      stride        : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDrawMultiIndexedEXT = procedure (
      commandBuffer : VkCommandBuffer;
      drawCount     : UInt32;
      pIndexInfo    : PVkMultiDrawIndexedInfoEXT;
      instanceCount : UInt32;
      firstInstance : UInt32;
      stride        : UInt32;
      pVertexOffset : PInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDrawIndirect = procedure (
      commandBuffer : VkCommandBuffer;
      buffer        : VkBuffer;
      offset        : VkDeviceSize;
      drawCount     : UInt32;
      stride        : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDrawIndexedIndirect = procedure (
      commandBuffer : VkCommandBuffer;
      buffer        : VkBuffer;
      offset        : VkDeviceSize;
      drawCount     : UInt32;
      stride        : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDispatch = procedure (
      commandBuffer : VkCommandBuffer;
      groupCountX   : UInt32;
      groupCountY   : UInt32;
      groupCountZ   : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDispatchIndirect = procedure (
      commandBuffer : VkCommandBuffer;
      buffer        : VkBuffer;
      offset        : VkDeviceSize
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSubpassShadingHUAWEI = procedure (
      commandBuffer : VkCommandBuffer
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdCopyBuffer = procedure (
      commandBuffer : VkCommandBuffer;
      srcBuffer     : VkBuffer;
      dstBuffer     : VkBuffer;
      regionCount   : UInt32;
      pRegions      : PVkBufferCopy
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdCopyImage = procedure (
      commandBuffer  : VkCommandBuffer;
      srcImage       : VkImage;
      srcImageLayout : VkImageLayout;
      dstImage       : VkImage;
      dstImageLayout : VkImageLayout;
      regionCount    : UInt32;
      pRegions       : PVkImageCopy
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBlitImage = procedure (
      commandBuffer  : VkCommandBuffer;
      srcImage       : VkImage;
      srcImageLayout : VkImageLayout;
      dstImage       : VkImage;
      dstImageLayout : VkImageLayout;
      regionCount    : UInt32;
      pRegions       : PVkImageBlit;
      filter         : VkFilter
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdCopyBufferToImage = procedure (
      commandBuffer  : VkCommandBuffer;
      srcBuffer      : VkBuffer;
      dstImage       : VkImage;
      dstImageLayout : VkImageLayout;
      regionCount    : UInt32;
      pRegions       : PVkBufferImageCopy
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdCopyImageToBuffer = procedure (
      commandBuffer  : VkCommandBuffer;
      srcImage       : VkImage;
      srcImageLayout : VkImageLayout;
      dstBuffer      : VkBuffer;
      regionCount    : UInt32;
      pRegions       : PVkBufferImageCopy
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdUpdateBuffer = procedure (
      commandBuffer : VkCommandBuffer;
      dstBuffer     : VkBuffer;
      dstOffset     : VkDeviceSize;
      dataSize      : VkDeviceSize;
      pData         : Pvoid
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdFillBuffer = procedure (
      commandBuffer : VkCommandBuffer;
      dstBuffer     : VkBuffer;
      dstOffset     : VkDeviceSize;
      size          : VkDeviceSize;
      data          : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdClearColorImage = procedure (
      commandBuffer : VkCommandBuffer;
      image         : VkImage;
      imageLayout   : VkImageLayout;
      pColor        : PVkClearColorValue;
      rangeCount    : UInt32;
      pRanges       : PVkImageSubresourceRange
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdClearDepthStencilImage = procedure (
      commandBuffer : VkCommandBuffer;
      image         : VkImage;
      imageLayout   : VkImageLayout;
      pDepthStencil : PVkClearDepthStencilValue;
      rangeCount    : UInt32;
      pRanges       : PVkImageSubresourceRange
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdClearAttachments = procedure (
      commandBuffer   : VkCommandBuffer;
      attachmentCount : UInt32;
      pAttachments    : PVkClearAttachment;
      rectCount       : UInt32;
      pRects          : PVkClearRect
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdResolveImage = procedure (
      commandBuffer  : VkCommandBuffer;
      srcImage       : VkImage;
      srcImageLayout : VkImageLayout;
      dstImage       : VkImage;
      dstImageLayout : VkImageLayout;
      regionCount    : UInt32;
      pRegions       : PVkImageResolve
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetEvent = procedure (
      commandBuffer : VkCommandBuffer;
      event         : VkEvent;
      stageMask     : VkPipelineStageFlags
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdResetEvent = procedure (
      commandBuffer : VkCommandBuffer;
      event         : VkEvent;
      stageMask     : VkPipelineStageFlags
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdWaitEvents = procedure (
      commandBuffer            : VkCommandBuffer;
      eventCount               : UInt32;
      pEvents                  : PVkEvent;
      srcStageMask             : VkPipelineStageFlags;
      dstStageMask             : VkPipelineStageFlags;
      memoryBarrierCount       : UInt32;
      pMemoryBarriers          : PVkMemoryBarrier;
      bufferMemoryBarrierCount : UInt32;
      pBufferMemoryBarriers    : PVkBufferMemoryBarrier;
      imageMemoryBarrierCount  : UInt32;
      pImageMemoryBarriers     : PVkImageMemoryBarrier
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdPipelineBarrier = procedure (
      commandBuffer            : VkCommandBuffer;
      srcStageMask             : VkPipelineStageFlags;
      dstStageMask             : VkPipelineStageFlags;
      dependencyFlags          : VkDependencyFlags;
      memoryBarrierCount       : UInt32;
      pMemoryBarriers          : PVkMemoryBarrier;
      bufferMemoryBarrierCount : UInt32;
      pBufferMemoryBarriers    : PVkBufferMemoryBarrier;
      imageMemoryBarrierCount  : UInt32;
      pImageMemoryBarriers     : PVkImageMemoryBarrier
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBeginQuery = procedure (
      commandBuffer : VkCommandBuffer;
      queryPool     : VkQueryPool;
      query         : UInt32;
      flags         : VkQueryControlFlags
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdEndQuery = procedure (
      commandBuffer : VkCommandBuffer;
      queryPool     : VkQueryPool;
      query         : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBeginConditionalRenderingEXT = procedure (
      commandBuffer              : VkCommandBuffer;
      pConditionalRenderingBegin : PVkConditionalRenderingBeginInfoEXT
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdEndConditionalRenderingEXT = procedure (
      commandBuffer : VkCommandBuffer
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdResetQueryPool = procedure (
      commandBuffer : VkCommandBuffer;
      queryPool     : VkQueryPool;
      firstQuery    : UInt32;
      queryCount    : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdWriteTimestamp = procedure (
      commandBuffer : VkCommandBuffer;
      pipelineStage : VkPipelineStageFlagBits;
      queryPool     : VkQueryPool;
      query         : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdCopyQueryPoolResults = procedure (
      commandBuffer : VkCommandBuffer;
      queryPool     : VkQueryPool;
      firstQuery    : UInt32;
      queryCount    : UInt32;
      dstBuffer     : VkBuffer;
      dstOffset     : VkDeviceSize;
      stride        : VkDeviceSize;
      flags         : VkQueryResultFlags
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdPushConstants = procedure (
      commandBuffer : VkCommandBuffer;
      layout        : VkPipelineLayout;
      stageFlags    : VkShaderStageFlags;
      offset        : UInt32;
      size          : UInt32;
      pValues       : Pvoid
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBeginRenderPass = procedure (
      commandBuffer    : VkCommandBuffer;
      pRenderPassBegin : PVkRenderPassBeginInfo;
      contents         : VkSubpassContents
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdNextSubpass = procedure (
      commandBuffer : VkCommandBuffer;
      contents      : VkSubpassContents
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdEndRenderPass = procedure (
      commandBuffer : VkCommandBuffer
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdExecuteCommands = procedure (
      commandBuffer      : VkCommandBuffer;
      commandBufferCount : UInt32;
      pCommandBuffers    : PVkCommandBuffer
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateAndroidSurfaceKHR = function  (
      instance    : VkInstance;
      pCreateInfo : PVkAndroidSurfaceCreateInfoKHR;
      pAllocator  : PVkAllocationCallbacks;
      pSurface    : PVkSurfaceKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceDisplayPropertiesKHR = function  (
      physicalDevice : VkPhysicalDevice;
      pPropertyCount : PUInt32;
      pProperties    : PVkDisplayPropertiesKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceDisplayPlanePropertiesKHR = function  (
      physicalDevice : VkPhysicalDevice;
      pPropertyCount : PUInt32;
      pProperties    : PVkDisplayPlanePropertiesKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDisplayPlaneSupportedDisplaysKHR = function  (
      physicalDevice : VkPhysicalDevice;
      planeIndex     : UInt32;
      pDisplayCount  : PUInt32;
      pDisplays      : PVkDisplayKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDisplayModePropertiesKHR = function  (
      physicalDevice : VkPhysicalDevice;
      display        : VkDisplayKHR;
      pPropertyCount : PUInt32;
      pProperties    : PVkDisplayModePropertiesKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateDisplayModeKHR = function  (
      physicalDevice : VkPhysicalDevice;
      display        : VkDisplayKHR;
      pCreateInfo    : PVkDisplayModeCreateInfoKHR;
      pAllocator     : PVkAllocationCallbacks;
      pMode          : PVkDisplayModeKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDisplayPlaneCapabilitiesKHR = function  (
      physicalDevice : VkPhysicalDevice;
      mode           : VkDisplayModeKHR;
      planeIndex     : UInt32;
      pCapabilities  : PVkDisplayPlaneCapabilitiesKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateDisplayPlaneSurfaceKHR = function  (
      instance    : VkInstance;
      pCreateInfo : PVkDisplaySurfaceCreateInfoKHR;
      pAllocator  : PVkAllocationCallbacks;
      pSurface    : PVkSurfaceKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateSharedSwapchainsKHR = function  (
      device         : VkDevice;
      swapchainCount : UInt32;
      pCreateInfos   : PVkSwapchainCreateInfoKHR;
      pAllocator     : PVkAllocationCallbacks;
      pSwapchains    : PVkSwapchainKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroySurfaceKHR = procedure (
      instance   : VkInstance;
      surface    : VkSurfaceKHR;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceSurfaceSupportKHR = function  (
      physicalDevice   : VkPhysicalDevice;
      queueFamilyIndex : UInt32;
      surface          : VkSurfaceKHR;
      pSupported       : PVkBool32
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceSurfaceCapabilitiesKHR = function  (
      physicalDevice       : VkPhysicalDevice;
      surface              : VkSurfaceKHR;
      pSurfaceCapabilities : PVkSurfaceCapabilitiesKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceSurfaceFormatsKHR = function  (
      physicalDevice      : VkPhysicalDevice;
      surface             : VkSurfaceKHR;
      pSurfaceFormatCount : PUInt32;
      pSurfaceFormats     : PVkSurfaceFormatKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceSurfacePresentModesKHR = function  (
      physicalDevice    : VkPhysicalDevice;
      surface           : VkSurfaceKHR;
      pPresentModeCount : PUInt32;
      pPresentModes     : PVkPresentModeKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateSwapchainKHR = function  (
      device      : VkDevice;
      pCreateInfo : PVkSwapchainCreateInfoKHR;
      pAllocator  : PVkAllocationCallbacks;
      pSwapchain  : PVkSwapchainKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroySwapchainKHR = procedure (
      device     : VkDevice;
      swapchain  : VkSwapchainKHR;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetSwapchainImagesKHR = function  (
      device               : VkDevice;
      swapchain            : VkSwapchainKHR;
      pSwapchainImageCount : PUInt32;
      pSwapchainImages     : PVkImage
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkAcquireNextImageKHR = function  (
      device      : VkDevice;
      swapchain   : VkSwapchainKHR;
      timeout     : UInt64;
      semaphore   : VkSemaphore;
      fence       : VkFence;
      pImageIndex : PUInt32
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkQueuePresentKHR = function  (
      queue        : VkQueue;
      pPresentInfo : PVkPresentInfoKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateViSurfaceNN = function  (
      instance    : VkInstance;
      pCreateInfo : PVkViSurfaceCreateInfoNN;
      pAllocator  : PVkAllocationCallbacks;
      pSurface    : PVkSurfaceKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateWin32SurfaceKHR = function  (
      instance    : VkInstance;
      pCreateInfo : PVkWin32SurfaceCreateInfoKHR;
      pAllocator  : PVkAllocationCallbacks;
      pSurface    : PVkSurfaceKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceWin32PresentationSupportKHR = function  (
      physicalDevice   : VkPhysicalDevice;
      queueFamilyIndex : UInt32
  ): UInt32; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateDebugReportCallbackEXT = function  (
      instance    : VkInstance;
      pCreateInfo : PVkDebugReportCallbackCreateInfoEXT;
      pAllocator  : PVkAllocationCallbacks;
      pCallback   : PVkDebugReportCallbackEXT
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyDebugReportCallbackEXT = procedure (
      instance   : VkInstance;
      callback   : VkDebugReportCallbackEXT;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDebugReportMessageEXT = procedure (
      instance     : VkInstance;
      flags        : VkDebugReportFlagsEXT;
      objectType   : VkDebugReportObjectTypeEXT;
      _object      : UInt64;
      location     : SizeUInt;
      messageCode  : Int32;
      pLayerPrefix : PAnsiChar;
      pMessage     : PAnsiChar
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDebugMarkerSetObjectNameEXT = function  (
      device    : VkDevice;
      pNameInfo : PVkDebugMarkerObjectNameInfoEXT
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDebugMarkerSetObjectTagEXT = function  (
      device   : VkDevice;
      pTagInfo : PVkDebugMarkerObjectTagInfoEXT
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDebugMarkerBeginEXT = procedure (
      commandBuffer : VkCommandBuffer;
      pMarkerInfo   : PVkDebugMarkerMarkerInfoEXT
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDebugMarkerEndEXT = procedure (
      commandBuffer : VkCommandBuffer
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDebugMarkerInsertEXT = procedure (
      commandBuffer : VkCommandBuffer;
      pMarkerInfo   : PVkDebugMarkerMarkerInfoEXT
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceExternalImageFormatPropertiesNV = function  (
      physicalDevice                 : VkPhysicalDevice;
      format                         : VkFormat;
      _type                          : VkImageType;
      tiling                         : VkImageTiling;
      usage                          : VkImageUsageFlags;
      flags                          : VkImageCreateFlags;
      externalHandleType             : VkExternalMemoryHandleTypeFlagsNV;
      pExternalImageFormatProperties : PVkExternalImageFormatPropertiesNV
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetMemoryWin32HandleNV = function  (
      device     : VkDevice;
      memory     : VkDeviceMemory;
      handleType : VkExternalMemoryHandleTypeFlagsNV;
      pHandle    : PHANDLE
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdExecuteGeneratedCommandsNV = procedure (
      commandBuffer          : VkCommandBuffer;
      isPreprocessed         : VkBool32;
      pGeneratedCommandsInfo : PVkGeneratedCommandsInfoNV
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdPreprocessGeneratedCommandsNV = procedure (
      commandBuffer          : VkCommandBuffer;
      pGeneratedCommandsInfo : PVkGeneratedCommandsInfoNV
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBindPipelineShaderGroupNV = procedure (
      commandBuffer     : VkCommandBuffer;
      pipelineBindPoint : VkPipelineBindPoint;
      pipeline          : VkPipeline;
      groupIndex        : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetGeneratedCommandsMemoryRequirementsNV = procedure (
      device              : VkDevice;
      pInfo               : PVkGeneratedCommandsMemoryRequirementsInfoNV;
      pMemoryRequirements : PVkMemoryRequirements2
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateIndirectCommandsLayoutNV = function  (
      device                  : VkDevice;
      pCreateInfo             : PVkIndirectCommandsLayoutCreateInfoNV;
      pAllocator              : PVkAllocationCallbacks;
      pIndirectCommandsLayout : PVkIndirectCommandsLayoutNV
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyIndirectCommandsLayoutNV = procedure (
      device                 : VkDevice;
      indirectCommandsLayout : VkIndirectCommandsLayoutNV;
      pAllocator             : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceFeatures2 = procedure (
      physicalDevice : VkPhysicalDevice;
      pFeatures      : PVkPhysicalDeviceFeatures2
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceProperties2 = procedure (
      physicalDevice : VkPhysicalDevice;
      pProperties    : PVkPhysicalDeviceProperties2
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceFormatProperties2 = procedure (
      physicalDevice    : VkPhysicalDevice;
      format            : VkFormat;
      pFormatProperties : PVkFormatProperties2
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceImageFormatProperties2 = function  (
      physicalDevice         : VkPhysicalDevice;
      pImageFormatInfo       : PVkPhysicalDeviceImageFormatInfo2;
      pImageFormatProperties : PVkImageFormatProperties2
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceQueueFamilyProperties2 = procedure (
      physicalDevice            : VkPhysicalDevice;
      pQueueFamilyPropertyCount : PUInt32;
      pQueueFamilyProperties    : PVkQueueFamilyProperties2
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceMemoryProperties2 = procedure (
      physicalDevice    : VkPhysicalDevice;
      pMemoryProperties : PVkPhysicalDeviceMemoryProperties2
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceSparseImageFormatProperties2 = procedure (
      physicalDevice : VkPhysicalDevice;
      pFormatInfo    : PVkPhysicalDeviceSparseImageFormatInfo2;
      pPropertyCount : PUInt32;
      pProperties    : PVkSparseImageFormatProperties2
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdPushDescriptorSetKHR = procedure (
      commandBuffer        : VkCommandBuffer;
      pipelineBindPoint    : VkPipelineBindPoint;
      layout               : VkPipelineLayout;
      _set                 : UInt32;
      descriptorWriteCount : UInt32;
      pDescriptorWrites    : PVkWriteDescriptorSet
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkTrimCommandPool = procedure (
      device      : VkDevice;
      commandPool : VkCommandPool;
      flags       : VkCommandPoolTrimFlags
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceExternalBufferProperties = procedure (
      physicalDevice            : VkPhysicalDevice;
      pExternalBufferInfo       : PVkPhysicalDeviceExternalBufferInfo;
      pExternalBufferProperties : PVkExternalBufferProperties
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetMemoryWin32HandleKHR = function  (
      device              : VkDevice;
      pGetWin32HandleInfo : PVkMemoryGetWin32HandleInfoKHR;
      pHandle             : PHANDLE
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetMemoryWin32HandlePropertiesKHR = function  (
      device                       : VkDevice;
      handleType                   : VkExternalMemoryHandleTypeFlagBits;
      handle                       : HANDLE;
      pMemoryWin32HandleProperties : PVkMemoryWin32HandlePropertiesKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetMemoryFdKHR = function  (
      device     : VkDevice;
      pGetFdInfo : PVkMemoryGetFdInfoKHR;
      pFd        : PInt32
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetMemoryFdPropertiesKHR = function  (
      device              : VkDevice;
      handleType          : VkExternalMemoryHandleTypeFlagBits;
      fd                  : Int32;
      pMemoryFdProperties : PVkMemoryFdPropertiesKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetMemoryRemoteAddressNV = function  (
      device                      : VkDevice;
      pMemoryGetRemoteAddressInfo : PVkMemoryGetRemoteAddressInfoNV;
      pAddress                    : PVkRemoteAddressNV
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceExternalSemaphoreProperties = procedure (
      physicalDevice               : VkPhysicalDevice;
      pExternalSemaphoreInfo       : PVkPhysicalDeviceExternalSemaphoreInfo;
      pExternalSemaphoreProperties : PVkExternalSemaphoreProperties
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetSemaphoreWin32HandleKHR = function  (
      device              : VkDevice;
      pGetWin32HandleInfo : PVkSemaphoreGetWin32HandleInfoKHR;
      pHandle             : PHANDLE
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkImportSemaphoreWin32HandleKHR = function  (
      device                          : VkDevice;
      pImportSemaphoreWin32HandleInfo : PVkImportSemaphoreWin32HandleInfoKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetSemaphoreFdKHR = function  (
      device     : VkDevice;
      pGetFdInfo : PVkSemaphoreGetFdInfoKHR;
      pFd        : PInt32
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkImportSemaphoreFdKHR = function  (
      device                 : VkDevice;
      pImportSemaphoreFdInfo : PVkImportSemaphoreFdInfoKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceExternalFenceProperties = procedure (
      physicalDevice           : VkPhysicalDevice;
      pExternalFenceInfo       : PVkPhysicalDeviceExternalFenceInfo;
      pExternalFenceProperties : PVkExternalFenceProperties
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetFenceWin32HandleKHR = function  (
      device              : VkDevice;
      pGetWin32HandleInfo : PVkFenceGetWin32HandleInfoKHR;
      pHandle             : PHANDLE
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkImportFenceWin32HandleKHR = function  (
      device                      : VkDevice;
      pImportFenceWin32HandleInfo : PVkImportFenceWin32HandleInfoKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetFenceFdKHR = function  (
      device     : VkDevice;
      pGetFdInfo : PVkFenceGetFdInfoKHR;
      pFd        : PInt32
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkImportFenceFdKHR = function  (
      device             : VkDevice;
      pImportFenceFdInfo : PVkImportFenceFdInfoKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkReleaseDisplayEXT = function  (
      physicalDevice : VkPhysicalDevice;
      display        : VkDisplayKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkAcquireWinrtDisplayNV = function  (
      physicalDevice : VkPhysicalDevice;
      display        : VkDisplayKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetWinrtDisplayNV = function  (
      physicalDevice   : VkPhysicalDevice;
      deviceRelativeId : UInt32;
      pDisplay         : PVkDisplayKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDisplayPowerControlEXT = function  (
      device            : VkDevice;
      display           : VkDisplayKHR;
      pDisplayPowerInfo : PVkDisplayPowerInfoEXT
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkRegisterDeviceEventEXT = function  (
      device           : VkDevice;
      pDeviceEventInfo : PVkDeviceEventInfoEXT;
      pAllocator       : PVkAllocationCallbacks;
      pFence           : PVkFence
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkRegisterDisplayEventEXT = function  (
      device            : VkDevice;
      display           : VkDisplayKHR;
      pDisplayEventInfo : PVkDisplayEventInfoEXT;
      pAllocator        : PVkAllocationCallbacks;
      pFence            : PVkFence
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetSwapchainCounterEXT = function  (
      device        : VkDevice;
      swapchain     : VkSwapchainKHR;
      counter       : VkSurfaceCounterFlagBitsEXT;
      pCounterValue : PUInt64
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceSurfaceCapabilities2EXT = function  (
      physicalDevice       : VkPhysicalDevice;
      surface              : VkSurfaceKHR;
      pSurfaceCapabilities : PVkSurfaceCapabilities2EXT
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkEnumeratePhysicalDeviceGroups = function  (
      instance                       : VkInstance;
      pPhysicalDeviceGroupCount      : PUInt32;
      pPhysicalDeviceGroupProperties : PVkPhysicalDeviceGroupProperties
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDeviceGroupPeerMemoryFeatures = procedure (
      device              : VkDevice;
      heapIndex           : UInt32;
      localDeviceIndex    : UInt32;
      remoteDeviceIndex   : UInt32;
      pPeerMemoryFeatures : PVkPeerMemoryFeatureFlags
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkBindBufferMemory2 = function  (
      device        : VkDevice;
      bindInfoCount : UInt32;
      pBindInfos    : PVkBindBufferMemoryInfo
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkBindImageMemory2 = function  (
      device        : VkDevice;
      bindInfoCount : UInt32;
      pBindInfos    : PVkBindImageMemoryInfo
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetDeviceMask = procedure (
      commandBuffer : VkCommandBuffer;
      deviceMask    : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDeviceGroupPresentCapabilitiesKHR = function  (
      device                          : VkDevice;
      pDeviceGroupPresentCapabilities : PVkDeviceGroupPresentCapabilitiesKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDeviceGroupSurfacePresentModesKHR = function  (
      device  : VkDevice;
      surface : VkSurfaceKHR;
      pModes  : PVkDeviceGroupPresentModeFlagsKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkAcquireNextImage2KHR = function  (
      device       : VkDevice;
      pAcquireInfo : PVkAcquireNextImageInfoKHR;
      pImageIndex  : PUInt32
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDispatchBase = procedure (
      commandBuffer : VkCommandBuffer;
      baseGroupX    : UInt32;
      baseGroupY    : UInt32;
      baseGroupZ    : UInt32;
      groupCountX   : UInt32;
      groupCountY   : UInt32;
      groupCountZ   : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDevicePresentRectanglesKHR = function  (
      physicalDevice : VkPhysicalDevice;
      surface        : VkSurfaceKHR;
      pRectCount     : PUInt32;
      pRects         : PVkRect2D
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateDescriptorUpdateTemplate = function  (
      device                    : VkDevice;
      pCreateInfo               : PVkDescriptorUpdateTemplateCreateInfo;
      pAllocator                : PVkAllocationCallbacks;
      pDescriptorUpdateTemplate : PVkDescriptorUpdateTemplate
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyDescriptorUpdateTemplate = procedure (
      device                   : VkDevice;
      descriptorUpdateTemplate : VkDescriptorUpdateTemplate;
      pAllocator               : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkUpdateDescriptorSetWithTemplate = procedure (
      device                   : VkDevice;
      descriptorSet            : VkDescriptorSet;
      descriptorUpdateTemplate : VkDescriptorUpdateTemplate;
      pData                    : Pvoid
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdPushDescriptorSetWithTemplateKHR = procedure (
      commandBuffer            : VkCommandBuffer;
      descriptorUpdateTemplate : VkDescriptorUpdateTemplate;
      layout                   : VkPipelineLayout;
      _set                     : UInt32;
      pData                    : Pvoid
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkSetHdrMetadataEXT = procedure (
      device         : VkDevice;
      swapchainCount : UInt32;
      pSwapchains    : PVkSwapchainKHR;
      pMetadata      : PVkHdrMetadataEXT
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetSwapchainStatusKHR = function  (
      device    : VkDevice;
      swapchain : VkSwapchainKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetRefreshCycleDurationGOOGLE = function  (
      device                   : VkDevice;
      swapchain                : VkSwapchainKHR;
      pDisplayTimingProperties : PVkRefreshCycleDurationGOOGLE
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPastPresentationTimingGOOGLE = function  (
      device                   : VkDevice;
      swapchain                : VkSwapchainKHR;
      pPresentationTimingCount : PUInt32;
      pPresentationTimings     : PVkPastPresentationTimingGOOGLE
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateIOSSurfaceMVK = function  (
      instance    : VkInstance;
      pCreateInfo : PVkIOSSurfaceCreateInfoMVK;
      pAllocator  : PVkAllocationCallbacks;
      pSurface    : PVkSurfaceKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateMacOSSurfaceMVK = function  (
      instance    : VkInstance;
      pCreateInfo : PVkMacOSSurfaceCreateInfoMVK;
      pAllocator  : PVkAllocationCallbacks;
      pSurface    : PVkSurfaceKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateMetalSurfaceEXT = function  (
      instance    : VkInstance;
      pCreateInfo : PVkMetalSurfaceCreateInfoEXT;
      pAllocator  : PVkAllocationCallbacks;
      pSurface    : PVkSurfaceKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetViewportWScalingNV = procedure (
      commandBuffer      : VkCommandBuffer;
      firstViewport      : UInt32;
      viewportCount      : UInt32;
      pViewportWScalings : PVkViewportWScalingNV
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetDiscardRectangleEXT = procedure (
      commandBuffer         : VkCommandBuffer;
      firstDiscardRectangle : UInt32;
      discardRectangleCount : UInt32;
      pDiscardRectangles    : PVkRect2D
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetSampleLocationsEXT = procedure (
      commandBuffer        : VkCommandBuffer;
      pSampleLocationsInfo : PVkSampleLocationsInfoEXT
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceMultisamplePropertiesEXT = procedure (
      physicalDevice         : VkPhysicalDevice;
      samples                : VkSampleCountFlagBits;
      pMultisampleProperties : PVkMultisamplePropertiesEXT
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceSurfaceCapabilities2KHR = function  (
      physicalDevice       : VkPhysicalDevice;
      pSurfaceInfo         : PVkPhysicalDeviceSurfaceInfo2KHR;
      pSurfaceCapabilities : PVkSurfaceCapabilities2KHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceSurfaceFormats2KHR = function  (
      physicalDevice      : VkPhysicalDevice;
      pSurfaceInfo        : PVkPhysicalDeviceSurfaceInfo2KHR;
      pSurfaceFormatCount : PUInt32;
      pSurfaceFormats     : PVkSurfaceFormat2KHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceDisplayProperties2KHR = function  (
      physicalDevice : VkPhysicalDevice;
      pPropertyCount : PUInt32;
      pProperties    : PVkDisplayProperties2KHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceDisplayPlaneProperties2KHR = function  (
      physicalDevice : VkPhysicalDevice;
      pPropertyCount : PUInt32;
      pProperties    : PVkDisplayPlaneProperties2KHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDisplayModeProperties2KHR = function  (
      physicalDevice : VkPhysicalDevice;
      display        : VkDisplayKHR;
      pPropertyCount : PUInt32;
      pProperties    : PVkDisplayModeProperties2KHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDisplayPlaneCapabilities2KHR = function  (
      physicalDevice    : VkPhysicalDevice;
      pDisplayPlaneInfo : PVkDisplayPlaneInfo2KHR;
      pCapabilities     : PVkDisplayPlaneCapabilities2KHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetBufferMemoryRequirements2 = procedure (
      device              : VkDevice;
      pInfo               : PVkBufferMemoryRequirementsInfo2;
      pMemoryRequirements : PVkMemoryRequirements2
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetImageMemoryRequirements2 = procedure (
      device              : VkDevice;
      pInfo               : PVkImageMemoryRequirementsInfo2;
      pMemoryRequirements : PVkMemoryRequirements2
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetImageSparseMemoryRequirements2 = procedure (
      device                        : VkDevice;
      pInfo                         : PVkImageSparseMemoryRequirementsInfo2;
      pSparseMemoryRequirementCount : PUInt32;
      pSparseMemoryRequirements     : PVkSparseImageMemoryRequirements2
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateSamplerYcbcrConversion = function  (
      device           : VkDevice;
      pCreateInfo      : PVkSamplerYcbcrConversionCreateInfo;
      pAllocator       : PVkAllocationCallbacks;
      pYcbcrConversion : PVkSamplerYcbcrConversion
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroySamplerYcbcrConversion = procedure (
      device          : VkDevice;
      ycbcrConversion : VkSamplerYcbcrConversion;
      pAllocator      : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDeviceQueue2 = procedure (
      device     : VkDevice;
      pQueueInfo : PVkDeviceQueueInfo2;
      pQueue     : PVkQueue
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateValidationCacheEXT = function  (
      device           : VkDevice;
      pCreateInfo      : PVkValidationCacheCreateInfoEXT;
      pAllocator       : PVkAllocationCallbacks;
      pValidationCache : PVkValidationCacheEXT
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyValidationCacheEXT = procedure (
      device          : VkDevice;
      validationCache : VkValidationCacheEXT;
      pAllocator      : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetValidationCacheDataEXT = function  (
      device          : VkDevice;
      validationCache : VkValidationCacheEXT;
      pDataSize       : PSizeUInt;
      pData           : Pvoid
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkMergeValidationCachesEXT = function  (
      device        : VkDevice;
      dstCache      : VkValidationCacheEXT;
      srcCacheCount : UInt32;
      pSrcCaches    : PVkValidationCacheEXT
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDescriptorSetLayoutSupport = procedure (
      device      : VkDevice;
      pCreateInfo : PVkDescriptorSetLayoutCreateInfo;
      pSupport    : PVkDescriptorSetLayoutSupport
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetSwapchainGrallocUsageANDROID = function  (
      device       : VkDevice;
      format       : VkFormat;
      imageUsage   : VkImageUsageFlags;
      grallocUsage : PInt32
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetSwapchainGrallocUsage2ANDROID = function  (
      device               : VkDevice;
      format               : VkFormat;
      imageUsage           : VkImageUsageFlags;
      swapchainImageUsage  : VkSwapchainImageUsageFlagsANDROID;
      grallocConsumerUsage : PUInt64;
      grallocProducerUsage : PUInt64
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkAcquireImageANDROID = function  (
      device        : VkDevice;
      image         : VkImage;
      nativeFenceFd : Int32;
      semaphore     : VkSemaphore;
      fence         : VkFence
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkQueueSignalReleaseImageANDROID = function  (
      queue              : VkQueue;
      waitSemaphoreCount : UInt32;
      pWaitSemaphores    : PVkSemaphore;
      image              : VkImage;
      pNativeFenceFd     : PInt32
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetShaderInfoAMD = function  (
      device      : VkDevice;
      pipeline    : VkPipeline;
      shaderStage : VkShaderStageFlagBits;
      infoType    : VkShaderInfoTypeAMD;
      pInfoSize   : PSizeUInt;
      pInfo       : Pvoid
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkSetLocalDimmingAMD = procedure (
      device             : VkDevice;
      swapChain          : VkSwapchainKHR;
      localDimmingEnable : VkBool32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceCalibrateableTimeDomainsEXT = function  (
      physicalDevice   : VkPhysicalDevice;
      pTimeDomainCount : PUInt32;
      pTimeDomains     : PVkTimeDomainEXT
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetCalibratedTimestampsEXT = function  (
      device          : VkDevice;
      timestampCount  : UInt32;
      pTimestampInfos : PVkCalibratedTimestampInfoEXT;
      pTimestamps     : PUInt64;
      pMaxDeviation   : PUInt64
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkSetDebugUtilsObjectNameEXT = function  (
      device    : VkDevice;
      pNameInfo : PVkDebugUtilsObjectNameInfoEXT
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkSetDebugUtilsObjectTagEXT = function  (
      device   : VkDevice;
      pTagInfo : PVkDebugUtilsObjectTagInfoEXT
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkQueueBeginDebugUtilsLabelEXT = procedure (
      queue      : VkQueue;
      pLabelInfo : PVkDebugUtilsLabelEXT
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkQueueEndDebugUtilsLabelEXT = procedure (
      queue : VkQueue
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkQueueInsertDebugUtilsLabelEXT = procedure (
      queue      : VkQueue;
      pLabelInfo : PVkDebugUtilsLabelEXT
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBeginDebugUtilsLabelEXT = procedure (
      commandBuffer : VkCommandBuffer;
      pLabelInfo    : PVkDebugUtilsLabelEXT
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdEndDebugUtilsLabelEXT = procedure (
      commandBuffer : VkCommandBuffer
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdInsertDebugUtilsLabelEXT = procedure (
      commandBuffer : VkCommandBuffer;
      pLabelInfo    : PVkDebugUtilsLabelEXT
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateDebugUtilsMessengerEXT = function  (
      instance    : VkInstance;
      pCreateInfo : PVkDebugUtilsMessengerCreateInfoEXT;
      pAllocator  : PVkAllocationCallbacks;
      pMessenger  : PVkDebugUtilsMessengerEXT
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyDebugUtilsMessengerEXT = procedure (
      instance   : VkInstance;
      messenger  : VkDebugUtilsMessengerEXT;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkSubmitDebugUtilsMessageEXT = procedure (
      instance        : VkInstance;
      messageSeverity : VkDebugUtilsMessageSeverityFlagBitsEXT;
      messageTypes    : VkDebugUtilsMessageTypeFlagsEXT;
      pCallbackData   : PVkDebugUtilsMessengerCallbackDataEXT
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetMemoryHostPointerPropertiesEXT = function  (
      device                       : VkDevice;
      handleType                   : VkExternalMemoryHandleTypeFlagBits;
      pHostPointer                 : Pvoid;
      pMemoryHostPointerProperties : PVkMemoryHostPointerPropertiesEXT
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdWriteBufferMarkerAMD = procedure (
      commandBuffer : VkCommandBuffer;
      pipelineStage : VkPipelineStageFlagBits;
      dstBuffer     : VkBuffer;
      dstOffset     : VkDeviceSize;
      marker        : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateRenderPass2 = function  (
      device      : VkDevice;
      pCreateInfo : PVkRenderPassCreateInfo2;
      pAllocator  : PVkAllocationCallbacks;
      pRenderPass : PVkRenderPass
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBeginRenderPass2 = procedure (
      commandBuffer     : VkCommandBuffer;
      pRenderPassBegin  : PVkRenderPassBeginInfo;
      pSubpassBeginInfo : PVkSubpassBeginInfo
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdNextSubpass2 = procedure (
      commandBuffer     : VkCommandBuffer;
      pSubpassBeginInfo : PVkSubpassBeginInfo;
      pSubpassEndInfo   : PVkSubpassEndInfo
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdEndRenderPass2 = procedure (
      commandBuffer   : VkCommandBuffer;
      pSubpassEndInfo : PVkSubpassEndInfo
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetSemaphoreCounterValue = function  (
      device    : VkDevice;
      semaphore : VkSemaphore;
      pValue    : PUInt64
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkWaitSemaphores = function  (
      device    : VkDevice;
      pWaitInfo : PVkSemaphoreWaitInfo;
      timeout   : UInt64
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkSignalSemaphore = function  (
      device      : VkDevice;
      pSignalInfo : PVkSemaphoreSignalInfo
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetAndroidHardwareBufferPropertiesANDROID = function  (
      device      : VkDevice;
      buffer      : PAHardwareBuffer;
      pProperties : PVkAndroidHardwareBufferPropertiesANDROID
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetMemoryAndroidHardwareBufferANDROID = function  (
      device  : VkDevice;
      pInfo   : PVkMemoryGetAndroidHardwareBufferInfoANDROID;
      pBuffer : PAHardwareBuffer
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDrawIndirectCount = procedure (
      commandBuffer     : VkCommandBuffer;
      buffer            : VkBuffer;
      offset            : VkDeviceSize;
      countBuffer       : VkBuffer;
      countBufferOffset : VkDeviceSize;
      maxDrawCount      : UInt32;
      stride            : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDrawIndexedIndirectCount = procedure (
      commandBuffer     : VkCommandBuffer;
      buffer            : VkBuffer;
      offset            : VkDeviceSize;
      countBuffer       : VkBuffer;
      countBufferOffset : VkDeviceSize;
      maxDrawCount      : UInt32;
      stride            : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetCheckpointNV = procedure (
      commandBuffer     : VkCommandBuffer;
      pCheckpointMarker : Pvoid
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetQueueCheckpointDataNV = procedure (
      queue                : VkQueue;
      pCheckpointDataCount : PUInt32;
      pCheckpointData      : PVkCheckpointDataNV
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBindTransformFeedbackBuffersEXT = procedure (
      commandBuffer : VkCommandBuffer;
      firstBinding  : UInt32;
      bindingCount  : UInt32;
      pBuffers      : PVkBuffer;
      pOffsets      : PVkDeviceSize;
      pSizes        : PVkDeviceSize
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBeginTransformFeedbackEXT = procedure (
      commandBuffer         : VkCommandBuffer;
      firstCounterBuffer    : UInt32;
      counterBufferCount    : UInt32;
      pCounterBuffers       : PVkBuffer;
      pCounterBufferOffsets : PVkDeviceSize
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdEndTransformFeedbackEXT = procedure (
      commandBuffer         : VkCommandBuffer;
      firstCounterBuffer    : UInt32;
      counterBufferCount    : UInt32;
      pCounterBuffers       : PVkBuffer;
      pCounterBufferOffsets : PVkDeviceSize
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBeginQueryIndexedEXT = procedure (
      commandBuffer : VkCommandBuffer;
      queryPool     : VkQueryPool;
      query         : UInt32;
      flags         : VkQueryControlFlags;
      index         : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdEndQueryIndexedEXT = procedure (
      commandBuffer : VkCommandBuffer;
      queryPool     : VkQueryPool;
      query         : UInt32;
      index         : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDrawIndirectByteCountEXT = procedure (
      commandBuffer       : VkCommandBuffer;
      instanceCount       : UInt32;
      firstInstance       : UInt32;
      counterBuffer       : VkBuffer;
      counterBufferOffset : VkDeviceSize;
      counterOffset       : UInt32;
      vertexStride        : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetExclusiveScissorNV = procedure (
      commandBuffer         : VkCommandBuffer;
      firstExclusiveScissor : UInt32;
      exclusiveScissorCount : UInt32;
      pExclusiveScissors    : PVkRect2D
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBindShadingRateImageNV = procedure (
      commandBuffer : VkCommandBuffer;
      imageView     : VkImageView;
      imageLayout   : VkImageLayout
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetViewportShadingRatePaletteNV = procedure (
      commandBuffer        : VkCommandBuffer;
      firstViewport        : UInt32;
      viewportCount        : UInt32;
      pShadingRatePalettes : PVkShadingRatePaletteNV
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetCoarseSampleOrderNV = procedure (
      commandBuffer          : VkCommandBuffer;
      sampleOrderType        : VkCoarseSampleOrderTypeNV;
      customSampleOrderCount : UInt32;
      pCustomSampleOrders    : PVkCoarseSampleOrderCustomNV
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDrawMeshTasksNV = procedure (
      commandBuffer : VkCommandBuffer;
      taskCount     : UInt32;
      firstTask     : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDrawMeshTasksIndirectNV = procedure (
      commandBuffer : VkCommandBuffer;
      buffer        : VkBuffer;
      offset        : VkDeviceSize;
      drawCount     : UInt32;
      stride        : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDrawMeshTasksIndirectCountNV = procedure (
      commandBuffer     : VkCommandBuffer;
      buffer            : VkBuffer;
      offset            : VkDeviceSize;
      countBuffer       : VkBuffer;
      countBufferOffset : VkDeviceSize;
      maxDrawCount      : UInt32;
      stride            : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCompileDeferredNV = function  (
      device   : VkDevice;
      pipeline : VkPipeline;
      shader   : UInt32
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateAccelerationStructureNV = function  (
      device                 : VkDevice;
      pCreateInfo            : PVkAccelerationStructureCreateInfoNV;
      pAllocator             : PVkAllocationCallbacks;
      pAccelerationStructure : PVkAccelerationStructureNV
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBindInvocationMaskHUAWEI = procedure (
      commandBuffer : VkCommandBuffer;
      imageView     : VkImageView;
      imageLayout   : VkImageLayout
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyAccelerationStructureKHR = procedure (
      device                : VkDevice;
      accelerationStructure : VkAccelerationStructureKHR;
      pAllocator            : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyAccelerationStructureNV = procedure (
      device                : VkDevice;
      accelerationStructure : VkAccelerationStructureNV;
      pAllocator            : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetAccelerationStructureMemoryRequirementsNV = procedure (
      device              : VkDevice;
      pInfo               : PVkAccelerationStructureMemoryRequirementsInfoNV;
      pMemoryRequirements : PVkMemoryRequirements2KHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkBindAccelerationStructureMemoryNV = function  (
      device        : VkDevice;
      bindInfoCount : UInt32;
      pBindInfos    : PVkBindAccelerationStructureMemoryInfoNV
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdCopyAccelerationStructureNV = procedure (
      commandBuffer : VkCommandBuffer;
      dst           : VkAccelerationStructureNV;
      src           : VkAccelerationStructureNV;
      mode          : VkCopyAccelerationStructureModeKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdCopyAccelerationStructureKHR = procedure (
      commandBuffer : VkCommandBuffer;
      pInfo         : PVkCopyAccelerationStructureInfoKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCopyAccelerationStructureKHR = function  (
      device            : VkDevice;
      deferredOperation : VkDeferredOperationKHR;
      pInfo             : PVkCopyAccelerationStructureInfoKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdCopyAccelerationStructureToMemoryKHR = procedure (
      commandBuffer : VkCommandBuffer;
      pInfo         : PVkCopyAccelerationStructureToMemoryInfoKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCopyAccelerationStructureToMemoryKHR = function  (
      device            : VkDevice;
      deferredOperation : VkDeferredOperationKHR;
      pInfo             : PVkCopyAccelerationStructureToMemoryInfoKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdCopyMemoryToAccelerationStructureKHR = procedure (
      commandBuffer : VkCommandBuffer;
      pInfo         : PVkCopyMemoryToAccelerationStructureInfoKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCopyMemoryToAccelerationStructureKHR = function  (
      device            : VkDevice;
      deferredOperation : VkDeferredOperationKHR;
      pInfo             : PVkCopyMemoryToAccelerationStructureInfoKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdWriteAccelerationStructuresPropertiesKHR = procedure (
      commandBuffer              : VkCommandBuffer;
      accelerationStructureCount : UInt32;
      pAccelerationStructures    : PVkAccelerationStructureKHR;
      queryType                  : VkQueryType;
      queryPool                  : VkQueryPool;
      firstQuery                 : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdWriteAccelerationStructuresPropertiesNV = procedure (
      commandBuffer              : VkCommandBuffer;
      accelerationStructureCount : UInt32;
      pAccelerationStructures    : PVkAccelerationStructureNV;
      queryType                  : VkQueryType;
      queryPool                  : VkQueryPool;
      firstQuery                 : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBuildAccelerationStructureNV = procedure (
      commandBuffer  : VkCommandBuffer;
      pInfo          : PVkAccelerationStructureInfoNV;
      instanceData   : VkBuffer;
      instanceOffset : VkDeviceSize;
      update         : VkBool32;
      dst            : VkAccelerationStructureNV;
      src            : VkAccelerationStructureNV;
      scratch        : VkBuffer;
      scratchOffset  : VkDeviceSize
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkWriteAccelerationStructuresPropertiesKHR = function  (
      device                     : VkDevice;
      accelerationStructureCount : UInt32;
      pAccelerationStructures    : PVkAccelerationStructureKHR;
      queryType                  : VkQueryType;
      dataSize                   : SizeUInt;
      pData                      : Pvoid;
      stride                     : SizeUInt
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdTraceRaysKHR = procedure (
      commandBuffer               : VkCommandBuffer;
      pRaygenShaderBindingTable   : PVkStridedDeviceAddressRegionKHR;
      pMissShaderBindingTable     : PVkStridedDeviceAddressRegionKHR;
      pHitShaderBindingTable      : PVkStridedDeviceAddressRegionKHR;
      pCallableShaderBindingTable : PVkStridedDeviceAddressRegionKHR;
      width                       : UInt32;
      height                      : UInt32;
      depth                       : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdTraceRaysNV = procedure (
      commandBuffer                    : VkCommandBuffer;
      raygenShaderBindingTableBuffer   : VkBuffer;
      raygenShaderBindingOffset        : VkDeviceSize;
      missShaderBindingTableBuffer     : VkBuffer;
      missShaderBindingOffset          : VkDeviceSize;
      missShaderBindingStride          : VkDeviceSize;
      hitShaderBindingTableBuffer      : VkBuffer;
      hitShaderBindingOffset           : VkDeviceSize;
      hitShaderBindingStride           : VkDeviceSize;
      callableShaderBindingTableBuffer : VkBuffer;
      callableShaderBindingOffset      : VkDeviceSize;
      callableShaderBindingStride      : VkDeviceSize;
      width                            : UInt32;
      height                           : UInt32;
      depth                            : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetRayTracingShaderGroupHandlesKHR = function  (
      device     : VkDevice;
      pipeline   : VkPipeline;
      firstGroup : UInt32;
      groupCount : UInt32;
      dataSize   : SizeUInt;
      pData      : Pvoid
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetRayTracingCaptureReplayShaderGroupHandlesKHR = function  (
      device     : VkDevice;
      pipeline   : VkPipeline;
      firstGroup : UInt32;
      groupCount : UInt32;
      dataSize   : SizeUInt;
      pData      : Pvoid
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetAccelerationStructureHandleNV = function  (
      device                : VkDevice;
      accelerationStructure : VkAccelerationStructureNV;
      dataSize              : SizeUInt;
      pData                 : Pvoid
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateRayTracingPipelinesNV = function  (
      device          : VkDevice;
      pipelineCache   : VkPipelineCache;
      createInfoCount : UInt32;
      pCreateInfos    : PVkRayTracingPipelineCreateInfoNV;
      pAllocator      : PVkAllocationCallbacks;
      pPipelines      : PVkPipeline
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateRayTracingPipelinesKHR = function  (
      device            : VkDevice;
      deferredOperation : VkDeferredOperationKHR;
      pipelineCache     : VkPipelineCache;
      createInfoCount   : UInt32;
      pCreateInfos      : PVkRayTracingPipelineCreateInfoKHR;
      pAllocator        : PVkAllocationCallbacks;
      pPipelines        : PVkPipeline
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceCooperativeMatrixPropertiesNV = function  (
      physicalDevice : VkPhysicalDevice;
      pPropertyCount : PUInt32;
      pProperties    : PVkCooperativeMatrixPropertiesNV
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdTraceRaysIndirectKHR = procedure (
      commandBuffer               : VkCommandBuffer;
      pRaygenShaderBindingTable   : PVkStridedDeviceAddressRegionKHR;
      pMissShaderBindingTable     : PVkStridedDeviceAddressRegionKHR;
      pHitShaderBindingTable      : PVkStridedDeviceAddressRegionKHR;
      pCallableShaderBindingTable : PVkStridedDeviceAddressRegionKHR;
      indirectDeviceAddress       : VkDeviceAddress
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDeviceAccelerationStructureCompatibilityKHR = procedure (
      device         : VkDevice;
      pVersionInfo   : PVkAccelerationStructureVersionInfoKHR;
      pCompatibility : PVkAccelerationStructureCompatibilityKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetRayTracingShaderGroupStackSizeKHR = function  (
      device      : VkDevice;
      pipeline    : VkPipeline;
      group       : UInt32;
      groupShader : VkShaderGroupShaderKHR
  ): VkDeviceSize; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetRayTracingPipelineStackSizeKHR = procedure (
      commandBuffer     : VkCommandBuffer;
      pipelineStackSize : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetImageViewHandleNVX = function  (
      device : VkDevice;
      pInfo  : PVkImageViewHandleInfoNVX
  ): UInt32; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetImageViewAddressNVX = function  (
      device      : VkDevice;
      imageView   : VkImageView;
      pProperties : PVkImageViewAddressPropertiesNVX
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceSurfacePresentModes2EXT = function  (
      physicalDevice    : VkPhysicalDevice;
      pSurfaceInfo      : PVkPhysicalDeviceSurfaceInfo2KHR;
      pPresentModeCount : PUInt32;
      pPresentModes     : PVkPresentModeKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDeviceGroupSurfacePresentModes2EXT = function  (
      device       : VkDevice;
      pSurfaceInfo : PVkPhysicalDeviceSurfaceInfo2KHR;
      pModes       : PVkDeviceGroupPresentModeFlagsKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkAcquireFullScreenExclusiveModeEXT = function  (
      device    : VkDevice;
      swapchain : VkSwapchainKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkReleaseFullScreenExclusiveModeEXT = function  (
      device    : VkDevice;
      swapchain : VkSwapchainKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkEnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR = function  (
      physicalDevice       : VkPhysicalDevice;
      queueFamilyIndex     : UInt32;
      pCounterCount        : PUInt32;
      pCounters            : PVkPerformanceCounterKHR;
      pCounterDescriptions : PVkPerformanceCounterDescriptionKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR = procedure (
      physicalDevice              : VkPhysicalDevice;
      pPerformanceQueryCreateInfo : PVkQueryPoolPerformanceCreateInfoKHR;
      pNumPasses                  : PUInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkAcquireProfilingLockKHR = function  (
      device : VkDevice;
      pInfo  : PVkAcquireProfilingLockInfoKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkReleaseProfilingLockKHR = procedure (
      device : VkDevice
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetImageDrmFormatModifierPropertiesEXT = function  (
      device      : VkDevice;
      image       : VkImage;
      pProperties : PVkImageDrmFormatModifierPropertiesEXT
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetBufferOpaqueCaptureAddress = function  (
      device : VkDevice;
      pInfo  : PVkBufferDeviceAddressInfo
  ): UInt64; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetBufferDeviceAddress = function  (
      device : VkDevice;
      pInfo  : PVkBufferDeviceAddressInfo
  ): VkDeviceAddress; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateHeadlessSurfaceEXT = function  (
      instance    : VkInstance;
      pCreateInfo : PVkHeadlessSurfaceCreateInfoEXT;
      pAllocator  : PVkAllocationCallbacks;
      pSurface    : PVkSurfaceKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV = function  (
      physicalDevice    : VkPhysicalDevice;
      pCombinationCount : PUInt32;
      pCombinations     : PVkFramebufferMixedSamplesCombinationNV
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkInitializePerformanceApiINTEL = function  (
      device          : VkDevice;
      pInitializeInfo : PVkInitializePerformanceApiInfoINTEL
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkUninitializePerformanceApiINTEL = procedure (
      device : VkDevice
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetPerformanceMarkerINTEL = function  (
      commandBuffer : VkCommandBuffer;
      pMarkerInfo   : PVkPerformanceMarkerInfoINTEL
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetPerformanceStreamMarkerINTEL = function  (
      commandBuffer : VkCommandBuffer;
      pMarkerInfo   : PVkPerformanceStreamMarkerInfoINTEL
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetPerformanceOverrideINTEL = function  (
      commandBuffer : VkCommandBuffer;
      pOverrideInfo : PVkPerformanceOverrideInfoINTEL
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkAcquirePerformanceConfigurationINTEL = function  (
      device         : VkDevice;
      pAcquireInfo   : PVkPerformanceConfigurationAcquireInfoINTEL;
      pConfiguration : PVkPerformanceConfigurationINTEL
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkReleasePerformanceConfigurationINTEL = function  (
      device        : VkDevice;
      configuration : VkPerformanceConfigurationINTEL
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkQueueSetPerformanceConfigurationINTEL = function  (
      queue         : VkQueue;
      configuration : VkPerformanceConfigurationINTEL
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPerformanceParameterINTEL = function  (
      device    : VkDevice;
      parameter : VkPerformanceParameterTypeINTEL;
      pValue    : PVkPerformanceValueINTEL
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDeviceMemoryOpaqueCaptureAddress = function  (
      device : VkDevice;
      pInfo  : PVkDeviceMemoryOpaqueCaptureAddressInfo
  ): UInt64; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPipelineExecutablePropertiesKHR = function  (
      device           : VkDevice;
      pPipelineInfo    : PVkPipelineInfoKHR;
      pExecutableCount : PUInt32;
      pProperties      : PVkPipelineExecutablePropertiesKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPipelineExecutableStatisticsKHR = function  (
      device          : VkDevice;
      pExecutableInfo : PVkPipelineExecutableInfoKHR;
      pStatisticCount : PUInt32;
      pStatistics     : PVkPipelineExecutableStatisticKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPipelineExecutableInternalRepresentationsKHR = function  (
      device                       : VkDevice;
      pExecutableInfo              : PVkPipelineExecutableInfoKHR;
      pInternalRepresentationCount : PUInt32;
      pInternalRepresentations     : PVkPipelineExecutableInternalRepresentationKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetLineStippleEXT = procedure (
      commandBuffer      : VkCommandBuffer;
      lineStippleFactor  : UInt32;
      lineStipplePattern : UInt16
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceToolPropertiesEXT = function  (
      physicalDevice  : VkPhysicalDevice;
      pToolCount      : PUInt32;
      pToolProperties : PVkPhysicalDeviceToolPropertiesEXT
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateAccelerationStructureKHR = function  (
      device                 : VkDevice;
      pCreateInfo            : PVkAccelerationStructureCreateInfoKHR;
      pAllocator             : PVkAllocationCallbacks;
      pAccelerationStructure : PVkAccelerationStructureKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBuildAccelerationStructuresKHR = procedure (
      commandBuffer     : VkCommandBuffer;
      infoCount         : UInt32;
      pInfos            : PVkAccelerationStructureBuildGeometryInfoKHR;
      ppBuildRangeInfos : PPVkAccelerationStructureBuildRangeInfoKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBuildAccelerationStructuresIndirectKHR = procedure (
      commandBuffer            : VkCommandBuffer;
      infoCount                : UInt32;
      pInfos                   : PVkAccelerationStructureBuildGeometryInfoKHR;
      pIndirectDeviceAddresses : PVkDeviceAddress;
      pIndirectStrides         : PUInt32;
      ppMaxPrimitiveCounts     : PPUInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkBuildAccelerationStructuresKHR = function  (
      device            : VkDevice;
      deferredOperation : VkDeferredOperationKHR;
      infoCount         : UInt32;
      pInfos            : PVkAccelerationStructureBuildGeometryInfoKHR;
      ppBuildRangeInfos : PPVkAccelerationStructureBuildRangeInfoKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetAccelerationStructureDeviceAddressKHR = function  (
      device : VkDevice;
      pInfo  : PVkAccelerationStructureDeviceAddressInfoKHR
  ): VkDeviceAddress; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateDeferredOperationKHR = function  (
      device             : VkDevice;
      pAllocator         : PVkAllocationCallbacks;
      pDeferredOperation : PVkDeferredOperationKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyDeferredOperationKHR = procedure (
      device     : VkDevice;
      operation  : VkDeferredOperationKHR;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDeferredOperationMaxConcurrencyKHR = function  (
      device    : VkDevice;
      operation : VkDeferredOperationKHR
  ): UInt32; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDeferredOperationResultKHR = function  (
      device    : VkDevice;
      operation : VkDeferredOperationKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDeferredOperationJoinKHR = function  (
      device    : VkDevice;
      operation : VkDeferredOperationKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetCullModeEXT = procedure (
      commandBuffer : VkCommandBuffer;
      cullMode      : VkCullModeFlags
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetFrontFaceEXT = procedure (
      commandBuffer : VkCommandBuffer;
      frontFace     : VkFrontFace
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetPrimitiveTopologyEXT = procedure (
      commandBuffer     : VkCommandBuffer;
      primitiveTopology : VkPrimitiveTopology
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetViewportWithCountEXT = procedure (
      commandBuffer : VkCommandBuffer;
      viewportCount : UInt32;
      pViewports    : PVkViewport
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetScissorWithCountEXT = procedure (
      commandBuffer : VkCommandBuffer;
      scissorCount  : UInt32;
      pScissors     : PVkRect2D
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBindVertexBuffers2EXT = procedure (
      commandBuffer : VkCommandBuffer;
      firstBinding  : UInt32;
      bindingCount  : UInt32;
      pBuffers      : PVkBuffer;
      pOffsets      : PVkDeviceSize;
      pSizes        : PVkDeviceSize;
      pStrides      : PVkDeviceSize
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetDepthTestEnableEXT = procedure (
      commandBuffer   : VkCommandBuffer;
      depthTestEnable : VkBool32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetDepthWriteEnableEXT = procedure (
      commandBuffer    : VkCommandBuffer;
      depthWriteEnable : VkBool32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetDepthCompareOpEXT = procedure (
      commandBuffer  : VkCommandBuffer;
      depthCompareOp : VkCompareOp
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetDepthBoundsTestEnableEXT = procedure (
      commandBuffer         : VkCommandBuffer;
      depthBoundsTestEnable : VkBool32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetStencilTestEnableEXT = procedure (
      commandBuffer     : VkCommandBuffer;
      stencilTestEnable : VkBool32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetStencilOpEXT = procedure (
      commandBuffer : VkCommandBuffer;
      faceMask      : VkStencilFaceFlags;
      failOp        : VkStencilOp;
      passOp        : VkStencilOp;
      depthFailOp   : VkStencilOp;
      compareOp     : VkCompareOp
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetPatchControlPointsEXT = procedure (
      commandBuffer      : VkCommandBuffer;
      patchControlPoints : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetRasterizerDiscardEnableEXT = procedure (
      commandBuffer           : VkCommandBuffer;
      rasterizerDiscardEnable : VkBool32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetDepthBiasEnableEXT = procedure (
      commandBuffer   : VkCommandBuffer;
      depthBiasEnable : VkBool32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetLogicOpEXT = procedure (
      commandBuffer : VkCommandBuffer;
      logicOp       : VkLogicOp
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetPrimitiveRestartEnableEXT = procedure (
      commandBuffer          : VkCommandBuffer;
      primitiveRestartEnable : VkBool32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreatePrivateDataSlotEXT = function  (
      device           : VkDevice;
      pCreateInfo      : PVkPrivateDataSlotCreateInfoEXT;
      pAllocator       : PVkAllocationCallbacks;
      pPrivateDataSlot : PVkPrivateDataSlotEXT
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyPrivateDataSlotEXT = procedure (
      device          : VkDevice;
      privateDataSlot : VkPrivateDataSlotEXT;
      pAllocator      : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkSetPrivateDataEXT = function  (
      device          : VkDevice;
      objectType      : VkObjectType;
      objectHandle    : UInt64;
      privateDataSlot : VkPrivateDataSlotEXT;
      data            : UInt64
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPrivateDataEXT = procedure (
      device          : VkDevice;
      objectType      : VkObjectType;
      objectHandle    : UInt64;
      privateDataSlot : VkPrivateDataSlotEXT;
      pData           : PUInt64
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdCopyBuffer2KHR = procedure (
      commandBuffer   : VkCommandBuffer;
      pCopyBufferInfo : PVkCopyBufferInfo2KHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdCopyImage2KHR = procedure (
      commandBuffer  : VkCommandBuffer;
      pCopyImageInfo : PVkCopyImageInfo2KHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBlitImage2KHR = procedure (
      commandBuffer  : VkCommandBuffer;
      pBlitImageInfo : PVkBlitImageInfo2KHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdCopyBufferToImage2KHR = procedure (
      commandBuffer          : VkCommandBuffer;
      pCopyBufferToImageInfo : PVkCopyBufferToImageInfo2KHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdCopyImageToBuffer2KHR = procedure (
      commandBuffer          : VkCommandBuffer;
      pCopyImageToBufferInfo : PVkCopyImageToBufferInfo2KHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdResolveImage2KHR = procedure (
      commandBuffer     : VkCommandBuffer;
      pResolveImageInfo : PVkResolveImageInfo2KHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetFragmentShadingRateKHR = procedure (
      commandBuffer : VkCommandBuffer;
      pFragmentSize : PVkExtent2D;
      combinerOps   : VkFragmentShadingRateCombinerOpKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceFragmentShadingRatesKHR = function  (
      physicalDevice            : VkPhysicalDevice;
      pFragmentShadingRateCount : PUInt32;
      pFragmentShadingRates     : PVkPhysicalDeviceFragmentShadingRateKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetFragmentShadingRateEnumNV = procedure (
      commandBuffer : VkCommandBuffer;
      shadingRate   : VkFragmentShadingRateNV;
      combinerOps   : VkFragmentShadingRateCombinerOpKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetAccelerationStructureBuildSizesKHR = procedure (
      device              : VkDevice;
      buildType           : VkAccelerationStructureBuildTypeKHR;
      pBuildInfo          : PVkAccelerationStructureBuildGeometryInfoKHR;
      pMaxPrimitiveCounts : PUInt32;
      pSizeInfo           : PVkAccelerationStructureBuildSizesInfoKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetVertexInputEXT = procedure (
      commandBuffer                   : VkCommandBuffer;
      vertexBindingDescriptionCount   : UInt32;
      pVertexBindingDescriptions      : PVkVertexInputBindingDescription2EXT;
      vertexAttributeDescriptionCount : UInt32;
      pVertexAttributeDescriptions    : PVkVertexInputAttributeDescription2EXT
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetColorWriteEnableEXT = procedure (
      commandBuffer      : VkCommandBuffer;
      attachmentCount    : UInt32;
      pColorWriteEnables : PVkBool32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdSetEvent2KHR = procedure (
      commandBuffer   : VkCommandBuffer;
      event           : VkEvent;
      pDependencyInfo : PVkDependencyInfoKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdResetEvent2KHR = procedure (
      commandBuffer : VkCommandBuffer;
      event         : VkEvent;
      stageMask     : VkPipelineStageFlags2KHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdWaitEvents2KHR = procedure (
      commandBuffer    : VkCommandBuffer;
      eventCount       : UInt32;
      pEvents          : PVkEvent;
      pDependencyInfos : PVkDependencyInfoKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdPipelineBarrier2KHR = procedure (
      commandBuffer   : VkCommandBuffer;
      pDependencyInfo : PVkDependencyInfoKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkQueueSubmit2KHR = function  (
      queue       : VkQueue;
      submitCount : UInt32;
      pSubmits    : PVkSubmitInfo2KHR;
      fence       : VkFence
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdWriteTimestamp2KHR = procedure (
      commandBuffer : VkCommandBuffer;
      stage         : VkPipelineStageFlags2KHR;
      queryPool     : VkQueryPool;
      query         : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdWriteBufferMarker2AMD = procedure (
      commandBuffer : VkCommandBuffer;
      stage         : VkPipelineStageFlags2KHR;
      dstBuffer     : VkBuffer;
      dstOffset     : VkDeviceSize;
      marker        : UInt32
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetQueueCheckpointData2NV = procedure (
      queue                : VkQueue;
      pCheckpointDataCount : PUInt32;
      pCheckpointData      : PVkCheckpointData2NV
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceVideoCapabilitiesKHR = function  (
      physicalDevice : VkPhysicalDevice;
      pVideoProfile  : PVkVideoProfileKHR;
      pCapabilities  : PVkVideoCapabilitiesKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetPhysicalDeviceVideoFormatPropertiesKHR = function  (
      physicalDevice            : VkPhysicalDevice;
      pVideoFormatInfo          : PVkPhysicalDeviceVideoFormatInfoKHR;
      pVideoFormatPropertyCount : PUInt32;
      pVideoFormatProperties    : PVkVideoFormatPropertiesKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateVideoSessionKHR = function  (
      device        : VkDevice;
      pCreateInfo   : PVkVideoSessionCreateInfoKHR;
      pAllocator    : PVkAllocationCallbacks;
      pVideoSession : PVkVideoSessionKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyVideoSessionKHR = procedure (
      device       : VkDevice;
      videoSession : VkVideoSessionKHR;
      pAllocator   : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateVideoSessionParametersKHR = function  (
      device                  : VkDevice;
      pCreateInfo             : PVkVideoSessionParametersCreateInfoKHR;
      pAllocator              : PVkAllocationCallbacks;
      pVideoSessionParameters : PVkVideoSessionParametersKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkUpdateVideoSessionParametersKHR = function  (
      device                 : VkDevice;
      videoSessionParameters : VkVideoSessionParametersKHR;
      pUpdateInfo            : PVkVideoSessionParametersUpdateInfoKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyVideoSessionParametersKHR = procedure (
      device                 : VkDevice;
      videoSessionParameters : VkVideoSessionParametersKHR;
      pAllocator             : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetVideoSessionMemoryRequirementsKHR = function  (
      device                               : VkDevice;
      videoSession                         : VkVideoSessionKHR;
      pVideoSessionMemoryRequirementsCount : PUInt32;
      pVideoSessionMemoryRequirements      : PVkVideoGetMemoryPropertiesKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkBindVideoSessionMemoryKHR = function  (
      device                      : VkDevice;
      videoSession                : VkVideoSessionKHR;
      videoSessionBindMemoryCount : UInt32;
      pVideoSessionBindMemories   : PVkVideoBindMemoryKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdDecodeVideoKHR = procedure (
      commandBuffer : VkCommandBuffer;
      pFrameInfo    : PVkVideoDecodeInfoKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdBeginVideoCodingKHR = procedure (
      commandBuffer : VkCommandBuffer;
      pBeginInfo    : PVkVideoBeginCodingInfoKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdControlVideoCodingKHR = procedure (
      commandBuffer      : VkCommandBuffer;
      pCodingControlInfo : PVkVideoCodingControlInfoKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdEndVideoCodingKHR = procedure (
      commandBuffer  : VkCommandBuffer;
      pEndCodingInfo : PVkVideoEndCodingInfoKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdEncodeVideoKHR = procedure (
      commandBuffer : VkCommandBuffer;
      pEncodeInfo   : PVkVideoEncodeInfoKHR
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateCuModuleNVX = function  (
      device      : VkDevice;
      pCreateInfo : PVkCuModuleCreateInfoNVX;
      pAllocator  : PVkAllocationCallbacks;
      pModule     : PVkCuModuleNVX
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCreateCuFunctionNVX = function  (
      device      : VkDevice;
      pCreateInfo : PVkCuFunctionCreateInfoNVX;
      pAllocator  : PVkAllocationCallbacks;
      pFunction   : PVkCuFunctionNVX
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyCuModuleNVX = procedure (
      device     : VkDevice;
      module     : VkCuModuleNVX;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkDestroyCuFunctionNVX = procedure (
      device     : VkDevice;
      _function  : VkCuFunctionNVX;
      pAllocator : PVkAllocationCallbacks
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkCmdCuLaunchKernelNVX = procedure (
      commandBuffer : VkCommandBuffer;
      pLaunchInfo   : PVkCuLaunchInfoNVX
  ); {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkAcquireDrmDisplayEXT = function  (
      physicalDevice : VkPhysicalDevice;
      drmFd          : Int32;
      display        : VkDisplayKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkGetDrmDisplayEXT = function  (
      physicalDevice : VkPhysicalDevice;
      drmFd          : Int32;
      connectorId    : UInt32;
      display        : PVkDisplayKHR
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}
PFN_vkWaitForPresentKHR = function  (
      device    : VkDevice;
      swapchain : VkSwapchainKHR;
      presentId : UInt64;
      timeout   : UInt64
  ): VkResult; {$IF Defined(Windows) or Defined(MSWindows)}stdcall;{$ELSE}cdecl;{$ENDIF}



function VK_MAKE_API_VERSION(_variant, major, minor, patch: UInt32): UInt32; inline;
function VK_API_VERSION_VARIANT(version: UInt32): UInt32; inline;
function VK_API_VERSION_MAJOR(version: UInt32): UInt32; inline;
function VK_API_VERSION_MINOR(version: UInt32): UInt32; inline;
function VK_API_VERSION_PATCH(version: UInt32): UInt32; inline;
     // See "Version Numbers" of the Vulkan spec

function VK_MAKE_VERSION(major, minor, patch: UInt32): UInt32; inline; deprecated 'VK_MAKE_VERSION is deprecated. VK_MAKE_API_VERSION should be used instead.';
function VK_VERSION_MAJOR(version: UInt32): UInt32; inline; deprecated 'VK_VERSION_MAJOR is deprecated. VK_API_VERSION_MAJOR should be used instead';
function VK_VERSION_MINOR(version: UInt32): UInt32; inline; deprecated 'VK_VERSION_MINOR is deprecated. VK_API_VERSION_MINOR should be used instead.';
function VK_VERSION_PATCH(version: UInt32): UInt32; inline; deprecated 'VK_VERSION_PATCH is deprecated. VK_API_VERSION_PATCH should be used instead.';

{$IF Defined(DVULKAN_LOADER)}
type
PVulkanGeneralFunctions = ^TVulkanGeneralFunctions;
TVulkanGeneralFunctions = record
  vkCreateInstance: PFN_vkCreateInstance;
  vkGetInstanceProcAddr: PFN_vkGetInstanceProcAddr;
  vkEnumerateInstanceVersion: PFN_vkEnumerateInstanceVersion;
  vkEnumerateInstanceLayerProperties: PFN_vkEnumerateInstanceLayerProperties;
  vkEnumerateInstanceExtensionProperties: PFN_vkEnumerateInstanceExtensionProperties;
end;

PVulkanInstanceFunctions = ^TVulkanInstanceFunctions;
TVulkanInstanceFunctions = record
  vkDestroyInstance: PFN_vkDestroyInstance;
  vkEnumeratePhysicalDevices: PFN_vkEnumeratePhysicalDevices;
  vkGetDeviceProcAddr: PFN_vkGetDeviceProcAddr;
  vkGetPhysicalDeviceProperties: PFN_vkGetPhysicalDeviceProperties;
  vkGetPhysicalDeviceQueueFamilyProperties: PFN_vkGetPhysicalDeviceQueueFamilyProperties;
  vkGetPhysicalDeviceMemoryProperties: PFN_vkGetPhysicalDeviceMemoryProperties;
  vkGetPhysicalDeviceFeatures: PFN_vkGetPhysicalDeviceFeatures;
  vkGetPhysicalDeviceFormatProperties: PFN_vkGetPhysicalDeviceFormatProperties;
  vkGetPhysicalDeviceImageFormatProperties: PFN_vkGetPhysicalDeviceImageFormatProperties;
  vkCreateDevice: PFN_vkCreateDevice;
  vkEnumerateDeviceLayerProperties: PFN_vkEnumerateDeviceLayerProperties;
  vkEnumerateDeviceExtensionProperties: PFN_vkEnumerateDeviceExtensionProperties;
  vkGetPhysicalDeviceSparseImageFormatProperties: PFN_vkGetPhysicalDeviceSparseImageFormatProperties;
  vkCreateAndroidSurfaceKHR: PFN_vkCreateAndroidSurfaceKHR;
  vkGetPhysicalDeviceDisplayPropertiesKHR: PFN_vkGetPhysicalDeviceDisplayPropertiesKHR;
  vkGetPhysicalDeviceDisplayPlanePropertiesKHR: PFN_vkGetPhysicalDeviceDisplayPlanePropertiesKHR;
  vkGetDisplayPlaneSupportedDisplaysKHR: PFN_vkGetDisplayPlaneSupportedDisplaysKHR;
  vkGetDisplayModePropertiesKHR: PFN_vkGetDisplayModePropertiesKHR;
  vkCreateDisplayModeKHR: PFN_vkCreateDisplayModeKHR;
  vkGetDisplayPlaneCapabilitiesKHR: PFN_vkGetDisplayPlaneCapabilitiesKHR;
  vkCreateDisplayPlaneSurfaceKHR: PFN_vkCreateDisplayPlaneSurfaceKHR;
  vkDestroySurfaceKHR: PFN_vkDestroySurfaceKHR;
  vkGetPhysicalDeviceSurfaceSupportKHR: PFN_vkGetPhysicalDeviceSurfaceSupportKHR;
  vkGetPhysicalDeviceSurfaceCapabilitiesKHR: PFN_vkGetPhysicalDeviceSurfaceCapabilitiesKHR;
  vkGetPhysicalDeviceSurfaceFormatsKHR: PFN_vkGetPhysicalDeviceSurfaceFormatsKHR;
  vkGetPhysicalDeviceSurfacePresentModesKHR: PFN_vkGetPhysicalDeviceSurfacePresentModesKHR;
  vkCreateViSurfaceNN: PFN_vkCreateViSurfaceNN;
  vkCreateWin32SurfaceKHR: PFN_vkCreateWin32SurfaceKHR;
  vkGetPhysicalDeviceWin32PresentationSupportKHR: PFN_vkGetPhysicalDeviceWin32PresentationSupportKHR;
  vkCreateDebugReportCallbackEXT: PFN_vkCreateDebugReportCallbackEXT;
  vkDestroyDebugReportCallbackEXT: PFN_vkDestroyDebugReportCallbackEXT;
  vkDebugReportMessageEXT: PFN_vkDebugReportMessageEXT;
  vkGetPhysicalDeviceExternalImageFormatPropertiesNV: PFN_vkGetPhysicalDeviceExternalImageFormatPropertiesNV;
  vkGetPhysicalDeviceFeatures2: PFN_vkGetPhysicalDeviceFeatures2;
  vkGetPhysicalDeviceProperties2: PFN_vkGetPhysicalDeviceProperties2;
  vkGetPhysicalDeviceFormatProperties2: PFN_vkGetPhysicalDeviceFormatProperties2;
  vkGetPhysicalDeviceImageFormatProperties2: PFN_vkGetPhysicalDeviceImageFormatProperties2;
  vkGetPhysicalDeviceQueueFamilyProperties2: PFN_vkGetPhysicalDeviceQueueFamilyProperties2;
  vkGetPhysicalDeviceMemoryProperties2: PFN_vkGetPhysicalDeviceMemoryProperties2;
  vkGetPhysicalDeviceSparseImageFormatProperties2: PFN_vkGetPhysicalDeviceSparseImageFormatProperties2;
  vkGetPhysicalDeviceExternalBufferProperties: PFN_vkGetPhysicalDeviceExternalBufferProperties;
  vkGetPhysicalDeviceExternalSemaphoreProperties: PFN_vkGetPhysicalDeviceExternalSemaphoreProperties;
  vkGetPhysicalDeviceExternalFenceProperties: PFN_vkGetPhysicalDeviceExternalFenceProperties;
  vkReleaseDisplayEXT: PFN_vkReleaseDisplayEXT;
  vkAcquireWinrtDisplayNV: PFN_vkAcquireWinrtDisplayNV;
  vkGetWinrtDisplayNV: PFN_vkGetWinrtDisplayNV;
  vkGetPhysicalDeviceSurfaceCapabilities2EXT: PFN_vkGetPhysicalDeviceSurfaceCapabilities2EXT;
  vkEnumeratePhysicalDeviceGroups: PFN_vkEnumeratePhysicalDeviceGroups;
  vkGetPhysicalDevicePresentRectanglesKHR: PFN_vkGetPhysicalDevicePresentRectanglesKHR;
  vkCreateIOSSurfaceMVK: PFN_vkCreateIOSSurfaceMVK;
  vkCreateMacOSSurfaceMVK: PFN_vkCreateMacOSSurfaceMVK;
  vkCreateMetalSurfaceEXT: PFN_vkCreateMetalSurfaceEXT;
  vkGetPhysicalDeviceMultisamplePropertiesEXT: PFN_vkGetPhysicalDeviceMultisamplePropertiesEXT;
  vkGetPhysicalDeviceSurfaceCapabilities2KHR: PFN_vkGetPhysicalDeviceSurfaceCapabilities2KHR;
  vkGetPhysicalDeviceSurfaceFormats2KHR: PFN_vkGetPhysicalDeviceSurfaceFormats2KHR;
  vkGetPhysicalDeviceDisplayProperties2KHR: PFN_vkGetPhysicalDeviceDisplayProperties2KHR;
  vkGetPhysicalDeviceDisplayPlaneProperties2KHR: PFN_vkGetPhysicalDeviceDisplayPlaneProperties2KHR;
  vkGetDisplayModeProperties2KHR: PFN_vkGetDisplayModeProperties2KHR;
  vkGetDisplayPlaneCapabilities2KHR: PFN_vkGetDisplayPlaneCapabilities2KHR;
  vkGetPhysicalDeviceCalibrateableTimeDomainsEXT: PFN_vkGetPhysicalDeviceCalibrateableTimeDomainsEXT;
  vkCreateDebugUtilsMessengerEXT: PFN_vkCreateDebugUtilsMessengerEXT;
  vkDestroyDebugUtilsMessengerEXT: PFN_vkDestroyDebugUtilsMessengerEXT;
  vkSubmitDebugUtilsMessageEXT: PFN_vkSubmitDebugUtilsMessageEXT;
  vkGetPhysicalDeviceCooperativeMatrixPropertiesNV: PFN_vkGetPhysicalDeviceCooperativeMatrixPropertiesNV;
  vkGetPhysicalDeviceSurfacePresentModes2EXT: PFN_vkGetPhysicalDeviceSurfacePresentModes2EXT;
  vkEnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR: PFN_vkEnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR;
  vkGetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR: PFN_vkGetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR;
  vkCreateHeadlessSurfaceEXT: PFN_vkCreateHeadlessSurfaceEXT;
  vkGetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV: PFN_vkGetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV;
  vkGetPhysicalDeviceToolPropertiesEXT: PFN_vkGetPhysicalDeviceToolPropertiesEXT;
  vkGetPhysicalDeviceFragmentShadingRatesKHR: PFN_vkGetPhysicalDeviceFragmentShadingRatesKHR;
  vkGetPhysicalDeviceVideoCapabilitiesKHR: PFN_vkGetPhysicalDeviceVideoCapabilitiesKHR;
  vkGetPhysicalDeviceVideoFormatPropertiesKHR: PFN_vkGetPhysicalDeviceVideoFormatPropertiesKHR;
  vkAcquireDrmDisplayEXT: PFN_vkAcquireDrmDisplayEXT;
  vkGetDrmDisplayEXT: PFN_vkGetDrmDisplayEXT;
end;

PVulkanDeviceFunctions = ^TVulkanDeviceFunctions;
TVulkanDeviceFunctions = record
  vkDestroyDevice: PFN_vkDestroyDevice;
  vkGetDeviceQueue: PFN_vkGetDeviceQueue;
  vkQueueSubmit: PFN_vkQueueSubmit;
  vkQueueWaitIdle: PFN_vkQueueWaitIdle;
  vkDeviceWaitIdle: PFN_vkDeviceWaitIdle;
  vkAllocateMemory: PFN_vkAllocateMemory;
  vkFreeMemory: PFN_vkFreeMemory;
  vkMapMemory: PFN_vkMapMemory;
  vkUnmapMemory: PFN_vkUnmapMemory;
  vkFlushMappedMemoryRanges: PFN_vkFlushMappedMemoryRanges;
  vkInvalidateMappedMemoryRanges: PFN_vkInvalidateMappedMemoryRanges;
  vkGetDeviceMemoryCommitment: PFN_vkGetDeviceMemoryCommitment;
  vkGetBufferMemoryRequirements: PFN_vkGetBufferMemoryRequirements;
  vkBindBufferMemory: PFN_vkBindBufferMemory;
  vkGetImageMemoryRequirements: PFN_vkGetImageMemoryRequirements;
  vkBindImageMemory: PFN_vkBindImageMemory;
  vkGetImageSparseMemoryRequirements: PFN_vkGetImageSparseMemoryRequirements;
  vkQueueBindSparse: PFN_vkQueueBindSparse;
  vkCreateFence: PFN_vkCreateFence;
  vkDestroyFence: PFN_vkDestroyFence;
  vkResetFences: PFN_vkResetFences;
  vkGetFenceStatus: PFN_vkGetFenceStatus;
  vkWaitForFences: PFN_vkWaitForFences;
  vkCreateSemaphore: PFN_vkCreateSemaphore;
  vkDestroySemaphore: PFN_vkDestroySemaphore;
  vkCreateEvent: PFN_vkCreateEvent;
  vkDestroyEvent: PFN_vkDestroyEvent;
  vkGetEventStatus: PFN_vkGetEventStatus;
  vkSetEvent: PFN_vkSetEvent;
  vkResetEvent: PFN_vkResetEvent;
  vkCreateQueryPool: PFN_vkCreateQueryPool;
  vkDestroyQueryPool: PFN_vkDestroyQueryPool;
  vkGetQueryPoolResults: PFN_vkGetQueryPoolResults;
  vkResetQueryPool: PFN_vkResetQueryPool;
  vkCreateBuffer: PFN_vkCreateBuffer;
  vkDestroyBuffer: PFN_vkDestroyBuffer;
  vkCreateBufferView: PFN_vkCreateBufferView;
  vkDestroyBufferView: PFN_vkDestroyBufferView;
  vkCreateImage: PFN_vkCreateImage;
  vkDestroyImage: PFN_vkDestroyImage;
  vkGetImageSubresourceLayout: PFN_vkGetImageSubresourceLayout;
  vkCreateImageView: PFN_vkCreateImageView;
  vkDestroyImageView: PFN_vkDestroyImageView;
  vkCreateShaderModule: PFN_vkCreateShaderModule;
  vkDestroyShaderModule: PFN_vkDestroyShaderModule;
  vkCreatePipelineCache: PFN_vkCreatePipelineCache;
  vkDestroyPipelineCache: PFN_vkDestroyPipelineCache;
  vkGetPipelineCacheData: PFN_vkGetPipelineCacheData;
  vkMergePipelineCaches: PFN_vkMergePipelineCaches;
  vkCreateGraphicsPipelines: PFN_vkCreateGraphicsPipelines;
  vkCreateComputePipelines: PFN_vkCreateComputePipelines;
  vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI: PFN_vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI;
  vkDestroyPipeline: PFN_vkDestroyPipeline;
  vkCreatePipelineLayout: PFN_vkCreatePipelineLayout;
  vkDestroyPipelineLayout: PFN_vkDestroyPipelineLayout;
  vkCreateSampler: PFN_vkCreateSampler;
  vkDestroySampler: PFN_vkDestroySampler;
  vkCreateDescriptorSetLayout: PFN_vkCreateDescriptorSetLayout;
  vkDestroyDescriptorSetLayout: PFN_vkDestroyDescriptorSetLayout;
  vkCreateDescriptorPool: PFN_vkCreateDescriptorPool;
  vkDestroyDescriptorPool: PFN_vkDestroyDescriptorPool;
  vkResetDescriptorPool: PFN_vkResetDescriptorPool;
  vkAllocateDescriptorSets: PFN_vkAllocateDescriptorSets;
  vkFreeDescriptorSets: PFN_vkFreeDescriptorSets;
  vkUpdateDescriptorSets: PFN_vkUpdateDescriptorSets;
  vkCreateFramebuffer: PFN_vkCreateFramebuffer;
  vkDestroyFramebuffer: PFN_vkDestroyFramebuffer;
  vkCreateRenderPass: PFN_vkCreateRenderPass;
  vkDestroyRenderPass: PFN_vkDestroyRenderPass;
  vkGetRenderAreaGranularity: PFN_vkGetRenderAreaGranularity;
  vkCreateCommandPool: PFN_vkCreateCommandPool;
  vkDestroyCommandPool: PFN_vkDestroyCommandPool;
  vkResetCommandPool: PFN_vkResetCommandPool;
  vkAllocateCommandBuffers: PFN_vkAllocateCommandBuffers;
  vkFreeCommandBuffers: PFN_vkFreeCommandBuffers;
  vkBeginCommandBuffer: PFN_vkBeginCommandBuffer;
  vkEndCommandBuffer: PFN_vkEndCommandBuffer;
  vkResetCommandBuffer: PFN_vkResetCommandBuffer;
  vkCmdBindPipeline: PFN_vkCmdBindPipeline;
  vkCmdSetViewport: PFN_vkCmdSetViewport;
  vkCmdSetScissor: PFN_vkCmdSetScissor;
  vkCmdSetLineWidth: PFN_vkCmdSetLineWidth;
  vkCmdSetDepthBias: PFN_vkCmdSetDepthBias;
  vkCmdSetBlendConstants: PFN_vkCmdSetBlendConstants;
  vkCmdSetDepthBounds: PFN_vkCmdSetDepthBounds;
  vkCmdSetStencilCompareMask: PFN_vkCmdSetStencilCompareMask;
  vkCmdSetStencilWriteMask: PFN_vkCmdSetStencilWriteMask;
  vkCmdSetStencilReference: PFN_vkCmdSetStencilReference;
  vkCmdBindDescriptorSets: PFN_vkCmdBindDescriptorSets;
  vkCmdBindIndexBuffer: PFN_vkCmdBindIndexBuffer;
  vkCmdBindVertexBuffers: PFN_vkCmdBindVertexBuffers;
  vkCmdDraw: PFN_vkCmdDraw;
  vkCmdDrawIndexed: PFN_vkCmdDrawIndexed;
  vkCmdDrawMultiEXT: PFN_vkCmdDrawMultiEXT;
  vkCmdDrawMultiIndexedEXT: PFN_vkCmdDrawMultiIndexedEXT;
  vkCmdDrawIndirect: PFN_vkCmdDrawIndirect;
  vkCmdDrawIndexedIndirect: PFN_vkCmdDrawIndexedIndirect;
  vkCmdDispatch: PFN_vkCmdDispatch;
  vkCmdDispatchIndirect: PFN_vkCmdDispatchIndirect;
  vkCmdSubpassShadingHUAWEI: PFN_vkCmdSubpassShadingHUAWEI;
  vkCmdCopyBuffer: PFN_vkCmdCopyBuffer;
  vkCmdCopyImage: PFN_vkCmdCopyImage;
  vkCmdBlitImage: PFN_vkCmdBlitImage;
  vkCmdCopyBufferToImage: PFN_vkCmdCopyBufferToImage;
  vkCmdCopyImageToBuffer: PFN_vkCmdCopyImageToBuffer;
  vkCmdUpdateBuffer: PFN_vkCmdUpdateBuffer;
  vkCmdFillBuffer: PFN_vkCmdFillBuffer;
  vkCmdClearColorImage: PFN_vkCmdClearColorImage;
  vkCmdClearDepthStencilImage: PFN_vkCmdClearDepthStencilImage;
  vkCmdClearAttachments: PFN_vkCmdClearAttachments;
  vkCmdResolveImage: PFN_vkCmdResolveImage;
  vkCmdSetEvent: PFN_vkCmdSetEvent;
  vkCmdResetEvent: PFN_vkCmdResetEvent;
  vkCmdWaitEvents: PFN_vkCmdWaitEvents;
  vkCmdPipelineBarrier: PFN_vkCmdPipelineBarrier;
  vkCmdBeginQuery: PFN_vkCmdBeginQuery;
  vkCmdEndQuery: PFN_vkCmdEndQuery;
  vkCmdBeginConditionalRenderingEXT: PFN_vkCmdBeginConditionalRenderingEXT;
  vkCmdEndConditionalRenderingEXT: PFN_vkCmdEndConditionalRenderingEXT;
  vkCmdResetQueryPool: PFN_vkCmdResetQueryPool;
  vkCmdWriteTimestamp: PFN_vkCmdWriteTimestamp;
  vkCmdCopyQueryPoolResults: PFN_vkCmdCopyQueryPoolResults;
  vkCmdPushConstants: PFN_vkCmdPushConstants;
  vkCmdBeginRenderPass: PFN_vkCmdBeginRenderPass;
  vkCmdNextSubpass: PFN_vkCmdNextSubpass;
  vkCmdEndRenderPass: PFN_vkCmdEndRenderPass;
  vkCmdExecuteCommands: PFN_vkCmdExecuteCommands;
  vkCreateSharedSwapchainsKHR: PFN_vkCreateSharedSwapchainsKHR;
  vkCreateSwapchainKHR: PFN_vkCreateSwapchainKHR;
  vkDestroySwapchainKHR: PFN_vkDestroySwapchainKHR;
  vkGetSwapchainImagesKHR: PFN_vkGetSwapchainImagesKHR;
  vkAcquireNextImageKHR: PFN_vkAcquireNextImageKHR;
  vkQueuePresentKHR: PFN_vkQueuePresentKHR;
  vkDebugMarkerSetObjectNameEXT: PFN_vkDebugMarkerSetObjectNameEXT;
  vkDebugMarkerSetObjectTagEXT: PFN_vkDebugMarkerSetObjectTagEXT;
  vkCmdDebugMarkerBeginEXT: PFN_vkCmdDebugMarkerBeginEXT;
  vkCmdDebugMarkerEndEXT: PFN_vkCmdDebugMarkerEndEXT;
  vkCmdDebugMarkerInsertEXT: PFN_vkCmdDebugMarkerInsertEXT;
  vkGetMemoryWin32HandleNV: PFN_vkGetMemoryWin32HandleNV;
  vkCmdExecuteGeneratedCommandsNV: PFN_vkCmdExecuteGeneratedCommandsNV;
  vkCmdPreprocessGeneratedCommandsNV: PFN_vkCmdPreprocessGeneratedCommandsNV;
  vkCmdBindPipelineShaderGroupNV: PFN_vkCmdBindPipelineShaderGroupNV;
  vkGetGeneratedCommandsMemoryRequirementsNV: PFN_vkGetGeneratedCommandsMemoryRequirementsNV;
  vkCreateIndirectCommandsLayoutNV: PFN_vkCreateIndirectCommandsLayoutNV;
  vkDestroyIndirectCommandsLayoutNV: PFN_vkDestroyIndirectCommandsLayoutNV;
  vkCmdPushDescriptorSetKHR: PFN_vkCmdPushDescriptorSetKHR;
  vkTrimCommandPool: PFN_vkTrimCommandPool;
  vkGetMemoryWin32HandleKHR: PFN_vkGetMemoryWin32HandleKHR;
  vkGetMemoryWin32HandlePropertiesKHR: PFN_vkGetMemoryWin32HandlePropertiesKHR;
  vkGetMemoryFdKHR: PFN_vkGetMemoryFdKHR;
  vkGetMemoryFdPropertiesKHR: PFN_vkGetMemoryFdPropertiesKHR;
  vkGetMemoryRemoteAddressNV: PFN_vkGetMemoryRemoteAddressNV;
  vkGetSemaphoreWin32HandleKHR: PFN_vkGetSemaphoreWin32HandleKHR;
  vkImportSemaphoreWin32HandleKHR: PFN_vkImportSemaphoreWin32HandleKHR;
  vkGetSemaphoreFdKHR: PFN_vkGetSemaphoreFdKHR;
  vkImportSemaphoreFdKHR: PFN_vkImportSemaphoreFdKHR;
  vkGetFenceWin32HandleKHR: PFN_vkGetFenceWin32HandleKHR;
  vkImportFenceWin32HandleKHR: PFN_vkImportFenceWin32HandleKHR;
  vkGetFenceFdKHR: PFN_vkGetFenceFdKHR;
  vkImportFenceFdKHR: PFN_vkImportFenceFdKHR;
  vkDisplayPowerControlEXT: PFN_vkDisplayPowerControlEXT;
  vkRegisterDeviceEventEXT: PFN_vkRegisterDeviceEventEXT;
  vkRegisterDisplayEventEXT: PFN_vkRegisterDisplayEventEXT;
  vkGetSwapchainCounterEXT: PFN_vkGetSwapchainCounterEXT;
  vkGetDeviceGroupPeerMemoryFeatures: PFN_vkGetDeviceGroupPeerMemoryFeatures;
  vkBindBufferMemory2: PFN_vkBindBufferMemory2;
  vkBindImageMemory2: PFN_vkBindImageMemory2;
  vkCmdSetDeviceMask: PFN_vkCmdSetDeviceMask;
  vkGetDeviceGroupPresentCapabilitiesKHR: PFN_vkGetDeviceGroupPresentCapabilitiesKHR;
  vkGetDeviceGroupSurfacePresentModesKHR: PFN_vkGetDeviceGroupSurfacePresentModesKHR;
  vkAcquireNextImage2KHR: PFN_vkAcquireNextImage2KHR;
  vkCmdDispatchBase: PFN_vkCmdDispatchBase;
  vkCreateDescriptorUpdateTemplate: PFN_vkCreateDescriptorUpdateTemplate;
  vkDestroyDescriptorUpdateTemplate: PFN_vkDestroyDescriptorUpdateTemplate;
  vkUpdateDescriptorSetWithTemplate: PFN_vkUpdateDescriptorSetWithTemplate;
  vkCmdPushDescriptorSetWithTemplateKHR: PFN_vkCmdPushDescriptorSetWithTemplateKHR;
  vkSetHdrMetadataEXT: PFN_vkSetHdrMetadataEXT;
  vkGetSwapchainStatusKHR: PFN_vkGetSwapchainStatusKHR;
  vkGetRefreshCycleDurationGOOGLE: PFN_vkGetRefreshCycleDurationGOOGLE;
  vkGetPastPresentationTimingGOOGLE: PFN_vkGetPastPresentationTimingGOOGLE;
  vkCmdSetViewportWScalingNV: PFN_vkCmdSetViewportWScalingNV;
  vkCmdSetDiscardRectangleEXT: PFN_vkCmdSetDiscardRectangleEXT;
  vkCmdSetSampleLocationsEXT: PFN_vkCmdSetSampleLocationsEXT;
  vkGetBufferMemoryRequirements2: PFN_vkGetBufferMemoryRequirements2;
  vkGetImageMemoryRequirements2: PFN_vkGetImageMemoryRequirements2;
  vkGetImageSparseMemoryRequirements2: PFN_vkGetImageSparseMemoryRequirements2;
  vkCreateSamplerYcbcrConversion: PFN_vkCreateSamplerYcbcrConversion;
  vkDestroySamplerYcbcrConversion: PFN_vkDestroySamplerYcbcrConversion;
  vkGetDeviceQueue2: PFN_vkGetDeviceQueue2;
  vkCreateValidationCacheEXT: PFN_vkCreateValidationCacheEXT;
  vkDestroyValidationCacheEXT: PFN_vkDestroyValidationCacheEXT;
  vkGetValidationCacheDataEXT: PFN_vkGetValidationCacheDataEXT;
  vkMergeValidationCachesEXT: PFN_vkMergeValidationCachesEXT;
  vkGetDescriptorSetLayoutSupport: PFN_vkGetDescriptorSetLayoutSupport;
  vkGetSwapchainGrallocUsageANDROID: PFN_vkGetSwapchainGrallocUsageANDROID;
  vkGetSwapchainGrallocUsage2ANDROID: PFN_vkGetSwapchainGrallocUsage2ANDROID;
  vkAcquireImageANDROID: PFN_vkAcquireImageANDROID;
  vkQueueSignalReleaseImageANDROID: PFN_vkQueueSignalReleaseImageANDROID;
  vkGetShaderInfoAMD: PFN_vkGetShaderInfoAMD;
  vkSetLocalDimmingAMD: PFN_vkSetLocalDimmingAMD;
  vkGetCalibratedTimestampsEXT: PFN_vkGetCalibratedTimestampsEXT;
  vkSetDebugUtilsObjectNameEXT: PFN_vkSetDebugUtilsObjectNameEXT;
  vkSetDebugUtilsObjectTagEXT: PFN_vkSetDebugUtilsObjectTagEXT;
  vkQueueBeginDebugUtilsLabelEXT: PFN_vkQueueBeginDebugUtilsLabelEXT;
  vkQueueEndDebugUtilsLabelEXT: PFN_vkQueueEndDebugUtilsLabelEXT;
  vkQueueInsertDebugUtilsLabelEXT: PFN_vkQueueInsertDebugUtilsLabelEXT;
  vkCmdBeginDebugUtilsLabelEXT: PFN_vkCmdBeginDebugUtilsLabelEXT;
  vkCmdEndDebugUtilsLabelEXT: PFN_vkCmdEndDebugUtilsLabelEXT;
  vkCmdInsertDebugUtilsLabelEXT: PFN_vkCmdInsertDebugUtilsLabelEXT;
  vkGetMemoryHostPointerPropertiesEXT: PFN_vkGetMemoryHostPointerPropertiesEXT;
  vkCmdWriteBufferMarkerAMD: PFN_vkCmdWriteBufferMarkerAMD;
  vkCreateRenderPass2: PFN_vkCreateRenderPass2;
  vkCmdBeginRenderPass2: PFN_vkCmdBeginRenderPass2;
  vkCmdNextSubpass2: PFN_vkCmdNextSubpass2;
  vkCmdEndRenderPass2: PFN_vkCmdEndRenderPass2;
  vkGetSemaphoreCounterValue: PFN_vkGetSemaphoreCounterValue;
  vkWaitSemaphores: PFN_vkWaitSemaphores;
  vkSignalSemaphore: PFN_vkSignalSemaphore;
  vkGetAndroidHardwareBufferPropertiesANDROID: PFN_vkGetAndroidHardwareBufferPropertiesANDROID;
  vkGetMemoryAndroidHardwareBufferANDROID: PFN_vkGetMemoryAndroidHardwareBufferANDROID;
  vkCmdDrawIndirectCount: PFN_vkCmdDrawIndirectCount;
  vkCmdDrawIndexedIndirectCount: PFN_vkCmdDrawIndexedIndirectCount;
  vkCmdSetCheckpointNV: PFN_vkCmdSetCheckpointNV;
  vkGetQueueCheckpointDataNV: PFN_vkGetQueueCheckpointDataNV;
  vkCmdBindTransformFeedbackBuffersEXT: PFN_vkCmdBindTransformFeedbackBuffersEXT;
  vkCmdBeginTransformFeedbackEXT: PFN_vkCmdBeginTransformFeedbackEXT;
  vkCmdEndTransformFeedbackEXT: PFN_vkCmdEndTransformFeedbackEXT;
  vkCmdBeginQueryIndexedEXT: PFN_vkCmdBeginQueryIndexedEXT;
  vkCmdEndQueryIndexedEXT: PFN_vkCmdEndQueryIndexedEXT;
  vkCmdDrawIndirectByteCountEXT: PFN_vkCmdDrawIndirectByteCountEXT;
  vkCmdSetExclusiveScissorNV: PFN_vkCmdSetExclusiveScissorNV;
  vkCmdBindShadingRateImageNV: PFN_vkCmdBindShadingRateImageNV;
  vkCmdSetViewportShadingRatePaletteNV: PFN_vkCmdSetViewportShadingRatePaletteNV;
  vkCmdSetCoarseSampleOrderNV: PFN_vkCmdSetCoarseSampleOrderNV;
  vkCmdDrawMeshTasksNV: PFN_vkCmdDrawMeshTasksNV;
  vkCmdDrawMeshTasksIndirectNV: PFN_vkCmdDrawMeshTasksIndirectNV;
  vkCmdDrawMeshTasksIndirectCountNV: PFN_vkCmdDrawMeshTasksIndirectCountNV;
  vkCompileDeferredNV: PFN_vkCompileDeferredNV;
  vkCreateAccelerationStructureNV: PFN_vkCreateAccelerationStructureNV;
  vkCmdBindInvocationMaskHUAWEI: PFN_vkCmdBindInvocationMaskHUAWEI;
  vkDestroyAccelerationStructureKHR: PFN_vkDestroyAccelerationStructureKHR;
  vkDestroyAccelerationStructureNV: PFN_vkDestroyAccelerationStructureNV;
  vkGetAccelerationStructureMemoryRequirementsNV: PFN_vkGetAccelerationStructureMemoryRequirementsNV;
  vkBindAccelerationStructureMemoryNV: PFN_vkBindAccelerationStructureMemoryNV;
  vkCmdCopyAccelerationStructureNV: PFN_vkCmdCopyAccelerationStructureNV;
  vkCmdCopyAccelerationStructureKHR: PFN_vkCmdCopyAccelerationStructureKHR;
  vkCopyAccelerationStructureKHR: PFN_vkCopyAccelerationStructureKHR;
  vkCmdCopyAccelerationStructureToMemoryKHR: PFN_vkCmdCopyAccelerationStructureToMemoryKHR;
  vkCopyAccelerationStructureToMemoryKHR: PFN_vkCopyAccelerationStructureToMemoryKHR;
  vkCmdCopyMemoryToAccelerationStructureKHR: PFN_vkCmdCopyMemoryToAccelerationStructureKHR;
  vkCopyMemoryToAccelerationStructureKHR: PFN_vkCopyMemoryToAccelerationStructureKHR;
  vkCmdWriteAccelerationStructuresPropertiesKHR: PFN_vkCmdWriteAccelerationStructuresPropertiesKHR;
  vkCmdWriteAccelerationStructuresPropertiesNV: PFN_vkCmdWriteAccelerationStructuresPropertiesNV;
  vkCmdBuildAccelerationStructureNV: PFN_vkCmdBuildAccelerationStructureNV;
  vkWriteAccelerationStructuresPropertiesKHR: PFN_vkWriteAccelerationStructuresPropertiesKHR;
  vkCmdTraceRaysKHR: PFN_vkCmdTraceRaysKHR;
  vkCmdTraceRaysNV: PFN_vkCmdTraceRaysNV;
  vkGetRayTracingShaderGroupHandlesKHR: PFN_vkGetRayTracingShaderGroupHandlesKHR;
  vkGetRayTracingCaptureReplayShaderGroupHandlesKHR: PFN_vkGetRayTracingCaptureReplayShaderGroupHandlesKHR;
  vkGetAccelerationStructureHandleNV: PFN_vkGetAccelerationStructureHandleNV;
  vkCreateRayTracingPipelinesNV: PFN_vkCreateRayTracingPipelinesNV;
  vkCreateRayTracingPipelinesKHR: PFN_vkCreateRayTracingPipelinesKHR;
  vkCmdTraceRaysIndirectKHR: PFN_vkCmdTraceRaysIndirectKHR;
  vkGetDeviceAccelerationStructureCompatibilityKHR: PFN_vkGetDeviceAccelerationStructureCompatibilityKHR;
  vkGetRayTracingShaderGroupStackSizeKHR: PFN_vkGetRayTracingShaderGroupStackSizeKHR;
  vkCmdSetRayTracingPipelineStackSizeKHR: PFN_vkCmdSetRayTracingPipelineStackSizeKHR;
  vkGetImageViewHandleNVX: PFN_vkGetImageViewHandleNVX;
  vkGetImageViewAddressNVX: PFN_vkGetImageViewAddressNVX;
  vkGetDeviceGroupSurfacePresentModes2EXT: PFN_vkGetDeviceGroupSurfacePresentModes2EXT;
  vkAcquireFullScreenExclusiveModeEXT: PFN_vkAcquireFullScreenExclusiveModeEXT;
  vkReleaseFullScreenExclusiveModeEXT: PFN_vkReleaseFullScreenExclusiveModeEXT;
  vkAcquireProfilingLockKHR: PFN_vkAcquireProfilingLockKHR;
  vkReleaseProfilingLockKHR: PFN_vkReleaseProfilingLockKHR;
  vkGetImageDrmFormatModifierPropertiesEXT: PFN_vkGetImageDrmFormatModifierPropertiesEXT;
  vkGetBufferOpaqueCaptureAddress: PFN_vkGetBufferOpaqueCaptureAddress;
  vkGetBufferDeviceAddress: PFN_vkGetBufferDeviceAddress;
  vkInitializePerformanceApiINTEL: PFN_vkInitializePerformanceApiINTEL;
  vkUninitializePerformanceApiINTEL: PFN_vkUninitializePerformanceApiINTEL;
  vkCmdSetPerformanceMarkerINTEL: PFN_vkCmdSetPerformanceMarkerINTEL;
  vkCmdSetPerformanceStreamMarkerINTEL: PFN_vkCmdSetPerformanceStreamMarkerINTEL;
  vkCmdSetPerformanceOverrideINTEL: PFN_vkCmdSetPerformanceOverrideINTEL;
  vkAcquirePerformanceConfigurationINTEL: PFN_vkAcquirePerformanceConfigurationINTEL;
  vkReleasePerformanceConfigurationINTEL: PFN_vkReleasePerformanceConfigurationINTEL;
  vkQueueSetPerformanceConfigurationINTEL: PFN_vkQueueSetPerformanceConfigurationINTEL;
  vkGetPerformanceParameterINTEL: PFN_vkGetPerformanceParameterINTEL;
  vkGetDeviceMemoryOpaqueCaptureAddress: PFN_vkGetDeviceMemoryOpaqueCaptureAddress;
  vkGetPipelineExecutablePropertiesKHR: PFN_vkGetPipelineExecutablePropertiesKHR;
  vkGetPipelineExecutableStatisticsKHR: PFN_vkGetPipelineExecutableStatisticsKHR;
  vkGetPipelineExecutableInternalRepresentationsKHR: PFN_vkGetPipelineExecutableInternalRepresentationsKHR;
  vkCmdSetLineStippleEXT: PFN_vkCmdSetLineStippleEXT;
  vkCreateAccelerationStructureKHR: PFN_vkCreateAccelerationStructureKHR;
  vkCmdBuildAccelerationStructuresKHR: PFN_vkCmdBuildAccelerationStructuresKHR;
  vkCmdBuildAccelerationStructuresIndirectKHR: PFN_vkCmdBuildAccelerationStructuresIndirectKHR;
  vkBuildAccelerationStructuresKHR: PFN_vkBuildAccelerationStructuresKHR;
  vkGetAccelerationStructureDeviceAddressKHR: PFN_vkGetAccelerationStructureDeviceAddressKHR;
  vkCreateDeferredOperationKHR: PFN_vkCreateDeferredOperationKHR;
  vkDestroyDeferredOperationKHR: PFN_vkDestroyDeferredOperationKHR;
  vkGetDeferredOperationMaxConcurrencyKHR: PFN_vkGetDeferredOperationMaxConcurrencyKHR;
  vkGetDeferredOperationResultKHR: PFN_vkGetDeferredOperationResultKHR;
  vkDeferredOperationJoinKHR: PFN_vkDeferredOperationJoinKHR;
  vkCmdSetCullModeEXT: PFN_vkCmdSetCullModeEXT;
  vkCmdSetFrontFaceEXT: PFN_vkCmdSetFrontFaceEXT;
  vkCmdSetPrimitiveTopologyEXT: PFN_vkCmdSetPrimitiveTopologyEXT;
  vkCmdSetViewportWithCountEXT: PFN_vkCmdSetViewportWithCountEXT;
  vkCmdSetScissorWithCountEXT: PFN_vkCmdSetScissorWithCountEXT;
  vkCmdBindVertexBuffers2EXT: PFN_vkCmdBindVertexBuffers2EXT;
  vkCmdSetDepthTestEnableEXT: PFN_vkCmdSetDepthTestEnableEXT;
  vkCmdSetDepthWriteEnableEXT: PFN_vkCmdSetDepthWriteEnableEXT;
  vkCmdSetDepthCompareOpEXT: PFN_vkCmdSetDepthCompareOpEXT;
  vkCmdSetDepthBoundsTestEnableEXT: PFN_vkCmdSetDepthBoundsTestEnableEXT;
  vkCmdSetStencilTestEnableEXT: PFN_vkCmdSetStencilTestEnableEXT;
  vkCmdSetStencilOpEXT: PFN_vkCmdSetStencilOpEXT;
  vkCmdSetPatchControlPointsEXT: PFN_vkCmdSetPatchControlPointsEXT;
  vkCmdSetRasterizerDiscardEnableEXT: PFN_vkCmdSetRasterizerDiscardEnableEXT;
  vkCmdSetDepthBiasEnableEXT: PFN_vkCmdSetDepthBiasEnableEXT;
  vkCmdSetLogicOpEXT: PFN_vkCmdSetLogicOpEXT;
  vkCmdSetPrimitiveRestartEnableEXT: PFN_vkCmdSetPrimitiveRestartEnableEXT;
  vkCreatePrivateDataSlotEXT: PFN_vkCreatePrivateDataSlotEXT;
  vkDestroyPrivateDataSlotEXT: PFN_vkDestroyPrivateDataSlotEXT;
  vkSetPrivateDataEXT: PFN_vkSetPrivateDataEXT;
  vkGetPrivateDataEXT: PFN_vkGetPrivateDataEXT;
  vkCmdCopyBuffer2KHR: PFN_vkCmdCopyBuffer2KHR;
  vkCmdCopyImage2KHR: PFN_vkCmdCopyImage2KHR;
  vkCmdBlitImage2KHR: PFN_vkCmdBlitImage2KHR;
  vkCmdCopyBufferToImage2KHR: PFN_vkCmdCopyBufferToImage2KHR;
  vkCmdCopyImageToBuffer2KHR: PFN_vkCmdCopyImageToBuffer2KHR;
  vkCmdResolveImage2KHR: PFN_vkCmdResolveImage2KHR;
  vkCmdSetFragmentShadingRateKHR: PFN_vkCmdSetFragmentShadingRateKHR;
  vkCmdSetFragmentShadingRateEnumNV: PFN_vkCmdSetFragmentShadingRateEnumNV;
  vkGetAccelerationStructureBuildSizesKHR: PFN_vkGetAccelerationStructureBuildSizesKHR;
  vkCmdSetVertexInputEXT: PFN_vkCmdSetVertexInputEXT;
  vkCmdSetColorWriteEnableEXT: PFN_vkCmdSetColorWriteEnableEXT;
  vkCmdSetEvent2KHR: PFN_vkCmdSetEvent2KHR;
  vkCmdResetEvent2KHR: PFN_vkCmdResetEvent2KHR;
  vkCmdWaitEvents2KHR: PFN_vkCmdWaitEvents2KHR;
  vkCmdPipelineBarrier2KHR: PFN_vkCmdPipelineBarrier2KHR;
  vkQueueSubmit2KHR: PFN_vkQueueSubmit2KHR;
  vkCmdWriteTimestamp2KHR: PFN_vkCmdWriteTimestamp2KHR;
  vkCmdWriteBufferMarker2AMD: PFN_vkCmdWriteBufferMarker2AMD;
  vkGetQueueCheckpointData2NV: PFN_vkGetQueueCheckpointData2NV;
  vkCreateVideoSessionKHR: PFN_vkCreateVideoSessionKHR;
  vkDestroyVideoSessionKHR: PFN_vkDestroyVideoSessionKHR;
  vkCreateVideoSessionParametersKHR: PFN_vkCreateVideoSessionParametersKHR;
  vkUpdateVideoSessionParametersKHR: PFN_vkUpdateVideoSessionParametersKHR;
  vkDestroyVideoSessionParametersKHR: PFN_vkDestroyVideoSessionParametersKHR;
  vkGetVideoSessionMemoryRequirementsKHR: PFN_vkGetVideoSessionMemoryRequirementsKHR;
  vkBindVideoSessionMemoryKHR: PFN_vkBindVideoSessionMemoryKHR;
  vkCmdDecodeVideoKHR: PFN_vkCmdDecodeVideoKHR;
  vkCmdBeginVideoCodingKHR: PFN_vkCmdBeginVideoCodingKHR;
  vkCmdControlVideoCodingKHR: PFN_vkCmdControlVideoCodingKHR;
  vkCmdEndVideoCodingKHR: PFN_vkCmdEndVideoCodingKHR;
  vkCmdEncodeVideoKHR: PFN_vkCmdEncodeVideoKHR;
  vkCreateCuModuleNVX: PFN_vkCreateCuModuleNVX;
  vkCreateCuFunctionNVX: PFN_vkCreateCuFunctionNVX;
  vkDestroyCuModuleNVX: PFN_vkDestroyCuModuleNVX;
  vkDestroyCuFunctionNVX: PFN_vkDestroyCuFunctionNVX;
  vkCmdCuLaunchKernelNVX: PFN_vkCmdCuLaunchKernelNVX;
  vkWaitForPresentKHR: PFN_vkWaitForPresentKHR;
end;

function vkGetInstanceProcAddr(instance: VkInstance;
                               pName: PAnsiChar): PFN_vkVoidFunction;
                               stdcall; external VulkanLibraryName;
     // Statically loaded system vkGetInstanceProcAddr

function LoadVulkanGeneralFunctions(_vkGetInstanceProcAddr: PFN_vkGetInstanceProcAddr; var GeneralFunctions: TVulkanGeneralFunctions): Boolean;
     // Loads all global Vulkan functions with the specified vkGetInstanceProcAddr
     // function. You may pass the global vkGetInstanceProcAddr.

function LoadVulkanInstanceFunctions(Instance: VkInstance; _vkGetInstanceProcAddr: PFN_vkGetInstanceProcAddr; var InstanceFunctions: TVulkanInstanceFunctions): Boolean;
     // Loads instance-related functions. You should create an instance
     // first before calling this function.

function LoadVulkanDeviceFunctions(Device: VkDevice; _vkGetDeviceProcAddr: PFN_vkGetDeviceProcAddr; var DeviceFunctions: TVulkanDeviceFunctions): Boolean;
     // Loads device-related functions. You should create a device
     // first before calling this function. Returned functions can
     // be used only for the specified Device.
{$ENDIF}

implementation

{$IF Defined(DVULKAN_LOADER)}
function LoadVulkanGeneralFunctions(_vkGetInstanceProcAddr: PFN_vkGetInstanceProcAddr; var GeneralFunctions: TVulkanGeneralFunctions): Boolean;
begin
  GeneralFunctions.vkCreateInstance := PFN_vkCreateInstance(_vkGetInstanceProcAddr(VkInstance(0), 'vkCreateInstance'));
  Pointer(GeneralFunctions.vkGetInstanceProcAddr) := PFN_vkGetInstanceProcAddr(_vkGetInstanceProcAddr(VkInstance(0), 'vkGetInstanceProcAddr'));
  GeneralFunctions.vkEnumerateInstanceVersion := PFN_vkEnumerateInstanceVersion(_vkGetInstanceProcAddr(VkInstance(0), 'vkEnumerateInstanceVersion'));
  GeneralFunctions.vkEnumerateInstanceLayerProperties := PFN_vkEnumerateInstanceLayerProperties(_vkGetInstanceProcAddr(VkInstance(0), 'vkEnumerateInstanceLayerProperties'));
  GeneralFunctions.vkEnumerateInstanceExtensionProperties := PFN_vkEnumerateInstanceExtensionProperties(_vkGetInstanceProcAddr(VkInstance(0), 'vkEnumerateInstanceExtensionProperties'));

  // vkGetInstanceProcAddr(nil, 'vkGetInstanceProcAddr') returns NULL prior to Vulkan 1.2, see the spec
  if GeneralFunctions.vkGetInstanceProcAddr = nil then begin
    GeneralFunctions.vkGetInstanceProcAddr := _vkGetInstanceProcAddr;
  end;

  Exit(True);
end;

function LoadVulkanInstanceFunctions(Instance: VkInstance; _vkGetInstanceProcAddr: PFN_vkGetInstanceProcAddr; var InstanceFunctions: TVulkanInstanceFunctions): Boolean;
begin
  InstanceFunctions.vkDestroyInstance := PFN_vkDestroyInstance(_vkGetInstanceProcAddr(Instance, 'vkDestroyInstance'));
  InstanceFunctions.vkEnumeratePhysicalDevices := PFN_vkEnumeratePhysicalDevices(_vkGetInstanceProcAddr(Instance, 'vkEnumeratePhysicalDevices'));
  Pointer(InstanceFunctions.vkGetDeviceProcAddr) := PFN_vkGetDeviceProcAddr(_vkGetInstanceProcAddr(Instance, 'vkGetDeviceProcAddr'));
  InstanceFunctions.vkGetPhysicalDeviceProperties := PFN_vkGetPhysicalDeviceProperties(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceProperties'));
  InstanceFunctions.vkGetPhysicalDeviceQueueFamilyProperties := PFN_vkGetPhysicalDeviceQueueFamilyProperties(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceQueueFamilyProperties'));
  InstanceFunctions.vkGetPhysicalDeviceMemoryProperties := PFN_vkGetPhysicalDeviceMemoryProperties(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceMemoryProperties'));
  InstanceFunctions.vkGetPhysicalDeviceFeatures := PFN_vkGetPhysicalDeviceFeatures(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceFeatures'));
  InstanceFunctions.vkGetPhysicalDeviceFormatProperties := PFN_vkGetPhysicalDeviceFormatProperties(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceFormatProperties'));
  InstanceFunctions.vkGetPhysicalDeviceImageFormatProperties := PFN_vkGetPhysicalDeviceImageFormatProperties(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceImageFormatProperties'));
  InstanceFunctions.vkCreateDevice := PFN_vkCreateDevice(_vkGetInstanceProcAddr(Instance, 'vkCreateDevice'));
  InstanceFunctions.vkEnumerateDeviceLayerProperties := PFN_vkEnumerateDeviceLayerProperties(_vkGetInstanceProcAddr(Instance, 'vkEnumerateDeviceLayerProperties'));
  InstanceFunctions.vkEnumerateDeviceExtensionProperties := PFN_vkEnumerateDeviceExtensionProperties(_vkGetInstanceProcAddr(Instance, 'vkEnumerateDeviceExtensionProperties'));
  InstanceFunctions.vkGetPhysicalDeviceSparseImageFormatProperties := PFN_vkGetPhysicalDeviceSparseImageFormatProperties(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceSparseImageFormatProperties'));
  InstanceFunctions.vkCreateAndroidSurfaceKHR := PFN_vkCreateAndroidSurfaceKHR(_vkGetInstanceProcAddr(Instance, 'vkCreateAndroidSurfaceKHR'));
  InstanceFunctions.vkGetPhysicalDeviceDisplayPropertiesKHR := PFN_vkGetPhysicalDeviceDisplayPropertiesKHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceDisplayPropertiesKHR'));
  InstanceFunctions.vkGetPhysicalDeviceDisplayPlanePropertiesKHR := PFN_vkGetPhysicalDeviceDisplayPlanePropertiesKHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceDisplayPlanePropertiesKHR'));
  InstanceFunctions.vkGetDisplayPlaneSupportedDisplaysKHR := PFN_vkGetDisplayPlaneSupportedDisplaysKHR(_vkGetInstanceProcAddr(Instance, 'vkGetDisplayPlaneSupportedDisplaysKHR'));
  InstanceFunctions.vkGetDisplayModePropertiesKHR := PFN_vkGetDisplayModePropertiesKHR(_vkGetInstanceProcAddr(Instance, 'vkGetDisplayModePropertiesKHR'));
  InstanceFunctions.vkCreateDisplayModeKHR := PFN_vkCreateDisplayModeKHR(_vkGetInstanceProcAddr(Instance, 'vkCreateDisplayModeKHR'));
  InstanceFunctions.vkGetDisplayPlaneCapabilitiesKHR := PFN_vkGetDisplayPlaneCapabilitiesKHR(_vkGetInstanceProcAddr(Instance, 'vkGetDisplayPlaneCapabilitiesKHR'));
  InstanceFunctions.vkCreateDisplayPlaneSurfaceKHR := PFN_vkCreateDisplayPlaneSurfaceKHR(_vkGetInstanceProcAddr(Instance, 'vkCreateDisplayPlaneSurfaceKHR'));
  InstanceFunctions.vkDestroySurfaceKHR := PFN_vkDestroySurfaceKHR(_vkGetInstanceProcAddr(Instance, 'vkDestroySurfaceKHR'));
  InstanceFunctions.vkGetPhysicalDeviceSurfaceSupportKHR := PFN_vkGetPhysicalDeviceSurfaceSupportKHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceSurfaceSupportKHR'));
  InstanceFunctions.vkGetPhysicalDeviceSurfaceCapabilitiesKHR := PFN_vkGetPhysicalDeviceSurfaceCapabilitiesKHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceSurfaceCapabilitiesKHR'));
  InstanceFunctions.vkGetPhysicalDeviceSurfaceFormatsKHR := PFN_vkGetPhysicalDeviceSurfaceFormatsKHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceSurfaceFormatsKHR'));
  InstanceFunctions.vkGetPhysicalDeviceSurfacePresentModesKHR := PFN_vkGetPhysicalDeviceSurfacePresentModesKHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceSurfacePresentModesKHR'));
  InstanceFunctions.vkCreateViSurfaceNN := PFN_vkCreateViSurfaceNN(_vkGetInstanceProcAddr(Instance, 'vkCreateViSurfaceNN'));
  InstanceFunctions.vkCreateWin32SurfaceKHR := PFN_vkCreateWin32SurfaceKHR(_vkGetInstanceProcAddr(Instance, 'vkCreateWin32SurfaceKHR'));
  InstanceFunctions.vkGetPhysicalDeviceWin32PresentationSupportKHR := PFN_vkGetPhysicalDeviceWin32PresentationSupportKHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceWin32PresentationSupportKHR'));
  InstanceFunctions.vkCreateDebugReportCallbackEXT := PFN_vkCreateDebugReportCallbackEXT(_vkGetInstanceProcAddr(Instance, 'vkCreateDebugReportCallbackEXT'));
  InstanceFunctions.vkDestroyDebugReportCallbackEXT := PFN_vkDestroyDebugReportCallbackEXT(_vkGetInstanceProcAddr(Instance, 'vkDestroyDebugReportCallbackEXT'));
  InstanceFunctions.vkDebugReportMessageEXT := PFN_vkDebugReportMessageEXT(_vkGetInstanceProcAddr(Instance, 'vkDebugReportMessageEXT'));
  InstanceFunctions.vkGetPhysicalDeviceExternalImageFormatPropertiesNV := PFN_vkGetPhysicalDeviceExternalImageFormatPropertiesNV(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceExternalImageFormatPropertiesNV'));
  InstanceFunctions.vkGetPhysicalDeviceFeatures2 := PFN_vkGetPhysicalDeviceFeatures2(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceFeatures2'));
  InstanceFunctions.vkGetPhysicalDeviceProperties2 := PFN_vkGetPhysicalDeviceProperties2(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceProperties2'));
  InstanceFunctions.vkGetPhysicalDeviceFormatProperties2 := PFN_vkGetPhysicalDeviceFormatProperties2(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceFormatProperties2'));
  InstanceFunctions.vkGetPhysicalDeviceImageFormatProperties2 := PFN_vkGetPhysicalDeviceImageFormatProperties2(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceImageFormatProperties2'));
  InstanceFunctions.vkGetPhysicalDeviceQueueFamilyProperties2 := PFN_vkGetPhysicalDeviceQueueFamilyProperties2(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceQueueFamilyProperties2'));
  InstanceFunctions.vkGetPhysicalDeviceMemoryProperties2 := PFN_vkGetPhysicalDeviceMemoryProperties2(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceMemoryProperties2'));
  InstanceFunctions.vkGetPhysicalDeviceSparseImageFormatProperties2 := PFN_vkGetPhysicalDeviceSparseImageFormatProperties2(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceSparseImageFormatProperties2'));
  InstanceFunctions.vkGetPhysicalDeviceExternalBufferProperties := PFN_vkGetPhysicalDeviceExternalBufferProperties(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceExternalBufferProperties'));
  InstanceFunctions.vkGetPhysicalDeviceExternalSemaphoreProperties := PFN_vkGetPhysicalDeviceExternalSemaphoreProperties(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceExternalSemaphoreProperties'));
  InstanceFunctions.vkGetPhysicalDeviceExternalFenceProperties := PFN_vkGetPhysicalDeviceExternalFenceProperties(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceExternalFenceProperties'));
  InstanceFunctions.vkReleaseDisplayEXT := PFN_vkReleaseDisplayEXT(_vkGetInstanceProcAddr(Instance, 'vkReleaseDisplayEXT'));
  InstanceFunctions.vkAcquireWinrtDisplayNV := PFN_vkAcquireWinrtDisplayNV(_vkGetInstanceProcAddr(Instance, 'vkAcquireWinrtDisplayNV'));
  InstanceFunctions.vkGetWinrtDisplayNV := PFN_vkGetWinrtDisplayNV(_vkGetInstanceProcAddr(Instance, 'vkGetWinrtDisplayNV'));
  InstanceFunctions.vkGetPhysicalDeviceSurfaceCapabilities2EXT := PFN_vkGetPhysicalDeviceSurfaceCapabilities2EXT(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceSurfaceCapabilities2EXT'));
  InstanceFunctions.vkEnumeratePhysicalDeviceGroups := PFN_vkEnumeratePhysicalDeviceGroups(_vkGetInstanceProcAddr(Instance, 'vkEnumeratePhysicalDeviceGroups'));
  InstanceFunctions.vkGetPhysicalDevicePresentRectanglesKHR := PFN_vkGetPhysicalDevicePresentRectanglesKHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDevicePresentRectanglesKHR'));
  InstanceFunctions.vkCreateIOSSurfaceMVK := PFN_vkCreateIOSSurfaceMVK(_vkGetInstanceProcAddr(Instance, 'vkCreateIOSSurfaceMVK'));
  InstanceFunctions.vkCreateMacOSSurfaceMVK := PFN_vkCreateMacOSSurfaceMVK(_vkGetInstanceProcAddr(Instance, 'vkCreateMacOSSurfaceMVK'));
  InstanceFunctions.vkCreateMetalSurfaceEXT := PFN_vkCreateMetalSurfaceEXT(_vkGetInstanceProcAddr(Instance, 'vkCreateMetalSurfaceEXT'));
  InstanceFunctions.vkGetPhysicalDeviceMultisamplePropertiesEXT := PFN_vkGetPhysicalDeviceMultisamplePropertiesEXT(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceMultisamplePropertiesEXT'));
  InstanceFunctions.vkGetPhysicalDeviceSurfaceCapabilities2KHR := PFN_vkGetPhysicalDeviceSurfaceCapabilities2KHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceSurfaceCapabilities2KHR'));
  InstanceFunctions.vkGetPhysicalDeviceSurfaceFormats2KHR := PFN_vkGetPhysicalDeviceSurfaceFormats2KHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceSurfaceFormats2KHR'));
  InstanceFunctions.vkGetPhysicalDeviceDisplayProperties2KHR := PFN_vkGetPhysicalDeviceDisplayProperties2KHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceDisplayProperties2KHR'));
  InstanceFunctions.vkGetPhysicalDeviceDisplayPlaneProperties2KHR := PFN_vkGetPhysicalDeviceDisplayPlaneProperties2KHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceDisplayPlaneProperties2KHR'));
  InstanceFunctions.vkGetDisplayModeProperties2KHR := PFN_vkGetDisplayModeProperties2KHR(_vkGetInstanceProcAddr(Instance, 'vkGetDisplayModeProperties2KHR'));
  InstanceFunctions.vkGetDisplayPlaneCapabilities2KHR := PFN_vkGetDisplayPlaneCapabilities2KHR(_vkGetInstanceProcAddr(Instance, 'vkGetDisplayPlaneCapabilities2KHR'));
  InstanceFunctions.vkGetPhysicalDeviceCalibrateableTimeDomainsEXT := PFN_vkGetPhysicalDeviceCalibrateableTimeDomainsEXT(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceCalibrateableTimeDomainsEXT'));
  InstanceFunctions.vkCreateDebugUtilsMessengerEXT := PFN_vkCreateDebugUtilsMessengerEXT(_vkGetInstanceProcAddr(Instance, 'vkCreateDebugUtilsMessengerEXT'));
  InstanceFunctions.vkDestroyDebugUtilsMessengerEXT := PFN_vkDestroyDebugUtilsMessengerEXT(_vkGetInstanceProcAddr(Instance, 'vkDestroyDebugUtilsMessengerEXT'));
  InstanceFunctions.vkSubmitDebugUtilsMessageEXT := PFN_vkSubmitDebugUtilsMessageEXT(_vkGetInstanceProcAddr(Instance, 'vkSubmitDebugUtilsMessageEXT'));
  InstanceFunctions.vkGetPhysicalDeviceCooperativeMatrixPropertiesNV := PFN_vkGetPhysicalDeviceCooperativeMatrixPropertiesNV(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceCooperativeMatrixPropertiesNV'));
  InstanceFunctions.vkGetPhysicalDeviceSurfacePresentModes2EXT := PFN_vkGetPhysicalDeviceSurfacePresentModes2EXT(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceSurfacePresentModes2EXT'));
  InstanceFunctions.vkEnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR := PFN_vkEnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR(_vkGetInstanceProcAddr(Instance, 'vkEnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR'));
  InstanceFunctions.vkGetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR := PFN_vkGetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR'));
  InstanceFunctions.vkCreateHeadlessSurfaceEXT := PFN_vkCreateHeadlessSurfaceEXT(_vkGetInstanceProcAddr(Instance, 'vkCreateHeadlessSurfaceEXT'));
  InstanceFunctions.vkGetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV := PFN_vkGetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV'));
  InstanceFunctions.vkGetPhysicalDeviceToolPropertiesEXT := PFN_vkGetPhysicalDeviceToolPropertiesEXT(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceToolPropertiesEXT'));
  InstanceFunctions.vkGetPhysicalDeviceFragmentShadingRatesKHR := PFN_vkGetPhysicalDeviceFragmentShadingRatesKHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceFragmentShadingRatesKHR'));
  InstanceFunctions.vkGetPhysicalDeviceVideoCapabilitiesKHR := PFN_vkGetPhysicalDeviceVideoCapabilitiesKHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceVideoCapabilitiesKHR'));
  InstanceFunctions.vkGetPhysicalDeviceVideoFormatPropertiesKHR := PFN_vkGetPhysicalDeviceVideoFormatPropertiesKHR(_vkGetInstanceProcAddr(Instance, 'vkGetPhysicalDeviceVideoFormatPropertiesKHR'));
  InstanceFunctions.vkAcquireDrmDisplayEXT := PFN_vkAcquireDrmDisplayEXT(_vkGetInstanceProcAddr(Instance, 'vkAcquireDrmDisplayEXT'));
  InstanceFunctions.vkGetDrmDisplayEXT := PFN_vkGetDrmDisplayEXT(_vkGetInstanceProcAddr(Instance, 'vkGetDrmDisplayEXT'));
  Exit(True);
end;

function LoadVulkanDeviceFunctions(Device: VkDevice; _vkGetDeviceProcAddr: PFN_vkGetDeviceProcAddr; var DeviceFunctions: TVulkanDeviceFunctions): Boolean;
begin
  DeviceFunctions.vkDestroyDevice := PFN_vkDestroyDevice(_vkGetDeviceProcAddr(Device, 'vkDestroyDevice'));
  DeviceFunctions.vkGetDeviceQueue := PFN_vkGetDeviceQueue(_vkGetDeviceProcAddr(Device, 'vkGetDeviceQueue'));
  DeviceFunctions.vkQueueSubmit := PFN_vkQueueSubmit(_vkGetDeviceProcAddr(Device, 'vkQueueSubmit'));
  DeviceFunctions.vkQueueWaitIdle := PFN_vkQueueWaitIdle(_vkGetDeviceProcAddr(Device, 'vkQueueWaitIdle'));
  DeviceFunctions.vkDeviceWaitIdle := PFN_vkDeviceWaitIdle(_vkGetDeviceProcAddr(Device, 'vkDeviceWaitIdle'));
  DeviceFunctions.vkAllocateMemory := PFN_vkAllocateMemory(_vkGetDeviceProcAddr(Device, 'vkAllocateMemory'));
  DeviceFunctions.vkFreeMemory := PFN_vkFreeMemory(_vkGetDeviceProcAddr(Device, 'vkFreeMemory'));
  DeviceFunctions.vkMapMemory := PFN_vkMapMemory(_vkGetDeviceProcAddr(Device, 'vkMapMemory'));
  DeviceFunctions.vkUnmapMemory := PFN_vkUnmapMemory(_vkGetDeviceProcAddr(Device, 'vkUnmapMemory'));
  DeviceFunctions.vkFlushMappedMemoryRanges := PFN_vkFlushMappedMemoryRanges(_vkGetDeviceProcAddr(Device, 'vkFlushMappedMemoryRanges'));
  DeviceFunctions.vkInvalidateMappedMemoryRanges := PFN_vkInvalidateMappedMemoryRanges(_vkGetDeviceProcAddr(Device, 'vkInvalidateMappedMemoryRanges'));
  DeviceFunctions.vkGetDeviceMemoryCommitment := PFN_vkGetDeviceMemoryCommitment(_vkGetDeviceProcAddr(Device, 'vkGetDeviceMemoryCommitment'));
  DeviceFunctions.vkGetBufferMemoryRequirements := PFN_vkGetBufferMemoryRequirements(_vkGetDeviceProcAddr(Device, 'vkGetBufferMemoryRequirements'));
  DeviceFunctions.vkBindBufferMemory := PFN_vkBindBufferMemory(_vkGetDeviceProcAddr(Device, 'vkBindBufferMemory'));
  DeviceFunctions.vkGetImageMemoryRequirements := PFN_vkGetImageMemoryRequirements(_vkGetDeviceProcAddr(Device, 'vkGetImageMemoryRequirements'));
  DeviceFunctions.vkBindImageMemory := PFN_vkBindImageMemory(_vkGetDeviceProcAddr(Device, 'vkBindImageMemory'));
  DeviceFunctions.vkGetImageSparseMemoryRequirements := PFN_vkGetImageSparseMemoryRequirements(_vkGetDeviceProcAddr(Device, 'vkGetImageSparseMemoryRequirements'));
  DeviceFunctions.vkQueueBindSparse := PFN_vkQueueBindSparse(_vkGetDeviceProcAddr(Device, 'vkQueueBindSparse'));
  DeviceFunctions.vkCreateFence := PFN_vkCreateFence(_vkGetDeviceProcAddr(Device, 'vkCreateFence'));
  DeviceFunctions.vkDestroyFence := PFN_vkDestroyFence(_vkGetDeviceProcAddr(Device, 'vkDestroyFence'));
  DeviceFunctions.vkResetFences := PFN_vkResetFences(_vkGetDeviceProcAddr(Device, 'vkResetFences'));
  DeviceFunctions.vkGetFenceStatus := PFN_vkGetFenceStatus(_vkGetDeviceProcAddr(Device, 'vkGetFenceStatus'));
  DeviceFunctions.vkWaitForFences := PFN_vkWaitForFences(_vkGetDeviceProcAddr(Device, 'vkWaitForFences'));
  DeviceFunctions.vkCreateSemaphore := PFN_vkCreateSemaphore(_vkGetDeviceProcAddr(Device, 'vkCreateSemaphore'));
  DeviceFunctions.vkDestroySemaphore := PFN_vkDestroySemaphore(_vkGetDeviceProcAddr(Device, 'vkDestroySemaphore'));
  DeviceFunctions.vkCreateEvent := PFN_vkCreateEvent(_vkGetDeviceProcAddr(Device, 'vkCreateEvent'));
  DeviceFunctions.vkDestroyEvent := PFN_vkDestroyEvent(_vkGetDeviceProcAddr(Device, 'vkDestroyEvent'));
  DeviceFunctions.vkGetEventStatus := PFN_vkGetEventStatus(_vkGetDeviceProcAddr(Device, 'vkGetEventStatus'));
  DeviceFunctions.vkSetEvent := PFN_vkSetEvent(_vkGetDeviceProcAddr(Device, 'vkSetEvent'));
  DeviceFunctions.vkResetEvent := PFN_vkResetEvent(_vkGetDeviceProcAddr(Device, 'vkResetEvent'));
  DeviceFunctions.vkCreateQueryPool := PFN_vkCreateQueryPool(_vkGetDeviceProcAddr(Device, 'vkCreateQueryPool'));
  DeviceFunctions.vkDestroyQueryPool := PFN_vkDestroyQueryPool(_vkGetDeviceProcAddr(Device, 'vkDestroyQueryPool'));
  DeviceFunctions.vkGetQueryPoolResults := PFN_vkGetQueryPoolResults(_vkGetDeviceProcAddr(Device, 'vkGetQueryPoolResults'));
  DeviceFunctions.vkResetQueryPool := PFN_vkResetQueryPool(_vkGetDeviceProcAddr(Device, 'vkResetQueryPool'));
  DeviceFunctions.vkCreateBuffer := PFN_vkCreateBuffer(_vkGetDeviceProcAddr(Device, 'vkCreateBuffer'));
  DeviceFunctions.vkDestroyBuffer := PFN_vkDestroyBuffer(_vkGetDeviceProcAddr(Device, 'vkDestroyBuffer'));
  DeviceFunctions.vkCreateBufferView := PFN_vkCreateBufferView(_vkGetDeviceProcAddr(Device, 'vkCreateBufferView'));
  DeviceFunctions.vkDestroyBufferView := PFN_vkDestroyBufferView(_vkGetDeviceProcAddr(Device, 'vkDestroyBufferView'));
  DeviceFunctions.vkCreateImage := PFN_vkCreateImage(_vkGetDeviceProcAddr(Device, 'vkCreateImage'));
  DeviceFunctions.vkDestroyImage := PFN_vkDestroyImage(_vkGetDeviceProcAddr(Device, 'vkDestroyImage'));
  DeviceFunctions.vkGetImageSubresourceLayout := PFN_vkGetImageSubresourceLayout(_vkGetDeviceProcAddr(Device, 'vkGetImageSubresourceLayout'));
  DeviceFunctions.vkCreateImageView := PFN_vkCreateImageView(_vkGetDeviceProcAddr(Device, 'vkCreateImageView'));
  DeviceFunctions.vkDestroyImageView := PFN_vkDestroyImageView(_vkGetDeviceProcAddr(Device, 'vkDestroyImageView'));
  DeviceFunctions.vkCreateShaderModule := PFN_vkCreateShaderModule(_vkGetDeviceProcAddr(Device, 'vkCreateShaderModule'));
  DeviceFunctions.vkDestroyShaderModule := PFN_vkDestroyShaderModule(_vkGetDeviceProcAddr(Device, 'vkDestroyShaderModule'));
  DeviceFunctions.vkCreatePipelineCache := PFN_vkCreatePipelineCache(_vkGetDeviceProcAddr(Device, 'vkCreatePipelineCache'));
  DeviceFunctions.vkDestroyPipelineCache := PFN_vkDestroyPipelineCache(_vkGetDeviceProcAddr(Device, 'vkDestroyPipelineCache'));
  DeviceFunctions.vkGetPipelineCacheData := PFN_vkGetPipelineCacheData(_vkGetDeviceProcAddr(Device, 'vkGetPipelineCacheData'));
  DeviceFunctions.vkMergePipelineCaches := PFN_vkMergePipelineCaches(_vkGetDeviceProcAddr(Device, 'vkMergePipelineCaches'));
  DeviceFunctions.vkCreateGraphicsPipelines := PFN_vkCreateGraphicsPipelines(_vkGetDeviceProcAddr(Device, 'vkCreateGraphicsPipelines'));
  DeviceFunctions.vkCreateComputePipelines := PFN_vkCreateComputePipelines(_vkGetDeviceProcAddr(Device, 'vkCreateComputePipelines'));
  DeviceFunctions.vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI := PFN_vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI(_vkGetDeviceProcAddr(Device, 'vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI'));
  DeviceFunctions.vkDestroyPipeline := PFN_vkDestroyPipeline(_vkGetDeviceProcAddr(Device, 'vkDestroyPipeline'));
  DeviceFunctions.vkCreatePipelineLayout := PFN_vkCreatePipelineLayout(_vkGetDeviceProcAddr(Device, 'vkCreatePipelineLayout'));
  DeviceFunctions.vkDestroyPipelineLayout := PFN_vkDestroyPipelineLayout(_vkGetDeviceProcAddr(Device, 'vkDestroyPipelineLayout'));
  DeviceFunctions.vkCreateSampler := PFN_vkCreateSampler(_vkGetDeviceProcAddr(Device, 'vkCreateSampler'));
  DeviceFunctions.vkDestroySampler := PFN_vkDestroySampler(_vkGetDeviceProcAddr(Device, 'vkDestroySampler'));
  DeviceFunctions.vkCreateDescriptorSetLayout := PFN_vkCreateDescriptorSetLayout(_vkGetDeviceProcAddr(Device, 'vkCreateDescriptorSetLayout'));
  DeviceFunctions.vkDestroyDescriptorSetLayout := PFN_vkDestroyDescriptorSetLayout(_vkGetDeviceProcAddr(Device, 'vkDestroyDescriptorSetLayout'));
  DeviceFunctions.vkCreateDescriptorPool := PFN_vkCreateDescriptorPool(_vkGetDeviceProcAddr(Device, 'vkCreateDescriptorPool'));
  DeviceFunctions.vkDestroyDescriptorPool := PFN_vkDestroyDescriptorPool(_vkGetDeviceProcAddr(Device, 'vkDestroyDescriptorPool'));
  DeviceFunctions.vkResetDescriptorPool := PFN_vkResetDescriptorPool(_vkGetDeviceProcAddr(Device, 'vkResetDescriptorPool'));
  DeviceFunctions.vkAllocateDescriptorSets := PFN_vkAllocateDescriptorSets(_vkGetDeviceProcAddr(Device, 'vkAllocateDescriptorSets'));
  DeviceFunctions.vkFreeDescriptorSets := PFN_vkFreeDescriptorSets(_vkGetDeviceProcAddr(Device, 'vkFreeDescriptorSets'));
  DeviceFunctions.vkUpdateDescriptorSets := PFN_vkUpdateDescriptorSets(_vkGetDeviceProcAddr(Device, 'vkUpdateDescriptorSets'));
  DeviceFunctions.vkCreateFramebuffer := PFN_vkCreateFramebuffer(_vkGetDeviceProcAddr(Device, 'vkCreateFramebuffer'));
  DeviceFunctions.vkDestroyFramebuffer := PFN_vkDestroyFramebuffer(_vkGetDeviceProcAddr(Device, 'vkDestroyFramebuffer'));
  DeviceFunctions.vkCreateRenderPass := PFN_vkCreateRenderPass(_vkGetDeviceProcAddr(Device, 'vkCreateRenderPass'));
  DeviceFunctions.vkDestroyRenderPass := PFN_vkDestroyRenderPass(_vkGetDeviceProcAddr(Device, 'vkDestroyRenderPass'));
  DeviceFunctions.vkGetRenderAreaGranularity := PFN_vkGetRenderAreaGranularity(_vkGetDeviceProcAddr(Device, 'vkGetRenderAreaGranularity'));
  DeviceFunctions.vkCreateCommandPool := PFN_vkCreateCommandPool(_vkGetDeviceProcAddr(Device, 'vkCreateCommandPool'));
  DeviceFunctions.vkDestroyCommandPool := PFN_vkDestroyCommandPool(_vkGetDeviceProcAddr(Device, 'vkDestroyCommandPool'));
  DeviceFunctions.vkResetCommandPool := PFN_vkResetCommandPool(_vkGetDeviceProcAddr(Device, 'vkResetCommandPool'));
  DeviceFunctions.vkAllocateCommandBuffers := PFN_vkAllocateCommandBuffers(_vkGetDeviceProcAddr(Device, 'vkAllocateCommandBuffers'));
  DeviceFunctions.vkFreeCommandBuffers := PFN_vkFreeCommandBuffers(_vkGetDeviceProcAddr(Device, 'vkFreeCommandBuffers'));
  DeviceFunctions.vkBeginCommandBuffer := PFN_vkBeginCommandBuffer(_vkGetDeviceProcAddr(Device, 'vkBeginCommandBuffer'));
  DeviceFunctions.vkEndCommandBuffer := PFN_vkEndCommandBuffer(_vkGetDeviceProcAddr(Device, 'vkEndCommandBuffer'));
  DeviceFunctions.vkResetCommandBuffer := PFN_vkResetCommandBuffer(_vkGetDeviceProcAddr(Device, 'vkResetCommandBuffer'));
  DeviceFunctions.vkCmdBindPipeline := PFN_vkCmdBindPipeline(_vkGetDeviceProcAddr(Device, 'vkCmdBindPipeline'));
  DeviceFunctions.vkCmdSetViewport := PFN_vkCmdSetViewport(_vkGetDeviceProcAddr(Device, 'vkCmdSetViewport'));
  DeviceFunctions.vkCmdSetScissor := PFN_vkCmdSetScissor(_vkGetDeviceProcAddr(Device, 'vkCmdSetScissor'));
  DeviceFunctions.vkCmdSetLineWidth := PFN_vkCmdSetLineWidth(_vkGetDeviceProcAddr(Device, 'vkCmdSetLineWidth'));
  DeviceFunctions.vkCmdSetDepthBias := PFN_vkCmdSetDepthBias(_vkGetDeviceProcAddr(Device, 'vkCmdSetDepthBias'));
  DeviceFunctions.vkCmdSetBlendConstants := PFN_vkCmdSetBlendConstants(_vkGetDeviceProcAddr(Device, 'vkCmdSetBlendConstants'));
  DeviceFunctions.vkCmdSetDepthBounds := PFN_vkCmdSetDepthBounds(_vkGetDeviceProcAddr(Device, 'vkCmdSetDepthBounds'));
  DeviceFunctions.vkCmdSetStencilCompareMask := PFN_vkCmdSetStencilCompareMask(_vkGetDeviceProcAddr(Device, 'vkCmdSetStencilCompareMask'));
  DeviceFunctions.vkCmdSetStencilWriteMask := PFN_vkCmdSetStencilWriteMask(_vkGetDeviceProcAddr(Device, 'vkCmdSetStencilWriteMask'));
  DeviceFunctions.vkCmdSetStencilReference := PFN_vkCmdSetStencilReference(_vkGetDeviceProcAddr(Device, 'vkCmdSetStencilReference'));
  DeviceFunctions.vkCmdBindDescriptorSets := PFN_vkCmdBindDescriptorSets(_vkGetDeviceProcAddr(Device, 'vkCmdBindDescriptorSets'));
  DeviceFunctions.vkCmdBindIndexBuffer := PFN_vkCmdBindIndexBuffer(_vkGetDeviceProcAddr(Device, 'vkCmdBindIndexBuffer'));
  DeviceFunctions.vkCmdBindVertexBuffers := PFN_vkCmdBindVertexBuffers(_vkGetDeviceProcAddr(Device, 'vkCmdBindVertexBuffers'));
  DeviceFunctions.vkCmdDraw := PFN_vkCmdDraw(_vkGetDeviceProcAddr(Device, 'vkCmdDraw'));
  DeviceFunctions.vkCmdDrawIndexed := PFN_vkCmdDrawIndexed(_vkGetDeviceProcAddr(Device, 'vkCmdDrawIndexed'));
  DeviceFunctions.vkCmdDrawMultiEXT := PFN_vkCmdDrawMultiEXT(_vkGetDeviceProcAddr(Device, 'vkCmdDrawMultiEXT'));
  DeviceFunctions.vkCmdDrawMultiIndexedEXT := PFN_vkCmdDrawMultiIndexedEXT(_vkGetDeviceProcAddr(Device, 'vkCmdDrawMultiIndexedEXT'));
  DeviceFunctions.vkCmdDrawIndirect := PFN_vkCmdDrawIndirect(_vkGetDeviceProcAddr(Device, 'vkCmdDrawIndirect'));
  DeviceFunctions.vkCmdDrawIndexedIndirect := PFN_vkCmdDrawIndexedIndirect(_vkGetDeviceProcAddr(Device, 'vkCmdDrawIndexedIndirect'));
  DeviceFunctions.vkCmdDispatch := PFN_vkCmdDispatch(_vkGetDeviceProcAddr(Device, 'vkCmdDispatch'));
  DeviceFunctions.vkCmdDispatchIndirect := PFN_vkCmdDispatchIndirect(_vkGetDeviceProcAddr(Device, 'vkCmdDispatchIndirect'));
  DeviceFunctions.vkCmdSubpassShadingHUAWEI := PFN_vkCmdSubpassShadingHUAWEI(_vkGetDeviceProcAddr(Device, 'vkCmdSubpassShadingHUAWEI'));
  DeviceFunctions.vkCmdCopyBuffer := PFN_vkCmdCopyBuffer(_vkGetDeviceProcAddr(Device, 'vkCmdCopyBuffer'));
  DeviceFunctions.vkCmdCopyImage := PFN_vkCmdCopyImage(_vkGetDeviceProcAddr(Device, 'vkCmdCopyImage'));
  DeviceFunctions.vkCmdBlitImage := PFN_vkCmdBlitImage(_vkGetDeviceProcAddr(Device, 'vkCmdBlitImage'));
  DeviceFunctions.vkCmdCopyBufferToImage := PFN_vkCmdCopyBufferToImage(_vkGetDeviceProcAddr(Device, 'vkCmdCopyBufferToImage'));
  DeviceFunctions.vkCmdCopyImageToBuffer := PFN_vkCmdCopyImageToBuffer(_vkGetDeviceProcAddr(Device, 'vkCmdCopyImageToBuffer'));
  DeviceFunctions.vkCmdUpdateBuffer := PFN_vkCmdUpdateBuffer(_vkGetDeviceProcAddr(Device, 'vkCmdUpdateBuffer'));
  DeviceFunctions.vkCmdFillBuffer := PFN_vkCmdFillBuffer(_vkGetDeviceProcAddr(Device, 'vkCmdFillBuffer'));
  DeviceFunctions.vkCmdClearColorImage := PFN_vkCmdClearColorImage(_vkGetDeviceProcAddr(Device, 'vkCmdClearColorImage'));
  DeviceFunctions.vkCmdClearDepthStencilImage := PFN_vkCmdClearDepthStencilImage(_vkGetDeviceProcAddr(Device, 'vkCmdClearDepthStencilImage'));
  DeviceFunctions.vkCmdClearAttachments := PFN_vkCmdClearAttachments(_vkGetDeviceProcAddr(Device, 'vkCmdClearAttachments'));
  DeviceFunctions.vkCmdResolveImage := PFN_vkCmdResolveImage(_vkGetDeviceProcAddr(Device, 'vkCmdResolveImage'));
  DeviceFunctions.vkCmdSetEvent := PFN_vkCmdSetEvent(_vkGetDeviceProcAddr(Device, 'vkCmdSetEvent'));
  DeviceFunctions.vkCmdResetEvent := PFN_vkCmdResetEvent(_vkGetDeviceProcAddr(Device, 'vkCmdResetEvent'));
  DeviceFunctions.vkCmdWaitEvents := PFN_vkCmdWaitEvents(_vkGetDeviceProcAddr(Device, 'vkCmdWaitEvents'));
  DeviceFunctions.vkCmdPipelineBarrier := PFN_vkCmdPipelineBarrier(_vkGetDeviceProcAddr(Device, 'vkCmdPipelineBarrier'));
  DeviceFunctions.vkCmdBeginQuery := PFN_vkCmdBeginQuery(_vkGetDeviceProcAddr(Device, 'vkCmdBeginQuery'));
  DeviceFunctions.vkCmdEndQuery := PFN_vkCmdEndQuery(_vkGetDeviceProcAddr(Device, 'vkCmdEndQuery'));
  DeviceFunctions.vkCmdBeginConditionalRenderingEXT := PFN_vkCmdBeginConditionalRenderingEXT(_vkGetDeviceProcAddr(Device, 'vkCmdBeginConditionalRenderingEXT'));
  DeviceFunctions.vkCmdEndConditionalRenderingEXT := PFN_vkCmdEndConditionalRenderingEXT(_vkGetDeviceProcAddr(Device, 'vkCmdEndConditionalRenderingEXT'));
  DeviceFunctions.vkCmdResetQueryPool := PFN_vkCmdResetQueryPool(_vkGetDeviceProcAddr(Device, 'vkCmdResetQueryPool'));
  DeviceFunctions.vkCmdWriteTimestamp := PFN_vkCmdWriteTimestamp(_vkGetDeviceProcAddr(Device, 'vkCmdWriteTimestamp'));
  DeviceFunctions.vkCmdCopyQueryPoolResults := PFN_vkCmdCopyQueryPoolResults(_vkGetDeviceProcAddr(Device, 'vkCmdCopyQueryPoolResults'));
  DeviceFunctions.vkCmdPushConstants := PFN_vkCmdPushConstants(_vkGetDeviceProcAddr(Device, 'vkCmdPushConstants'));
  DeviceFunctions.vkCmdBeginRenderPass := PFN_vkCmdBeginRenderPass(_vkGetDeviceProcAddr(Device, 'vkCmdBeginRenderPass'));
  DeviceFunctions.vkCmdNextSubpass := PFN_vkCmdNextSubpass(_vkGetDeviceProcAddr(Device, 'vkCmdNextSubpass'));
  DeviceFunctions.vkCmdEndRenderPass := PFN_vkCmdEndRenderPass(_vkGetDeviceProcAddr(Device, 'vkCmdEndRenderPass'));
  DeviceFunctions.vkCmdExecuteCommands := PFN_vkCmdExecuteCommands(_vkGetDeviceProcAddr(Device, 'vkCmdExecuteCommands'));
  DeviceFunctions.vkCreateSharedSwapchainsKHR := PFN_vkCreateSharedSwapchainsKHR(_vkGetDeviceProcAddr(Device, 'vkCreateSharedSwapchainsKHR'));
  DeviceFunctions.vkCreateSwapchainKHR := PFN_vkCreateSwapchainKHR(_vkGetDeviceProcAddr(Device, 'vkCreateSwapchainKHR'));
  DeviceFunctions.vkDestroySwapchainKHR := PFN_vkDestroySwapchainKHR(_vkGetDeviceProcAddr(Device, 'vkDestroySwapchainKHR'));
  DeviceFunctions.vkGetSwapchainImagesKHR := PFN_vkGetSwapchainImagesKHR(_vkGetDeviceProcAddr(Device, 'vkGetSwapchainImagesKHR'));
  DeviceFunctions.vkAcquireNextImageKHR := PFN_vkAcquireNextImageKHR(_vkGetDeviceProcAddr(Device, 'vkAcquireNextImageKHR'));
  DeviceFunctions.vkQueuePresentKHR := PFN_vkQueuePresentKHR(_vkGetDeviceProcAddr(Device, 'vkQueuePresentKHR'));
  DeviceFunctions.vkDebugMarkerSetObjectNameEXT := PFN_vkDebugMarkerSetObjectNameEXT(_vkGetDeviceProcAddr(Device, 'vkDebugMarkerSetObjectNameEXT'));
  DeviceFunctions.vkDebugMarkerSetObjectTagEXT := PFN_vkDebugMarkerSetObjectTagEXT(_vkGetDeviceProcAddr(Device, 'vkDebugMarkerSetObjectTagEXT'));
  DeviceFunctions.vkCmdDebugMarkerBeginEXT := PFN_vkCmdDebugMarkerBeginEXT(_vkGetDeviceProcAddr(Device, 'vkCmdDebugMarkerBeginEXT'));
  DeviceFunctions.vkCmdDebugMarkerEndEXT := PFN_vkCmdDebugMarkerEndEXT(_vkGetDeviceProcAddr(Device, 'vkCmdDebugMarkerEndEXT'));
  DeviceFunctions.vkCmdDebugMarkerInsertEXT := PFN_vkCmdDebugMarkerInsertEXT(_vkGetDeviceProcAddr(Device, 'vkCmdDebugMarkerInsertEXT'));
  DeviceFunctions.vkGetMemoryWin32HandleNV := PFN_vkGetMemoryWin32HandleNV(_vkGetDeviceProcAddr(Device, 'vkGetMemoryWin32HandleNV'));
  DeviceFunctions.vkCmdExecuteGeneratedCommandsNV := PFN_vkCmdExecuteGeneratedCommandsNV(_vkGetDeviceProcAddr(Device, 'vkCmdExecuteGeneratedCommandsNV'));
  DeviceFunctions.vkCmdPreprocessGeneratedCommandsNV := PFN_vkCmdPreprocessGeneratedCommandsNV(_vkGetDeviceProcAddr(Device, 'vkCmdPreprocessGeneratedCommandsNV'));
  DeviceFunctions.vkCmdBindPipelineShaderGroupNV := PFN_vkCmdBindPipelineShaderGroupNV(_vkGetDeviceProcAddr(Device, 'vkCmdBindPipelineShaderGroupNV'));
  DeviceFunctions.vkGetGeneratedCommandsMemoryRequirementsNV := PFN_vkGetGeneratedCommandsMemoryRequirementsNV(_vkGetDeviceProcAddr(Device, 'vkGetGeneratedCommandsMemoryRequirementsNV'));
  DeviceFunctions.vkCreateIndirectCommandsLayoutNV := PFN_vkCreateIndirectCommandsLayoutNV(_vkGetDeviceProcAddr(Device, 'vkCreateIndirectCommandsLayoutNV'));
  DeviceFunctions.vkDestroyIndirectCommandsLayoutNV := PFN_vkDestroyIndirectCommandsLayoutNV(_vkGetDeviceProcAddr(Device, 'vkDestroyIndirectCommandsLayoutNV'));
  DeviceFunctions.vkCmdPushDescriptorSetKHR := PFN_vkCmdPushDescriptorSetKHR(_vkGetDeviceProcAddr(Device, 'vkCmdPushDescriptorSetKHR'));
  DeviceFunctions.vkTrimCommandPool := PFN_vkTrimCommandPool(_vkGetDeviceProcAddr(Device, 'vkTrimCommandPool'));
  DeviceFunctions.vkGetMemoryWin32HandleKHR := PFN_vkGetMemoryWin32HandleKHR(_vkGetDeviceProcAddr(Device, 'vkGetMemoryWin32HandleKHR'));
  DeviceFunctions.vkGetMemoryWin32HandlePropertiesKHR := PFN_vkGetMemoryWin32HandlePropertiesKHR(_vkGetDeviceProcAddr(Device, 'vkGetMemoryWin32HandlePropertiesKHR'));
  DeviceFunctions.vkGetMemoryFdKHR := PFN_vkGetMemoryFdKHR(_vkGetDeviceProcAddr(Device, 'vkGetMemoryFdKHR'));
  DeviceFunctions.vkGetMemoryFdPropertiesKHR := PFN_vkGetMemoryFdPropertiesKHR(_vkGetDeviceProcAddr(Device, 'vkGetMemoryFdPropertiesKHR'));
  DeviceFunctions.vkGetMemoryRemoteAddressNV := PFN_vkGetMemoryRemoteAddressNV(_vkGetDeviceProcAddr(Device, 'vkGetMemoryRemoteAddressNV'));
  DeviceFunctions.vkGetSemaphoreWin32HandleKHR := PFN_vkGetSemaphoreWin32HandleKHR(_vkGetDeviceProcAddr(Device, 'vkGetSemaphoreWin32HandleKHR'));
  DeviceFunctions.vkImportSemaphoreWin32HandleKHR := PFN_vkImportSemaphoreWin32HandleKHR(_vkGetDeviceProcAddr(Device, 'vkImportSemaphoreWin32HandleKHR'));
  DeviceFunctions.vkGetSemaphoreFdKHR := PFN_vkGetSemaphoreFdKHR(_vkGetDeviceProcAddr(Device, 'vkGetSemaphoreFdKHR'));
  DeviceFunctions.vkImportSemaphoreFdKHR := PFN_vkImportSemaphoreFdKHR(_vkGetDeviceProcAddr(Device, 'vkImportSemaphoreFdKHR'));
  DeviceFunctions.vkGetFenceWin32HandleKHR := PFN_vkGetFenceWin32HandleKHR(_vkGetDeviceProcAddr(Device, 'vkGetFenceWin32HandleKHR'));
  DeviceFunctions.vkImportFenceWin32HandleKHR := PFN_vkImportFenceWin32HandleKHR(_vkGetDeviceProcAddr(Device, 'vkImportFenceWin32HandleKHR'));
  DeviceFunctions.vkGetFenceFdKHR := PFN_vkGetFenceFdKHR(_vkGetDeviceProcAddr(Device, 'vkGetFenceFdKHR'));
  DeviceFunctions.vkImportFenceFdKHR := PFN_vkImportFenceFdKHR(_vkGetDeviceProcAddr(Device, 'vkImportFenceFdKHR'));
  DeviceFunctions.vkDisplayPowerControlEXT := PFN_vkDisplayPowerControlEXT(_vkGetDeviceProcAddr(Device, 'vkDisplayPowerControlEXT'));
  DeviceFunctions.vkRegisterDeviceEventEXT := PFN_vkRegisterDeviceEventEXT(_vkGetDeviceProcAddr(Device, 'vkRegisterDeviceEventEXT'));
  DeviceFunctions.vkRegisterDisplayEventEXT := PFN_vkRegisterDisplayEventEXT(_vkGetDeviceProcAddr(Device, 'vkRegisterDisplayEventEXT'));
  DeviceFunctions.vkGetSwapchainCounterEXT := PFN_vkGetSwapchainCounterEXT(_vkGetDeviceProcAddr(Device, 'vkGetSwapchainCounterEXT'));
  DeviceFunctions.vkGetDeviceGroupPeerMemoryFeatures := PFN_vkGetDeviceGroupPeerMemoryFeatures(_vkGetDeviceProcAddr(Device, 'vkGetDeviceGroupPeerMemoryFeatures'));
  DeviceFunctions.vkBindBufferMemory2 := PFN_vkBindBufferMemory2(_vkGetDeviceProcAddr(Device, 'vkBindBufferMemory2'));
  DeviceFunctions.vkBindImageMemory2 := PFN_vkBindImageMemory2(_vkGetDeviceProcAddr(Device, 'vkBindImageMemory2'));
  DeviceFunctions.vkCmdSetDeviceMask := PFN_vkCmdSetDeviceMask(_vkGetDeviceProcAddr(Device, 'vkCmdSetDeviceMask'));
  DeviceFunctions.vkGetDeviceGroupPresentCapabilitiesKHR := PFN_vkGetDeviceGroupPresentCapabilitiesKHR(_vkGetDeviceProcAddr(Device, 'vkGetDeviceGroupPresentCapabilitiesKHR'));
  DeviceFunctions.vkGetDeviceGroupSurfacePresentModesKHR := PFN_vkGetDeviceGroupSurfacePresentModesKHR(_vkGetDeviceProcAddr(Device, 'vkGetDeviceGroupSurfacePresentModesKHR'));
  DeviceFunctions.vkAcquireNextImage2KHR := PFN_vkAcquireNextImage2KHR(_vkGetDeviceProcAddr(Device, 'vkAcquireNextImage2KHR'));
  DeviceFunctions.vkCmdDispatchBase := PFN_vkCmdDispatchBase(_vkGetDeviceProcAddr(Device, 'vkCmdDispatchBase'));
  DeviceFunctions.vkCreateDescriptorUpdateTemplate := PFN_vkCreateDescriptorUpdateTemplate(_vkGetDeviceProcAddr(Device, 'vkCreateDescriptorUpdateTemplate'));
  DeviceFunctions.vkDestroyDescriptorUpdateTemplate := PFN_vkDestroyDescriptorUpdateTemplate(_vkGetDeviceProcAddr(Device, 'vkDestroyDescriptorUpdateTemplate'));
  DeviceFunctions.vkUpdateDescriptorSetWithTemplate := PFN_vkUpdateDescriptorSetWithTemplate(_vkGetDeviceProcAddr(Device, 'vkUpdateDescriptorSetWithTemplate'));
  DeviceFunctions.vkCmdPushDescriptorSetWithTemplateKHR := PFN_vkCmdPushDescriptorSetWithTemplateKHR(_vkGetDeviceProcAddr(Device, 'vkCmdPushDescriptorSetWithTemplateKHR'));
  DeviceFunctions.vkSetHdrMetadataEXT := PFN_vkSetHdrMetadataEXT(_vkGetDeviceProcAddr(Device, 'vkSetHdrMetadataEXT'));
  DeviceFunctions.vkGetSwapchainStatusKHR := PFN_vkGetSwapchainStatusKHR(_vkGetDeviceProcAddr(Device, 'vkGetSwapchainStatusKHR'));
  DeviceFunctions.vkGetRefreshCycleDurationGOOGLE := PFN_vkGetRefreshCycleDurationGOOGLE(_vkGetDeviceProcAddr(Device, 'vkGetRefreshCycleDurationGOOGLE'));
  DeviceFunctions.vkGetPastPresentationTimingGOOGLE := PFN_vkGetPastPresentationTimingGOOGLE(_vkGetDeviceProcAddr(Device, 'vkGetPastPresentationTimingGOOGLE'));
  DeviceFunctions.vkCmdSetViewportWScalingNV := PFN_vkCmdSetViewportWScalingNV(_vkGetDeviceProcAddr(Device, 'vkCmdSetViewportWScalingNV'));
  DeviceFunctions.vkCmdSetDiscardRectangleEXT := PFN_vkCmdSetDiscardRectangleEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetDiscardRectangleEXT'));
  DeviceFunctions.vkCmdSetSampleLocationsEXT := PFN_vkCmdSetSampleLocationsEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetSampleLocationsEXT'));
  DeviceFunctions.vkGetBufferMemoryRequirements2 := PFN_vkGetBufferMemoryRequirements2(_vkGetDeviceProcAddr(Device, 'vkGetBufferMemoryRequirements2'));
  DeviceFunctions.vkGetImageMemoryRequirements2 := PFN_vkGetImageMemoryRequirements2(_vkGetDeviceProcAddr(Device, 'vkGetImageMemoryRequirements2'));
  DeviceFunctions.vkGetImageSparseMemoryRequirements2 := PFN_vkGetImageSparseMemoryRequirements2(_vkGetDeviceProcAddr(Device, 'vkGetImageSparseMemoryRequirements2'));
  DeviceFunctions.vkCreateSamplerYcbcrConversion := PFN_vkCreateSamplerYcbcrConversion(_vkGetDeviceProcAddr(Device, 'vkCreateSamplerYcbcrConversion'));
  DeviceFunctions.vkDestroySamplerYcbcrConversion := PFN_vkDestroySamplerYcbcrConversion(_vkGetDeviceProcAddr(Device, 'vkDestroySamplerYcbcrConversion'));
  DeviceFunctions.vkGetDeviceQueue2 := PFN_vkGetDeviceQueue2(_vkGetDeviceProcAddr(Device, 'vkGetDeviceQueue2'));
  DeviceFunctions.vkCreateValidationCacheEXT := PFN_vkCreateValidationCacheEXT(_vkGetDeviceProcAddr(Device, 'vkCreateValidationCacheEXT'));
  DeviceFunctions.vkDestroyValidationCacheEXT := PFN_vkDestroyValidationCacheEXT(_vkGetDeviceProcAddr(Device, 'vkDestroyValidationCacheEXT'));
  DeviceFunctions.vkGetValidationCacheDataEXT := PFN_vkGetValidationCacheDataEXT(_vkGetDeviceProcAddr(Device, 'vkGetValidationCacheDataEXT'));
  DeviceFunctions.vkMergeValidationCachesEXT := PFN_vkMergeValidationCachesEXT(_vkGetDeviceProcAddr(Device, 'vkMergeValidationCachesEXT'));
  DeviceFunctions.vkGetDescriptorSetLayoutSupport := PFN_vkGetDescriptorSetLayoutSupport(_vkGetDeviceProcAddr(Device, 'vkGetDescriptorSetLayoutSupport'));
  DeviceFunctions.vkGetSwapchainGrallocUsageANDROID := PFN_vkGetSwapchainGrallocUsageANDROID(_vkGetDeviceProcAddr(Device, 'vkGetSwapchainGrallocUsageANDROID'));
  DeviceFunctions.vkGetSwapchainGrallocUsage2ANDROID := PFN_vkGetSwapchainGrallocUsage2ANDROID(_vkGetDeviceProcAddr(Device, 'vkGetSwapchainGrallocUsage2ANDROID'));
  DeviceFunctions.vkAcquireImageANDROID := PFN_vkAcquireImageANDROID(_vkGetDeviceProcAddr(Device, 'vkAcquireImageANDROID'));
  DeviceFunctions.vkQueueSignalReleaseImageANDROID := PFN_vkQueueSignalReleaseImageANDROID(_vkGetDeviceProcAddr(Device, 'vkQueueSignalReleaseImageANDROID'));
  DeviceFunctions.vkGetShaderInfoAMD := PFN_vkGetShaderInfoAMD(_vkGetDeviceProcAddr(Device, 'vkGetShaderInfoAMD'));
  DeviceFunctions.vkSetLocalDimmingAMD := PFN_vkSetLocalDimmingAMD(_vkGetDeviceProcAddr(Device, 'vkSetLocalDimmingAMD'));
  DeviceFunctions.vkGetCalibratedTimestampsEXT := PFN_vkGetCalibratedTimestampsEXT(_vkGetDeviceProcAddr(Device, 'vkGetCalibratedTimestampsEXT'));
  DeviceFunctions.vkSetDebugUtilsObjectNameEXT := PFN_vkSetDebugUtilsObjectNameEXT(_vkGetDeviceProcAddr(Device, 'vkSetDebugUtilsObjectNameEXT'));
  DeviceFunctions.vkSetDebugUtilsObjectTagEXT := PFN_vkSetDebugUtilsObjectTagEXT(_vkGetDeviceProcAddr(Device, 'vkSetDebugUtilsObjectTagEXT'));
  DeviceFunctions.vkQueueBeginDebugUtilsLabelEXT := PFN_vkQueueBeginDebugUtilsLabelEXT(_vkGetDeviceProcAddr(Device, 'vkQueueBeginDebugUtilsLabelEXT'));
  DeviceFunctions.vkQueueEndDebugUtilsLabelEXT := PFN_vkQueueEndDebugUtilsLabelEXT(_vkGetDeviceProcAddr(Device, 'vkQueueEndDebugUtilsLabelEXT'));
  DeviceFunctions.vkQueueInsertDebugUtilsLabelEXT := PFN_vkQueueInsertDebugUtilsLabelEXT(_vkGetDeviceProcAddr(Device, 'vkQueueInsertDebugUtilsLabelEXT'));
  DeviceFunctions.vkCmdBeginDebugUtilsLabelEXT := PFN_vkCmdBeginDebugUtilsLabelEXT(_vkGetDeviceProcAddr(Device, 'vkCmdBeginDebugUtilsLabelEXT'));
  DeviceFunctions.vkCmdEndDebugUtilsLabelEXT := PFN_vkCmdEndDebugUtilsLabelEXT(_vkGetDeviceProcAddr(Device, 'vkCmdEndDebugUtilsLabelEXT'));
  DeviceFunctions.vkCmdInsertDebugUtilsLabelEXT := PFN_vkCmdInsertDebugUtilsLabelEXT(_vkGetDeviceProcAddr(Device, 'vkCmdInsertDebugUtilsLabelEXT'));
  DeviceFunctions.vkGetMemoryHostPointerPropertiesEXT := PFN_vkGetMemoryHostPointerPropertiesEXT(_vkGetDeviceProcAddr(Device, 'vkGetMemoryHostPointerPropertiesEXT'));
  DeviceFunctions.vkCmdWriteBufferMarkerAMD := PFN_vkCmdWriteBufferMarkerAMD(_vkGetDeviceProcAddr(Device, 'vkCmdWriteBufferMarkerAMD'));
  DeviceFunctions.vkCreateRenderPass2 := PFN_vkCreateRenderPass2(_vkGetDeviceProcAddr(Device, 'vkCreateRenderPass2'));
  DeviceFunctions.vkCmdBeginRenderPass2 := PFN_vkCmdBeginRenderPass2(_vkGetDeviceProcAddr(Device, 'vkCmdBeginRenderPass2'));
  DeviceFunctions.vkCmdNextSubpass2 := PFN_vkCmdNextSubpass2(_vkGetDeviceProcAddr(Device, 'vkCmdNextSubpass2'));
  DeviceFunctions.vkCmdEndRenderPass2 := PFN_vkCmdEndRenderPass2(_vkGetDeviceProcAddr(Device, 'vkCmdEndRenderPass2'));
  DeviceFunctions.vkGetSemaphoreCounterValue := PFN_vkGetSemaphoreCounterValue(_vkGetDeviceProcAddr(Device, 'vkGetSemaphoreCounterValue'));
  DeviceFunctions.vkWaitSemaphores := PFN_vkWaitSemaphores(_vkGetDeviceProcAddr(Device, 'vkWaitSemaphores'));
  DeviceFunctions.vkSignalSemaphore := PFN_vkSignalSemaphore(_vkGetDeviceProcAddr(Device, 'vkSignalSemaphore'));
  DeviceFunctions.vkGetAndroidHardwareBufferPropertiesANDROID := PFN_vkGetAndroidHardwareBufferPropertiesANDROID(_vkGetDeviceProcAddr(Device, 'vkGetAndroidHardwareBufferPropertiesANDROID'));
  DeviceFunctions.vkGetMemoryAndroidHardwareBufferANDROID := PFN_vkGetMemoryAndroidHardwareBufferANDROID(_vkGetDeviceProcAddr(Device, 'vkGetMemoryAndroidHardwareBufferANDROID'));
  DeviceFunctions.vkCmdDrawIndirectCount := PFN_vkCmdDrawIndirectCount(_vkGetDeviceProcAddr(Device, 'vkCmdDrawIndirectCount'));
  DeviceFunctions.vkCmdDrawIndexedIndirectCount := PFN_vkCmdDrawIndexedIndirectCount(_vkGetDeviceProcAddr(Device, 'vkCmdDrawIndexedIndirectCount'));
  DeviceFunctions.vkCmdSetCheckpointNV := PFN_vkCmdSetCheckpointNV(_vkGetDeviceProcAddr(Device, 'vkCmdSetCheckpointNV'));
  DeviceFunctions.vkGetQueueCheckpointDataNV := PFN_vkGetQueueCheckpointDataNV(_vkGetDeviceProcAddr(Device, 'vkGetQueueCheckpointDataNV'));
  DeviceFunctions.vkCmdBindTransformFeedbackBuffersEXT := PFN_vkCmdBindTransformFeedbackBuffersEXT(_vkGetDeviceProcAddr(Device, 'vkCmdBindTransformFeedbackBuffersEXT'));
  DeviceFunctions.vkCmdBeginTransformFeedbackEXT := PFN_vkCmdBeginTransformFeedbackEXT(_vkGetDeviceProcAddr(Device, 'vkCmdBeginTransformFeedbackEXT'));
  DeviceFunctions.vkCmdEndTransformFeedbackEXT := PFN_vkCmdEndTransformFeedbackEXT(_vkGetDeviceProcAddr(Device, 'vkCmdEndTransformFeedbackEXT'));
  DeviceFunctions.vkCmdBeginQueryIndexedEXT := PFN_vkCmdBeginQueryIndexedEXT(_vkGetDeviceProcAddr(Device, 'vkCmdBeginQueryIndexedEXT'));
  DeviceFunctions.vkCmdEndQueryIndexedEXT := PFN_vkCmdEndQueryIndexedEXT(_vkGetDeviceProcAddr(Device, 'vkCmdEndQueryIndexedEXT'));
  DeviceFunctions.vkCmdDrawIndirectByteCountEXT := PFN_vkCmdDrawIndirectByteCountEXT(_vkGetDeviceProcAddr(Device, 'vkCmdDrawIndirectByteCountEXT'));
  DeviceFunctions.vkCmdSetExclusiveScissorNV := PFN_vkCmdSetExclusiveScissorNV(_vkGetDeviceProcAddr(Device, 'vkCmdSetExclusiveScissorNV'));
  DeviceFunctions.vkCmdBindShadingRateImageNV := PFN_vkCmdBindShadingRateImageNV(_vkGetDeviceProcAddr(Device, 'vkCmdBindShadingRateImageNV'));
  DeviceFunctions.vkCmdSetViewportShadingRatePaletteNV := PFN_vkCmdSetViewportShadingRatePaletteNV(_vkGetDeviceProcAddr(Device, 'vkCmdSetViewportShadingRatePaletteNV'));
  DeviceFunctions.vkCmdSetCoarseSampleOrderNV := PFN_vkCmdSetCoarseSampleOrderNV(_vkGetDeviceProcAddr(Device, 'vkCmdSetCoarseSampleOrderNV'));
  DeviceFunctions.vkCmdDrawMeshTasksNV := PFN_vkCmdDrawMeshTasksNV(_vkGetDeviceProcAddr(Device, 'vkCmdDrawMeshTasksNV'));
  DeviceFunctions.vkCmdDrawMeshTasksIndirectNV := PFN_vkCmdDrawMeshTasksIndirectNV(_vkGetDeviceProcAddr(Device, 'vkCmdDrawMeshTasksIndirectNV'));
  DeviceFunctions.vkCmdDrawMeshTasksIndirectCountNV := PFN_vkCmdDrawMeshTasksIndirectCountNV(_vkGetDeviceProcAddr(Device, 'vkCmdDrawMeshTasksIndirectCountNV'));
  DeviceFunctions.vkCompileDeferredNV := PFN_vkCompileDeferredNV(_vkGetDeviceProcAddr(Device, 'vkCompileDeferredNV'));
  DeviceFunctions.vkCreateAccelerationStructureNV := PFN_vkCreateAccelerationStructureNV(_vkGetDeviceProcAddr(Device, 'vkCreateAccelerationStructureNV'));
  DeviceFunctions.vkCmdBindInvocationMaskHUAWEI := PFN_vkCmdBindInvocationMaskHUAWEI(_vkGetDeviceProcAddr(Device, 'vkCmdBindInvocationMaskHUAWEI'));
  DeviceFunctions.vkDestroyAccelerationStructureKHR := PFN_vkDestroyAccelerationStructureKHR(_vkGetDeviceProcAddr(Device, 'vkDestroyAccelerationStructureKHR'));
  DeviceFunctions.vkDestroyAccelerationStructureNV := PFN_vkDestroyAccelerationStructureNV(_vkGetDeviceProcAddr(Device, 'vkDestroyAccelerationStructureNV'));
  DeviceFunctions.vkGetAccelerationStructureMemoryRequirementsNV := PFN_vkGetAccelerationStructureMemoryRequirementsNV(_vkGetDeviceProcAddr(Device, 'vkGetAccelerationStructureMemoryRequirementsNV'));
  DeviceFunctions.vkBindAccelerationStructureMemoryNV := PFN_vkBindAccelerationStructureMemoryNV(_vkGetDeviceProcAddr(Device, 'vkBindAccelerationStructureMemoryNV'));
  DeviceFunctions.vkCmdCopyAccelerationStructureNV := PFN_vkCmdCopyAccelerationStructureNV(_vkGetDeviceProcAddr(Device, 'vkCmdCopyAccelerationStructureNV'));
  DeviceFunctions.vkCmdCopyAccelerationStructureKHR := PFN_vkCmdCopyAccelerationStructureKHR(_vkGetDeviceProcAddr(Device, 'vkCmdCopyAccelerationStructureKHR'));
  DeviceFunctions.vkCopyAccelerationStructureKHR := PFN_vkCopyAccelerationStructureKHR(_vkGetDeviceProcAddr(Device, 'vkCopyAccelerationStructureKHR'));
  DeviceFunctions.vkCmdCopyAccelerationStructureToMemoryKHR := PFN_vkCmdCopyAccelerationStructureToMemoryKHR(_vkGetDeviceProcAddr(Device, 'vkCmdCopyAccelerationStructureToMemoryKHR'));
  DeviceFunctions.vkCopyAccelerationStructureToMemoryKHR := PFN_vkCopyAccelerationStructureToMemoryKHR(_vkGetDeviceProcAddr(Device, 'vkCopyAccelerationStructureToMemoryKHR'));
  DeviceFunctions.vkCmdCopyMemoryToAccelerationStructureKHR := PFN_vkCmdCopyMemoryToAccelerationStructureKHR(_vkGetDeviceProcAddr(Device, 'vkCmdCopyMemoryToAccelerationStructureKHR'));
  DeviceFunctions.vkCopyMemoryToAccelerationStructureKHR := PFN_vkCopyMemoryToAccelerationStructureKHR(_vkGetDeviceProcAddr(Device, 'vkCopyMemoryToAccelerationStructureKHR'));
  DeviceFunctions.vkCmdWriteAccelerationStructuresPropertiesKHR := PFN_vkCmdWriteAccelerationStructuresPropertiesKHR(_vkGetDeviceProcAddr(Device, 'vkCmdWriteAccelerationStructuresPropertiesKHR'));
  DeviceFunctions.vkCmdWriteAccelerationStructuresPropertiesNV := PFN_vkCmdWriteAccelerationStructuresPropertiesNV(_vkGetDeviceProcAddr(Device, 'vkCmdWriteAccelerationStructuresPropertiesNV'));
  DeviceFunctions.vkCmdBuildAccelerationStructureNV := PFN_vkCmdBuildAccelerationStructureNV(_vkGetDeviceProcAddr(Device, 'vkCmdBuildAccelerationStructureNV'));
  DeviceFunctions.vkWriteAccelerationStructuresPropertiesKHR := PFN_vkWriteAccelerationStructuresPropertiesKHR(_vkGetDeviceProcAddr(Device, 'vkWriteAccelerationStructuresPropertiesKHR'));
  DeviceFunctions.vkCmdTraceRaysKHR := PFN_vkCmdTraceRaysKHR(_vkGetDeviceProcAddr(Device, 'vkCmdTraceRaysKHR'));
  DeviceFunctions.vkCmdTraceRaysNV := PFN_vkCmdTraceRaysNV(_vkGetDeviceProcAddr(Device, 'vkCmdTraceRaysNV'));
  DeviceFunctions.vkGetRayTracingShaderGroupHandlesKHR := PFN_vkGetRayTracingShaderGroupHandlesKHR(_vkGetDeviceProcAddr(Device, 'vkGetRayTracingShaderGroupHandlesKHR'));
  DeviceFunctions.vkGetRayTracingCaptureReplayShaderGroupHandlesKHR := PFN_vkGetRayTracingCaptureReplayShaderGroupHandlesKHR(_vkGetDeviceProcAddr(Device, 'vkGetRayTracingCaptureReplayShaderGroupHandlesKHR'));
  DeviceFunctions.vkGetAccelerationStructureHandleNV := PFN_vkGetAccelerationStructureHandleNV(_vkGetDeviceProcAddr(Device, 'vkGetAccelerationStructureHandleNV'));
  DeviceFunctions.vkCreateRayTracingPipelinesNV := PFN_vkCreateRayTracingPipelinesNV(_vkGetDeviceProcAddr(Device, 'vkCreateRayTracingPipelinesNV'));
  DeviceFunctions.vkCreateRayTracingPipelinesKHR := PFN_vkCreateRayTracingPipelinesKHR(_vkGetDeviceProcAddr(Device, 'vkCreateRayTracingPipelinesKHR'));
  DeviceFunctions.vkCmdTraceRaysIndirectKHR := PFN_vkCmdTraceRaysIndirectKHR(_vkGetDeviceProcAddr(Device, 'vkCmdTraceRaysIndirectKHR'));
  DeviceFunctions.vkGetDeviceAccelerationStructureCompatibilityKHR := PFN_vkGetDeviceAccelerationStructureCompatibilityKHR(_vkGetDeviceProcAddr(Device, 'vkGetDeviceAccelerationStructureCompatibilityKHR'));
  DeviceFunctions.vkGetRayTracingShaderGroupStackSizeKHR := PFN_vkGetRayTracingShaderGroupStackSizeKHR(_vkGetDeviceProcAddr(Device, 'vkGetRayTracingShaderGroupStackSizeKHR'));
  DeviceFunctions.vkCmdSetRayTracingPipelineStackSizeKHR := PFN_vkCmdSetRayTracingPipelineStackSizeKHR(_vkGetDeviceProcAddr(Device, 'vkCmdSetRayTracingPipelineStackSizeKHR'));
  DeviceFunctions.vkGetImageViewHandleNVX := PFN_vkGetImageViewHandleNVX(_vkGetDeviceProcAddr(Device, 'vkGetImageViewHandleNVX'));
  DeviceFunctions.vkGetImageViewAddressNVX := PFN_vkGetImageViewAddressNVX(_vkGetDeviceProcAddr(Device, 'vkGetImageViewAddressNVX'));
  DeviceFunctions.vkGetDeviceGroupSurfacePresentModes2EXT := PFN_vkGetDeviceGroupSurfacePresentModes2EXT(_vkGetDeviceProcAddr(Device, 'vkGetDeviceGroupSurfacePresentModes2EXT'));
  DeviceFunctions.vkAcquireFullScreenExclusiveModeEXT := PFN_vkAcquireFullScreenExclusiveModeEXT(_vkGetDeviceProcAddr(Device, 'vkAcquireFullScreenExclusiveModeEXT'));
  DeviceFunctions.vkReleaseFullScreenExclusiveModeEXT := PFN_vkReleaseFullScreenExclusiveModeEXT(_vkGetDeviceProcAddr(Device, 'vkReleaseFullScreenExclusiveModeEXT'));
  DeviceFunctions.vkAcquireProfilingLockKHR := PFN_vkAcquireProfilingLockKHR(_vkGetDeviceProcAddr(Device, 'vkAcquireProfilingLockKHR'));
  DeviceFunctions.vkReleaseProfilingLockKHR := PFN_vkReleaseProfilingLockKHR(_vkGetDeviceProcAddr(Device, 'vkReleaseProfilingLockKHR'));
  DeviceFunctions.vkGetImageDrmFormatModifierPropertiesEXT := PFN_vkGetImageDrmFormatModifierPropertiesEXT(_vkGetDeviceProcAddr(Device, 'vkGetImageDrmFormatModifierPropertiesEXT'));
  DeviceFunctions.vkGetBufferOpaqueCaptureAddress := PFN_vkGetBufferOpaqueCaptureAddress(_vkGetDeviceProcAddr(Device, 'vkGetBufferOpaqueCaptureAddress'));
  DeviceFunctions.vkGetBufferDeviceAddress := PFN_vkGetBufferDeviceAddress(_vkGetDeviceProcAddr(Device, 'vkGetBufferDeviceAddress'));
  DeviceFunctions.vkInitializePerformanceApiINTEL := PFN_vkInitializePerformanceApiINTEL(_vkGetDeviceProcAddr(Device, 'vkInitializePerformanceApiINTEL'));
  DeviceFunctions.vkUninitializePerformanceApiINTEL := PFN_vkUninitializePerformanceApiINTEL(_vkGetDeviceProcAddr(Device, 'vkUninitializePerformanceApiINTEL'));
  DeviceFunctions.vkCmdSetPerformanceMarkerINTEL := PFN_vkCmdSetPerformanceMarkerINTEL(_vkGetDeviceProcAddr(Device, 'vkCmdSetPerformanceMarkerINTEL'));
  DeviceFunctions.vkCmdSetPerformanceStreamMarkerINTEL := PFN_vkCmdSetPerformanceStreamMarkerINTEL(_vkGetDeviceProcAddr(Device, 'vkCmdSetPerformanceStreamMarkerINTEL'));
  DeviceFunctions.vkCmdSetPerformanceOverrideINTEL := PFN_vkCmdSetPerformanceOverrideINTEL(_vkGetDeviceProcAddr(Device, 'vkCmdSetPerformanceOverrideINTEL'));
  DeviceFunctions.vkAcquirePerformanceConfigurationINTEL := PFN_vkAcquirePerformanceConfigurationINTEL(_vkGetDeviceProcAddr(Device, 'vkAcquirePerformanceConfigurationINTEL'));
  DeviceFunctions.vkReleasePerformanceConfigurationINTEL := PFN_vkReleasePerformanceConfigurationINTEL(_vkGetDeviceProcAddr(Device, 'vkReleasePerformanceConfigurationINTEL'));
  DeviceFunctions.vkQueueSetPerformanceConfigurationINTEL := PFN_vkQueueSetPerformanceConfigurationINTEL(_vkGetDeviceProcAddr(Device, 'vkQueueSetPerformanceConfigurationINTEL'));
  DeviceFunctions.vkGetPerformanceParameterINTEL := PFN_vkGetPerformanceParameterINTEL(_vkGetDeviceProcAddr(Device, 'vkGetPerformanceParameterINTEL'));
  DeviceFunctions.vkGetDeviceMemoryOpaqueCaptureAddress := PFN_vkGetDeviceMemoryOpaqueCaptureAddress(_vkGetDeviceProcAddr(Device, 'vkGetDeviceMemoryOpaqueCaptureAddress'));
  DeviceFunctions.vkGetPipelineExecutablePropertiesKHR := PFN_vkGetPipelineExecutablePropertiesKHR(_vkGetDeviceProcAddr(Device, 'vkGetPipelineExecutablePropertiesKHR'));
  DeviceFunctions.vkGetPipelineExecutableStatisticsKHR := PFN_vkGetPipelineExecutableStatisticsKHR(_vkGetDeviceProcAddr(Device, 'vkGetPipelineExecutableStatisticsKHR'));
  DeviceFunctions.vkGetPipelineExecutableInternalRepresentationsKHR := PFN_vkGetPipelineExecutableInternalRepresentationsKHR(_vkGetDeviceProcAddr(Device, 'vkGetPipelineExecutableInternalRepresentationsKHR'));
  DeviceFunctions.vkCmdSetLineStippleEXT := PFN_vkCmdSetLineStippleEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetLineStippleEXT'));
  DeviceFunctions.vkCreateAccelerationStructureKHR := PFN_vkCreateAccelerationStructureKHR(_vkGetDeviceProcAddr(Device, 'vkCreateAccelerationStructureKHR'));
  DeviceFunctions.vkCmdBuildAccelerationStructuresKHR := PFN_vkCmdBuildAccelerationStructuresKHR(_vkGetDeviceProcAddr(Device, 'vkCmdBuildAccelerationStructuresKHR'));
  DeviceFunctions.vkCmdBuildAccelerationStructuresIndirectKHR := PFN_vkCmdBuildAccelerationStructuresIndirectKHR(_vkGetDeviceProcAddr(Device, 'vkCmdBuildAccelerationStructuresIndirectKHR'));
  DeviceFunctions.vkBuildAccelerationStructuresKHR := PFN_vkBuildAccelerationStructuresKHR(_vkGetDeviceProcAddr(Device, 'vkBuildAccelerationStructuresKHR'));
  DeviceFunctions.vkGetAccelerationStructureDeviceAddressKHR := PFN_vkGetAccelerationStructureDeviceAddressKHR(_vkGetDeviceProcAddr(Device, 'vkGetAccelerationStructureDeviceAddressKHR'));
  DeviceFunctions.vkCreateDeferredOperationKHR := PFN_vkCreateDeferredOperationKHR(_vkGetDeviceProcAddr(Device, 'vkCreateDeferredOperationKHR'));
  DeviceFunctions.vkDestroyDeferredOperationKHR := PFN_vkDestroyDeferredOperationKHR(_vkGetDeviceProcAddr(Device, 'vkDestroyDeferredOperationKHR'));
  DeviceFunctions.vkGetDeferredOperationMaxConcurrencyKHR := PFN_vkGetDeferredOperationMaxConcurrencyKHR(_vkGetDeviceProcAddr(Device, 'vkGetDeferredOperationMaxConcurrencyKHR'));
  DeviceFunctions.vkGetDeferredOperationResultKHR := PFN_vkGetDeferredOperationResultKHR(_vkGetDeviceProcAddr(Device, 'vkGetDeferredOperationResultKHR'));
  DeviceFunctions.vkDeferredOperationJoinKHR := PFN_vkDeferredOperationJoinKHR(_vkGetDeviceProcAddr(Device, 'vkDeferredOperationJoinKHR'));
  DeviceFunctions.vkCmdSetCullModeEXT := PFN_vkCmdSetCullModeEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetCullModeEXT'));
  DeviceFunctions.vkCmdSetFrontFaceEXT := PFN_vkCmdSetFrontFaceEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetFrontFaceEXT'));
  DeviceFunctions.vkCmdSetPrimitiveTopologyEXT := PFN_vkCmdSetPrimitiveTopologyEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetPrimitiveTopologyEXT'));
  DeviceFunctions.vkCmdSetViewportWithCountEXT := PFN_vkCmdSetViewportWithCountEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetViewportWithCountEXT'));
  DeviceFunctions.vkCmdSetScissorWithCountEXT := PFN_vkCmdSetScissorWithCountEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetScissorWithCountEXT'));
  DeviceFunctions.vkCmdBindVertexBuffers2EXT := PFN_vkCmdBindVertexBuffers2EXT(_vkGetDeviceProcAddr(Device, 'vkCmdBindVertexBuffers2EXT'));
  DeviceFunctions.vkCmdSetDepthTestEnableEXT := PFN_vkCmdSetDepthTestEnableEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetDepthTestEnableEXT'));
  DeviceFunctions.vkCmdSetDepthWriteEnableEXT := PFN_vkCmdSetDepthWriteEnableEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetDepthWriteEnableEXT'));
  DeviceFunctions.vkCmdSetDepthCompareOpEXT := PFN_vkCmdSetDepthCompareOpEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetDepthCompareOpEXT'));
  DeviceFunctions.vkCmdSetDepthBoundsTestEnableEXT := PFN_vkCmdSetDepthBoundsTestEnableEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetDepthBoundsTestEnableEXT'));
  DeviceFunctions.vkCmdSetStencilTestEnableEXT := PFN_vkCmdSetStencilTestEnableEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetStencilTestEnableEXT'));
  DeviceFunctions.vkCmdSetStencilOpEXT := PFN_vkCmdSetStencilOpEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetStencilOpEXT'));
  DeviceFunctions.vkCmdSetPatchControlPointsEXT := PFN_vkCmdSetPatchControlPointsEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetPatchControlPointsEXT'));
  DeviceFunctions.vkCmdSetRasterizerDiscardEnableEXT := PFN_vkCmdSetRasterizerDiscardEnableEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetRasterizerDiscardEnableEXT'));
  DeviceFunctions.vkCmdSetDepthBiasEnableEXT := PFN_vkCmdSetDepthBiasEnableEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetDepthBiasEnableEXT'));
  DeviceFunctions.vkCmdSetLogicOpEXT := PFN_vkCmdSetLogicOpEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetLogicOpEXT'));
  DeviceFunctions.vkCmdSetPrimitiveRestartEnableEXT := PFN_vkCmdSetPrimitiveRestartEnableEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetPrimitiveRestartEnableEXT'));
  DeviceFunctions.vkCreatePrivateDataSlotEXT := PFN_vkCreatePrivateDataSlotEXT(_vkGetDeviceProcAddr(Device, 'vkCreatePrivateDataSlotEXT'));
  DeviceFunctions.vkDestroyPrivateDataSlotEXT := PFN_vkDestroyPrivateDataSlotEXT(_vkGetDeviceProcAddr(Device, 'vkDestroyPrivateDataSlotEXT'));
  DeviceFunctions.vkSetPrivateDataEXT := PFN_vkSetPrivateDataEXT(_vkGetDeviceProcAddr(Device, 'vkSetPrivateDataEXT'));
  DeviceFunctions.vkGetPrivateDataEXT := PFN_vkGetPrivateDataEXT(_vkGetDeviceProcAddr(Device, 'vkGetPrivateDataEXT'));
  DeviceFunctions.vkCmdCopyBuffer2KHR := PFN_vkCmdCopyBuffer2KHR(_vkGetDeviceProcAddr(Device, 'vkCmdCopyBuffer2KHR'));
  DeviceFunctions.vkCmdCopyImage2KHR := PFN_vkCmdCopyImage2KHR(_vkGetDeviceProcAddr(Device, 'vkCmdCopyImage2KHR'));
  DeviceFunctions.vkCmdBlitImage2KHR := PFN_vkCmdBlitImage2KHR(_vkGetDeviceProcAddr(Device, 'vkCmdBlitImage2KHR'));
  DeviceFunctions.vkCmdCopyBufferToImage2KHR := PFN_vkCmdCopyBufferToImage2KHR(_vkGetDeviceProcAddr(Device, 'vkCmdCopyBufferToImage2KHR'));
  DeviceFunctions.vkCmdCopyImageToBuffer2KHR := PFN_vkCmdCopyImageToBuffer2KHR(_vkGetDeviceProcAddr(Device, 'vkCmdCopyImageToBuffer2KHR'));
  DeviceFunctions.vkCmdResolveImage2KHR := PFN_vkCmdResolveImage2KHR(_vkGetDeviceProcAddr(Device, 'vkCmdResolveImage2KHR'));
  DeviceFunctions.vkCmdSetFragmentShadingRateKHR := PFN_vkCmdSetFragmentShadingRateKHR(_vkGetDeviceProcAddr(Device, 'vkCmdSetFragmentShadingRateKHR'));
  DeviceFunctions.vkCmdSetFragmentShadingRateEnumNV := PFN_vkCmdSetFragmentShadingRateEnumNV(_vkGetDeviceProcAddr(Device, 'vkCmdSetFragmentShadingRateEnumNV'));
  DeviceFunctions.vkGetAccelerationStructureBuildSizesKHR := PFN_vkGetAccelerationStructureBuildSizesKHR(_vkGetDeviceProcAddr(Device, 'vkGetAccelerationStructureBuildSizesKHR'));
  DeviceFunctions.vkCmdSetVertexInputEXT := PFN_vkCmdSetVertexInputEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetVertexInputEXT'));
  DeviceFunctions.vkCmdSetColorWriteEnableEXT := PFN_vkCmdSetColorWriteEnableEXT(_vkGetDeviceProcAddr(Device, 'vkCmdSetColorWriteEnableEXT'));
  DeviceFunctions.vkCmdSetEvent2KHR := PFN_vkCmdSetEvent2KHR(_vkGetDeviceProcAddr(Device, 'vkCmdSetEvent2KHR'));
  DeviceFunctions.vkCmdResetEvent2KHR := PFN_vkCmdResetEvent2KHR(_vkGetDeviceProcAddr(Device, 'vkCmdResetEvent2KHR'));
  DeviceFunctions.vkCmdWaitEvents2KHR := PFN_vkCmdWaitEvents2KHR(_vkGetDeviceProcAddr(Device, 'vkCmdWaitEvents2KHR'));
  DeviceFunctions.vkCmdPipelineBarrier2KHR := PFN_vkCmdPipelineBarrier2KHR(_vkGetDeviceProcAddr(Device, 'vkCmdPipelineBarrier2KHR'));
  DeviceFunctions.vkQueueSubmit2KHR := PFN_vkQueueSubmit2KHR(_vkGetDeviceProcAddr(Device, 'vkQueueSubmit2KHR'));
  DeviceFunctions.vkCmdWriteTimestamp2KHR := PFN_vkCmdWriteTimestamp2KHR(_vkGetDeviceProcAddr(Device, 'vkCmdWriteTimestamp2KHR'));
  DeviceFunctions.vkCmdWriteBufferMarker2AMD := PFN_vkCmdWriteBufferMarker2AMD(_vkGetDeviceProcAddr(Device, 'vkCmdWriteBufferMarker2AMD'));
  DeviceFunctions.vkGetQueueCheckpointData2NV := PFN_vkGetQueueCheckpointData2NV(_vkGetDeviceProcAddr(Device, 'vkGetQueueCheckpointData2NV'));
  DeviceFunctions.vkCreateVideoSessionKHR := PFN_vkCreateVideoSessionKHR(_vkGetDeviceProcAddr(Device, 'vkCreateVideoSessionKHR'));
  DeviceFunctions.vkDestroyVideoSessionKHR := PFN_vkDestroyVideoSessionKHR(_vkGetDeviceProcAddr(Device, 'vkDestroyVideoSessionKHR'));
  DeviceFunctions.vkCreateVideoSessionParametersKHR := PFN_vkCreateVideoSessionParametersKHR(_vkGetDeviceProcAddr(Device, 'vkCreateVideoSessionParametersKHR'));
  DeviceFunctions.vkUpdateVideoSessionParametersKHR := PFN_vkUpdateVideoSessionParametersKHR(_vkGetDeviceProcAddr(Device, 'vkUpdateVideoSessionParametersKHR'));
  DeviceFunctions.vkDestroyVideoSessionParametersKHR := PFN_vkDestroyVideoSessionParametersKHR(_vkGetDeviceProcAddr(Device, 'vkDestroyVideoSessionParametersKHR'));
  DeviceFunctions.vkGetVideoSessionMemoryRequirementsKHR := PFN_vkGetVideoSessionMemoryRequirementsKHR(_vkGetDeviceProcAddr(Device, 'vkGetVideoSessionMemoryRequirementsKHR'));
  DeviceFunctions.vkBindVideoSessionMemoryKHR := PFN_vkBindVideoSessionMemoryKHR(_vkGetDeviceProcAddr(Device, 'vkBindVideoSessionMemoryKHR'));
  DeviceFunctions.vkCmdDecodeVideoKHR := PFN_vkCmdDecodeVideoKHR(_vkGetDeviceProcAddr(Device, 'vkCmdDecodeVideoKHR'));
  DeviceFunctions.vkCmdBeginVideoCodingKHR := PFN_vkCmdBeginVideoCodingKHR(_vkGetDeviceProcAddr(Device, 'vkCmdBeginVideoCodingKHR'));
  DeviceFunctions.vkCmdControlVideoCodingKHR := PFN_vkCmdControlVideoCodingKHR(_vkGetDeviceProcAddr(Device, 'vkCmdControlVideoCodingKHR'));
  DeviceFunctions.vkCmdEndVideoCodingKHR := PFN_vkCmdEndVideoCodingKHR(_vkGetDeviceProcAddr(Device, 'vkCmdEndVideoCodingKHR'));
  DeviceFunctions.vkCmdEncodeVideoKHR := PFN_vkCmdEncodeVideoKHR(_vkGetDeviceProcAddr(Device, 'vkCmdEncodeVideoKHR'));
  DeviceFunctions.vkCreateCuModuleNVX := PFN_vkCreateCuModuleNVX(_vkGetDeviceProcAddr(Device, 'vkCreateCuModuleNVX'));
  DeviceFunctions.vkCreateCuFunctionNVX := PFN_vkCreateCuFunctionNVX(_vkGetDeviceProcAddr(Device, 'vkCreateCuFunctionNVX'));
  DeviceFunctions.vkDestroyCuModuleNVX := PFN_vkDestroyCuModuleNVX(_vkGetDeviceProcAddr(Device, 'vkDestroyCuModuleNVX'));
  DeviceFunctions.vkDestroyCuFunctionNVX := PFN_vkDestroyCuFunctionNVX(_vkGetDeviceProcAddr(Device, 'vkDestroyCuFunctionNVX'));
  DeviceFunctions.vkCmdCuLaunchKernelNVX := PFN_vkCmdCuLaunchKernelNVX(_vkGetDeviceProcAddr(Device, 'vkCmdCuLaunchKernelNVX'));
  DeviceFunctions.vkWaitForPresentKHR := PFN_vkWaitForPresentKHR(_vkGetDeviceProcAddr(Device, 'vkWaitForPresentKHR'));
  Exit(True);
end;
{$ENDIF}

function VK_MAKE_API_VERSION(_variant, major, minor, patch: UInt32): UInt32; inline;
begin
  Exit((_variant shl 29) or (major shl 22) or (minor shl 12) or patch);
end;

function VK_API_VERSION_VARIANT(version: UInt32): UInt32; inline;
begin
  Exit(version shr 29);
end;

function VK_API_VERSION_MAJOR(version: UInt32): UInt32; inline;
begin
  Exit((version shr 22) and $7F);
end;

function VK_API_VERSION_MINOR(version: UInt32): UInt32; inline;
begin
  Exit((version shr 12) and $3FF);
end;

function VK_API_VERSION_PATCH(version: UInt32): UInt32; inline;
begin
  Exit(version and $FFF);
end;

function VK_MAKE_VERSION(major, minor, patch: UInt32): UInt32; inline;
begin
  Exit((major shl 22) or (minor shl 12) or patch);
end;

function VK_VERSION_MAJOR(version: UInt32): UInt32; inline;
begin
  Exit(version shr 22);
end;

function VK_VERSION_MINOR(version: UInt32): UInt32; inline;
begin
  Exit((version shr 12) and $3FF);
end;

function VK_VERSION_PATCH(version: UInt32): UInt32; inline;
begin
  Exit(version and $FFF);
end;

end.

//  ------------------------------------------------------------------------------
//  This software is available under 2 licenses -- choose whichever you prefer.
//  ------------------------------------------------------------------------------
//  ALTERNATIVE A - MIT License
//  Copyright (c) 2017 Sean Barrett
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//  ------------------------------------------------------------------------------
//  ALTERNATIVE B - Public Domain (www.unlicense.org)
//  This is free and unencumbered software released into the public domain.
//  Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
//  software, either in source code form or as a compiled binary, for any purpose,
//  commercial or non-commercial, and by any means.
//  In jurisdictions that recognize copyright laws, the author or authors of this
//  software dedicate any and all copyright interest in the software to the public
//  domain. We make this dedication for the benefit of the public at large and to
//  the detriment of our heirs and successors. We intend this dedication to be an
//  overt act of relinquishment in perpetuity of all present and future rights to
//  this software under copyright law.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
//  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//  ------------------------------------------------------------------------------
