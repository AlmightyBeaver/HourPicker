//
//  HourPicker.swift
//  MultiPicker
//
//  Created by Heiner Gerdes on 18.06.21.
//

import SwiftUI
import MultiPicker

#if os(iOS)
/// An expandable SwiftUI hour picker for positive and negative hours.
///
/// # Example
/// ```
/// struct HourPickerExample: View {
///     @State var hours = 2.3
///     @State var isDecimalTimeFormatUsed: Bool = false
///
///     var body: some View {
///         Form{
///             Toggle("Decimal Time", isOn: $isDecimalTimeFormatUsed)
///             Button(action: {
///                 if hours == 2.3{
///                     hours = -15.8
///                 }else {
///                     hours = 2.3
///                 }
///             }) {
///                 Text("Change hours externally")
///             }.buttonStyle(BorderlessButtonStyle())
///             HourPicker(hours: $hours,
///                        title: "Title",
///                        captionTitle: "Caption text here",
///                        maxHours: 30,
///                        isSignPickerVisible: true,
///                        isDecimalTimeFormatUsed: isDecimalTimeFormatUsed)
///             Text("Value: \(hours)")
///         }
///     }
/// }
/// ```
@available(iOS 14, *)
public struct HourPicker: View {
    typealias TM = HourPicker.HourTimeManager
    /// The height of the HourPicker view
    private(set) var height: CGFloat = 200
    /// Indicator if the title view is visible
    private var isTitleViewVisible: Bool
    /// Indicator if decimal time format (e.g. 2.5h instead of 2h 30min ) is used
    private var isDecimalTimeFormatUsed: Bool
    /// Indicator if the picker for the sign selection is visible
    private var isSignPickerVisible: Bool
    
    
    /// Maximum selectable hour
    private let maxHours: Int
    /// All possible sign values e.g. ["+", "-"]
    private var signValues: [String]
    /// All possible hour values e.g [0, 1, ..., 23]
    private var hourValues: [Int]
    /// All possible minute values [0, 1, ..., 59]
    private var minuteValues: [Int]
    
    /// Indicator if the hours change is triggered from external
    @State private var isExternalChange: Bool = false
    /// The hours value in decimal format (e.g. 8.25h) for external use
    @Binding private var hoursExternal: Double
    /// The hours value in decimal format (e.g. 8.25h) for internal use
    @State private var hoursInternal: Double
    /// The selected index of the sign picker component
    @State private var selectedSignIndex: Int
    /// The selected index of the hour picker component
    @State private var selectedHourIndex: Int
    /// The selected index of the minute picker component
    @State private var selectedMinuteIndex: Int
    
    
    /// The title of the title view
    private var title: LocalizedStringKey
    /// The caption title of the title view
    private var captionTitle: LocalizedStringKey
    /// Indicator if the title view is expanded
    @State private var isExpanded: Bool = false
    
    
    
    
    /// SwiftUI hour picker for positive and negative hours.
    ///
    /// - Parameters:
    ///   - hours: The hours value in decimal format (e.g. 8.25h)
    ///   - title: The title
    ///   - captionTitle: The caption
    ///   - maxHours: Maximum selectable hour
    ///   - isSignPickerVisible: Indicator if the picker for the sign selection is visible
    ///   - isDecimalTimeFormatUsed: Indicator if decimal time format (e.g. 2.5h instead of 2h 30min ) is used
    public init(hours: Binding<Double>,
                title: LocalizedStringKey,
                captionTitle: LocalizedStringKey,
                maxHours: Int = 23,
                isSignPickerVisible: Bool = true,
                isDecimalTimeFormatUsed: Bool) {
        self.isTitleViewVisible = true
        self.title = title
        self.captionTitle = captionTitle
        self.maxHours = maxHours
        self.hourValues = Array(0...maxHours)
        let timeStep = 1
        self.minuteValues = Array(stride(from: 0, through: 59, by: timeStep))
        self.isSignPickerVisible = isSignPickerVisible
        self.isDecimalTimeFormatUsed = isDecimalTimeFormatUsed
        
        self._hoursExternal = hours
        self._hoursInternal = State(wrappedValue: hours.wrappedValue)
        self.signValues = ["+", "-"]
        let signIndex: Int = hours.wrappedValue.sign == .plus ? 0 : 1
        self._selectedSignIndex = State(wrappedValue: signIndex)
        self._selectedHourIndex = State(wrappedValue: TM.getHours(hours.wrappedValue))
        self._selectedMinuteIndex = State(wrappedValue: TM.getMinutes(hours.wrappedValue))
    }
    
    
    
    public var body: some View {
        Group{
            VStack{
                if isTitleViewVisible{
                    HourPicker.TitleViewButton(title: self.title,
                                               captionTitle: self.captionTitle,
                                               decimalHours: self.hoursInternal,
                                               hourTextColor: self.isExpanded ? .accentColor : .accentColor,
                                               isDecimalTimeFormatUsed: self.isDecimalTimeFormatUsed){
                        self.isExpanded.toggle()
                    }
                    if self.isExpanded{
                        multiPicker
                    }
                }else{
                    multiPicker
                }
            }
            .animation(.spring())
        }
        
        .onChange(of: self.hoursExternal, perform: { _ in
            if !self.isExternalChange{
                self.isExternalChange = true
                if self.hoursInternal != self.hoursExternal{
                    // when hours change was externally triggered
                    self.hoursInternal = self.hoursExternal
                }else{
                    // when hour change was internally triggered
                    self.isExternalChange = false
                }
            }
        })
        .onChange(of: self.hoursInternal, perform: { _ in
            if self.isExternalChange{ // when hours change was externally triggered
                self.selectedSignIndex = hoursInternal.sign == .plus ? 0 : 1
                self.selectedHourIndex = TM.getHours(hoursInternal)
                self.selectedMinuteIndex = TM.getMinutes(hoursInternal)
                self.isExternalChange = false
            }else{ // when hour change was internally triggered
                self.hoursExternal = self.hoursInternal
            }
        })
        .onChange(of: self.selectedSignIndex, perform: { _ in
            setInternalHoursFromIndex()
        })
        .onChange(of: self.selectedHourIndex, perform: { _ in
            setInternalHoursFromIndex()
        })
        .onChange(of: self.selectedMinuteIndex, perform: { _ in
            setInternalHoursFromIndex()
        })
        
    }
    
    /// Set `hoursInternal` (and indirect `hoursExternal`) to index values, when the index changes were internally triggerd
    private func setInternalHoursFromIndex() {
        if !isExternalChange{ // when index change was internally triggered
            if self.selectedSignIndex == 0{ // positve
                hoursInternal = TM.components2Hours(components: [selectedHourIndex, selectedMinuteIndex])
            }else { // negative
                hoursInternal = (TM.components2Hours(components: [selectedHourIndex, selectedMinuteIndex]) * -1)
            }
        }
    }
    
    // The MultiPicker component to select the hours
    private var multiPicker: MultiPicker{
        if self.isSignPickerVisible{
            return MultiPicker(selection1: self.$selectedSignIndex,
                               selection2: self.$selectedHourIndex,
                               selection3: self.$selectedMinuteIndex,
                               values1: self.signValues,
                               values2: self.hourValues,
                               values3: self.minuteValues,
                               values2Suffix: "h",
                               values3Suffix: "m")
        }else{
            return MultiPicker(selection1: self.$selectedHourIndex,
                               selection2: self.$selectedMinuteIndex,
                               values1: self.hourValues,
                               values2: self.minuteValues,
                               values1Suffix: "h",
                               values2Suffix: "m")
        }
    }
    
}
#endif

#if os(iOS)
@available(iOS 14, *)
extension HourPicker{
    
    /// The title view button of the hour picker
    internal struct TitleViewButton: View{
        typealias TM = HourPicker.HourTimeManager
        /// The title
        var title: LocalizedStringKey
        /// The caption title
        var captionTitle: LocalizedStringKey
        /// The hour in decimal form (e.g. 2.5)
        let decimalHours: Double
        /// The color of the text that shows the hour value
        let hourTextColor: Color
        /// Indicator if decimal time format (e.g. 2.5h instead of 2h 30min ) is used
        var isDecimalTimeFormatUsed: Bool
        /// The action to perform when the user triggers the button.
        let action: () -> Void
        
        
        var body: some View {
            Button(action: {
                action()
            }) {
                HStack{
                    HourPicker.TitleTextView(titleText: self.title,
                                             captionText: self.captionTitle)
                    Spacer()
                    if isDecimalTimeFormatUsed{
                        Text("\(String(format: "%.2f", decimalHours))h")
                            .foregroundColor(hourTextColor)
                    }else {
                        HStack{
                            Text("\(decimalHours.sign == .minus ? "-" : "")")
                            Text("\(TM.getHours(decimalHours))h")
                            Text("\(TM.getMinutes(decimalHours))m")
                        }
                        .foregroundColor(hourTextColor)
                    }
                }
                .foregroundColor(.primary)
            }.buttonStyle(BorderlessButtonStyle())
        }
    }
    
    /// A view with title and caption text
    internal struct TitleTextView: View {
        /// The title text
        var titleText: LocalizedStringKey
        /// The caption text
        var captionText: LocalizedStringKey
        
        var body: some View {
            VStack {
                HStack {
                    Text(titleText)
                        .foregroundColor(.primary)
                    Spacer()
                }
                HourPicker.CaptionTextView(captionText: captionText)
            }
        }
    }
    
    
    /// The caption text of the `TitleTextView`
    internal struct CaptionTextView: View {
        /// The caption text
        var captionText: LocalizedStringKey
        
        var body: some View {
            HStack {
                Text(captionText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }
}
#endif




//MARK: - Preview
#if os(iOS)
@available(iOS 14, *)
internal struct HourPicker_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            HourPicker(hours: .constant(25.4),
                       title: "Title",
                       captionTitle: "Caption text",
                       maxHours: 30,
                       isSignPickerVisible: true,
                       isDecimalTimeFormatUsed: false)
            HourPicker(hours: .constant(-25.4),
                       title: "Title",
                       captionTitle: "Caption text",
                       maxHours: 30,
                       isSignPickerVisible: true,
                       isDecimalTimeFormatUsed: true)
            HourPicker(hours: .constant(25.4),
                       title: "Title",
                       captionTitle: "Caption text",
                       maxHours: 30,
                       isSignPickerVisible: false,
                       isDecimalTimeFormatUsed: false)
        }
    }
}
#endif
