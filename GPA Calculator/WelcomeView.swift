import SwiftUI

// WelcomeView provides the first screen the user sees upon launching the app.
struct WelcomeView: View {
    // `navAction` determines the destination view for the navigation link.
    // A value of 1 triggers a navigation to the `PresetSetupView`.
    @State var navAction: Int? = 0

    // `appSingleton` holds the shared application data and methods used across different views.
    var appSingleton: AppSingleton
    
    var body: some View {
        // A NavigationView encapsulates the entire view, allowing navigations between views.
        NavigationView {
            VStack(spacing: 0) {
                // The NavigationLink is set up to navigate to the `PresetSetupView` when `navAction` is 1.
                // It's wrapped in an EmptyView as its activation is controlled programmatically, not by user interaction.
                NavigationLink(
                    destination: PresetSetupView(appSingleton: appSingleton),
                    tag: 1,
                    selection: $navAction,
                    label: {
                        EmptyView()
                    }
                )

                Spacer() // Creates empty space
                
                // This VStack holds the introductory text and images.
                VStack(spacing: 0) {
                    Image("Icon")
                        .resizable()
                        .frame(width: 123, height: 123)
                        .shadow(color: .init("WelcomeShadow"), radius: 13, x: 0, y: 0)
                        .padding(.bottom, 25)
                    Text("Welcome To GPA Calculator")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 19)
                        .padding(.horizontal, 57)
                    Text("Compute SHSID GPAs instantly and accurately")
                        .font(.system(size: 22, weight: .medium, design: .default))
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 50)
                }
                
                Spacer() // Creates empty space

                // The "Continue" button triggers the navigation action, taking the user to the next view.
                Button {
                    vibrate(.medium)
                    navAction = 1
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 31)
                            .foregroundColor(.init("ContinueButtonBackground"))
                        Text("Continue")
                            .font(.system(size: 24, weight: .medium, design: .default))
                            .foregroundColor(.init("ContinueButtonText"))
                    }.frame(width: 196, height: 62)
                }.padding(.bottom, 72)
                .buttonStyle(nilButtonStyle())
            }
            .navigationBarHidden(true)
            .frame(maxWidth: .greatestFiniteMagnitude)
            .background(Color.init("AntiPrimary"))
        }.navigationViewStyle(.stack)
    }
}

// This struct provides a preview of the `WelcomeView` in Xcode's design canvas.
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(appSingleton: .init(loadSave: false))
    }
}
