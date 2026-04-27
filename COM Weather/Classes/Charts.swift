////
////  Charts.swift
////  COM Weather
////
////  Created by Victor Rosales  on 4/27/26.
////
//
//import SwiftUI
//import Combine
//import Foundation
//
//// 1. DATA MODEL
//struct StorageItem: Identifiable {
//    let id = UUID()
//    let title: String
//    let value: Double? // Optional to handle "N/A"
//    let totalCapacity: Double
//    let color: Color
//}
//
//// 2. VIEW MODEL (Logic Layer)
//class StorageViewModel: ObservableObject {
//    @Published var items: [StorageItem]
//    
//    init(data: [StorageItem] = []) {
//        // Default data if no values are provided
//        if data.isEmpty {
//            self.items = [
//                StorageItem(title: "Main Program", value: 1.2, totalCapacity: 4.0, color: .purple),
//                StorageItem(title: "Sensor Records", value: 0.8, totalCapacity: 4.0, color: .pink),
//                StorageItem(title: "OTA", value: nil, totalCapacity: 4.0, color: .red)
//            ]
//        } else {
//            self.items = data
//        }
//    }
//    
//    // Only includes valid, non-nil values for calculations
//    var validItems: [StorageItem] {
//        items.filter { $0.value != nil }
//    }
//    
//    var totalUsed: Double {
//        validItems.reduce(0) { $0 + ($1.value ?? 0) }
//    }
//    
//    var maxCapacity: Double {
//        items.first?.totalCapacity ?? 4.0
//    }
//}
//
//// 3. DONUT CHART COMPONENT
//struct DonutChart: View {
//    let items: [StorageItem]
//    let totalCapacity: Double
//    @State private var animate = false
//    
//    var body: some View {
//        ZStack {
//            // Background ring
//            Circle().stroke(Color.gray.opacity(0.2), lineWidth: 20)
//            
//            // Segments
//            ForEach(0..<items.count, id: \.self) { index in
//                let item = items[index]
//                if item.value != nil {
//                    let start = calculateStart(index: index)
//                    let end = calculateEnd(index: index)
//                    
//                    Circle()
//                        .trim(from: animate ? 0 : start, to: animate ? end : start)
//                        .stroke(item.color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
//                        .rotationEffect(.degrees(-90))
//                }
//            }
//        }
//        .frame(width: 150, height: 150)
//        .onAppear { withAnimation(.easeInOut(duration: 1.5)) { animate = true } }
//    }
//    
//    func calculateStart(index: Int) -> CGFloat {
//        let prev = items.prefix(index).compactMap { $0.value }.reduce(0, +)
//        return CGFloat(prev / totalCapacity)
//    }
//    
//    func calculateEnd(index: Int) -> CGFloat {
//        let current = items.prefix(index + 1).compactMap { $0.value }.reduce(0, +)
//        return CGFloat(current / totalCapacity)
//    }
//}
//
//// 4. STORAGE ROW (Handles "N/A" display)
//struct StorageRow: View {
//    let item: StorageItem
//    
//    var body: some View {
//        HStack {
//            Circle().fill(item.color).frame(width: 10, height: 10)
//            Text(item.title)
//                .font(.subheadline)
//            Spacer()
//            
//            if let val = item.value {
//                Text("\(val, specifier: "%.1f") GB")
//                    .font(.subheadline).bold()
//            } else {
//                Text("N/A")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .italic()
//            }
//        }
//    }
//}
//
//// 5. MAIN DASHBOARD VIEW
//struct DashboardView: View {
//    @StateObject var viewModel: StorageViewModel
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Device Storage")
//                .font(.title2).bold()
//            
//            DonutChart(items: viewModel.items, totalCapacity: viewModel.maxCapacity)
//                .overlay(
//                    VStack {
//                        Text("\(Int((viewModel.totalUsed / viewModel.maxCapacity) * 100))%")
//                            .font(.title.bold())
//                        Text("used").font(.caption)
//                    }
//                )
//            
//            VStack(alignment: .leading, spacing: 15) {
//                ForEach(viewModel.items) { item in
//                    StorageRow(item: item)
//                    Divider()
//                }
//            }
//            .padding()
//            .background(RoundedRectangle(cornerRadius: 15).fill(Color(.secondarySystemBackground)))
//        }
//        .padding()
//    }
//}
//
//// Preview
//#Preview {
//    DashboardView(viewModel: StorageViewModel())
//}
