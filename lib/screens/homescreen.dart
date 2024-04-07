import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hiveproj/models/PersonModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ageController = TextEditingController();
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HIVE Data"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<PersonModel>('persons').listenable(),
        builder: (context, box, _) {
          var data = box.values.toList().cast<PersonModel>();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              itemCount: box.length,
              reverse: true,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return buildCard(context, data[index], index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          showDialogToAddOrUpdate(context);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildCard(BuildContext context, PersonModel person, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: Colors.amber,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Name : ${person.name}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 15),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      deletePerson(index);
                    },
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      showDialogToAddOrUpdate(context,
                          person: person, index: index);
                    },
                  ),
                ],
              ),
              Text(
                "Age : ${person.age.toString()}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showDialogToAddOrUpdate(BuildContext context,
      {PersonModel? person, int? index}) {
    final isEditing = person != null;
    nameController.text = isEditing ? person.name : '';
    ageController.text = isEditing ? person.age.toString() : '';

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit details' : 'Add person details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter Age',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    ageController.text.isNotEmpty) {
                  final newData = PersonModel(
                    name: nameController.text,
                    age: int.parse(ageController.text),
                  );
                  if (isEditing) {
                    editPerson(index!, newData);
                  } else {
                    addPerson(newData);
                  }
                  nameController.clear();
                  ageController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Edit' : 'Add details'),
            ),
          ],
        );
      },
    );
  }

  void deletePerson(int index) {
    Hive.box<PersonModel>('persons').deleteAt(index);
  }

  void editPerson(int index, PersonModel newData) {
    Hive.box<PersonModel>('persons').putAt(index, newData);
  }

  void addPerson(PersonModel newData) {
    Hive.box<PersonModel>('persons').add(newData);
  }
}
