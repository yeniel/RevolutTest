import Foundation


/*
 * Complete the 'findRateAndRoute' function below.
 *
 * The function accepts:
 *  - currencyPair: a pair of ISO 4217 currency codes, e.g. USDEUR
 *  - rates: a dictionary of currency pairs and their respective exchange rate, e.g.
 *    USDEUR -> 0.89
 *    RUBDKK -> 0.083
 *    ...
 *
 * The function is expected to return, in a (Decimal, String) pair:
 *  1. exchange rate from left to right currency in currencyPair
 *  2. shortest route between currencies to make the exchange, formed concatenating currency codes (e.g. USDEURRUB)
 */

class Currency {
    var identifier: String
    var edges = [Edge]()
    var visited = false
    var distance: Int = Int.max
    var previous: Currency?

    var description: String {
        var edgesString = String()
        edges.forEach{  edgesString.append("\n    " + $0.description)}
        return "{ Node, identifier: \(identifier.description), distance: \(distance) visited: \(visited) \(edgesString)}"
    }

    init(visited: Bool, identifier: String, edges: [Edge]) {
        self.visited = visited
        self.identifier = identifier
        self.edges = edges
    }

    static func == (lhs: Currency, rhs: Currency) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

class Edge {
    var from: Currency
    var to: Currency
    var exchange: Decimal

    var description : String {
        return "{ Edge, from: \(from.identifier), to: \(to.identifier), exchange: \(exchange) }"

    }

    init(to: Currency, from: Currency, exchange: Decimal) {
        self.to = to
        self.exchange = exchange
        self.from = from
    }
}

class CurrencyGraph {
    var nodes: [Currency] = []
}

func setupGraphwith(edges: [String: Decimal]) -> CurrencyGraph {
    let graph = CurrencyGraph()

    // create all the nodes
    // The first and last node need to be included, so need nodes from "to" and "from"
    var nodeNames = Set<String>()

    edges.keys.forEach {
        nodeNames.insert(String($0.prefix(3)))
        nodeNames.insert(String($0.suffix(3)))
    }

    for node in nodeNames {
        let newNode = Currency(visited: false, identifier: node, edges: [])
        graph.nodes.append(newNode)
    }

    // create all the edges to link the nodes
    for (currencyPair, exchange) in edges {
        if let fromCurrency = graph.nodes.first(where: { $0.identifier == currencyPair.prefix(3) }) {
            if let toCurrency = graph.nodes.first(where: { $0.identifier == currencyPair.suffix(3) }) {
                let forwardEdge = Edge(to: toCurrency, from: fromCurrency, exchange: exchange)

                fromCurrency.edges.append(forwardEdge)
            }
        }
    }

    return graph
}

func addDistancesToTheGraph(source: String, destination: String, graph: CurrencyGraph) {
    guard let sourceCurrency = (graph.nodes.first{ $0.identifier == source }) else {
        return
    }

    var currentCurrency: Currency = sourceCurrency

    currentCurrency.visited = true
    currentCurrency.distance = 0

    var toVisit = [Currency]()

    toVisit.append(currentCurrency)

    while (!toVisit.isEmpty) {
        print("\nCURRENT NODE: ")
        print(currentCurrency.description)

        toVisit = toVisit.filter{ $0.identifier != currentCurrency.identifier }

        currentCurrency.visited = true

        // Go to each adjacent vertex and update the path length

        for connectedEdge in currentCurrency.edges {
            // if we want to find the shortest path taking into account the exchange rate (e.g. lowest rate)
            // we should add the connectedEdge.exchange (let dist = currentCurrency.distance + connectedEdge.exchange)
            // For this case I assume that every exchange from one currency to another has the same cost = 1
            let dist = currentCurrency.distance + 1

            if (dist < connectedEdge.to.distance) {
                connectedEdge.to.distance = dist
                connectedEdge.to.previous = currentCurrency

                toVisit.append(connectedEdge.to)

                if (connectedEdge.to.visited) {
                    connectedEdge.to.visited = false
                }
            }
        }

        currentCurrency.visited = true

        //set current node to the smallest vertex

        print("\nCANDIDATES: ")
        toVisit.forEach { print($0.description + "\n") }

        if !toVisit.isEmpty {
            guard let minCurrency = toVisit.min(by: { (a, b) -> Bool in
                return a.distance < b.distance
            }) else {
                return
            }

            print("MIN CURRENCY")
            print(minCurrency.description)

            print("\nEDGES:")
            currentCurrency.edges.forEach { print($0.description) }
            currentCurrency = minCurrency
        }

        if (currentCurrency.identifier == destination) {
            return
        }
    }

    return
}

func findRateAndRoute(for currencyPair: String, rates: [String: Decimal]) -> (rate: Decimal, route: String) {
    let currencyGraph = setupGraphwith(edges: rates)
    let fromCurrency = String(currencyPair.prefix(3))
    let toCurrency = String(currencyPair.suffix(3))


    currencyGraph.nodes.forEach { print("\($0.description) \n") }
    print("SOURCE: \(fromCurrency)")
    print("DESTINATION: \(toCurrency)")

    addDistancesToTheGraph(source: fromCurrency, destination: toCurrency, graph: currencyGraph)

    print("FINAL GRAPH")
    currencyGraph.nodes.forEach { print("\($0.description) \n") }

    let visitedNodes = currencyGraph.nodes.filter { $0.visited }
    var route = ""
    var exchange = Decimal(1)
    guard let destinationNode = (currencyGraph.nodes.first { $0.identifier == toCurrency }) else {
        return (rate: 0, route: "")
    }
    var currentNode: Currency = destinationNode

    while currentNode.identifier != fromCurrency {
        route = currentNode.identifier + " " + route

        guard let previous = currentNode.previous else {
            break
        }

        exchange *= previous.edges.first { $0.to == currentNode }?.exchange ?? 1
        currentNode = previous
    }

    route = fromCurrency + " " + route

    return (rate: exchange, route: route)
}

let rates = [
    "EGPGMD": Decimal(3.3421),
    "EGPSVC": Decimal(0.5566),
    "SEKGHS": Decimal(0.6644),
    "SEKHKD": Decimal(0.8307),
    "IDREGP": Decimal(0.0011),
    "GHSHKD": Decimal(1.2504),
    "GMDJMD": Decimal(2.9725),
    "GMDCRC": Decimal(12.1763),
    "GELEGP": Decimal(5.1432),
    "GELIDR": Decimal(4692.8022),
    "CRCTOP": Decimal(0.0036),
    "CRCSEK": Decimal(0.0146),
    "SVCGMD": Decimal(6.005),
    "RUBSEK": Decimal(0.1207),
    "TOPRUB": Decimal(34.1588),
    "JMDCRC": Decimal(4.0963),
]

var result = findRateAndRoute(for: "GELHKD", rates: rates)

print("\n\(result)")
