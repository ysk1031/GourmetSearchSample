import UIKit
import MapKit

class ShopMapDetailViewController: UIViewController {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var showHereButton: UIBarButtonItem!
    
    let ls = LocationService()
    let nc = NSNotificationCenter.defaultCenter()
    var observers = [NSObjectProtocol]()
    var shop = Shop()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let lat = shop.lat {
            if let lon = shop.lon {
                let cllc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let mkcr = MKCoordinateRegionMakeWithDistance(cllc, 500, 500)
                map.setRegion(mkcr, animated: false)
                
                let pin = MKPointAnnotation()
                pin.coordinate = cllc
                pin.title = shop.name
                map.addAnnotation(pin)
            }
        }
        
        self.navigationItem.title = shop.name
    }
    
    override func viewWillAppear(animated: Bool) {
        observers.append(
            nc.addObserverForName(
                ls.LSAuthDeniedNotification,
                object: nil,
                queue: nil,
                usingBlock: { notification in
                    self.presentViewController(self.ls.locationServiceDisabledAlert, animated: true, completion: nil)
                    self.showHereButton.enabled = false
                }
            )
        )
        observers.append(
            nc.addObserverForName(
                ls.LSAuthRestrictedNotification,
                object: nil,
                queue: nil,
                usingBlock: { notification in
                    self.presentViewController(self.ls.locationServiceRestrictedAlert, animated: true, completion: nil)
                    self.showHereButton.enabled = false
                }
            )
        )
        observers.append(
            nc.addObserverForName(
                ls.LSDidFailLocationNotification,
                object: nil,
                queue: nil,
                usingBlock: { notification in
                    self.presentViewController(self.ls.locationServiceDidFailAlert, animated: true, completion: nil)
                    self.showHereButton.enabled = false
                }
            )
        )
        observers.append(
            nc.addObserverForName(
                ls.LSDidUpdateLocationNotification,
                object: nil,
                queue: nil,
                usingBlock: { notification in
                    if let userInfo = notification.userInfo as? [String: CLLocation] {
                        if let clloc = userInfo["location"] {
                            if let lat = self.shop.lat {
                                if let lon = self.shop.lon {
                                    let center = CLLocationCoordinate2D(
                                        latitude: (lat + clloc.coordinate.latitude) / 2,
                                        longitude: (lon + clloc.coordinate.longitude) / 2
                                    )
                                    let diff = (
                                        lat: abs(clloc.coordinate.latitude - lat),
                                        lon: abs(clloc.coordinate.longitude - lon)
                                    )
                                    
                                    let mkcs = MKCoordinateSpanMake(diff.lat * 1.4, diff.lon * 1.4)
                                    let mkcr = MKCoordinateRegionMake(center, mkcs)
                                    println(mkcr)
                                    self.map.setRegion(mkcr, animated: true)
                                    
                                    self.map.showsUserLocation = true
                                }
                            }
                        }
                    }
                    self.showHereButton.enabled = true
                }
            )
        )
        observers.append(
            nc.addObserverForName(
                ls.LSAuthorizedNotification,
                object: nil,
                queue: nil,
                usingBlock: { notification in
                    self.showHereButton.enabled = true
                }
            )
        )
    }
    
    override func viewWillDisappear(animated: Bool) {
        for observer in observers {
            nc.removeObserver(observer)
        }
        observers = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func showHereButtonTapped(sender: UIBarButtonItem) {
        ls.startUpdatingLocation()
    }

}
