// Models/TextWidgetRecord.swift
import Foundation
import CoreTransferable
import UniformTypeIdentifiers

public struct TextWidgetRecord: Codable, Transferable {
  public var id: UUID
  public var x: Double
  public var y: Double
  public var z: Int
  public var width: Double
  public var height: Double
  public var text: String
  public var fontSize: Double

  public static var transferRepresentation: some TransferRepresentation {
    CodableRepresentation(contentType: .visualsTextWidget)
  }
}
