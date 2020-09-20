import 'package:hepitrack/models/body_part.dart';
import 'package:hepitrack/models/symptom.dart';

class Constants {
  static List<Symptom> allSymptoms = [
    Symptom(
      id: 1,
      name: 'Fever',
      image: 'assets/symptom/fever.png',
      defaultBodyPart: 1,
    ),
    Symptom(
      id: 2,
      name: 'Exhaustion',
      image: 'assets/symptom/exhaustion.png',
      defaultBodyPart: 1,
    ),
    Symptom(
      id: 3,
      name: 'Pain',
      image: 'assets/symptom/pain.png',
    ),
    Symptom(
      id: 4,
      name: 'Cough',
      image: 'assets/symptom/cough.png',
      defaultBodyPart: 8,
    ),
    Symptom(
      id: 5,
      name: 'Leak',
      image: 'assets/symptom/leak.png',
    ),
    Symptom(
      id: 6,
      name: 'Poop',
      image: 'assets/symptom/poop.png',
      defaultBodyPart: 17,
    ),
    Symptom(
      id: 7,
      name: 'Skin',
      image: 'assets/symptom/skin.png',
    ),
    Symptom(
      id: 8,
      name: 'Other',
      image: 'assets/symptom/other.png',
    ),
  ];

  static List<BodyPart> partList = [
    BodyPart(id: 1, name: 'None'),
    BodyPart(id: 2, name: 'Head'),
    BodyPart(id: 3, name: 'Throat'),
    BodyPart(id: 4, name: 'Right Arm'),
    BodyPart(id: 5, name: 'Left Arm'),
    BodyPart(id: 6, name: 'Right Hand'),
    BodyPart(id: 7, name: 'Left Hand'),
    BodyPart(id: 8, name: 'Chest'),
    BodyPart(id: 9, name: 'Stomach'),
    BodyPart(id: 10, name: 'Crotch'),
    BodyPart(id: 11, name: 'Right Leg'),
    BodyPart(id: 12, name: 'Left Leg'),
    BodyPart(id: 13, name: 'Right Foot'),
    BodyPart(id: 14, name: 'Left Foot'),
    BodyPart(id: 15, name: 'Back'),
    BodyPart(id: 16, name: 'Uppor Back'),
    BodyPart(id: 17, name: 'Bowel'),
  ];
}
