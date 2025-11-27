import ProjectDescription

public extension SettingsDictionary {
  static var project_base: SettingsDictionary {
    [
      "CODE_SIGN_STYLE": "Manual",
      "DEVELOPMENT_TEAM": "F3QMGAV9F8",
      "IPHONEOS_DEPLOYMENT_TARGET": "26.0",
      "OTHER_LDFLAGS": .array(["$(inherited)", "-ObjC"]),
      "_EXPERIMENTAL_SWIFT_EXPLICIT_MODULES": true
    ]
  }

  static var project_debug: SettingsDictionary {
    [
      "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
      "SWIFT_OPTIMIZATION_LEVEL": "-Onone"
    ]
  }

  static var project_release: SettingsDictionary {
    [
      "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "RELEASE",
      "SWIFT_OPTIMIZATION_LEVEL": "-O -whole-module-optimization"
    ]
  }

  static var app_base: SettingsDictionary {
    [
      "PRODUCT_NAME": "Fixsy"
    ]
  }

  static var app_debug: SettingsDictionary {
    [
      "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG"
    ]
  }

  static var app_release: SettingsDictionary {
    [
      "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "RELEASE"
    ]
  }
}

extension Environment {
  public static var isDevModeEnabled: Bool {
    Environment.devMode.getBoolean(default: true)
  }
}
