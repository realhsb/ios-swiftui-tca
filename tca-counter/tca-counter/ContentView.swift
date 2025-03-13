//
//  ContentView.swift
//  tca-counter
//
//  Created by Subeen on 2/17/25.
//

import SwiftUI
import Combine

struct WolframAlphaResult: Decodable {
  let queryresult: QueryResult

  struct QueryResult: Decodable {
    let pods: [Pod]

    struct Pod: Decodable {
      let primary: Bool?
      let subpods: [SubPod]

      struct SubPod: Decodable {
        let plaintext: String
      }
    }
  }
}

func wolframAlpha(
  query: String,
  callback: @escaping (WolframAlphaResult?) -> Void
) -> Void {
  var components = URLComponents(
    string: "https://api.wolframalpha.com/v2/query"
  )!
  components.queryItems = [
    URLQueryItem(name: "input", value: query),
    URLQueryItem(name: "format", value: "plaintext"),
    URLQueryItem(name: "output", value: "JSON"),
//    URLQueryItem(name: "appid", value: wolframAlphaApiKey),
  ]

  URLSession.shared.dataTask(
    with: components.url(relativeTo: nil)!
  ) { data, response, error in
    callback(
      data.flatMap {
        try? JSONDecoder().decode(WolframAlphaResult.self, from: $0)
      }
    )
  }
  .resume()
}

func nthPrime(
  _ n: Int, callback: @escaping (Int?) -> Void
) -> Void {
  wolframAlpha(query: "prime \(n)") { result in
    callback(
      result
        .flatMap {
          $0.queryresult
            .pods
            .first(where: { $0.primary == .some(true) })?
            .subpods
            .first?
            .plaintext
        }
        .flatMap(Int.init)
    )
  }
}

func foo() -> Int {
    fatalError()
}

struct ContentView: View {
    
    @ObservedObject var state: AppState
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(state: self.state)) {
                    Text("Counter Demo")
                }
                
                NavigationLink(destination: EmptyView()) {
                    Text("Favorite primes")
                }
            }
            .navigationTitle("State management")
        }
    }
}

private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}

// BindableObject




struct CounterView: View {
    
    @ObservedObject var state: AppState
    @State var isPrimeModelShown: Bool = false
    @State var alertNthPrime: Int?
    @State var isNthPrimeButtonDisabled = false
    
    var body: some View {
        
//        self.$count // Binding<Int>
        
        VStack {
            HStack {
                Button {
                    self.state.count -= 1
                } label: {
                    Text("-")
                }
                
                Text("\(self.state.count)")
                
                Button {
                    self.state.count += 1
                } label: {
                    Text("+")
                }
            }
            
            Button  {
                self.isPrimeModelShown = true
            } label: {
                Text("Is this prime?")
            }
            
            Button  {
                
            } label: {
                Text("What is the \(ordinal(self.state.count)) prime?")
            }
        }
        .font(.title)
        .navigationBarTitle("Counter Demo")
        .sheet(isPresented: self.$isPrimeModelShown) {
            IsPrimeModelView(state: self.state)
        }11
    }
    
    func nthPrimeButtonAction() {
        self.isNthPrimeButtonDisabled = true
        nthPrime(self.state.count) { prime in
          self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
          self.isNthPrimeButtonDisabled = false
        }
      }
}

private func isPrime(_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }
    for i in 2...Int(sqrtf(Float(p))) {
        if p % i == 0 { return false }
    }
    return true
}

struct IsPrimeModelView: View {
    
    @ObservedObject var state: AppState
    
    var body: some View {
        VStack {
            if isPrime(self.state.count) {
                Text("\(self.state.count) is prime")
                
                if self.state.favoritePrimes.contains(self.state.count) {
                    Button {
                        self.state.favoritePrimes.removeAll(where: { $0 == self.state.count })
                    } label: {
                        Text("Remove from favorite primes")
                    }
                } else {
                    Button {
                        self.state.favoritePrimes.append(self.state.count)
                    } label: {
                        Text("Save to favorite primes")
                    }
                }
            } else {
                Text("\(self.state.count) is not prime")
            }
        }
    }
}

#Preview {
    ContentView(state: AppState())
}
