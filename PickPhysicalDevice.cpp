// PickPhysicalDevice.cpp
// Rates all available physical GPU devices and returns the one with the highest score.
// Writes the highest scoring GPU score to a PhysicalDevice pointer.

#define GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>
#include <iostream>
#include <vector>
#include <map>
#include <set>

#include "VulkanPhysicalDevice.h"
#include "VulkanQueueFamily.h"
#include "VulkanSwapChain.h"

int VulkanApplication::RateDeviceSuitability(VkPhysicalDevice * PhysicalDevice, VkSurfaceKHR * Surface) {
	int Score = 0;
	VkPhysicalDeviceProperties DeviceProperties{};
	VkPhysicalDeviceFeatures DeviceFeatures{};

	vkGetPhysicalDeviceProperties(*PhysicalDevice, &DeviceProperties);
	vkGetPhysicalDeviceFeatures(*PhysicalDevice, &DeviceFeatures);

	QueueFamilyIndices Indices = VulkanApplication::FindQueueFamilies(PhysicalDevice, Surface);
	if (!Indices.IsComplete() || !DeviceFeatures.geometryShader || !VulkanApplication::CheckDeviceExtensionSupport(PhysicalDevice)) {
		return 0;
	}

	SwapChainSupportDetails SwapChainSupport = QuerySwapChainSupport(PhysicalDevice, Surface);
	bool SwapChainAdequate = !SwapChainSupport.Formats.empty() && !SwapChainSupport.PresentationModes.empty();

	if (!SwapChainAdequate) {
		return 0;
	}

	if (DeviceProperties.deviceType == VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU) { // Discrete GPUs have a significant performance advantage
		Score += 1000;
	}

	Score += DeviceProperties.limits.maxImageDimension2D;

	return Score;
}

bool VulkanApplication::CheckDeviceExtensionSupport(VkPhysicalDevice* PhysicalDevice) {
	uint32_t ExtensionCount = 0;
	vkEnumerateDeviceExtensionProperties(*PhysicalDevice, nullptr, &ExtensionCount, nullptr);

	std::vector<VkExtensionProperties> AvailableExtensionProperties{ ExtensionCount };
	vkEnumerateDeviceExtensionProperties(*PhysicalDevice, nullptr, &ExtensionCount, AvailableExtensionProperties.data());

	std::set<std::string> RequiredExtensions {DeviceExtensions.begin(), DeviceExtensions.end()};

	for (const auto& Extension : AvailableExtensionProperties) {
		RequiredExtensions.erase(Extension.extensionName);
	}

	return RequiredExtensions.empty();
}

void VulkanApplication::PickPhysicalDevice(VkInstance * Instance, VkPhysicalDevice* PhysicalDevice, VkSurfaceKHR* Surface) {
	uint32_t DeviceCount {0};
	vkEnumeratePhysicalDevices(*Instance, &DeviceCount, nullptr);

	if (DeviceCount == 0) {
		throw std::runtime_error("No physical device found!");
	}

	std::vector<VkPhysicalDevice> Devices { DeviceCount };
	vkEnumeratePhysicalDevices(*Instance, &DeviceCount, Devices.data());

	std::multimap<int, VkPhysicalDevice> Candidates;
	VkPhysicalDevice SuitableDevice;

	for (VkPhysicalDevice Candidate : Devices) {
		int DeviceScore = VulkanApplication::RateDeviceSuitability(&Candidate, Surface);
		Candidates.insert(std::make_pair(DeviceScore, Candidate));
	}

	if (Candidates.rbegin()->first > 0) {
		SuitableDevice = Candidates.rbegin()->second;
	} 
	else {
		throw std::runtime_error("No suitable device found");
	}

	*PhysicalDevice = SuitableDevice;
}
