enum PropertyTypes { maison, appartement, autre }

String propertyString(PropertyTypes property) {
  switch (property) {
    case PropertyTypes.maison:
      return "Maison";
    case PropertyTypes.appartement:
      return "Appartment";
    case PropertyTypes.autre:
      return "Autre";
  }
}

enum EtatsRapport { enCours, termine }

String etatRapportString(EtatsRapport etat) {
  switch (etat) {
    case EtatsRapport.enCours:
      return "En cours";
    case EtatsRapport.termine:
      return "Terminé";
  }
}

enum EtatsElement {
  ok,
  aReparer,
}

String etatElementString(EtatsElement etat) {
  switch (etat) {
    case EtatsElement.ok:
      return "Bon état";
    case EtatsElement.aReparer:
      return "A réparer";
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
      return "Entrée";
    case RoomTypes.livingRoom:
      return "Salon";
    case RoomTypes.kitchen:
      return "Cuisine";
    case RoomTypes.bathroom:
      return "Salle de bain";
    case RoomTypes.bedroom:
      return "Chambre";
    case RoomTypes.wc:
      return "WC";
    case RoomTypes.other:
      return "Autre";
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
  stove, // Or cooking surface
  refrigeratorSpace,

  // Bathroom/WC specific
  bathtubOrShower,
  toilets,
  sinkVanity, // Using a more specific name for sink in bathroom

  // Living/Bedroom specific
  wardrobe,
  fireplace,
  balconyOrTerrace,
}

String roomElementString(RoomElements element) {
switch (element) {
      // General Structure
      case RoomElements.door:
        return "Porte";
      case RoomElements.walls:
        return "Murs";
      case RoomElements.floor:
        return "Sol";
      case RoomElements.ceiling:
        return "Plafond";
      case RoomElements.window:
        return "Fenêtre";

      // Utilities & Comfort
      case RoomElements.heating:
        return "Chauffage";
      case RoomElements.lighting:
        return "Éclairage";
      case RoomElements.electricalOutlets:
        return "Prises électriques";
      case RoomElements.ventilation:
        return "Ventilation (VMC)";
      case RoomElements.storage:
        return "Rangements";

      // Kitchen specific
      case RoomElements.countertop:
        return "Plan de travail";
      case RoomElements.cabinets:
        return "Meubles de cuisine";
      case RoomElements.sink:
        return "Évier de cuisine";
      case RoomElements.stove:
        return "Plaque de cuisson";
      case RoomElements.refrigeratorSpace:
        return "Emplacement réfrigérateur";

      // Bathroom/WC specific
      case RoomElements.bathtubOrShower:
        return "Baignoire ou douche";
      case RoomElements.toilets:
        return "Toilettes";
      case RoomElements.sinkVanity:
        return "Meuble vasque/Lavabo";

      // Living/Bedroom specific
      case RoomElements.wardrobe:
        return "Penderie/Placard";
      case RoomElements.fireplace:
        return "Cheminée";
      case RoomElements.balconyOrTerrace:
        return "Balcon ou Terrasse";
    }
  
}