//
//  WeatherDataViewModel.swift
//  CMExpertise Precticle
//
//  Created by Dhananjay chauhan on 31/03/24.
//

import Foundation
import Combine

struct WeatherDay: Identifiable {
    let id = UUID()
    let date: String
    let items: [WeatherListItem]
}

@MainActor
final class WeatherDataViewModel: ObservableObject {

    @Published private(set) var days: [WeatherDay] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    private let service: WebService

    init(service: WebService = WebService()) {
        self.service = service
    }

    func loadWeather() async {
        isLoading = true
        errorMessage = nil
        let result = await service.getDataWithWait(resModel: WeatherResModel.self, url: APIKeys.whether.rawValue)
        isLoading = false
        switch result {
        case .success(let response):
            days = group(response)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    private func group(_ response: WeatherResModel?) -> [WeatherDay] {
        var buckets: [(date: String, items: [WeatherListItem])] = []
        for item in response?.list ?? [] {
            let date = item.dtTxt?.getDate() ?? ""
            if let index = buckets.firstIndex(where: { $0.date == date }) {
                buckets[index].items.append(item)
            } else {
                buckets.append((date: date, items: [item]))
            }
        }
        return buckets.map { WeatherDay(date: $0.date, items: $0.items) }
    }
}
