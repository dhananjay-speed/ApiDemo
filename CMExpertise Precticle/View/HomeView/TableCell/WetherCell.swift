//
//  WeatherRowView.swift
//  CMExpertise Precticle
//
//  Created by Dhananjay chauhan on 31/03/24.
//

import SwiftUI

struct WeatherRowView: View {

    let day: WeatherDay

    private let columns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(day.date)
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.top, 12)

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(day.items, id: \.dt) { item in
                    WeatherItemView(item: item)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
