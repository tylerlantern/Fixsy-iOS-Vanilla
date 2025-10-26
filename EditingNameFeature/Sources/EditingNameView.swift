import APIClient
import BannerCenterModule
import DatabaseClient
import Router
import SwiftUI

public struct EditingNameView: View {
  @State var firstName: String
  @State var lastName: String
  @State var isSubmiting: Bool = false
  @State var submitTask: Task<(), Never>?

  @Environment(\.router) var router
  @Environment(\.apiClient) var apiClient
  @Environment(\.databaseClient) var databaseClient
  @Environment(\.dismiss) var dismiss

  @EnvironmentObject var banners: BannerCenter

  public init(
    firstName: String,
    lastName: String
  ) {
    self.firstName = firstName
    self.lastName = lastName
  }

  public var body: some View {
    VStack {
      Form {
        Section {
          TextField(
            "First name",
            text: self.$firstName
          )
          TextField(
            "Last name",
            text: self.$lastName
          )
        }
      }
      Spacer()
      Button {
        self.submit()
      } label: {
        HStack(spacing: 8) {
          Spacer()
          if self.isSubmiting {
            ProgressView().tint(Color.white)
          }
          Text("Save")
            .bold()
            .foregroundColor(Color.white)
            .padding()
          Spacer()
        }
      }
      .background(
        EditingNameFeatureAsset.Colors.primary.swiftUIColor
      )
      .padding()
      .disabled(self.isSubmiting)
    }
    .navigationBarTitle("Editing Name")
    .onDisappear {
      self.submitTask?.cancel()
    }
  }
}

#if DEBUG
  #Preview {
    EditingNameView(firstName: "Tiger", lastName: "Hippo")
  }
#endif
