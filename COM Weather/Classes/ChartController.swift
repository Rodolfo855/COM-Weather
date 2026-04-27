//
//  ChartController.swift
//  COM Weather
//
//  Created by Victor Rosales  on 4/27/26.
//

import SwiftUI

// MARK: - Models
struct StorageItem: Identifiable {
    let id = UUID()
    let title: String
    let value: Double
    let total: Double
    let color: Color
}

// MARK: - Components
struct DonutChart: View {
    let items: [StorageItem]
    let totalCapacity: Double
    
    var body: some View {
        ZStack {
            Circle().stroke(Color.gray.opacity(0.2), lineWidth: 12)
            
            ForEach(0..<items.count, id: \.self) { index in
                let item = items[index]
                let start = calculateStart(index: index)
                let end = calculateEnd(index: index)
                
                Circle()
                    .trim(from: start, to: end)
                    .stroke(item.color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            
            VStack {
                Text("\(Int((items.reduce(0) { $0 + $1.value } / totalCapacity) * 100))%")
                    .font(.system(size: 20, weight: .bold))
                Text("used").font(.caption)
            }
        }
        .frame(width: 100, height: 100)
    }
    
    func calculateStart(index: Int) -> CGFloat {
        let prev = items.prefix(index).reduce(0) { $0 + $1.value }
        return CGFloat(prev / totalCapacity)
    }
    
    func calculateEnd(index: Int) -> CGFloat {
        let current = items.prefix(index + 1).reduce(0) { $0 + $1.value }
        return CGFloat(current / totalCapacity)
    }
}

// MARK: - Main View
struct DeviceStorageDashboard: View {
    
    @Environment(\.dismiss) var dismiss
    // Data sets
    let esp32Items = [
        StorageItem(title: "Main Program", value: 1.0, total: 4.0, color: .purple),
        StorageItem(title: "Sensor Records", value: 0.8, total: 4.0, color: .pink),
        StorageItem(title: "OTA", value: 0.4, total: 4.0, color: .red),
        StorageItem(title: "GPS & Battery", value: 0.9, total: 4.0, color: .orange),
        StorageItem(title: "Other apps", value: 0.3, total: 4.0, color: .yellow)
    ]
    
    let usageItems = [
        StorageItem(title: "Code base", value: 11.5, total: 32.0, color: .purple),
        StorageItem(title: "Binary records", value: 7.15, total: 32.0, color: .pink),
        StorageItem(title: "Over the air updates (OTA)", value: 2.5, total: 32.0, color: .red),
        StorageItem(title: "Reserved/Unused", value: 5.83, total: 32.0, color: .orange)
    ]
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    Text("Device Storage Information")
                        .font(.title2).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Our ESP32 is equipped with 4MB of internal flash storage. Below is a quick graph of real time usage of how this storage is being used.")
                        .font(.subheadline).foregroundColor(.gray)
                    
                    // CARD 1: ESP32 Storage
                    VStack(alignment: .leading, spacing: 20) {
                        Text("ESP32's Storage").font(.headline)
                        HStack {
                            DonutChart(items: esp32Items, totalCapacity: 4.0)
                            Spacer()
                            // Legend
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(esp32Items) { item in
                                    HStack {
                                        Circle().fill(item.color).frame(width: 10, height: 10)
                                        Text(item.title).font(.caption)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(white: 0.10))
                    .cornerRadius(25)
                    
                    Text("The ESP32 is equipped with 2MB of PSRAM which we use to read data and parse records. Below is a detailed description on how this fast memory is being utilized.")
                        .font(.subheadline).foregroundColor(.gray)
                    
                    // CARD 2: Usage Details
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Usage details").font(.headline)
                                    .padding(1)
                                Text("26.98GB").font(.title.bold())
                                Text("of 32GB").font(.subheadline).foregroundColor(.gray)
                            }
                            Spacer()
                            DonutChart(items: usageItems, totalCapacity: 32.0)
                        }
                        
                        // List
                        ForEach(usageItems) { item in
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(item.title).font(.subheadline)
                                    Spacer()
                                    Text("\(item.value, specifier: "%.2f") GB").font(.subheadline)
                                }
                                // Progress bar
                                GeometryReader { geo in
                                    Capsule().fill(Color.gray.opacity(0.3)).frame(height: 6)
                                    Capsule().fill(item.color).frame(width: geo.size.width * CGFloat(item.value / item.total), height: 6)
                                }
                                .frame(height: 6)
                            }
                        }
                    }
                    .padding()
                    .background(Color(white: 0.10))
                    .cornerRadius(25)
                }
                .padding()
                .preferredColorScheme(.dark)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                }
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    DeviceStorageDashboard()
}
