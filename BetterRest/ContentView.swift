//
//  ContentView.swift
//  BetterRest
//
//  Created by Eduardo Hoffmann on 24/05/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var image = "relogio"
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        
        NavigationView {
            ZStack {
               
            Form {
                
                Text("Qual horário você quer acordar?")
                    .font(.headline)
                
                DatePicker("Por favor, escolha a hora", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("Quantidade de sono desejável")
                        .font(.headline)
                    
                    Stepper("  \(sleepAmount.formatted()) horas", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Ingestão diária de café")
                        .font(.headline)
                    
                    Stepper(coffeeAmount == 1 ? "  1 xícara" : "  \(coffeeAmount) xícaras", value: $coffeeAmount, in: 1...20)
                }
                
               
                
                
            }
            
            .navigationTitle("MelhorDescanso")
            .toolbar {
                Button("Calcular", action: calculateBedtime)
                
                    .alert(alertTitle, isPresented: $showingAlert) {
                        Button("OK") {}
                    } message: {
                        Text(alertMessage)
                    }
                
            }
          
                VStack {
                    Image(image).resizable().scaledToFit().frame(width: 200.0, height: 100.0).clipShape(Circle())
                }
        }
    }
    
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "A hora ideal para você dormir é..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Erro"
            alertMessage = "Desculpe, houve um problema ao calcular sua hora de dormir"
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
