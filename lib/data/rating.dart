enum Rating {
  inactive,
  suspended,
  observer,
  towerTrainee,
  towerController,
  seniorStudent,
  enrouteController,
  controller2,
  eniorController,
  instructor,
  instructor2,
  seniorInstructor,
  supervisor,
  administrator
}

extension RatingExt on Rating {
  String get long {
    switch (this) {
      case Rating.inactive:
        return "inactive";
      case Rating.suspended:
        return "suspended";
      case Rating.observer:
        return "observer";
      case Rating.towerTrainee:
        return "Tower Trainee";
      case Rating.towerController:
        return "Tower Controller";
      case Rating.seniorStudent:
        return "Senior Student";
      case Rating.enrouteController:
        return "Enroute Controller";
      case Rating.controller2:
        return "Controller 2";
      case Rating.eniorController:
        return "Senior Controller";
      case Rating.instructor:
        return "instructor";
      case Rating.instructor2:
        return "instructor 2";
      case Rating.seniorInstructor:
        return "Senior instructor";
      case Rating.supervisor:
        return "supervisor";
      case Rating.administrator:
        return "administrator";
    }
  }

  String get short {
    switch (this) {
      case Rating.inactive:
        return "INAC";
      case Rating.suspended:
        return "SUS";
      case Rating.observer:
        return "OBS";
      case Rating.towerTrainee:
        return "S1";
      case Rating.towerController:
        return "S2";
      case Rating.seniorStudent:
        return "S3";
      case Rating.enrouteController:
        return "C1";
      case Rating.controller2:
        return "C2";
      case Rating.eniorController:
        return "C3";
      case Rating.instructor:
        return "I1";
      case Rating.instructor2:
        return "I2";
      case Rating.seniorInstructor:
        return "I3";
      case Rating.supervisor:
        return "SUP";
      case Rating.administrator:
        return "ADM";
    }
  }

  static Rating fromId(int id) {
    switch (id) {
      case -1:
        return Rating.inactive;
      case 0:
        return Rating.suspended;
      case 1:
        return Rating.observer;
      case 2:
        return Rating.towerTrainee;
      case 3:
        return Rating.towerController;
      case 4:
        return Rating.seniorStudent;
      case 5:
        return Rating.enrouteController;
      case 6:
        return Rating.controller2;
      case 7:
        return Rating.eniorController;
      case 8:
        return Rating.instructor;
      case 9:
        return Rating.instructor2;
      case 10:
        return Rating.seniorInstructor;
      case 11:
        return Rating.supervisor;
      case 12:
        return Rating.administrator;
      default:
        throw Exception("Invalid rating id: $id");
    }
  }
}
