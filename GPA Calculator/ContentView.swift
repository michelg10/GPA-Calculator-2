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

struct SubjectCell: View {
    var subject: Subject
    @Binding var levelIndex: Int
    @Binding var scoreIndex: Int
    var nameMode: NameMode
    var body: some View {
        VStack(spacing: 19) {
            HStack(spacing:0) {
                Text(subject.name)
                    .frame(width: 124, alignment: .leading)
                    .font(.system(size: 22, weight: .regular, design: .default))
                Picker(selection: $levelIndex) {
                    ForEach((0...subject.levels.count-1), id:\.self) { index in
                        Text(subject.levels[index].name).tag(index)
                    }
                } label: {
                    EmptyView()
                }.pickerStyle(SegmentedPickerStyle())
            }
            Picker(selection: $scoreIndex) {
                ForEach((0...subject.scoreToBaseGPAMap.count-1), id:\.self) { index in
                    let currentScoreToBaseGPAMapItem = subject.scoreToBaseGPAMap[index]
                    Text(nameMode == .percentage ? currentScoreToBaseGPAMapItem.percentageName : currentScoreToBaseGPAMapItem.letterName).tag(index)
                }
            } label: {
                EmptyView()
            }.pickerStyle(SegmentedPickerStyle())
        }.frame(height: 114)
        .padding(.horizontal,11)
    }
}

struct ContentView: View {
    @ObservedObject var appSingleton: AppSingleton
    var body: some View {
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
                        HStack(alignment: .center, spacing: 26) {
                            Button {
                                
                            } label: {
                                CircularButton(text: "Customize")
                            }.buttonStyle(nilButtonStyle())
                            Button {
                                
                            } label: {
                                CircularButton(text: "Reset")
                            }.buttonStyle(nilButtonStyle())
                        }.frame(height: 70)
                        let subjects = appSingleton.currentPreset.getSubjects()
                        ForEach((0...subjects.count-1), id:\.self) { index in
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.init("Separator"))
                            SubjectCell(subject: subjects[index], levelIndex: $appSingleton.userInput[index].levelIndex, scoreIndex: $appSingleton.userInput[index].scoreIndex, nameMode: appSingleton.nameMode)
                        }
                    }
                }
            }.cornerRadius(14)
        }.padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appSingleton: .init())
    }
}
