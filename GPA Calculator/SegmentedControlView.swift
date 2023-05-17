//
//  SegmentedControlView.swift
//  GPA Calculator
//
//  Created by Michel Guo on 2022/1/12.
//

import Foundation
import SwiftUI

#if !os(macOS)
struct SegmentedControlView: UIViewRepresentable {
    var items: [String]
    @Binding var selectedIndex: Int
    
    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        uiView.selectedSegmentIndex = selectedIndex
    }
    
    func makeUIView(context: Context) -> UISegmentedControl {
        let view = UISegmentedControl(items: items)
        view.apportionsSegmentWidthsByContent = true
        view.selectedSegmentIndex = selectedIndex
        for i in 0 ..< items.count {
            view.setAction(UIAction(title: items[i]) { (action) in
                selectedIndex = i
            }, forSegmentAt: i)
        }
        return view
    }
}
#endif

#if os(macOS)
struct SegmentedControlView: View {
    var items: [String]
    @Binding var selectedIndex: Int
    
    var body: some View {
        Picker(selection: $selectedIndex) {
            ForEach((0..<items.count), id:\.self) { index in
                Text(items[index]).tag(index)
            }
        } label: {
            EmptyView()
        }.pickerStyle(SegmentedPickerStyle())

    }
}
#endif


struct SegmentedControlView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedControlView(items: ["item one", "item 2"], selectedIndex: .constant(0))
    }
}
