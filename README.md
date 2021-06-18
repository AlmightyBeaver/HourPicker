# HourPicker

An expandable SwiftUI hour picker for positive and negative hours.

 
### Example
 ```
 struct HourPickerExample: View {
     @State var hours = 2.3
     @State var isDecimalTimeFormatUsed: Bool = false

     var body: some View {
         Form{
             Toggle("Decimal Time", isOn: $isDecimalTimeFormatUsed)
             Button(action: {
                 if hours == 2.3{
                     hours = -15.8
                 }else {
                     hours = 2.3
                 }
             }) {
                 Text("Change hours externally")
             }.buttonStyle(BorderlessButtonStyle())
             HourPicker(hours: $hours,
                        title: "Title",
                        captionTitle: "Caption text here",
                        maxHours: 30,
                        isDecimalTimeFormatUsed: isDecimalTimeFormatUsed)
             Text("Value: \(hours)")
         }
     }
 }
```
