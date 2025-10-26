import ProjectDescription

public extension SettingsDictionary {
  static var project_base: SettingsDictionary {
    [
      "DEVELOPMENT_TEAM": "F3QMGAV9F8",
      "IPHONEOS_DEPLOYMENT_TARGET": "26.0",
      "OTHER_LDFLAGS": .array(["$(inherited)", "-ObjC"])
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
    [
      "PRODUCT_NAME": "Fixsy"
    ]
  }

  static var app_debug: SettingsDictionary {
    [:]
//    [
//      "CODE_SIGN_IDENTITY": "Apple Development: Created via API (PD8PQZDKG4)"
//    ]
  }

  static var app_release: SettingsDictionary {
    [:]
//    [
//      "CODE_SIGN_IDENTITY": "Apple Distribution: MessageSpring, LLC (92XK5S268V)"
//    ]
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
