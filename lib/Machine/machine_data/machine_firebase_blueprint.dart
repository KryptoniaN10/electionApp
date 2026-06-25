class MachineFirebaseBlueprint {
  const MachineFirebaseBlueprint._();

  // This file intentionally stays dependency-free for now so the project compiles
  // before Firebase is initialized. When you add `cloud_firestore` and auth config,
  // these snippets can move into a real service layer.

  static const String dashboardReadExample = '''
// final machineDoc = await FirebaseFirestore.instance
//     .collection('machines')
//     .doc(machineId)
//     .snapshots();
//
// final commandDoc = await FirebaseFirestore.instance
//     .collection('machine_commands')
//     .doc(machineId)
//     .snapshots();
''';

  static const String ballotGrantExample = '''
// final grantStream = FirebaseFirestore.instance
//     .collection('voter_grants')
//     .doc(machineId)
//     .snapshots();
//
// if (grantDoc['granted'] == true) {
//   // show ballot
// }
''';

  static const String candidateImageExample = '''
// final candidates = await FirebaseFirestore.instance
//     .collection('elections')
//     .doc(electionId)
//     .collection('candidates')
//     .get();
//
// final photoUrl = candidateDoc['photo_url'];
''';
}
