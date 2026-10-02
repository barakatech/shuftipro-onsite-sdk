import Flutter
import UIKit
import ShuftiPro
var window:UIWindow?

public class SwiftShuftiproSdk:  NSObject, FlutterPlugin{
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.example.package_sample/sendAndroid", binaryMessenger: registrar.messenger())
        let instance = SwiftShuftiproSdk()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    /*
     * This method is initiated when a call from bridging class is made
     * This function then modifies the data type of received parameters and calls the sdk
     * The response received in this method is then forwarded to bridging class
     * */
    private func resolveFlutterViewController() -> FlutterViewController? {
        var root_vc: UIViewController?
        
        if #available(iOS 13.0, *) {
            // Scene-based lifecycle: find the key window owned by the active foreground scene
            let key_window = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })
            root_vc = key_window?.rootViewController
        }
        
        // Fallback: AppDelegate-owned window (non-scene apps or iOS < 13)
        if root_vc == nil {
            root_vc = UIApplication.shared.delegate?.window??.rootViewController
        }
        
        // Unwrap common container controllers to reach the FlutterViewController
        if let nav = root_vc as? UINavigationController {
            root_vc = nav.topViewController
        } else if let tab = root_vc as? UITabBarController {
            root_vc = tab.selectedViewController
        }
        
        return root_vc as? FlutterViewController
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "sendRequest" :
            guard let args = call.arguments as? Dictionary<String , Any> else {return}
            
            let requestObject = args["RequestObj"] as? Dictionary<String , Any>
            let authObject = args["AuthObj"] as? Dictionary<String , String>
            var configs = args["ConfigObj"] as? Dictionary<String ,Any>
            configs?["platform"] = "flutter"
            configs?["flutter_version"] = "1.0.23"
            let fontColor = configs?["font_color"] as? String
            let buttonColor = configs?["button_text_color"] as? String
            let buttonBgColor = configs?["button_background_color"] as? String
            
            guard let controller = resolveFlutterViewController() else {
                result(FlutterError(
                    code: "NO_VIEW_CONTROLLER",
                    message: "Could not resolve FlutterViewController. The app window may not be fully initialised.",
                    details: nil
                ))
                return
            }
            
            let instance = Shufti()
            
            var response : Dictionary<String, Any>!
            instance.shuftiProVerification(requestObject: requestObject!, authKeys: authObject!, parentVC:controller , configs: configs) { (response) in
                
                if let output = self.convertDictionaryToJSON(response as! [String : Any]) {
                    result(output.description);
                }
                
            }
            
        case "registerRequest":
            guard let args = call.arguments as? Dictionary<String , Any> else {return}
            
            var clientId = args["clientIdObj"] as? String
            var customerID = args["customerIdObj"] as? String
            var configs = args["ConfigObj"] as? Dictionary<String ,Any>
            
            let instance = Shufti()
            
            var response : Dictionary<String, Any>!
            instance.register(clientID: clientId!, customerID: customerID!, configs: configs) { response in
                if let output = self.convertDictionaryToJSON(response as! [String : Any]) {
                    result(output.description);
                }
            }
            
        default :
            result(FlutterMethodNotImplemented)
        }
    }
    
    func convertDictionaryToJSON(_ dictionary: [String: Any]) -> String? {
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
            print("Something went wrong while converting dictionary to JSON data.")
            return nil
        }
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Something went wrong while converting JSON data to JSON string.")
            return nil
        }
        
        return jsonString
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
}
