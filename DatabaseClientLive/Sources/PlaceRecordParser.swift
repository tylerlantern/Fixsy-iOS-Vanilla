import Foundation
import Models

func toCarBrand(_ r: CarBrandRecord) -> CarBrand {
  CarBrand(
    id: r.id,
    displayName: r.displayName
  )
}

func toPlace(record r: PlaceInfo) -> Place {
  func toImage(
    _ r: ImageRecord
  ) -> Place.Image {
    .init(id: r.id, url: r.url)
  }

  let p = r.place
  return Place(
    id: p.id,
    name: p.name,
    latitude: p.latitude,
    longitude: p.longitude,
    address: p.address,
    hasMotorcycleGarage: p.hasMotorcycleGarage,
    hasInflationStation: p.hasInflationStation,
    hasWashStation: p.hasWashStation,
    hasPatchTireStation: p.hasPatchTireStation,
    hasCarGarage: p.hasCarGarage,
    averageRate: p.averageRate,
    carGarage: Place.CarGarage(brands: r.carBrands.map(toCarBrand)),
    openCloseTime: .init(
      mondayOpen: p.mondayOpen,
      mondayClose: p.mondayClose,
      tuesdayOpen: p.tuesdayOpen,
      tuesdayClose: p.tuesdayClose,
      wednesdayOpen: p.wednesdayOpen,
      wednesdayClose: p.wednesdayClose,
      thursdayOpen: p.thursdayOpen,
      thursdayClose: p.thursdayClose,
      fridayOpen: p.fridayOpen,
      fridayClose: p.fridayClose,
      saturdayOpen: p.saturdayOpen,
      saturdayClose: p.saturdayClose,
      sundayOpen: p.sundayOpen,
      sundayClose: p.sundayClose
    ),
    images: r.images.map(toImage),
    contributorName: p.contributorName
  )
}

func toCarBrandRecord(
  _ b: CarBrand
) -> CarBrandRecord {
  CarBrandRecord(
    id: b.id, displayName: b.displayName
  )
}

func toPlaceRecord(place p: Place) -> PlaceInfo {
  func toImageRecord(
    placeId: Int,
    _ r: Place.Image
  ) -> ImageRecord {
    ImageRecord(
      id: r.id,
      url: r.url,
      placeId: placeId
    )
  }

  let oct = p.openCloseTime
  return PlaceInfo(
    place: .init(
      id: p.id,
      name: p.name,
      latitude: p.latitude,
      longitude: p.longitude,
      address: p.address,
      hasMotorcycleGarage: p.hasMotorcycleGarage,
      hasInflationStation: p.hasInflationStation,
      hasWashStation: p.hasWashStation,
      hasPatchTireStation: p.hasPatchTireStation,
      hasCarGarage: p.hasCarGarage,
      averageRate: p.averageRate,
      mondayOpen: oct.mondayOpen,
      mondayClose: oct.mondayClose,
      tuesdayOpen: oct.tuesdayOpen,
      tuesdayClose: oct.tuesdayClose,
      wednesdayOpen: oct.wednesdayOpen,
      wednesdayClose: oct.wednesdayClose,
      thursdayOpen: oct.thursdayOpen,
      thursdayClose: oct.thursdayClose,
      fridayOpen: oct.fridayOpen,
      fridayClose: oct.fridayClose,
      saturdayOpen: oct.saturdayOpen,
      saturdayClose: oct.saturdayClose,
      sundayOpen: oct.sundayOpen,
      sundayClose: oct.sundayClose,
      contributorName: p.contributorName
    ),
    images: p.images.map({
      toImageRecord(placeId: p.id, $0)
    }),
    carBrands: p.carGarage?.brands.map(toCarBrandRecord) ?? []
  )
}
