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

String etatString(EtatsRapport etat) {
  switch (etat) {
    case EtatsRapport.enCours:
      return "In Progress";
    case EtatsRapport.termine:
      return "Finished";
  }
}

enum EtatsElement { ok, aReparer }
