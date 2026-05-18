//
//  HomeView.swift
//  CMExpertise Precticle
//
//  Created by Dhananjay chauhan on 31/03/24.
//

import SwiftUI

struct HomeView: View {

    @StateObject private var viewModel = WeatherDataViewModel()

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Weather data")
        }
        .task {
            await viewModel.loadWeather()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.days.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let message = viewModel.errorMessage, viewModel.days.isEmpty {
            Text(message)
                .foregroundColor(.secondary)
                .padding()
        } else {
            List(viewModel.days) { day in
                WeatherRowView(day: day)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.loadWeather()
            }
        }
    }
}

#Preview {
    HomeView()
}
