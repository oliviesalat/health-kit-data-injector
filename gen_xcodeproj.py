#!/usr/bin/env python3
"""Generate HealthKitInjector.xcodeproj/project.pbxproj"""

import os

BASE = os.path.dirname(os.path.abspath(__file__))

# Fixed UUIDs (24 hex chars, deterministic)
ID = {
    "project":        "AA000000000000000000001",
    "target":         "AA000000000000000000002",
    "cfglist_proj":   "AA000000000000000000003",
    "cfglist_tgt":    "AA000000000000000000004",
    "cfg_proj_dbg":   "AA000000000000000000005",
    "cfg_proj_rel":   "AA000000000000000000006",
    "cfg_tgt_dbg":    "AA000000000000000000007",
    "cfg_tgt_rel":    "AA000000000000000000008",
    "bp_src":         "AA000000000000000000009",
    "bp_fw":          "AA000000000000000000010",
    "bp_res":         "AA000000000000000000011",
    "gp_main":        "AA000000000000000000012",
    "gp_src":         "AA000000000000000000013",
    "gp_prod":        "AA000000000000000000014",
    "gp_fw":          "AA000000000000000000015",
    "fref_app":       "AA000000000000000000016",
    "fref_cv":        "AA000000000000000000017",
    "fref_hkm":       "AA000000000000000000018",
    "fref_dtc":       "AA000000000000000000019",
    "fref_dtr":       "AA000000000000000000020",
    "fref_info":      "AA000000000000000000021",
    "fref_ent":       "AA000000000000000000022",
    "fref_assets":    "AA000000000000000000023",
    "fref_prod":      "AA000000000000000000024",
    "fref_hkfw":      "AA000000000000000000025",
    "bfid_app":       "AA000000000000000000026",
    "bfid_cv":        "AA000000000000000000027",
    "bfid_hkm":       "AA000000000000000000028",
    "bfid_dtc":       "AA000000000000000000029",
    "bfid_dtr":       "AA000000000000000000030",
    "bfid_hkfw":      "AA000000000000000000031",
    "bfid_assets":    "AA000000000000000000032",
}

SOURCE_FILES = [
    ("fref_app",  "bfid_app",  "HealthKitInjectorApp.swift"),
    ("fref_cv",   "bfid_cv",   "ContentView.swift"),
    ("fref_hkm",  "bfid_hkm",  "HealthKitManager.swift"),
    ("fref_dtc",  "bfid_dtc",  "DataTypeConfig.swift"),
    ("fref_dtr",  "bfid_dtr",  "DataTypeRow.swift"),
]

def pbxproj():
    i = ID
    src_build_files = "\n".join(
        f"\t\t{i[bfid]} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {i[fref]} /* {name} */; }};"
        for fref, bfid, name in SOURCE_FILES
    )
    src_file_refs = "\n".join(
        f"\t\t{i[fref]} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = \"<group>\"; }};"
        for fref, bfid, name in SOURCE_FILES
    )
    src_group_children = "\n".join(
        f"\t\t\t\t{i[fref]} /* {name} */,"
        for fref, bfid, name in SOURCE_FILES
    )
    src_sources_files = "\n".join(
        f"\t\t\t\t{i[bfid]} /* {name} in Sources */,"
        for fref, bfid, name in SOURCE_FILES
    )

    return f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 77;
\tobjects = {{

/* Begin PBXBuildFile section */
{src_build_files}
\t\t{i["bfid_hkfw"]} /* HealthKit.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = {i["fref_hkfw"]} /* HealthKit.framework */; }};
\t\t{i["bfid_assets"]} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {i["fref_assets"]} /* Assets.xcassets */; }};
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{src_file_refs}
\t\t{i["fref_info"]} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};
\t\t{i["fref_ent"]} /* HealthKitInjector.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = HealthKitInjector.entitlements; sourceTree = "<group>"; }};
\t\t{i["fref_assets"]} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};
\t\t{i["fref_prod"]} /* HealthKitInjector.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = HealthKitInjector.app; sourceTree = BUILT_PRODUCTS_DIR; }};
\t\t{i["fref_hkfw"]} /* HealthKit.framework */ = {{isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = HealthKit.framework; path = System/Library/Frameworks/HealthKit.framework; sourceTree = SDKROOT; }};
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{i["bp_fw"]} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{i["bfid_hkfw"]} /* HealthKit.framework in Frameworks */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t{i["gp_main"]} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{i["gp_src"]} /* HealthKitInjector */,
\t\t\t\t{i["gp_fw"]} /* Frameworks */,
\t\t\t\t{i["gp_prod"]} /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{i["gp_src"]} /* HealthKitInjector */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{src_group_children}
\t\t\t\t{i["fref_info"]} /* Info.plist */,
\t\t\t\t{i["fref_ent"]} /* HealthKitInjector.entitlements */,
\t\t\t\t{i["fref_assets"]} /* Assets.xcassets */,
\t\t\t);
\t\t\tpath = HealthKitInjector;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{i["gp_prod"]} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{i["fref_prod"]} /* HealthKitInjector.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{i["gp_fw"]} /* Frameworks */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{i["fref_hkfw"]} /* HealthKit.framework */,
\t\t\t);
\t\t\tname = Frameworks;
\t\t\tsourceTree = "<group>";
\t\t}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{i["target"]} /* HealthKitInjector */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {i["cfglist_tgt"]} /* Build configuration list for PBXNativeTarget "HealthKitInjector" */;
\t\t\tbuildPhases = (
\t\t\t\t{i["bp_src"]} /* Sources */,
\t\t\t\t{i["bp_fw"]} /* Frameworks */,
\t\t\t\t{i["bp_res"]} /* Resources */,
\t\t\t);
\t\t\tbuildRules = ();
\t\t\tdependencies = ();
\t\t\tname = HealthKitInjector;
\t\t\tpackageProductDependencies = ();
\t\t\tproductName = HealthKitInjector;
\t\t\tproductReference = {i["fref_prod"]} /* HealthKitInjector.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{i["project"]} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1630;
\t\t\t\tLastUpgradeCheck = 1630;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{i["target"]} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 16.3;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {i["cfglist_proj"]} /* Build configuration list for PBXProject "HealthKitInjector" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {i["gp_main"]};
\t\t\tproductRefGroup = {i["gp_prod"]} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{i["target"]} /* HealthKitInjector */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{i["bp_res"]} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{i["bfid_assets"]} /* Assets.xcassets in Resources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{i["bp_src"]} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{src_sources_files}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\t{i["cfg_proj_dbg"]} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{i["cfg_proj_rel"]} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{i["cfg_tgt_dbg"]} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_ENTITLEMENTS = HealthKitInjector/HealthKitInjector.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = HealthKitInjector/Info.plist;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "com.example.HealthKitInjector";
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{i["cfg_tgt_rel"]} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_ENTITLEMENTS = HealthKitInjector/HealthKitInjector.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = HealthKitInjector/Info.plist;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "com.example.HealthKitInjector";
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{i["cfglist_proj"]} /* Build configuration list for PBXProject "HealthKitInjector" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{i["cfg_proj_dbg"]} /* Debug */,
\t\t\t\t{i["cfg_proj_rel"]} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{i["cfglist_tgt"]} /* Build configuration list for PBXNativeTarget "HealthKitInjector" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{i["cfg_tgt_dbg"]} /* Debug */,
\t\t\t\t{i["cfg_tgt_rel"]} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */

\t}};
\trootObject = {i["project"]} /* Project object */;
}}
"""

proj_dir = os.path.join(BASE, "HealthKitInjector.xcodeproj")
os.makedirs(proj_dir, exist_ok=True)
pbxproj_path = os.path.join(proj_dir, "project.pbxproj")
with open(pbxproj_path, "w") as f:
    f.write(pbxproj())

print(f"Generated: {pbxproj_path}")
