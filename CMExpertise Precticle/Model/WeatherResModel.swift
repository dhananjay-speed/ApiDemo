//
//  WeatherResModel.swift
//  CMExpertise Precticle
//
//  Created by Dhananjay chauhan on 31/03/24.
//

import Foundation
class WeatherResModel: Decodable {

    let cod: String?
    let message: Int?
    let cnt: Int?
    let list: [WeatherListItem]?

    private enum CodingKeys: String, CodingKey {
        case cod = "cod"
        case message = "message"
        case cnt = "cnt"
        case list = "list"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cod = try? values.decodeIfPresent(String.self, forKey: .cod)
        message = try? values.decodeIfPresent(Int.self, forKey: .message)
        cnt = try? values.decodeIfPresent(Int.self, forKey: .cnt)
        list = try? values.decodeIfPresent([WeatherListItem].self, forKey: .list)
    }

}

class WeatherListItem: Decodable {

    let dt: Int?
    let main: Main?
    let weather: [Weather]?
    let dtTxt: String?

    private enum CodingKeys: String, CodingKey {
        case dt = "dt"
        case main = "main"
        case weather = "weather"
        case dtTxt = "dt_txt"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dt = try? values.decodeIfPresent(Int.self, forKey: .dt)
        main = try? values.decodeIfPresent(Main.self, forKey: .main)
        weather = try? values.decodeIfPresent([Weather].self, forKey: .weather)
        dtTxt = try? values.decodeIfPresent(String.self, forKey: .dtTxt)
    }

}

class Main: Decodable {

    let temp: Double?

    private enum CodingKeys: String, CodingKey {
        case temp = "temp"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        temp = try? values.decodeIfPresent(Double.self, forKey: .temp)
    }

}

class Weather: Decodable {

    let icon: String?

    private enum CodingKeys: String, CodingKey {
        case icon = "icon"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        icon = try? values.decodeIfPresent(String.self, forKey: .icon)
    }

}
