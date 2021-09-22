# dvulkan

Free Pascal Header for Vulkan API, public domain. All in the [dvulkan.pas](dvulkan.pas) file.

##  Issues

* Tested only on Windows, no support for other platforms for now
* Declarations for `vk_video` are incomplete. Should be removed completely I guess

## Naming

Almost all names are consistent with those of the C headers:
* `Vk*`   - types
* `vk*`   - functions
* `PFN_*` - pointers to functions
* `VK_*`  - constants

There are several exceptions, though:
* When a field or a function argument is a Pascal keyword, an underscore
  prefix is added, e.g. `_type` instead of `type`
* When a declaration instoduced which is not part of the Vulkan API,
  regular pascal conventions are implied (e.g. T prefix for types), e.g.
  `TVkHandleNonDispatchable`
* Additionaly, almost each type has corresponding `P*` and `PP*`
  declarations for a "pointer to X" and a "pointer to pointer to X"
  types respectively. For example, for VkBuffer there are PVkBuffer
  and PPVkBuffer types.

## The loader

The [dvulkan](dvulkan.pas) unit is provided with a loader. The loader consists of the following:
* Statically loaded `vkGetInstanceProcAddr` provided by the system.
* A function `LoadVulkanGeneralFunctions` and a record `TVulkanGeneralFunctions` for loading general function (i.e. non-instance and non-device functions)
* A function `LoadVulkanInstanceFunctions` and a record `TVulkanInstanceFunctions` for loading instance functions
* A function `LoadVulkanDeviceFunctions` and a record `TVulkanDeviceFunctions` for loading device functions

Here is an example pseudocode of how to use all of that:

```pascal
var
  vkg: TVulkanGeneralFunctions;
  vki: TVulkanInstanceFunctions;
  vkd: TVulkanDeviceFunctions;
  instance: VkInstance;
  device: VkDevice;

function InitVulkan: Boolean;
begin
  if not LoadVulkanGeneralFunctions(@vkGetInstanceProcAddr, vkg) then
    Exit(False);

  ...

  if vkg.vkCreateInstance(@instanceCreateInfo, nil, @instance) <> VK_SUCCESS then
    Exit(False);

  if not LoadVulkanInstanceFunctions(instance, vkg.vkGetInstanceProcAddr, vki) then
      Exit(False);

  ...

  if vki.vkCreateDevice(physicalDevice, @deviceCreateInfo, nil, @device) <> VK_SUCCESS then
    Exit(False);

  // Notice the vki.vkGetDeviceProcAddr
  if not LoadVulkanInstanceFunctions(instance, vki.vkGetDeviceProcAddr, vkd) then
      Exit(False);

  // Now all the functions loaded to vkg, vki, vkd and can be used

  ...

  Exit(True);
end;
```

The [dvulkan.pas](dvulkan.pas) unit does not provide global functions besides
the global `vkGetInstanceProcAddr`. If you don't want to use prefixes in your
code, you can use `with` operator:

```pascal
  with vkg, vki, vkd do begin
    ...
  end;
```

You can disable the loader entirely by commenting out the `DVULKAN_LOADER` define.
