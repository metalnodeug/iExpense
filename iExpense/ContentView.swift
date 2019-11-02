//
//  ContentView.swift
//  iExpense
//
//  Created by metalnodeug on 01/11/2019.
//  Copyright © 2019 metalnodeug. All rights reserved.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: String
    let amount: Int
}

class Expenses: ObservableObject {
    @Published var items: [ExpenseItem] {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    init() {
        if let items = UserDefaults.standard.data(forKey: "Items") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items) {
                self.items = decoded
                return
            }
        }

        self.items = []
    }
}

struct Design: ViewModifier {
    func body(content: Content) -> some View {
    content
        .font(.title)
    }
}

extension View {
    func design() -> some View {
        self.modifier(Design())
    }

}

struct ContentView: View {
    @ObservedObject var expenses = Expenses()
    @State private var showingAddExpense = false

    var body: some View {
        NavigationView {
            List {
                ForEach(expenses.items) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.type)
                        }

                        Spacer()
                        Text("$\(item.amount)")
                        .design()
                            .foregroundColor(self.colorDesign(amount: item.amount))
                    }
                }
                .onDelete(perform: removeItems)
            }
            .navigationBarTitle("iExpense")
            .navigationBarItems(leading: EditButton(), trailing: Button(action: {
                self.showingAddExpense = true
            }) {
                Image(systemName: "plus")
                }
            )
                .sheet(isPresented: $showingAddExpense) {
                    AddView(expenses: self.expenses)
            }
        }
    }

    //Adding color design
    func colorDesign(amount: Int) -> Color {
        switch amount {
        case 0..<10: return .green
        case 10..<100: return .orange
        case 100...Int.max: return .red
        default:
            break
        }
        return .black
    }

    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
