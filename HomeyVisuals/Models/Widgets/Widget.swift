// Widget.swift
import Foundation

protocol Widget: Identifiable {
    var id: UUID { get }
    var x: Double { get set }   // normalized 0...1
    var y: Double { get set }   // normalized 0...1
}
