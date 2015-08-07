import Foundation

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