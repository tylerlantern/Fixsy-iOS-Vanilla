import ProjectDescription

public extension SettingsDictionary {
  static var project_base: SettingsDictionary {
    [
      "ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS": false,
      "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": false,
      "CODE_SIGN_STYLE": "Manual",
      "DEVELOPMENT_TEAM": "92XK5S268V",
      "IPHONEOS_DEPLOYMENT_TARGET": "18.0",
      "ENABLE_USER_SCRIPT_SANDBOXING": true,
      "MODULE_VERIFIER_SUPPORTED_LANGUAGE_STANDARDS": .array(["gnu11", "gnu++14"]),
      "_EXPERIMENTAL_SWIFT_EXPLICIT_MODULES": true,
      "EAGER_LINKING": true,
      "SWIFT_VERSION": "6",
      "SWIFT_ACTIVE_COMPILATION_CONDITIONS": .SWIFT_ACTIVE_COMPILATION_CONDITIONS,
      "OTHER_LDFLAGS": .array(["$(inherited)", "-ObjC"]),
      "OTHER_SWIFT_FLAGS": .array([
        "-Xfrontend -warn-long-function-bodies=1000",
        "-Xfrontend -warn-long-expression-type-checking=1000"
      ])
    ]
  }

  static var project_debug: SettingsDictionary {
    [
      "ENABLE_MODULE_VERIFIER": false,
      "CLANG_ENABLE_EXPLICIT_MODULES": false,
      "CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED": true
    ]
  }

  static var project_release: SettingsDictionary {
    [
      "ENABLE_MODULE_VERIFIER": true
    ]
  }

  static var app_base: SettingsDictionary {
    [:]
  }

  static var app_debug: SettingsDictionary {
    [
      "CODE_SIGN_IDENTITY": "Apple Development: Created via API (PD8PQZDKG4)"
    ]
  }

  static var app_release: SettingsDictionary {
    [
      "CODE_SIGN_IDENTITY": "Apple Distribution: MessageSpring, LLC (92XK5S268V)"
    ]
  }
}

extension SettingValue {
  public static var SWIFT_ACTIVE_COMPILATION_CONDITIONS: Self {
    .array(
      Environment.isDevModeEnabled ? ["DEV_MODE"] : []
    )
  }
}

extension Environment {
  public static var isDevModeEnabled: Bool {
    Environment.devMode.getBoolean(default: true)
  }
}
