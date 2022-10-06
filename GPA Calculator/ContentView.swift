//
//  ContentView.swift
//  GPA Calculator
//
//  Created by Michel Guo on 2021/12/30.
//

import SwiftUI

struct CircularButton: View {
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

private extension ContentView {
    struct SubjectTitleSizeKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        
        static func reduce(value: inout CGFloat,
                           nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}

struct ContentView: View {
    @ObservedObject var appSingleton: AppSingleton
    @State var navAction:Int? = 0
    @State private var subjectTitleWidth: CGFloat?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var viewInit = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing:0) {
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
                                    CircularButton(text: "Customize")
                                }.buttonStyle(nilButtonStyle())
                                Button {
                                    appSingleton.resetUserCourseInput()
                                    vibrate(.medium)
                                } label: {
                                    CircularButton(text: "Reset")
                                }.buttonStyle(nilButtonStyle())
                            }.frame(height: 70)
                            let subjects = appSingleton.currentPreset.getSubjects()
                            
                            ForEach((0..<subjects.count), id:\.self) { index in
                                let typedIndex: Int = index
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.init("Separator"))
                                    .padding(.leading, index == 0 ? 0 : 25)
                                
                                let subject=subjects[index]
                                let userNameChoiceIndex=appSingleton.userNameChoiceIndex[appSingleton.appliedPresetIndex][index]
                                
                                VStack(spacing: 19) {
                                    HStack(spacing:0) {
                                        let name=userNameChoiceIndex == -1 ? subject.name : subject.alternateNames![userNameChoiceIndex]
                                        Text((horizontalSizeClass == .regular ? name.regular : name.compact))
                                            .fixedSize()
                                            .font(.system(size: 22, weight: .regular, design: .default))
                                            .background(GeometryReader {geometry in
                                                Color.clear.preference(key: SubjectTitleSizeKey.self, value: geometry.size.width)
                                            }).frame(width: subjectTitleWidth, alignment: .leading)
                                        Spacer()
                                        SegmentedControlView(items: subject.getLevelNames(), selectedIndex: .init(get: {
                                            appSingleton.userInput[appSingleton.appliedPresetIndex][typedIndex].levelIndex
                                        }, set: { val in
                                            vibrate(.light)
                                            appSingleton.userInput[appSingleton.appliedPresetIndex][typedIndex].levelIndex=val
                                            appSingleton.computeGPA()
                                        })).frame(maxWidth: (appSingleton.currentPreset.useSmallLevelDisplay ? 170 : (horizontalSizeClass == .regular ? 470 : 265)))
                                        
                                    }
                                    Picker(selection: .init(get: {
                                        appSingleton.userInput[appSingleton.appliedPresetIndex][typedIndex].scoreIndex
                                    }, set: { x in
                                        vibrate(.light)
                                        appSingleton.userInput[appSingleton.appliedPresetIndex][typedIndex].scoreIndex=x
                                        appSingleton.computeGPA()
                                    })) {
                                        ForEach((0..<subject.scoreToBaseGPAMap.count), id:\.self) { index2 in
                                            let currentScoreToBaseGPAMapItem = subject.scoreToBaseGPAMap[index2]
                                            Text(appSingleton.nameMode == .percentage ? currentScoreToBaseGPAMapItem.percentageName : currentScoreToBaseGPAMapItem.letterName).tag(index2)
                                        }
                                    } label: {
                                        EmptyView()
                                    }.pickerStyle(SegmentedPickerStyle())
                                }.frame(height: 114)
                                    .padding(.horizontal,11)
                            }.id(appSingleton.currentPreset.id)
                        }
                    }
                }.cornerRadius(14)
            }.padding(.horizontal, 7)
                .padding(.bottom, 20)
                .navigationBarHidden(true)
                .onAppear {
                    if viewInit {
                        appSingleton.applySelection()
                        vibrate(.medium)
                    }
                    viewInit=true
                }
                .background(Color.init("AntiPrimary"))
        }
        .navigationViewStyle(.stack)
        .onPreferenceChange(SubjectTitleSizeKey.self) {
            subjectTitleWidth = $0
        }.navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appSingleton: .init(loadSave: false))
    }
}
