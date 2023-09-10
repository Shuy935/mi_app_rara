import 'package:flutter/material.dart';

class Cosas extends StatefulWidget {
  const Cosas({super.key});

  @override
  State<Cosas> createState() => _CosasState();
}

class AppGlobals {
  bool isChecked = false;
  AppGlobals._privateConstructor();
  static final AppGlobals instance = AppGlobals._privateConstructor();
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
                  builder: (context) => const DatePickerExample(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

//form
class FormApp extends StatefulWidget {
  final bool showDatePicker;
  final VoidCallback openDatePicker;

  const FormApp(
      {Key? key, required this.showDatePicker, required this.openDatePicker})
      : super(key: key);

  @override
  State<FormApp> createState() => _FormState();
}

class _FormState extends State<FormApp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _Texto = "";
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
              value: AppGlobals.instance.isChecked,
              onChanged: (bool? value) {
                setState(() {
                  AppGlobals.instance.isChecked = value ?? false;
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
        content: Container(
          height: 350,
          child: const MyLista(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'Entendido!');
            },
            child: const Text('Entendido!'),
          ),
        ],
      ),
    );
  }

  void _updateCheckboxVisibility() {
    setState(() {
      _isCheckedVisible = _Texto == "shuy" || _Texto == "Shuy";
    });
  }
}

//date
class DatePickerExample extends StatefulWidget {
  const DatePickerExample({super.key, this.restorationId});

  final String? restorationId;

  @override
  State<DatePickerExample> createState() => _DatePickerExampleState();
}

class _DatePickerExampleState extends State<DatePickerExample>
    with RestorationMixin {
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture;
  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());

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
      _selectedDate.value = newSelectedDate;
      if (_selectedDate.value.day == 21 && _selectedDate.value.month == 9 && _selectedDate.value.year == 2023) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const Nav(),
        ));
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Felicidades, lo lograste!'),
          ));
        });
      } else {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Seleccionado: ${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}'),
          ));
        });
      }
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
          helpText: 'Seleccione el cumpleaños de mi creador',
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
              child: const Text('Abrir calendario'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  AppGlobals.instance.isChecked = false;
                });
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

//nav
class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Card1(),
    Card2(),
    Card3(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.one_k),
          label: 'Fijate',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.two_k),
          label: 'Bien',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.three_k),
          label: 'En todo',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 7, 44, 255),
      onTap: _onItemTapped,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            setState(() {
              AppGlobals.instance.isChecked = false;
            });
            Navigator.of(context).pop();
          },
        ),
        title: const Text('My aplicacion'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

//card

class Card1 extends StatelessWidget {
  const Card1({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Card(
        child: SizedBox(
          width: 300,
          height: 100,
          child: Center(child: Text('Esto es una carta elevada')),
        ),
      ),
    );
  }
}

class Card2 extends StatelessWidget {
  const Card2({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const Scroll(),
        ));
      },
      child: const Card(
        elevation: 0,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: 300,
          height: 100,
          child: Center(child: Text('Esto es una carta "normal"')),
        ),
      ),
    );
  }
}

class Card3 extends StatelessWidget {
  const Card3({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: const SizedBox(
          width: 300,
          height: 100,
          child: Center(child: Text('Esto es una carta delineada')),
        ),
      ),
    );
  }
}

//scrollview

class Scroll extends StatelessWidget {
  const Scroll({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Este personaje es carnal de "el donas"'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Aquí puedes agregar la navegación para volver a la pantalla anterior
              Navigator.of(context).pop();
            },
          ),
        ),
        body: const SingleChildScrollView(
          child: Column(
            children: <Widget>[
              RadioB(),
            ],
          ),
        ),
      ),
    );
  }
}

//radio

enum SingingCharacter {
  luffy,
  nami,
  usopp,
  chopper,
  sanji,
  zoro,
  brook,
  franky,
  robin
}

class RadioB extends StatefulWidget {
  const RadioB({super.key});

  @override
  State<RadioB> createState() => _RadioBState();
}

class _RadioBState extends State<RadioB> {
  SingingCharacter? _character = SingingCharacter.brook;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('Chopper'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.chopper,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Franky'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.franky,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Luffy'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.luffy,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const DrawerM(),
              ));
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Nami'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.nami,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Robin'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.robin,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Sanji'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.sanji,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Usopp'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.usopp,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Zoro'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.zoro,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Brook'),
          leading: Radio<SingingCharacter>(
            value: SingingCharacter.brook,
            groupValue: _character,
            onChanged: (SingingCharacter? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
      ],
    );
  }
}

//drawer
class DrawerM extends StatelessWidget {
  const DrawerM({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viva mexico cabrones!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              height: 200,
              child: CustomPaint(
                painter: MexicoFlagPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MexicoFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rectn = Rect.fromLTRB(0, 0, size.width, size.height);
    final Rect rectv = Rect.fromLTRB(1, 1, size.width / 3, size.height - 1);
    final Rect rectb = Rect.fromLTRB(
        (size.width) / 3, 1, ((size.width) / 3) * 2, size.height - 1);
    final Rect rectr = Rect.fromLTRB(
        ((size.width) / 3) * 2, 1, size.width - 1, size.height - 1);

    final negroPaint = Paint()..color = const Color.fromARGB(255, 0, 0, 0);
    canvas.drawRect(rectn, negroPaint);
    final rojoPaint = Paint()..color = Colors.red;
    canvas.drawRect(rectr, rojoPaint);
    final blancoPaint = Paint()..color = Colors.white;
    canvas.drawRect(rectb, blancoPaint);
    final verdePaint = Paint()..color = Colors.green;
    canvas.drawRect(rectv, verdePaint);
    final amarishoPaint = Paint()
      ..color = const Color.fromARGB(255, 233, 229, 17);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 7;
    canvas.drawCircle(center, radius, amarishoPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
