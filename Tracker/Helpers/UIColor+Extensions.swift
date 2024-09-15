import UIKit

extension UIColor {
    convenience init?(hex: String) {
        var cleanedHexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cleanedHexString.hasPrefix("#") {
            cleanedHexString.remove(at: cleanedHexString.startIndex)
        }
        
        guard cleanedHexString.count == 6 else {
            return nil
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cleanedHexString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
    
    func toHex() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb: Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255)
        
        return String(format: "#%06X", rgb).uppercased()
    }
}
