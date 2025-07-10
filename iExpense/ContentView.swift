//
//  ContentView.swift
//  iExpense
//
//  Created by Arthur Rocha on 25/06/25.
//

import SwiftUI

// Expense item model
struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: ExpenseType
    let amount: Double
    let date: Date
    
    enum ExpenseType: String, CaseIterable, Codable {
        case personal = "Personal"
        case business = "Business"
        
        var icon: String {
            switch self {
            case .personal: return "person.fill"
            case .business: return "briefcase.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .personal: return .blue
            case .business: return .green
            }
        }
    }
}

// Stores and manages the list of expenses
@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    var newlyAddedIds: Set<UUID> = []
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
        items = []
    }
    
    func addExpense(_ expense: ExpenseItem) {
        items.append(expense)
        newlyAddedIds.insert(expense.id)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.newlyAddedIds.remove(expense.id)
        }
    }
    
    var personalExpenses: [ExpenseItem] {
        items.filter { $0.type == .personal }
    }
    
    var businessExpenses: [ExpenseItem] {
        items.filter { $0.type == .business }
    }
    
    var totalPersonal: Double {
        personalExpenses.reduce(0) { $0 + $1.amount }
    }
    
    var totalBusiness: Double {
        businessExpenses.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Double {
        items.reduce(0) { $0 + $1.amount }
    }
}

struct ContentView: View {
    @State private var showingAddExpense = false
    @State private var expenses = Expenses()
    @State private var isClearingAll = false
    @State private var showPersonalDetail = false
    @State private var showBusinessDetail = false
    @State private var animateTitle = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Premium, layered background gradient
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.45),
                            Color.purple.opacity(0.32),
                            Color.cyan.opacity(0.28),
                            Color.white.opacity(0.18)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.22),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 60,
                        endRadius: 350
                    )
                }
                .ignoresSafeArea()
                VStack(spacing: 36) {
                    // Transparent, animated title
                    Text("iExpense")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                        .scaleEffect(animateTitle ? 1.08 : 0.95)
                        .animation(.spring(response: 0.7, dampingFraction: 0.7), value: animateTitle)
                        .onAppear { animateTitle = true }
                    // Animated, glassy summary cards
                    VStack(spacing: 28) {
                        SummaryCard(
                            title: "Total",
                            amount: expenses.totalExpenses,
                            color: .purple,
                            icon: "dollarsign.circle.fill"
                        )
                        .transition(.scale.combined(with: .opacity))
                        Button(action: { showPersonalDetail = true }) {
                            SummaryCard(
                                title: "Personal",
                                amount: expenses.totalPersonal,
                                color: .blue,
                                icon: "person.circle.fill"
                            )
                        }
                        .buttonStyle(.plain)
                        .transition(.scale.combined(with: .opacity))
                        Button(action: { showBusinessDetail = true }) {
                            SummaryCard(
                                title: "Business",
                                amount: expenses.totalBusiness,
                                color: .green,
                                icon: "briefcase.circle.fill"
                            )
                        }
                        .buttonStyle(.plain)
                        .transition(.scale.combined(with: .opacity))
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 8)
                    Spacer(minLength: 0)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.45)) {
                            isClearingAll = true
                            expenses.items.removeAll()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                            isClearingAll = false
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                            Text("Clear")
                                .font(.system(size: 15, weight: .regular))
                        }
                        .padding(10)
                        .background(
                            .ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.13), lineWidth: 1)
                        )
                        .foregroundColor(.red)
                        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                        .scaleEffect(isClearingAll ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isClearingAll)
                    }
                    .disabled(expenses.items.isEmpty || isClearingAll)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExpense = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                            Text("Add")
                                .font(.system(size: 15, weight: .regular))
                        }
                        .padding(10)
                        .background(
                            .ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.13), lineWidth: 1)
                        )
                        .foregroundColor(.accentColor)
                        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                        .scaleEffect(showingAddExpense ? 1.08 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: showingAddExpense)
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
            .navigationDestination(isPresented: $showPersonalDetail) {
                ExpensesListDetailView(
                    title: "Personal Expenses",
                    expenses: expenses.personalExpenses,
                    color: .blue,
                    icon: "person.circle.fill",
                    expensesStore: expenses
                )
            }
            .navigationDestination(isPresented: $showBusinessDetail) {
                ExpensesListDetailView(
                    title: "Business Expenses",
                    expenses: expenses.businessExpenses,
                    color: .green,
                    icon: "briefcase.circle.fill",
                    expensesStore: expenses
                )
            }
        }
    }
    
    private func deletePersonalExpenses(offsets: IndexSet) {
        withAnimation(.easeInOut(duration: 0.3)) {
            let itemsToDelete = offsets.map { expenses.personalExpenses[$0] }
            expenses.items.removeAll { item in
                itemsToDelete.contains { $0.id == item.id }
            }
        }
    }
    private func deleteBusinessExpenses(offsets: IndexSet) {
        withAnimation(.easeInOut(duration: 0.3)) {
            let itemsToDelete = offsets.map { expenses.businessExpenses[$0] }
            expenses.items.removeAll { item in
                itemsToDelete.contains { $0.id == item.id }
            }
        }
    }
}

// Shows the summary cards for total, personal, and business expenses
struct SummaryCards: View {
    let expenses: Expenses
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SummaryCard(
                title: "Total",
                amount: expenses.totalExpenses,
                color: .purple,
                icon: "dollarsign.circle.fill"
            )
            SummaryCard(
                title: "Personal",
                amount: expenses.totalPersonal,
                color: .blue,
                icon: "person.circle.fill"
            )
            SummaryCard(
                title: "Business",
                amount: expenses.totalBusiness,
                color: .green,
                icon: "briefcase.circle.fill"
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
    }
}

// Shows the list of expenses, split by type
struct ExpensesList: View {
    let expenses: Expenses
    let onDeletePersonal: (IndexSet) -> Void
    let onDeleteBusiness: (IndexSet) -> Void
    var body: some View {
        List {
            if !expenses.personalExpenses.isEmpty {
                ExpenseSection(
                    title: "Personal Expenses",
                    expenses: expenses.personalExpenses,
                    total: expenses.totalPersonal,
                    onDelete: onDeletePersonal,
                    expensesStore: expenses
                )
            }
            if !expenses.businessExpenses.isEmpty {
                ExpenseSection(
                    title: "Business Expenses",
                    expenses: expenses.businessExpenses,
                    total: expenses.totalBusiness,
                    onDelete: onDeleteBusiness,
                    expensesStore: expenses
                )
            }
        }
        .listStyle(.insetGrouped)
    }
}

// Section for a group of expenses
struct ExpenseSection: View {
    let title: String
    let expenses: [ExpenseItem]
    let total: Double
    let onDelete: (IndexSet) -> Void
    let expensesStore: Expenses
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title.uppercased())
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray.opacity(0.7))
                Spacer()
                Text(total, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 0.8)
            )
            .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 6)
            .padding(.top, 8)
            ForEach(expenses) { item in
                ExpenseRow(item: item, expenses: expensesStore)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.98)).combined(with: .move(edge: .bottom)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
            .onDelete(perform: onDelete)
        }
    }
}

// Displays a single expense row
struct ExpenseRow: View {
    let item: ExpenseItem
    let expenses: Expenses
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.type.icon)
                .foregroundColor(item.type.color)
                .frame(width: 26, height: 26)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .background(Color(.systemGray6).opacity(0.7))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                Text(item.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.6))
            }
            Spacer()
            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(amountColor)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isNewlyAdded ? Color.accentColor.opacity(0.5) : Color.white.opacity(0.13), lineWidth: isNewlyAdded ? 1.5 : 1)
                .animation(.easeOut(duration: 0.5), value: isNewlyAdded)
        )
        .shadow(color: .black.opacity(0.13), radius: 12, x: 0, y: 6)
        .padding(.vertical, 7)
        .padding(.horizontal, 4)
    }
    private var isNewlyAdded: Bool {
        expenses.newlyAddedIds.contains(item.id)
    }
    private var amountColor: Color {
        switch item.amount {
        case ..<10:
            return .green
        case 10..<100:
            return .orange
        default:
            return .red
        }
    }
}

// Enhanced iOS 26 inspired summary card
struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    var body: some View {
        ZStack {
            // Liquid Glass background with more blur and white overlay
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    Color.white.opacity(0.18)
                        .blur(radius: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 38, style: .continuous)
                        .stroke(Color.white.opacity(0.13), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.13), radius: 18, x: 0, y: 8)
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.13))
                            .frame(width: 44, height: 44)
                        Image(systemName: icon)
                            .foregroundColor(color)
                            .font(.system(size: 26, weight: .medium, design: .rounded))
                    }
                    Spacer()
                }
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary.opacity(0.82))
                Text(amount, format: .currency(code: "BRL"))
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundColor(color)
                    .lineLimit(1)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: amount)
                    .scaleEffect(amount > 0 ? 1.0 : 0.97)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: amount)
            }
            .padding(.vertical, 28)
            .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
    }
}

struct ExpensesListDetailView: View {
    let title: String
    let expenses: [ExpenseItem]
    let color: Color
    let icon: String
    let expensesStore: Expenses
    var body: some View {
        ZStack {
            // Layered background gradient for detail view
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.45),
                        Color.purple.opacity(0.32),
                        Color.cyan.opacity(0.28),
                        Color.white.opacity(0.18)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.22),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 60,
                    endRadius: 350
                )
            }
            .ignoresSafeArea()
            VStack(spacing: 24) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                    Text(title)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(color)
                    Spacer()
                }
                .padding(.horizontal, 20)
                if expenses.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.system(size: 32, weight: .regular))
                            .foregroundColor(.gray.opacity(0.18))
                        Text("No expenses yet")
                            .font(.title3)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 80)
                } else {
                    List {
                        ForEach(expenses) { item in
                            ExpenseRow(item: item, expenses: expensesStore)
                        }
                        .onDelete { indexSet in
                            // Remove from the correct type in the main Expenses store
                            let idsToDelete = indexSet.map { expenses[$0].id }
                            expensesStore.items.removeAll { idsToDelete.contains($0.id) }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .background(Color.clear)
                }
                Spacer()
            }
            .padding(.top, 32)
        }
    }
}

#Preview {
    ContentView()
}
