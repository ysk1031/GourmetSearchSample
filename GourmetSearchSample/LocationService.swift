import Foundation
import UIKit
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    let LSAuthDeniedNotification = "LSAuthDeniedNotification"
    let LSAuthRestrictedNotification = "LSAuthRestrictedNotification"
    let LSAuthorizedNotification = "LSAuthorizedNotification"
    let LSDidUpdateLocationNotification = "LSDidUpdateLocationNotification"
    let LSDidFailLocationNotification = "LSDidFailLocationNotification"
    
    let cllm = CLLocationManager()
    let nsnc = NSNotificationCenter.defaultCenter()
    
    var locationServiceDisabledAlert: UIAlertController {
        get {
            let alert = UIAlertController(title: "位置情報が取得できません",
                message: "設定からプライバシー → 位置情報画面を開いてGourmetSearchの位置情報の許可を「このAppの使用中のみ許可」と設定してください。",
                preferredStyle: .Alert
            )
            alert.addAction(
                UIAlertAction(title: "閉じる", style: .Cancel, handler: nil)
            )
            return alert
        }
    }
    
    var locationServiceRestrictedAlert: UIAlertController {
        get {
            let alert = UIAlertController(title: "位置情報が取得できません",
                message: "設定から一般 → 機能制限画面を開いてGourmetSearchが位置情報を使用できる設定にしてください。",
                preferredStyle: .Alert
            )
            alert.addAction(
                UIAlertAction(title: "閉じる", style: .Cancel, handler: nil)
            )
            return alert
        }
    }
    
    var locationServiceDidFailAlert: UIAlertController {
        get {
            let alertView = UIAlertController(title: nil, message: "位置情報の取得に失敗しました。", preferredStyle: .Alert)
            alertView.addAction(
                UIAlertAction(title: "OK", style: .Default, handler: nil)
            )
            return alertView
        }
    }
    
    override init() {
        super.init()
        cllm.delegate = self
    }
    
    
    // MARK: - CLLocationManager delegate
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            cllm.requestWhenInUseAuthorization()
        case .Restricted:
            nsnc.postNotificationName(LSAuthRestrictedNotification, object: nil)
        case .Denied:
            nsnc.postNotificationName(LSAuthDeniedNotification, object: nil)
        case .AuthorizedWhenInUse:
            break;
        default:
            break;
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        cllm.stopUpdatingLocation()
        if let location = locations.last as? CLLocation {
            nsnc.postNotificationName(LSDidUpdateLocationNotification,
                object: self,
                userInfo: ["location": location]
            )
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        nsnc.postNotificationName(LSDidFailLocationNotification, object: nil)
    }
    
    // MARK: - Application logic
    func startUpdatingLocation() {
        cllm.startUpdatingLocation()
    }
    
}