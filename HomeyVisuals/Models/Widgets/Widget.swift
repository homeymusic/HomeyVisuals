// Widget.swift
import Foundation

protocol Widget: Identifiable {
    var id: UUID { get }
    var slide: Slide? { get set }
    var x: Double { get set }
    var y: Double { get set }
}
