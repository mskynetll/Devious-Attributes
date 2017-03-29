#include <common/IDebugLog.h>
#include <skse/PluginAPI.h>	
#include <skse/skse_version.h>
#include <shlobj.h>				// CSIDL_MYCODUMENTS

#include "AttributesTracker.h"
#include "DeviousAttributes.hpp"
#include "EventsDispatcher.hpp"

static PluginHandle					g_pluginHandle = kPluginHandle_Invalid;
static SKSEPapyrusInterface         *g_papyrus = nullptr;
static SKSESerializationInterface	*g_serialization = nullptr;
const UInt32 kSerializationVersion = 1;


void Serialization_Load(SKSESerializationInterface* intfc)
{
	_MESSAGE("Loading persisted data...");
	g_AttributesTracker.Load(intfc);
}

void Serialization_Save(SKSESerializationInterface * intfc)
{
	_MESSAGE("Saving persisted data...");
	g_AttributesTracker.Save(intfc);
}

extern "C" {

	bool SKSEPlugin_Query(const SKSEInterface * skse, PluginInfo * info) 
	{
		gLog.OpenRelative(CSIDL_MYDOCUMENTS, "\\My Games\\Skyrim\\SKSE\\DeviousAttributes.log");
		gLog.SetPrintLevel(IDebugLog::kLevel_Error);
		gLog.SetLogLevel(IDebugLog::kLevel_DebugMessage);

		info->infoVersion = PluginInfo::kInfoVersion;
		info->name = "DeviousAttributes";
		info->version = 1;

		g_pluginHandle = skse->GetPluginHandle();

		if (skse->isEditor)
		{
			_MESSAGE("loaded in editor, marking as incompatible");

			return false;
		}
		else if (skse->runtimeVersion != RUNTIME_VERSION_1_9_32_0)
		{
			_MESSAGE("unsupported runtime version %08X", skse->runtimeVersion);

			return false;
		}

		// ### do not do anything else in this callback
		// ### only fill out PluginInfo and return true/false

		// supported runtime version
		return true;
	}

	bool SKSEPlugin_Load(const SKSEInterface * skse) {	// Called by SKSE to load this plugin
		_MESSAGE("Devious Attributes loaded, starting registration of papyrus functions");

		g_papyrus = (SKSEPapyrusInterface *)skse->QueryInterface(kInterface_Papyrus);
		g_serialization = (SKSESerializationInterface*)skse->QueryInterface(kInterface_Serialization);		

		bool success = g_papyrus->Register(AttributesTrackerPapyrus::RegisterFuncs);

		if (success)
		{
			_MESSAGE("Registeration of attribute tracking functions succeeded");
		}
		else return false;

		success = g_papyrus->Register(EventsDispatcher::RegisterFuncs);

		if (success)
		{
			_MESSAGE("Registeration of event dispatching functions succeeded");
		}
		else return false;

		success = g_papyrus->Register(DeviousAttributes::RegisterFuncs);

		if (success)
		{
			_MESSAGE("Registeration of attributes mutation functions succeeded");
		}
		else return false;

		g_serialization->SetUniqueID(g_pluginHandle, 'Datt');
		g_serialization->SetSaveCallback(g_pluginHandle, Serialization_Save);
		g_serialization->SetLoadCallback(g_pluginHandle, Serialization_Load);

		return true;
	}
};