//
//  TimeManager.swift
//  MultiPicker
//
//  Created by Heiner Gerdes on 18.06.21.
//

import Foundation

extension HourPicker{
    internal struct HourTimeManager{
        
        /// Converts hour and minute components as Int values [hh, mm] into hours as decimal value (e.g [2, 30] -> 2.5)
        /// - Parameter components: Hours and minutes as Int values [hh, mm] or [-hh, mm]
        internal static func components2Hours(components: [Int]) -> Double{
            var _components: [Int] = []
            if components[0] < .zero{
                _components = [components[0], -components[1]]
            }else {
                _components = components
            }
            let componentsString        : String    = "\(String(format: "%02d", _components[0])).\(String(format: "%02d",_components[1]))"
            let componentsStringParts   : [String]  = (componentsString.components(separatedBy: "."))
            let hoursPart               : Double    = Double(componentsStringParts[0])!
            let minutesPart             : Double    = (Double(componentsStringParts[1])!) / 60
            let hours                   : Double    = hoursPart + minutesPart
            return hours
        }
        
        /// Returns the hour value of a decimal hours value (as positive Int)
        ///
        /// - Warning:
        ///  The value is always positive!!
        ///
        /// # Example Code:
        /// ```
        /// let value: Double = 8.5
        /// getHours(value) // 8
        ///
        /// let value: Double = -8.5
        /// getHours(value) // 8
        /// ```
        ///
        internal static func getHours(_ decimalHours: Double) -> Int{
            return Int(abs(decimalHours))
        }
        
        /// Returns the minutes value of a decimal hours value (as positive Int)
        ///
        /// - Warning:
        ///  The value is always positive!!
        ///
        /// # Example Code:
        /// ```
        /// let value: Double = 8.5
        /// getMinutes(value) // 30
        ///
        /// let value: Double = -8.5
        /// getMinutes(value) // 30
        /// ```
        ///
        internal static func getMinutes(_ decimalHours: Double) -> Int{
            // rounds considering the first three decimal places and cuts to the second decimal place
            //.rounded() uses only the first decimal place. 100 defines the considered overall decimal places
            let hoursRounded: Double =  (decimalHours * 100).rounded() / 100
            // converts to a string (cut to two decimal places)
            let hoursString: String = String(format: "%.2f",hoursRounded)
            // seperates min parts
            let hoursStringParts: [String] = hoursString.components(separatedBy: ".")
            let minutesDouble: Double = (Double(hoursStringParts[1])!) * 0.6
            return Int(minutesDouble.rounded())
        }
    }
}
