import 'package:flutter/material.dart';

class Cosas extends StatefulWidget {
  const Cosas({super.key});

  @override
  State<Cosas> createState() => _CosasState();
}

class _CosasState extends State<Cosas> {
  final bool _showDatePicker = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Muchas cositas')),
        body: Column(
          children: <Widget>[
            FormApp(
              showDatePicker: _showDatePicker,
              openDatePicker: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DatePickerExample(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FormApp extends StatefulWidget {
  final bool showDatePicker;
  final VoidCallback openDatePicker;

  const FormApp({Key? key, required this.showDatePicker, required this.openDatePicker})
      : super(key: key);

  @override
  State<FormApp> createState() => _FormState();
}
//form
class _FormState extends State<FormApp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _Texto = "";
  bool _isChecked = false;
  bool _isCheckedVisible = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Ingresa lo que gustes',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Necesita ingresar algo, loco';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _Texto = value;
                _updateCheckboxVisibility();
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _showAlertDialog(context);
                }
              },
              child: const Text('Ingresar'),
            ),
          ),
          Visibility(
            visible: _isCheckedVisible,
            child: Checkbox(
              value: _isChecked,
              onChanged: (bool? value) {
                setState(() {
                  _isChecked = value ?? false;
                  widget.openDatePicker();
                });
              },
            ),
          ),
          Visibility(
            visible: widget.showDatePicker,
            child: OutlinedButton(
              onPressed: () {
                widget.openDatePicker();
              },
              child: const Text('Abrir calendario'),
            ),
          ),
        ],
      ),
    );
  }

//alerta
  void _showAlertDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('¿Ingresó el apodo de mi creador?'),
        content: MyLista(),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Salir'),
            child: const Text('Salir'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'Lo hare');
            },
            child: const Text('Lo hare'),
          ),
          
        ],
      ),
    );
  }

  void _updateCheckboxVisibility() {
    setState(() {
      _isCheckedVisible = _Texto == "shuy";
    });
  }
}
//list

//date 
class DatePickerExample extends StatefulWidget {
  const DatePickerExample({super.key, this.restorationId});

  final String? restorationId;

  @override
  State<DatePickerExample> createState() => _DatePickerExampleState();
}

class _DatePickerExampleState extends State<DatePickerExample> with RestorationMixin {
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture;
  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime(2023, 9, 07));

  @override
  String? get restorationId => widget.restorationId;

  @override
  void initState() {
    super.initState();
    _restorableDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
      onComplete: _selectDate,
      onPresent: (NavigatorState navigator, Object? arguments) {
        return navigator.restorablePush(
          _datePickerRoute,
          arguments: _selectedDate.value.millisecondsSinceEpoch,
        );
      },
    );
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Selected: ${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}'),
        ));
      });
    }
  }

  void presentDatePicker() {
    _restorableDatePickerRouteFuture.present();
  }

  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2023),
          lastDate: DateTime(2024),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {
                presentDatePicker();
              },
              child: const Text('Open Date Picker'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
                //aqui falta
              },
              child: const Text('Volver al Formulario'),
            ),
          ],
        ),
      ),
    );
  }
}

//list

class ToDo {
  final String title;
  bool isDone;

  ToDo({
    required this.title,
    this.isDone = false,
  });
}

class MyLista extends StatefulWidget {
  const MyLista({Key? key}) : super(key: key);

  @override
  _Lista createState() => _Lista();
}

class _Lista extends State<MyLista> {
  List<ToDo> MiLista = [
    ToDo(title: "jesus"),
    ToDo(title: "ivan"),
    ToDo(title: "mi amor"),
    ToDo(title: "shuy"),
    ToDo(title: "mi pen#%!o"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posibles apodos'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: MiLista.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(MiLista[index].title),
          );
        },
      ),
    );
  }
}