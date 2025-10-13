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

enum EtatsElement{
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

enum RoomElements{
  door,
  walls,
  floor,
  ceiling,
  window,
  sink,
  faucets,
  appliances,
  bathtubOrShower,
  toilets
}

String roomElementString(RoomElements element) {
  switch (element) {
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
    case RoomElements.sink:
      return "Évier";
    case RoomElements.faucets:
      return "Robinetterie";
    case RoomElements.appliances:
      return "Électroménager";
    case RoomElements.bathtubOrShower:
      return "Baignoire ou douche";
    case RoomElements.toilets:
      return "Toilettes";
  }
}