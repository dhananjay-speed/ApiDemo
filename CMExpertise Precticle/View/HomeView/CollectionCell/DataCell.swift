//
//  WeatherItemView.swift
//  CMExpertise Precticle
//
//  Created by Dhananjay chauhan on 31/03/24.
//

import SwiftUI

struct WeatherItemView: View {

    let item: WeatherListItem

    var body: some View {
        VStack(spacing: 4) {
            Text(item.dtTxt?.getTime() ?? "")
                .font(.caption)

            iconView
                .frame(width: 50, height: 50)

            Text(item.main?.temp?.getCelcius() ?? "")
                .font(.subheadline)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.6), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var iconView: some View {
        if let icon = item.weather?.first?.icon,
           let url = URL(string: "https://openweathermap.org/img/wn/\(icon).png") {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit()
                case .failure:
                    Image(systemName: "cloud")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.secondary)
                case .empty:
                    ProgressView()
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Image(systemName: "cloud")
                .resizable()
                .scaledToFit()
                .foregroundColor(.secondary)
        }
    }
}
