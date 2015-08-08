import Foundation
import Alamofire
import SwiftyJSON
import Keys

class Shop: Printable {
    var gid: String? = nil
    var name: String? = nil
    var photoUrl: String? = nil
    var yomi: String? = nil
    var tel: String? = nil
    var address: String? = nil
    var lat: Double? = nil
    var lon: Double? = nil
    var catchCopy: String? = nil
    var hasCoupon: Bool = false
    var station: String? = nil
    
    var description: String {
        get {
            var string = "\nGid: \(gid)\n"
            string += "PhotoUrl: \(photoUrl)\n"
            string += "Yomi: \(yomi)\n"
            string += "Tel: \(tel)\n"
            string += "Address: \(address)\n"
            string += "Lat & Lon: (\(lat), \(lon))\n"
            string += "CatchCopy: \(catchCopy)\n"
            string += "hasCoupon: \(hasCoupon)\n"
            string += "Station: \(station)\n"
            
            return string
        }
    }
}


class QueryCondition {
    var query: String? = nil
    var gid: String? = nil
    enum Sort: String {
        case Score = "score"
        case Geo = "geo"
    }
    var sort: Sort = .Score
    var lat: Double? = nil
    var lon: Double? = nil
    var dist: Double? = nil
    var queryParams: [String: String] {
        get {
            var params = [String: String]()
            if let unwrapped = query {
                params["query"] = unwrapped
            }
            if let unwrapped = gid {
                params["gid"] = unwrapped
            }
            switch sort {
            case .Score:
                params["sort"] = "score"
            case .Geo:
                params["sort"] = "geo"
            }
            if let unwrapped = lat {
                params["let"] = "\(unwrapped)"
            }
            if let unwrapped = lon {
                params["lon"] = "\(unwrapped)"
            }
            if let unwrapped = dist {
                params["dist"] = "\(unwrapped)"
            }
            params["device"] = "mobile"
            params["group"] = "gid"
            params["image"] = "true"
            params["gc"] = "01"
            
            return params
        }
    }
}

class YahooLocalSearch {
    let YLSLoadStartNotification = "YLSLoadStartNotification"
    let YLSLoadCompleteNotification = "YLSLoadCompleteNotification"
    
    let apiId = GourmesearchsampleKeys().yahooApiID()
    let apiUrl = "http://search.olp.yahooapis.jp/OpenLocalPlatform/V1/localSearch"
    let perPage = 10
    
    var shops = [Shop]()
    var loading = false
    var total = 0
    var condition: QueryCondition = QueryCondition() {
        didSet {
            shops = []
            total = 0
        }
    }
    
    init() {}
    
    init(condition: QueryCondition) { self.condition = condition }
    
    func loadData(reset: Bool = false) {
        if loading { return }
        
        if reset {
            shops = []
            total = 0
        }
        
        loading = true
        
        var params = condition.queryParams
        params["appid"] = apiId
        params["output"] = "json"
        params["start"] = String(shops.count + 1)
        params["results"] = String(perPage)
        
        NSNotificationCenter.defaultCenter().postNotificationName(YLSLoadStartNotification, object: nil)
        
        Alamofire.request(.GET, apiUrl, parameters: params).response { (request, response, data, error) in
            if error != nil {
                self.loading = false
                var message = "Unknown error."
                if let description = error?.description {
                    message = description
                }
                NSNotificationCenter.defaultCenter().postNotificationName(self.YLSLoadCompleteNotification,
                    object: nil,
                    userInfo: ["error": message]
                )
                return
            }
            
            var json = JSON.nullJSON
//              if error == nil && data != nil && data is NSData {
            if data != nil { json = SwiftyJSON.JSON(data: data! as NSData) }
            
            for (key, item) in json["Feature"] {
                var shop = Shop()
                
                shop.gid = item["Gid"].string
                var name = item["Name"].string
                shop.name = name?.stringByReplacingOccurrencesOfString("&#39;",
                    withString: "'",
                    options: .LiteralSearch,
                    range: nil
                )
                shop.yomi = item["Property"]["Yomi"].string
                shop.tel = item["Property"]["Tel1"].string
                shop.address = item["Property"]["Address"].string
                if let geometry = item["Geometry"]["Coordinates"].string {
                    let components = geometry.componentsSeparatedByString(",")
                    shop.lat = (components[1] as NSString).doubleValue
                    shop.lon = (components[0] as NSString).doubleValue
                }
                shop.catchCopy = item["Property"]["CatchCopy"].string
                shop.photoUrl = item["Property"]["LeadImage"].string
                if item["Property"]["CouponFlag"].string == "true" {
                    shop.hasCoupon = true
                }
                if let stations = item["Property"]["Station"].array {
                    var line = ""
                    if let lineString = stations[0]["Railway"].string {
                        let lines = lineString.componentsSeparatedByString("/")
                        line = lines[0]
                    }
                    if let station = stations[0]["Name"].string {
                        shop.station = "\(line) \(station)"
                    } else {
                        shop.station = "\(line)"
                    }
                }
                
                self.shops.append(shop)
            }
            
            if let total = json["ResultInfo"]["Total"].int {
                self.total = total
            } else {
                self.total = 0
            }
            
            self.loading = false
            NSNotificationCenter.defaultCenter().postNotificationName(self.YLSLoadCompleteNotification, object: nil)
        }
    }
}