//
//  ContentView.swift
//  tca-counter
//
//  Created by Subeen on 2/17/25.
//

import SwiftUI
import Combine

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
    
    @ObservedObject var store: Store<AppState, CounterAction>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(store: self.store)) {
                    Text("Counter Demo")
                }
            
                NavigationLink(
                    destination: FavoritePrimesView(
                        favoritePrimes: self.$store.value.favoritePrimes,
                        activityFeed: self.$store.value.activityFeed
                    )
                ) {
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
    
    @ObservedObject var store: Store<AppState, AppAction>
    @State var isPrimeModelShown: Bool = false
    @State var alertNthPrime: PrimeAlert?
    @State var isNthPrimeButtonDisabled = false
    
    func decrementCount() { self.store.value.count -= 1 }
    func incrementCount() { self.store.value.count += 1 }
    
    var body: some View {

        VStack {
            HStack {
                Button("-") { self.store.send(.counter(.decrTapped)) }
                
                Text("\(self.store.value.count)")
                
                Button("+") { self.store.send(.counter(.incrTapped)) }
            }
            
            Button  {
                self.isPrimeModelShown = true
            } label: {
                Text("Is this prime?")
            }
            
            Button  {
                
            } label: {
                Text("What is the \(ordinal(self.store.value.count)) prime?")
            }
        }
        .font(.title)
        .navigationBarTitle("Counter Demo")
        .sheet(isPresented: self.$isPrimeModelShown) {
            IsPrimeModalView(
                store: self.store
//                activityFeed: self.$store.value.activityFeed,
//                count: self.store.value.count,
//                favoritePrimes: self.$store.value.favoritePrimes
            )
        }
    }
    
    func nthPrimeButtonAction() {
        self.isNthPrimeButtonDisabled = true    // self.isNthPrimeButtonDisabled = true -> true로 변환되지 않음
        nthPrime(self.store.value.count) { prime in
//          self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
//            prime.map(PrimeAlert.init(prime: 0))
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

struct IsPrimeModalView: View {
    struct State {
        var activityFeed: [AppState.Activity]
        let count: Int
        var favoritePrimes: [Int]
    }
    
    @ObservedObject var store: Store<AppState, AppAction>
    
//    @Binding var activityFeed: [AppState.Activity]
//    @Binding let count: Int
//    @Binding var favoritePrimes: [Int]
    
    var body: some View {
        VStack {
            if isPrime(self.store.value.count) {
                Text("\(self.store.value.count) is prime")
                
                if self.store.value.favoritePrimes.contains(self.store.value.count) {
                    Button("Remove from favorite primes") {
                        self.store.send(.primeModal(.removeFavoritePrimeTapped))
                        
                    }
                } else {
                    Button("Save to favorite primes") {
                        self.store.send(.primeModal(.saveFavoritePrimeTapped))
                    }
                }
            } else {
                Text("\(self.store.value.count) is not prime")
            }
        }
    }
    
    func removeFavoritePrime() {
        self.store.value.favoritePrimes.removeAll(where: { $0 == self.store.value.count })
        self.store.value.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(self.store.value.count)))
        self.store.value.activityFeed = []
    }
    
    func saveFavoritePrime() {
        self.store.value.favoritePrimes.append(self.store.value.count)
        self.store.value.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(self.store.value.count)))
    }
}

extension AppState {
    var isPrimeModalViewState: IsPrimeModalView.State {
        get {
            IsPrimeModalView.State(
                activityFeed: self.activityFeed,
                count: self.count,
                favoritePrimes: self.favoritePrimes
            )
        }
        set {
            (
                self.activityFeed,
                self.count,
                self.favoritePrimes
            ) = (
                newValue.activityFeed,
                newValue.count,
                newValue.favoritePrimes
            )
        }
    }
}

#Preview {
    ContentView(store: Store(initialValue: AppState(), reducer: counterReducer))
}

