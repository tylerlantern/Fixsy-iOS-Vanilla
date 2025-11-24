import SwiftUI

public struct ChangeApplicationLanguageView: View {
  let applicationLanguageSet: Set<String> = Set(
    Bundle.main.preferredLocalizations
  )

  let suggestedLocales: [String] = Locale.preferredLanguages
  let suggestedLocaleSet: Set<String> = Set(Locale.preferredLanguages)
  var localizations: [String] {
    Bundle.main.localizations.filter { localization in
      !self.suggestedLocaleSet.contains { suggested in
        suggested.hasPrefix(localization)
      }
    }
  }

  @State var changeLanguageAs: String? = nil

  var confirmChangeLanguageAlertPresented: Binding<Bool> {
    Binding(
      get: {
        self.changeLanguageAs != nil
      },
      set: { isPresented in
        self.changeLanguageAs = isPresented ? self.changeLanguageAs : nil
      }
    )
  }

  public init() {}

  func isLocalizationSelected(_ localization: String) -> Bool {
    self.applicationLanguageSet.contains(where: { applicationLanguage in
      localization.hasPrefix(applicationLanguage)
    })
  }

  private func normalizedLanguage(_ id: String) -> String {
    id.split(separator: "-").first.map(String.init) ?? id
  }

  public var body: some View {
    ScrollView {
      VStack(spacing: 12) {
        if !self.suggestedLocales.isEmpty {
          HStack {
            Text(
              String(
                localized: "Suggested",
                bundle: .module
              )
            )
            .fontWeight(.semibold)
            Spacer()
          }
          .padding(.bottom, 5)

          ForEach(self.suggestedLocales, id: \.self) { localization in
            Button {
              self.changeLanguageAs = localization
            } label: {
              HStack {
                MenuMessageView(
                  title: Text.nativeLanguageNameText(
                    localization: localization
                  ),
                  subtitle: Text.englishLanguageNameText(
                    localization: localization
                  ),
                )
                if self.isLocalizationSelected(localization) {
                  Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(
                      ChangeAppLanguageFeatureAsset.primary.swiftUIColor
                    )
                }
              }
              .padding(.vertical, 4)
              .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(self.isLocalizationSelected(localization))

            Divider()
          }
        }

        ForEach(Array(self.localizations.enumerated()), id: \.element) {
          index,
            localization in
          Button {
            self.changeLanguageAs = localization
          } label: {
            HStack {
              MenuMessageView(
                title: Text.nativeLanguageNameText(localization: localization),
                subtitle: Text.englishLanguageNameText(
                  localization: localization
                ),
              )

              if self.isLocalizationSelected(localization) {
                Image(systemName: "checkmark.circle.fill")
                  .foregroundStyle(.primary)
              }
            }
            .padding(.vertical, 4)
          }
          .disabled(self.isLocalizationSelected(localization))

          if index != self.localizations.count - 1 {
            Divider()
          }
        }
      }
      .padding()
    }
    .toolbarTitleDisplayMode(.inline)
    .navigationTitle(
      Text(
        String(
          localized: "Application language",
          bundle: .module
        )
      )
    )
    .alert(
      Text(
        String(
          localized: "Restart App Required",
          bundle: .module
        )
      ),
      isPresented: self.confirmChangeLanguageAlertPresented
    ) {
      Button(role: .cancel) {} label: {
        Text(
          String(
            localized: "Cancel",
            bundle: .module
          )
        )
      }
      Button {
        if let changeLanguageAs {
          UserDefaults.standard.set([changeLanguageAs], forKey: "AppleLanguages")
          exit(0)
        }
      } label: {
        Text(
          String(
            localized: "Restart",
            bundle: .module
          )
        )
      }
    } message: {
      Text(
        String(
          localized: "To apply the language change, please restart the app.",
          bundle: .module
        )
      )
    }
  }
}

public struct MenuMessageView: View {
  let title: Text
  let subtitle: Text

  let detailTitle: Text?

  public init(title: Text, subtitle: Text, detailTitle: Text? = nil) {
    self.title = title
    self.subtitle = subtitle
    self.detailTitle = detailTitle
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack {
        Spacer()
      }
      self.title
        .fontWeight(.semibold)
      self.subtitle
    }
  }
}

#if DEBUG
  #Preview {
    NavigationStack {
      ChangeApplicationLanguageView()
    }
  }
#endif
