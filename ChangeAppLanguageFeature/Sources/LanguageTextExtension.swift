import SwiftUI

extension Text {
	static func englishLanguageNameText(localization: String) -> Text {
		if localization.hasPrefix("en") {
			Text("English")
		} else if localization.hasPrefix("th") {
			Text("Thai")
		} else {
			Text("English")
		}
	}

	static func nativeLanguageNameText(localization: String) -> Text {
		if localization.hasPrefix("en") {
			Text(verbatim: "English")
		} else if localization.hasPrefix("th") {
			Text(verbatim: "ไทย")
		} else {
			Text(verbatim: "English")
		}
	}
}
