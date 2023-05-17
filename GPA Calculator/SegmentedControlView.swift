import Foundation
import SwiftUI

#if !os(macOS)
// `SegmentedControlView` for iOS uses `UIViewRepresentable` to create a native UIKit `UISegmentedControl`.
// It's used instead of SwiftUI's `Picker` to ensure efficient use of space in a limited-size iPhone environment.
struct SegmentedControlView: UIViewRepresentable {
    var items: [String] // The titles of each segment.
    @Binding var selectedIndex: Int // The index of the currently selected segment.
    
    // Updates the `UISegmentedControl` view with the latest `selectedIndex`.
    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        uiView.selectedSegmentIndex = selectedIndex
    }
    
    // Creates the `UISegmentedControl` view.
    func makeUIView(context: Context) -> UISegmentedControl {
        let view = UISegmentedControl(items: items)
        view.apportionsSegmentWidthsByContent = true // Makes the segments' width dependent on their content.
        view.selectedSegmentIndex = selectedIndex
        for i in 0 ..< items.count {
            // Sets the action for each segment to update the `selectedIndex` when that segment is selected.
            view.setAction(UIAction(title: items[i]) { (action) in
                selectedIndex = i
            }, forSegmentAt: i)
        }
        return view
    }
}
#endif

#if os(macOS)
// `SegmentedControlView` for macOS uses SwiftUI's `Picker` with a `SegmentedPickerStyle`.
struct SegmentedControlView: View {
    var items: [String] // The titles of each segment.
    @Binding var selectedIndex: Int // The index of the currently selected segment.
    
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
