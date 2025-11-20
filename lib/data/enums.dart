enum PropertyTypes { maison, appartement, autre }

String propertyString(PropertyTypes property) {
  switch (property) {
    case PropertyTypes.maison:
      return "House";
    case PropertyTypes.appartement:
      return "Apartment";
    case PropertyTypes.autre:
      return "Other";
  }
}

enum EtatsRapport { enCours, termine }

String etatRapportString(EtatsRapport etat) {
  switch (etat) {
    case EtatsRapport.enCours:
      return "In progress";
    case EtatsRapport.termine:
      return "Finished";
  }
}

enum EtatsElement {
  ok,
  aReparer,
}

String etatElementString(EtatsElement etat) {
  switch (etat) {
    case EtatsElement.ok:
      return "Ok";
    case EtatsElement.aReparer:
      return "Damaged";
  }
}


enum RoomTypes{
  entrance,
  livingRoom,
  kitchen,
  bathroom,
  bedroom,
  wc,
  other,
}

String roomTypeString(RoomTypes type) {
  switch (type) {
    case RoomTypes.entrance:
      return "Entrance";
    case RoomTypes.livingRoom:
      return "Living Room";
    case RoomTypes.kitchen:
      return "Kitchen";
    case RoomTypes.bathroom:
      return "Bathroom";
    case RoomTypes.bedroom:
      return "Bedroom";
    case RoomTypes.wc:
      return "WC";
    case RoomTypes.other:
      return "Other";
  }
}


enum RoomElements {
  // General Structure
  walls,
  floor,
  ceiling,
  window,
  door,

  // Utilities & Comfort
  heating,
  lighting,
  electricalOutlets,
  ventilation, // General ventilation/VMC
  storage,

  // Kitchen specific
  countertop,
  cabinets,
  sink,
  stove,
  refrigeratorSpace,

  // Bathroom/WC specific
  bathtubOrShower,
  toilets,
  sinkVanity, 

  // Living/Bedroom specific
  wardrobe,
  fireplace,
  balconyOrTerrace,
}

String roomElementString(RoomElements element) {
switch (element) {
      // General Structure
      case RoomElements.door:
        return "Door";
      case RoomElements.walls:
        return "Walls";
      case RoomElements.floor:
        return "Floor";
      case RoomElements.ceiling:
        return "Ceiling";
      case RoomElements.window:
        return "Window";

      // Utilities & Comfort
      case RoomElements.heating:
        return "Heating";
      case RoomElements.lighting:
        return "Lighting";
      case RoomElements.electricalOutlets:
        return "Electrical Outlets";
      case RoomElements.ventilation:
        return "Ventilation (VMC)";
      case RoomElements.storage:
        return "Storage";

      // Kitchen specific
      case RoomElements.countertop:
        return "Countertop";
      case RoomElements.cabinets:
        return "Cabinets";
      case RoomElements.sink:
        return "Sink";
      case RoomElements.stove:
        return "Stove/Cooking Surface";
      case RoomElements.refrigeratorSpace:
        return "Refrigerator Space";

      // Bathroom/WC specific
      case RoomElements.bathtubOrShower:
        return "Bathtub or Shower";
      case RoomElements.toilets:
        return "Toilets";
      case RoomElements.sinkVanity:
        return "Sink/Vanity";

      // Living/Bedroom specific
      case RoomElements.wardrobe:
        return "Wardrobe";
      case RoomElements.fireplace:
        return "Fireplace";
      case RoomElements.balconyOrTerrace:
        return "Balcony or Terrace";
    }
  
}