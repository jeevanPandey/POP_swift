

import Foundation

struct ServiceResponse: Codable {
  let recordings: [Recording]
  let page: Int
  let numPages: Int
}
