import SwiftUI

// `CapsuleButton` is a reusable view that displays a button with a rounded rectangle (capsule-like) shape.
struct CapsuleButton: View {
    var text: String // The text displayed in the button.

    var body: some View {
        ZStack {
            // The capsule-shaped background of the button.
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.init("Top Buttons"))
            
            // The text displayed in the button.
            Text(text)
                .font(.system(size: 17, weight: .medium, design: .default))
                .foregroundColor(.primary)
        }
        // The fixed size of the button.
        .frame(width: 143, height: 40)
    }
}

// MaxWidthPreferenceKey is a PreferenceKey.
// SwiftUI uses PreferenceKey types to read values from views in the hierarchy that set a preference.
struct MaxWidthPreferenceKey: PreferenceKey {
    // The default value if no other value is provided.
    static let defaultValue: CGFloat = 0
    
    // This function is called by SwiftUI to combine multiple values if they exist.
    // In our case, it keeps the maximum width value.
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// `SubjectDataInputView` is a SwiftUI View representing an individual subject's data input components.
struct SubjectDataInputView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    // A singleton instance managing application-wide data.
    var appSingleton: AppSingleton
    
    // `name` is a size-dependent string, providing different text based on the device's horizontal size class.
    var name: SizeDependentString
    
    // The specific `Subject` instance this view is associated with.
    var subject: Subject
    
    // The index of the subject in the global subjects list.
    var subjectIndex: Int
    
    // The width of the subject title text, set externally to match the widest title among all subjects.
    var subjectTitleWidth: CGFloat?

    var body: some View {
        VStack(spacing: 19) {
            HStack(spacing:0) {
                // The subject's name, displayed as a Text view.
                // The width of this Text view is set by the `subjectTitleWidth` property to be the maximum of all other subject name views.
                Text(name.getStringFor(horizontalUserInterfaceSizeClass: horizontalSizeClass))
                    .fixedSize()
                    .font(.system(size: 22, weight: .regular, design: .default))
                    .background(GeometryReader {geometry in
                        Color.clear.preference(key: MaxWidthPreferenceKey.self, value: geometry.size.width)
                    }).frame(width: subjectTitleWidth, alignment: .leading)
                
                Spacer(minLength: 0)
                
                // A segmented control for selecting the level of the subject.
                // The user's selection is stored in the `AppSingleton` instance.
                SegmentedControlView(items: subject.getLevelNames(), selectedIndex: .init(get: {
                    appSingleton.userInput[appSingleton.appliedPresetIndex][subjectIndex].levelIndex
                }, set: { val in
                    vibrate(.light)
                    appSingleton.userInput[appSingleton.appliedPresetIndex][subjectIndex].levelIndex = val
                    appSingleton.computeGPA()
                })).frame(maxWidth: (appSingleton.currentPreset.useSmallLevelDisplay ? 170 : (horizontalSizeClass == .regular ? 470 : 265)))
            }
            
            // A picker for the subject score.
            // The user's selection is stored in the `AppSingleton` instance.
            Picker(selection: .init(get: {
                appSingleton.userInput[appSingleton.appliedPresetIndex][subjectIndex].scoreIndex
            }, set: { x in
                vibrate(.light)
                appSingleton.userInput[appSingleton.appliedPresetIndex][subjectIndex].scoreIndex=x
                appSingleton.computeGPA()
            })) {
                ForEach((0..<subject.scoreAndBaseGPAPairs.count), id: \.self) { scoreIndex in
                    let currentScoreAndBaseGPAPair = subject.scoreAndBaseGPAPairs[scoreIndex]
                    Text(currentScoreAndBaseGPAPair.score.getName(forMode: appSingleton.nameMode)).tag(scoreIndex)
                }
            } label: {
                EmptyView() // Picker label is empty as it's not needed in this context.
            }.pickerStyle(SegmentedPickerStyle())
        }.frame(height: 114)
        .padding(.horizontal,11)
    }
}

// `ContentView` is the primary view of the application, displaying the GPA calculator interface.
struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @StateObject var appSingleton: AppSingleton // Singleton instance managing global application data.
    @State var navAction:Int? = 0 // Navigation action to trigger a navigation link.
    @State var viewInitialized = false // Flag to check if the view has been initialized.
    @State var subjectTitleWidth: CGFloat? // The width of the subject title text, set to match the widest title among all subjects.

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing:0) {
                // Header
                Text("GPA Calculator")
                    .font(.system(size: 28, weight: .semibold, design: .default))
                    .padding(.top, 25)
                Text("Your GPA: \(appSingleton.currentGPA)")
                    .padding(.bottom, 15)
                
                ScrollView {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .foregroundColor(.init("Background"))
                        VStack(spacing: 0) {
                            // Invisible navigation link triggered by the 'Customize' button.
                            NavigationLink(
                                destination: CustomizeView(nameMode: $appSingleton.nameMode, appSingleton: appSingleton),
                                tag: 1,
                                selection: $navAction,
                                label: {
                                    EmptyView()
                                })
                            
                            HStack(alignment: .center, spacing: 26) {
                                // Button that triggers the navigation to the 'Customize' view.
                                Button {
                                    navAction=1
                                    vibrate(.medium)
                                } label: {
                                    CapsuleButton(text: "Customize")
                                }.buttonStyle(nilButtonStyle())

                                // Button that resets the user's course input.
                                Button {
                                    appSingleton.resetUserCourseInput()
                                    vibrate(.medium)
                                } label: {
                                    CapsuleButton(text: "Reset")
                                }.buttonStyle(nilButtonStyle())
                            }.frame(height: 70)
                            
                            // Create a `SubjectDataInputView` for each subject in the current preset.
                            let subjects = appSingleton.currentPreset.getSubjects()
                            ForEach((0..<subjects.count), id: \.self) { subjectIndex in
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.init("Separator"))
                                    .padding(.leading, subjectIndex == 0 ? 0 : 25)
                                
                                let subject = subjects[subjectIndex]
                                let userNameChoiceIndex = appSingleton.userNameChoiceIndex[appSingleton.appliedPresetIndex][subjectIndex]
                                let name = userNameChoiceIndex == -1 ? subject.name : subject.alternateNames![userNameChoiceIndex]
                                
                                SubjectDataInputView(appSingleton: appSingleton, name: name, subject: subject, subjectIndex: subjectIndex, subjectTitleWidth: subjectTitleWidth)
                                    .onPreferenceChange(MaxWidthPreferenceKey.self) { value in
                                        subjectTitleWidth = max(subjectTitleWidth ?? 0, value)
                                    }
                            }.id(appSingleton.currentPreset.id)
                        }
                    }
                }.cornerRadius(14)
            }.padding(.horizontal, 7)
                .padding(.bottom, 20)
                .navigationBarHidden(true)
                .onAppear {
                    // Recompute the GPA and vibrate the device when the view reappears after initialization.
                    if viewInitialized {
                        appSingleton.recomputeGPA()
                        vibrate(.medium)
                    }
                    viewInitialized=true
                }
                .background(Color.init("AntiPrimary"))
        }
        .navigationViewStyle(.stack)
        .navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appSingleton: .init(loadSave: false))
    }
}
