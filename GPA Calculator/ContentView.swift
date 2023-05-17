//
//  ContentView.swift
//  GPA Calculator
//
//  Created by Michel Guo on 2021/12/30.
//

import SwiftUI

struct CapsuleButton: View {
    var text: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.init("Top Buttons"))
            Text(text)
                .font(.system(size: 17, weight: .medium, design: .default))
                .foregroundColor(.primary)
        }.frame(width: 143, height: 40)
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


struct SubjectDataInputView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var appSingleton: AppSingleton
    var name: SizeDependentString
    var subject: Subject
    var subjectIndex: Int
    var subjectTitleWidth: CGFloat?
    
    var body: some View {
        VStack(spacing: 19) {
            HStack(spacing:0) {
                Text((horizontalSizeClass == .regular ? name.regular : name.compact))
                    .fixedSize()
                    .font(.system(size: 22, weight: .regular, design: .default))
                    .background(GeometryReader {geometry in
                        Color.clear.preference(key: MaxWidthPreferenceKey.self, value: geometry.size.width)
                    }).frame(width: subjectTitleWidth, alignment: .leading)
                Spacer()
                SegmentedControlView(items: subject.getLevelNames(), selectedIndex: .init(get: {
                    appSingleton.userInput[appSingleton.appliedPresetIndex][subjectIndex].levelIndex
                }, set: { val in
                    vibrate(.light)
                    appSingleton.userInput[appSingleton.appliedPresetIndex][subjectIndex].levelIndex=val
                    appSingleton.computeGPA()
                })).frame(maxWidth: (appSingleton.currentPreset.useSmallLevelDisplay ? 170 : (horizontalSizeClass == .regular ? 470 : 265)))
                
            }
            Picker(selection: .init(get: {
                appSingleton.userInput[appSingleton.appliedPresetIndex][subjectIndex].scoreIndex
            }, set: { x in
                vibrate(.light)
                appSingleton.userInput[appSingleton.appliedPresetIndex][subjectIndex].scoreIndex=x
                appSingleton.computeGPA()
            })) {
                ForEach((0..<subject.scoreToBaseGPAMap.count), id:\.self) { subjectIndex2 in
                    let currentScoreToBaseGPAMapItem = subject.scoreToBaseGPAMap[subjectIndex2]
                    Text(appSingleton.nameMode == .percentage ? currentScoreToBaseGPAMapItem.percentageName : currentScoreToBaseGPAMapItem.letterName).tag(subjectIndex2)
                }
            } label: {
                EmptyView()
            }.pickerStyle(SegmentedPickerStyle())
        }.frame(height: 114)
        .padding(.horizontal,11)
    }
    
}

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @StateObject var appSingleton: AppSingleton
    @State var navAction:Int? = 0
    @State var viewInitialized = false
    @State var subjectTitleWidth: CGFloat?
    
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
                            NavigationLink(
                                destination: CustomizeView(nameMode: $appSingleton.nameMode, appSingleton: appSingleton),tag: 1,selection: $navAction,
                                label: {
                                    EmptyView()
                                })
                            HStack(alignment: .center, spacing: 26) {
                                Button {
                                    navAction=1
                                    vibrate(.medium)
                                } label: {
                                    CapsuleButton(text: "Customize")
                                }.buttonStyle(nilButtonStyle())
                                Button {
                                    appSingleton.resetUserCourseInput()
                                    vibrate(.medium)
                                } label: {
                                    CapsuleButton(text: "Reset")
                                }.buttonStyle(nilButtonStyle())
                            }.frame(height: 70)
                            
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
