//
//  Map.swift
//  Odontoceti
//
//  Created by Gregory Foster on 2/20/17.
//  Copyright © 2017 Greg M Foster. All rights reserved.
//


import UIKit

/// Representation of a particle for use in the particle filter algorithm.
struct Particle {
    var xLoc: Int = 0
    var yLoc: Int = 0
    var weight: Double = 0
}

/// Representation of a coordinate point on a grid.
struct Point: Hashable {
    var xLoc: Int = 0
    var yLoc: Int = 0
    var hashValue: Int {
        return (xLoc * 0x1f1f1f1f) ^ yLoc
    }
}

/**
    Extra comparison definition allowing points to be equated to particles.

    - parameter left:       One point.
    - parameter right:      The other point.
    - returns:              Bool indicating equality.
 */
func == (left: Point, right: Point) -> Bool {
    return left.xLoc == right.xLoc && left.yLoc == right.yLoc
}

func == (left: Particle, right: Point) -> Bool {
    return left.xLoc == right.xLoc && left.yLoc == right.yLoc
}

func == (left: Point, right: Particle) -> Bool {
    return left.xLoc == right.xLoc && left.yLoc == right.yLoc
}

/// Entend ints to allow them to be cast to Bools.
extension Int {
    init(_ bool: Bool) {
        self = bool ? 1 : 0
    }
}

func += ( left: inout CGPoint, right: CGPoint) {
    left.x += right.x
    left.y += right.y
}


// MARK: - Map Object

/// The Map represents the data backing of the current map for measuring and particle filtering.
class Map: NSObject {

    /// The number of particles for particle filtering.
    private let numParticles = 100
    /// The array storing the current particles.
    private var particles = [Particle]()
    /// The constant limiting rate at which new mag readings adjust the declared current magnitude.
    private let updateRate: Double
    /// The array of points representing the grid.
    private var grid = [Point: Double]()
    /// The size of the grid to be used throughout the entire app.
    let gridSize: Int
    lazy var CGGridSize: CGSize = {
        return CGSize(width: UIScreen.main.bounds.size.width / CGFloat(self.gridSize),
                      height: UIScreen.main.bounds.size.height / CGFloat(self.gridSize))
    }()

    /// The singleton map object to be used throughout the entire app.
    static let sharedMap = Map(gridSize: 5, updateRate: 0.3)

    lazy var points: [Point] = {
        var _points = [Point]()
        for y in 0..<self.gridSize {
            for x in 0..<self.gridSize {
                _points.append(Point(xLoc:x, yLoc:y))
            }
        }
        return _points
    }()

    init(gridSize: Int, updateRate: Double) {
        self.updateRate = updateRate
        self.gridSize = gridSize
        super.init()

        // Create n particles with equal normalized weights.
        initializeParticles()

        // Populate grid with average values
        for y in 0..<gridSize {
            for x in 0..<gridSize {
                grid[Point(xLoc:x, yLoc:y)] = 30
            }
        }
    }

    // MARK: - Grid writing and reading methods

    func update(location: Point, value: Double) {
        if let curVal = grid[location] {
            if curVal > 0 {
                grid[location]! += (value - curVal) * updateRate
            } else {
                grid[location] = value
            }
        }
    }

    func valueFor(location: Point) -> Double {
        return grid[location]!
    }

    func normalizedValueFor(location: Point) -> Double {
        let min: Double? = grid.values.filter({$0 > 0}).min()
        let max: Double? = grid.values.filter({$0 > 0}).max()
        if let val = grid[location], val > 0, let min = min, let max = max {
            let range: Double = max - min
            if range > 0 {
                return (val - min) / range
            }
        }
        return 0.5
    }

    func locationForValue(value: Double) -> CGPoint {
        let closest = grid.min(by: {abs($0.value - value) < abs($1.value - value)})
        if let path = closest?.key {
            let x = path.xLoc
            let y = path.yLoc
            return CGPoint(x: 1.0 / CGFloat(gridSize) * CGFloat(x) + 0.5 / CGFloat(gridSize),
                           y: 1.0 / CGFloat(gridSize) * CGFloat(y) + 0.5 / CGFloat(gridSize))
        }
        return CGPoint(x: 0.5, y: 0.5)
    }

    private func normalizeWeights() {
        let s: Double = particles.reduce(0, {$0 + $1.weight})
        particles = particles.map({ (p: Particle) -> Particle in
            var p = p
            p.weight = p.weight / s
            return p
        })
    }

//    private func gridToCGPoint(grid: Point) -> CGPoint {
//        return CGPoint(x: UIScreen.main.bounds.size.width * CGFloat(grid.xLoc) / CGFloat(gridSize),
//                     y: UIScreen.main.bounds.size.height * CGFloat(grid.yLoc) / CGFloat(gridSize))
//    }
//
    private func CGPointToGrid(point: CGPoint) -> CGPoint {
        let halfW: CGFloat = UIScreen.main.bounds.size.width / CGFloat(gridSize) / 2.0
        let halfH: CGFloat = UIScreen.main.bounds.size.height / CGFloat(gridSize) / 2.0
        let x = CGFloat(gridSize) * (point.x - halfW) / UIScreen.main.bounds.size.width
        let y = CGFloat(gridSize) * (point.y - halfH) / UIScreen.main.bounds.size.height
        return CGPoint(x: x, y: y)
    }
//
//    private func distVector(a: CGPoint, grid: Point) -> CGPoint {
//        let b = gridToCGPoint(grid: grid)
//        return CGPoint(x: a.x - b.x, y: a.y - b.y)
//    }

    // MARK: - Particle Filtering

    // Update the current set of weights with some new measurement m.
    func updateWeights(measurement: Double) {
        // Consider the dead-reckoning model as well.
//        let dr: CGPoint = CGPointToGrid(point: DeadReckoningModel.sharedModel.currentLocation)
        let dr: CGPoint = CGPoint(x: 0, y: 0)
        var drPull: CGPoint = CGPoint(x: 0, y: 0)
        let damp: CGFloat = 0.001
        for i in particles.indices {
            let op = particles[i]
            var np = Particle(xLoc: op.xLoc, yLoc: op.yLoc, weight: op.weight)
            let y: Double = Map.sharedMap.valueFor(location: Point(xLoc: np.xLoc, yLoc: np.yLoc))
            // Lambda dictates how quicky weights grow.
            let lambda: Double = 0.1
            // Increase the weight of the particle if it is close to the measurement.
            np.weight =
                np.weight * Stats.normalPDF(measure: measurement, mean: y, sigma: 10) * lambda
            // Increase the weight of the particle based on its proximity to the dead reckoning.
            np.weight = np.weight * Stats.normalPDF(measure: Double(op.xLoc),
                                                    mean: Double(dr.x),
                                                    sigma: 5)
            np.weight = np.weight * Stats.normalPDF(measure: Double(op.yLoc),
                                                    mean: Double(dr.y),
                                                    sigma: 5)

            var xFactor = CGGridSize.width * damp
            if dr.x > CGFloat(np.xLoc) {
                xFactor *= -1
            }
            drPull.x += CGFloat(Stats.normalPDF(measure: Double(dr.x),
                                                mean: Double(np.xLoc),
                                                sigma: Double(gridSize))) * xFactor

            var yFactor = CGGridSize.height * damp
            if dr.y > CGFloat(np.yLoc) + 0.5 {
                yFactor *= -1
            }
            drPull.y += CGFloat(Stats.normalPDF(measure: Double(dr.y),
                                                mean: Double(np.yLoc),
                                                sigma: Double(gridSize))) * yFactor
            particles[i] = np
        }
        // Adjust dead reckoning by the net pull on it.
//        DeadReckoningModel.sharedModel.currentLocation += drPull
        // Now normalize the weights.
        normalizeWeights()
        // Now resample
        resampleParticles()
        // Normalize the weights again
        normalizeWeights()
    }

    // Randomly generate a number between 0 and 1
    private func random() -> Double {
        return Double(Float(arc4random()) / Float(UINT32_MAX))
    }

    // Randomly generate a particle with resampling and weights consideration.
    private func generateParticle() -> Particle {
        var rand = random()
        for p in particles {
            rand -= p.weight
            if rand < 0 {
                return p
            }
        }
        return particles.last!
    }

    // Set all the weights to have equal probability.
    private func initializeParticles() {
        let n = numParticles / (gridSize*gridSize)
        let w = Double(1) / Double(numParticles)

        for y in 0..<gridSize {
            for x in 0..<gridSize {
                particles += [Particle](repeating: Particle(xLoc: x, yLoc: y, weight: w), count: n)
            }
        }
    }

    // Create a new set of particles.
    private func resampleParticles() {
        var newParticles = [Particle]()

        // Create some percentage of random particles each time to prevent getting stuck.
        let randomCount: Int = Int(0.1 * Double(numParticles))
        let averageWeight: Double = particles.reduce(0, {$0 + $1.weight}) / Double(numParticles)
        for _ in 0..<randomCount {
            let x = Int(random() * Double(gridSize))
            let y = Int(random() * Double(gridSize))
            newParticles.append(Particle(xLoc: x, yLoc: y, weight: averageWeight))
        }

        for _ in 0..<numParticles - randomCount {
            newParticles.append(generateParticle())
        }
        particles = newParticles
    }

    // Return the probability that user is standing at some point.
    func likelihood(point: Point) -> Double {
        let count = particles.reduce(0, {$0 + Int($1 == point)})
        return Double(count) / Double(particles.count)
    }

    func particleDistribution() -> [Double] {
        var dist = [Double](repeating: 0, count: 10)
        var total: Int = 0
        let minWeight: Double = particles.map({$0.weight}).min()!
        let rangeWeight: Double = particles.map({$0.weight}).max()! - minWeight

        // If the range is 0, theres obviously no varience between the weights.
        if rangeWeight == 0 {
            return [Double](repeating: 0.1, count: 10)
        }

        // Otherwise, lets make something happen.
        for p in particles {
            dist[Int((p.weight - minWeight) / rangeWeight * 9.0)] += 1
            total += 1
        }
        return dist.map({$0 / Double(total)})
    }
}
