import UIKit
import MapKit

class ShopDetailViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var nameHeight: NSLayoutConstraint!
    @IBOutlet weak var tel: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var addressContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var favoriteLabel: UILabel!
        
    var shop = Shop()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = shop.photoUrl {
            photo.sd_setImageWithURL(NSURL(string: url),
                placeholderImage: UIImage(named: "loading"),
                options: nil
            )
        } else {
            photo.image = UIImage(named: "loading")
        }
        name.text = shop.name
        tel.text = shop.tel
        address.text = shop.address
        
        if let lat = shop.lat {
            if let lon = shop.lon {
                let cllc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let mkcr = MKCoordinateRegionMakeWithDistance(cllc, 200, 200)
                map.setRegion(mkcr, animated: false)
                
                let pin = MKPointAnnotation()
                pin.coordinate = cllc
                map.addAnnotation(pin)
            }
        }
        
        updateFavoriteButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.scrollView.delegate = self
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.scrollView.delegate = nil
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        let nameFrame = name.sizeThatFits(CGSizeMake(name.frame.size.width, CGFloat.max))
        nameHeight.constant = nameFrame.height
        
        let addressFrame = address.sizeThatFits(CGSizeMake(address.frame.size.width, CGFloat.max))
        addressContainerHeight.constant = addressFrame.height
        view.layoutIfNeeded()
    }
    
    // MARK: - UIScrollView delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        if scrollOffset <= 0 {
            photo.frame.origin.y = scrollOffset
            photo.frame.size.height = 200 - scrollOffset
        }
    }
    
    // MARK: - Application logic
    func updateFavoriteButton() {
        if Favorite.inFavorites(shop.gid) {
            favoriteIcon.image = UIImage(named: "star-on")
            favoriteLabel.text = "お気に入りからはずす"
        } else {
            favoriteIcon.image = UIImage(named: "star-off")
            favoriteLabel.text = "お気に入りに入れる"
        }
    }
    
    // MARK: - IBAction
    @IBAction func telTapped(sender: UIButton) {
        println("telTapped")
    }
    
    @IBAction func addressTapped(sender: UIButton) {
        performSegueWithIdentifier("PushMapDetail", sender: nil)
    }
   
    @IBAction func favoriteTapped(sender: UIButton) {
        Favorite.toggle(shop.gid)
        updateFavoriteButton()
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushMapDetail" {
            let vc = segue.destinationViewController as! ShopMapDetailViewController
            vc.shop = shop
        }
        
    }

}
