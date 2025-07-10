//
//  AddView.swift
//  iExpense
//
//  Created by Arthur Rocha on 25/06/25.
//

import SwiftUI

struct AddView: View {
    // Holds the list of expenses
    @State public var expenses: Expenses
    @Environment(\.dismiss) var dismiss
    
    // User input fields
    @State private var name = ""
    @State private var amountString: String = ""
    @State private var type = ExpenseItem.ExpenseType.personal
    @State private var date = Date()
    @FocusState private var amountFieldFocused: Bool
    
    // Checks if the form is valid
    var isValid: Bool {
        let digits = amountString.filter { $0.isNumber }
        let value = (Double(digits) ?? 0) / 100
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && value > 0
    }
    
    // Formats the amount as currency using the user's currency
    private var formattedAmount: String {
        let digits = amountString.filter { $0.isNumber }
        let doubleValue = (Double(digits) ?? 0) / 100
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: doubleValue)) ?? ""
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Vibrant, blurred gradient background
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
                .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        // Liquid Glass form section
                        VStack(spacing: 18) {
                            TextField("Expense name", text: $name)
                                .textFieldStyle(.plain)
                                .font(.system(size: 17, weight: .semibold))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(10)
                            HStack {
                                Text("Amount")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(.gray.opacity(0.7))
                                Spacer()
                                TextField("0.00", text: Binding(
                                    get: { formattedAmount },
                                    set: { newValue in
                                        amountString = newValue.filter { $0.isNumber }
                                    }
                                ))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .focused($amountFieldFocused)
                                .font(.system(size: 17, weight: .semibold))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(10)
                                .frame(width: 120)
                            }
                            Picker("Type", selection: $type) {
                                ForEach(ExpenseItem.ExpenseType.allCases, id: \.self) { type in
                                    Label(type.rawValue, systemImage: type.icon)
                                        .foregroundColor(type.color)
                                        .tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                            DatePicker("Date", selection: $date, displayedComponents: .date)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        .padding(22)
                        .background(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 12)
                        // Info section
                        VStack {
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(type.color)
                                Text("This will be added as a \(type.rawValue.lowercased()) expense")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(14)
                        .background(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 32)
                        Spacer(minLength: 0)
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .regular))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
                            .cornerRadius(10)
                            .foregroundColor(.gray)
                            .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { addExpense() }) {
                        Text("Add")
                            .font(.system(size: 15, weight: .semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
                            .cornerRadius(10)
                            .foregroundColor(.accentColor)
                            .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    // Adds a new expense to the list
    private func addExpense() {
        let digits = amountString.filter { $0.isNumber }
        let amountValue = (Double(digits) ?? 0) / 100
        guard amountValue > 0 else { return }
        let expense = ExpenseItem(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type,
            amount: amountValue,
            date: date
        )
        expenses.addExpense(expense)
        dismiss()
    }
}

#Preview {
    AddView(expenses: Expenses())
} 
